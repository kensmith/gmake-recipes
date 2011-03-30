# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Logical not.
# Eg.
#
# $(call not,$(val),do something)
not = $(if $(strip $(1)),,t)

# String comparison
# Eg.
#
# $(call eq,$(s1),$(s2),do something when s1 == s2)
eq = \
$(strip \
  $(if $(filter $(strip $(1)),$(strip $(2))), \
    $(if $(filter $(strip $(2)),$(strip $(1))), \
      t \
     ) \
   ) \
 )

# String comparison.
# Eg.
#
# $(call neq,$(s1),$(s2),do something when s1 != s2)
neq = $(call not,$(call eq,$(1),$(2)))
