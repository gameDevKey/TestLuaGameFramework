--控制器基类，会在游戏启动前自动加载
--处理业务逻辑，以及界面交互逻辑
--函数InitComplete()会在Facade安装完成后自顶向下被调用
CtrlBase = Class("CtrlBase", ModuleBase)

function CtrlBase:OnInitComplete()
    self.registerUpdate = nil
end

---动态开关Update，Ctrl类不宜随便使用Update，用了要及时关闭
---@param active boolean
function CtrlBase:ActiveUpdate(active)
    if active then
        self:RegisterUpdate()
    else
        self:UnregisterUpdate()
    end
end

function CtrlBase:RegisterUpdate()
    if self.registerUpdate then
        return
    end
    self.registerUpdate = UpdateManager.Instance:Register(self:ToFunc("Update"))
end

function CtrlBase:UnregisterUpdate()
    if self.registerUpdate then
        UpdateManager.Instance:Unregister(self.registerUpdate)
        self.registerUpdate = nil
    end
end

function CtrlBase:Update(deltaTime)
    self:CallFuncDeeply("OnUpdate", true, deltaTime)
end

function CtrlBase:OnUpdate(deltaTime) end

return CtrlBase
