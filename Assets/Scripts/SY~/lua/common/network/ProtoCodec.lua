ProtoCodec = SingleClass("ProtoCodec")

local fieldName = ""

function ProtoCodec:__init()
    self.sendFields = nil
	self.recvFields = nil
	
    self.writer = {}
	self.reader = {}

    self:InitWriter()
    self:InitReader()

	self.readByteArray = ByteArray.New()
	self.writeByteArray = nil
	
	self.marshalData = nil
	self.unmarshalData = nil

	self.protoId = nil
	self.fieldName = nil
	self.fieldType = nil
	self.fieldData = nil

	self.readDataFunc = function(fields) self:ReadData(fields) end
	self.writeDataFunc = function(data,fields) self:WriteData(data,fields) end
end

function ProtoCodec:InitReader()
    self.reader[NetworkDefine.DataType.bool] = function(field) return self:Read_bool(field) end
	self.reader[NetworkDefine.DataType.int8] = function(field) return self:Read_byte(field) end
	self.reader[NetworkDefine.DataType.uint8] = function(field) return self:Read_ubyte(field) end
	self.reader[NetworkDefine.DataType.int16] = function(field) return self:Read_short(field) end
	self.reader[NetworkDefine.DataType.uint16] = function(field) return self:Read_ushort(field) end
	self.reader[NetworkDefine.DataType.int32] = function(field) return self:Read_int(field) end
	self.reader[NetworkDefine.DataType.uint32] = function(field) return self:Read_uint(field) end
	self.reader[NetworkDefine.DataType.int64] = function(field) return self:Read_long(field) end
	self.reader[NetworkDefine.DataType.uint64] = function(field) return self:Read_ulong(field) end
	self.reader[NetworkDefine.DataType.float] = function(field) return self:Read_float(field) end
	self.reader[NetworkDefine.DataType.double] = function(field) return self:Read_double(field) end
	self.reader[NetworkDefine.DataType.string] = function(field) return self:Read_string(field) end
	self.reader[NetworkDefine.DataType.array] = function(field) return self:Read_array(field) end
	self.reader[NetworkDefine.DataType.dict] = function(field) return self:Read_dict(field) end
	self.reader[NetworkDefine.DataType.binary] = function(field) return self:Read_binary(field) end
	self.reader[NetworkDefine.DataType.byte] = function(field) return self:Read_strByte(field) end
end

function ProtoCodec:InitWriter()
	self.writer[NetworkDefine.DataType.bool] = function(v,field) self:Write_bool(v,field) end
	self.writer[NetworkDefine.DataType.int8] = function(v,field) self:Write_byte(v,field) end
	self.writer[NetworkDefine.DataType.uint8] = function(v,field) self:Write_ubyte(v,field) end
	self.writer[NetworkDefine.DataType.int16] = function(v,field) self:Write_short(v,field) end
	self.writer[NetworkDefine.DataType.uint16] = function(v,field) self:Write_ushort(v,field) end
	self.writer[NetworkDefine.DataType.int32] = function(v,field) self:Write_int(v,field) end
	self.writer[NetworkDefine.DataType.uint32] = function(v,field) self:Write_uint(v,field) end
	self.writer[NetworkDefine.DataType.int64] = function(field) return self:Write_long(field) end
	self.writer[NetworkDefine.DataType.uint64] = function(field) return self:Write_ulong(field) end
	self.writer[NetworkDefine.DataType.float] = function(v,field) self:Write_float(v,field) end
	self.writer[NetworkDefine.DataType.double] = function(v,field) self:Write_double(v,field) end
	self.writer[NetworkDefine.DataType.string] = function(v,field) self:Write_string(v,field) end
	self.writer[NetworkDefine.DataType.array] = function(v,field) self:Write_array(v,field) end
	self.writer[NetworkDefine.DataType.dict] = function(v,field) self:Write_dict(v,field) end
	self.writer[NetworkDefine.DataType.binary] = function(v,field) self:Write_binary(v,field) end
	self.writer[NetworkDefine.DataType.byte] = function(v,field) self:Write_strByte(v,field) end
end

function ProtoCodec:SetSendFields(v)
    self.sendFields = v
end

function ProtoCodec:SetRecvFields(v)
    self.recvFields = v
end

