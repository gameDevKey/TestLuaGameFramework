BattlePluginSystem = BaseClass("BattlePluginSystem",SECBPluginSystem)
BattlePluginSystem.NAME = "PluginSystem"

function BattlePluginSystem:__Init()
end

function BattlePluginSystem:__Delete()

end

function BattlePluginSystem:OnInitSystem()

end

function BattlePluginSystem:OnInitPlugin()
    self:AddPlugin(CheckCondPlugin)
    self:AddPlugin(CalcAttrPlugin)
    self:AddPlugin(EntityFuncPlugin)
    self:AddPlugin(EntityStateCheckPlugin)
    self:AddPlugin(PasvActionPlugin)
    self:AddPlugin(SkillPlugin)
    self:AddPlugin(KeyDataCountPlugin)
    self:AddPlugin(BuffComponentPlugin)
end