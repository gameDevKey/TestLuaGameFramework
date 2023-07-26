UIUtil = StaticClass("UIUtil")

---用UIPool获取UI
function UIUtil.CreateUIByPool(uiType,pathOrPrefab,ui,enterData,callback)
    local pool = CacheManager.Instance:GetPool(CacheDefine.PoolType.UI,true)
    local args = {
        callback = callback,
        args = {ui=ui,data=enterData}}
    if IsString(pathOrPrefab) then
        args.path = pathOrPrefab
    else
        args.prefab = pathOrPrefab
    end
    local cacheUI = pool:Get(uiType, args)
    ui:SetCacheHandler(cacheUI)
end

return UIUtil