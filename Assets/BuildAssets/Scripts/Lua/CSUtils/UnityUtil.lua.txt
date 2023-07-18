UnityUtil = StaticClass("UnityUtil")

function UnityUtil.FindGameObject(name)
    return GameObject.Find(name)
end

function UnityUtil.NewGameObject(name)
    return UnityEngine.GameObject(name)
end

function UnityUtil.LoadResources(path)
    return UnityEngine.Resources.Load(path)
end

function UnityUtil.Instantiate(prefab)
    return GameObject.Instantiate(prefab)
end

function UnityUtil.DestroyGameObject(gameObject)
    return GameObject.Destroy(gameObject)
end

function UnityUtil.IsEmptyGameObject(gameObject)
    return gameObject:IsNull()
end

function UnityUtil.SetAnchorMinAndMax(rectTransform, minX, minY, maxX, maxY)
    rectTransform.anchorMin = Vector2(minX, minY)
    rectTransform.anchorMax = Vector2(maxX, maxY)
end

function UnityUtil.SetPivot(rectTransform, x, y)
    rectTransform.pivot = Vector2(x, y)
end

function UnityUtil.SetAnchoredPosition(rectTransform, x, y)
    rectTransform.anchoredPosition = Vector2(x, y)
end

return UnityUtil