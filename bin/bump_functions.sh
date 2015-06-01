#!/usr/bin/env bash

# Reset
COLOR_OFF='\x1B[0m'       # Text Reset

# Bold Colors
BOLD_GREEN='\x1B[1;32m'   # Bold Green
BOLD_RED='\x1B[1;31m'     # Bold Red
BOLD_WHITE='\x1B[1;37m'   # Bold White

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

bump [-s|--silent] [--pre-cmd=<command>] [--post-cmd=<command>] [<version-file>]

Arguments:

* version-file : path to yml version file (default: app/config/version.yml)

Options:

* -h or --help          : print this help
* -s or --silent        : don't push to remote
* --pre-cmd=<command>   : execute <command> before bump
* --after-cmd=<command> : execute <command> after successful bump
* --no-color            : turn off colored messages
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
        echo -e "${BOLD_RED}${error_message}${COLOR_OFF}"
    else
        echo -e "${error_message}"
    fi;
}

echo_info() {
    local message="(INFO) ${1}";

    if [ -n "${NO_COLOR-}" ] && [ "${NO_COLOR}" = false ]; then
        echo -e "${BOLD_WHITE}${message}${COLOR_OFF}"
    else
        echo -e "${message}"
    fi;
}

echo_success() {
    local message="(SUCCESS) ${1}"

    if [ -n "${NO_COLOR-}" ] && [ "${NO_COLOR}" = true ]; then
        echo -e "${BOLD_GREEN}{$message}${COLOR_OFF}"
    else
        echo -e "${message}"
    fi;
}

bump_version_file() {

    local version=$1;
    local path=$2

    if echo "parameters:
  version: ${version}" > ${path}
    then echo_info "${path} was modified"
    else rollback; echo_help; echo_error "" true; exit 1;
    fi
}

write_temp_changelog_md() {
    echo -e "${1}" > .CHANGELOG.tmp.md;

    vi .CHANGELOG.md -c ":r .CHANGELOG.tmp.md"
    rm -f .CHANGELOG.tmp.md;

    if [ ! -f .CHANGELOG.md ]; then
        echo_error "new changelog message doesn't exist" true; exit 1;
    fi
}

update_changelog_md() {
    if echo -e "$(cat .CHANGELOG.md)\n\n\n$(cat CHANGELOG.md)" > CHANGELOG.md
    then echo_info "CHANGELOG.md was modified"; rm -f .CHANGELOG.md;
    else echo_error "" true; exit 1;
    fi
}

rollback() {
    echo_info "rollback"

    if [ -f .CHANGELOG.tmp.md ]; then
        rm .CHANGELOG.tmp.md
    fi

    if [ -f .CHANGELOG.md ]; then
        rm .CHANGELOG.md
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
   echo -e "${updated}" > package.json
}

execute_cmd(){
    if ! [ -z "$1" ]
    then
        eval ${1}
        [ $? = 1 ] && echo_error "${2}=\"${1}\" fails" true && exit 1;
    fi
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
    if [ "${2}" = false ]
    then
        if git push origin master && git push origin ${1};
        then echo_info "master and ${1} were pushed"
        else echo_error "" true; exit 1;
        fi
    fi
}

git_commit() {
    git commit -m "${1}";
}

git_resync_dev_branch() {
    echo "resync 'dev' branch?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                git checkout dev && git rebase master;
                if [ "${1}" = false ]
                then
                    if git push origin dev;
                    then echo_info "dev was pushed"
                    else echo_error "can't push dev branch" true; exit 1;
                    fi;
                fi;
                break;;
            No ) break;;
        esac
    done
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
    if [ ! "$current_git_branch" = "master" ]; then
        echo_error "You are not on 'master' branch. Be sure to move to 'master' branch and merge your progress" true; exit 1;
    fi;
}


#
# PARSE YAML
# http://stackoverflow.com/a/21189044/1823473
#
# practical usage example:
#
# eval $(parse_yaml version.yml "CONF_")
# echo "${CONF_parameters_version}"
#
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
