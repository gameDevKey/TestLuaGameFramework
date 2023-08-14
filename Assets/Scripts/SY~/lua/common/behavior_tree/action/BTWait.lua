BTWait = BaseClass("BTWait",BTAction)

function BTWait:__Init()
    self.waitTime = 0
end

function BTWait:__Delete()
end

function BTWait:OnStart()
    if self.params.isRandom then
        self.waitTime = Random.Range(self.params.waitTimeMin, self.params.waitTimeMax)
    else
        self.waitTime = self.params.waitTime
    end
end

function BTWait:OnUpdate(deltaTime)
    self.waitTime = self.waitTime - deltaTime
    return self.waitTime <= 0 and BTTaskStatus.Success or BTTaskStatus.Running
end