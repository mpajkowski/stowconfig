#!/bin/bash

focused_window="$(niri msg -j focused-window)"
pid=$(ycwd $(echo $focused_window | jq .pid))

if [ "$focused_window" = "null" ] || [ -z $pid ]; then
    exec alacritty
else
    exec alacritty --working-directory "$pid"
fi
