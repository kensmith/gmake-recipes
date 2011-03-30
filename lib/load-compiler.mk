# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Compute the name of and load the toolchain (compiler)
# specific configuration file then verify it completely
# specifies a compiler.

compiler-specification := $(osname)-$(compiler)
compiler-definition-file := \
   $(this-dir)/compilers/$(compiler-specification).mk

compiler-required-variables := \
   sudo \
   delete \
   recursive-delete \
   install \
   mkdir \
   chmod \
   include-install-location \
   man-install-location \
   dylib-install-location \
   staticlib-install-location \
   prog-install-location \
   lua-c-module-install-location \
   lua-module-install-location \
   luadoc-install-location \
   config-install-location \
   $(foreach .plat,$(supported-platforms), \
     $(addprefix $(.plat)-, \
       c-compiler \
       c-compiler-just-preprocess \
       c-compiler-just-compile \
       c-compiler-debugging-flag \
       c-compiler-depend \
       c-compiler-depend-post-process \
       c-compiler-dylib-macros \
       c-compiler-dylib-macros \
       c-compiler-dylib-macros \
       c-compiler-dylib-postflags \
       c-compiler-dylib-preflags \
       c-compiler-include-flag \
       c-compiler-lua-c-module-macros \
       c-compiler-lua-c-module-postflags \
       c-compiler-lua-c-module-preflags \
       c-compiler-macro-flag \
       c-compiler-optimization-flag \
       c-compiler-output-flag \
       c-compiler-prog-macros \
       c-compiler-prog-macros \
       c-compiler-prog-macros \
       c-compiler-prog-postflags \
       c-compiler-prog-preflags \
       c-compiler-staticlib-macros \
       c-compiler-staticlib-macros \
       c-compiler-staticlib-macros \
       c-compiler-staticlib-postflags \
       c-compiler-staticlib-preflags \
       c++-compiler \
       c++-compiler-depend \
       c++-compiler-depend-post-process \
       dylib-library-flag \
       dylib-library-path-flag \
       dylib-linker \
       dylib-linker-postflags \
       dylib-linker-preflags \
       dylib-linker-output-flag \
       dylib-run-path-flag \
       dylib-suffix \
       staticlib-linker \
       staticlib-postlink \
       staticlib-linker-preflags \
       staticlib-suffix \
       prog-library-flag \
       prog-library-path-flag \
       prog-linker \
       prog-linker-postflags \
       prog-linker-preflags \
       prog-linker-output-flag \
       prog-run-path-flag \
       prog-suffix \
       lua-c-module-library-flag \
       lua-c-module-library-path-flag \
       lua-c-module-linker \
       lua-c-module-linker-postflags \
       lua-c-module-linker-preflags \
       lua-c-module-linker-output-flag \
       lua-c-module-suffix \
       lua-c-module-run-path-flag \
      ) \
    )

$(foreach .compiler-var,$(compiler-required-variables), \
  $(eval $(.compiler-var) := load-compiler-undefined) \
 )

-include $(compiler-definition-file)

$(foreach .compiler-var,$(compiler-required-variables), \
  $(call assert, \
    $(call neq,$($(.compiler-var)),load-compiler-undefined), \
    $(compiler-definition-file) does not define "$(.compiler-var)". \
    Read through the other compiler definition files to see \
    what kind of value this variable should have.  Set every value \
    even if you end up setting many variables to empty string \
   ) \
 )
