#!/usr/bin/env bash

FAILED_COUNTER=0
PASSED_COUNTER=0
TOTAL_COUNTER=0


FAILED_TESTS=0
PASSED_TESTS=0
TOTAL_TESTS=0

FAILED_TESTS_COUNTER=0
PASSED_TESTS_COUNTER=0
TOTAL_TESTS_COUNTER=0

# Reset
TEXT_RESET='\x1B[0m'

# Bold Colors
BOLD_GREEN='\x1B[1;32m'
BOLD_RED='\x1B[1;31m'
BOLD_WHITE='\x1B[1;37m'

for filename in bin/*_test.sh; do

    SUCCESS_RATE="0%";
    FAILED_TESTS=0
    PASSED_TESTS=0
    TOTAL_TESTS=0
    TOTAL_COUNTER=$(expr ${TOTAL_COUNTER} + 1);

    echo -e "${BOLD_WHITE}\n#\n#\n# EXECUTING: '${filename}'\n#\n#\n${TEXT_RESET}"
    if bash ${filename}
        then
            OUTPUT="$(bash ${filename} 2> /dev/null)"

            TOTAL_TESTS="$(echo ${OUTPUT} | sed -n 's/.*tests total: \([0-9]\{1,\}\).*/\1/p')"
            FAILED_TESTS="$(echo ${OUTPUT} | sed -n 's/.*tests failed: \([0-9]\{1,\}\).*/\1/p')"
            PASSED_TESTS="$(echo ${OUTPUT} | sed -n 's/.*tests passed: \([0-9]\{1,\}\).*/\1/p')"

            FAILED_TESTS_COUNTER=$(expr ${FAILED_TESTS_COUNTER} + ${FAILED_TESTS});
            PASSED_TESTS_COUNTER=$(expr ${PASSED_TESTS_COUNTER} + ${PASSED_TESTS});
            TOTAL_TESTS_COUNTER=$(expr ${TOTAL_TESTS_COUNTER} + ${TOTAL_TESTS});

            SUCCESS_RATE="$(echo ${OUTPUT} | grep -Po '(?<=success rate: ).*' )"

            if [ "$SUCCESS_RATE" == "100%" ];
            then
                PASSED_COUNTER=$(expr ${PASSED_COUNTER} + 1);
                echo -e "${BOLD_GREEN}\nPASSED${TEXT_RESET}";
            else
                FAILED_COUNTER=$(expr ${FAILED_COUNTER} + 1); echo -e "${BOLD_RED}\nFAILED${TEXT_RESET}";
            fi
    else
        FAILED_COUNTER=$(expr ${FAILED_COUNTER} + 1); echo -e "${BOLD_RED}\nFAILED WHILE EXECUTING${TEXT_RESET}";
    fi

done

SUMMARY_MESSAGE="
TESTS SCRIPTS PASSED : ${PASSED_COUNTER}/${TOTAL_COUNTER}
TESTS SCRIPTS FAILED : ${FAILED_COUNTER}/${TOTAL_COUNTER}
TESTS PASSED         : ${PASSED_TESTS_COUNTER}/${TOTAL_TESTS_COUNTER}
TESTS FAILED         : ${FAILED_TESTS_COUNTER}/${TOTAL_TESTS_COUNTER}
"

if [ ! ${FAILED_COUNTER} = 0 ]; then
    echo -e "${BOLD_RED}${SUMMARY_MESSAGE}${TEXT_RESET} "; exit 1;
else
    echo -e "${BOLD_GREEN}${SUMMARY_MESSAGE}${TEXT_RESET}"; exit 0;
fi
