# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Crawl the current working directory looking for source and
# header files.
$(foreach .lang,$(supported-languages), \
  $(eval srcs += \
    $(call find-files-matching-extension,src,$($(.lang)-source-suffix-patterns))) \
  $(eval includes += \
    $(call find-files-matching-extension,include,$($(.lang)-include-suffix-patterns))) \
  $(eval tests += \
    $(call find-files-matching-extension,test,$($(.lang)-source-suffix-patterns))) \
 )

# Find subdirectories underneath src/ and include/ that need
# to be reflected in the build directory.  Eg.
# src/c++/Foo.cpp becomes build/.../c++/Foo.o.  They are
# reversed so that they are created in order from shallowest
# to deepest.
unique-src-dirs := $(call reverse,$(abspath $(sort $(dir $(srcs)))))
unique-include-dirs := $(call reverse,$(abspath $(sort $(dir $(includes)))))
unique-test-dirs := $(call reverse,$(abspath $(sort $(dir $(tests)))))

# Shorthand for the main targets.
all-goals = development release release-g encap
.PHONY: $(all-goals)

# Set .DEFAULT_GOAL in your GNUmakefile to override
$(if $(call not,$(.DEFAULT_GOAL)), \
  $(eval .DEFAULT_GOAL := development) \
 )

name ?= $(notdir $(abspath $(CURDIR)))

# Tack the prefix and suffix on to the target's basename.
# Eg.
# target := dylib calxs
# => target-fullname => libcalxs.so (On Solaris)
target-fullname := \
   $($(plat)-$(type)-prefix)$(name)$($(plat)-$(type)-suffix)

# Encap package location.
$(if $(strip $($(type)-install-location)), \
  $(if $(strip $(target-fullname)), \
    $(eval installed-target := \
      $($(type)-install-location)/$(target-fullname)) \
   ) \
 )

# Just the path component of the encap directory.
install-location := $(dir $(installed-target))

# Optionally include a secondary compiler definition file to
# allow platform specific tweaks to happen after the target
# parameters have been worked out.
post-compiler-definition-file := \
   $(this-dir)/compilers/$(compiler-specification)-post.mk
-include $(post-compiler-definition-file)

# Assemble the compiler and linker commands.
include $(this-dir)/lib/generate-commands.mk

# make sure encap gets run after other goals specified on the command line
encap: $(filter-out encap,$(MAKECMDGOALS))

# and after the user selected default goal
encap: $(.DEFAULT_GOAL)

# and after encap exists
encap: $(encapper)

# The encap (install) target.
encap: $(installed-target) $(installed-prefix)
	$(call announce,encp,$(full-project-name)) \
	if [[ -d $(install-prefix-backup) ]] \
           && [[ -d $(install-prefix) ]] \
	   && diff -qNr $(install-prefix-backup) $(install-prefix) \
           > /dev/null 2>&1; \
	then \
	   $(recursive-delete) $(install-prefix); \
	   $(move) $(install-prefix-backup) $(install-prefix); \
	   $(encapper) $(full-project-name); \
	else \
	   $(encapper) $(full-project-name); \
	   $(recursive-delete) $(install-prefix-backup); \
	fi

# The unencap (uninstall) target.
unencap:
	$(call announce,unec,$(full-project-name)) \
	$(encapper) -r $(full-project-name)

# This target unencaps any existing project and deletes the
# encapper package to make way for a new installation of the
# same.  This ensures that renmes of header files or other
# modifications to files which may not have existed in
# former builds are correctly reflected all the way through
# to the final installation.
.PHONY: prepare-encap
prepare-encap:
	$(call announce,prep,$(full-project-name)) \
	$(encapper) -rf $(full-project-name) > /dev/null 2>&1 \
	&& if [[ -d $(install-prefix-backup) ]]; then $(recursive-delete) $(install-prefix-backup); fi \
	&& if [[ -d $(install-prefix) ]]; then $(move) $(install-prefix) $(install-prefix-backup); fi