-----写入相关
function ProtoCodec:Marshal(id,data)
	self.protoId = id

	local fields = self.sendFields[id]
	
	self.writeByteArray = PoolManager.Instance:Pop(PoolType.class,ByteArray.poolKey)
	if not self.writeByteArray then self.writeByteArray = ByteArray.New() end

    self:Write_uint(0)
	self:Write_ushort(id)

	--self:Write(data,fields)

	local ok, msg = pcall(self.writeDataFunc,data,fields)
	if not ok then 
		LogErrorf("写入协议字段出错[协议:%s][字段:%s][类型:%s][数据:%s]",self.protoId,self.fieldName,self.fieldType,Print.ToString(self.fieldData))
		return nil
	end

	local endPos = self.writeByteArray:getPos()

    local len = self.writeByteArray:getAvailable()
    self.writeByteArray:setPos(1)
	self:Write_uint(len - 4)
	self.writeByteArray:setPos(endPos)

    return self.writeByteArray
end

function ProtoCodec:WriteData(data,fields)
	self.marshalData = self:Write(data,fields)
end

function ProtoCodec:Write(data,fields)
	for _,v in ipairs(fields) do
		self.fieldName = v.name
		self.fieldType = v.type
		self.fieldData = data
		local func = self.writer[v.type]
		func(data[v.name],v)
		--if not func then
		--	Debug.LogError(string.format("无法识别的字段类型[name:%s][type:%s]",tostring(v.name),tostring(v.type)))
		--else
		--	func(data[v.name],v)
		--end
	end
end

function ProtoCodec:Write_bool(v,field)
	self.writeByteArray:writeBool(v)
end

function ProtoCodec:Write_byte(v,field)
	self.writeByteArray:writeByte(v)
end

function ProtoCodec:Write_ubyte(v,field)
	self.writeByteArray:writeUByte(v)
end

function ProtoCodec:Write_short(v,field)
	self.writeByteArray:writeShort(v)
end

function ProtoCodec:Write_ushort(v,field)
	self.writeByteArray:writeUShort(v)
end

function ProtoCodec:Write_int(v,field)
	self.writeByteArray:writeInt(v)
end

function ProtoCodec:Write_uint(v,field)
	self.writeByteArray:writeUInt(v)
end

function ProtoCodec:Write_long(v,field)
	self.writeByteArray:writeLong(v)
end

function ProtoCodec:Write_ulong(v,field)
	self.writeByteArray:writeULong(v)
end

function ProtoCodec:Write_float(v,field)
	self.writeByteArray:writeFloat(v)
end

function ProtoCodec:Write_double(v,field)
	self.writeByteArray:writeDouble(v)
end

function ProtoCodec:Write_string(v,field)
	self.writeByteArray:writeStringUShort(v)
end

