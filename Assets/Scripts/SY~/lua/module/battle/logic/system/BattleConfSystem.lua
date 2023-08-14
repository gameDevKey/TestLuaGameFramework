BattleConfSystem = BaseClass("BattleConfSystem",SECBEntitySystem)

function BattleConfSystem:__Init()
    self.cacheConf = {}
    self.isCache = false
end

function BattleConfSystem:__Delete()

end

function BattleConfSystem:OnInitSystem()

end

function BattleConfSystem:OnLateInitSystem()
    
end

function BattleConfSystem:SetCahceConf(cacheConf)
    self.isCache = true
    self.cacheConf = cacheConf
end

function BattleConfSystem:GetCacheConf()
    return self.cacheConf
end

function BattleConfSystem:PvpData_data_pvp(id)
    if self.isCache then
        return self:GetCacheConfig("PvpData","data_pvp",id)
    else
        local conf = Config.PvpData.data_pvp[id]
        self:AddCacheConfig("PvpData","data_pvp",id,conf)
        return conf
    end
end

function BattleConfSystem:PvpData_data_pvp_group(id,group)
    local key = id .."_" .. group
    if self.isCache then
        return self:GetCacheConfig("PvpData","data_pvp_group",key)
    else
        local conf = Config.PvpData.data_pvp_group[key]
        self:AddCacheConfig("PvpData","data_pvp_group",key,conf)
        return conf
    end
end

function BattleConfSystem:PvpData_data_pvp_buy_cost(id,count)
    local key = id .."_" .. count
    if self.isCache then
        return self:GetCacheConfig("PvpData","data_pvp_buy_cost",key)
    else
        local conf = Config.PvpData.data_pvp_buy_cost[key]
        self:AddCacheConfig("PvpData","data_pvp_buy_cost",key,conf)
        return conf
    end
end

function BattleConfSystem:PvpData_data_pvp_extend_cost(id,count)
    local key = id .."_" .. count
    if self.isCache then
        return self:GetCacheConfig("PvpData","data_pvp_extend_cost",key)
    else
        local conf = Config.PvpData.data_pvp_extend_cost[key]
        self:AddCacheConfig("PvpData","data_pvp_extend_cost",key,conf)
        return conf
    end
end

function BattleConfSystem:PvpData_data_random_unit_info(id,num)
    local key = id .."_" .. num
    if self.isCache then
        return self:GetCacheConfig("PvpData","data_random_unit_info",key)
    else
        local conf = Config.PvpData.data_random_unit_info[key]
        self:AddCacheConfig("PvpData","data_random_unit_info",key,conf)
        return conf
    end
end

function BattleConfSystem:PveData_data_pve(id)
    if self.isCache then
        return self:GetCacheConfig("PveData","data_pve",id)
    else
        local conf = Config.PveData.data_pve[id]
        self:AddCacheConfig("PveData","data_pve",id,conf)
        return conf
    end
end

function BattleConfSystem:PveData_data_pve_group(id,group)
    local key = id .."_" .. group
    if self.isCache then
        return self:GetCacheConfig("PveData","data_pve_group",key)
    else
        local conf = Config.PveData.data_pve_group[key]
        self:AddCacheConfig("PveData","data_pve_group",key,conf)
        return conf
    end
end

function BattleConfSystem:PveData_data_pve_monster(groupId,unitId)
    local key = groupId .."_" .. unitId
    if self.isCache then
        return self:GetCacheConfig("PveData","data_pve_monster",key)
    else
        local conf = Config.PveData.data_pve_monster[key]
        self:AddCacheConfig("PveData","data_pve_monster",key,conf)
        return conf
    end
end

function BattleConfSystem:PveData_data_pve_monsters(groupId)
    local key = groupId
    if self.isCache then
        return self:GetCacheConfig("PveData","data_pve_monsters",key)
    else
        local list = {}
        for _, conf in pairs(Config.PveData.data_pve_monster) do
            if conf.id == groupId then
                table.insert(list, conf)
            end
        end
        self:AddCacheConfig("PveData","data_pve_monsters",key,list)
        return list
    end
end

function BattleConfSystem:PveData_data_pve_item(groupId,itemId)
    local key = groupId.."_"..itemId
    if self.isCache then
        return self:GetCacheConfig("PveData","data_pve_item",key)
    else
        local conf = Config.PveData.data_pve_item[key]
        self:AddCacheConfig("PveData","data_pve_item",key,conf)
        return conf
    end
end

function BattleConfSystem:PveData_data_group_pve_item(groupId)
    local key = groupId
    if self.isCache then
        return self:GetCacheConfig("PveData","data_group_pve_item",key)
    else
        local conf = Config.PveData.data_group_pve_item[key]
        self:AddCacheConfig("PveData","data_group_pve_item",key,conf)
        return conf
    end
