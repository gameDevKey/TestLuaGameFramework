EnterProcessCtrl = BaseClass("EnterProcessCtrl",Controller)
local tunpack = unpack or table.unpack
--必须准备的东西，都准备完了，才能进入游戏

function EnterProcessCtrl:__Init()
    self.lockNum = 0
    self.firstUnlock = true
    self.requestMsgs = {}
    self.requestMsgDict = {}
    self.lockMsgs = {}
end

function EnterProcessCtrl:__Delete()

end

function EnterProcessCtrl:__InitComplete()

end

function EnterProcessCtrl:__Clear()
    self.lockNum = 0
end

--设置SetLogin(false)时，调用一次
function EnterProcessCtrl:SetFirstUnlock(flag)
    self.firstUnlock = flag
end

function EnterProcessCtrl:AddLock(num)
    self.lockNum = self.lockNum + num
end

function EnterProcessCtrl:Unlock(num)
    self.lockNum = self.lockNum - num
    if self.lockNum <= 0 then
        self:UnlockComplete()
    end
end

function EnterProcessCtrl:UnlockComplete()
    Log("解锁完成了")
    self.firstUnlock = false
    ViewManager.Instance:CloseWindow(LoginWindow)
    mod.MainuiProxy.mainuiPanel:Show()
end

function EnterProcessCtrl:LoginComplete()
    mod.LoginProxy:SetLogin(true)
    self:ClearUnlockMsg()
    self:EnterRequest()
end

function EnterProcessCtrl:EnterRequest()
    --服务器返回协议结束后发10101
    self:AddLockMsg(10101,true)
    self:AddMsg(mod.RoleFacade,10100,false)
    --

    --各模块初始请求

    --开始向服务器发送协议
    for i,v in ipairs(self.requestMsgs) do
        self:xpcall(function() v.mod:SendMsg(v.msdId,tunpack(v.params)) end)
    end
    self.requestMsgs = {}
    self.requestMsgDict = {}


    if mod.ReconnectCtrl.reconnetFlag then
        mod.BattleCtrl:CheckReconnet()
    end
end

function EnterProcessCtrl:xpcall(call)
    local status, err = xpcall(call, function(errinfo)
        LogError("EnterProcessCtrl:EnterRequest报错了 " .. tostring(errinfo))
        LogError(debug.traceback())
    end)
    if not status then
        LogError("EnterProcessCtrl:EnterRequest报错了 " .. tostring(err))
    end
end

function EnterProcessCtrl:AddMsg(mod,msgId,isLock,...)
    if self.requestMsgDict[msgId] then
        assert(false,string.format("重复发送进入初始协议[msdId:%s]",msgId))
    end
    self.requestMsgDict[msgId] = true

    table.insert(self.requestMsgs,{mod = mod,msdId = msgId,params = {...}})
    self:AddLockMsg(isLock)
end

function EnterProcessCtrl:AddLockMsg(msgId,lock)
    if self.firstUnlock and lock then
        self.lockMsgs[msgId] = true
        Network.Instance:AddHandler(msgId,self:ToFunc("UnlockMsg"))
        self:AddLock(1)
    end
end

function EnterProcessCtrl:UnlockMsg(data,msgId)
    self.lockMsgs[msgId] = nil
    Network.Instance:RemoveHandler(msgId,self:ToFunc("UnlockMsg"))
    self:Unlock(1)
end

function EnterProcessCtrl:ClearUnlockMsg()
    for msgId,_ in pairs(self.lockMsgs) do
        Network.Instance:RemoveHandler(msgId,self:ToFunc("UnlockMsg"))
    end
    
    self.lockNum = 0
    self.requestMsgs = {}
    self.requestMsgDict = {}
    self.lockMsgs = {}
end