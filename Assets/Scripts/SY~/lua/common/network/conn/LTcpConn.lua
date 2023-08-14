LTcpConn = BaseClass("LTcpConn",BaseConn)

local socket = require "socket.core"
local pack = require("pack")
local string_pack = pack.pack
local string_unpack = pack.unpack

function LTcpConn:__Init()
    self.readByteArray = ByteArray.New()
    self.packList = List.New()

    self.recvState = nil
    self.needRecvLen = nil
    self.recvLen = nil
    self.recvData = nil

    self.keepRecv = true
    self.frameRecvNum = 0

    self.sendList = {}
    self.maxSendLen = 1000
    self.dispatcherNum = 10000

    self.offsetNum = 0
end


function LTcpConn:OnConnect()
    local netType = "inet"
   -- if ctx:IsIpv6() then netType = "inet6" end
   
    self.socket = socket.tcp()
    self.socket:settimeout(0)
    self.socket:connect(self.host,self.port, nil, nil, netType)
    self.try = 0
    self:RemoveConnTimer()
    self.connTimer = TimerManager.Instance:AddTimer(self.maxTry, 0.5, self:ToFunc("LoopConnect"))
end

function LTcpConn:LoopConnect()
    if self.state ~= ConnState.connecting then 
        return 
    end

    self.try = self.try + 1
    if self.try >= self.maxTry then
        self.connTimer = nil
    end
    Log("尝试连接",self.try)


    local _, infos = socket.select({},{self.socket}, 0)
    local succeed,fail = false,false
    if infos[1] ~= nil then
        local flag = self:Handshake()
        if not flag then fail = true end
        if flag then succeed = true end
    end

    if succeed then
        self:RemoveConnTimer()
        self:ConnectSucceed()
    elseif fail or self:IsMaxTry() then
        self:RemoveConnTimer()
        self:ConnectFail()
    end
end

function LTcpConn:Handshake()
    self.socket:setoption("keepalive", true)
    self.socket:setoption("tcp-nodelay", true)
    --self.socket:setoption("reuseaddr", true)
    local byteArry = ByteArray.New()
    byteArry:writeString(NetworkDefine.handshake)
    local len,err = self.socket:send(byteArry:getPack())
    return len ~= nil
end

function LTcpConn:ConnectFail()
    Log("连接失败")
    self:SetState(ConnState.none)
    self:NoticeEvent(ConnEvent.connect_fail)
end

function LTcpConn:ConnectSucceed()
    Log("连接成功")
    self:ResetRecv()
    self:SetState(ConnState.connected)
    self:NoticeEvent(ConnEvent.connected)
end

function LTcpConn:OnUpdate()
    self:SendPack()
    self:RecvPack()
    self:DispatcherPack()
end


function LTcpConn:SendPack()
    local lenCount = 0
    local remove = {}
    local sendFlag = true

    for i,v in ipairs(self.sendList) do
        while v.sendLen < v.maxLen and lenCount < self.maxSendLen do
            local addLen = v.maxLen - v.sendLen
            if lenCount + addLen > self.maxSendLen then addLen = self.maxSendLen - lenCount end

            local _,bytes = string_unpack(v.byteArray, "<A".. addLen, v.sendLen + 1)
            local sendFlag = self:SendData(bytes)

            if not sendFlag then break end
            
            v.sendLen = v.sendLen + addLen
            lenCount = lenCount + addLen
        end

        if v.sendLen >= v.maxLen then table.insert(remove,i) end
        if lenCount >= self.maxSendLen then break end
    end
    
    if not sendFlag then
        return 
    end

    for i=#remove,1,-1 do
        table.remove( self.sendList,remove[i])
    end
end

function LTcpConn:DispatcherPack()
    for i = 1,self.dispatcherNum do 
        local bytes = self.packList:PopHead()
        if not bytes then
            break
        end
        self:Dispatcher(bytes)
    end
end


function LTcpConn:OnSend(byteArray)
    table.insert(self.sendList,{sendLen = 0,maxLen = #byteArray, byteArray = byteArray })
end

function LTcpConn:SendData(bytes)
    if not self.socket or not self:IsConnect() then
        return false
    end
   
    local len, err, _ = self.socket:send(bytes)
    if len then
        return true 
    end

    self:Disconnect(NetworkDefine.DisconnectType.send_fail)
    return false
end

function LTcpConn:RecvPack()
    if not self.socket or not self:IsConnect() then
        return
    end

    self.frameRecvNum = 0

    if self.recvState == RecvState.header then
        self:RecvHeader()
    elseif self.recvState == RecvState.body then
        self:RecvBody()
    end

    if self.keepRecv and self.frameRecvNum < 10 then
        self:RecvPack()
    end
end

function LTcpConn:RecvHeader()
    self.offsetNum = 0
    local ok = self:RecvData()
    if not ok then return end
    self.readByteArray:setPos(1)
    self.readByteArray:writeBuf(self.recvData)
    self.readByteArray:setPos(1)
    self.needRecvLen = self.readByteArray:readUInt()
    self.recvState = RecvState.body
end

function LTcpConn:RecvBody()
    self.offsetNum = NetworkDefine.headerLen
    local ok = self:RecvData()
    if not ok then return end
    self.packList:Push(self.recvData)
    self.recvState = RecvState.header
    self.needRecvLen = NetworkDefine.headerLen
    self.recvData = ""
end

function LTcpConn:RecvData()
    local needLen = self.needRecvLen - self.recvLen
    local fullBytes, err, partBytes = self.socket:receive(needLen)

    if not fullBytes and not partBytes then
        self:Disconnect(NetworkDefine.DisconnectType.recv_fail)
        return false
    end

    local receive = fullBytes or partBytes

    if #receive <= 0 then
        self.keepRecv = false
        return false
    else
        self.keepRecv = true
    end

    self.recvData =  self.recvData .. receive
    self.recvLen = self.recvLen + #receive

    self.frameRecvNum = self.frameRecvNum + 1

    if self.recvLen >= self.needRecvLen then
        self.recvLen = 0
        return true
    else
        return false
    end
end

function LTcpConn:OnDisconnect()
    if self.socket then
        self.socket:close()
        self.socket = nil
    end
   
    self.packList:Clear()
    self:ResetRecv()
    self.keepRecv = true
    self.sendList = {}
end

function LTcpConn:ResetRecv()
    self.recvState = RecvState.header
    self.needRecvLen = NetworkDefine.headerLen
    self.recvLen = 0
    self.recvData = ""
end