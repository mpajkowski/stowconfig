#!/bin/bash

TERM_APP=$1

focused_window="$(niri msg -j focused-window)"
pid=$(ycwd $(echo $focused_window | jq .pid))

if [ "$focused_window" = "null" ] || [ -z $pid ]; then
    exec $TERM_APP
else
    exec $TERM_APP --working-directory "$pid"
fi
