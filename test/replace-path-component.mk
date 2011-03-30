include main.mk
include finalize.mk

$(call assert \
  $(call eq, \
    $(call replace-path-component,1,/tmp dir/a/b/c/d,hello), \
    /hello/a/b/c/d \
   ) \
 )

$(call assert \
  $(call eq, \
    $(call replace-path-component,2,/tmp dir/a/b/c/d,hello), \
    /tmp dir/hello/b/c/d \
   ) \
 )

$(call assert \
  $(call eq, \
    $(call replace-path-component,2,/tmp dir/a/b/c/d/,hello), \
    /tmp dir/hello/b/c/d/ \
   ) \
 )

$(call assert \
  $(call eq, \
    $(call replace-path-component,1,tmp dir/a/b/c/d/,hello), \
    hello/a/b/c/d/ \
   ) \
 )

$(call assert \
  $(call eq, \
    $(call replace-path-component,1,tmp dir/a/b/c/d,hello), \
    hello/a/b/c/d \
   ) \
 )

$(info all tests passed)
