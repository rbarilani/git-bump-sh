hal9087/git-bump-sh
==============================

Simple shell script to bump a new version of a package with git.

[![Build Status](https://travis-ci.org/hal9087/git-bump-sh.svg)](https://travis-ci.org/hal9087/git-bump-sh)

## Limitations, conventions and assumptions 

* Follows semantic versioning
* In your project there are two required main branches called master and dev
* Tags are only used to mark a release
* A CHANGELOG.md markdown file is used to track changes
* A yml file is used to set a version parameter
* You must run this command from the root of your project folder (where CHANGELOG.md resides)

## Install

### Using git

```
git clone https://github.com/hal9087/git-bump-sh.git 
```

This would install an executable script ```./git-bump-sh/bin/bump```.


### Using composer

Adds this to your composer.json and run ```composer update hal9087/git-bump-sh```:

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

This would install an executable script ```./vendor/bin/bump```.

### Using npm

Adds this to your package.json and run ```npm install```:

```json
{
    "dependencies": {
        "hal9087-git-bump-sh" : "git+https://github.com/hal9087/git-bump-sh.git"
    }
}
```

This would install an executable script ```./node_modules/.bin/bump```.

## Usage

Assuming you, npm or composer has installed the script ```vendor/bin/bump```.

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

or with the help of composer post install hook

```
composer install
```

#### Run tests

```
bash test.sh
```

[shunit2]: https://code.google.com/p/shunit2/


