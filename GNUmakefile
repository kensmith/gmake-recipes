# Copyright (C) 2006-2009 Ken Smith <kgsmith@gmail>

plat := native
type := prog
name := encapper
organization := organization

include $(CURDIR)/main.mk

.DEFAULT_GOAL := release

macros += ORGANIZATION="\"$(organization)\""

include $(CURDIR)/finalize.mk

$(call install-man-pages,$(wildcard man/man7/*.7),7)

$(if $(strip $(prep-encap)), \
  $(warning \
    Intentionally overriding commands for target `prepare-encap'. \
    Ignore the following warning. \
   ) \
  $(eval $(prep-encap):;) \
 )
