truelab/git-bump-sh
==============================

Simple shell script to bump a new version of a package with git.

[![Build Status](https://travis-ci.org/hal9087/git-bump-sh.svg)](https://travis-ci.org/hal9087/git-bump-sh)

## Install

### Using git

```
git clone https://github.com/hal9087/git-bump-sh.git
```

### Using composer

Adds this to your composer.json and run ```composer update truelab/git-bump-sh```:

```json
{
    "require": {
        "hal9087/git-bump-sh" : "dev-master"
    },
    "repositories" : [
        { "type":"git", "url":"https://github.com/hal9087/git-bump-sh.git" }
    ]
}
```

## Usage

Assuming you or composer has installed the script at ```vendor/bin/bump``` .

```bash

vendor/bin/bump [-sh] [version_file_path]

Arguments:

* version_file_path : path to yml version file (default: app/config/version.yml)

Options:

* -h : print this help
* -s : don't push to remote

```

## Development

### Tests

#### Install shunit2

Install [shunit2] manually 

```
cd vendor && { curl -L "http://downloads.sourceforge.net/shunit2/shunit2-2.0.3.tgz" | tar zx ; cd -; }
```

or with composer

```
composer install
```

#### Run tests

```
bash test.sh
```

[shunit2]: https://code.google.com/p/shunit2/


