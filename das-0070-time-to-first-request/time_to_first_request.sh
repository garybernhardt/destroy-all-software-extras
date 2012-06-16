#!/bin/bash

main() {
    print_runtime > /dev/null
    print_runtime
}

print_runtime() {
    pid=$(start_server)
    runtime=$(time_command wait_for_server)
    baseline=$(time_command wait_for_server)
    echo $runtime - $baseline | bc
    kill -9 $pid
}

start_server() {
    cd example
    rackup >/dev/null 2>&1 &
    echo $!
}

time_command() {
    local cmd=$*
    TIMEFORMAT="%3R"
    (time $cmd) 2>&1
}

wait_for_server() {
    while true; do
        lsof -i :9292 > /dev/null
        if [[ $? == 0 ]]; then
            break
        fi
    done
}

main