ifneq (,$(strip $(type))) # 2              
$(call assert,$(call has,$(plat),$(supported-platforms)), \
  Target platform "$(plat)" is not in "$(supported-platforms)" \
 )

$(call assert,$(call has,$(type),$(supported-types)), \
  Target type "$(type)" is not in "$(supported-types)" \
 )

# Only run the following when we have a target definition.
# Some makefiles, such as those which only install scripts
# or documentation, don't define targets.

# Absolute path to installed file.
real-target := $(build-dir)/$(target-fullname)
real-target := $(abspath $(real-target))

# Validate the target specification.
$(if $(call not,$(plat)),$(call usage,Missing plat))
$(if $(call not,$(type)),$(call usage,Missing type))
$(if $(call not,$(name)),$(call usage,Missing name))
$(if $(call not, \
       $(filter $(type),$(supported-types)) \
      ), \
  $(call usage,$(type) not in supported types=[$(supported-types)]) \
 )

# Copies the target from the build directory into the
# encapper package.
$(installed-target): $(real-target) | $(abspath $(install-location))
	$(call announce-install,$<,$@)

# Ensure that the encapper package is prepped before the new
# target is installed.
$(installed-target): $(prep-encap)

# Install when performing any main target.
$(all-goals) : $(installed-target)

# Ensure the build directory is there before attempting to
# build the main target.
$(real-target): | $(dir $(real-target))

# Make rules to build all the directories involved in the
# build and installation process.
$(foreach .d, \
  $(dir $(real-target)) \
  $(install-prefix) \
  $(install-location) \
  $(include-install-location) \
  $(dylib-install-location) \
  $(staticlib-install-location) \
  $(prog-install-location) \
  $(man-install-location) \
  $(lua-c-module-install-location) \
  $(lua-module-install-location) \
  $(config-install-location) \
  , \
  $(call make-directory-rules,$(.d)) \
 )

# Before building directories for the encapper package, make
# sure the prep target runs.
$(install-location) $(install-prefix): $(prep-encap)

# Generate custom compile pattern rules.
$(foreach .dir,$(unique-src-dirs), \
  $(eval .src-dir-off-curdir := $(subst $(CURDIR)/src,,$(.dir))) \
  $(eval .this-build-dir := $(abspath $(build-dir)/$(.src-dir-off-curdir))) \
  $(foreach .lang,$(supported-languages), \
    $(foreach .extn-pattern,$($(.lang)-source-suffix-patterns), \
      $(eval \
        $(.this-build-dir)/%.o: \
        $(.dir)/$(.extn-pattern) \
        $(compiler-definition-file) \
        $(this-dir)/lib/generate-commands.mk \
        GNUmakefile \
        | \
        $(abspath $(.this-build-dir)) ; \
           $$(call announce,comp,$$<) \
           $$(call compile-$(plat)-$(.lang)-$(type),$$<,$$@)) \
      $(call make-directory-rules,$(.this-build-dir)) \
     ) \
   ) \
 )

# Generate a list of all object files.
objs := $(subst $(CURDIR)/src,$(build-dir),$(srcs))
$(foreach .lang,$(supported-languages), \
  $(foreach .extn-pattern,$($(.lang)-source-suffix-patterns), \
    $(eval objs := $(patsubst $(.extn-pattern),%.o,$(objs))) \
   ) \
 )
objs-without-main := $(filter-out %main.o,$(objs))

# The link rule for the main target.
# Note: eval used so definition of rules consistently uses
# $$.  Use C++ linker since the language settings affect
# only compilation.
$(eval $(real-target): $(objs) $(dependency-library-abspaths); \
  $$(call announce,link,$(real-target)) \
  $$(call link-$(plat)-$(type),$(sort $(objs)),$$@) \
 )

endif # ifneq (,$(strip $(target))) # 2

ifneq (,$(strip $(tests)))

