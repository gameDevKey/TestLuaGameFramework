BTConditional = BaseClass("BTConditional",BTTask)

function BTConditional:__Init()
    --self.invert = false
end

function BTConditional:__Delete()
end

function BTConditional:CheckCond(flag)
    flag =  self.params.invert and not flag or flag
    return flag and BTTaskStatus.Success or BTTaskStatus.Failure
end