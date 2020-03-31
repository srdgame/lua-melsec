local base = require 'melsec.frame.base'

local frame = class('LUA_MELSEC_FRAME_4C_FORMAT_5_BIN', base)

function frame:initialize(network, index, io, station, cmd, sub_cmd, data)
	base.initialize(self)
	self._network = network
	self._index = index
	self._io = io
	self._station = station
	self._cmd = cmd
	self._sub_cmd = sub_cmd
	self._data = data
end

function frame:to_hex()
	local pre = string.pack('>I2', 0x1002)
	local pos = string.pack('>I2', 0x1003)

	local data_p = string.pack('<I2I2', self._cmd, self._sub_cmd)
	local data = data_p .. self._data:to_hex()
	local data_len = string.len(data) + 8

	--- 0x00 站号???
	local qhdr = string.pack('<I2I1I1I1I1I2I1I1', data_len, 0xF8, 0x00, self._network, self._index, self._io, self._station, 0x00)

	data = qhdr..data

	local sum = sum:check(data)

	return pre .. data .. pos .. string.pack('>I2', sum)
end

function frame:from_hex(raw, index)
	local pre, index = string.unpack('>I2', raw, index)
	assert(pre == 0x1002)

	local data_len = 0
	data_len, index = string.unpack('<I2', raw, index)

	local str_left = string.len(raw) - index + 1
	if data_len + 4 > str_left then
		return nil, data_len + 4 - str_left
	end
	
	local sum = string.unpack('>I2', string.sub(raw, index + data_len + 2))
	-- TODO: check sum

	local ver = 0
	local site = 0
	local this_site = 0
	ver, site, self._network, self._index, self._io, self._station, this_site, index = string.unpack('<I1I1I1I1I2I1I1')
	assert(ver == 0xF8)
	assert(site == 0x00)
	assert(this_site == 0x00)

	self._cmd, self._sub_cmd, index = string.unpack('<I2I2', raw, index)

	self._data, index = parser(raw, index)

	local pos, sum, index = string.unpack('>I2I2', raw, index)
	assert(pos == 0x1003)
	--assert(sum == ???)

	return index
end

function frame:network()
	return self._network
end

function frame:index()
	return self._index
end

function frame:io()
	return self._io
end

function frame:station()
	return self._station
end

function frame:tiemr()
	return self._timer
end

function frame:cmd()
	return self._cmd
end

function frame:sub_cmd()
	return self._sub_cmd
end

function frame:data()
	return self._data
end

return frame
