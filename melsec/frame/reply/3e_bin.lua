local base = require 'melsec.frame.base'

local frame = class('LUA_MELSEC_FRAME_4E_BIN', base)

function frame:initialize(network, index, io, station, status, data)
	base.initialize(self)
	self._network = network
	self._index = index
	self._io = io
	self._station = station
	self._status = status
	self._data = data
end

function frame:to_hex()
	local hdr = string.pack('>I2', 0xD000)

	local data_p = string.pack('<I2', self._status)
	local data = data_p .. self._data:to_hex()
	local data_len = string.len(data)

	local qhdr = string.pack('<I1I1I2I1I2', self._network, self._index, self._io, self._station)

	return hdr..qhdr..data
end

function frame:from_hex(raw, index)
	local es, index = string.unpack('>I2', raw, index)
	assert(es == 0xD000)

	local data_len = 0
	self._network, self._index, self._io, self._station, data_len, index = string.unpack('<I1I1I2I1I2', raw, index)

	local str_left = string.len(raw) - index + 1
	if data_len > str_left then
		return nil, data_len - str_left
	end

	self._status, index = string.unpack('<I2', raw, index)

	self._data, index = parser(raw, index)

	assert(index = data_len + 9, 'Incorrect index returned!')

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

function frame:status()
	return self._status
end

function frame:data()
	return self._data
end

function frame:__tostring()
end

return frame
