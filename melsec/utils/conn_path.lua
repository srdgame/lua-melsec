local class = require 'middleclass'

local path = class('LUA_ENIP_PATH')

local function parse_conn_path(path)
	local proto, addr, port = string.match(path, '^([^:]-)[://]-([^:]+):?(%d-)$')
	--print(proto, addr, port)

	proto = string.len(proto or '') == 0 and 'tcp' or proto
	port = string.len(port or '') == 0 and 0xAF12 or tonumber(port)

	return string.lower(proto), string.lower(addr), port
end

local function test_parse_conn_path()
	local proto, addr, port = parse_conn_path('127.0.0.1')
	assert(proto == 'tcp', 'Default tcp protocol parse failed')
	assert(addr == '127.0.0.1', 'IP Address parse failed')
	assert(port == 0xAF12, 'Port default failure')

	proto, addr, port = parse_conn_path('127.0.0.1:44817')
	assert(proto == 'tcp', 'Default tcp protocol parse failed')
	assert(addr == '127.0.0.1', 'IP Address parse failed')
	assert(port == 44817, 'Port default failure')

	proto, addr, port = parse_conn_path('udp:127.0.0.1:44817')
	assert(proto == 'udp', 'Protocol parse failed')
	assert(addr == '127.0.0.1', 'IP Address parse failed')
	assert(port == 44817, 'Port default failure')
end

-- test_parse_conn_path()

function path:initialize(conn_path)
	self._proto, self._addr, self._port = parse_conn_path(conn_path)
end

function path:__tostring()
	return string.format('%s:%s:%d', self._proto, self._addr, self._port)
end

function path:proto()
	return self._proto
end

function path:address()
	return self._addr
end

function path:port()
	return self._port
end

return path
