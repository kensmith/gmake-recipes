gnu-arm-c-compiler := arm-elf-gcc -std=gnu99 -c
gnu-arm-c-compiler-just-preprocess := arm-elf-gcc -std=gnu99 -E
gnu-arm-c-compiler-just-compile := arm-elf-gcc -std=gnu99 -S
gnu-arm-c-compiler-debugging-flag := -g
gnu-arm-c-compiler-depend := arm-elf-gcc -std=gnu99 -c -MM
gnu-arm-c-compiler-depend-post-process = $(native-c-compiler-depend-post-process)
gnu-arm-c-compiler-dylib-macros :=
gnu-arm-c-compiler-dylib-postflags :=
gnu-arm-c-compiler-dylib-preflags := -Wall -Werror
gnu-arm-c-compiler-dylib-preflags += -fPIC
gnu-arm-c-compiler-dylib-preflags += -Wextra
gnu-arm-c-compiler-dylib-preflags += -Wno-strict-aliasing
gnu-arm-c-compiler-dylib-preflags += -fomit-frame-pointer
gnu-arm-c-compiler-dylib-preflags += -mthumb-interwork
gnu-arm-c-compiler-dylib-preflags += -mcpu=arm7tdmi
gnu-arm-c-compiler-include-flag := -I
gnu-arm-c-compiler-lua-c-module-macros :=
gnu-arm-c-compiler-lua-c-module-postflags :=
gnu-arm-c-compiler-lua-c-module-preflags := $(gnu-arm-c-compiler-dylib-preflags)
gnu-arm-c-compiler-macro-flag := -D
gnu-arm-c-compiler-optimization-flag := -Os
gnu-arm-c-compiler-output-flag := -o
gnu-arm-c-compiler-prog-macros :=
gnu-arm-c-compiler-prog-postflags :=
gnu-arm-c-compiler-prog-preflags := $(filter-out -fPIC,$(gnu-arm-c-compiler-dylib-preflags))
gnu-arm-c-compiler-staticlib-macros :=
gnu-arm-c-compiler-staticlib-postflags :=
gnu-arm-c-compiler-staticlib-preflags := $(filter-out -fPIC,$(gnu-arm-c-compiler-dylib-preflags))

gnu-arm-c++-compiler := arm-elf-g++ -std=gnu++0x -fno-exceptions -fno-rtti -c
gnu-arm-c++-compiler-just-preprocess := arm-elf-g++ -std=gnu++0x -E
gnu-arm-c++-compiler-just-compile := arm-elf-g++ -std=gnu++0x -S
gnu-arm-c++-compiler-depend := arm-elf-g++ -std=gnu++0x -c -MM
gnu-arm-c++-compiler-depend-post-process = $(native-c-compiler-depend-post-process)
$(call derive,gnu-arm-c++,gnu-arm-c)
gnu-arm-c++-compiler-dylib-preflags += -fno-exceptions -fno-rtti 
gnu-arm-c++-compiler-lua-c-module-preflags += -fno-exceptions -fno-rtti 
gnu-arm-c++-compiler-prog-preflags += -fno-exceptions -fno-rtti 
gnu-arm-c++-compiler-staticlib-preflags += -fno-exceptions -fno-rtti 

gnu-arm-dylib-library-flag := -l
gnu-arm-dylib-library-path-flag := -L
gnu-arm-dylib-linker := arm-elf-g++ -std=gnu++0x
gnu-arm-dylib-linker-postflags := 
gnu-arm-dylib-linker-preflags := -shared -fPIC
gnu-arm-dylib-linker-output-flag := -o
gnu-arm-dylib-run-path-flag := -Wl,-rpath=
gnu-arm-dylib-suffix := .so

gnu-arm-staticlib-linker := arm-elf-ar
gnu-arm-staticlib-postlink := arm-elf-ranlib
gnu-arm-staticlib-linker-preflags := ruc
gnu-arm-staticlib-suffix := .a

gnu-arm-prog-library-flag := -l
gnu-arm-prog-library-path-flag := -L
gnu-arm-prog-linker := arm-elf-g++ -std=gnu++0x
gnu-arm-prog-linker-postflags := 
gnu-arm-prog-linker-preflags := -nostartfiles
gnu-arm-prog-linker-preflags += -Wl,-M
gnu-arm-prog-linker-preflags += -Wl,-Map -Wl,$(build-dir)/map.txt
gnu-arm-prog-linker-preflags += -mthumb-interwork
gnu-arm-prog-linker-preflags += -mcpu=arm7tdmi
gnu-arm-prog-linker-output-flag := -o
gnu-arm-prog-run-path-flag := -Wl,-rpath=
gnu-arm-prog-suffix := 

gnu-arm-lua-c-module-library-flag := -l
gnu-arm-lua-c-module-library-path-flag := -L
gnu-arm-lua-c-module-linker := arm-elf-g++ -std=gnu++0x
gnu-arm-lua-c-module-linker-postflags := 
gnu-arm-lua-c-module-linker-preflags := -fPIC -shared
gnu-arm-lua-c-module-linker-output-flag := -o
gnu-arm-lua-c-module-suffix := .so
gnu-arm-lua-c-module-run-path-flag := -Wl,-rpath=

include $(this-dir)/compilers/gnu-arm-thumb.mk
