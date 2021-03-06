# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# When reading through the gmake recipes remember that all
# the variables here, as well as the numerous included
# files, are in one global namespace.  Gmake offers no
# alternative.
#

$(if $(call not,$(srcs)), \
  $(eval srcs :=) \
 )

$(if $(call not,$(includes)), \
  $(eval includes :=) \
 )

$(if $(call not,$(tests)), \
  $(eval tests :=) \
 )

# These are useful because they are often treated specially
# and we occasionally want to treat them literally.
empty :=# null string
space :=$(empty) # a single space (comment must be one space from $(empty))
comma := ,

# Set show to the empty string, `make show=t`, to show the
# actual commands being run rather than the normal
# sysnopses.
show :=

# Projects paths are svn/ca/proj/trunk with the GNUmakefile
# residing in trunk.  That means that the top of the
# repository is two directories higher.
svn-home ?= ../..

# These are the target types that gmake recipes can build.
supported-types := dylib prog lua-c-module staticlib

# These are the target platforms that gmake recipes can build.
supported-platforms := native gnu-arm gnu-arm-thumb

gmake-recipes-config-filename := $(CURDIR)/gmake-recipes-config.mk
gmake-recipes-config-file := $(wildcard $(gmake-recipes-config-filename))

# Sudo binary location.  Assumed to be in the path somewhere.
sudo := sudo

# Custom search for bash binary.
bash-loc := $(word 1,$(wildcard /bin/bash /usr/bin/bash /usr/local/bin/bash))

# Use bash as our default shell.  This helps avoid some of
# the cross platform issues, though not all, between Darwin,
# Linux, and Solaris.
$(if $(bash-loc), \
  $(eval SHELL := $(bash-loc)), \
  $(error This makefile requires bash.) \
 )

# Make sure we're running with GNU make version 3.81 or
# later.
#make-version := $(subst .,$(space),$(MAKE_VERSION))
#$(error $(MAKE_VERSION))
#make-major-version := $(word 1,$(make-version))
#make-minor-version := $(word 2,$(make-version))
#check-major-version := $(shell (($(make-minor-version) < 3)) && echo eek)
#check-minor-version := $(shell (($(make-minor-version) < 81)) && echo eek)
#$(if $(check-major-version)$(check-minor-version), \
#  $(error This make file requires version 3.81 or higher of GNU make) \
# )

# Platform attributes.
osname := $(subst $(space),-,$(shell uname -s))
osver := $(subst $(space),-,$(shell uname -r))
cpuarch := $(subst $(space),-,$(shell uname -m))

# The directory containing the gmake-recipe files.
this-dir := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

organization ?= organization

# If we're encapping (installing) then set the flag to
# prepare the encap repository by removing existing encap
# packages.
$(if $(filter encap,$(MAKECMDGOALS)), \
  $(eval prep-encap := prepare-encap) \
 )

.SUFFIXES:

# Load library functions.
include $(this-dir)/lib/usage.mk
include $(this-dir)/lib/logic.mk
include $(this-dir)/lib/assert.mk
include $(this-dir)/lib/list.mk
include $(this-dir)/lib/debug.mk
include $(this-dir)/lib/source-tree.mk
include $(this-dir)/lib/file-manip.mk
include $(this-dir)/lib/version.mk
include $(this-dir)/lib/terse.mk
include $(this-dir)/lib/directory.mk
include $(this-dir)/lib/dependency.mk
include $(this-dir)/lib/derive.mk
-include $(this-dir)/lib/math.mk # autogenerated, see finalize.mk

# Default compiler names for supported platforms.
$(if $(call eq,$(osname),Darwin),$(eval compiler ?= gcc))
$(if $(call eq,$(osname),SunOS),$(eval compiler ?= cc))
$(if $(call eq,$(osname),Linux),$(eval compiler ?= gcc))

# Compiler versions
$(if $(call eq,$(osname),Linux), \
  $(if $(call eq,$(compiler),gcc), \
    $(eval compiler-version := $(shell gcc -dumpversion)) \
   ) \
 )

$(if $(call eq,$(osname),Darwin), \
  $(if $(call eq,$(compiler),gcc), \
    $(eval compiler-version := $(shell gcc -dumpversion)) \
   ) \
 )

$(if $(call eq,$(osname),SunOS), \
  $(if $(call eq,$(compiler),cc), \
    $(eval compiler-version := $(shell CC -V 2>&1 |awk '{print $$4}')) \
   ) \
 )

# Don't proceed without an idea of what the compiler should
# be.  This can be set on the command line.
# Eg.
# make compiler=CC.
$(if $(call not,$(compiler)), \
  $(error no compiler definition for this platform) \
 )

$(if $(call not,$(compiler-version)), \
  $(error could not determine compiler version) \
 )

# The build directory contains platform information to
# prevent the linker from accidentally attempting to link
# different platform's binaries.  This will matter more when
# we use network mounted developer home directories.
build-reldir :=  \
$(strip \
  $(subst $(space),-,$(strip \
      build/$(plat) \
      $(type) \
     )) \
 )

# Absolute path.
build-dir := \
$(strip \
  $(subst $(space),-,$(strip \
      $(CURDIR)/$(build-reldir) \
     )) \
 )

# The custom encapper binary.
encapper := $(this-dir)/build/native-prog/encapper

lua-version ?= 5.1

# Break the current working directory into tokens.
intermediate-curdir := $(subst $(space),-,hi $(CURDIR))
intermediate-curdir := $(subst /,$(space),$(intermediate-curdir))

# Deepest token represents the version, eg. trunk, eg.
# 2.6.1.  Second deepest token represents the project name,
# eg. libcalxs, eg. afltnav.
intermediate-curdir := $(call reverse,$(intermediate-curdir))
release-name := trunk
project-name := $(word 1,$(intermediate-curdir))
top-level-tag := $(word 2,$(intermediate-curdir))
top-level-name := $(word 3,$(intermediate-curdir))

# Currently logged in user's ID.
whoami := $(strip $(shell whoami))

# Encapped project name.
full-project-name := $(whoami)-$(top-level-name)-$(top-level-tag)-$(project-name)-$(release-name)
plain-project-name := $(project-name)-$(release-name)
organization-root = /usr/local/$(organization)
install-root := $(organization-root)/encap
install-prefix := $(install-root)/$(full-project-name)
install-prefix-backup := $(install-root)/.$(full-project-name)

# Make the installation top level directory with the
# appropriate permissions.
$(foreach d,$(organization-root) $(install-root), \
  $(if $(call not,$(wildcard $(d))), \
    $(warning $(d) doesn't exist.  Making $(d).) \
    $($(shell \
      sudo mkdir -p $(d) \
      ; \
      sudo chmod 1777 $(d) \
     )) \
   ) \
 )

# More library functions.
include $(this-dir)/lib/path-to.mk
include $(this-dir)/lib/load-compiler.mk
