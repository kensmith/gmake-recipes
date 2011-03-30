# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Assemble the toolchain characterization (from
# ../compilers) into compile and link lines for a given
# language and target type.

# Generate a compile command.
#
# $(1) one of $(supported-languages)
# $(2) one of $(supported-types)
# $(3) one of $(supported-platforms)
compile-command = \
$(strip \
  $(call assert,$(call has,$(1),$(supported-languages)), \
    compile-command: $$(1) must be one of "$(supported-languages)" \
    is "$(1)" \
   ) \
  $(call assert,$(call has,$(2),$(supported-types)), \
    compile-command: $$(2) must be one of "$(supported-types)" \
    is "$(2)" \
   ) \
  $(call assert,$(call has,$(3),$(supported-platforms)), \
    compile-command: $$(3) must be one of "$(supported-platforms)" \
   ) \
  $$(eval infile := $$(subst $(CURDIR)/src/,,$$(1))) \
  $(if $($(3)-$(1)-compiler-depend), \
    $($(3)-$(1)-compiler-depend) \
    $$($$(infile)-preflags) \
    $(preflags) \
    $($(3)-preflags) \
    $($(3)-$(1)-compiler-$(2)-preflags) \
    $$(addprefix \
       $($(3)-$(1)-compiler-macro-flag), \
       $$($$(infile)-macros) \
      ) \
    $(addprefix \
      $($(3)-$(1)-compiler-macro-flag), \
      $($(3)-$(1)-compiler-$(2)-macros) \
      $($(3)-macros) \
      $(macros) \
     ) \
    $$(addprefix \
       $($(3)-$(1)-compiler-include-flag), \
       $$($$(infile)-include-paths) \
      ) \
    $(addprefix \
      $($(3)-$(1)-compiler-include-flag), \
      $(include-paths) \
      $($(3)-include-paths) \
      $(CURDIR)/include $(dependency-include-paths) \
     ) \
    $$(1) \
    $($(3)-$(1)-compiler-$(2)-postflags) \
    $(postflags) \
    $($(3)-postflags) \
    $$($$(infile)-postflags) \
    2>/dev/null \
    $(if $($(3)-$(1)-compiler-depend-post-process), \
      $($(3)-$(1)-compiler-depend-post-process) \
     ) \
    && \
   ) \
  $(if $(and $(generate-preprocessed),$($(3)-$(1)-compiler-just-preprocess)),\
    $($(3)-$(1)-compiler-just-preprocess) \
    $$($$(infile)-preflags) \
    $(preflags) \
    $($(3)-preflags) \
    $($(3)-$(1)-compiler-$(2)-preflags) \
    $$(addprefix \
       $($(3)-$(1)-compiler-macro-flag), \
       $$($$(infile)-macros) \
      ) \
    $(addprefix \
      $($(3)-$(1)-compiler-macro-flag), \
      $($(3)-$(1)-compiler-$(2)-macros) \
      $($(3)-macros) \
      $(macros) \
     ) \
    $$(addprefix \
       $($(3)-$(1)-compiler-include-flag), \
       $$($$(infile)-include-paths) \
      ) \
    $(addprefix \
      $($(3)-$(1)-compiler-include-flag), \
      $(include-paths) \
      $($(3)-include-paths) \
      $(CURDIR)/include $(dependency-include-paths) \
     ) \
    $$(1) \
    $($(3)-$(1)-compiler-output-flag) \
    $$(2:.o=.i) \
    $($(3)-$(1)-compiler-$(2)-postflags) \
    $(postflags) \
    $($(3)-postflags) \
    $$($$(infile)-postflags) \
    && \
   ) \
  $(if $(and $(generate-assembly),$($(3)-$(1)-compiler-just-compile)),\
    $($(3)-$(1)-compiler-just-compile) \
    $(if $(call eq,$(.DEFAULT_GOAL),release), \
      $($(3)-$(1)-compiler-optimization-flag), \
      $($(3)-$(1)-compiler-debugging-flag) \
     ) \
    $(if $(call eq,$(.DEFAULT_GOAL),release-g), \
      $($(3)-$(1)-compiler-optimization-flag) \
      $($(3)-$(1)-compiler-debugging-flag) \
     ) \
    $$($$(infile)-preflags) \
    $(preflags) \
    $($(3)-preflags) \
    $($(3)-$(1)-compiler-$(2)-preflags) \
    $$(addprefix \
       $($(3)-$(1)-compiler-macro-flag), \
       $$($$(infile)-macros) \
      ) \
    $(addprefix \
      $($(3)-$(1)-compiler-macro-flag), \
      $($(3)-$(1)-compiler-$(2)-macros) \
      $($(3)-macros) \
      $(macros) \
     ) \
    $$(addprefix \
       $($(3)-$(1)-compiler-include-flag), \
       $$($$(infile)-include-paths) \
      ) \
    $(addprefix \
      $($(3)-$(1)-compiler-include-flag), \
      $(include-paths) \
      $($(3)-include-paths) \
      $(CURDIR)/include $(dependency-include-paths) \
     ) \
    $$(1) \
    $($(3)-$(1)-compiler-output-flag) \
    $$(2:.o=.s) \
    $($(3)-$(1)-compiler-$(2)-postflags) \
    $(postflags) \
    $($(3)-postflags) \
    $$($$(infile)-postflags) \
    && \
   ) \
  $$($$(infile)-precompile) \
  $(precompile) \
  $($(3)-precompile) \
  $($(3)-$(1)-compiler) \
  $(if $(call eq,$(.DEFAULT_GOAL),release), \
    $($(3)-$(1)-compiler-optimization-flag), \
    $($(3)-$(1)-compiler-debugging-flag) \
   ) \
  $(if $(call eq,$(.DEFAULT_GOAL),release-g), \
    $($(3)-$(1)-compiler-optimization-flag) \
    $($(3)-$(1)-compiler-debugging-flag) \
   ) \
  $$($$(infile)-preflags) \
  $(preflags) \
  $($(3)-preflags) \
  $($(3)-$(1)-compiler-$(2)-preflags) \
  $$(addprefix \
     $($(3)-$(1)-compiler-macro-flag), \
     $$($$(infile)-macros) \
    ) \
  $(addprefix \
    $($(3)-$(1)-compiler-macro-flag), \
    $($(3)-$(1)-compiler-$(2)-macros) \
    $($(3)-macros) \
    $(macros) \
   ) \
  $$(addprefix \
     $($(3)-$(1)-compiler-include-flag), \
     $$($$(infile)-include-paths) \
    ) \
  $(addprefix \
    $($(3)-$(1)-compiler-include-flag), \
    $(include-paths) \
    $($(3)-include-paths) \
    $(CURDIR)/include $(dependency-include-paths) \
   ) \
  $$(1) \
  $($(3)-$(1)-compiler-output-flag) \
  $$(2) \
  $($(3)-$(1)-compiler-$(2)-postflags) \
  $(postflags) \
  $($(3)-postflags) \
  $$($$(infile)-postflags) \
  $$(if $$(strip $$($$(infile)-postcompile)), \
     && $$($$(infile)-postcompile) \
    ) \
  $(if $(strip $(postcompile)), \
    && $(postcompile) \
   ) \
  $(if $(strip $($(3)-postcompile)), \
    && $($(3)-postcompile) \
   ) \
 )

