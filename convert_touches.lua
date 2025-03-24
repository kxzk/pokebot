#!/usr/bin/env lua

-- hex2dec:
--   Converts a hexadecimal string (e.g. "000002c2") to its decimal representation.
local function hex2dec(hex_str)
	local num = tonumber(hex_str, 16)
	-- If conversion fails for any reason, just return the original string.
	if not num then
		return hex_str
	end
	return tostring(num)
end

-- Process each line from stdin.
for line in io.lines() do
	-- Only convert lines that mention ABS_MT_POSITION_X or ABS_MT_POSITION_Y.
	if line:find("ABS_MT_POSITION_X") or line:find("ABS_MT_POSITION_Y") then
		-- gsub each purely-hex substring ([0-9A-Fa-f]+) to its decimal form.
		line = line:gsub("([0-9A-Fa-f]+)", function(h)
			return hex2dec(h)
		end)
	end
	print(line)
end
