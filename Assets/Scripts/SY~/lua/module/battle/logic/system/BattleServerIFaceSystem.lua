BattleServerIFaceSystem = BaseClass("BattleServerIFaceSystem",SECBClientEntitySystem)
BattleServerIFaceSystem.NAME = "ServerIFaceSystem"

BattleServerIFaceSystem.callFunc = nil

function BattleServerIFaceSystem:__Init()
end

function BattleServerIFaceSystem:__Delete()

end

function BattleServerIFaceSystem:OnInitSystem()
    
end

function BattleServerIFaceSystem:OnLateInitSystem()
    
end

function BattleServerIFaceSystem.SetCallFunc(func)
    BattleServerIFaceSystem.callFunc = func
end

function BattleServerIFaceSystem:Call(eventType,roleUid,...)
    if IS_CHECK and self.callFunc then
        self.callFunc(eventType,self.world.uid,roleUid,...)
    end
end