# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# This original implementation attempted to find the latest numbered version
# and adding an asterisk when building from trunk.  This doesn't work with
# our new policy of #.#rc#.
#version-string = \
$(strip \
  $(eval tmp := \
    $(strip \
      $(eval .my-dir := $(notdir $(CURDIR))) \
      $(if $(filter 0% 1% 2% 3% 4% 5% 6% 7% 8% 9%,$(.my-dir)), \
        $(if $(strip $(.my-dir)), \
          $(.my-dir) \
          $(eval gmake-recipes := $(strip $(.my-dir))) \
          , \
          $(error Could not determine release name) \
         ) \
        , \
        $(eval res:=$(notdir $(wildcard ../*))) \
        $(eval res:=$(filter 0% 1% 2% 3% 4% 5% 6% 7% 8% 9%,$(res))) \
        $(eval res:=$(sort $(res))) \
        $(eval latest-major-version:=$(lastword $(shell for each in $(res); do echo $$each | sed -e 's/\..*//'; done|sort -n|uniq))) \
        $(eval res:=$(filter $(latest-major-version)%,$(res))) \
        $(eval latest-minor-version:=$(lastword $(shell for each in $(res); do echo $$each | sed -e 's/.*\.//'; done|sort -n|uniq))) \
        $(latest-major-version).$(latest-minor-version)$(if $(call eq,$(.my-dir),trunk),*) \
       ) \
     ) \
   ) \
  $(if $(call eq,$(strip $(tmp)),.*), \
    0.0, \
    $(tmp) \
   ) \
 )

# Version is now just the release name.
version-string = $(release-name)
