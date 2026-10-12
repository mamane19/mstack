---
name: grilling
description: Interview me about a plan, decision, or idea until every branch is settled, with your recommended answer on each question. Use for /grilling.
disable-model-invocation: true
triggers: [user]
---

# Grilling

Interview me until we share one understanding of the plan. Do not build anything during the interview.

## Map the decisions

Treat the plan as a tree of decisions. Each decision opens the decisions that depend on it.

The frontier is every open decision whose prerequisites are already settled. Ask the whole frontier in one round, then wait for my answers.

A question that depends on another open question in the same round belongs to a later round.

## Format each round

Number each question and put your recommended answer under it:

```
**Q1. <short title>**
<the question, with the options if there are several>
Recommended: <your answer and the one-line reason>
```

Word each question so "yes" accepts your recommendation.

Put the question with the biggest consequence first.

## Facts are yours, decisions are mine

- Before you ask, look up every fact you can: the code, the docs, the data (read-only), the history.
- Never ask me for a fact you could find yourself.
- If a lookup is still running, ask the questions that do not depend on it now.
- Put each decision to me, and wait for the answer.

## After each round

Recompute the frontier from my answers. Settled decisions open new questions.

If my answer contradicts something you found, say so once, with the evidence.

## Finish

The interview ends when the frontier is empty and nothing is silently assumed.

Then write the result as a short list: each decision, and the answer we settled on.

Act on it only after I confirm the list.
