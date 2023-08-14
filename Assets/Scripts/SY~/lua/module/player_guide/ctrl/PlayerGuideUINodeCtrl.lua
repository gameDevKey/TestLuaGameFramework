PlayerGuideUINodeCtrl = BaseClass("PlayerGuideUINodeCtrl",Controller)

function PlayerGuideUINodeCtrl:__Init()
    self.nodes = {}
end

function PlayerGuideUINodeCtrl:__Delete()

end

function PlayerGuideUINodeCtrl:__InitComplete()

end

function PlayerGuideUINodeCtrl:InitDataComplete()

end

function PlayerGuideUINodeCtrl:CreateUI(name,rootTrans)
    --TODO:非新手状态屏蔽
    self.nodes[name] = rootTrans
end

function PlayerGuideUINodeCtrl:RemoveUI(name)
    if self.nodes[name] then
        self.nodes[name] = nil
    end
end

function PlayerGuideUINodeCtrl:GetUIObjByPathKey(pathKey)
    local data = PlayerGuideDefine.NodePath[pathKey]
    local node = self.nodes[data.name]
    if node then
        local result = node:Find(data.path)
        return result and result.gameObject
    end
end

function PlayerGuideUINodeCtrl:GetUIObj(path)
    if not path then
        return
    end
    for k,v in pairs(self.nodes) do
        local obj = v:Find(path)
        
        -- Log("查找",k,path)
        if obj then
            return obj.gameObject
        end
    end
end

