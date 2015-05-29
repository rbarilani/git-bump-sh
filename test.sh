#!/usr/bin/env bash

test_script="bin/bump_functions_test.sh"

if bash ${test_script}
then echo -e "\nEXECUTED.";
else echo -e "\nFAILURE."; exit 1;
fi;

success_rate="$(bash ${test_script} 2> /dev/null | grep -Po '(?<=success rate: ).*' )"

if [ "$success_rate" == "100%" ];
then echo -e "\nSUCCESS."; exit 0;
else echo -e "\nFAILURE."; exit 1;
fi
