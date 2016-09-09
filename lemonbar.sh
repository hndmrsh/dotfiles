#!/bin/bash

# Inspiration: use fifo/background jobs/subshells to allow different sleep schedules per bar and performance improvements
# https://raw.githubusercontent.com/onespaceman/dotfiles/158a49ab84b92e9653b476b5964e71d411e49ecc/lemonbar/.config/lemonbar/bar

#####################
###### HELPERS ######
#####################
debug () {
    (>&2 echo "$1")
}

getproproot () {
    echo "$(obxprop --root "$1")" | cut -d "=" -f 2
}

getpropid () {
    echo "$(obxprop --id "$2" "$1")" | cut -d "=" -f 2
}

#####################
###### BLOCKS #######
#####################

lb_workspaces() {
    WORKSPACE_NAMES=$(getproproot "_NET_DESKTOP_NAMES" | tr -d ",")
    CURRENT_WORKSPACE_NUM=$(getproproot "_NET_CURRENT_DESKTOP")
    WINDOW_IDS=$(getproproot "_NET_CLIENT_LIST" | tr -d ",")
    ACTIVE_WINDOW_ID=$(getproproot "_NET_ACTIVE_WINDOW" | tr -d " ")

    # define array of window "icons"
    for window in $WINDOW_IDS; do
        TITLE=$(getpropid "_OB_APP_NAME" $window)
        WID=$(getpropid "_NET_WM_DESKTOP" $window)

        if [ ! -z "$TITLE" ]; then
            if [ $window -eq $ACTIVE_WINDOW_ID ]; then
                ICON="%{B#BB000000}  ${TITLE:2:1}  %{B#A0000000}"
            else
                ICON="  ${TITLE:2:1}  "
            fi


            WINDOWS[$WID]="${WINDOWS[$WID]}$ICON"
        fi
    done

    let "i = 0"
    for w in $WORKSPACE_NAMES; do
        WINDOWS_OUTPUT="${WINDOWS[$i]}"
        if [ ! -z  "$WINDOWS_OUTPUT" ]; then
            TW=$(echo $w | tr -d "\"")

            # if [ $CURRENT_WORKSPACE_NUM -eq $i ]; then
            #     echo -n "%{B#FF000000} $TW %{B#A0000000}"
            # else
            #     echo -n "%{B#BB000000} $TW %{B#A0000000}"
            # fi

            echo -n "%{B#FF000000}  $TW  %{B#A0000000}$WINDOWS_OUTPUT"
        fi
        let "i = i + 1"
    done
}

lb_clock() {
    TIME="$(date "+%l:%M %p")"
    echo -n "$TIME"
}

lb_stat() {
    CPU="$(mpstat 1 1 | tail -n 1 | awk '$12 ~ /[0-9.]+/ { print 100 - $12 }')"
    RAM="$(free -b | awk 'NR==2 {print $3/$2*100}')"

    echo -n "CPU: $(printf "%.0f%%" "$CPU")  RAM: $(printf "%.0f%%" "$RAM")"
}

lb_uptime() {
    UPTIME="$(uptime -p)"
    if [ -z "${UPTIME:3}" ]; then
        echo "0 minutes"
    else
        echo -n "${UPTIME:3}"
    fi
}

lb_redshift() {
    REDSHIFT=$(redshift -p 2> /dev/null | tail -n 2 | head -n 1 | cut -d ':' -f 2 | tr -d ' ')
    echo -n "$REDSHIFT"
}

lb_asana() {
    COUNT=$(asana-tasks-due)
    echo -n "$COUNT tasks due"
}

lb_tvstatus() {
    COUNT=$(xrandr | grep "[0-9]\+x[0-9]\++[0-9]\++[0-9]\+" | wc -l)

    if [ $COUNT -eq 3 ]; then
        echo -n "tv on"
    else
        echo -n "tv off"
    fi
}

#####################
###### RENDER #######
#####################
while true; do
        echo -n "%{l}%{F#FFFFFF}%{B#2F343F}"
        # echo -n "$(lb_workspaces)"
        echo -n "%{r}"
        echo -n " | $(lb_redshift) | "
        # echo -n " | $(lb_tvstatus) | "
        # echo -n " | $(lb_asana) | "
        echo -n " | $(lb_uptime) | "
        echo -n " | $(lb_stat) | "
        echo -n " | $(lb_clock) | "
        echo
        sleep 1
done