$(foreach .plat,$(supported-platforms), \
  $(foreach .lang,$(supported-languages), \
    $(foreach .type,$(supported-types), \
      $(eval compile-$(.plat)-$(.lang)-$(.type) = \
        $(call compile-command,$(.lang),$(.type),$(.plat))) \
     ) \
   ) \
 )

# Generate a link command
#
# $(1) one of $(supported-types)
# $(2) one of $(supported-platforms)
link-command = \
$(strip \
  $(prelink) \
  $($(2)-prelink) \
  $($(2)-$(1)-linker) \
  $(linker-preflags) \
  $($(2)-linker-preflags) \
  $($(2)-$(1)-linker-preflags) \
  $(if $(strip $($(2)-$(1)-run-path-flag)), \
    $(addprefix \
      $($(2)-$(1)-run-path-flag), \
      $(dependency-run-paths) \
     ) \
   ) \
  $(if $(strip $($(2)-$(1)-library-path-flag)), \
    $(addprefix \
      $($(2)-$(1)-library-path-flag), \
      $(dependency-library-paths) \
     ) \
   ) \
  $($(2)-$(1)-linker-output-flag) \
  $$(2) \
  $$(1) \
  $($(2)-$(1)-linker-postflags) \
  $(if $(strip $($(2)-$(1)-library-flag)), \
    $(addprefix \
      $($(2)-$(1)-library-flag), \
      $(patsubst \
        lib%, \
        %, \
        $(patsubst \
          %$(dylib-suffix), \
          %, \
          $(dependency-libraries) \
         ) \
       ) \
     ) \
   ) \
  $(linker-postflags) \
  $($(2)-linker-postflags) \
  $(if $(strip $($(2)-$(1)-postlink)), \
    && $($(2)-$(1)-postlink) $$(2) \
   ) \
  $(if $(strip $(postlink)), \
    && $(postlink) \
   ) \
  $(if $(strip $(postlink)), \
    && $($(2)-postlink) \
   ) \
 )

$(foreach .plat,$(supported-platforms), \
  $(foreach .type,$(supported-types), \
    $(eval link-$(.plat)-$(.type) = \
      $(call link-command,$(.type),$(.plat))) \
   ) \
 )
