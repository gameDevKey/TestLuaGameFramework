AnimUtils = SingleClass("AnimUtils")

function AnimUtils.CreateAnim(root,animData,nodes,animNodes,onCreate)
    if not animData then return nil end
    local animClass = GetClass(animData.class)
    local anim = animClass.Create(root,animData,nodes,animNodes)
    anim:BaseCreate(animData)
    if animData.name then 
        animNodes[animData.name] = anim
        anim:SetId(animData.name)
    end
    return anim
end

function AnimUtils.GetComponent(transform,path,cType)
    local object = transform:Find(path)
    assert(object,string.format("无法找到节点[%s]",path))
    if not cType then return object end

    local component = object.gameObject:GetComponent(cType)
    assert(component,string.format("无法获取组件类型[%s]",tostring(cType)))
    return component
end