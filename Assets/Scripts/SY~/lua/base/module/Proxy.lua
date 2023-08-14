Proxy = BaseClass("Proxy",BaseModule)
Proxy.__proxy = true

function Proxy:__Init()
    self.idToNetwork = {}
    self.sendFuns={}
    self.recvFuns={}
    self:__InitProxy()
end

function Proxy:BindMsg(id,isResend,network)
    if network then
        self.idToNetwork[id] = network
    else
        network = Network.Instance
    end

    network:AddHandler(id,self:ToFunc("_RecvMsg"),isResend)

    self.module:BindMsg(id,self:ToFunc("_SendMsg"))
    self.sendFuns[id] = "Send_"..id
    self.recvFuns[id] = "Recv_"..id
end

function Proxy:RemoveMsg(id)
    local network = self.idToNetwork[id] or Network.Instance
    network:RemoveHandler(id)
    self.module:RemoveMsg(id)
end

function Proxy:_SendMsg(msgId,...)
    local network = self.idToNetwork[id] or Network.Instance
    local funName = self.sendFuns[msgId]
    local data = nil
    if self[funName] then data = self[funName](self,...) end
    network:Send(msgId,data)
end

function Proxy:_RecvMsg(data,msgId)
    local funName = self.recvFuns[msgId]
    if self[funName] then 
        self[funName](self,data,msgId)
    end
end

--虚函数
function Proxy:__InitProxy() end
function Proxy:__InitComplete() end
function Proxy:__Clear() end