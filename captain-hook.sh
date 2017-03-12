#!/usr/bin/env bash
# Written by Eric Crosson
# 2016-10-28
#
# This script provides a framework for git hooks.
#
# Goals:
# - provide an isolated space for each hook
# - provide a scalable framework for development to expand into
# - DRY
# - handle edge cases in git flows (mainly due to stashing)

# set -x

#------------------------------------------------------------------------------
# Define constants
#------------------------------------------------------------------------------
# Set this flag to a 1 to get debugging output
#
# Note: may not work great with the in-place test status updates.
#       Consider logging with `tee` to a file for inspection.
declare _debug=0

# Use this command instead of `echo` to only print information when
# debug-mode is enabled.
debug() {
    if [[ "${_debug}" -gt 0 ]]; then
        >&2 echo "$@"
    fi
}

_getPipeline() {
    searchDir=$1; shift
    find "${searchDir}" \
         -regex ".*/[0-9]\{3\}+\{0,1\}.*" \
        | sort
}

_ensuredScript() {
    [ -z "$(echo "${script}" | sed -ne '/[0-9]\{3\}+/p')" ]
}

_updateRc() {
    if [[ $1 -eq 0 ]]; then
        echo $2
    else
        echo $1
    fi
}

_shortCircuit() {
    local -r rc=$1; shift
    [ "${rc}" -le 0 ]
}

_determineExitCode() {
    local -r rc=$1; shift
    # negative exit codes indicate a short-circuit without failure
    if _shortCircuit "${rc}"; then
        echo 0
    else
        echo "${rc}"
    fi
}

runHook() {
    local -r hook=$1; shift
    local rc=0

    local -r pipeline=$(_getPipeline "${hook}.d")
    while IFS= read -rd '' script; do
        # if part of the pipeline has failed, skip forward to the
        # "ensured" scripts
        if [[ "${rc}" -ne 0 ]]; then
            ! _ensuredScript "${script}" && continue
        fi

        debug "Executing script: '${script}'..."
        "${script}" "$@"
        rc=$(_updateRc "${rc}" $?)
        debug "Executing script: '${script}'...done"
    done <  <("${pipeline}")

    exit "$(_determineExitCode "${rc}")"
}
export runHook
