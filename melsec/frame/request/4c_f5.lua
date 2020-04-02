local base = require 'melsec.frame.base'

local frame = class('LUA_MELSEC_FRAME_4C_FORMAT_5_BIN', base)

function frame:initialize(session, command)
	base.initialize(self)
	self._session = session
	self._command = command
end

function frame:to_hex()
	local pre = string.pack('>I2', 0x1002)
	local pos = string.pack('>I2', 0x1003)

	local data = self._command:to_hex()
	local data_len = string.len(data) + 8

	local network = self._session:network()
	local index = self._session:index()
	local io = self._session:io()
	local station = self._session:station()

	--- 0x00 站号???
	local qhdr = string.pack('<I2I1I1I1I1I2I1I1', data_len, 0xF8, 0x00, network, index, io, station, 0x00)

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

	local ver, site, network, sindex, io, station, this_site, index = string.unpack('<I1I1I1I1I2I1I1')
	assert(ver == 0xF8)
	assert(site == 0x00)
	assert(this_site == 0x00)

	local new_index = 1
	local new_raw = string.sub(raw, index, index + data_len - 8)

	local basexx = require 'basexx'
	print('FROM_HEX', basexx.to_hex(new_raw))

	self._command, index = parser(raw, index)
	self._session = session:new(network, sindex, io, station)

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

function frame:command()
	return self._command
end

return frame
