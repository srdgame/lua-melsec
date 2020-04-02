local base = require 'melsec.frame.base'
local parser = require 'melsec.command.reply.parser'
local session = require 'melsec.session'

local frame = class('LUA_MELSEC_FRAME_4E_BIN', base)

function frame:initialize(session, command)
	base.initialize(self)
	self._session = session
	self._command = command
end

function frame:to_hex()
	local sequence = self._session:gen_seq()
	local hdr = string.pack('>I2', 0x5400)..string.pack('<I2', sequence)..string.pack('>I2', 0x0000)

	local data_p = string.pack('<I2', self._sesssion:timer())
	local data = data_p .. self._command:to_hex()
	local data_len = string.len(data)

	local network = self._session:network()
	local index = self._session:index()
	local io = self._session:io()
	local station = self._session:station()

	local qhdr = string.pack('<I1I1I2I1I2', network, index, io, station, data_len)


	return hdr..qhdr..data
end

function frame:from_hex(raw, index)
	local es, index = string.unpack('>I2', raw, index)
	assert(es == 0x5400)
	local seq, index = string.unpack('<I2', raw, index)
	local ed, index = string.unpack('>I2', raw, index)
	assert(ed == 0x0000)

	local network, sindex, io, station, data_len, index = string.unpack('<I1I1I2I1I2')

	local str_left = string.len(raw) - index + 1
	if data_len > str_left then
		return nil, data_len - str_left
	end

	local timer, index = string.unpack('<I2', raw, index)

	local new_index = 1
	local new_raw = string.sub(raw, index, index + data_len - 2)

	local basexx = require 'basexx'
	print('FROM_HEX', basexx.to_hex(new_raw))

	self._command, new_index = parser(new_raw, new_index)
	self._session = session:new(network, sindex, io, station, timer)
	self._session:set_seq(seq)

	assert(new_index = data_len - 2 + 1, "Incorrect index returned!")

	return index + new_index
end

function frame:session()
	return self._session
end

function frame:command()
	return self._command
end

return frame
