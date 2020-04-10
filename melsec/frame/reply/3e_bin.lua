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
	assert(self._session and self._status and self._data

	local hdr = string.pack('>I2', 0xD000)

	local data_p = string.pack('<I2', self._status)
	local data = data_p .. self._data:to_hex()
	local data_len = string.len(data)

	local network = self._session:network()
	local index = self._session:index()
	local io = self._session:io()
	local station = self._session:station()

	local qhdr = string.pack('<I1I1I2I1I2', network, index, io, station)

	return hdr..qhdr..data
end

function frame:from_hex(raw, index)
	local es, index = string.unpack('>I2', raw, index)
	assert(es == 0xD000)

	local network, p_index, io, station, data_len, index = string.unpack('<I1I1I2I1I2', raw, index)

	self._session = session:new(network, p_index, io, station)

	local str_left = string.len(raw) - index + 1
	if data_len > str_left then
		return nil, data_len - str_left
	end

	self._status, index = string.unpack('<I2', raw, index)

	self._data, index = parser(raw, index)

	assert(index = data_len + 9 + 1, 'Incorrect index returned!')

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
