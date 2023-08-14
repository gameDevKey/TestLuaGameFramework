SyncComponent = BaseClass("SyncComponent",SECBClientComponent)

function SyncComponent:__Init()

end

function SyncComponent:__Delete()
    
end

function SyncComponent:OnInit()

end

--同步一个出手的行为数据
function SyncComponent:SyncAction()

end

--延迟太多回合了，直接同步
function SyncComponent:SyncNewest()

end