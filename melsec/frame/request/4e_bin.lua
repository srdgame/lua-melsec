local base = require 'melsec.frame.base'

local frame = class('LUA_MELSEC_FRAME_4E_BIN', base)

function frame:initialize(sequence, network, index, io, station, timer, cmd, sub_cmd, data)
	self._sequence = sequence
	self._network = network
	self._index = index
	self._io = io
	self._station = station
	self._timer = timer
	self._cmd = cmd
	self._sub_cmd = sub_cmd
	self._data = data
end

function frame:to_hex()
	local hdr = string.pack('>I2', 0x5400)..string.pack('<I2', self._sequence)..string.pack('>I2', 0x0000)

	local data_p = string.pack('<I2I2I2', self._timer, self._cmd, self._sub_cmd)
	local data = data_p .. self._data:to_hex()
	local data_len = string.len(data)

	local qhdr = string.pack('<I1I1I2I1I2', self._network, self._index, self._io, self._station, data_len)


	return hdr..qhdr..data
end

function frame:from_hex(raw, index)
	local es, index = string.unpack('>I2', raw, index)
	assert(es == 0x5400)
	local seq, index = string.unpack('<I2', raw, index)
	local ed, index = string.unpack('>I2', raw, index)
	assert(ed == 0x0000)

	self._sequence = seq

	local data_len = 0
	self._network, self._index, self._io, self._station, data_len, index = string.unpack('<I1I1I2I1I2')

	local str_left = string.len(raw) - index + 1
	if data_len > str_left then
		return nil, data_len - str_left
	end

	self._timer, self._cmd, self._sub_cmd, index = string.unpack('<I2I2I2', raw, index)

	self._data, index = parser(raw, index)

	assert(index = data_len + 13, "Incorrect index returned!")

	return index
end

function frame:sequence()
	return self._sequence
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
