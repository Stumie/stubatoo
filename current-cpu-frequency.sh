#!/usr/bin/env bash

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts

### Function declarations ###

current-cpu-frequency_generate-output () {
    for f in $(ls -1v /sys/devices/system/cpu/ | grep -E '^cpu([0-9]+)$'); do
        cpu=$(basename $f)
        echo "$f $((`cat /sys/devices/system/cpu/$cpu/cpufreq/scaling_cur_freq`/1000)) Mhz"
    done
}

current-cpu-frequency_columnized-output () {
    current-cpu-frequency_generate-output | column -t
    echo ""
    echo "Ctrl+C to quit"
}

### Procedures ###

$SUBSCRIPT/check-for-software-existence.sh column watch

export -f current-cpu-frequency_generate-output
export -f current-cpu-frequency_columnized-output

watch -t -n1 -x bash -c current-cpu-frequency_columnized-output