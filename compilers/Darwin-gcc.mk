# Copyright 2007-2009 Ken Smith <kgsmith@gmail>

sudo := sudo
delete := rm -f
recursive-delete := rm -Rf
move := mv -f
install := cp -fR
mkdir := mkdir -p
chmod := chmod

include-install-location := $(install-prefix)/include
man-install-location := $(install-prefix)/man
dylib-install-location := $(install-prefix)/lib
staticlib-install-location := $(install-prefix)/lib
prog-install-location := $(install-prefix)/bin
lua-c-module-install-location := $(install-prefix)/lib/lua/$(lua-version)
lua-module-install-location := $(install-prefix)/share/lua/$(lua-version)
luadoc-install-location := $(install-prefix)/share/luadoc/$(project-name)
config-install-location := $(install-prefix)/share/ca/config

native-c-compiler := gcc -std=gnu99 -c
native-c-compiler-just-preprocess := gcc -std=gnu99 -E
native-c-compiler-just-compile := gcc -std=gnu99 -S
native-c-compiler-debugging-flag := -g
native-c-compiler-depend := gcc -std=gnu99 -c -MM
native-c-compiler-depend-post-process = \
   | sed -e 's|$$(subst .,\.,$$(notdir $$(@)))|$$@|' \
   | tee $$(@:.o=.d) \
   | grep "\.h" \
   | sed \
      -e 's, *\\,,' \
      -e 's/^ *//' \
      -e 's/\.hpp/.hpp:/' \
      -e 's/\.h$$$$/.h:/' \
      -e 's, /,:=/,' \
   | tr '=' "\n" \
   > $$(@:.o=.headers-only) \
   ; \
   cat $$(@:.o=.d) $$(@:.o=.headers-only) \
   > $$(@:.o=.everything) \
   ; \
   mv $$(@:.o=.everything) $$(@:.o=.d) \
   ; \
   rm -f $$(@:.o=.headers-only)
native-c-compiler-dylib-macros :=
native-c-compiler-dylib-postflags :=
native-c-compiler-dylib-preflags := -Wall
native-c-compiler-dylib-preflags += -fexceptions
native-c-compiler-dylib-preflags += -fPIC
native-c-compiler-dylib-preflags += -Wextra
native-c-compiler-dylib-preflags += -Wno-strict-aliasing
native-c-compiler-include-flag := -I
native-c-compiler-lua-c-module-macros :=
native-c-compiler-lua-c-module-postflags :=
native-c-compiler-lua-c-module-preflags := -Wall -Werror -fexceptions -fPIC
native-c-compiler-macro-flag := -D
native-c-compiler-optimization-flag := -O2
native-c-compiler-output-flag := -o
native-c-compiler-prog-macros := _REENTRANT
native-c-compiler-prog-macros += PACKED
native-c-compiler-prog-macros += USE_CEARCH_PROTOCOL_OBJECTS
native-c-compiler-prog-postflags :=
native-c-compiler-prog-preflags := -Wall -Werror -fexceptions
native-c-compiler-staticlib-macros := _REENTRANT
native-c-compiler-staticlib-macros += PACKED
native-c-compiler-staticlib-macros += USE_CEARCH_PROTOCOL_OBJECTS
native-c-compiler-staticlib-postflags :=
native-c-compiler-staticlib-preflags := -Wall -Werror -fexceptions -fPIC


native-c++-compiler := g++ -c
native-c++-compiler-just-preprocess := g++ -E
native-c++-compiler-just-compile := g++ -S
native-c++-compiler-depend := g++ -c -MM
native-c++-compiler-depend-post-process = \
   | sed -e 's|$$(subst .,\.,$$(notdir $$(@)))|$$@|' \
   | tee $$(@:.o=.d) \
   | grep "\.h" \
   | sed \
      -e 's, *\\,,' \
      -e 's/^ *//' \
      -e 's/\.hpp/.hpp:/' \
      -e 's/\.h$$$$/.h:/' \
      -e 's, /,:=/,' \
   | tr '=' "\n" \
   > $$(@:.o=.headers-only) \
   ; \
   cat $$(@:.o=.d) $$(@:.o=.headers-only) \
   > $$(@:.o=.everything) \
   ; \
   mv $$(@:.o=.everything) $$(@:.o=.d) \
   ; \
   rm -f $$(@:.o=.headers-only)
$(call derive,native-c++,native-c)
native-c++-compiler-dylib-preflags := $(c++-compiler-dylib-preflags) \
   -Wabi \
   -Woverloaded-virtual
native-dylib-library-flag := -l
native-dylib-library-path-flag := -L
native-dylib-linker := g++
native-dylib-linker-postflags := 
native-dylib-linker-preflags := -dynamiclib -fPIC
native-dylib-linker-output-flag := -o
native-dylib-run-path-flag := -Wl,-rpath -Wl,
native-dylib-suffix := .dylib

native-staticlib-linker := ar
native-staticlib-postlink := ranlib
native-staticlib-linker-preflags := ruc
native-staticlib-suffix := .a

native-prog-library-flag := -l
native-prog-library-path-flag := -L
native-prog-linker := g++
native-prog-linker-postflags := 
native-prog-linker-preflags := -fPIC
native-prog-linker-output-flag := -o
native-prog-run-path-flag := -Wl,-rpath -Wl,
native-prog-suffix :=

native-lua-c-module-library-flag := -l
native-lua-c-module-library-path-flag := -L
native-lua-c-module-linker := g++
native-lua-c-module-linker-postflags := 
native-lua-c-module-linker-preflags := -fPIC -shared -bundle -undefined dynamic_lookup
native-lua-c-module-linker-output-flag := -o
native-lua-c-module-suffix := .so
native-lua-c-module-run-path-flag := -Wl,-rpath -Wl,

include $(this-dir)/compilers/gnu-arm.mk
