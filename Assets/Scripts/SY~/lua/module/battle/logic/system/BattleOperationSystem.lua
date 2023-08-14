BattleOperationSystem = BaseClass("BattleOperationSystem",SECBOperationSystem)

function BattleOperationSystem:__Init()
    self.randomCostMoney = {}
end

function BattleOperationSystem:__Delete()
end

function BattleOperationSystem:OnInitSystem()
    self:BindOperation(BattleDefine.Operation.random_hero,self:ToFunc("RandomHero"))
    self:BindOperation(BattleDefine.Operation.update_hero,self:ToFunc("UpdateHero"))
    self:BindOperation(BattleDefine.Operation.extend_grid,self:ToFunc("ExtendGrid"))
    self:BindOperation(BattleDefine.Operation.swap_hero_grid,self:ToFunc("SwapHeroGrid"))
    self:BindOperation(BattleDefine.Operation.use_magic_card,self:ToFunc("UseMagicCard"))
end

function BattleOperationSystem:RandomHero(frame,data)
    --TODO:加入是否满足金币判断，不满足直接当作弊
    for i,v in ipairs(data.update_list) do
        self.world.BattleInputSystem:UnlockOp(v.operate_num)

        local costMoney = self.world.BattleDataSystem:GetRandomCostMoney(v.role_uid)
        local flag = self.world.BattleDataSystem:HasMoney(v.role_uid,costMoney)

        -- if not flag and v.role_uid == self.world.BattleDataSystem.roleUid then
        --     --非法,
        --     LogError("非法，随机单位金币不足")
        -- end

        local waitSelectUnits = v.choose_unit_list
        if #waitSelectUnits <= 0 then
            waitSelectUnits = self.world.BattleReserveUnitSystem:GetReserveSelectUnits(v.role_uid) or self:GetWaitSelectUnits(v.role_uid)
        end
        
        self.world.BattleDataSystem:SetWaitSelectUnits(v.role_uid,waitSelectUnits)

        self.world.BattleDataSystem:SetRandomMoney(v.role_uid,costMoney)
        self.world.BattleDataSystem:AddRoleMoney(v.role_uid,-costMoney)
        self.world.BattleDataSystem:AddRandomNum(v.role_uid,1)
        
        if v.role_uid == self.world.BattleDataSystem.roleUid and not self.world.BattleStateSystem.isReplay then
            self.world.ClientIFacdeSystem:Call("SendEvent","BattleSelectHeroView","RefreshSelectHero",waitSelectUnits)
            self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","random_unit")
        end
    end

    self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshMoney")
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshExtGrid")
end

