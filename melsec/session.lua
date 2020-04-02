local class = require 'middleclass'

local session = class('LUA_MELSEC_SESSION')

function session:initialize(network, index, io, station, timer)
	self._network = network
	self._index = index
	self._io = io
	self._station = station
	self._timer = timer
	self._seq = 0
end

function session:gen_seq()
	self._seq = (self._seq + 1) % 0xFFFF
	return self._seq
end

function session:set_seq(seq)
	self._seq = seq
end

function session:sequence()
	return self._seq
end

function session:network()
	return self._network
end

function session:index()
	return self._index
end

function session:io()
	return self._io
end

function session:station()
	return self._station
end

function session:timer()
	return self._timer
end

return session
