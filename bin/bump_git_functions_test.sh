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
## OVERRIDE/STUB GIT COMMAND
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
    assertEquals "(ERROR) ..aborting" "${RESULT}";
}

test_git_fetch_all() {
    git() {
        return 0;
    }

    RESULT="$(git_fetch_all)"
    assertTrue "must not fail" "[ $? = 0 ]"
    assertEquals "(INFO) git fetch completed" "${RESULT}";
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

test_git_add_tag() {
    git() {
        assertEquals "tag" "${1}"
        assertEquals "-a" "${2}"
        assertEquals "0.1.0" "${3}"
        assertEquals "-m" "${4}"
        assertEquals "message" "${5}"
    }
    git_add_tag "0.1.0" "message"
}

test_git_check_current_branch_is_master_must_fail() {
    git() {
        if [ "${1}" = "rev-parse" ]; then
            echo "dev"
        fi;
    }

    RESULT=$(git_check_current_branch_is_master "master")
    assertTrue "if current branch is dev, must fail" "[ $? = 1 ]"
}

test_git_check_current_branch_is_master() {
    git() {
        if [ "${1}" = "rev-parse" ]; then
            echo "master"
        fi;
    }

    RESULT=$(git_check_current_branch_is_master "master")
    assertTrue "if current branch is master, must not fail" "[ $? = 0 ]"
}

test_git_rebase_and_push_dev_branch_silent() {
    local times=0;
    git() {
        if [ ${times} = 0 ]; then
            assertEquals "checkout" "${1}"
            assertEquals "foo" "${2}"
        fi
        if [ ${times} = 1 ]; then
            assertEquals "rebase" "${1}"
            assertEquals "bar" "${2}"
        fi
        times=$(expr ${times} + 1)
    }
    git_rebase_and_push_dev_branch 1> /dev/null "foo" "bar" true
    assertEquals "git must be called two times with silent=true" 2 ${times}
}

test_git_rebase_and_push_dev_branch_not_silent() {
    local times=0;
    git() {
        if [ ${times} = 2 ]; then
            assertEquals "push" "${1}"
            assertEquals "origin" "${2}"
            assertEquals "foo" "${3}"
        fi
        times=$(expr ${times} + 1)
    }
    git_rebase_and_push_dev_branch 1> /dev/null "foo" "bar" false
    assertEquals "git must be called three times with silent=false" 3 ${times}
}

test_git_resync_dev_branch_not_interactive() {
    git() {
        return 0;
    }
    RESULT=$(git_resync_dev_branch "foo" "bar" true true true)
    assertEquals "(INFO) resync 'foo' branch" "${RESULT}"
}

test_git_resync_dev_branch_not_interactive_false_sync() {
    git() {
        return 0;
    }
    RESULT=$(git_resync_dev_branch "foo" "bar" true true false)
    assertEquals "" "${RESULT}"
}

test_git_resync_dev_branch_interactive_1() {
    echo "-----------------------------"
    local expected_output="resync 'foo' branch?
(INFO) resync 'foo' branch not confirmed. continue."

    git() {
        return 0;
    }

    RESULT=$(echo "2" | git_resync_dev_branch "foo" "bar" true false "")
    assertEquals "${expected_output}" "${RESULT}"
    echo -e "\n-----------------------------"
}

test_git_resync_dev_branch_interactive_2() {
    echo "-----------------------------"
    local expected_output="resync 'foo' branch?
(INFO) 'foo' was pushed";
    local c=""

    git() {
       return 0;
    }

    RESULT=$(echo "1" | git_resync_dev_branch "foo" "bar" false false "")
    assertEquals "${expected_output}" "${RESULT}"
    echo -e "\n-----------------------------"

}

test_git_push_silent() {
    git() {
       return 1;
    }
    RESULT=$(git_push "foo" "1.0.1" true)
    assertTrue "must not fail" "[ $? = 0 ]"
    assertEquals "" "${RESULT}"
}

test_git_push() {
    git() {
       return 0
    }
    RESULT=$(git_push "foo" "1.0.1" false)
    assertTrue "must not fail" "[ $? = 0 ]"
    assertEquals "(INFO) foo and 1.0.1 were pushed" "${RESULT}"
}

. $(dirname $0)/../vendor/shunit2-2.0.3/src/shell/shunit2
