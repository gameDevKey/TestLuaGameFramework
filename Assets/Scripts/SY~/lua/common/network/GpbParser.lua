GpbParser = SingleClass("GpbParser")
-- protobuf 打包/解包
local pb = require("pb")
local pack = require("pack")

local table_concat = table.concat
local table_insert = table.insert
local string_pack = pack.pack
local string_unpack = pack.unpack
local string_sub = string.sub

function GpbParser:__Init()
	self.decoderNames = {}
	self.encoderNames = {}
	self.protoMapping = nil
end

function GpbParser:InitGpb()
	Log("加载3")
	self.protoMapping = require "data/proto/pt_define"
	
	for _,pbFile in ipairs(self.protoMapping.file) do
		local flag = pb.load(LuaManager.Instance:GetPb(pbFile))
		assert(flag, string.format("加载pb文件失败[%s]",pbFile))
	end
end

-- Tcp协议打包
function GpbParser:Pack(protoId, data)
	data = data or {}
	local encoder = self.encoderNames[protoId] or self:EncoderName(protoId)
	local binary = pb.encode(encoder, data)
	return string_pack("<I<H<I<A", #binary + 6, protoId, 0, binary)
end

-- Tcp协议解包
function GpbParser:UnPack(bytes)
	local _,_,protoId,originSize,binary = string_unpack(bytes, "<I<H<I<A".. #bytes - 10,1)
	local decoderName = self.decoderNames[protoId] or self:DecoderName(protoId)
	local data = pb.decode(decoderName, binary)
	return protoId,data
	--if size > 0 then bytes = Lz4.block_decompress_fast(bytes, size)	end
end

-- Udp协议打包
function GpbParser:PackUdp(protoId, data)
	return self:Pack(protoId, data)
end

-- Udp协议解包
function GpbParser:UnPackUdp(bytes)
	local cursor = 1
	local length, id, size, binary
	cursor, length = string_unpack(bytes, "<H", cursor)
	__, id, size, binary = string_unpack(bytes, "<H<H<A".. length - 4, cursor)
	if size > 0 then binary = Lz4.block_decompress_fast(binary, size) end
	local decoder = self.decoder[id] or self:InitDecoder(id)
	local data = pb.decode(decoder, binary)
	return id, data
end

-- 初始化打包器字典
function GpbParser:EncoderName(protoId)
	self.encoderNames[protoId] = self.protoMapping.send[protoId]
	return self.encoderNames[protoId]
end

-- 初始化解包器字典
function GpbParser:DecoderName(protoId)
	self.decoderNames[protoId] = self.protoMapping.recv[protoId]
	return self.decoderNames[protoId]
end

