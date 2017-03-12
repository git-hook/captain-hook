#!/usr/bin/env bats
# Written by Eric Crosson
# 2017-03-12
#
# Test captain-hook.sh

setup() {
    . "${BATS_TEST_DIRNAME}/../captain-hook.sh"
}

@test "debug should print nothing when debug mode is not enabled" {
    run debug 'A light switch is also a dark switch.'
    [ "${status}" -eq 0 ]
    [ "${output}" = '' ]
}

@test "debug mode should print all args when debug mode is enabled" {
    _debug=1
    debug "Nope"
    truth='When you clean a vacuum cleaner, you are the vacuum cleaner.'
    run debug "${truth}"
    [ "${status}" -eq 0 ]
    [ "${output}" = "${truth}" ]
}
