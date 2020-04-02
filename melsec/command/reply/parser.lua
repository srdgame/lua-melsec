local basexx = require 'basexx'

local types = require 'melsec.command.types'

local function load_package(cmd)
	for k,v in pairs(types.CMD) do
		if v == cmd then
			return require('melsec.command.reply.'..string.lower(k))
		end
	end
	assert(nil, "No package for CMD:"..cmd)
end

local function parser_command(ascii, raw, index)
	local cmd, sub_cmd
	if asccii then
		local new_raw = string.sub(raw, index or 1, 9)
		new_raw = basexx.from_hex(new_raw)
		cmd, sub_cmd = string.unpack('>I2I2', new_raw)

		local p = load_package(cmd)
		local obj = p:new(ascii)
		local index = obj:from_hex(raw, index)
		return obj, index
	else
		cmd, sub_cmd = string.unpack('<I2I2', raw, index)

		local p = load_package(cmd)
		local obj = p:new(ascii)
		local index = obj:from_hex(raw, index)
		return obj, index
	end
end
