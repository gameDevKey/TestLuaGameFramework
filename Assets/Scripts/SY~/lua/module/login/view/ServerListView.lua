ServerListView = BaseClass("ServerListView",ExtendView)


function ServerListView:__Init()
    self.serverTabItems = {}
    self.selectTabIndex = 0

    self.serverNodeItems = {}
    self.selectNodeIndex = 0
end

function ServerListView:__Delete()

end

function ServerListView:__CacheObject()
    self.serverTabItem = self:Find("server_list_panel/Main/ServerTabScrollView/Mask/Content/Item").gameObject
    self.serverNodeItem = self:Find("server_list_panel/Main/ServerItemScrollView/Mask/Content/Item").gameObject
    self.serverRoleItem = self:Find("server_list_panel/Main/RoleItemScrollView/Mask/Content/Item").gameObject

    self.serverTabParent = self:Find("server_list_panel/Main/ServerTabScrollView/Mask/Content")
    self.serverNodeParent = self:Find("server_list_panel/Main/ServerItemScrollView/Mask/Content")
    self.serverRoleParent = self:Find("server_list_panel/Main/RoleItemScrollView/Mask/Content")
end

function ServerListView:GetPkInfoObject(objects,nodeName)
    local root = self:Find("main/pk_info/"..nodeName)
    objects.nameText = root:Find("name").gameObject:GetComponent(Text)
    objects.headIcon = root:Find("head").gameObject:GetComponent(CircleImage)
    objects.hpBar = root:Find("hp").gameObject:GetComponent(Image)
end

function ServerListView:__BindEvent()
end

function ServerListView:__Show()
end

function ServerListView:__Hide()
end

function ServerListView:RefreshServer()
    Log("进入刷新")
    self:RefreshServerTab()
end

function ServerListView:RefreshServerTab()
    for i,v in ipairs(self.serverTabItems) do
        GameObject.Destroy(v.item)
    end
    self.serverTabItems = {}

    local serverTabList = self:GetServerTabList()
    for i,v in ipairs(serverTabList) do
        local itemObjects = self:CreateServerTab()
        itemObjects.info = v
        itemObjects.item:SetActive(true)
        itemObjects.transform:SetParent(self.serverTabParent)
        itemObjects.transform:Reset()
        table.insert(self.serverTabItems,itemObjects)

        itemObjects.tabName.text = itemObjects.info.tabName
    end

    self:ServerTabClick(1)
end
function ServerListView:CreateServerTab()
    local item = GameObject.Instantiate(self.serverTabItem)
    local objects = {}
    objects.item = item
    objects.transform = item.transform
    objects.tabName = item.transform:Find("Text").gameObject:GetComponent(Text)
    return objects
end

function ServerListView:RefreshServerNode()
    for i,v in ipairs(self.serverNodeItems) do
        GameObject.Destroy(v.item)
    end
    self.serverNodeItems = {}

    local zoneId = self.serverTabItems[self.selectTabIndex].info.zoneId
    local serverList = mod.LoginProxy:GetServerList(zoneId)

    for i,v in ipairs(serverList) do
        local itemObjects = self:CreateServerNode()
        itemObjects.info = v
        itemObjects.item:SetActive(true)
        itemObjects.transform:SetParent(self.serverNodeParent)
        itemObjects.transform:Reset()
        table.insert(self.serverTabItems,itemObjects)

        itemObjects.btn:SetClick(self:ToFunc("ServerNodeClick"),itemObjects.info)
        itemObjects.serverNum.text = TI18N(itemObjects.info.server_id.." 服")
        itemObjects.serverName.text = TI18N(itemObjects.info.name)
    end
end
function ServerListView:CreateServerNode()
    local item = GameObject.Instantiate(self.serverNodeItem)
    local objects = {}
    objects.item = item
    objects.transform = item.transform
    objects.btn = item.gameObject:GetComponent(Button)
    objects.statusIcon = item.transform:Find("image_server_status").gameObject:GetComponent(Image)
    objects.serverNum = item.transform:Find("serverNumText").gameObject:GetComponent(Text)
    objects.serverName = item.transform:Find("serverNameText").gameObject:GetComponent(Text)
    return objects
end

function ServerListView:GetServerTabList()
    --后期通过协议从服务端获取，现在先确定写
    local serverTabList = {}
    table.insert(serverTabList,{tabIndex = 1,zoneId = 1,tabName = TI18N("测试服")})
    return serverTabList
end

function ServerListView:ServerTabClick(index)
    if self.selectTabIndex == index then
        return
    end

    self.selectTabIndex = index
    self:SelectServetTab(index)
    self:RefreshServerNode()
end

function ServerListView:SelectServetTab(index)
    for i,v in ipairs(self.serverTabItems) do
        local color = i == index and "ececec" or "EEE0C0"
        v.tabName.text = string.format("<color='#%s'>%s</color>",color,v.info.tabName)
    end
end

function ServerListView:ServerNodeClick(info)
    self.MainView:SwitchServer(info)
end