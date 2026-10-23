# At-rest encryption for .env secrets.
#
# Any value in a .env (here, every key whose name ends in PASSWORD / PASSWD /
# SECRET / TOKEN / API_KEY / PRIVATE_KEY / ACCESS_KEY, plus anything you encrypt
# by hand) may be stored either as plain text or encrypted:
#
#     DB_PASSWORD="Warrior#312"
#     DB_PASSWORD=encrypted:<base64( IV || ciphertext )>
#
# Encrypted values are AES-256-CBC. The key is derived (PBKDF2-SHA256) from a
# passphrase and salt kept in a key file under $HOME, never in the repo:
#
#     ~/.config/env-secrets/env.key   (override with $env:ENV_SECRET_KEYFILE)
#
# Reads are transparent: a config/inventory loader calls Unprotect-EnvSecret on
# every value, so a plain value passes through untouched and an encrypted one is
# decrypted on the fly. A plain .env therefore needs no key file at all; only an
# 'encrypted:' value requires one.
#
# Usage:
#     . ./scripts/env-secrets.ps1                 # dot-source the functions
#     Initialize-EnvKey                           # once per machine/repo
#     Update-EnvSecrets -Path .env                # encrypt plaintext PASSWORD values
#     Unprotect-EnvSecret $value                  # read a value back
#
# Or run it directly to encrypt a file in place:
#     pwsh ./scripts/env-secrets.ps1 -Path .env

[CmdletBinding()]
param(
    # When invoked directly (not dot-sourced), the .env to encrypt in place.
    [string]$Path,
    [switch]$NoBackup
)

$script:EnvKeyCache = $null

function Get-EnvKeyFilePath {
    # One shared key file for all repos. Override with $env:ENV_SECRET_KEYFILE.
    if ($env:ENV_SECRET_KEYFILE) { return $env:ENV_SECRET_KEYFILE }
    $base = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { '.' }
    return (Join-Path (Join-Path $base '.config') (Join-Path 'env-secrets' 'env.key'))
}

function Initialize-EnvKey {
    # Creates a new key file with a random passphrase + salt. Refuses to clobber an
    # existing key (that would orphan everything already encrypted) unless -Force.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path = (Get-EnvKeyFilePath),
        [int]$Iterations = 200000,
        [switch]$Force
    )
    if ((Test-Path -LiteralPath $Path) -and -not $Force) {
        throw "Key file already exists: $Path. Use -Force to overwrite (this invalidates every value encrypted with the old key)."
    }
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        $null = New-Item -ItemType Directory -Path $dir -Force
    }
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $passBytes = [byte[]]::new(32); $rng.GetBytes($passBytes)
        $saltBytes = [byte[]]::new(16); $rng.GetBytes($saltBytes)
    } finally { $rng.Dispose() }
    $material = [ordered]@{
        passphrase = [Convert]::ToBase64String($passBytes)
        salt       = [Convert]::ToBase64String($saltBytes)
        iterations = $Iterations
    }
    if ($PSCmdlet.ShouldProcess($Path, 'write new .env encryption key')) {
        Set-Content -LiteralPath $Path -Value ($material | ConvertTo-Json) -NoNewline
        # Best-effort lockdown so the key is owner-only on Unix-like systems.
        if ($IsLinux -or $IsMacOS) { & chmod 600 $Path 2>$null }
    }
    $script:EnvKeyCache = $null
    return $Path
}

function Get-EnvKey {
    # Derives (and caches) the 32-byte AES key from the key file.
    param([string]$Path = (Get-EnvKeyFilePath))
    if ($script:EnvKeyCache) { return $script:EnvKeyCache }
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "An encrypted .env value was found but no key file exists at '$Path'. Create one with Initialize-EnvKey, or point `$env:ENV_SECRET_KEYFILE at the right file."
    }
    $material = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    $passBytes = [Convert]::FromBase64String($material.passphrase)
    $saltBytes = [Convert]::FromBase64String($material.salt)
    $iter = [int]$material.iterations
    $kdf = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
        $passBytes, $saltBytes, $iter, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
    try { $key = $kdf.GetBytes(32) } finally { $kdf.Dispose() }
    $script:EnvKeyCache = $key
    return $key
}

function Test-EncryptedValue {
    param([AllowEmptyString()][string]$Value)
    return ($null -ne $Value -and $Value -match '^\s*encrypted:')
}

