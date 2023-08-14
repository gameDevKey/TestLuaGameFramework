BloomSetter = BaseClass("BloomSetter",BaseSetter)

function BloomSetter:__Init()

end

function BloomSetter:__Delete()

end

function BloomSetter:OnLoad()
    self.setterVal = PlayerPrefsEx.GetInt(self.key,-1)
    if self.setterVal == -1 then
        self.setterVal = DevicesManager.Instance:HighThan(PerformanceDefine.DeviceLevel.high) and 1 or 0
    end
end

function BloomSetter:OnSetVal(val)
    self.setterVal = val and 1 or 0
    PlayerPrefsEx.SetInt(self.key,self.setterVal)
    self:Apply()
end

function BloomSetter:OnGetVal()
    return self.setterVal == 1
end

function BloomSetter:OnApply()
    --调用生效设置接口
end