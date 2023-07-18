local cmdA = Class("A",CommandBase)
function cmdA:Execute(args)
    print("执行命令A",args)
end
function cmdA:UnDo(args)
    print("回滚命令A",args)
end

local cmdB = Class("B",CommandBase)
function cmdB:Execute(args)
    print("执行命令B",args)
end
function cmdB:UnDo(args)
    print("回滚命令B",args)
end

CommandManager.Global:ExecuteCmd(cmdA.New(),"参数1")

CommandManager.Global:ExecuteCmd(cmdB.New(),"参数2")

CommandManager.Global:UnDoCmd("参数3")
CommandManager.Global:UnDoCmd("参数4")

CommandManager.Global:ReDoCmd("参数5")
CommandManager.Global:ReDoCmd("参数6")
CommandManager.Global:ReDoCmd("参数7")