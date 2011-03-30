include main.mk
include finalize.mk

input-range := 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
expected-values := 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
$(foreach n,$(input-range), \
  $(eval result := $(call --,$(word $(n),$(input-range)))) \
  $(info $(n)-- => $(result)) \
  $(call assert, \
    $(call eq, \
      $(result), \
      $(word $(n),$(expected-values)) \
     ) \
    , \
    failed to decrement $(n) \
   ) \
 )

expected-values := 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
$(foreach n,$(input-range), \
  $(eval result := $(call ++,$(word $(n),$(input-range)))) \
  $(info $(n)++ => $(result)) \
  $(call assert, \
    $(call eq, \
      $(result), \
      $(word $(n),$(expected-values)) \
     ) \
    , \
    failed to increment $(n) \
   ) \
 )

list1 := a b c d e
list2 := A B C D E
iter := 1
$(foreach x,$(list1), \
  $(eval y := $(word $(iter),$(list2))) \
  $(info $(x)-$(y) := $(iter)) \
  $(eval $(x)-$(y) := $(iter)) \
  $(eval iter := $(call ++,$(iter))) \
 )
