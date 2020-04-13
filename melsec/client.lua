local class = require 'middleclass'
local session = require 'melsec.session'
local utils_conn_path = require 'melsec.utils.conn_path'

local block_read = require 'melsec.command.request.block_read'
local cmd_types = require 'melsec.command.types'

local client = class("LUA_MELSEC_CLIENT")

local PROTO_MAP = {
	P_3E_BIN = '3e_bin',
	P_4E_BIN = '4e_bin',
	P_4C_FMT_5 = '4c_f5',
}

local function try_load_package(pn)
	local r, p = pcall(require, pn)
	if not r then
		return nil, p
	end
	return p
end

local function load_proto_frame(protocol)
	local req_pn = 'melsec.frame.request.'..PROTO_MAP['P_'..protocol]
	local rep_pn = 'melsec.frame.reply.'..PROTO_MAP['P_'..protocol]

	local req = assert(try_load_package(req_pn))
	local rep = assert(try_load_package(rep_pn))

	return req, rep
end


function client:initialize(conn_path, protocol, network, index, io, station)
	assert(conn_path, 'Connection path is required')
	assert(protocol, 'Protocol is required')
	assert(network, 'Network ID is required')
	assert(index, 'Index is required')
	assert(io, 'IO ID is required')
	assert(station, 'Station ID is required')

	self._ascii = false
	self._conn_path = utils_conn_path(conn_path)
	self._request_frame, self._reply_frame = load_proto_frame(protocol)
	self._session = session:new(network, index, io, station)
end

function client:conn_path()
	return self._conn_path
end

function client:session()
	return self._session
end

function client:connect()
	assert(nil, "Not implemented!")
end

function client:close()
	assert(nil, "Not implemented!")
end

function client:request(req, response)
	assert(nil, "Not implemented!")
end

function client:on_reply(request, raw)
	local index, need_len = self._reply_frame:from_hex(raw)
	if not index then
		return nil, need_len
	end

	return self._reply_frame, index
end

function client:read_sc(name, index, count, response)
	local sc_name = name
	if string.len(sc_name) == 2 and string.sub(2,2) == '*' then
		sc_name = string.sub(sc_name, 1,1)
	end
	if 'BIT' == cmd_types.SC_VALUE_TYPE[sc_name] then
		return self:read_bits(name, index, count, response)
	else
		return self:read_words(name, index, count, response)
	end
end

function client:read_words(name, index, count, response)
	local cmd = block_read(self._ascii, true, name, index, count)
	local req = self._request_frame:new(self._session, cmd)

	return self:request(req, function(reply, err)
		if not reply then
			return response(nil, err)
		else
			local data = reply:data()
			--[[
			local basexx = require 'basexx'
			print(basexx.to_hex(data))
			]]--
			return response(data, err)
		end
	end)
end

function client:read_bits(name, index, count, response)
	local cmd = block_read(self._ascii, false, name, index, count)
	local req = self._request_frame:new(self._session, cmd)

	return self:request(req, function(reply, err)
		--- TODO:
		return response(reply, err)
	end)
end

function client:read_tags(tags, response)
end

function client:write_tag(name, index, values)
end

return client