# Generate custom compile pattern rules.
$(foreach .dir,$(unique-test-dirs), \
  $(eval .test-dir-off-curdir := $(subst $(CURDIR)/test,,$(.dir))) \
  $(eval .this-build-dir := $(build-dir)/test/$(.test-dir-off-curdir)) \
  $(foreach .lang,$(supported-languages), \
    $(foreach .extn-pattern,$($(.lang)-source-suffix-patterns), \
      $(eval \
        $(.this-build-dir)%.o: \
        $(.dir)/$(.extn-pattern) \
        $(compiler-definition-file) \
        $(this-dir)/lib/generate-commands.mk \
        GNUmakefile \
        | \
        $(abspath $(.this-build-dir)) ; \
           $$(call announce,comp,$$<) \
           $$(filter-out -W%,$$(call compile-$(plat)-$(.lang)-prog,$$<,$$@))) \
      $(call make-directory-rules,$(abspath $(.this-build-dir))) \
     ) \
   ) \
 )

.PHONY: test
test: 
test-progs :=
test-objs :=
$(foreach .test,$(tests), \
  $(eval .test-obj := $(subst $(CURDIR),$(build-dir),$(.test))) \
  $(foreach .lang,$(supported-languages), \
    $(foreach .extn-pattern,$($(.lang)-source-suffix-patterns), \
      $(eval .test-obj := $(patsubst $(.extn-pattern),%.o,$(.test-obj))) \
     ) \
   ) \
  $(eval test-objs += $(.test-obj)) \
  $(eval .test-prog := $(.test-obj:.o=)) \
  $(eval test-progs += $(.test-prog)) \
  $(eval .test-name := $(notdir $(.test-prog))) \
  $(eval $(.test-name): $(.test-prog); \
    $(call announce-exec,$($(.test-name)-env) $(.test-prog) $($(.test-name)-args)) \
   ) \
  $(eval test: $(.test-name)) \
  $(eval $(.test-prog): $(.test-obj) $(installed-target); \
    $(call announce,link,$(.test-prog)) \
    $(call link-native-prog,$$< $(objs-without-main),$$@) \
    -lboost_unit_test_framework \
    $($(.test-name)-linker-postflags) \
    $(if \
      $(call and, \
        $(call eq,$(plat),native), \
        $(filter %lib,$(type)) \
       ), \
    -L$(build-dir) \
    -l$(strip \
        $(patsubst \
          lib%, \
          %, \
          $(patsubst \
            %$($(plat)-$(type)-suffix), \
            %, \
            $(target-fullname) \
           ) \
         ) \
       ) \
     ) \
   ) \
 )

$(all-goals): test

endif # ifneq (,$(strip $(tests)))

# Install rule for header files.
$(foreach .dir,$(unique-include-dirs), \
  $(eval .include-dir-off-curdir := $(subst $(CURDIR)/include,,$(.dir))) \
  $(eval .this-install-dir := \
    $(abspath $(include-install-location)/$(.include-dir-off-curdir))) \
  $(foreach .lang,$(supported-languages), \
    $(foreach .extn-pattern,$($(.lang)-include-suffix-patterns), \
      $(if $(strip $($(.this-install-dir)/$(.extn-pattern)-rule-defined)), \
        $(comment nothing to do, rule is already defined), \
        $(eval $(.this-install-dir)/$(.extn-pattern)-rule-defined := t) \
        $(eval $(.this-install-dir)/$(.extn-pattern): $(.dir)/$(.extn-pattern) \
               | $(include-install-location) $(abspath $(.this-install-dir)); \
               $$(call announce-install,$$<,$$@)) \
        $(call make-directory-rules,$(.this-install-dir)) \
       ) \
     ) \
   ) \
 )

# List of installed header files.
installed-includes := \
$(subst \
  $(CURDIR)/include, \
  $(include-install-location), \
  $(includes) \
 )

# Install the header files on all goals.
$(all-goals): $(installed-includes)

# Prepare the encapper package and make the installation
# directory before installing header files.
$(sort) $(installed-includes)): $(prep-encap) | $(include-install-location)

