# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Announce a terse message about a command, then run the
# command.
# Eg.
# 
# $(call announce,verb,filename)
announce = \
$(strip \
  $(eval .verb := $(1)) \
  $(eval .filename := $(or $(2),$@)) \
  $(if $(call not,$(show)), \
    @echo $(.verb) $(patsubst $(CURDIR)/%,%,$(.filename)); \
   ) \
 )

# Make a directory with a terse message.
announce-mkdir = $(call announce,mkdr,$(1)) $(mkdir) $(1)

# Install a file with a terse message.
announce-install = $(call announce,inst,$(2)) $(install) $(1) $(2)

# Delete a file (rm) with a terse message.
announce-clean = $(call announce,clean) $(delete) $(1)

# Delete a file or directory (rm -Rf) with a terse message.
announce-recursive-clean = $(call announce,recursive-clean) \
  $(recursive-delete) $(1)

# Run a test with a terse message.
announce-exec = $(call announce,exec,$(1)) $(1)

announce-make = $(call announce,make,$(1)) $(strip \
  $(MAKE) \
    -C $(1) \
    $(if $(strip $(terse)),--no-print-directory) \
    $(2) \
 )
