PveResultItem = BaseClass("PveResultItem", BaseView)

function PveResultItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function PveResultItem:__CacheObject()
    self.objInfoRoot = self:Find("main").gameObject
    self.imgIcon = self:Find("main/img_icon",Image)
    self.objSkillAct = self:Find("main/img_skill_tag").gameObject
    self.objSkillPass = self:Find("main/img_skill_tag_1").gameObject
    self.txtSkillAct = self:Find("main/img_skill_tag/txt_skill_tag",Text)
    self.txtSkillPass = self:Find("main/img_skill_tag_1/txt_skill_tag",Text)
    self.txtName = self:Find("main/image_16/txt_skill_name",Text)
end

function PveResultItem:__Create()
    self.txtSkillAct.text = TI18N("主")
    self.txtSkillPass.text = TI18N("被")
end

--[[
    data : PveData.data_pve_item[xx]
    data.isEmpty : 是否为空
]]--
function PveResultItem:SetData(data, index)
    self.data = data
    self.index = index
    self:RefreshStyle()
end

function PveResultItem:RefreshStyle()
    if self.data.isEmpty then
        self.objInfoRoot:SetActive(false)
    else
        self.objInfoRoot:SetActive(true)
        self.txtName.text = self.data.name
        if self.data.type == BattleDefine.pveItemEffectType.manual_skill then
            self.objSkillAct:SetActive(true)
            self.objSkillPass:SetActive(false)
        else
            self.objSkillAct:SetActive(false)
            self.objSkillPass:SetActive(true)
        end
        local iconPath = AssetPath.GetPveItemLongIcon(self.data.icon)
        self:SetSprite(self.imgIcon,iconPath)
    end
end

function PveResultItem:OnRecycle()
end

function PveResultItem.Create(template)
    local resultItem = PveResultItem.New()
    resultItem:SetObject(GameObject.Instantiate(template))
    resultItem:Show()
    return resultItem
end