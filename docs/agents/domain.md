# Domain docs

For an agent skill that arrived here without reading `AGENTS.md` first.

**Read [AGENTS.md](../../AGENTS.md).** Its *Where things live* table says which file owns what, and
its *What wins* section says which one to believe when two disagree. This file adds only what a
skill needs on top of that.

This repository holds one context. There is no `CONTEXT-MAP.md`, and there are no per-context ADR
folders.

## These documents came first

A skill may expect a glossary to grow late, and to be a draft it can extend as it goes. Here the
words and the records were written before the code, and the code is still small.

So when your output and a document disagree, the document is more likely to be right. Say so and
stop, rather than writing around it.

## Some of your proposals are build errors

The package boundaries under *Package boundaries* in `AGENTS.md` are not preferences to weigh
against a benefit. Read the rule there.

Before you propose crossing one, read
[ADR-0004](../adr/0004-pure-domain-core-feature-shell.md) and
[ADR-0018](../adr/0018-ui-package-and-widgetbook.md). Both already reject the usual arguments for
it, including the one you are about to make.

## Do not summarise the glossary

`CONTEXT.md` is the only copy of the words and of the `_Avoid_` lists. They change. Read them
there, never from a summary, including any summary in this file.
