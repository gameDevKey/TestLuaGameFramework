IconLoader = BaseClass("IconLoader")
IconLoader.poolKey = "icon_loader"

function IconLoader:__Init()
    self.isLoaded = false
    self.file = nil
    self.image = nil
end

function IconLoader:LoadIcon(image,file,nativeSize,callBack)
    if BaseUtils.IsNull(image) then 
        LogError("Icon加载异常,空的Image组件") 
        return 
    end

    if not file or file == "" then 
        LogError("Icon加载异常,路径为空") 
        return 
    end

    -- if image:GetType():ToString() ~= "UnityEngine.UI.Image" then
    --     LogError("Icon加载异常,错误的组件类型:"..tostring(image:GetType():ToString()))
    --     return
    -- end

    if self.isLoaded and self.file == file and self.image == image then
        self:Completed()
        return
    end

    --self.debug = debug.traceback()

    self:RemoveLoader()
    self:Releaser()
    
    self.isLoaded = false
    self.image = image
    self.file = file
    self.callBack = callBack
    self.nativeSize = nativeSize or false

    self.image.enabled = false

    self.assetLoader = AssetBatchLoader.New()
    self.assetLoader:Load({{file = self.file,loadMode = AssetLoadMode.PureSync,type = AssetType.Sprite}},self:ToFunc("AssetLoaded"))
end

function IconLoader:__Delete()
    self:OnReset()
end

function IconLoader:AssetLoaded()
    if BaseUtils.IsNull(self.image) then 
        self:RemoveLoader()
        LogErrorf( "icon加载完成,单位图片对象已经被删除了[%s]\n[%s]",self.file,self.debug)
        return
    end

    self.image.enabled = true
    
    self.isLoaded = true

    self.image.sprite = self.assetLoader:GetAsset(self.file)
    AssetLoaderProxy.Instance:AddReference(self.file)

    if self.nativeSize then 
        self.image:SetNativeSize() 
    end

    self:RemoveLoader()
    self:Completed()
end

function IconLoader:Completed()
    if self.callBack then 
        self.callBack(self.image) 
    end
end

function IconLoader:RemoveLoader()
    if self.assetLoader then 
        self.assetLoader:Destroy()
        self.assetLoader = nil 
    end
end

function IconLoader:OnReset()
    self.image = nil
    self.name = nil
    self.callBack = nil
    self:Releaser()
end

function IconLoader:Releaser()
    if not self.isLoaded or not self.file then 
        return
    end

    AssetLoaderProxy.Instance:SubReference(self.file)
    self.isLoaded = false
    self.file = nil
end

function IconLoader.Create()
    return PoolManager.Instance:Pop(PoolType.class,IconLoader.poolKey) or IconLoader.New() 
end