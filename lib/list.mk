# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Iterative list reversal implementation.  Much faster than
# the perhaps more intuitive recursive implementation.
# Eg.
#
# x := $(call reverse,1 2 3 4 5)
# x is now 5 4 3 2 1
reverse = \
$(strip \
  $(eval .retval :=) \
  $(foreach .elem,$(1), \
    $(eval .retval := $(.elem) $(.retval)) \
   ) \
  $(.retval) \
 )

# Returns true if the list $(2) has an exact match for $(1).
# $(1) can contain the wildcard, %.
has = \
$(strip \
  $(and \
    $(filter $(1),$(2)), \
    $(filter $(2),$(1)) \
   ) \
 )