function ProtoCodec:Write_array(v,field)
	self:Write_ushort(#v)
	for _,data in ipairs(v) do self:Write(data,field.fields) end
end

function ProtoCodec:Write_dict(data,field)
	local beginPos = byteBuffer:getPos()
	self:Write_ushort(0) --先写入个长度

	local keyType = field.keyType

	if not self:IsDictKeyType(keyType) then
		Log.Error(string.format("Dict -> key数据类型错误[name:%s][type:%s]",field.name,keyType))
		return
	end

	local count = 0
	local dataDict = data[field.name]

	local func = self.writer[keyType]
	if not func then
		Log.Error(string.format("无法识别的字段类型[name:%s][type:%s]",field.name,field.type))
		return
	end

	for k,v in pairs(dataDict) do
		func(k,nil)
		self:Write(v,field.fields)
		count = count + 1
	end

	if count == 0 then return end
	local endPos = self.writeByteArray:getPos()
	self.writeByteArray:setPos(beginPos)
	self:Write_ushort(count)
	self.writeByteArray:setPos(endPos)
end

function ProtoCodec:Write_binary(v,field)
	local len = v.Length
    self.writeByteArray:writeUShort(len)
    self.writeByteArray:writeBufArray(v)
end

function ProtoCodec:Write_strByte(v,field)
	local len = #v
    self.writeByteArray:writeUInt(len)
    self.writeByteArray:writeStringBytes(v)
end


--读取相关
function ProtoCodec:Unmarshal(bytes)
    self.readByteArray:setPos(1)
    self.readByteArray:writeBuf(bytes)
	self.readByteArray:setPos(1)

	self.protoId = self:Read_ushort()

	local fields = self.recvFields[self.protoId]
	if not fields then
		LogErrorf("解析协议字段异常，未知的协议Id[协议:%s]",self.protoId)
		return 0,nil
	end

	local ok, msg = pcall(self.readDataFunc,fields)
	if not ok then 
		LogErrorf("解析协议字段出错[协议:%s][字段:%s][类型:%s]",self.protoId,self.fieldName,self.fieldType)
		return 0,nil
	end

	if NetworkDefine.NewReadByteArray[self.protoId] then
		self.readByteArray = ByteArray.New()
	end

	return self.protoId,self.unmarshalData
end

--读取相关
function ProtoCodec:UnmarshalCSharp(protoId, bytes)
    self.readByteArray:setPos(1)
    self.readByteArray:writeBuf(bytes)
	self.readByteArray:setPos(1)

	local fields = self.recvFields[protoId]

	local ok, msg = pcall(self.readDataFunc,fields)
	if not ok then 
		LogErrorf("解析协议字段出错[协议:%s][字段:%s][类型:%s]", protoId,self.fieldName,self.fieldType)
		return 0,nil
	end

	if NetworkDefine.NewReadByteArray[protoId] then
		self.readByteArray = ByteArray.New()
	end

	return self.unmarshalData
end

function ProtoCodec:ReadData(fields)
	self.unmarshalData = self:Read(fields)
end

function ProtoCodec:Read(fields)
	local data = {}
	for _,v in ipairs(fields) do
		self.fieldName = v.name
		self.fieldType = v.type
		local func = self.reader[v.type]
		data[v.name] = func(v)
		--if not func then
		--	Log.Error(string.format("未知的协议字段类型[id:%s][name:%s][type:%s]",self.protoId,v.name,v.type))
		--else
		--	data[v.name] = func(v)
		--end
	end
	return data
end

function ProtoCodec:Read_bool(field)
	return self.readByteArray:readBool()
end

function ProtoCodec:Read_byte(field)
	return self.readByteArray:readByte()
end

function ProtoCodec:Read_ubyte(field)
	return self.readByteArray:readUByte()
end

function ProtoCodec:Read_short(field)
	return self.readByteArray:readShort()
end

function ProtoCodec:Read_ushort(field)
	return self.readByteArray:readUShort()
end

function ProtoCodec:Read_int(field)
	return self.readByteArray:readInt()
end

function ProtoCodec:Read_uint(field)
	return self.readByteArray:readUInt()
end

function ProtoCodec:Read_long(field)
	return self.readByteArray:readLong()
end

function ProtoCodec:Read_ulong(field)
	return self.readByteArray:readULong()
end


function ProtoCodec:Read_float(field)
	return self.readByteArray:readFloat()
end

function ProtoCodec:Read_double(field)
	return self.readByteArray:readDouble()
end

function ProtoCodec:Read_string(field)
	return self.readByteArray:readStringUShort()
end

function ProtoCodec:Read_array(field)
	local array = {}
	local len = self:Read_ushort()
	for i=1,len do table.insert(array,self:Read(field.fields)) end
	return array
end

function ProtoCodec:Read_dict(field)
	local dict = {}
	local keyType = field.keyType

	if not self:IsDictKeyType(keyType) then
		Log.Error(string.format("Dict -> key数据类型错误[name:%s][type:%s]",field.name,keyType))
		return dict
	end

	local func = self.reader[keyType]
	if not func then
		Log.Error(string.format("未处理的字段类型[name:%s][type:%s]",field.name,field.type))
		return
	end
	
	local len = self:Read_ushort()
	for i=1,len do
		local key = func(nil)
		local data = self:Read(field.fields)
		dict[key] = data
	end
	
	return dict
end

function ProtoCodec:Read_binary(field)
	local length = self.readByteArray:readUShort()
	return self.readByteArray:readBuf(length)
end

function ProtoCodec:Read_strByte(field)
	local length = self.readByteArray:readUInt()
	return self.readByteArray:readStringBytes(length)
end

----------------------------
function ProtoCodec:IsDictKeyType(keyType)
	if keyType == NetworkDefine.DataType.bool then return false end
	if keyType == NetworkDefine.DataType.array then return false end
	if keyType == NetworkDefine.DataType.dict then return false end
	return true
end

-----------------------------------------
ProtoCodec:__init()