local class = require 'middleclass'

local session = require 'melsec.session'
local base = require 'melsec.frame.base'

local frame = class('LUA_MELSEC_FRAME_4C_FORMAT_5_BIN', base)

function frame:initialize(session, status, data)
	base.initialize(self)
	self._session = session
	self._status = status
	self._data = data
end

function frame:to_hex()
	local pre = string.pack('>I2', 0x1002)
	local pos = string.pack('>I2', 0x1003)

	local data = string.pack('<I2I2', 0xFF, self._status)
	if self._data then
		local data = data .. self._data:to_hex()
	end

	local data_len = string.len(data) + 10

	local sequence = self._session:get_seq()
	local network = self._session:network()
	local index = self._session:index()
	local io = self._session:io()
	local station = self._session:station()

	local qhdr = string.pack('<I2I1I1I1I2I1I1', data_len, 0xF8, 0x00, network, index, io, station, 0x00)

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

	local ver, site, network, p_index, io, station, this_site, index = string.unpack('<I1I1I1I1I2I1I1')
	assert(ver == 0xF8)
	assert(site == 0x00)
	assert(this_site == 0x00)

	self._session = session:new(network, p_index, io, station)

	local rp
	rp, self._status, index = string.unpack('<I2I2', raw, index)

	if self._status == 0x00 then
		self._data, index = parser(raw, index)
	else
		self._data = nil
	end

	local pos, sum, index = string.unpack('>I2I2', raw, index)
	assert(pos == 0x1003)
	--assert(sum == ???)

	return index
end

function frame:session()
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