end

function BattleConfSystem:PveData_data_random_item(pveId,index)
    local key = pveId.."_"..index
    if self.isCache then
        return self:GetCacheConfig("PveData","data_random_item",key)
    else
        local conf = Config.PveData.data_random_item[key]
        self:AddCacheConfig("PveData","data_random_item",key,conf)
        return conf
    end
end

function BattleConfSystem:HeroData_data_hero_info(id)
    local key = id
    if self.isCache then
        return self:GetCacheConfig("HeroData","data_hero_info",key)
    else
        local conf = Config.HeroData.data_hero_info[key]
        self:AddCacheConfig("HeroData","data_hero_info",key,conf)
        return conf
    end
end

function BattleConfSystem:UnitData_data_unit_info(id)
    local key = id
    if self.isCache then
        return self:GetCacheConfig("UnitData","data_unit_info",key)
    else
        local conf = Config.UnitData.data_unit_info[key]
        self:AddCacheConfig("UnitData","data_unit_info",key,conf)
        return conf
    end
end

function BattleConfSystem:UnitData_data_unit_lev_info(id,lev)
    local key = id .."_" .. lev
    if self.isCache then
        return self:GetCacheConfig("UnitData","data_unit_lev_info",key)
    else
        local conf = Config.UnitData.data_unit_lev_info[key]
        self:AddCacheConfig("UnitData","data_unit_lev_info",key,conf)
        return conf
    end
end

function BattleConfSystem:UnitData_data_unit_star_info(id,star)
    local key = id .."_" .. star
    if self.isCache then
        return self:GetCacheConfig("UnitData","data_unit_star_info",key)
    else
        local conf = Config.UnitData.data_unit_star_info[key]
        self:AddCacheConfig("UnitData","data_unit_star_info",key,conf)
        return conf
    end
end

function BattleConfSystem:UnitData_data_kill_res(id,star)
    local key = id .."_" .. star
    if self.isCache then
        return self:GetCacheConfig("UnitData","data_kill_res",key)
    else
        local conf = Config.UnitData.data_kill_res[key]
        self:AddCacheConfig("UnitData","data_kill_res",key,conf)
        return conf
    end
end

function BattleConfSystem:SkillData_data_skill_base(id)
    if self.isCache then
        return self:GetCacheConfig("SkillData","data_skill_base",id)
    else
        local conf = Config.SkillData.data_skill_base[id]
        self:AddCacheConfig("SkillData","data_skill_base",id,conf)
        return conf
    end
end

function BattleConfSystem:SkillData_data_skill_lev(id,lev)
    local key = id .."_" .. lev
    if self.isCache then
        return self:GetCacheConfig("SkillData","data_skill_lev",key)
    else
        local conf = Config.SkillData.data_skill_lev[key]
        self:AddCacheConfig("SkillData","data_skill_lev",key,conf)
        return conf
    end
end

function BattleConfSystem:SkillData_data_pasv_info(id)
    if self.isCache then
        return self:GetCacheConfig("SkillData","data_pasv_info",id)
    else
        local conf = Config.SkillData.data_pasv_info[id]
        self:AddCacheConfig("SkillData","data_pasv_info",id,conf)
        return conf
    end
end

function BattleConfSystem:SkillData_data_target_cond(id)
    if self.isCache then
        return self:GetCacheConfig("SkillData","data_target_cond",id)
    else
        local conf = Config.SkillData.data_target_cond[id]
        self:AddCacheConfig("SkillData","data_target_cond",id,conf)
        return conf
    end
end

function BattleConfSystem:HitResultData_data_hit_result(id)
    if self.isCache then
        return self:GetCacheConfig("HitResultData","data_hit_result",id)
    else
        local conf = Config.HitResultData.data_hit_result[id]
        self:AddCacheConfig("HitResultData","data_hit_result",id,conf)
        return conf
    end
end


function BattleConfSystem:BuffData_data_buff_info(id)
    if self.isCache then
        return self:GetCacheConfig("BuffData","data_buff_info",id)
    else
        local conf = Config.BuffData.data_buff_info[id]
        self:AddCacheConfig("BuffData","data_buff_info",id,conf)
        return conf
    end
end


function BattleConfSystem:EventData_data_event_info(id)
    if self.isCache then
        return self:GetCacheConfig("EventData","data_event_info",id)
    else
        local conf = Config.EventData.data_event_info[id]
        self:AddCacheConfig("EventData","data_event_info",id,conf)
        return conf
    end
end

