--[[
Serialzation bytes stream like ActionScript flash.utils.ByteArray.
It depends on lpack.
A sample: https://github.com/zrong/lua#ByteArray
@see http://underpop.free.fr/l/lua/lpack/
@see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/ByteArray.html
@author zrong(zengrong.net)
Creation 2013-11-14
Last Modification 2014-12-25
]]
ByteArray = BaseClass("ByteArray")
ByteArray.poolKey = "byte_array"
ByteArray.ENDIAN_LITTLE = "ENDIAN_LITTLE"
ByteArray.ENDIAN_BIG = "ENDIAN_BIG"
ByteArray.radix = {[10]="%u",[8]="%03o",[16]="%02X"}
vars = ""
local lpack = require("pack")
local string_format = string.format
local string_byte = string.byte
local string_gsub = string.gsub
local string_char = string.char
local string_sub = string.sub
local table_concat = table.concat
local sunpack = lpack.unpack or string.unpack
local spack = lpack.pack or string.pack
local tunpack = unpack or table.unpack

--- Return a string to display.
-- If self is ByteArray, read string from self.
-- Else, treat self as byte string.
-- @param __radix radix of display, value is 8, 10 or 16, default is 10.
-- @param __separator default is " ".
-- @return string, number
function ByteArray.toString(self, __radix, __separator)
    __radix = __radix or 16
    __radix = ByteArray.radix[__radix] or "%02X"
    __separator = __separator or " "
    local __fmt = __radix..__separator
    local __format = function(__s)
        return string_format(__fmt, string_byte(__s))
    end
    if type(self) == "string" then
        return string_gsub(self, "(.)", __format)
    end
    local __bytes = {}
    for i=1,#self._buf do
        __bytes[i] = __format(self._buf[i])
    end
    return table_concat(__bytes) ,#__bytes
end

function ByteArray.toStringOffset(self,beginIndex,endIndex,__radix, __separator)
    __radix = __radix or 16
    __radix = ByteArray.radix[__radix] or "%02X"
    __separator = __separator or " "
    local __fmt = __radix..__separator
    local __format = function(__s)
        return string_format(__fmt, string_byte(__s))
    end
    if type(self) == "string" then
        return string_gsub(self, "(.)", __format)
    end
    local __bytes = {}
    for i=beginIndex,endIndex do
        __bytes[i] = __format(self._buf[i])
    end
    return table_concat(__bytes) ,#__bytes

end


function ByteArray:__Init(__endian)
    -- self._endian = __endian
    -- 默认设置成小端序
    self._endian = ByteArray.ENDIAN_LITTLE
    self._buf = {}
    self._pos = 1
end

function ByteArray:getLen()
    return #self._buf
end

function ByteArray:getAvailable()
    return self._pos - 1
end

function ByteArray:getPos()
    return self._pos
end

function ByteArray:setPos(__pos)
    self._pos = __pos
    return self
end

function ByteArray:getEndian()
    return self._endian
end

function ByteArray:setEndian(__endian)
    self._endian = __endian
end

