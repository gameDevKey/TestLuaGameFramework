BTDecorator = BaseClass("BTDecorator",BTParentTask)

function BTDecorator:__Init()

end

function BTDecorator:__Delete()
end

function BTDecorator:MaxChildren()
    return 1
end