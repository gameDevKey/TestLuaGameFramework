UIBaseExtend = ExtendClass(UIBase)

local CS_UI = UnityEngine.UI

function UIBaseExtend:GetComponent(path, cmp, transform)
    transform = transform or self.transform
    if transform and path then
        transform = transform:Find(path)
    end
    if not transform then
        return
    end
    if not cmp then --不填cmp代表想获取transform
        return transform
    end
    return transform.gameObject:GetComponent(typeof(cmp))
end

function UIBaseExtend:GetGameObject(path, transform)
    local t = self:GetComponent(path, nil, transform)
    return t and t.gameObject
end

function UIBaseExtend:GetTransform(path, transform)
    return self:GetComponent(path, nil, transform)
end

function UIBaseExtend:GetCanvas(path, transform)
    return self:GetComponent(path, UnityEngine.Canvas, transform)
end

function UIBaseExtend:GetImage(path, transform)
    return self:GetComponent(path, CS_UI.Image, transform)
end

function UIBaseExtend:GetButton(path, transform)
    return self:GetComponent(path, CS_UI.Button, transform)
end

function UIBaseExtend:GetText(path, transform)
    return self:GetComponent(path, CS_UI.Text, transform)
end

function UIBaseExtend:GetRectTransform(path, transform)
    return self:GetComponent(path, CS_UI.Text, transform)
end

function UIBaseExtend:GetScrollRect(path, transform)
    return self:GetComponent(path, CS_UI.ScrollRect, transform)
end

return UIBaseExtend
