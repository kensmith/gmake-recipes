# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Recursive rule generator for making all the rules required
# to build a directory up from root.
# Eg.
#
# $(call make-directory-rules,/tmp/a/b/c/d)
#
# This generates these rules:
# /tmp: | /; mkdir $@
# /tmp/a: | /tmp: mkdir $@
# /tmp/a/b: | /tmp/a: mkdir $@
# /tmp/a/b/c: | /tmp/a/b: mkdir $@
# /tmp/a/b/c/d: | /tmp/a/b/c: mkdir $@
#
# $(1) directory name (only absolute paths tested)
make-directory-rules = \
$(strip \
  $(eval .mdr-dir := $(patsubst %/,%,$(1))) \
  $(eval .mdr-dir := $(strip $(.mdr-dir))) \
  $(if $(and $(.mdr-dir),$(call neq,.,$(.mdr-dir))), \
    $(if $(call not,$($(.mdr-dir))), \
      $(eval $(.mdr-dir):;$$(call announce-mkdir,$(.mdr-dir))) \
      $(eval $(.mdr-dir): $(prep-encap)) \
      $(eval $(.mdr-dir) := created rule) \
      , \
      $(comment rule exists for $(.mdr-dir)) \
     ) \
    $(call make-directory-rules,$(dir $(.mdr-dir))) \
   ) \
 )

# Replace a path component by number
#
# Eg.
#
# $(call replace-path-component,1,/tmp/a/b/c/d,hello)
#
# Yields:
#
# /hello/a/b/c/d
#
# $(call replace-path-component,2,/tmp/a/b/c/d,hello)
#
# Yields:
#
# /tmp/hello/b/c/d
#
# $(call replace-path-component,1,tmp/a/b/c/d,hello)
#
# Yields:
#
# hello/a/b/c/d
replace-path-component = \
$(strip \
  $(eval .space-sentinel := SPACESENTINELSPACE) \
  $(eval .path := $(subst $(space),$(.space-sentinel),$(2))) \
  $(if $(call neq,$(.path),$(patsubst /%,%,$(.path))), \
    $(eval .first-slash := /), \
    $(eval .first-slash :=) \
   ) \
  $(if $(call neq,$(.path),$(patsubst %/,%,$(.path))), \
    $(eval .last-slash := /), \
    $(eval .last-slash :=) \
   ) \
  $(eval .path := $(subst /,$(space),$(.path))) \
  $(eval .repl := $(subst $(space),$(.space-sentinel),$(3))) \
  $(eval .newpath := \
    $(wordlist 1,$(call --,$(1)),$(.path)) \
    $(.repl) \
    $(wordlist $(call ++,$(1)),$(words $(.path)),$(.path)) \
   ) \
  $(eval .newpath := $(subst $(space),/,$(strip $(.newpath)))) \
  $(eval .newpath := $(addprefix $(.first-slash),$(.newpath))) \
  $(eval .newpath := $(addsuffix $(.last-slash),$(.newpath))) \
  $(eval .newpath := $(subst $(.space-sentinel),$(space),$(.newpath))) \
  $(.newpath) \
 )
