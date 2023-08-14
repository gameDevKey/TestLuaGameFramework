BaseUtils = BaseUtils or {}

function BaseUtils.IsNull(value)
    return value == nil or ( type(value)=="userdata" and value:Equals(nil))
end

function BaseUtils.SetActive(transform,active)
    if IS_EDITOR then
        UnityUtils.SetActive(transform.gameObject,active)
    else
        transform.gameObject:SetActive(active)
    end
end

function BaseUtils.FindListIndex(list,value,attrName)
	if not list then return nil end
	for i,v in ipairs(list) do
		if attrName == nil then
			if v == value then return i end
		else
			if v[attrName] ==  value then return i end
		end
    end
    
end

function BaseUtils.GetVector3()
    return  PoolManage.Instance:Pop(PoolType.class,PoolDefine.PoolKey.vector3) or Vector3()
end

function BaseUtils.GetVector2()
    return  PoolManage.Instance:Pop(PoolType.class,PoolDefine.PoolKey.vector2) or Vector2()
end

function BaseUtils.ChangeLayers(gameObject,layer, onlySelf)
    gameObject.layer = layer
    if not onlySelf then
        local transform = gameObject.transform
        local childCount = transform.childCount
        if childCount <= 0 then return end
        for i=1,childCount do BaseUtils.ChangeLayers(transform:GetChild(i-1).gameObject,layer) end
    end
end

function BaseUtils.RangeObjByLayer(gameObject, callback, layer, maxLayer)
    if not gameObject or not callback or (maxLayer and layer > maxLayer) then
        return
    end
    callback(gameObject)
    local transform = gameObject.transform
    local childCount = transform.childCount
    for i=1,childCount do
        local childObj = transform:GetChild(i-1).gameObject
        BaseUtils.RangeObjByLayer(childObj, callback, layer+1, maxLayer)
    end
end

function BaseUtils.RangeObj(gameObject, callback, maxLayer)
    BaseUtils.RangeObjByLayer(gameObject, callback, 0, maxLayer)
end

local vec2 = nil
if not IS_CHECK then
    vec2 = Vector2()
end
function BaseUtils.WorldToUIPoint(camera,point)
    local worldScreenPos = camera:WorldToScreenPoint(point)
    vec2:Set(worldScreenPos.x, worldScreenPos.y)
    local _,pos = RectTransformUtility.ScreenPointToLocalPointInRectangle(UIDefine.canvasRoot, vec2, UIDefine.uiCamera)
    return Vector3(pos.x, pos.y,0)
end

function BaseUtils.WorldToScreenPoint(camera,point)
    local worldScreenPos = camera:WorldToScreenPoint(point)
    vec2:Set(worldScreenPos.x, worldScreenPos.y)
    return vec2
end

function BaseUtils.FindTableIndex(table,value)
    for i,v in ipairs(table) do
        if v == value then return i end
    end
end

local color = nil
if not IS_CHECK then
    color = Color(1,1,1,1)
end
function BaseUtils.GetColor(r,g,b,a)
	color.r = r
	color.g = g
	color.b = b
	color.a = a
	return color
end

function BaseUtils.GetAnimatorClipTime(animator,animName)
    local animTime = 1.0
    if animator and animator.runtimeAnimatorController then
        local clips = animator.runtimeAnimatorController.animationClips
        for i = 0, clips.Length - 1 do
            local clip = clips[i]
            if clip.name == animName then
                animTime = clip.length
                break
            end
        end
    end
    return animTime
end


-- 设置对象及子对象的sortingOrder
function BaseUtils.SetOrder(go, order)
    local renders = go:GetComponentsInChildren(Renderer, true)
    for i = 0, renders.Length - 1 do renders[i].sortingOrder = order end
end

function BaseUtils.SetFullSize(rectTrans)
    local width = Screen.width
    local height = Screen.height
    local designWidth = 1280
    local designHeight = 720
    local s1 = designWidth / designHeight
    local s2 = width / height

    if s1 < s2 then
        designWidth = math.floor(designHeight * s2)
    elseif s1 > s2 then
        designHeight =  math.floor(designWidth / s2)
    end

    UnityUtils.SetSizeDelata(rectTrans,designWidth,designHeight)
end

function BaseUtils.ToStringEx(value)
    if type(value)=='table' then
       return BaseUtils.TableToStr(value)
    elseif type(value)=='string' then
        return "\""..value.."\""
    else
       return tostring(value)
    end
end

function BaseUtils.TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..BaseUtils.ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..BaseUtils.ToStringEx(key).."]="..BaseUtils.ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..BaseUtils.ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..BaseUtils.ToStringEx(value)
                end
            end
        end

        i = i+1
    end

    retstr = retstr.."}"
    return retstr
end


function BaseUtils.SetDepthTextureMode(camera)
    camera.depthTextureMode = DepthTextureMode.Depth
    --BitUtil:Or(camera.depthTextureMode, DepthTextureMode.Depth)
end


function BaseUtils.GetEmptyObject()
    return PoolManager.Instance:Pop(PoolType.object,PoolDefine.PoolKey.empty_object) or GameObject()
end

function BaseUtils.PushEmptyObject(object)
    PoolManager.Instance:Push(PoolType.object,PoolDefine.PoolKey.empty_object,object)
end


function BaseUtils.GetBoneName(bone,customBone)
    local boneName = nil
    if bone == GDefine.Bone.custom then
        boneName = customBone
    else
        boneName = GDefine.BoneIndex[bone]
    end
    return boneName
end

function BaseUtils.ScreenToWorldPoint(camera,pos)
    return camera:ScreenToWorldPoint(Vector3(pos.x,pos.y,0))
end

function BaseUtils.ScreenPointToRay(camera,pos)
    return camera:ScreenPointToRay(Vector3(pos.x,pos.y,0))
end