function BattleOperationSystem:GetWaitSelectUnits(roleUid)
    local waitSelectUnits = {}
    local waitRandomUnits = self.world.BattleDataSystem:GetRandomUnits(roleUid)
    local existWaitRandomUnits = self.world.BattleDataSystem:GetRandomUnitsByExistUnit(roleUid)

    local curNotSelectNum = self.world.BattleDataSystem:GetCurNotSelectNum(roleUid)

    local heroNum = self.world.BattleDataSystem:GetHeroNum(roleUid)

    local randomConf = self.world.BattleConfSystem:PvpData_data_random_unit_info(self.world.BattleDataSystem.pvpConf.id,heroNum)

    local maxLockNum = randomConf and randomConf.max_lock_num or 0
    local existProb = randomConf and randomConf.exist_prob or 0

    local isExistRandom = false
    if maxLockNum > 0 and curNotSelectNum >= maxLockNum then
        isExistRandom = true
    elseif existProb > 0 then
        local probVal = existProb
        local value = self.world.BattleRandomSystem:Random(1,BattleDefine.AttrRatio)
        isExistRanom = value <= probVal
    end

    if isExistRandom then
        local index = self.world.BattleRandomSystem:Random(1,#existWaitRandomUnits)
        local unitId = existWaitRandomUnits[index]
        table.insert(waitSelectUnits,unitId)
        table.remove(existWaitRandomUnits,index)

        local removeIndex = nil
        for i,v in ipairs(waitRandomUnits) do
            if v == unitId then
                removeIndex = i
                break
            end
        end
        if removeIndex then
            table.remove(waitRandomUnits,removeIndex)
        end
    else
        local index = self.world.BattleRandomSystem:Random(1,#waitRandomUnits)
        table.insert(waitSelectUnits,waitRandomUnits[index])
        table.remove(waitRandomUnits,index)
    end

    for i=1,2 do
        local index = self.world.BattleRandomSystem:Random(1,#waitRandomUnits)
        table.insert(waitSelectUnits,waitRandomUnits[index])
        table.remove(waitRandomUnits,index)
    end

    -- local existUnit1 = self.world.BattleDataSystem:HasUnit(roleUid,waitSelectUnits[1])
    -- local existUnit2 = self.world.BattleDataSystem:HasUnit(roleUid,waitSelectUnits[2])

    -- if not flag or existUnit1 or existUnit2 then
    --     local index = self.world.BattleRandomSystem:Random(1,#waitRandomUnits)
    --     table.insert(waitSelectUnits,waitRandomUnits[index])
    -- else
    --     local lastWaitRandomUnits = self.world.BattleDataSystem:GetRandomUnitsByExclude(roleUid,waitSelectUnits[1],waitSelectUnits[2])
    --     local index = self.world.BattleRandomSystem:Random(1,#lastWaitRandomUnits)
    --     table.insert(waitSelectUnits,lastWaitRandomUnits[index])
    -- end

    return waitSelectUnits
end


function BattleOperationSystem:UpdateHero(frame,data)
    --TODO:加入是否满足金币判断，不满足直接当作弊
    for i,v in ipairs(data.update_list) do
        self.world.BattleInputSystem:UnlockOp(v.operate_num)

        if v.operate_type == BattleDefine.ServerOperation.select_hero then
            local randomMoney = self.world.BattleDataSystem:GetRandomMoney(v.role_uid)
            self.world.BattleDataSystem:AddHeroBuyMoney(v.role_uid,v.grid_list[1].unit_id,randomMoney)

            --TODO:加入单位是否在随机单位列表里的判断

            for _,info in ipairs(v.grid_list) do
                if info.unit_id ~= 0 then
                    local unitData = self.world.BattleDataSystem:GetUnitData(v.role_uid,info.unit_id)
                    local grid = info.grid_id
                    if grid == 0 then
                        grid = unitData and unitData.grid_id or self.world.BattleDataSystem:GetEnemyUnlockGird(v.role_uid)
                    else
                        if unitData and unitData.grid_id ~= info.grid_id then
                            assert(false,string.format("10403协议服务器数据异常,单位已存在,但是发来了新的格子[角色Uid:%s][单位Id:%s][已存在格子:%s][服务器发送格子:%s]"
                                ,v.role_uid,info.unit_id,unitData.grid_id,info.grid_id))
                        end
                    end

                    local star = unitData and unitData.star + 1 or 1
                    self.world.BattleMixedSystem:UpdateUnit(v.role_uid,info.unit_id,grid,star)
                end
            end

            if v.role_uid == self.world.BattleDataSystem.roleUid then
                self.world.BattleDataSystem:SetWaitSelectUnits(v.role_uid,nil)
            end
        elseif v.operate_type == BattleDefine.ServerOperation.extend_grid then
            --扣钱
            local costMoney = self.world.BattleDataSystem:GetExtendMoney(v.role_uid)
            local flag = self.world.BattleDataSystem:HasMoney(v.role_uid,costMoney)

            -- if not flag and v.role_uid == self.world.BattleDataSystem.roleUid then
            --     --非法
            --     LogError("非法，随机单位金币不足")
            -- end

            self.world.BattleDataSystem:AddRoleMoney(v.role_uid,-costMoney)
            self.world.BattleDataSystem:AddExtendNum(v.role_uid,1)

            for _,info in ipairs(v.grid_list) do
                self.world.BattleMixedSystem:ExtendGrid(v.role_uid,info.grid_id)
                if v.role_uid == self.world.BattleDataSystem.roleUid then
                    self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","PlayUnlockGrid",info.grid_id)
                    self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","unlock_grid",info.grid_id)
                elseif v.role_uid ~= self.world.BattleDataSystem.roleUid and not self.world.BattleStateSystem.isReplay then
                    self.world.ClientIFacdeSystem:Call("SendEvent","BattleEnemyGridView","RefreshGridUnlock")
                end
            end
        elseif v.operate_type == BattleDefine.ServerOperation.sell_hero then
            --TODO:1、检测是否存在，不存在就是外挂
            -- local needMoney = self.world.BattleDataSystem:GetExtendMoney(v.role_uid)
            -- local flag = self.world.BattleDataSystem:HasMoney(v.role_uid,needMoney)
            -- if not flag and v.role_uid == self.world.BattleDataSystem.roleUid then
            --     --非法
            --     LogError("非法，随机单位金币不足")
            -- end

            for _,info in ipairs(v.grid_list) do
                local addMoney = self.world.BattleDataSystem:GetHeroSellMoney(v.role_uid,info.grid_id,true)
                self.world.BattleDataSystem:AddRoleMoney(v.role_uid,addMoney)

                self.world.BattleMixedSystem:RemoveUnit(v.role_uid,info.grid_id)
            end

        elseif v.operate_type == BattleDefine.ServerOperation.swap_hero_grid then
            self.world.BattleMixedSystem:SwapUnit(v.role_uid,v.grid_list[1].grid_id,v.grid_list[2].grid_id)
        end
    end

    self.world.ClientIFacdeSystem:Call("RefreshHeroGrid",data.update_list[1].role_uid)
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshMoney")
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshExtGrid")
end

function BattleOperationSystem:ExtendGrid(frame,data)
    --TODO:加入是否满足金币判断，不满足直接当作弊
end

function BattleOperationSystem:SwapHeroGrid(frame,data)

end

function BattleOperationSystem:UseMagicCard(frame,data)
    for i,v in ipairs(data.frame_list) do
        self.world.BattleInputSystem:UnlockOp(v.operate_num)

        local useInfo = TableUtils.StringToTable(v.data)
        --LogTable("使用魔法卡了:"..v.role_uid,useInfo)
        local entity = self.world.EntitySystem:GetRoleCommander(v.role_uid)
        if entity then
            entity.SkillComponent:RelSkill(useInfo.skillId,useInfo.targets,useInfo.transInfo)

            local dragSkillInfo = self.world.BattleCommanderSystem:GetDragSkillInfo(v.role_uid,useInfo.skillId)
            local consume = dragSkillInfo.consume *(-1)
            self.world.BattleCommanderSystem:AddRage(v.role_uid,consume)
            dragSkillInfo.relNum = dragSkillInfo.relNum + 1
            if v.role_uid == self.world.BattleDataSystem.roleUid then
                self.world.ClientIFacdeSystem:Call("SendEvent","BattleCommanderDragSkillView","RefreshView")
            end
        end

        -- if v.role_uid == self.world.BattleDataSystem.roleUid and not self.world.BattleStateSystem.isReplay then
        --     self.world.BattleDataSystem:SetWaitSelectUnits(v.role_uid,nil)
        -- end

        -- if v.role_uid == self.world.BattleDataSystem.roleUid and not self.world.BattleStateSystem.isReplay then
        --     mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.use_magic_card)
        -- end
    end
end