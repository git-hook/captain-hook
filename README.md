[//]: # TODO: add epic graphic

# Overview

This package provides a framework for git hooks following the [.d configuration approach].

[.d configuration approach]: (http://blog.siphos.be/2013/05/the-linux-d-approach/)

# Installation

Recommended use is through git submodules:

```bash
mkdir -p hooks
git submodule add https://github.com/ericcrosson/captain-hook /hooks/captain-hook
git submodule init
git submodule update
./hooks/captain-hook/setup
```

The resulting directory structure after `setup`:

```bash
▲ workspace/tree -I captain-hook
.
└── hooks
├── commit-msg -> captain-hook/run-hook
├── commit-msg.d
├── post-checkout -> captain-hook/run-hook
├── post-checkout.d
├── post-clone -> captain-hook/run-hook
├── post-clone.d
├── post-commit -> captain-hook/run-hook
├── post-commit.d
├── pre-commit -> captain-hook/run-hook
├── pre-commit.d
├── pre-rebase -> captain-hook/run-hook
├── pre-rebase.d
├── prepare-commit-msg -> captain-hook/run-hook
└── prepare-commit-msg.d
```

# Use

[//]: # TODO: create linter -- demonstrate order of invoked scripts
[//]: # TODO: debugger? invoke them on my mark
[//]: # TODO: add this comment delimiter to .emacs
[//]: # TODO: remove aggressive-indent-mode from md mode
[//]: # TODO: profile the time it takes to run an empty hook

Every client-side git hook is installed, and will be called by git
naturally.  Each git hook is intercepted by captain-hook, a wrapper to
invoke the scripts in its corresponding `<git-hook-name>.d` directory.
These directories are empty by default, so they will not do anything
when called by the captain.  To configure a given script as invokable,
move or symlink it into the desired `<git-hook>.d` directory, taking
care to name it appropriately.

## Naming scripts

Captain-hook invokes scripts in the order specified by the names of
the scripts in the relevant hook-directory.  The scripts are invoked
numerically, from 000-999.  Scripts beginning with anything other than
a three-digit number between one and nine-hundred ninety-nine,
inclusive, will be ignored.

## Executing scripts

If one of the scripts exits with a non-zero code, the remaining
scripts are not invoked in order to limit unexpected behavior.
Sometimes this is undesirable, as we would like to separate the
cleanup code from the actionable code that created the mess.  For this
reason captain-hook provides the concept of an *ensured script* that
is run every time git invokes a hook, no matter how successful the
hook execution has been.  Typically, ensured scripts are the last
scripts to run, performing cleanup or unstashes to undo modifications
to the repository made by earlier scripts in the git hook.

Sometimes it is desirable to "short-circuit" a git-hook similar to the
above, but without reporting an error.  For exampke, perhaps the first
hook is to check if any action needs to be taken, and it concludes the
answer is "no."  In this case, return a negative exit-code to skip the
remaining non-ensured scripts in the hook directory.  Remember,
ensured scripts are run *every* time the hook is invoked by git.
