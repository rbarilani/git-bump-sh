truelab/git-bump-sh
==============================

Simple shell script to bump a new version of a package with git.

[![Build Status](https://travis-ci.org/hal9087/git-bump-sh.svg?branch=master)](https://travis-ci.org/hal9087/git-bump-sh)


## Install

Adds this to your composer.json and run ```composer update truelab/git-bump-sh```:

```json
{
    "require": {
        "truelab/git-bump-sh" : "dev-master"
    },
    "repositories" : [
        { "type":"git", "url":"https://github.com/truelab/git-bump-sh.git" }
    ]
}
```


## Limitations, conventions and assumptions 

* Follow semantic versioning
* There are two branch called master and dev
* Tags are only used to mark a release
* A CHANGELOG.md markdown file is used to track changes
* A yml file is used to set a version parameter
* You must run this command from the root of your project folder (where CHANGELOG.md resides)


## Usage

Assuming composer has installed the script in the path ```bin / bump``` .

```bash

bin/bump [-sh] [version_file_path]

Arguments:

* version_file_path : path to yml version file (default: app/config/version.yml)

Options:

* -h : print this help
* -s : don't push to remote

```



