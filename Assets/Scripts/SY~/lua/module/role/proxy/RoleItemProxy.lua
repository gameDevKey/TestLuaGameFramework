RoleItemProxy = BaseClass("RoleItemProxy",Proxy)

function RoleItemProxy:__Init()
    self.roleItemData = nil
    self.roleItemDataByUid = nil
    self.updateUid = 0
end

function RoleItemProxy:__InitProxy()
    self:BindMsg(10300)
	self:BindMsg(10301)
end

-- 角色道具信息
function RoleItemProxy:InitRoleItemData(data)
	if not self.roleItemData then 
		self.roleItemData = {}
		self.roleItemDataByUid = {}
	end

	for k, v in pairs(data) do
		if not self.roleItemData[v.bag_type] then
			self.roleItemData[v.bag_type] = {}
		end
        v.update_uid = self:GetUpdateUid()
		table.insert(self.roleItemData[v.bag_type],v)
		self.roleItemDataByUid[v.item_uid] = v
	end
end

function RoleItemProxy:GetUpdateUid()
    self.updateUid = self.updateUid + 1
    return self.updateUid
end

function RoleItemProxy:Recv_10300(data)
	LogTable("接收10300",data)
	self.roleItemData = nil
	self:InitRoleItemData(data.item_list)
end

function RoleItemProxy:Recv_10301(data)
	LogTable("接收10301",data)
	local changeList = {}

	for _,itemUid in ipairs(data.del_list) do
		local itemData = self.roleItemDataByUid[itemUid]
		if not itemData then
			assert(false,string.format("服务器尝试删除不存在的道具[item_uid:%s]",itemUid))
		end

		local index = self:GetItemByIndex(itemData.bag_type,itemData.item_uid)
		table.remove(self.roleItemData[itemData.bag_type],index)
		self.roleItemDataByUid[itemData.item_uid] = nil
		changeList[itemData.item_id] = true
	end


	for _,v in ipairs(data.item_list) do
		local lastData = self.roleItemDataByUid[v.item_uid]

        if not self.roleItemData[v.bag_type] then
			self.roleItemData[v.bag_type] = {}
		end

        v.update_uid = self:GetUpdateUid()

		if not lastData then
			table.insert(self.roleItemData[v.bag_type],v)
		else
			if v.bag_type == lastData.bag_type then
				local index = self:GetItemByIndex(v.bag_type,v.item_uid)
				self.roleItemData[v.bag_type][index] = v
			else
				local index = self:GetItemByIndex(lastData.bag_type,lastData.item_uid)
				table.remove(self.roleItemData[lastData.bag_type],index)
				table.insert(self.roleItemData[v.bag_type],v)
			end
		end
		self.roleItemDataByUid[v.item_uid] = v
		changeList[v.item_id] = true
	end

    EventManager.Instance:SendEvent(EventDefine.refresh_role_item, changeList, data.source)
end

function RoleItemProxy:GetRoleItemData()
	return self.roleItemData
end

function RoleItemProxy:GetRoleItemType(bagType)
	return self.roleItemData[bagType]
end

function RoleItemProxy:GetItemNum(itemId)
	local itemConf = Config.ItemData.data_item_info[itemId]
	if not itemConf then
		error(string.format("无法找到道具数据 %s",tostring(itemId)))
		return 0
	end
	if itemConf.type == GDefine.ItemType.unitCard then
		local data = mod.CollectionProxy:GetDataById(itemId)
		return data and data.count or 0
	end
    local itemDatas = self:GetRoleItemType(GDefine.BagType.item)
    if itemDatas then
        for i,v in ipairs(itemDatas) do
            if v.item_id == itemId then
                return v.count
            end
        end
    end
	return 0
end

function RoleItemProxy:HasItemNum(itemId,num)
	return self:GetItemNum(itemId) >= num
end

function RoleItemProxy:GetEquipByPart(partType)
    local equipDatas = self:GetRoleItemType(GDefine.BagType.equip)
    if equipDatas then
        for i,v in ipairs(equipDatas) do
            local conf = Config.ItemData.data_item_info[v.item_id]
            if conf.equip_type == partType then
                return v
            end
        end
    end
end

function RoleItemProxy:GetItemById(itemId)
	local items = self.roleItemData[GDefine.BagType.item]
	if items then
		for i,v in ipairs(items) do
			if v.item_id == itemId then
				return v
			end
		end
	end
end

function RoleItemProxy:GetItemByIndex(bagType,uid)
	for i,v in ipairs(self.roleItemData[bagType]) do
		if v.item_uid == uid then
			return i
		end
	end
end