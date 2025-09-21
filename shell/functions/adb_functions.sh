#!/bin/bash

# function adbe2() {
#   __adbe_main $@
# }

function __adbe_main() {
  local _SUBCOMMAND=""
  local _SUBCOMMAND_ARGUMENTS=()
  local _DEFAULT_SUBCOMMAND="help"

  while ((${#})); do
    __opt="${1}"
    shift

    case "${__opt}" in
    -h | --help)
      if [[ -n "${_SUBCOMMAND}" ]]; then
        _SUBCOMMAND_ARGUMENTS+=("${__opt}")
      else
        _SUBCOMMAND="help"
      fi
      ;;
    -v | --version)
      if [[ -n "${_SUBCOMMAND}" ]]; then
        _SUBCOMMAND_ARGUMENTS+=("${__opt}")
      else
        _SUBCOMMAND="version"
      fi
      ;;
    # --debug)
    #   _USE_DEBUG=1
    #   ;;
    *)
      # The first non-option argument is assumed to be the subcommand name.
      # All subsequent arguments are added to $_SUBCOMMAND_ARGUMENTS.
      if [[ -n "${_SUBCOMMAND}" ]]; then
        _SUBCOMMAND_ARGUMENTS+=("${__opt}")
      else
        _SUBCOMMAND="${__opt}"
      fi
      ;;
    esac
  done

  if [[ -z "${_SUBCOMMAND}" ]]; then
    _SUBCOMMAND="${_DEFAULT_SUBCOMMAND}"
  fi

  local __func="__adbe_$_SUBCOMMAND"

  # echo "_SUBCOMMAND = $_SUBCOMMAND"
  # echo "_SUBCOMMAND_ARGUMENTS = $_SUBCOMMAND_ARGUMENTS"
  # echo "__func = $__func"

  if [[ $(declare -F -f $__func) ]]; then
    eval "__adbe_$_SUBCOMMAND $_SUBCOMMAND_ARGUMENTS"
  else
    eval "adb $_SUBCOMMAND $_SUBCOMMAND_ARGUMENTS"
  fi
}

function __adbe_mirror() {
  echo "Mirroring device via scrcpy"
  scrcpy $@
}

function __adbe_version() {
  echo "0.0.1"
}

function __adbe_debug() {
  echo "adbe debug $@"
}

function __adbe_help() {
  echo """
  Usage:  adbe <command> [options]

    commaneds:
      help      : show help info
      version   : version info
      link      : link device via wifi
      screencap : capture an screenshot
      laybound  : enable/disable layout bonary
      mirror    : mirror device via scrcpy
      inputKey  : send key event
      wakeup    : wake device up
      sleep     : sleep

    options:
      -h        : manual for that command

  """
}

function __adbe_link() {
  local __device_ip=$(nocorrect adb shell ip addr show wlan0 | grep -E "inet " | sed -nE "s_.*inet (([0-9]{1,3}\.?){4}).*_\1_p")
  adb tcpip 5555
  adb connect $__device_ip
}

function __adbe_screencap() {

  if [ "$#" -gt 0 ]; then
    name=$1
  else
    name='screencap'
  fi

  adb shell screencap -p /sdcard/$name.png
  adb pull /sdcard/$name.png
  echo "screencap has been stored in $PWD/$name.png"
}

function __adbe_laybound() {
  while ((${#})); do
    __opt="${1}"
    shift

    case "${__opt}" in
    -h | --help)
      echo """Enable or disable layout boundary.
        Usage: adbe laybound <-h> <enable|true|disable|false>
        """
      exit
      ;;
    enable | true | on)
      nocorrect adb shell setprop debug.layout true && adb shell service check SurfaceFlinger
      nocorrect adb shell service call activity 1599295570
      ;;
    disable | false | off)
      nocorrect adb shell setprop debug.layout false && adb shell service check SurfaceFlinger
      nocorrect adb shell service call activity 1599295570
      ;;
    *)
      echo "command $__opt not found"
      ;;
    esac
  done

}


function __adbe_inputKey() {
  while ((${#})); do
    __opt="${1}"
    shift

    case "${__opt}" in
    -h | --help)
      echo """Input key event.
        Usage: adbe inputKey <-h> <home|back|vUp|vDown>
        """
      exit
      ;;
    home)
      echo "Press Home"
      adb shell input keyevent 3
      ;;
    back)
      echo "Press Back"
      adb shell input keyevent 4
      ;;
    vMute)
      echo "Press volume mute"
      adb shell input keyevent 164
      ;;
    vDown)
      echo "Press volume down"
      adb shell input keyevent 25
      ;;
    vUp)
      echo "Press volume up"
      adb shell input keyevent 24
      ;;
    *)
      eval "adb shell input keyevent $__opt"
      ;;
    esac
  done

}


function __adbe_wake() {
  adb shell input keyevent 224
}


function __adbe_sleep() {
  adb shell input keyevent 223
}



alias adbe='__adbe_main'