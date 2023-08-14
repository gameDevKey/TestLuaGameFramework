JumpCtrl = BaseClass("JumpCtrl",Controller)

function JumpCtrl:__Init()

end

function JumpCtrl:__Delete()

end

function JumpCtrl:__InitComplete()

end

function JumpCtrl:JumpTo(jumpId,...)
    local conf = Config.JumpData.data_jump_info[jumpId]
    if not jumpId then
        return
    end

    local info = JumpDefine.JumperMapping[conf.action.type]
    local class  = _G[info and info.class or nil]
    if not class then
        assert(false,string.format("未实现的跳转类型[跳转Id:%s][行为类型:%s]",jumpId,tostring(conf.action.type)))
    end

    local jumper = class.New()
    jumper:Init(jumpId,info,...)
    jumper:Start()
end

function JumpCtrl:ItemJumpWay(itemId)
    local conf = Config.ItemData.data_item_info[itemId]
    if #conf.jump_ways > 0 then
        ViewManager.Instance:OpenWindow(JumpWindow,conf.jump_ways)
        return true
    else
        return false
    end
end

function JumpCtrl:CheckItemNumJumpWay(itemId,itemNum)
    if not mod.RoleItemProxy:HasItemNum(itemId,itemNum) then
        return self:ItemJumpWay(itemId)
    end
    return false
end