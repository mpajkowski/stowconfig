#!/bin/bash

focused_window="$(niri msg -j focused-window)"

if [ "$focused_window" = "null" ]; then
    exec alacritty
else
    exec alacritty --working-directory $(ycwd $(echo $focused_window | jq .pid))
fi
