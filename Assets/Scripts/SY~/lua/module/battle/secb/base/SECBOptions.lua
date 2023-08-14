SECBOptions = BaseClass("SECBOptions")

function SECBOptions:__Init()
    self.frameRate = 0
    self.frameDeltaTime = 0
    self.deltaTime = 0
    self.isClient = true

    self.clientWorldType = nil

    self.componentInitOrder = nil
    self.componentUpdateOrder = nil
    self.componentDelOrder = nil

    self.localRun = false
end

function SECBOptions:SetFrameRate(frameRate,frameDeltaTime)
    self.frameRate = frameRate
    self.frameDeltaTime = frameDeltaTime
    self.deltaTime = 1 / frameRate * 1000
end

function SECBOptions:IsClient()
    return self.isClient
end

function SECBOptions:SetClientWorldType(clientWorldType)
    self.clientWorldType = clientWorldType
end

function SECBOptions:SetClient(flag)
    self.isClient = flag
end

--queuues:{1,3,4,5,6}
function SECBOptions:SetComponentOrder(initOrder,updateOrder,delOrder)
    self.componentInitOrder = initOrder
    self.componentUpdateOrder = updateOrder
    self.componentDelOrder = delOrder
end