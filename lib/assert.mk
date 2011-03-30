# Copyright 2006-2009 Ken Smith <kgsmith@gmail>

# A custom assertion function.
assert = \
$(strip \
  $(if $(strip $(1)), \
    $(comment assertion holds), \
    $(error $(strip $(2))) \
   ) \
 )
