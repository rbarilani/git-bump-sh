rbarilani/git-bump-sh
==============================

A **Unix-like** shell command to bump a new version of a "package" with git.

[![Build Status](https://travis-ci.org/rbarilani/git-bump-sh.svg)](https://travis-ci.org/rbarilani/git-bump-sh)

## Conventions, limitations and assumptions 

* Follows semantic versioning
* In your project there are two required main branches, one branch for active development (default name:'dev') 
and one branch for releases (default name:'master')
* Tags are only used to mark releases
* You must run this command from the root of your project folder

## Install

### Using git

```
git clone https://github.com/rbarilani/git-bump-sh.git 
```

This would install an executable script ```./git-bump-sh/bin/bump```.


### Using composer

Adds this to your composer.json and run ```composer update rbarilani/git-bump-sh```:

```json
{
    "require": {
        "rbarilani/git-bump-sh" : "dev-master"
    },
    "repositories" : [
        { "type":"git", "url":"https://github.com/rbarilani/git-bump-sh.git" }
    ]
}
```

This would install an executable script ```./vendor/bin/bump```.

### Using npm

Adds this to your package.json and run ```npm install```:

```json
{
    "dependencies": {
        "rbarilani-git-bump-sh" : "git+https://github.com/rbarilani/git-bump-sh.git"
    }
}
```

This would install an executable script ```./node_modules/.bin/bump```.

## Usage

```
Usage:

bump [<version-file>] [--release-type=<type>] [--changes-file=<path>]
     [-s|--silent] [--force] [--sync-dev=<flag>]
     [--pre-cmd=<command>] [--pre-commit-cmd=<command>] [--after-cmd=<command>]
     [--no-interactive] [--no-color] [-h|--help] [--version]

Arguments:

* version-file : path to the version file (default: version)

Options:

* --release-type=<type>      : provide <type> (fix or minor or major) for the release, required when --no-interactive
* --changes-file=<path>      : use <path> to prepend change message (default: CHANGELOG.md)
* -s or --silent             : don't push to remote
* --force                    : bypass checks
* --sync-dev=<flag>          : rebasing master progress into dev after success. (<flag>: true or false or '', default: '')
                               required when --no-interactive
* --pre-cmd=<command>        : execute <command> before bump
* --pre-commit-cmd=<command> : execute <command> before git commit
* --after-cmd=<command>      : execute <command> after successful bump
* --no-interactive           : turn off interaction
* --no-color                 : turn off colored messages
* -h or --help               : print this help
* --version                  : print version
```

### .bumprc

To provide default options you can use a ```.bumprc``` file in your project root:

```bash
#.bumprc

# THOSE ARE DEFAULTS 
MASTER_BRANCH="master"
DEV_BRANCH="dev"
VERSION_FILE="version"
CHANGES_FILE="CHANGELOG.md"
SILENT=false
NO_COLOR=false
FORCE=false
SYNC_DEV=""
PRE_CMD=""
AFTER_CMD=""
PRE_COMMIT_CMD=""
```

Example: 

```bash
# .bumprc

VERSION_FILE="config/version"
SILENT=true
FORCE=true
PRE_CMD="cmd1"
PRE_COMMIT_CMD="cmd2"
AFTER_CMD="cmd3"
NO_COLOR=true
```

you can always override those values with arguments

```bash
bump --pre-cmd="cmd4"
```

is like 

```
bump config/version -s --force --pre-cmd="cmd4" --pre-commit-cmd="cmd2" --after-cmd="cmd3" --no-color
```

### pre-cmd/pre-commit-cmd/after-cmd placeholders

```
* {{RELEASE TYPE}}  # chosen release type (fix, major, minor)
* {{CURRENT_TAG}}   # current version
* {{NEW_TAG}}       # new bumped version
```

You can use those placeholders in yours ```--pre-cmd/--pre-commit-cmd/--after-cmd``` commands hooks.
Take in mind that those values will be replaced before your command will be evaluated; for a live example take a look
to the ```.bumprc``` file in this project.

## Development

### Tests

#### Install shunit2

Install [shunit2] manually and the [test runner] with npm

```
cd vendor && curl -L "http://downloads.sourceforge.net/shunit2/shunit2-2.0.3.tgz" | tar zx ; cd -;
npm install;
```

#### Run tests

```
bash test.sh
```

[shunit2]: https://code.google.com/p/shunit2/
[test runner]: https://github.com/hal9087/shunit2-test-runner

