--新手引导业务基类
GuideModuleBase = Class("GuideModuleBase", GameModuleBase)

function GuideModuleBase:OnInit()
end

function GuideModuleBase:OnDelete()
end

function GuideModuleBase:OnInitComplete()
end

function GuideModuleBase:Update(deltaTime)
    self:CallFuncDeeply("OnUpdate", true, deltaTime)
end

function GuideModuleBase:OnUpdate(deltaTime) end

return GuideModuleBase
