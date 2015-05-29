#!/bin/sh

source $(dirname $0)/bump_functions.sh

TMP_FOLDER=".tmp"
result="null"

oneTimeSetUp() {
    mkdir ${TMP_FOLDER}
}

oneTimeTearDown() {
    rm -rf ${TMP_FOLDER}
}

setUp() {
   result="null"
}

tearDown() {
   result="null"
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
    result="$(bump_version_file "0.0.1" "${TMP_FOLDER}/NOT_EXISTENT/version.yml")"
    assertTrue "must fail" "[ $? = 1 ]"
}

test_bump_version_file() {
    assertEquals "INFO. ${TMP_FOLDER}/version.yml was modified." "$(bump_version_file "0.0.1" "${TMP_FOLDER}/version.yml")"
}

. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
