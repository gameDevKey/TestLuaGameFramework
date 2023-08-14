CommanderAIBehavior = BaseClass("CommanderAIBehavior",SECBBehavior)

function CommanderAIBehavior:__Init()

end

function CommanderAIBehavior:__Delete()

end

function CommanderAIBehavior:OnUpdate()
    if self.world.BattleStateSystem:IsBattleState(BattleDefine.BattleState.solo_battle) then
        return
    end
    
    if not self.entity.StateComponent:CanSwitchState() then
        return
    end

    local skill,entitys = self.world.BattleCastSkillSystem:GetCastSkill(self.entity)
    if skill then
        self.entity.SkillComponent:RelSkill(skill.skillId,entitys)
    end
end