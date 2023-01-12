#!/bin/bash

source .env
source .localenv






### Genric sources
for js in src/data/*.js; do
    echo "[INFO] Working on '$js'..."
    node $js
done
