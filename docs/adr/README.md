# Architecture Decision Records

One file per significant decision: `NNNN-short-title.md`. A decision is significant if
reversing it would be expensive, or if a future maintainer would otherwise ask "why on
earth is it like this?"

Record the decision when it is made, not later. An ADR is short — a page at most.

## Template

```markdown
# NNNN. <Decision in a sentence>

- Status: proposed | accepted | superseded by NNNN
- Date: YYYY-MM-DD
- Deciders: <names>

## Context
What forced a decision. Constraints, deadlines, what we knew and did not know.

## Decision
What we are doing, stated plainly in the present tense.

## Alternatives considered
Each option and the specific reason it lost.

## Consequences
What this makes easy, what it makes hard, what we now have to live with, and what would
make us revisit it.
```

Supersede rather than edit: a wrong ADR is still a true record of what was decided.
Reference the ADR number in the developer changelog entry for the change that implements it.
