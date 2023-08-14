BaseSetter = BaseClass("BaseSetter")

function BaseSetter:__Init()
    self.key = nil
    self.setterVal = nil
end

function BaseSetter:__Delete()

end

function BaseSetter:Init(key,...)
    self.key = key
    self:OnInit()
end

function BaseSetter:Load()
    self:OnLoad()
end

function BaseSetter:SetVal(val)
    self:OnSetVal(val)
end

function BaseSetter:GetVal()
    return self:OnGetVal()
end

function BaseSetter:Apply()
    self:OnApply()
end

--
function BaseSetter:OnInit()
end

function BaseSetter:OnLoad()
end

function BaseSetter:OnSetVal(val)
end

function BaseSetter:OnGetVal()
end

function BaseSetter:OnApply()
end