include main.mk

$(call assert,$(call not,$(call has,123,123456 789012)))
$(call assert,$(call has,123,123 456 789))
$(call assert,$(call not,$(call has,arm,gnu-arm gnu-arm-thumb)))

.PHONY: test
test:
