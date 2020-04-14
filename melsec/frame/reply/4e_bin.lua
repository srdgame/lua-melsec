local class = require 'middleclass'

local session = require 'melsec.session'
local base = require 'melsec.frame.base'

local frame = class('LUA_MELSEC_FRAME_4E_BIN', base)

function frame:initialize(session, status, data)
	base.initialize(self)
	self._session = session
	self._status = status
	self._data = data
end

function frame:to_hex()
	assert(self._session and self._status and self._data)

	local sequence = self._session:get_seq()
	local network = self._session:network()
	local index = self._session:index()
	local io = self._session:io()
	local station = self._session:station()

	local es = string.pack('>I2', 0xD400)
	local seq = string.pack('<I2', sequence)
	local ed = string.pack('>I2', 0x0000)
	local hdr = es..seq..ed

	local data_p = string.pack('<I2', self._status)
	local data = data_p .. self._data:to_hex()
	local data_len = string.len(data)

	local qhdr = string.pack('<I1I1I2I1I2', network, index, io, station)

	return hdr..qhdr..data
end

function frame:from_hex(raw, index)
	local es, index = string.unpack('>I2', raw, index)
	assert(es == 0xD400)
	local seq, index = string.unpack('<I2', raw, index)
	local ed, index = string.unpack('>I2', raw, index)
	assert(ed == 0x0000)

	local network, p_index, io, station, data_len, index = string.unpack('<I1I1I2I1I2', raw, index)

	self._session = session:new(network, p_index, io, station, nil, seq)

	local str_left = string.len(raw) - index + 1
	if data_len > str_left then
		return nil, data_len - str_left
	end

	self._status, index = string.unpack('<I2', raw, index)
	--print('REPLY STATUS', self._status, string.format('%02X', self._status))

	self._data, index = string.unpack('<c'..(data_len - 2), raw, index)

	assert(index == data_len + 13 + 1, 'Incorrect index returned!')

	return index
end

function frame:session()
	return self._session
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
