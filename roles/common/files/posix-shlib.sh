#!/bin/sh

# Much of this came from the Public Domain licensed https://github.com/client9/shlib - portable posix shell functions

# portable functions for posix shell environments

# echoerr: write message to stderr
echoerr() {
  echo "$@" 1>&2
}

# is_command: returns true if command exists
is_command() {
  command -v "$1" >/dev/null
  #type "$1" > /dev/null 2>/dev/null
}

is_usable() {
  test -x "$1" >/dev/null
}

now() {
  date '+%F %T'
}

# function to prefix each log output
#  over-ride to add custom output or format
#
# by default prints the script name ($0)
log_prefix() {
  echo "$0"
}

# default priority
_logp=6

# set the log priority
log_set_priority() {
  _logp="$1"
}

# if no args, return the priority
# if arg, then test if greater than or equals to priority
log_priority() {
  if test -z "$1"; then
    echo "$_logp"
    return
  fi
  [ "$1" -le "$_logp" ]
}

log_tag() {
  case $1 in
    0) echo "emerg:" ;;
    1) echo "alert:" ;;
    2) echo "crit:" ;;
    3) echo "error:" ;;
    4) echo "warning:" ;;
    5) echo "notice:" ;;
    6) echo "info:" ;;
    7) echo "debug:" ;;
    *) echo "$1" ;;
  esac
}

log_debug() {
  log_priority 7 || return 0
  echoerr "$(log_prefix)" "$(log_tag 7)" "$@"
}

log_info() {
  log_priority 6 || return 0
  echoerr "$(log_tag 6)" "$@"
}

log_warn() {
  log_priority 4 || return 0
  echoerr "$(log_tag 4)" "$@"
}

log_err() {
  log_priority 3 || return 0
  echoerr "$(log_tag 3)" "$@"
}

# log_crit is for platform problems
log_crit() {
  log_priority 2 || return 0
  echoerr "$(log_prefix)" "$(log_tag 2)" "$@"
}

### Options/Args handling

invalid_option() {
  echo "$0: invalid option $1"
  usage
  exit 1
}

### Hints for your script that uses this lib:

# usage() {
# cat <<- USAGE
#   Usage: $0 [options] [POSITIONAL_ARG]
# USAGE

# cat <<-USAGE

#   Batch renames branches with a matching prefix to another prefix

#   Options:
#   -h|--help     - show this page.
#   -v|--verbose  - print more details about what is being done.
#   -n|--dry-run  - do not make any changes

#   Examples:
#   $ <this script> -v <some_arg>
#   <some_output>

#   Copyright (C) <year> <your_name> [(<your_nickname/handle>)] <your_email>
#   [License: <license, including hyperlink>]
# USAGE
# }
