#!/usr/bin/env bash

__failure_counter=0

for filename in bin/*_test.sh; do

    __success_rate="0%";

    echo -e "\n#\n# EXECUTING: '${filename}'.\n#"
    if bash ${filename}
        then
            echo -e "\nEXECUTED.";
            __success_rate="$(bash ${filename} 2> /dev/null | grep -Po '(?<=success rate: ).*' )"

            if [ "$__success_rate" == "100%" ];
            then
                echo -e "SUCCESS.";
            else
                __failure_counter=$(expr ${__failure_counter} + 1); echo -e "FAILURE.";
            fi
    else
        __failure_counter=$(expr ${__failure_counter} + 1); echo -e "\nFAILURE.";
    fi

done

if [ ! ${__failure_counter} = 0 ]; then
    echo -e "\n(!)-(!) TEST SUITE FAIL (!)-(!)"; exit 1;
else
    echo -e "\n(*)-(*) TEST SUITE SUCCESS (*)-(*)"; exit 0;
fi
