BattleHeroStatisticsView = BaseClass("BattleHeroStatisticsView",ExtendView)
BattleHeroStatisticsView.MAX_ROLE_AMOUNT = 6	--显示英雄个数
BattleHeroStatisticsView.REFRESH_DELTATIME = 1 	--刷新间隔
BattleHeroStatisticsView.DEFAULT_SWITCH = true	--默认打开状态

BattleHeroStatisticsView.TabType = {
	Atk = 1,
	Def = 2,
	HP = 3,
}

BattleHeroStatisticsView.PageName = {
	[BattleHeroStatisticsView.TabType.Atk] = "page_attack",
	[BattleHeroStatisticsView.TabType.Def] = "page_shield",
	[BattleHeroStatisticsView.TabType.HP] = "page_hp",
}

BattleHeroStatisticsView.Tab2Output = {
	[BattleHeroStatisticsView.TabType.Atk] = BattleDefine.OutputType.atk,
	[BattleHeroStatisticsView.TabType.Def] = BattleDefine.OutputType.def,
	[BattleHeroStatisticsView.TabType.HP] = BattleDefine.OutputType.heal,
}

BattleHeroStatisticsView.Tab2Name = {
	[BattleHeroStatisticsView.TabType.Atk] = TI18N("伤害统计"),
	[BattleHeroStatisticsView.TabType.Def] = TI18N("承伤统计"),
	[BattleHeroStatisticsView.TabType.HP] = TI18N("治疗统计"),
}

function BattleHeroStatisticsView:__Init()
	self.tbRole = {}
	self.heroOutputUpdateIdx = {}
end

function BattleHeroStatisticsView:__Delete()
end

function BattleHeroStatisticsView:__CacheObject()
	self.txtName = self:Find("main/top_node/statis_node/btn_off/txt_name",Text)
	self.btnOn = self:Find("main/top_node/statis_node/btn_on",Button)
	self.btnOff = self:Find("main/top_node/statis_node/btn_off",Button)
	self.objContent = self:Find("main/top_node/statis_node/content").gameObject
	self.objRoleContent = self:Find("main/top_node/statis_node/content/roles").gameObject
	self.objPageContent = self:Find("main/top_node/statis_node/content/pages").gameObject
	self.templateRole = self:Find("main/top_node/statis_node/content/roles/role_item").gameObject
	self.templateRole:SetActive(false)

	self.tabs = {}
	for key, name in pairs(BattleHeroStatisticsView.PageName) do
		local tab = self:Find("main/top_node/statis_node/content/pages/content/"..name).gameObject
		local btn = tab:GetComponent(Button)
		local select = tab.transform:Find("img_select").gameObject
		table.insert(self.tabs, {
			btn = btn,
			select = select,
			key = key,
		})
	end
end

function BattleHeroStatisticsView:__Create()

end

function BattleHeroStatisticsView:__BindEvent()

end

function BattleHeroStatisticsView:__BindListener()
	for _, tab in ipairs(self.tabs) do
		tab.btn:SetClick(self:ToFunc("OnTabClick"),tab.key)
	end

	self.btnOn:SetClick(self:ToFunc("OnSwitchButtonClick"),true)
	self.btnOff:SetClick(self:ToFunc("OnSwitchButtonClick"),false)
end

function BattleHeroStatisticsView:__Hide()
	self:ClearAllRoleItem()
	self:StopRefreshTimer()
end

function BattleHeroStatisticsView:__Show()
	self:OnSwitchButtonClick(BattleHeroStatisticsView.DEFAULT_SWITCH)
end

function BattleHeroStatisticsView:OnTabClick(tabType)
	self.curPage = tabType
	self.txtName.text = BattleHeroStatisticsView.Tab2Name[tabType]
	for _, tab in ipairs(self.tabs) do
		if tab.key == tabType then
			self:RefreshStatisticsPanel(true)
			tab.select:SetActive(true)
		else
			tab.select:SetActive(false)
		end
	end
end

function BattleHeroStatisticsView:OnSwitchButtonClick(active)
	BattleHeroStatisticsView.DEFAULT_SWITCH = active
	self.objContent:SetActive(active)
	if active then
		self.btnOff.gameObject:SetActive(true)
		self.btnOn.gameObject:SetActive(false)
		self:OnTabClick(BattleHeroStatisticsView.TabType.Atk)
		self:StartRefreshTimer()
	else
		self.btnOff.gameObject:SetActive(false)
		self.btnOn.gameObject:SetActive(true)
		self:StopRefreshTimer()
	end
