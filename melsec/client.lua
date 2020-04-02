local class = require 'middleclass'
local utils_conn_path = require 'melsec.utils.conn_path'
local utils_route_path = require 'melsec.utils.route_path'

local block_read = require 'melsec.command.request.block_read'

local client = class("LUA_MELSEC_CLIENT")

local PROTO_MAP = {
	3E_BIN = '3e_bin',
	4E_BIN = '4e_bin',
	4C_FMT_5 = '4c_f5',
}

local function try_load_package(pn)
	local r, p = pcall(require, pn)
	if not r then
		return nil, p
	end
	return p
end

local function load_proto_frame(protocol)
	local req_pn = 'melsec.frame.request.'..PROTO_MAP[protocol]
	local rep_pn = 'melsec.frame.reply.'..PROTO_MAP[protocol]

	local req = assert(try_load_package(req_pn))
	local rep = assert(try_load_package(rep_pn))

	return req, rep
end


function client:initialize(protocol, conn_path, route_path)
	self._ascii = false
	self._request_frame, self._reply_frame = load_proto_frame(protocol)
	self._conn_path = utils_conn_path(conn_path)
	self._route_path = utils_route_path(route_path)
end

function client:connect()
	assert(nil, "Not implemented!")
end

function client:disconnect()
	assert(nil, "Not implemented!")
end

function client:read_words(name, index, count, response)
	local cmd = block_read(self._ascii, true, name, index, count)
	local req = self._request_frame:new(
end

function client:read_bits(name, index, count, response)

end

function client:read_tags(tags, response)
end

function client:write_tag(name, index, values)
end

return client
