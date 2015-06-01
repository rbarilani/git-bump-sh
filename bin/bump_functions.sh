#!/usr/bin/env bash


#
#
# FUNCTIONS
#
# --------------------

join() {
    local IFS="$1"; shift; echo "$*";
}

echo_confirmation() {

    #
    # CONFIRM INFORMATION (last and new version)
    #
    echo "INFO

last release: '${1}'
next release: '${2}'

"

    echo "looks right?"
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
    else rollback; echo_help; echo_error "" true; exit 1;
    fi
}

write_temp_changelog_md() {
    echo -e "${1}" > .CHANGELOG.tmp.md;

    vi .CHANGELOG.md -c ":r .CHANGELOG.tmp.md"
    rm -f .CHANGELOG.tmp.md;

    if [ ! -f .CHANGELOG.md ]; then
        echo_error "" true; exit 1;
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
    if ${2} == 'true'
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
                if ${1} == 'true'
                then
                    if git push origin dev;
                    then echo_info "dev saw pushed"
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
    if [ -z "$(git status 2> /dev/null | grep "nothing to commit (working directory clean)")" ]
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
