# Written by Eric Crosson
# 2017-03-12
#
# This makefile provides targets to test the provided project.

tests := $(wildcard test/*.sh)

.PHONY: test

test: $(tests)
	bats $(tests)
