1.控件单独使用方式
    local anim1 = RotationLocalXAnim.New(self:Find("BtnEnterGame"),50,2)
    anim:Play()

2.播放器使用方式
    local anim1 = RotationLocalXAnim.New(self:Find("BtnEnterGame"),50,2)
    local anim2 = RotationLocalYAnim.New(self:Find("BtnEnterGame"),80,2)
    local animPlay = AnimPlay.New()
    animPlay:AddAnim(anim1,"anim1")
    animPlay:AddAnim(anim2,"anim2")
    animPlay:Play("anim1")

3.播放器加载配置使用方式
    local animPlay = AnimPlay.New()
    animPlay:LoadAnim("TestAnimConfig",self.transform)
    animPlay:PlayAll()