--- Get all byte array as a lua string.
-- Do not update position.
function ByteArray:getBytes(__offset, __length)
    __offset = __offset or 1
    __length = __length or #self._buf
    -- if __length > #self._buf then
    --     hzf("getBytes,offset:%u, length:%u, #self._buf", __offset, __length, #self._buf)
    -- end
    return table_concat(self._buf, "", __offset, __length)
end

--- Get pack style string by lpack.
-- The result use ByteArray.getBytes to get is unavailable for lua socket.
-- E.g. the #self:_buf is 18, but #ByteArray.getBytes is 63.
-- I think the cause is the table_concat treat every item in ByteArray._buf as a general string, not a char.
-- So, I use lpack repackage the ByteArray._buf, theretofore, I must convert them to a byte number.
function ByteArray:getPack(__offset, __length)
    __offset = __offset or 1
    __length = __length or #self._buf
    local __t = {}
    for i=__offset,__length do
        __t[#__t+1] = string_byte(self._buf[i])
    end
    local __fmt = self:_getLC("b"..#__t)
    --print("fmt:", __fmt)
    local __s = spack(__fmt, tunpack(__t))
    return __s
end

--- rawUnPack perform like lpack.pack, but return the ByteArray.
function ByteArray:rawPack(__fmt, ...)
    local __s = spack(__fmt, ...)
    self:writeBuf(__s)
    return self
end

--- rawUnPack perform like lpack.unpack, but it is only support FORMAT parameter.
-- Because ByteArray include a position itself, so we haven't to save another.
function ByteArray:rawUnPack(__fmt)
    -- read all of bytes.
    local __s = self:getBytes(self._pos)
    local __next, __val = sunpack(__s, __fmt)
    -- update position of the ByteArray
    self._pos = self._pos + __next
    -- Alternate value and next
    return __val, __next
end

function ByteArray:readBool()
    -- When char > 256, the readByte method will show an error.
    -- So, we have to use readChar
    return self:readChar() ~= 0
end

function ByteArray:writeBool(__bool)
    if __bool then
        self:writeByte(1)
    else
        self:writeByte(0)
    end
    return self
end

function ByteArray:readDouble()
    local __, __v = sunpack(self:readBuf(8), self:_getLC("d"))
    return __v
end

function ByteArray:writeDouble(__double)
    local __s = spack( self:_getLC("d"), __double)
    self:writeBuf(__s)
    return self
end

function ByteArray:readFloat()
    local __, __v = sunpack(self:readBuf(4), self:_getLC("f"))
    return __v
end

function ByteArray:writeFloat(__float)
    local __s = spack( self:_getLC("f"),  __float)
    self:writeBuf(__s)
    return self
end

function ByteArray:readInt8()
    local __, __v = sunpack(self:readBuf(1), self:_getLC("i"))
    return __v
end

function ByteArray:readInt16()
    local __, __v = sunpack(self:readBuf(2), self:_getLC("i"))
    return __v
end

function ByteArray:readInt()
    local __, __v = sunpack(self:readBuf(4), self:_getLC("i"))
    return __v
end

function ByteArray:writeInt(__int)
    local __s = spack( self:_getLC("i"),  __int)
    self:writeBuf(__s)
    return self
end


function ByteArray:readUInt8()
    local __, __v = sunpack(self:readBuf(1), self:_getLC("I"))
    return __v
end

function ByteArray:readUInt16()
    local __, __v = sunpack(self:readBuf(2), self:_getLC("I"))
    return __v
end

function ByteArray:readUInt()
    local __, __v = sunpack(self:readBuf(4), self:_getLC("I"))
    return __v
end

function ByteArray:writeUInt(__uint)
    local __s = spack(self:_getLC("I"), __uint)
    self:writeBuf(__s)
    return self
end

function ByteArray:readShort()
    local __, __v = sunpack(self:readBuf(2), self:_getLC("h"))
    return __v
end

function ByteArray:writeShort(__short)
    local __s = spack( self:_getLC("h"),  __short)
    self:writeBuf(__s)
    return self
end

function ByteArray:readUShort()
    local __, __v = sunpack(self:readBuf(2), self:_getLC("H"))
    return __v
end

function ByteArray:writeUShort(__ushort)
    local __s = spack(self:_getLC("H"),  __ushort)
    self:writeBuf(__s)
    return self
end


-- 2014-07-09 Remove all of methods about Long in ByteArray.
-- @see http://zengrong.net/post/2134.htm
function ByteArray:readLong()
    local __, __v = sunpack(self:readBuf(8), self:_getLC("l"))
    return __v
end
function ByteArray:writeLong(__long)
    local __s = spack( self:_getLC("l"),  __long)
    self:writeBuf(__s)
    return self
end
function ByteArray:readULong()
    local __, __v = sunpack(self:readBuf(8), self:_getLC("L"))
    return __v
end
function ByteArray:writeULong(__ulong)
    local __s = spack( self:_getLC("L"), __ulong)
    self:writeBuf(__s)
    return self
end

function ByteArray:readUByte()
    local __, __v = sunpack(self:readRawByte(), "b")
    return __v
end

function ByteArray:writeUByte(__ubyte)
    local __s = spack("b", __ubyte)
    self:writeBuf(__s)
    return self
end

function ByteArray:readLuaNumber(__number)
    local __, __v = sunpack(self:readBuf(8), self:_getLC("n"))
    return __v
end

function ByteArray:writeLuaNumber(__number)
    local __s = spack(self:_getLC("n"), __number)
    self:writeBuf(__s)
    return self
end

--- The differently about (read/write)StringBytes and (read/write)String
-- are use pack libraty or not.
function ByteArray:readStringBytes(__len)
    assert(__len, "Need a length of the string!")
    if __len == 0 then return "" end
    self:_checkAvailable()
    local __, __v = sunpack(self:readBuf(__len), self:_getLC("A"..__len))
    return __v
end

function ByteArray:writeStringBytes(__string)
    local __s = spack(self:_getLC("A"), __string)
    self:writeBuf(__s)
    return self
end


function ByteArray:readString(__len)
    assert(__len, "Need a length of the string!")
    if __len == 0 then return "" end
    self:_checkAvailable()
    return self:readBuf(__len)
end

function ByteArray:writeString(__string)
    self:writeBuf(__string)
    return self
end

--- The length of size_t in C/C++ is mutable.
-- In 64bit os, it is 8 bytes.
-- In 32bit os, it is 4 bytes.
function ByteArray:readStringSizeT()
    self:_checkAvailable()
    local __s = self:rawUnPack(self:_getLC("a"))
    return  __s
end

--- Perform rawPack() simply.
function ByteArray:writeStringSizeT(__string)
    self:rawPack(self:_getLC("a"), __string)
    return self
end

function ByteArray:readStringUShort()
    self:_checkAvailable()
    local __len = self:readUShort()
    -- hzf("读取字符串长度："..__len)
    return self:readString(__len)
    -- return self:readStringBytes(__len)
end

function ByteArray:writeStringUShort(__string)
    -- local strbyte = string_byte(__string)
    self:writeUShort(__string:len())
    local __s = spack(self:_getLC("P"), __string)
    self:writeString(__string)
    return self
end

--- Read some bytes from buf
-- @return a bit string
function ByteArray:readBytes(__bytes, __offset, __length)
    assert(iskindof(__bytes, "ByteArray"), "Need a ByteArray instance!")
    local __selfLen = #self._buf
    local __availableLen = __selfLen - self._pos
    __offset = __offset or 1
    if __offset > __selfLen then __offset = 1 end
    __length = __length or 0
    if __length == 0 or __length > __availableLen then __length = __availableLen end
    __bytes:setPos(__offset)
    for i=__offset,__offset+__length do
        __bytes:writeRawByte(self:readRawByte())
    end
end

--- Write some bytes into buf
function ByteArray:writeBytes(__bytes, __offset, __length)
    assert(iskindof(__bytes, "ByteArray"), "Need a ByteArray instance!")
    local __bytesLen = __bytes:getLen()
    if __bytesLen == 0 then return end
    __offset = __offset or 1
    if __offset > __bytesLen then __offset = 1 end
    local __availableLen = __bytesLen - __offset
    __length = __length or __availableLen
    if __length == 0 or __length > __availableLen then __length = __availableLen end
    local __oldPos = __bytes:getPos()
    __bytes:setPos(__offset)
    for i=__offset,__offset+__length do
        self:writeRawByte(__bytes:readRawByte())
    end
    __bytes:setPos(__oldPos)
    return self
end

--- Actionscript3 readByte == lpack readChar
-- A signed char
function ByteArray:readChar()
    local __, __val = sunpack( self:readRawByte(), "c")
    return __val
end

--- Use the spack of lpack api to write a byte.
function ByteArray:writeChar(__char)
    self:writeRawByte(spack("c", __char))
    return self
end

function ByteArray:readByte()
    local ret = string_byte(self:readRawByte())
    if ret > 127 then
        ret = ret - 256
    end
    return ret
end

function ByteArray:readSbyte()
    local ret = string_byte(self:readRawByte())
    if ret > 127 then
        ret = ret - 256
    end
    return ret
end


--- Use the string_char of lua standard library to write a byte.
-- The byte is a number between 0 and 255, otherwise, Lua will throw an error.
-- 这里改写成有符号的8位整数
-- 黄泽枫 2019年01月11日11:57:48
function ByteArray:writeByte(__byte)
    if __byte < 0 then
        __byte = 256 + __byte
    end
    self:writeRawByte(string_char(__byte))
    return self
end

function ByteArray:writeSbyte(__byte)
    if __byte < 0 then
        __byte = 256 + __byte
    end
    self:writeRawByte(string_char(__byte))
    return self
end

function ByteArray:readRawByte()
    self:_checkAvailable()
    local __byte = self._buf[self._pos]
    self._pos = self._pos + 1
    return __byte
end

function ByteArray:writeRawByte(__rawByte)
    -- Fill zero between position and length.
    if self._pos > #self._buf+1 then
        for i=#self._buf+1,self._pos-1 do
            self._buf[i] = string_char(0)
        end
    end
    self._buf[self._pos] = string_sub(__rawByte, 1,1)
    self._pos = self._pos + 1
    return self
end

--- Read a byte array as string from current position, then update the position.
function ByteArray:readBuf(__len)
    -- hzf("readBuf,len:%u, pos:%u", __len, self._pos)
    local __ba = self:getBytes(self._pos, self._pos + __len - 1)
    self._pos = self._pos + __len
    return __ba
end

--- Write a encoded char array into buf
function ByteArray:writeBuf(__s)
    -- hzf("写入数据长度", #__s)
    for i=1,#__s do
        self:writeRawByte(string_sub(__s,i,i))
    end
    return self
end

function ByteArray:writeBufArray(__s)
    local len = __s.Length
    for i=1,len do
        self:writeRawByte(string_char(__s[i-1]))
    end
end

function ByteArray:InsertBuf(__buf)
    for i,v in ipairs(__buf) do
        self._buf[self._pos] = v
        self._pos = self._pos + 1
    end
end
----------------------------------------
-- private
----------------------------------------
function ByteArray:_checkAvailable()
    assert(#self._buf >= self._pos, string_format("End of file was encountered. pos: %d, len: %d.", self._pos, #self._buf))
end

--- Get Letter Code
function ByteArray:_getLC(__fmt)
    __fmt = __fmt or ""
    if self._endian == ByteArray.ENDIAN_LITTLE then
        return "<"..__fmt
    elseif self._endian == ByteArray.ENDIAN_BIG then
        return ">"..__fmt
    end
    return "="..__fmt
end

function ByteArray:OnReset()
    self._pos = 1
end


