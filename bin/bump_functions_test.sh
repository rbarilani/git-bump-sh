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
    RESULT="$(bump_version_file "0.0.1" "${TMP_FOLDER}/NOT_EXISTENT/version.yml" 2> /dev/null)"
    assertTrue "must fail" "[ $? = 1 ]"
}

test_bump_version_file() {
    assertEquals "$(bump_version_file "0.0.1" "${TMP_FOLDER}/version.yml")" "INFO. ${TMP_FOLDER}/version.yml was modified."
}

. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
