#!/usr/bin/env bash

FAILURE_COUNTER=0
SUCCESS_COUNTER=0
TOTAL_COUNTER=0

# Reset
TEXT_RESET='\x1B[0m'

# Bold Colors
BOLD_GREEN='\x1B[1;32m'
BOLD_RED='\x1B[1;31m'
BOLD_WHITE='\x1B[1;37m'

for filename in bin/*_test.sh; do

    SUCCESS_RATE="0%";
    TOTAL_COUNTER=$(expr ${TOTAL_COUNTER} + 1);

    echo -e "${BOLD_WHITE}\n#\n#\n# EXECUTING: '${filename}'.\n#\n#\n${TEXT_RESET}"
    if bash ${filename}
        then
            SUCCESS_RATE="$(bash ${filename} 2> /dev/null | grep -Po '(?<=success rate: ).*' )"
            if [ "$SUCCESS_RATE" == "100%" ];
            then
                SUCCESS_COUNTER=$(expr ${SUCCESS_COUNTER} + 1);
                echo -e "${BOLD_GREEN}\nSUCCESS.${TEXT_RESET}";
            else
                FAILURE_COUNTER=$(expr ${FAILURE_COUNTER} + 1); echo -e "${BOLD_RED}\nFAILURE.${TEXT_RESET}";
            fi
    else
        FAILURE_COUNTER=$(expr ${FAILURE_COUNTER} + 1); echo -e "${BOLD_RED}\nFAILURE WHILE EXECUTING.${TEXT_RESET}";
    fi

done

if [ ! ${FAILURE_COUNTER} = 0 ]; then
    echo -e "${BOLD_RED}\nTEST SUITE FAIL. ${FAILURE_COUNTER}/${TOTAL_COUNTER}${TEXT_RESET}"; exit 1;
else
    echo -e "${BOLD_GREEN}\nTEST SUITE SUCCESS. ${SUCCESS_COUNTER}/${TOTAL_COUNTER}${TEXT_RESET}"; exit 0;
fi
