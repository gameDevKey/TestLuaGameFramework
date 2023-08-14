GmWindow = BaseClass("GmWindow",BaseWindow)

function GmWindow:__Init()
    --self["DebugMap"](self)
    self:SetAsset("ui/prefab/gm/gm_main_window.prefab", AssetType.Prefab)

    self.starDesctar={}
    self.itemDesctar={}
    self.SeletItem={}
    self.HisItem={}
    self.BtnTypes={}
    self.isOpenHistory = false
end

function GmWindow:__CacheObject()
    self.ItemHistory=self:Find("main/groupmsg/group_history/Scroll View/Viewport/Content/gm_item").gameObject
    self.ItemGm=self:Find("main/groupmsg/group_item/Viewport/Content/gm_item").gameObject
    self.GmScrollView=self:Find("main/groupmsg/group_item/Viewport/Content")
    self.TypeGrid=self:Find("main/groupmsg/groupstype/Viewport/Content/gm_typeItem").gameObject
    self.TypeScrollView=self:Find("main/groupmsg/groupstype/Viewport/Content")
    self.GroupItem=self:Find("main/groupmsg/group_item").gameObject
    self.GroupHistory=self:Find("main/groupmsg/group_history").gameObject
    self.HistoryBtn=self:Find("main/groupmsg/group_input/Button").gameObject
    self.HistoryScrollView=self:Find("main/groupmsg/group_history/Scroll View/Viewport/Content")
    self.InputSend=self:Find("main/groupmsg/group_input/InputField").gameObject:GetComponent(InputField)
end

function GmWindow:__BindListener()
    self:Find("main/groupmsg/btn_close",Button):SetClick(self:ToFunc("CloseClick"))
    self:Find("main/groupmsg/groups_type/Button1",Button):SetClick(self:ToFunc("BtnRoutineClick"))
    self:Find("main/groupmsg/groups_type/Button2",Button):SetClick(self:ToFunc("BtnServerClick"))
    self:Find("main/groupmsg/groups_type/Button3",Button):SetClick(self:ToFunc("BtnClientClick"))
    self:Find("main/groupmsg/group_input/Button",Button):SetClick(self:ToFunc("HistoryClick"))
    self:Find("main/groupmsg/group_input/btn_send",Button):SetClick(self:ToFunc("SendToSever"))
end

function GmWindow:__Show()
    self:BtnRoutineClick()
    self:SetOther()
end

function GmWindow:SetOther()
    self.GroupHistory:SetActive(false)
end

function GmWindow:SetScroll()
    UnityUtils.SetLocalPosition(self.HistoryScrollView.transform,0,0)
    UnityUtils.SetLocalPosition(self.GmScrollView.transform,0,0)
    UnityUtils.SetLocalPosition(self.TypeScrollView.transform,0,0)
end

function GmWindow:BtnRoutineClick()
    self.SetScroll(self)
    self:RefreshTab(GmDefine.FromType.conf,mod.GmProxy.confGmData)
    for k,v in pairs(mod.GmProxy.confGmData) do
        self:RefreshCmd(GmDefine.FromType.conf,v)
        break
    end
end

function GmWindow:BtnServerClick()
    self.SetScroll(self)
    self:RefreshTab(GmDefine.FromType.server,mod.GmProxy.serverGmData,mod.GmProxy.serverGmOrder)
    for k,v in pairs(mod.GmProxy.serverGmData) do
        self:RefreshCmd(GmDefine.FromType.server,v)
        break
    end
end

function GmWindow:BtnClientClick()
    self.SetScroll(self)
    self:RefreshTab(GmDefine.FromType.client,GmDefine.gmList)
    for k,v in pairs(GmDefine.gmList) do
        self:RefreshCmd(GmDefine.FromType.client,v)
        break
    end
end

function GmWindow:ClearTypeItems()
    for key, value in pairs(self.starDesctar) do
        GameObject.Destroy(value)
    end
    self.starDesctar={}
end

function GmWindow:Clearitems()
    for key, value in pairs(self.itemDesctar) do
        GameObject.Destroy(value.obj)
    end
    self.itemDesctar={}
end

function GmWindow:ClearHistoryItems()
    for key, value in pairs(self.HisItem) do
        GameObject.Destroy(value)
    end
    self.HisItem={}
end

