AudioManager = SingleClass("AudioManager")

function AudioManager:__Init()
    self.uid = 0
    self.audioRecords = {}
    self.audioPlays = {}

    self.OnPlayButtonClick = self:ToFunc("PlayButtonClick")

    self:InitAudio()
end

function AudioManager:__Delete()
end

function AudioManager:InitAudio()
    self.audioParent =  GameObject("Audio")
    self.audioParent.transform:SetLocalPosition(0,0,0)
    GameObject.DontDestroyOnLoad(self.audioParent)

    for k,v in pairs(AudioDefine.AudioType) do
        local audioType = k
        local setting = AudioDefine.AudioPlaySetting[audioType]
        local audioPlay = AudioPlay.New(self.audioParent,audioType)
        audioPlay:SetSingle(setting.single)
        audioPlay:SetLoop(setting.loop)
        audioPlay:SetSameDispose(setting.sameDispose)
        audioPlay:SetVolume(setting.volume)
        self.audioPlays[k] = audioPlay
    end
end

function AudioManager:PlayBgm(audioId)
    if not audioId then
        return
    end
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        return
    end

    local uid = self:GetUid()
    local file = AssetPath.GetAudioByBgm(audioId)
    self:AudioRecord(audioId,file)

    local audioPlay = self.audioPlays[AudioDefine.AudioType.bgm]
    audioPlay:Play(uid,audioId,file)
end

function AudioManager:StopBgm()
    local audioPlay = self.audioPlays[AudioDefine.AudioType.bgm]
    audioPlay:StopAll()
end

function AudioManager:PlayUI(audioId)
    if not audioId then
        return 
    end
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        return
    end

    local uid = self:GetUid()
    local file = AssetPath.GetAudioByUI(audioId)
    self:AudioRecord(audioId,file)

    local audioPlay = self.audioPlays[AudioDefine.AudioType.ui]
    audioPlay:Play(uid,audioId,file)
end

function AudioManager:PlayButtonClick(audioId)
    self:PlayUI(audioId)
end

function AudioManager:PlaySkill(audioId)
    if not audioId then
        return
    end
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        return
    end

    local uid = self:GetUid()
    local file = AssetPath.GetAudioByGroup(audioId)
    self:AudioRecord(audioId,file)

    local audioPlay = self.audioPlays[AudioDefine.AudioType.skill]
    audioPlay:Play(uid,audioId,file)
end

--音频加载后不进行释放了
function AudioManager:AudioRecord(audioId,file)
    if not self.audioRecords[audioId] then
        self.audioRecords[audioId] = true
        AssetLoaderProxy.Instance:SetReleaseTime(file,0)
    end
end

function AudioManager:GetUid()
    self.uid = self.uid + 1
    return self.uid
end