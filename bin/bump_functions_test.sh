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
	assertEquals "(ERROR) ..aborting" "$(echo_error "" true)"
	assertEquals "(ERROR) foobar ..aborting" "$(echo_error "foobar" true)"
	assertEquals "(ERROR) foobar" "$(echo_error "foobar" false)"
}

test_echo_info() {
    assertEquals "(INFO) foo" "$(echo_info "foo")"
}

test_bump_version_file_error_not_existent_path() {
    RESULT="$(bump_version_file "0.0.1" "${TMP_FOLDER}/NOT_EXISTENT/version.yml" 2> /dev/null)"
    assertTrue "must fail" "[ $? = 1 ]"
}

test_bump_version_file() {
    assertEquals "$(bump_version_file "0.0.1" "${TMP_FOLDER}/version.yml")" "(INFO) ${TMP_FOLDER}/version.yml was modified"
}

test_match_and_replace_version() {
    local actual="$(match_and_replace_version '"version":"2.4.1"' "2.5.1")"
    assertEquals '"version": "2.5.1"' "${actual}"
}

test_is_npm_project() {

    cd ${TMP_FOLDER};

    assertFalse $(is_npm_project)

    echo "{
    "name": "hal9087-git-bump-sh",
    "version": "0.6.1"
}" >> package.json

    assertTrue $(is_npm_project)

    rm -f package.json

    if [ $(is_npm_project) = true ];
    then fail " I expect it returns false if package.json doesn't exist"
    fi;

    cd - 1> /dev/null;
}

test_bump_npm_package_version() {

    local new_tag="1.0.0"

    cd ${TMP_FOLDER};

    echo -e "{
    \"name\": \"hal9087-git-bump-sh\",
    \"version\": \"0.6.1\",
    \"scripts\": {},
    \"foo\" : [\"version: 0.6.1\"]
}" >> package.json

    bump_npm_package_version ${new_tag} package.json

    assertEquals "{
    \"name\": \"hal9087-git-bump-sh\",
    \"version\": \"${new_tag}\",
    \"scripts\": {},
    \"foo\" : [\"version: 0.6.1\"]
}" "$(cat package.json)"

    cd - 1> /dev/null;
}

. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
