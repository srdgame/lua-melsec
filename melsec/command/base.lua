local class = require 'middleclass'
local basexx = require 'basexx'

local base = class('LUA_MELSEC_FRAME_BASE')

function base:initialize(ascii, cmd, sub_cmd)
	self._ascii = ascii
	self._cmd = cmd
	self._sub_cmd = sub_cmd
end

function base:ascii()
	return self._ascii
end

function base:pack(fmt, ...)
	local be = self._ascii and '>' or '<'
	local data = string.pack(be..fmt, ...)
	if self._ascii then
		data = basexx.to_hex(data)	
	end
	return data
end

function base:unpack(fmt, raw, index)
	local be = self._ascii and '>' or '<'
	if self._ascii then
		local new_raw = basexx.from_hex(string.sub(raw, index or 1))
		local rets = {string.unpack(be..fmt, new_raw)}
		if not rets[1] then
			return nil, rets[2]
		end
		assert(#rets > 1, 'Incorrect returns')
		rets[#rets] = rets[#rets] * 2

		return table.unpack(rets)
	else
		return string.unpack(be..fmt, raw, index)
	end
end

function base:cmd()
	return self._cmd
end

function base:sub_cmd()
	return self._sub_cmd
end

function base:to_hex()
	local data = self:pack('I2I2', self._cmd, self._sub_cmd)
	if self.encode then
		data = data..self:encode()
	end
	return data
end

function base:from_hex(raw, index)
	local raw = raw
	self._cmd, self._sub_cmd, index = self:unpack('I2I2', raw, index)

	if self.decode then
		index = self:decode(raw, index)
	end

	return index
end

function base:__tostring()
	return string.format("COMAMND:\t%02X\t%02X", self._cmd, self._sub_cmd)
end

return base
