BattleHeroOutputView = BaseClass("BattleHeroOutputView",ExtendView)

function BattleHeroOutputView:__Init()
    self.refreshTimer = nil

    self.outputToBg = 
	{
		[BattleDefine.OutputType.atk] = {UITex("battle/88"),UITex("battle/28")},
		[BattleDefine.OutputType.heal] = {UITex("battle/89"),UITex("battle/29")},
		[BattleDefine.OutputType.def] = {UITex("battle/87"),UITex("battle/30")},
	}
	self.activeOutput = false
end

function BattleHeroOutputView:__Delete()
end

function BattleHeroOutputView:__CacheObject()
    self.outputNode = self:Find("main/top_node/output_node").gameObject
	self.openCloseOutputBtn = self:Find("main/top_node/output_node/open_close_output_btn")
	self.outputPanelTrans = self:Find("main/top_node/output_node/output_panel")
	self.outputItemParentTrans = self:Find("main/top_node/output_node/output_panel/items")

	self.openBtn = self:Find("main/top_node/output_node/open_btn",Button)
	self.closeBtn = self:Find("main/top_node/output_node/close_btn",Button)
	self:Find("main/top_node/output_node/close_btn/title",Text).text = TI18N("数据统计")
    self.outputItems = {}
	for i = 1,6 do self:GetOutputItem(i) end
end

function BattleHeroOutputView:GetOutputItem(index)
	local root = self:Find("main/top_node/output_node/output_panel/items/hero_"..index)
	local objects = {}
	objects.node = root.gameObject
	-- objects.nameText = root:Find("name"):GetComponent(Text)
	objects.iconBg = root:Find("icon_bg"):GetComponent(Image)
	objects.icon = root:Find("icon"):GetComponent(Image)
	objects.outputTypeIcon = root:Find("output_type"):GetComponent(Image)
	objects.valueText = root:Find("value"):GetComponent(Text)
	-- objects.job = root:Find("job"):GetComponent(Image)
	objects.slider = root:Find("slider"):GetComponent(Image)
	self.outputItems[index] = objects
end

function BattleHeroOutputView:__BindEvent()

end

function BattleHeroOutputView:__BindListener()
	self.openBtn:SetClick(self:ToFunc("OpenOutput"))
	self.closeBtn:SetClick(self:ToFunc("CloseOutput"))
	-- self.openCloseOutputBtn.gameObject:GetComponent(Button):SetClick( self:ToFunc("SwitchOutputPanel"))
end

function BattleHeroOutputView:__Hide()
    self:RemoveRefreshTimer()
	for k, v in pairs(self.outputItems) do
		v.node:SetActive(false)
	end
end

function BattleHeroOutputView:__Show()
    self:CloseOutput()
    self.refreshTimer = TimerManager.Instance:AddTimer(0,1,self:ToFunc("RefreshTimer"))
end

-- function BattleHeroOutputView:SwitchOutputPanel()
-- 	if self.activeOutput then
-- 		self:CloseOutput()
-- 	else
-- 		self:OpenOutput()
-- 	end
-- end

function BattleHeroOutputView:OpenOutput()
    self.activeOutput = true
	UnityUtils.SetAnchoredPosition(self.outputPanelTrans,0,-41-46)

	-- UnityUtils.SetLocalScale(self.openCloseOutputBtn,1,1,1)
	self.openBtn.gameObject:SetActive(false)
	self.closeBtn.gameObject:SetActive(true)
	if RunWorld.BattleStatisticsSystem.heroOutputRefresh then 
        RunWorld.BattleStatisticsSystem:SortHeroOutput() 
    end
	self:RefreshOuputItems() 
end

function BattleHeroOutputView:CloseOutput()
    self.activeOutput = false
	UnityUtils.SetAnchoredPosition(self.outputPanelTrans,160,-41-46)
	self.openBtn.gameObject:SetActive(true)
	self.closeBtn.gameObject:SetActive(false)
	-- UnityUtils.SetLocalScale(self.openCloseOutputBtn,-1,1,1)
	-- UnityUtils.SetAnchoredPosition(self.openCloseOutputBtn,-34,-41)
end

function BattleHeroOutputView:RefreshTimer()
    if not self.activeOutput or not RunWorld.BattleStatisticsSystem.heroOutputRefresh then 
		return 
	end

	RunWorld.BattleStatisticsSystem:SortHeroOutput()
    self:RefreshOuputItems()
end

function BattleHeroOutputView:RefreshOuputItems()
    local index = 0
	-- local maxValue = {
	-- 	[BattleDefine.OutputType.atk] = nil,
	-- 	[BattleDefine.OutputType.heal] = nil,
	-- 	[BattleDefine.OutputType.def] = nil
	-- }

	local statisticsInfo = RunWorld.BattleStatisticsSystem:GetInfo(RunWorld.BattleDataSystem.roleUid)
	

	for i,v in ipairs(statisticsInfo.outputInfoList) do
		if index >= 6 then
			break
		end
		index = index + 1
		local objects = self.outputItems[index]
		objects.node:SetActive(true)

		local config = RunWorld.BattleConfSystem:UnitData_data_unit_info(v.unitId)

		-- objects.nameText.text = config.name
		self:SetSprite(objects.iconBg,AssetPath.QualityToIconBg[config.quality])
		self:SetSprite(objects.icon, AssetPath.GetUnitIconHead(config.head),false)

		local maxOutput = statisticsInfo.outputMaxVals[v.maxValueType]

		objects.valueText.text = v.maxVal
		objects.slider.fillAmount = v.maxVal / maxOutput

		self:SetSprite(objects.slider,self.outputToBg[v.maxValueType][2])

		self:SetSprite(objects.outputTypeIcon,self.outputToBg[v.maxValueType][1])
	end

	for i = index + 1,6 do 
		self.outputItems[i].node:SetActive(false)
	end

	local size = index * 53

	UnityUtils.SetSizeDelata(self.outputItemParentTrans,155,size)
	-- UnityUtils.SetAnchoredPosition(self.openCloseOutputBtn,-34,-size-41)
end

function BattleHeroOutputView:RemoveRefreshTimer()
    if self.refreshTimer then
        TimerManager.Instance:RemoveTimer(self.refreshTimer)
        self.refreshTimer = nil
    end
end