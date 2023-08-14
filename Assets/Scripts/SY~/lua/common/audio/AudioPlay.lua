AudioPlay = BaseClass("AudioPlay")

function AudioPlay:__Init(parent,audioType)
    self.audioType = audioType
    self.single = false
    self.loop = false
    --self.sleepVolume = sleepVolume

    self.isMute = false
    self.volume = 1

    self.audioPlays = List.New()
    self.audioPool = {} --音源组件池

    self.sameDispose = AudioDefine.SameDispose.ignore

    self.gameObject = GameObject(self.audioType)
    self.gameObject.transform:SetParent(parent.transform)
    self.gameObject.transform:SetLocalPosition(0,0,0)
end

function AudioPlay:__Delete()

end

function AudioPlay:SetSingle(single)
    self.single = single
end

function AudioPlay:SetLoop(flag)
    self.loop = flag
end

-- function AudioPlay:SetSleepVolume(value)
--     self.sleepVolume = value
-- end

function AudioPlay:SetSameDispose(sameDispose)
    self.sameDispose = sameDispose
end

function AudioPlay:Play(uid,audioId,file)
    local flag = self:HasAudio(audioId)
    if flag and self.sameDispose == AudioDefine.SameDispose.ignore then
        return
    end

    if flag and not self.single and self.sameDispose == AudioDefine.SameDispose.replace then
        self:Stop(audioId)
    end

    if self.single then
        self:StopAll()
    end

    local audioInfo = table.remove(self.audioPool) or {}
    audioInfo.uid = uid
    audioInfo.audioId = audioId
    audioInfo.file = file
    audioInfo.audioLoader = AssetBatchLoader.New()
    audioInfo.timer = nil

    if not audioInfo.audioSource then
        audioInfo.audioSource = self:CreateAudioSource()
    end


    self.audioPlays:Push(audioInfo,audioInfo.uid)

    audioInfo.audioLoader:Load({{file = audioInfo.file,type = AssetType.AudioClip}},self:ToFunc("AudioLoaded"),audioInfo.uid)
end

function AudioPlay:AudioLoaded(uid)
    local iter = self.audioPlays:GetIterByIndex(uid)
    if iter then
        local audioInfo = iter.value
        audioInfo.audioSource.clip = audioInfo.audioLoader:GetAsset(audioInfo.file)
        AssetLoaderProxy.Instance:AddReference(audioInfo.file)

        audioInfo.audioSource:Play()

        if not self.loop then
            audioInfo.timer = TimerManager.Instance:AddTimerByNextFrame(1,audioInfo.audioSource.clip.length, self:ToFunc("OnPlayed"))
            audioInfo.timer:SetArgs(uid)
        end

        audioInfo.audioLoader:Destroy()
        audioInfo.audioLoader = nil
    end
end

function AudioPlay:CreateAudioSource()
    local audioSource = self.gameObject:AddComponent(AudioSource)
    audioSource.playOnAwake = false
    audioSource.volume = self.volume
    audioSource.mute = self.isMute
    audioSource.loop = self.loop
    return audioSource
end

function AudioPlay:HasAudio(audioId)
    for iter in self.audioPlays:Items() do
        if iter.value.audioId == audioId then
            return true
        end
    end
    return false
end

function AudioPlay:Stop(audioId)
    for iter in self.audioPlays:Items() do
        local audioInfo = iter.value
        if audioInfo.audioId == audioId then
            self:ClearAudio(audioInfo)
            self.audioPlays:Remove(iter)
        end
    end
end

function AudioPlay:StopAll()
    for iter in self.audioPlays:Items() do
        self:ClearAudio(iter.value)
    end
    self.audioPlays:Clear()
end

function AudioPlay:StopByUid(uid)
    local iter = self.audioPlays:GetIterByIndex(uid)
    if iter then
        self:ClearAudio(iter.value)
        self.audioPlays:Remove(iter)
    end
end

function AudioPlay:ClearAudio(audioInfo)
    if audioInfo.timer then
        TimerManager.Instance:RemoveTimer(audioInfo.timer)
        audioInfo.timer = nil
    end

    audioInfo.audioSource.clip = nil
    audioInfo.audioSource:Stop()
    
    AssetLoaderProxy.Instance:SubReference(audioInfo.file)
    table.insert(self.audioPool,audioInfo)
end

function AudioPlay:Pause()
    for _, audio in pairs(self.audioList) do 
        audio:Pause() 
    end
end

function AudioPlay:UnPause()
    for _, audio in pairs(self.audioList) do 
        audio:UnPause() 
    end
end

-- 音量
function AudioPlay:SetVolume(volume)
    self.volume = volume
    for iter in self.audioPlays:Items() do
        iter.value.volume = volume
    end
end

-- 静音
function AudioPlay:SetMute(flag)
    self.isMute = flag
    for iter in self.audioPlays:Items() do
        iter.value.mute = self.isMute
    end
end

--是否静音
function AudioPlay:IsMute()
    return self.isMute
end

function AudioPlay:ResetVolume()
    for audio in self.audioList:Items() do
        audio.value.volume = self.volume
    end
end

-- function AudioPlay:OnSleep()
--     if self.sleepVolume > self.volume then return end
--     for audio in self.audioList:Items() do
--         if audio.playing then audio.value.volume = self.sleepVolume end
--     end
-- end

--播放结束
function AudioPlay:OnPlayed(uid)
    self:StopByUid(uid)
end