function GmWindow:RefreshTab(fromType,gmData,orderMap)
    self:ClearTypeItems()
    local list = {}
    local order = 0
    for k,gmList in pairs(gmData) do
        table.insert(list, {
            gmList = gmList,
            type = k,
            order = orderMap and orderMap[k] or order
        })
        order = order + 1
    end
    table.sort(list, function (a, b)
        return a.order < b.order
    end)
    for i,sc in ipairs(list) do
        local gmList = sc.gmList
        local type = sc.type
        local item = GameObject.Instantiate(self.TypeGrid)
        item.transform:SetParent(self.TypeScrollView)
        item.gameObject:SetActive(true)
        item.transform:Reset()
        item.transform:Find("text").gameObject:GetComponent(Text).text = type
        item.transform:Find("btn_type").gameObject:GetComponent(Button):SetClick(self:ToFunc("SwitchClick"),fromType,gmList)
        table.insert(self.starDesctar,item.gameObject)
    end
end

function GmWindow:RefreshCmd(fromType,gmList)
    self:Clearitems()
    for i,v in ipairs(gmList) do
        local item = GameObject.Instantiate(self.ItemGm)
        item.transform:SetParent(self.GmScrollView)
        item.gameObject:SetActive(true)
        item.transform:Reset()

        item.transform:Find("text").gameObject:GetComponent(Text).text = v.notes
        input = item.transform:Find("InputField").gameObject:GetComponent(InputField)
        local btn = item.transform:Find("btn_enter").gameObject:GetComponent(Button)



        if fromType == GmDefine.FromType.conf then
            btn:SetClick(self:ToFunc("ConfHandle"),v,i)
        elseif fromType == GmDefine.FromType.server then
            btn:SetClick(self:ToFunc("ServerHandle"),v,i)
        else
            btn:SetClick(self:ToFunc("ClientHandle"),v,i)
        end

        table.insert(self.itemDesctar,{input = input,obj = item.gameObject} )
    end
end

function GmWindow:SwitchClick(fromType,gmList)
    self:RefreshCmd(fromType,gmList)
end

function GmWindow:ConfHandle(data,index)
    local item = self.itemDesctar[index]
    local msg = string.format(data.command,item.input.text)

    mod.GmFacade:SendMsg(10106,msg)
    table.insert(self.SeletItem,{fromType = GmDefine.FromType.conf,data = data})
end

function string.split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end

    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function GmWindow:ServerHandle(data,index)
    local item = self.itemDesctar[index]
    local msg = nil
    local aryModel = string.split(data.content, " ")
    msg=data.content
    if  #aryModel == 2 then
        msg = aryModel[1].." "..item.input.text
    end
    mod.GmFacade:SendMsg(10106,msg)
    table.insert(self.SeletItem,{fromType = GmDefine.FromType.server,data = data})
end

function GmWindow:Split(input, delimiter)
    local arr = {}
    string.gsub(input, '[^' .. delimiter ..']+', function(w) table.insert(arr, w) end)
    return arr
end

function GmWindow:ClientHandle(data,index)
    local item = self.itemDesctar[index]

    local inputText = item.input.text
    local inputInfos = string.split(inputText, " ") or {}
    local inputArgs = {}
    for i,v in ipairs(inputInfos) do
        table.insert(inputArgs,v)
    end

    local infos = self:Split(data.func,".")
    local ctrlName = infos[1]
    local funName = infos[2]

    local ctrl = mod[ctrlName]
    ctrl[funName](ctrl,inputArgs)

    table.insert(self.SeletItem,{fromType = GmDefine.FromType.client,data = data})
end

function GmWindow:CloseClick()
    ViewManager.Instance:CloseWindow(GmWindow)
end

function GmWindow:HistoryClick()
    self.isOpenHistory = not self.isOpenHistory
    self.GroupHistory:SetActive(self.isOpenHistory)
    if self.isOpenHistory then
        self:RefreshHistory()
        UnityUtils.SetSizeDelata(self.GroupItem.gameObject.transform,485.5,455)
    else
        UnityUtils.SetSizeDelata(self.GroupItem.gameObject.transform,485.5,957)
    end
end

function GmWindow:RefreshHistory()
    self:ClearHistoryItems()
    for i,v in ipairs(self.SeletItem) do
        local item = GameObject.Instantiate(self.ItemHistory)
        item.transform:SetParent(self.HistoryScrollView)
        item.gameObject:SetActive(true)
        item.transform:Reset()

        item.transform:Find("text").gameObject:GetComponent(Text).text = v.data.notes

        local btn= item.transform:Find("btn_enter").gameObject:GetComponent(Button)
        if v.fromType == GmDefine.FromType.conf then
            btn:SetClick(self:ToFunc("ConfHandle"),v.data)
        elseif v.fromType == GmDefine.FromType.server then
            btn:SetClick(self:ToFunc("ServerHandle"),v.data)
        else
            btn:SetClick(self:ToFunc("ClientHandle"),v.data)
        end

        table.insert(self.HisItem,item.gameObject)
    end
end

function GmWindow:SendToSever()
    local msg=self.InputSend.text
    --string.format("add_item %s ",)
    mod.GmFacade:SendMsg(10106,msg)
end