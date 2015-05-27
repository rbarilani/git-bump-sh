truelab/git-bump-sh
==============================

Simple shell script to bump a new version of a package with git.



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
* Tags are used only to mark a release
* A CHANGELOG.md markdown file is used to track changes
* Run this command from the root of your project folder (where CHANGELOG.md resides)


## Usage

Assuming composer has installed the script in the path ```bin / bump``` .

```bash

bin/bump [-ph]

Options:

* -h : print this help
* -p : push to remote

```



