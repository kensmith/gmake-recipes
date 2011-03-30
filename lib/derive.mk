# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Shorthand for setting the compiler and linker variables
# for a toolchain characterization for one language based on
# another.  This was explicitly invented to base C++
# settings on C settings with the minimum of redundancy.
#
# $(1) derivative language name
# $(2) original language name
# given:
# c-var1 := x
# c-var2 := y
# c-var3 := z
# c++-var1 := a
# $(call derive,c++,c)
# results in:
# c-var1 := x
# c-var2 := y
# c-var3 := z
# c++-var1 := a
# c++-var2 := y
# c++-var3 := z
#
# Effectively allows a derivative language to be partially
# specified when it maintains much in common with another
# language's specification.
derive = \
$(strip \
  $(eval .parent := $(strip $(2))) \
  $(eval .derivative := $(strip $(1))) \
  \
  $(foreach .$(.parent)-var, \
    $(filter $(.parent)-compiler% $(.parent)-linker%,$(.VARIABLES)), \
    $(eval .$(.derivative)-var := \
      $(patsubst $(.parent)-%,$(.derivative)-%,$(.$(.parent)-var))) \
    $(if $(call not,$($(.$(.derivative)-var))), \
      $(eval $(.$(.derivative)-var) := $($(.$(.parent)-var))) \
     ) \
   ) \
 )
