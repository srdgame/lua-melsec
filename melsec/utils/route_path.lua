local class = require 'middleclass'

local path = class('LUA_ENIP_PATH')

local function parse_route_path(path)
	local port, link = string.match(path, '^(%d+),(%d+)$')
	assert(port and link, "Parser route path error. route:"..path)

	return tonumber(port), tonumber(link)
end

function path:initialize(route_path)
	self._port, self._link = parse_route_path(route_path)
end

function path:__tostring()
	return string.format('%d:%d', self._port, self._link)
end

function path:port()
	return self._port
end

function path:link()
	return self._link
end

return path
