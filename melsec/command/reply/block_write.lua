local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REPLY_BLOCK_READ', base)


function read:initialize(ascii, word_or_bit, values)
	local sub_cmd = word_or_bit and types.SUB_CMD.WORD or types.SUB_CMD.BIT
	base.initialize(self, ascii, types.CMD.BLOCK_READ, sub_cmd)
end

return read
