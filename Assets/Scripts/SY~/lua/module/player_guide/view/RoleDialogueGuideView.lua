RoleDialogueGuideView = BaseClass("RoleDialogueGuideView",BaseView)

function RoleDialogueGuideView:__Init()
    self:SetAsset("ui/prefab/player_guide/role_dialogue_guide.prefab",AssetType.Prefab)
    self.closeTimer = nil
end

function RoleDialogueGuideView:__CacheObject()
    self.imgChilds = {}
    local imgRoot = self:Find("image").gameObject
    local childNum = imgRoot.transform.childCount
    for i = 0, childNum-1 do
        local child = imgRoot.transform:GetChild(i)
        table.insert(self.imgChilds, child.gameObject:GetComponent(Image))
    end
    self.imgRole = self:Find("img_role",Image)
    self.txtMsg = self:Find("msg",Text)
end

function RoleDialogueGuideView:__Show()
    self:SetSize()
    self:SetText()
    self:SetImages()
    self:ChangeRoleImage()
end

function RoleDialogueGuideView:SetSize()
    if self.args.width and self.args.height then
        self.rectTrans:SetSizeDelata(self.args.width,self.args.height)
    end
end

function RoleDialogueGuideView:ChangeRoleImage()
    local path = AssetPath.GetPlayerGuideIconPath(self.args.roleId)
    self:SetSprite(self.imgRole,path,true)
end

function RoleDialogueGuideView:SetText()
    self.txtMsg.text = self.args.text
    if self.args.textAlignCenter then
        self.txtMsg.alignment = TextAnchor.MiddleCenter
    else
        self.txtMsg.alignment = TextAnchor.MiddleLeft
    end
end

function RoleDialogueGuideView:GetComponentsFromCache(cacheTable, num)
    local list = {}
    local overnum = num
    for i, comp in ipairs(cacheTable or {}) do
        if i <= num then
            table.insert(list, comp)
            overnum = overnum - 1
            comp.gameObject:SetActive(true)
        else
            comp.gameObject:SetActive(false)
        end
    end
    -- TODO 组件不够用，是否需要实例化？
    -- for i = 1, overnum do
    -- end
    return list
end

function RoleDialogueGuideView:SetImages()
    local images = self.args.images or {}
    local len = #images
    if len <= 0 then return end

    local comps = self:GetComponentsFromCache(self.imgChilds, len)
    for i, info in ipairs(images) do
        local img = info.name
        assert(img,string.format("角色气泡消息引导界面在设置第%d个图片时未指定图片路径",i))
        local pos = info.pos or {x=0,y=0}
        local width = info.width or 0
        local height = info.height or 0
        local com = comps[i]
        if com then
            local path = AssetPath.GetPlayerGuideIconPath(img)
            if width <= 0 or height <= 0 then
                self:SetSprite(com,path,true)
            else
                self:SetSprite(com,path,false)
                UnityUtils.SetSizeDelata(com.transform, width, height)
            end
            UnityUtils.SetAnchoredPosition(com.transform, pos.x, pos.y)
        end
    end
end