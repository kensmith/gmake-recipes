# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Compute the encapper package path for package $(1) with
# version $(2).
# Eg.
#
# path1 := $(call path-to,libmylib,trunk)
# path2 := $(call path-to,luadoc,3.0)
# path3 := $(call path-to,lua,5.1.3)
path-to = \
$(install-root)/$(whoami)-$(strip $(1))$(strip \
$(if $(strip $(2)), \
  -$(strip $(2)), \
  -trunk \
 ))

system-path-to = \
$(firstword \
  $(wildcard \
    $(addsuffix \
      /$(strip $(1)),\
      $(subst :,$(space),$(PATH)) \
     ) \
   ) \
 )
