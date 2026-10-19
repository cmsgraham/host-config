---
name: crlf-checkout-breaks-gofmt-gate
description: "A Go acceptance check that runs `gofmt -l` fails on a pristine SnoopyFrog v3 checkout, because core.autocrlf=true gives every .go file CRLF; fix with connector/.gitattributes *.go text eol=lf"
metadata: 
  node_type: memory
  type: project
  originSessionId: b17d8e8e-c36f-46a5-9de4-a626e6d3977d
  modified: 2026-09-12T05:38:25.350Z
---

TASK-12.9's `go-vet-clean` check (`test -z "$(gofmt -l .)" && go vet ./...`) failed
before a line of the task was written: this repo is a CRLF checkout
(repo-local `core.autocrlf=true`, CLAUDE.md "Line endings"), the root
`.gitattributes` only covers `*.sh`, and `gofmt -l` reports every CRLF file as
unformatted. The blobs in git are LF — only the working tree is CRLF.

**Why:** the builder's whole attempt got blamed on its diff ("the implementation
does not satisfy the check") when the gate was red on master too. Always run a
new task's acceptance commands on the *pristine* worktree before reading the
diff — see [[agent-ci-escalation-pattern]].

**How to apply:** add `*.go text eol=lf` (plus go.mod/go.sum) to a
`.gitattributes` inside the owned directory — not the root one, which
`scope-respected` forbids touching — then rewrite the working-tree files to LF.
Git then shows no diff, because the stored blob was already LF. Any future Go,
or any other gofmt/prettier/black-style formatter gate added to this repo, needs
the same line in its own directory.
