#!/usr/bin/env bash

__failure_counter=0
__success_counter=0
__total_counter=0

# Reset
Color_Off='\x1B[0m'       # Text Reset

# Bold Colors
Bold_Green='\x1B[1;32m'   # Bold Green
Bold_Red='\x1B[1;31m'     # Bold Red
Bold_White='\x1B[1;37m'   # Bold White

for filename in bin/*_test.sh; do

    __success_rate="0%";
    __total_counter=$(expr ${__total_counter} + 1);

    echo -e "${Bold_White}\n#\n#\n# EXECUTING: '${filename}'.\n#\n#\n${Color_Off}"
    if bash ${filename}
        then
            __success_rate="$(bash ${filename} 2> /dev/null | grep -Po '(?<=success rate: ).*' )"
            if [ "$__success_rate" == "100%" ];
            then
                __success_counter=$(expr ${__success_counter} + 1);
                echo -e "${Bold_Green}\nSUCCESS.${Color_Off}";
            else
                __failure_counter=$(expr ${__failure_counter} + 1); echo -e "${Bold_Red}\nFAILURE.${Color_Off}";
            fi
    else
        __failure_counter=$(expr ${__failure_counter} + 1); echo -e "${Bold_Red}\nFAILURE WHILE EXECUTING.${Color_Off}";
    fi

done

if [ ! ${__failure_counter} = 0 ]; then
    echo -e "${Bold_Red}\nTEST SUITE FAIL. ${__failure_counter}/${__total_counter}${Color_Off}"; exit 1;
else
    echo -e "${Bold_Green}\nTEST SUITE SUCCESS. ${__success_counter}/${__total_counter}${Color_Off}"; exit 0;
fi
