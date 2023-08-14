TagComponent = BaseClass("TagComponent",SECBComponent)

function TagComponent:__Init()
    self.mainTag = BattleDefine.EntityTag.none
    self.subTag = BattleDefine.EntitySubTag.none
end

function TagComponent:__Delete()
end

function TagComponent:OnInit()

end

function TagComponent:SetTag(mainTag,subTag)
    if mainTag then
        self.mainTag = mainTag
    end

    if subTag then
        self.subTag = subTag
    end
end

function TagComponent:IsTag(mainTag,subTag)
    if mainTag and subTag then
        return self.mainTag == mainTag and self.subTag == subTag
    elseif mainTag and not subTag then
        return self.mainTag == mainTag
    elseif not mainTag and subTag then
        return self.subTag == subTag
    end
end