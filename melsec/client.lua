local class = require 'middleclass'
local utils_conn_path = require 'melsec.utils.conn_path'
local utils_route_path = require 'melsec.utils.route_path'

local client = class("LUA_MELSEC_CLIENT")


function client:initialize(conn_path, route_path)
	self._conn_path = utils_conn_path(conn_path)
	self._route_path = utils_route_path(route_path)
end

function client:connect()
	assert(nil, "Not implemented!")
end

function client:disconnect()
	assert(nil, "Not implemented!")
end

return client
