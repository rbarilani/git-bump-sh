#!/usr/bin/env bash

VERSION="1.1.5"

CHANGE_MESSAGE_FILE=".bump_changes"
CHANGE_MESSAGE_FILE_TMP=".bump_changes.tmp"

# Reset
TEXT_RESET='\x1B[0m'

# Bold Colors
BOLD_GREEN='\x1B[1;32m'
BOLD_RED='\x1B[1;31m'
BOLD_WHITE='\x1B[1;37m'
#
#
# FUNCTIONS
#
# --------------------

join() {
    local IFS="$1"; shift; echo "$*";
}

echo_confirmation() {

    echo ""
    echo_info "\n
last release: '${1}'
next release: '${2}'
"
    echo "it seems right?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) echo_error "not confirmed" true; exit 1;;
        esac
    done
}

echo_help() {
    echo -e "
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
"
}

echo_error() {
    local error_message="(ERROR)";

    if [ ! -z "$1" ]; then
        error_message=$(echo -e "${error_message} ${1}")
    fi

    if [ "$2" = true ] ; then
        error_message=$(echo -e "${error_message} ..aborting")
    fi

    if [ -n "${NO_COLOR-}" ] && [ "${NO_COLOR}" = false ]; then
        echo -e "${BOLD_RED}${error_message}${TEXT_RESET}"
    else
        echo -e "${error_message}"
    fi;
}

echo_info() {
    local message="(INFO) ${1}";

    if [ -n "${NO_COLOR-}" ] && [ "${NO_COLOR}" = false ]; then
        echo -e "${BOLD_WHITE}${message}${TEXT_RESET}"
    else
        echo -e "${message}"
    fi;
}

echo_success() {
    local message="(SUCCESS) ${1}"

    if [ -n "${NO_COLOR-}" ] && [ "${NO_COLOR}" = false ]; then
        echo -e "${BOLD_GREEN}${message}${TEXT_RESET}"
    else
        echo -e "${message}"
    fi;
}

echo_version() {
    echo "${VERSION}"
}

bump_version_file() {

    local version=$1;
    local path=$2

    if echo "${version}" > ${path}
    then echo_info "${path} was modified"
    else rollback; echo_help; echo_error "" true; exit 1;
    fi
}

write_temp_changelog_md() {

    if [ -n "${2-}" ] && [ "${2}" = true ]; then
        echo -e "${1}" > "${CHANGE_MESSAGE_FILE}";
    else
        echo -e "${1}" > "${CHANGE_MESSAGE_FILE_TMP}";
        vi ${CHANGE_MESSAGE_FILE} -c ":r ${CHANGE_MESSAGE_FILE_TMP}"
        rm -f ${CHANGE_MESSAGE_FILE_TMP};
    fi;

    if [ ! -f ${CHANGE_MESSAGE_FILE} ]; then
        echo_error "new changelog message doesn't exist" true; exit 1;
    fi
}

update_changes() {
    if echo -e "$(cat ${CHANGE_MESSAGE_FILE})\n\n\n$(cat ${1})" > "${1}"
    then echo_info "${1} was modified"; rm -f ${CHANGE_MESSAGE_FILE};
    else echo_error "" true; exit 1;
    fi
}

rollback() {
    echo_info "rollback"

    if [ -f ${CHANGE_MESSAGE_FILE_TMP} ]; then
        rm ${CHANGE_MESSAGE_FILE_TMP}
    fi

    if [ -f ${CHANGE_MESSAGE_FILE} ]; then
        rm ${CHANGE_MESSAGE_FILE}
    fi
}

match_and_replace_version() {
    echo "${1}" | sed 's/"version":[ \t]\{0,\}"[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}"/"version": "'${2}'"/'
}

is_npm_project() {
    if [ -f package.json ];
    then echo true
    else echo false
    fi
}

bump_npm_package_version() {
   local updated="$(match_and_replace_version "$(cat package.json)" "${1}")"
   echo -e "${updated}" > "${2}"
}

replace_cmd_placeholders() {
    echo "${1}" | sed 's/{{CURRENT_TAG}}/'${CURRENT_TAG}'/g' |  sed 's/{{NEW_TAG}}/'${NEW_TAG}'/g' | sed 's/{{RELEASE_TYPE}}/'${RELEASE_TYPE}'/g'
}

execute_cmd(){
    if ! [ -z "$1" ]
    then
        local cmd=$(replace_cmd_placeholders "${1}")
        eval "${cmd}";
        [ $? = 1 ] && echo_error "${2}=\"${1}\" fails" true && exit 1;
    fi
}

check_release_type() {
    if ! [[ ${1} =~ ^(major)$|^(minor)$|^(fix)$ ]]; then
        echo_error "wrong release type. value should be major, minor or fix" true; exit 1;
    fi;
}

#
#
# GIT FUNCTIONS
#
#
git_last_tag() {
    local rev="$(git rev-list --tags --max-count=1 2> /dev/null)"
    git describe --tags ${rev} 2> /dev/null
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

git_fetch_all() {
    if git fetch --all
    then echo_info "git fetch completed"
    else echo_error "" true; exit 1;
    fi
}

git_add_tag() {
    git tag -a ${1} -m "${2}";
}

git_push() {
    if [ "${3}" = false ]
    then
        if git push origin ${1} && git push origin ${2};
        then echo_info "${1} and ${2} were pushed"
        else echo_error "" true; exit 1;
        fi
    fi
}

git_commit() {
    git commit -m "${1}";
}

git_rebase_and_push_dev_branch() {
    local dev_branch=$1
    local master_branch=$2
    local silent=$3;

    git checkout ${dev_branch} && git rebase ${master_branch};
    if [ "${silent}" = false ]
    then
        if git push origin ${1};
        then echo_info "'${dev_branch}' was pushed"
        else echo_error "can't push '${dev_branch}' branch" true; exit 1;
        fi;
    fi;
}

git_resync_dev_branch() {

    local dev_branch=$1
    local master_branch=$2
    local silent=$3;
    local no_interactive=$4
    local sync_dev=$5;

    if [ ${no_interactive} = false ]; then # interactive

        if [ -z "${sync_dev}" ]; then
            echo "resync '${dev_branch}' branch?"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes )
                        git_rebase_and_push_dev_branch ${dev_branch} ${master_branch} ${silent}
                        break;;
                    No ) echo_info "resync '${dev_branch}' branch not confirmed. continue.";
                        break;;
                esac
            done
        else
            if [ "${sync_dev}" = true ]; then
                echo_info "resync '${dev_branch}' branch"
                git_rebase_and_push_dev_branch ${dev_branch} ${master_branch} ${silent}
            fi;
        fi

    else # not interactive
        if [ "${sync_dev}" = true ]; then
            echo_info "resync '${dev_branch}' branch"
            git_rebase_and_push_dev_branch ${dev_branch} ${master_branch} ${silent}
        fi;
    fi;
}

git_add() {
    for var in "$@"
    do
      git add ${var}
    done
}

git_check_working_directory_clean() {
    if [ -z "$(git status 2> /dev/null | grep "nothing to commit")" ]
    then echo_error "git working directory is not clean" true;  exit 1;
    fi;
}

git_check_current_branch_is_master() {
    local current_git_branch="$(git_current_branch)"
    if [ ! "$current_git_branch" = "${1}" ]; then
        echo_error "You are not on '${1}' branch. Be sure to move to '${1}' branch and merge your progress" true; exit 1;
    fi;
}
