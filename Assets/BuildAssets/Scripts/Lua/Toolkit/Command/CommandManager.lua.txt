CommandManager = Class("CommandManager")

function CommandManager:OnInit()
    self.doCmds = {}
    self.unDoCmds = {}
end

function CommandManager:OnDelete()
    for _, list in ipairs({self.doCmds,self.unDoCmds}) do
        for _, cmd in ipairs(list) do
            cmd:Delete()
        end
    end
end

function CommandManager:ExecuteCmd(command, args)
    command:Execute(args)
    table.insert(self.doCmds, command)
end

--回滚到上一个命令
function CommandManager:UnDoCmd(args)
    if #self.doCmds == 0 then
        return
    end
    local cmd = table.remove(self.doCmds, #self.doCmds)
    cmd:UnDo(args)
    table.insert(self.unDoCmds,cmd)
end

--重做已回滚的上一个命令
function CommandManager:ReDoCmd(args)
    if #self.unDoCmds == 0 then
        return
    end
    local cmd = table.remove(self.unDoCmds, #self.unDoCmds)
    self:ExecuteCmd(cmd,args)
end

return CommandManager