function Protect-EnvSecret {
    # Plain text -> 'encrypted:<base64(IV||ciphertext)>'.
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$PlainText,
        [string]$Path = (Get-EnvKeyFilePath)
    )
    $key = Get-EnvKey -Path $Path
    $aes = [System.Security.Cryptography.Aes]::Create()
    try {
        $aes.Key = $key; $aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'; $aes.GenerateIV()
        $encryptor = $aes.CreateEncryptor()
        $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
        $cipher = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
        $blob = $aes.IV + $cipher
        return 'encrypted:' + [Convert]::ToBase64String($blob)
    } finally { $aes.Dispose() }
}

function Unprotect-EnvSecret {
    # 'encrypted:<base64>' -> plain text. A non-encrypted value is returned as-is,
    # so this is safe to call on every .env value and needs no key for plain ones.
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Value,
        [string]$Path = (Get-EnvKeyFilePath)
    )
    if (-not (Test-EncryptedValue $Value)) { return $Value }
    $b64 = ($Value -replace '^\s*encrypted:\s*', '')
    $blob = [Convert]::FromBase64String($b64)
    if ($blob.Length -le 16) { throw 'Encrypted value is too short to contain an IV and ciphertext.' }
    $key = Get-EnvKey -Path $Path
    $aes = [System.Security.Cryptography.Aes]::Create()
    try {
        $aes.Key = $key; $aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'
        $aes.IV = [byte[]]($blob[0..15])
        $cipher = [byte[]]($blob[16..($blob.Length - 1)])
        $decryptor = $aes.CreateDecryptor()
        $plainBytes = $decryptor.TransformFinalBlock($cipher, 0, $cipher.Length)
        return [System.Text.Encoding]::UTF8.GetString($plainBytes)
    } finally { $aes.Dispose() }
}

function Update-EnvSecrets {
    # Rewrites a .env in place, encrypting every plain-text value whose key matches
    # $SecretKeyPattern. Already-encrypted and empty values are left alone, and all other
    # lines (comments, blanks, non-password keys) are preserved verbatim. A .bak of
    # the original is written first unless -NoBackup.
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$KeyFile = (Get-EnvKeyFilePath),
        # Which keys count as secrets to encrypt, matched against the key name.
        [string]$SecretKeyPattern = '(?i)(PASSWORD|PASSWD|SECRET|TOKEN|API_?KEY|PRIVATE_KEY|ACCESS_KEY)$',
        [switch]$NoBackup
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Env file not found: $Path" }
    $null = Get-EnvKey -Path $KeyFile   # fail early if the key is missing/bad

    $changed = 0
    $skipped = 0
    $out = foreach ($line in (Get-Content -LiteralPath $Path)) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith('#') -or $line -notmatch '^(?<key>[^=]+)=(?<val>.*)$') {
            $line; continue
        }
        $key = $Matches.key
        $rawVal = $Matches.val
        if ($key.TrimEnd() -notmatch $SecretKeyPattern) { $line; continue }

        if (Test-EncryptedValue $rawVal) { $skipped++; $line; continue }
        # Unquote to recover the true secret before encrypting.
        $plain = $rawVal.Trim()
        if ($plain.Length -ge 2 -and
            (($plain.StartsWith('"') -and $plain.EndsWith('"')) -or
             ($plain.StartsWith("'") -and $plain.EndsWith("'")))) {
            $plain = $plain.Substring(1, $plain.Length - 2)
        }
        if ([string]::IsNullOrEmpty($plain)) { $line; continue }

        $changed++
        "$key=$(Protect-EnvSecret -PlainText $plain -Path $KeyFile)"
    }

    $backup = $null
    if ($PSCmdlet.ShouldProcess($Path, "encrypt $changed password value(s)")) {
        if ($changed -gt 0 -and -not $NoBackup) {
            $backup = "$Path.bak"
            Copy-Item -LiteralPath $Path -Destination $backup -Force
        }
        Set-Content -LiteralPath $Path -Value $out
    }
    return [pscustomobject]@{ Path = $Path; Encrypted = $changed; AlreadyEncrypted = $skipped; Backup = $backup }
}

# When run directly (not dot-sourced) with -Path, encrypt that file in place.
# Dot-sourcing (`. ./scripts/env-secrets.ps1`) defines the functions and does nothing.
if ($MyInvocation.InvocationName -ne '.' -and $Path) {
    Update-EnvSecrets -Path $Path -NoBackup:$NoBackup
}
