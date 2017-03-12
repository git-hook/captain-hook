# Written by Eric Crosson
# 2017-03-12
#
# This makefile provides targets to test captain-hook.

tests := $(wildcard test/*.sh)

.PHONY: test

test: $(tests)
	@$(foreach test,$(tests),$(test);)
