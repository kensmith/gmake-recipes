# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# These macros can only be called after including
# finalize.mk because finalize.mk defines targets and uses
# the platform dependent $(mkdir)

# Generate rules for installing a list of files to a
# specific location.
# $(1) = space separated list of files
# $(2) = install location
# $(3) = optional mode
.PHONY: install-man
install-files = \
$(strip \
  $(eval .files := $(1)) \
  $(eval .target-dir := $(2)) \
  $(call make-directory-rules,$(.target-dir)) \
  $(foreach f,$(.files), \
    $(eval .this-target := $(.target-dir)/$(notdir $(f))) \
    $(eval $(.this-target): $(f) | $(.target-dir) \
      ; $$(if $$(call not,$$(show)),@echo inst $$@;) $$(install) $$< $$@ \
      $(if $(strip $(3)), \
        ; chmod $3 $$@ \
       ) \
     ) \
    $(eval encap: $(.this-target)) \
    $(eval $(.this-target): $(prep-encap)) \
   ) \
 )

# Install Lua modules to the standard location.
#
# $(call install-lua-modules,<lua files>,<module namespace>)
install-lua-modules = $(call install-files,$(1),$(abspath $(lua-module-install-location)/$(2)))

# Install man pages to the standard locations.
#
# $(call install-man-pages,<man files>,<section number>)
install-man-pages = $(call install-files,$(1),$(abspath $(man-install-location)/man$(strip $(2))))

# Install files into the bin directory.
#
# $(call install-scripts,<script files>,<subdir of bin>)
install-scripts = $(call install-files,$(1),$(abspath $(prog-install-location)/$(2)),0755)

# Install configuration files into the standard location.
#
# $(call install-config-files,<config files>,<subdir>)
install-config-files = $(call install-files,$(1),$(abspath $(config-install-location)/$(2)),0644)

# Build and install luadoc documentation into the standard
# location.
#
# $(call install-luadoc,<list of lua sources to run through
# luadoc>,<subdir of standard luadoc dir>)
install-luadoc = \
$(strip \
  $(eval $(luadoc-install-location)/index.html: \
    $(addprefix $(CURDIR)/,$(1)); $(if $(call not,$(show)),@echo \
      ldoc $(project-name); \
      mkdir -p $$(dir $$@); \
      (cd $(luadoc-install-location); $$(call path-to,luadoc,3.0)/bin/luadoc --no-files $(2) \
       $$(filter-out $(prep-encap),$$^)) \
     ) \
   ) \
  $(eval luadoc: $(luadoc-install-location)/index.html) \
  $(eval $(luadoc-install-location)/index.html: $(prep-encap)) \
 )

# Diff two files copying the first over the second if they
# are different.  Runs in $(shell) or rule context.
rename-if-changed = \
$(strip \
  if ! diff $(1) $(2) > /dev/null 2>&1; then \
    $(move) $(1) $(2); \
  else \
    $(delete) $(1); \
  fi \
 )

# Diff two files copying the first to the second if they
# are different.  Runs in $(shell) or rule context.
copy-if-changed = \
$(strip \
  if ! diff $(1) $(2) > /dev/null 2>&1; then \
    $(install) $(1) $(2); \
  fi \
 )
