#!/bin/sh

source $(dirname $0)/bump_functions.sh

TMP_FOLDER=".tmp"
RESULT="null"

oneTimeSetUp() {
    mkdir ${TMP_FOLDER}
}

oneTimeTearDown() {
    rm -rf ${TMP_FOLDER}
}

setUp() {
   RESULT="null"
}

tearDown() {
   RESULT="null"
}

test_echo_error() {
	assertEquals "ERROR. aborting." "$(echo_error "" true)"
	assertEquals "ERROR. foobar. aborting." "$(echo_error "foobar" true)"
	assertEquals "ERROR. foobar." "$(echo_error "foobar" false)"
}

test_echo_info() {
    assertEquals "INFO. foo." "$(echo_info "foo")"
}

test_bump_version_file_error_not_existent_path() {
    RESULT="$(bump_version_file "0.0.1" "${TMP_FOLDER}/NOT_EXISTENT/version.yml")"
    assertTrue "must fail" "[ $? = 1 ]"
}

test_bump_version_file() {
    assertEquals "$(bump_version_file "0.0.1" "${TMP_FOLDER}/version.yml")" "INFO. ${TMP_FOLDER}/version.yml was modified."
}

test_git_check_working_directory_clean_error() {
    touch bump_tmp.txt
    RESULT="$(git_check_working_directory_clean)"
    assertTrue "must fail, i expect directory is dirty after a file creation" "[ $? = 1 ]"
    rm bump_tmp.txt
}

. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
