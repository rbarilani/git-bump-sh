#!/usr/bin/env bash

source $(dirname $0)/bump_functions.sh

RESULT="null"

setUp() {
   RESULT="null"
}

tearDown() {
   RESULT="null"
}


test_git_check_working_directory_clean_error() {
    touch bump_tmp.txt
    RESULT="$(git_check_working_directory_clean)"
    assertTrue "must fail, i expect directory is dirty after a file creation" "[ $? = 1 ]"
    rm bump_tmp.txt
}
#
## "UNIT TESTS"
## OVERRIDE GIT COMMAND
test_git_check_working_directory_clean_error2() {
    git() {
        assertEquals "status" "${1}"
        echo "not clean. something to commit"
    }
    RESULT="$(git_check_working_directory_clean)"
    assertTrue "must fail" "[ $? = 1 ]"
}

test_git_check_working_directory_clean_success() {
    git() {
        assertEquals "status" "${1}"
        echo "nothing to commit (working directory clean)"
    }
    RESULT="$(git_check_working_directory_clean)"
    assertTrue "must not fail" "[ $? = 0 ]"
}

test_git_log_head() {
    git() {
        assertEquals "log" "${1}"
        assertEquals "HEAD" "${3}"
    }
    git_log false
}

test_git_log_from_target_to_head() {
    git() {
        assertEquals "log" "${1}"
        assertEquals "0..HEAD" "${3}"
    }
    git_log "0"
}

test_git_fetch_all_error() {
    git() {
        return 1;
    }

    RESULT="$(git_fetch_all)"
    assertTrue "must fail" "[ $? = 1 ]"
    assertEquals "ERROR. aborting." "${RESULT}";
}

test_git_fetch_all() {
    git() {
        return 0;
    }

    RESULT="$(git_fetch_all)"
    assertTrue "must not fail" "[ $? = 0 ]"
    assertEquals "INFO. git fetch completed." "${RESULT}";
}

test_git_add() {
    local times=0;
    git() {
        assertEquals "add" "${1}"
        times=$(expr ${times} + 1)
    }
    git_add "foo" "bar"
    assertEquals 2 ${times}
}

. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
