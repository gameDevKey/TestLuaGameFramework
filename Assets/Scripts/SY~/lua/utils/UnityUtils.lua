UnityUtils = UnityUtils or {}

function UnityUtils.SetPosition(transform,x,y,z)
    CustomUnityUtils.SetPosition(transform,x,y,z)
end

function UnityUtils.SetLocalPosition(transform,x,y,z)
    CustomUnityUtils.SetLocalPosition(transform,x,y,z)
end

function UnityUtils.SetLocalScale(transform,x,y,z)
    CustomUnityUtils.SetLocalScale(transform,x,y,z)
 end

function UnityUtils.SetEulerAngles(transform,x,y,z)
    CustomUnityUtils.SetEulerAngles(transform,x,y,z)
end

function UnityUtils.SetLocalEulerAngles(transform,x,y,z)
    CustomUnityUtils.SetLocalEulerAngles(transform,x,y,z)
end

function UnityUtils.SetAnchoredPosition(transform,x,y)
    CustomUnityUtils.SetAnchoredPosition(transform,x,y)
end

function UnityUtils.SetPivot(transform,x,y)
    CustomUnityUtils.SetPivot(transform,x,y)
end

function UnityUtils.SetAnchorMin(transform,x,y)
    CustomUnityUtils.SetAnchorMin(transform,x,y)
end

function UnityUtils.SetAnchorMax(transform,x,y)
    CustomUnityUtils.SetAnchorMax(transform,x,y)
end

function UnityUtils.SetAnchorMinAndMax(transform,min_x,min_y,max_x,max_y)
    CustomUnityUtils.SetAnchorMinAndMax(transform,min_x,min_y,max_x,max_y)
end

function UnityUtils.SetSizeDelata(transform,x,y)
    CustomUnityUtils.SetSizeDelata(transform,x,y)
end

function UnityUtils.SetColor(image,r,g,b,a)
    CustomUnityUtils.SetImageColor(image,r,g,b,a)
end

function UnityUtils.SetTextColor(text,r,g,b,a)
    CustomUnityUtils.SetTextColor(text,r,g,b,a)
end

function UnityUtils.SetActive(gameObject,active)
    CustomUnityUtils.SetActive(gameObject,active)
end

function UnityUtils.SetRotation(transform,x,y,z,w)
	CustomUnityUtils.SetRotation(transform,x,y,z,w)
end

function UnityUtils.CopyToCliboard(str)
    CS.UnityEngine.GUIUtility.systemCopyBuffer = str
end

function UnityUtils.GetFromCliboard()
    return CS.UnityEngine.GUIUtility.systemCopyBuffer
end