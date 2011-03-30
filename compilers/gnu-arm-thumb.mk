gnu-arm-thumb-c-compiler := arm-elf-gcc -std=gnu99 -c -mthumb
gnu-arm-thumb-c-compiler-just-preprocess := arm-elf-gcc -std=gnu99 -E
gnu-arm-thumb-c-compiler-just-compile := arm-elf-gcc -std=gnu99 -S
gnu-arm-thumb-c-compiler-debugging-flag := -g
gnu-arm-thumb-c-compiler-depend := arm-elf-gcc -std=gnu99 -c -MM
gnu-arm-thumb-c-compiler-depend-post-process = $(native-c-compiler-depend-post-process)
gnu-arm-thumb-c-compiler-dylib-macros :=
gnu-arm-thumb-c-compiler-dylib-postflags :=
gnu-arm-thumb-c-compiler-dylib-preflags := $(gnu-arm-c-compiler-dylib-preflags)
gnu-arm-thumb-c-compiler-include-flag := -I
gnu-arm-thumb-c-compiler-lua-c-module-macros :=
gnu-arm-thumb-c-compiler-lua-c-module-postflags :=
gnu-arm-thumb-c-compiler-lua-c-module-preflags := $(gnu-arm-thumb-c-compiler-dylib-preflags)
gnu-arm-thumb-c-compiler-macro-flag := -D
gnu-arm-thumb-c-compiler-optimization-flag := -Os
gnu-arm-thumb-c-compiler-output-flag := -o
gnu-arm-thumb-c-compiler-prog-macros :=
gnu-arm-thumb-c-compiler-prog-postflags :=
gnu-arm-thumb-c-compiler-prog-preflags := $(filter-out -fPIC,$(gnu-arm-thumb-c-compiler-dylib-preflags))
gnu-arm-thumb-c-compiler-staticlib-macros :=
gnu-arm-thumb-c-compiler-staticlib-postflags :=
gnu-arm-thumb-c-compiler-staticlib-preflags := $(filter-out -fPIC,$(gnu-arm-c-compiler-dylib-preflags))

gnu-arm-thumb-c++-compiler := arm-elf-g++ -c -mthumb
gnu-arm-thumb-c++-compiler-just-preprocess := arm-elf-g++ -E
gnu-arm-thumb-c++-compiler-just-compile := arm-elf-g++ -S
gnu-arm-thumb-c++-compiler-depend := arm-elf-g++ -c -MM
gnu-arm-thumb-c++-compiler-depend-post-process = $(native-c-compiler-depend-post-process)
$(call derive,gnu-arm-thumb-c++,gnu-arm-thumb-c)
gnu-arm-thumb-c++-compiler-dylib-preflags += -fno-exceptions -fno-rtti 
gnu-arm-thumb-c++-compiler-lua-c-module-preflags += -fno-exceptions -fno-rtti 
gnu-arm-thumb-c++-compiler-prog-preflags += -fno-exceptions -fno-rtti 
gnu-arm-thumb-c++-compiler-staticlib-preflags += -fno-exceptions -fno-rtti 

gnu-arm-thumb-dylib-library-flag := -l
gnu-arm-thumb-dylib-library-path-flag := -L
gnu-arm-thumb-dylib-linker := arm-elf-g++
gnu-arm-thumb-dylib-linker-postflags := 
gnu-arm-thumb-dylib-linker-preflags := -shared -fPIC
gnu-arm-thumb-dylib-linker-output-flag := -o
gnu-arm-thumb-dylib-run-path-flag := -Wl,-rpath=
gnu-arm-thumb-dylib-suffix := .so

gnu-arm-thumb-staticlib-linker := arm-elf-ar
gnu-arm-thumb-staticlib-postlink := arm-elf-ranlib
gnu-arm-thumb-staticlib-linker-preflags := ruc
gnu-arm-thumb-staticlib-suffix := .a

gnu-arm-thumb-prog-library-flag := -l
gnu-arm-thumb-prog-library-path-flag := -L
gnu-arm-thumb-prog-linker := arm-elf-g++
gnu-arm-thumb-prog-linker-postflags := 
gnu-arm-thumb-prog-linker-preflags := $(gnu-arm-prog-linker-preflags)
gnu-arm-thumb-prog-linker-output-flag := -o
gnu-arm-thumb-prog-run-path-flag := -Wl,-rpath=
gnu-arm-thumb-prog-suffix :=

gnu-arm-thumb-lua-c-module-library-flag := -l
gnu-arm-thumb-lua-c-module-library-path-flag := -L
gnu-arm-thumb-lua-c-module-linker := arm-elf-g++
gnu-arm-thumb-lua-c-module-linker-postflags := 
gnu-arm-thumb-lua-c-module-linker-preflags := -fPIC -shared
gnu-arm-thumb-lua-c-module-linker-output-flag := -o
gnu-arm-thumb-lua-c-module-suffix := .so
gnu-arm-thumb-lua-c-module-run-path-flag := -Wl,-rpath=
