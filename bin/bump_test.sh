#!/usr/bin/env bash

TMP_DIR=".tmp"
COMMAND="./bin/bump -s" # always silent, we don't have a stub repo

_setUp() {
    RESULT=""

    rm -rf ${TMP_DIR}
    mkdir ${TMP_DIR}
    mkdir ${TMP_DIR}/bin
    cp bin/bump ${TMP_DIR}/bin/.
    cp bin/bump_functions.sh ${TMP_DIR}/bin/.
    cp .gitignore ${TMP_DIR}/.

    touch ${TMP_DIR}/CHANGELOG.md
    touch ${TMP_DIR}/version

    cd ${TMP_DIR};
    git init 1> /dev/null;
    git add --all;
    git commit -m "fist commit" 1> /dev/null;
    echo -e "# 0.1.0\n\nFirst manual release" > CHANGELOG.md
    echo "0.1.0" > version
    git add --all;
    git commit -m "0.1.0" 1> /dev/null;
    git tag -a "0.1.0" -m "0.1.0"
}


setUp() {
    _setUp
}

tearDown() {
   RESULT="";
   cd - 1> /dev/null;
   rm -rf ${TMP_DIR};
}


test_unknown_option_throw_error() {
    local expected_output="(ERROR) Unknown option '-c' ..aborting"

    RESULT="$(${COMMAND} --no-color -c)"
    assertExitWithError $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
}

test_no_interactive_no_sync_dev_throw_error() {
    local expected_output="(ERROR) you have to specifiy a --sync-dev=<flag> while non-interactive mode ..aborting"

    RESULT="$(${COMMAND} --no-color --no-interactive)"
    assertExitWithError $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
}

test_execute_pre_command_and_exit_in_case_of_error_exit_code() {
    local wrong_pre_cmd="ls --jjjj 2> /dev/null";
    local expected_output="(ERROR) pre-cmd=\"${wrong_pre_cmd}\" fails ..aborting"

    RESULT="$(${COMMAND} --no-color --no-interactive --sync-dev=false --pre-cmd="${wrong_pre_cmd}")"
    assertExitWithError $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
}

test_error_if_not_on_master_branch() {
    git checkout -b dev
    local expected_output="(ERROR) You are not on 'master' branch. Be sure to move to 'master' branch and merge your progress ..aborting"

    RESULT="$(${COMMAND} --no-color --no-interactive --sync-dev=false)"
    assertExitWithError $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
}

test_error_if_working_directory_is_dirty() {
    touch test.txt
    local expected_output="(ERROR) git working directory is not clean ..aborting"

    RESULT="$(${COMMAND} --no-color --no-interactive --sync-dev=false)"
    assertExitWithError $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
}

test_error_if_release_type_not_provided() {
    local expected_output="(ERROR) you have to specifiy a release type while non-interactive mode ..aborting"

    RESULT="$(${COMMAND} --no-color --no-interactive --sync-dev=false)"
    assertExitWithError $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
}

__test_bump_success() {
    local release_type=$1
    local expected_version=$2;
    local expected_output="(SUCCESS) DONE!"
    local format="format:%s";

    touch test.txt
    git add test.txt;
    git commit -m "adds test.txt" 1> /dev/null;

    RESULT="$(${COMMAND} --no-color --pre-cmd="echo 'hgiuj08928jk'" --no-interactive --sync-dev=false --release-type=${release_type})"
    assertExitWithSuccess $?
    assertLastLineEquals "${expected_output}" "${RESULT}"
    assertFirstLineMatch "changelog is changed" "${expected_version}" "$(cat CHANGELOG.md)"
    assertFirstLineMatch "last commit have the right message" "${expected_version}" "$(git log -n 1 --pretty="${format}")"
    assertFirstLineEquals "${expected_version}" "$(cat version)"
    assertMatch "hgiuj08928jk" "${RESULT}"
}

test_bump_fix_success() {
    __test_bump_success "fix" "0.1.1"
}

test_bump_minor_success() {
    __test_bump_success "minor" "0.2.0"
}

test_bump_major_success() {
    __test_bump_success "major" "1.0.0"
}


#
# CUSTOM ASSERTIONS
#

assertLastLineEquals() {
  local msg=''
  if [ $# -eq 3 ]; then
    msg=$1
    shift
  fi
  local expected=$1
  local actual=$2

  assertEquals "last line is equal.${msg}" "${expected}" "$(echo "${actual}" | tail -n 1)"
}

assertFirstLineEquals() {
  local msg=''
  if [ $# -eq 3 ]; then
    msg=$1
    shift
  fi
  local expected=$1
  local actual=$2

  assertEquals "first line is equal.${msg}" "${expected}" "$(echo "${actual}" | head -n 1)"
}

assertFirstLineMatch() {
  local msg=''
  if [ $# -eq 3 ]; then
    msg=$1
    shift
  fi
  local pattern=$1
  local actual=$2

  if ! [[ "$(echo "${actual}" | head -n 1)" =~ ${pattern} ]]; then
    fail "first line match.${msg}. pattern was:<${pattern}>, actual was:<${actual}>"
  else
    assertTrue 0
  fi;
}

assertMatch() {
  local msg=''
  if [ $# -eq 3 ]; then
    msg=$1
    shift
  fi
  local pattern=$1
  local actual=$2

  if ! [[ "$(echo "${actual}")" =~ ${pattern} ]]; then
    fail "match.${msg}. pattern was:<${pattern}>, actual was:<${actual}>"
  else
    assertTrue 0
  fi;
}

assertExitWithError() {
  local msg=''
  if [ $# -eq 2 ]; then
    msg=$1
    shift
  fi
  local status=$1
  assertTrue "exit with error.${msg}" "[ $status = 1 ]"
}

assertExitWithSuccess() {
  local msg=''
  if [ $# -eq 2 ]; then
    msg=$1
    shift
  fi
  local status=$1
  assertTrue "exit with success.${msg}" "[ $status = 0 ]"
}


. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
