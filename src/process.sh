#!/bin/bash

source .env
source .localenv

echo "  **  PROCESS_CURRENT_RETRY=$PROCESS_CURRENT_RETRY"
if [[ $PROCESS_CURRENT_RETRY == 10 ]]; then
    echo "[ERROR] Reached max process retry count. Need human intervention."
else
    PROCESS_CURRENT_RETRY=0
fi


function retry_job() {
    sourcename="$1"
    echo "[ERROR] Something bad happened when processing the RSS data for source '$sourcename'."
    OVERWRITE=y bash src/fetch.sh "$sourcename"
}






### Genric sources
for js in src/data/*.js; do
    echo "[INFO] Working on '$js'..."
    node $js || FAIL_LIST="$FAIL_LIST $(basename "$js" | cut -d. -f1)"
done

for sourcename in $FAIL_LIST; do
    retry_job "$sourcename"
    # export PROCESS_CURRENT_RETRY="$((PROCESS_CURRENT_RETRY+1))"
    echo '   **   ' exec bash $0
    exec PROCESS_CURRENT_RETRY="$((PROCESS_CURRENT_RETRY+1))" bash $0
done
