#!/usr/bin/env bash
# Script to toggle the capacitive touchscreen after detecting that the
# LEFT+RIGHT keys are pressed together
#
# Adapted from https://duckpond.ch/evkill/bash/2020/08/10/disable-reMarkable-touchscreen-with-evkill.html

 set -euo pipefail

DEVICE_BUTTONS='/dev/input/event1' # Input of the physical button (gpio-keys)
DEVICE_TO_KILL='/dev/input/event2' # Input to kill (capacitive screen, cyttsp5_mt)

# commands
EVTEST=$(command -v evtest || echo '/home/root/evtest')
EVKILL=$(command -v evkill || echo '/home/root/evkill')

LEFT_DOWN=false
RIGHT_DOWN=false

toggle_evkill(){
  local evkill_pid
  evkill_pid="$(pidof evkill || true)"
  if [ -z "${evkill_pid}" ]; then
    echo "=> Disable touchscreen: ${EVKILL} ${DEVICE_TO_KILL}"
    "${EVKILL}" "${DEVICE_TO_KILL}" &
  else
    echo "=> Enable touchscreen: kill ${evkill_pid}"
    kill "${evkill_pid}" &>/dev/null
  fi
}

handle_events(){
  local key_left_down='*type 1 (EV_KEY), code 105 (KEY_LEFT), value 1*'
  local key_left_up='*type 1 (EV_KEY), code 105 (KEY_LEFT), value 0*'
  local key_right_down='*type 1 (EV_KEY), code 106 (KEY_RIGHT), value 1*'
  local key_right_up='*type 1 (EV_KEY), code 106 (KEY_RIGHT), value 0*'

  "$EVTEST" "$DEVICE_BUTTONS" | while read -r line; do
      case $line in
          ($key_left_down) LEFT_DOWN=true ;;
          ($key_left_up) LEFT_DOWN=false ;;
          ($key_right_down) RIGHT_DOWN=true ;;
          ($key_right_up) RIGHT_DOWN=false ;;
          (*) continue ;;
      esac
      echo "$line -> LEFT ${LEFT_DOWN} , RIGHT: ${RIGHT_DOWN}"

      if [ "${LEFT_DOWN}" = true ] && [ "${RIGHT_DOWN}" = true ]; then
        toggle_evkill
      fi
  done
}

handle_events