end

function BattleHeroStatisticsView:StartRefreshTimer()
	self:AddUniqueTimer("RefreshHeroStatistics",0,BattleHeroStatisticsView.REFRESH_DELTATIME,self:ToFunc("RefreshStatisticsPanel"),true)
end

function BattleHeroStatisticsView:StopRefreshTimer()
	self:RemoveTimer("RefreshHeroStatistics")
end

function BattleHeroStatisticsView:RefreshStatisticsPanel(forceUpdate)
	local outputType = BattleHeroStatisticsView.Tab2Output[self.curPage]

	local newData = RunWorld.BattleStatisticsSystem.heroOutputUpdateIdx
	local lastIdx = self.heroOutputUpdateIdx[outputType]
	local dirty = lastIdx ~= newData[outputType]
	self.heroOutputUpdateIdx[outputType] = newData[outputType]

	if forceUpdate or dirty then
        RunWorld.BattleStatisticsSystem:SortHeroOutputByType(outputType)
    end
	local datas = RunWorld.BattleStatisticsSystem:GetInfo(RunWorld.BattleDataSystem.roleUid)

	self:ClearAllRoleItem()
	local maxVal = 0
	for i = 1, BattleHeroStatisticsView.MAX_ROLE_AMOUNT do
		local data = datas.outputInfoList[i]
		if not data then
			break
		end
		local roleItem = self:GetRoleItem(i,data,outputType)
		local config = RunWorld.BattleConfSystem:UnitData_data_unit_info(data.unitId)
		self:SetSprite(roleItem.imgIcon, AssetPath.GetUnitIconHead(config.head),false)
		roleItem.txtVal.text = roleItem.showData.value
		if roleItem.showData.value > maxVal then
			maxVal = roleItem.showData.value
		end
	end
	for _, roleItem in ipairs(self.tbRole) do
		for tpe, pgr in pairs(roleItem.rectPgrs) do
			if tpe == outputType then
				pgr.gameObject:SetActive(true)
				local w = roleItem.showData.value / maxVal * roleItem.rectPgrWidth
				UnityUtils.SetSizeDelata(pgr,w,roleItem.rectPgrHeight)
			else
				pgr.gameObject:SetActive(false)
			end
		end
	end

	self.objPageContent:SetActive(TableUtils.IsValid(self.tbRole))
end

function BattleHeroStatisticsView:GetRoleItem(i,data,outputType)
	local roleItem = self.tbRole[i]
	if not roleItem then
		roleItem = {}
		roleItem.obj = GameObject.Instantiate(self.templateRole)
		roleItem.obj:SetActive(true)
		roleItem.obj.transform:SetParent(self.objRoleContent.transform)
		roleItem.obj.transform:Reset()
		roleItem.rectPgrs = {
			[BattleDefine.OutputType.atk] = roleItem.obj.transform:Find("img_atk_pgr"):GetComponent(RectTransform),
			[BattleDefine.OutputType.def] = roleItem.obj.transform:Find("img_def_pgr"):GetComponent(RectTransform),
			[BattleDefine.OutputType.heal] = roleItem.obj.transform:Find("img_hp_pgr"):GetComponent(RectTransform),
		}
		roleItem.rectPgrWidth = roleItem.rectPgrs[BattleDefine.OutputType.atk].rect.width
		roleItem.rectPgrHeight = roleItem.rectPgrs[BattleDefine.OutputType.atk].rect.height
		roleItem.imgIcon = roleItem.obj.transform:Find("img_icon"):GetComponent(Image)
		roleItem.txtVal = roleItem.obj.transform:Find("txt_val"):GetComponent(Text)
		self.tbRole[i] = roleItem

		local config = RunWorld.BattleConfSystem:UnitData_data_unit_info(data.unitId)
		self:SetSprite(roleItem.imgIcon, AssetPath.GetUnitIconHead(config.head),false)
	end
	roleItem.showData = data.valueList[outputType]
	return roleItem
end

function BattleHeroStatisticsView:ClearAllRoleItem()
	for _, data in ipairs(self.tbRole) do
		GameObject.Destroy(data.obj)
	end
	self.tbRole = {}
end