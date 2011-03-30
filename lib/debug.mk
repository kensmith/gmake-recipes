# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# I use this all the time when debugging changes to the make
# rules.  Display values for multiple variables like this
# Eg.
#
# $(call show-vars,compiler linker)
#
# This shows the contents of $(compiler) and $(linker) and
# the line numer of the call to show-vars.
show-vars = \
$(strip \
  $(foreach .tmp,$(1), \
    $(warning $(.tmp)="$($(.tmp))") \
   ) \
 )
