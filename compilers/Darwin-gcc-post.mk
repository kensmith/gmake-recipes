# Copyright 2006-2009 Ken Smith <kgsmith@gmail>
#
# Darwin doesn't use run paths for dependent modules.  It
# uses install names for dependency libraries.  Clear the
# run path variable and add the install location for dylibs
# to the runpath if we're building a dylib.

#$(if $(call eq,$(target-type),dylib), \
#  $(eval dependency-run-paths := $(installed-target)), \
#  $(eval dependency-run-paths :=) \
# )