function BattleConfSystem:HaloData_data_halo_info(id,lev)
    local key = id .."_" .. lev
    if self.isCache then
        return self:GetCacheConfig("HaloData","data_halo_info",key)
    else
        local conf = Config.HaloData.data_halo_info[key]
        self:AddCacheConfig("HaloData","data_halo_info",key,conf)
        return conf
    end
end

function BattleConfSystem:CommanderData_data_base_info(id)
    if self.isCache then
        return self:GetCacheConfig("CommanderData","data_base_info",id)
    else
        local conf = Config.CommanderData.data_base_info[id]
        self:AddCacheConfig("CommanderData","data_base_info",id,conf)
        return conf
    end
end

function BattleConfSystem:CommanderData_data_star_info(id,star)
    local key = id .."_" .. star
    if self.isCache then
        return self:GetCacheConfig("CommanderData","data_star_info",key)
    else
        local conf = Config.CommanderData.data_star_info[key]
        self:AddCacheConfig("CommanderData","data_star_info",key,conf)
        return conf
    end
end

function BattleConfSystem:EffectData_data_skill_effect(id)
    if self.isCache then
        local conf = self:GetCacheConfig("EffectData","data_skill_effect",id)
        if not conf then conf = Config.EffectData.data_skill_effect[id] end
        return conf
    else
        local conf = Config.EffectData.data_skill_effect[id]
        self:AddCacheConfig("EffectData","data_skill_effect",id,conf)
        return conf
    end
end

function BattleConfSystem:HomeData_data_home_info(id)
    if self.isCache then
        return self:GetCacheConfig("HomeData","data_home_info",id)
    else
        local conf = Config.HomeData.data_home_info[id]
        self:AddCacheConfig("HomeData","data_home_info",id,conf)
        return conf
    end
end

function BattleConfSystem:DefenderData_data_defender_info(id)
    if self.isCache then
        return self:GetCacheConfig("DefenderData","data_defender_info",id)
    else
        local conf = Config.DefenderData.data_defender_info[id]
        self:AddCacheConfig("DefenderData","data_defender_info",id,conf)
        return conf
    end
end


function BattleConfSystem:BattleDungeonData_data_reserve_unit(id,camp,group,reserveIndex)
    local key = string.format("%s_%s_%s_%s",id,camp,group,reserveIndex)
    if self.isCache then
        return self:GetCacheConfig("BattleDungeonData","data_reserve_unit",key)
    else
        local conf = Config.BattleDungeonData.data_reserve_unit[key]
        self:AddCacheConfig("BattleDungeonData","data_reserve_unit",key,conf)
        return conf
    end
end

function BattleConfSystem:BattleDungeonData_data_random_unit(id,camp,num,index)
    local key = string.format("%s_%s_%s_%s",id,camp,num,index)
    if self.isCache then
        return self:GetCacheConfig("BattleDungeonData","data_random_unit",key)
    else
        local conf = Config.BattleDungeonData.data_random_unit[key]
        self:AddCacheConfig("BattleDungeonData","data_random_unit",key,conf)
        return conf
    end
end


function BattleConfSystem:SkillTimeline(id)
    if self.isCache then
        return self:GetCacheConfig("SkillTimeline","data",id)
    else
        local config = Config["Skill"..tostring(id)]
        self:AddCacheConfig("SkillTimeline","data",id,config)
        return config
    end
end

function BattleConfSystem:DeadTimeline(id)
    if self.isCache then
        return self:GetCacheConfig("DeadTimeline","data",id)
    else
        local config = Config["Dead"..tostring(id)]
        self:AddCacheConfig("DeadTimeline","data",id,config)
        return config
    end
end

function BattleConfSystem:BornTimeline(id)
    if self.isCache then
        return self:GetCacheConfig("BornTimeline","data",id)
    else
        local config = Config["Born"..tostring(id)]
        self:AddCacheConfig("BornTimeline","data",id,config)
        return config
    end
end

function BattleConfSystem:AIBehaviorTree(id)
    if self.isCache then
        return self:GetCacheConfig("AIBehaviorTree","data",id)
    else
        local config = Config["Ai"..tostring(id)]
        self:AddCacheConfig("AIBehaviorTree","data",id,config)
        return config
    end
end

function BattleConfSystem:AddCacheConfig(confName,dataName,key,conf)
    if not self.cacheConf[confName] then
        self.cacheConf[confName] = {}
    end
    if not self.cacheConf[confName][dataName] then
        self.cacheConf[confName][dataName] = {}
    end
    if not self.cacheConf[confName][dataName][key] then
        self.cacheConf[confName][dataName][key] = conf
    end
end

function BattleConfSystem:GetCacheConfig(confName,dataName,key)
    if not self.cacheConf[confName] or not self.cacheConf[confName][dataName] then
        return nil
    else
        return self.cacheConf[confName][dataName][key]
    end
end