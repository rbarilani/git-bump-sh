#!/usr/bin/env bash

#
#
# FUNCTIONS
#
# --------------------

join() {
    local IFS="$1"; shift; echo "$*";
}

git_last_tag() {
    git describe origin/master
}

git_tag_exists() {

    if git show-ref --tags | egrep -q "refs/tags/$1$"
    then
        echo true
    else
        echo false
    fi
}

git_log() {

    local format="format:- %h %s [%an]";

    if [ "$1" = false ] ; then
        git log --pretty="${format}" HEAD
    else
        git log --pretty="${format}" ${1}..HEAD
    fi;
}

git_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

echo_help() {
    echo -e "
Usage:

bump [-sh] [version_file_path]

Arguments:

* version_file_path : path to yml version file (default: app/config/version.yml)

Options:

* -h : print this help
* -s : don't push to remote

"
}

echo_error() {
    local error_message="ERROR.";

    if [ ! -z "$1" ]; then
        error_message=$(echo -e "${error_message} ${1}.")
    fi

    if [ "$2" = true ] ; then
        error_message=$(echo -e "${error_message} aborting.")
    fi

    echo -e "${error_message}";
}

echo_info() {
    echo -e "INFO. ${1}."
}

bump_version_file() {

    local version=$1;
    local path=$2

    if echo "parameters:
    version: ${version}" > ${path}
    then echo_info "${path} was modified"
    else echo_error "" true; exit 1;
    fi
}
