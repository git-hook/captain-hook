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

runHook() {
    local -r hook=$1; shift
    local rc=0

    for script in $(find "${hook}.d" \
                         -regextype sed \
                         -regex ".*/[0-9]\{3\}+\{0,1\}.*" | \
                        sort); do

        # if part of the hook has failed, skip forward to the
        # `ensured` scripts
        if [[ "${rc}" -ne 0 && \
                  -z "$(echo "${script}" | sed -ne '/[0-9]\{3\}+/p')" ]]
        then
            continue
        fi

        chmod u+x "${script}"
        debug "Executing ${script}"
        "${script}" "$@"
        local script_rc=$?
        # exit code can only be modified one time
        if [[ "${rc}" -eq 0 ]]; then
            rc="${script_rc}"
        fi
    done

    # negative exit codes indicate a short-circuit without failure
    debug "Return code is ${rc}"
    if [[ "${rc}" -le 0 ]]; then
        exit 0
    else
        exit "${rc}"
    fi
}
export runHook
