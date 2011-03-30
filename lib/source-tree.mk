# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Definitive list of supported, compilable languages.  Any
# number of non-compiled languages (eg. Python, Lua, etc.)
# are supported by install-scripts from file-manip.mk.
supported-languages := c c++

# Recognized suffixes for C++ source files.
c++-source-suffixes := .cpp .C .cxx
c++-source-suffix-patterns := $(addprefix %,$(c++-source-suffixes))

# Recognized suffixes for C++ header files.
c++-include-suffixes := .h .hpp .inc .ipp $(c++-source-suffixes)
c++-include-suffix-patterns := $(addprefix %,$(c++-include-suffixes))

# Recognized suffixes for C source files.
c-source-suffixes := .c .s
c-source-suffix-patterns := $(addprefix %,$(c-source-suffixes))

# Recognized suffixes for C header files.
c-include-suffixes := .h $(c-source-suffixes)
c-include-suffix-patterns := $(addprefix %,$(c-include-suffixes))

# Find all the files in a directory tree which match a
# set of extensions.
#
# $(1)=subdir of $(CURDIR) to begin search
# $(2)=extension patterns
# $(3)=private recursive state variable (don't set)
#
# Eg.
#
# $(call find-files-matching-extension,src,%.cpp %.C %.cxx)
#
# Eg.
#
# $(call find-files-matching-extension,include,%.h)
find-files-matching-extension = \
$(strip \
  $(if $(call not,$(3)), \
    $(eval .thisdir := $(CURDIR)/$(1)) \
    , \
    $(eval .thisdir := $(1)) \
   ) \
  $(eval .thesefiles := $(wildcard $(.thisdir)/*)) \
  $(foreach .thisfile,$(.thesefiles), \
    $(eval .subdir := $(wildcard $(.thisfile)/*)) \
    $(if $(.subdir), \
      $(call find-files-matching-extension,$(.thisfile),$(2),t) \
      , \
      $(filter $(2),$(.thisfile)) \
     ) \
   ) \
 )
