SimpleWindow = BaseClass("SimpleWindow",BaseWindow)
SimpleWindow.isWindow = true

function SimpleWindow:__Init()
	self.panelAssetPath = nil
	self.parentPath = "" --需要设置成正式的
	self.x = nil
	self.y = nil
	self.panel = nil
end

function SimpleWindow:__baseCreate()
    self:InitCreate()
    self.panel = self:GetObject(self.panelAssetPath)
    self.panel.transform:SetParent(self:Find(self.parentPath),false)
    self.panel.name = "panel"
    UnityUtils.SetLocalPosition(self.panel.transform,self.x or 0,self.y or 0,self.z or 0)
end

function SimpleWindow:SetParentInfo(path,x,y,z)
	if path then self.parentPath = path end
	if y then self.y = y end
	if x then self.x = x end
	if z then self.z = z end
end

function SimpleWindow:SetPanelAsset(file)
	assert(self.panelAssetPath == nil, "禁止多次设置附加面板资源路径")
	self.panelAssetPath = file
end

function SimpleWindow:__baseLoadAsset()
    assert(self.assetPath ~= nil, "UI资源路径为空，请调用SetAsset接口设置")
    assert(self.panelAssetPath ~= nil, "附加面板资源路径为空，请调用SetPanelAsset接口设置")
    self:MergeAsset()
    table.insert(self.assetList,{path = self.panelAssetPath, type = AssetType.Prefab})
end
