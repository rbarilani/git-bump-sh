# 1.1.4 (2015-06-04)

- 9e3a9e1 fix travis failing [Ruben Barilani]


# 1.1.3 (2015-06-04)

- ec78ca1 updates help and readme, fix echo_success [Ruben Barilani]


# 1.1.2 (2015-06-03)

- 5b2132f adds bump functional test, fix echo_success with --no-color [Ruben Barilani]


# 1.1.1 (2015-06-03)

- a3dc6aa updates composer.json description [Ruben Barilani]


# 1.1.0 (2015-06-03)

- def1c89 adds --sync-dev options, adds fix, updates README [Ruben Barilani]


# 1.0.0 (2015-06-03)

## new features

- configuration .bumprc file
- more options 
- optionally not interactive
- cmd hooks


## breaking changes

- changes version-file default from app/config/version.yml to version
- version-file it's a simple text file

## commits:

- f30dd4c updates README [Ruben Barilani]
- 13ff6fa add --changes-file option [Ruben Barilani]
- ec2a2aa adds --no-interactive, --release-type options [Ruben Barilani]
- ef938cf no more yaml, updates README [Ruben Barilani]
- 942a72c updates echo_help, updates README [Ruben Barilani]
- ffb8689 updates README.md with infos about placeholders [Ruben Barilani]
- 599f32b exit on unknown option [Ruben Barilani]
- 86e6caa adds --force options [Ruben Barilani]
- 0fc8037 adds --version option [Ruben Barilani]
- 14d3f2e adds --pre-commit-cmd option, adds placeholders [Ruben Barilani]


# 0.8.2 (2015-06-02)

- ed644ea renaming variables [Ruben Barilani]


# 0.8.1 (2015-06-02)

- 8a8cb1e change VERSION_FILE default value [Ruben Barilani]


# 0.8.0 (2015-06-02)

- 473a743 refactor options and the options/arguments parsing method, adds --pre-cmd, --after-cmd, --no-color options, change message format, colorize output,  adds minor updates, adds .bumprc source feature, updates README.md [Ruben Barilani]


# 0.7.2 (2015-06-01)

- e5f668e hotfix [Ruben Barilani]
- 6fda7bb updates README.md [Ruben Barilani]


# 0.7.1 (2015-06-01)

- 1aa3fb8 fix a typo error [Ruben Barilani]


# 0.7.0 (2015-06-01)

- a5f4438 updates also package.json if present [Ruben Barilani]
- 107aa87 updates and test git_add_tag function, long message also for the tag [Ruben Barilani]


# 0.6.2 (2015-06-01)

- ce5e562 updates LICENSE, updates readme, adds README.md lost part [Ruben Barilani]
- be30ab9 git last tag redirect error output [Ruben Barilani]
- 477eb16 adds package.json [Ruben Barilani]


# 0.6.1 (2015-05-31)

- 6a563f0 updates README.md [Ruben Barilani]


# 0.6.0 (2015-05-31)

- 2b8a868 change version.yml indentation, add parse_yaml function, add minor updates [Ruben Barilani]
- 03ec20d truelab to hal9087 plus updates [Ruben Barilani]
- 0e65d63 post install shunit [Ruben Barilani]
- b4f45d3 splits tests [Ruben Barilani]
- b9e321e updates README [Ruben Barilani]
- 45666ee adds travis badge [Ruben Barilani]
- 4f19c2c redirecting output when git status [Ruben Barilani]
- c05414d updates git_add, test git_add, adds check functions, adds tests [Ruben Barilani]
- 89e5e9e updates rollback [Ruben Barilani]
- a9ea675 adds rollback function [Ruben Barilani]
- b258b41 adds more functions, adds more tests [Ruben Barilani]
- 899c4a0 move functions in a separate file, adds tests and travis integration [Ruben Barilani]
- 3bab9eb wip: check git commands before continue [Ruben Barilani]


# 0.5.1 (2015-05-29)

- b504de0 updates README [Ruben Barilani]


# 0.5.0 (2015-05-29)

- 99b0d4c Merge pull request #1 from hal9087/dev [Ruben Barilani]
- 1ac8e8d fix getopts and arguments [Ruben Barilani]
- 05bd735 removes unwanted exit [Ruben Barilani]
- 7754801 adds version file [Ruben Barilani]


# 0.4.1 (2015-05-28)

- a85c997 check tag already exists [Ruben Barilani]


# 0.4.0 (2015-05-28)

- 10edef6 permits release only on the master branch, optionally resync dev branch [Ruben Barilani]


# 0.3.0 (2015-05-28)

- eafaa61 adds fix, wrong new_tag [Ruben Barilani]


# 0.2.0 (2015-05-28)

- 4e89e57 don't push to remote option [Ruben Barilani]


# 0.1.0 (2015-05-28)

- 2364961 updates README.md, updates bin/bump [Ruben Barilani]
- 697d660 updates bin/bump [Ruben Barilani]
- cbbe8d5 updates README.md [Ruben Barilani]
- 144cb68 adds vendor folder to .gitignore [Ruben Barilani]
- a276473 first commit [Ruben Barilani]
