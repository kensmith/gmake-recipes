# Copyright 2006-2009 Ken Smith <kgsmith@gmail>

dependency-include-paths :=
dependency-library-paths :=
dependency-library-abspaths :=
dependency-run-paths :=
dependency-libraries :=
system-include-paths := /usr/local/include
system-library-paths := /usr/local/lib

proprietary-projects :=
proprietary-versions :=

# Eg.
#
# $(call dependencies,liba libb libc)
#
# is equivalent to
#
# $(call dependency,liba)
# $(call dependency,libb)
# $(call dependency,libc)
dependencies = \
$(strip \
  $(foreach .tmpdep,$(1), \
    $(call dependency,$(.tmpdep)) \
   ) \
 )

# Add a library dependency to your target.  Use this instead
# of automatically adding library paths (-L) runpaths (-R)
# and libraries (-l) to your build manually.
# Eg.
#
# $(call dependency,libcalxs) # proprietary
# $(call dependency,libm) # system
# $(call dependency,lua,5.1.3) # proprietary with version
# $(call dependency,boost,1.34.1,n/a) # Add headers only, no -l
# $(call dependency,libanylib,,n/a) # Add headers only from default version
dependency = \
$(strip \
  $(eval .lib := $(strip $(1))) \
  $(eval .version := $(strip $(2))) \
  $(eval .explicit-libs := $(strip $(3))) \
  $(if $(call not,$(.version)), \
    $(eval .version := $(release-name)) \
   ) \
  $(eval .dependency-install-prefix := \
    $(install-root)/$(whoami)-$(top-level-name)-$(top-level-tag)-$(.lib)-$(.version)) \
  $(if $(wildcard $(svn-home)/$(.lib)), \
    $(if $(strip $(verbose)), \
      $(info $(.lib) is proprietary) \
     ) \
    $(eval .abs-lib := \
      $(wildcard $(.dependency-install-prefix)/lib/$(.lib)*)) \
    $(if $(strip $(.abs-lib)), \
      $(if \
        $(call not, \
          $(filter \
            $(.abs-lib), \
            $(dependency-library-abspaths) \
           ) \
         ), \
        $(eval \
          dependency-library-abspaths += $(.abs-lib)) \
       ) \
     ) \
    $(eval $(.lib)-version := $(.version)) \
    $(eval proprietary-projects += $(.lib)) \
    $(eval proprietary-versions += $(.version)) \
    $(if $(strip $(4)), \
      $(eval $(.lib)-$(.version) := $(4)) \
     ) \
    $(if \
      $(call not, \
        $(filter \
          $(.dependency-install-prefix)/include, \
          $(dependency-include-paths) \
         ), \
       ), \
      $(eval dependency-include-paths += \
        $(.dependency-install-prefix)/include \
       ) \
     ) \
    $(if \
      $(call not, \
        $(filter \
          $(.dependency-install-prefix)/lib, \
          $(dependency-library-paths) \
         ), \
       ), \
      $(eval dependency-library-paths += \
        $(.dependency-install-prefix)/lib \
       ) \
     ) \
    $(if \
      $(call not, \
        $(filter \
          $(.dependency-install-prefix)/lib, \
          $(dependency-run-paths) \
         ), \
       ), \
      $(eval dependency-run-paths += \
        $(.dependency-install-prefix)/lib \
       ) \
     ) \
    $(if $(.explicit-libs), \
      $(if $(call neq,$(.explicit-libs),n/a), \
        $(eval dependency-libraries += $(.explicit-libs)) \
       ) \
      , \
      $(eval dependency-libraries += $(.lib)) \
     ) \
    , \
    $(if $(strip $(verbose)), \
      $(info $(.lib) is system) \
     ) \
    $(if \
      $(call not, \
        $(filter \
          $(word 1,$(system-library-paths)), \
          $(dependency-library-paths) \
         ) \
       ) \
      , \
      $(eval dependency-library-paths += $(system-library-paths)) \
     ) \
    $(if \
      $(call not, \
        $(filter \
          $(word 1,$(system-include-paths)), \
          $(dependency-include-paths) \
         ) \
       ) \
      , \
      $(eval dependency-include-paths += $(system-include-paths)) \
     ) \
    $(if $(.explicit-libs), \
      $(if $(call neq,$(.explicit-libs),n/a), \
        $(eval dependency-libraries += $(.explicit-libs)) \
       ) \
      , \
      $(if \
        $(call not, \
          $(filter \
            $(.lib), \
            $(dependency-libraries) \
             ), \
         ), \
        $(eval dependency-libraries += $(.lib)) \
       ) \
     ) \
   ) \
  $(eval dependency-include-paths := \
    $(strip $(dependency-include-paths)) \
   ) \
  $(eval dependency-library-paths := \
    $(strip $(dependency-library-paths)) \
   ) \
  $(eval dependency-run-paths := $(strip $(dependency-run-paths))) \
  $(eval dependency-libraries := $(strip $(dependency-libraries))) \
  $(if $(strip $(verbose)), \
    $(call show-vars, \
      dependency-include-paths \
      dependency-library-paths \
      dependency-run-paths \
      dependency-libraries \
     ) \
   ) \
 )
