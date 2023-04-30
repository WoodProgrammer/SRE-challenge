#!/bin/bash
set -ou pipefail
set -o nounset
## Author: WoodProgrammer
## Usage: ./main.sh 
export BASE_PATH=$(pwd)
## reads from the yaml file, with this way we can easily read the 
## config data from a configmap instead of using environment variables.
export THRESHOLD=$(yq e '.network.threshold' config.yaml)
export URL_TO_TEST=$(yq e '.network.url' config.yaml)
export SLACK_WEBHOOK_URL=$(yq e '.slack.webhook_url' config.yaml)

trap ctrl_c INT

ctrl_c(){
    ## Trap function to use in the future any kind of interruption
    echo "ctrl+c received closing system"
    exit 1
}

cecho (){

     ## colored output function
    BLACK='\033[1;30m'
	RED='\033[1;31m'
	GREEN='\033[1;32m'
	YELLOW='\033[1;33m'
	BLUE='\033[1;34m'
	PURPLE='\033[1;35m'
	CYAN='\033[1;36m'
	WHITE='\033[1;37m'
	NC="\033[0m" # No Color

    printf "${!1}${2} ${NC}\n"
}

call_slack(){
    cecho "RED" "Request Routing to the Slack $1"
}

create_load(){

    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    ## check with the regex whether passed URL compatible with RFC standarts 

    while true ## infinite loop
    do
        if [[ $URL_TO_TEST =~ $regex ]]
        then 
            TIME_TO_RESPONSE=$(curl -w  "%{time_total}" --connect-timeout $THRESHOLD $URL_TO_TEST -o/dev/null)
            ## response time of the curl command to the target address

            if [ "$?" -ne "0" ]; ## check the curl command properly worked properly 
            then
                cecho "RED" "The request failed in threshold"
                call_slack $URL_TO_TEST ## call the slack
            else
                cecho "BLUE" "All clear ${TIME_TO_RESPONSE}"
            fi
        
        else
            cecho "RED" "Link not valid:: https://site.co" 
            exit 1
        fi
    done

}

create_load ## call the load functions