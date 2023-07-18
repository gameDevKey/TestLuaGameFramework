Network = SingletonClass("Network")

function Network:OnInit()

end

function Network:Send(proto,args)
    --TODO 压包发送
end

function Network:Recv(proto,args)
    --TODO 解包接收
    EventDispatcher.Global:Broadcast(EGlobalEvent.Proto,proto,args)
end

return Network