# Generate targets for installing man pages.
$(foreach manpage,$(wildcard $(CURDIR)/man/*), \
  $(eval m := $(subst .,$(space),$(notdir $(manpage)))) \
  $(eval section := $(lastword $(m))) \
  $(eval name := $(filter-out $(section),$(m))) \
  $(eval name := $(subst $(space),.,$(name))) \
  $(if $(filter-out $(section),$(m)), \
    $(call install-man-pages,$(CURDIR)/man/$(name).$(section),$(section)), \
    $(disable warning Not installing $(manpage) as a man page) \
   ) \
 )

# Header dependency files are stored next to the object
# files in the build directory.
header-dependencies := $(objs:.o=.d) $(test-objs:.o=.d)

# The clean target removes everything including the build
# directory itself for clean 'svn status'.

.PHONY: clean clena
clean: ; $(call announce-clean,\
  $(objs) \
  $(real-target) \
  $(my-clean-files) \
  $(header-dependencies) \
  $(test-progs) \
  $(test-objs) \
 ) \
 && $(recursive-delete) $(CURDIR)/build

clena: clean

# Include the header dependency files if they exist.  This
# implementation of automatic header dependency discovery is
# based on Tom Tromey's method outlined on Paul D. Smith's
# website, http://make.paulandlesley.org/autodep.html.
-include $(header-dependencies)

#$(this-dir)/lib/math.mk: $(this-dir)/generate-math.lua; $(call announce,copy) \
#  $(this-dir)/generate-math.lua > $@

num-dependencies := 1
$(foreach p,$(proprietary-projects), \
  $(eval v := $(word $(num-dependencies),$(proprietary-versions))) \
  $(eval args := $($(p)-$(v))) \
  $(eval num-dependencies := $(call ++,$(num-dependencies))) \
  $(eval pdir := $(svn-home)/$(p)/$(v)) \
  $(if $(call not,$($(p))), \
    $(eval .PHONY: $(p)) \
    $(eval $(p):; $(call announce-make,$(pdir),$(args))) \
    $(eval $(p)-build-dir := $(pdir)/build/*) \
    $(eval $(p) := $($(p)-build-dir)/$(p)) \
    $(if $(call not,$(wildcard $($(p))*)), \
      $(disabled eval $(build-dir): $(p)) \
      $(comment if you do make -j10 in some project, it will \
        recurse into sibling directories for its proprietary \
        dependencies.  If two sibling proprietary dependencies \
        depend on the same file, they will both try to build the \
        common subdependency causing a race condition where two \
        builds are happening in the same directory. \
        This can only end badly. Permanently disabled but left in \
        place to warn those who would venture here. \
       ) \
     ) \
   ) \
 )
num-dependencies := $(call --,$(num-dependencies))

$(if $(call neq,$(CURDIR),$(this-dir)), \
  $(eval $(encapper):; @+$(MAKE) -C $(this-dir) --no-print-directory)\
 )

.PHONY: build-order
build-order: $(svn-home)/build-order/$(project-name)-deps.mk

$(svn-home)/build-order/$(project-name)-deps.mk \
  : $(MAKEFILE_LIST) \
  | $(svn-home)/build-order \
  ; $(call announce,copy) \
  rm -f $@; \
  touch $@; \
  $(foreach dep,$(proprietary-projects), \
    echo $(project-name): $(dep) >> $@; \
   ) \
  $(if $(call neq,$(project-name),gmake-recipes), \
    echo $(project-name): gmake-recipes >> $@; \
   )

$(svn-home)/build-order:; $(mkdir) $@

# ensures that removed sources cause a relink
$(real-target): $(build-dir)/srcs.txt

$(build-dir)/srcs.txt: $(build-dir)/srcs.txt.new ;$(call announce,copy) \
  $(call rename-if-changed,$<,$@)

.PHONY: $(build-dir)/srcs.txt.new
$(build-dir)/srcs.txt.new: | $(build-dir);$(call announce,copy) \
  echo $(srcs) > $@

# rebuild if anything in one of the included makefiles or the main makefile
# changes
$(objs): $(filter-out %.d,$(MAKEFILE_LIST))
