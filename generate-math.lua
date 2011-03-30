#!/usr/bin/env lua

-- Copyright 2006-2009 Ken Smith <kgsmith@gmail>

io.write(
   '# Automatically generated from ',
   arg[0] or 'generate-math.lua',
   '\n\n',
   'decr-list := \\',
   '\n'
)

for i=0,65535 do
   io.write('   ',tostring(i),' ')
   if (i+1) / 8 == math.floor((i+1) / 8) then
      if i ~= 65535 then
         io.write('\\')
      end
      io.write('\n')
   end
end

io.write(
   '\n',
   '-- = $(word $(1),$(decr-list))\n\n'
)

io.write('incr-list := \\\n')

for i=2,65536 do
   io.write('   ',tostring(i),' ')
   if (i-1) / 8 == math.floor((i-1) / 8) then
      if i ~= 65536 then
         io.write('\\')
      end
      io.write('\n')
   end
end

io.write(
   '\n\n',
   '++ = $(word $(1),$(incr-list))\n'
)

io.write(
   '\n\n',
   'bc = $(shell echo "$(1)" | bc)\n'
)
