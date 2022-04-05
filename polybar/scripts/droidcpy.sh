#!/usr/bin/env bash

# name of the android device, check with "adb wait-for-device devices -l"
my_device="Redmi_7A"

# test the status of each systemd services
test_scrcpy=$(systemctl --user is-active scrcpy.service)
test_sndcpy=$(systemctl --user is-active sndcpy.service)
test_v4l2ipwebcam=$(systemctl --user is-active v4l2-ipwebcam.service)
# test the presence of some device on adb, with a 4 sec timeout
device_test="$(timeout 4 adb wait-for-device devices -l 2>&1)"

if [[ "$device_test" == *"$my_device"* ]]; then
    # if the device is connected define 3 icons with a systemd command and a color depending of their current state
    if [[ "$test_scrcpy" = "active" ]] ; then
        icon_scrcpy="%{F#68f400}%{A1:systemctl --user stop scrcpy.service:}%{A}%{F-}"
    elif [[ "$test_scrcpy" = "failed" ]]; then
        icon_scrcpy="%{F#f40000}%{A1:systemctl --user start scrcpy.service:}%{A}%{F-}"
    else 
        icon_scrcpy="%{F#99eaeaea}%{A1:systemctl --user start scrcpy.service:}%{A}%{F-}"
    fi
    
    if [[ "$test_sndcpy" = "active" ]] ; then
        icon_sndcpy="%{F#68f400}%{A1:systemctl --user stop sndcpy.service:}蓼%{A}%{F-}"
    elif [[ "$test_sndcpy" = "failed" ]]; then
        icon_sndcpy="%{F#f40000}%{A1:systemctl --user start sndcpy.service:}蓼%{A}%{F-}"
    else 
        icon_sndcpy="%{F#99eaeaea}%{A1:systemctl --user start sndcpy.service:}蓼%{A}%{F-}"
    fi
    
    if [[ "$test_v4l2ipwebcam" = "active" ]] ; then
        icon_v4l2ipwebcam="%{F#68f400}%{A1:systemctl --user stop v4l2-ipwebcam.service:}犯%{A}%{F-}"
    elif [[ "$test_v4l2ipwebcam" = "failed" ]]; then
        icon_v4l2ipwebcam="%{F#f40000}%{A1:systemctl --user start v4l2-ipwebcam.service:}犯%{A}%{F-}"
    else 
        icon_v4l2ipwebcam="%{F#99eaeaea}%{A1:systemctl --user start v4l2-ipwebcam.service:}犯%{A}%{F-}"
    fi
    
    # add a background if some of them is active
    if [[ "$test_scrcpy" = "active" || "$test_sndcpy" = "active" || "$test_v4l2ipwebcam" = "active" ]] ; then
        background="%{B#143820} "
        background_end=" %{B-}"
    else 
        background=""
        background_end=""
    fi
    
    # output to polybar
    echo -e "$background$icon_scrcpy $icon_sndcpy $icon_v4l2ipwebcam$background_end"
 
else
    # if the device is not connected check if some services are still active or failed and display only those ones for corrective actions
    # if a service stay failed you probably have to reconnect the device and start/stop again to clean the state
    if [[ "$test_scrcpy" = "active" ]] ; then
        icon_scrcpy="%{B#5E2014} %{F#68f400}%{A1:systemctl --user stop scrcpy.service:}%{A}%{F-} %{B-}"
    elif [[ "$test_scrcpy" = "failed" ]]; then
        icon_scrcpy="%{B#5E2014} %{F#f40000}%{A1:systemctl --user start scrcpy.service:}%{A}%{F-} %{B-}"
    else 
        icon_scrcpy=""
    fi
    
    if [[ "$test_sndcpy" = "active" ]] ; then
        icon_sndcpy="%{B#5E2014} %{F#68f400}%{A1:systemctl --user stop sndcpy.service:}蓼%{A}%{F-} %{B-}"
    elif [[ "$test_sndcpy" = "failed" ]]; then
        icon_sndcpy="%{B#5E2014} %{F#f40000}%{A1:systemctl --user start sndcpy.service:}蓼%{A}%{F-} %{B-}"
    else 
        icon_sndcpy=""
    fi
    
    if [[ "$test_v4l2ipwebcam" = "active" ]] ; then
        icon_v4l2ipwebcam="%{B#5E2014} %{F#68f400}%{A1:systemctl --user stop v4l2-ipwebcam.service:}犯%{A}%{F-} %{B-}"
    elif [[ "$test_v4l2ipwebcam" = "failed" ]]; then
        icon_v4l2ipwebcam="%{B#5E2014} %{F#f40000}%{A1:systemctl --user start v4l2-ipwebcam.service:}犯%{A}%{F-} %{B-}"
    else 
        icon_v4l2ipwebcam=""
    fi

    # output to polybar
    echo -e "$icon_scrcpy$icon_sndcpy$icon_v4l2ipwebcam"
fi