CommanderProxy = BaseClass("CommanderProxy",Proxy)

function CommanderProxy:__Init()
    self.commanderInfos = nil
end 

function CommanderProxy:__InitProxy()
    self:BindMsg(11000) --匹配成功
end


--统领信息
function CommanderProxy:Recv_11000(data)
    LogTable("接收11000",data)
    self.commanderInfos = data.info
    mod.CommanderFacade:SendEvent(CommanderFacade.Event.RefreshCommanderAttr,true)
end

function CommanderProxy:GetModeData(modeType)
    for k,v in pairs(self.commanderInfos.part_info_list) do
        if v.type == modeType then
            return v
        end
    end
end

function CommanderProxy:GetCommanderUnitId()
    return self.commanderInfos.unit_id
end

function CommanderProxy:GetModeAttr(modeType,attrType)
    local data = self:GetModeData(modeType)
    for i,v in ipairs(data.attr_list) do
        if v.attr_id == attrType then
            return v.attr_val
        end
    end
end

function CommanderProxy:GetModeAttrList(modeType)
    local attrList = {}
    local data = self:GetModeData(modeType)
    for i,v in ipairs(data.attr_list) do
        if v.attr_id ~= GDefine.Attr.battle_power 
            and v.attr_id ~= GDefine.Attr.move_speed then
            table.insert(attrList,v)
        end
    end
    return attrList
end