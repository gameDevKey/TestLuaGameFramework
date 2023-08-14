ImageBubbleMsgGuideNode = BaseClass("ImageBubbleMsgGuideNode", BaseGuideNode)

function ImageBubbleMsgGuideNode:__Init()
    self.bubbleMsgGuideView = nil
    self.closeTimer = nil
    self.followTarget = nil
end

function ImageBubbleMsgGuideNode:OnInit()
    self.followTarget = nil
    self:ShowBubbleMsgGuideView()
    self:StartCloseTimer()
end

function ImageBubbleMsgGuideNode:OnDestroy()
    self:OnFollowTargetFinish()
    self:RemoveCloseTimer()
    self:RemoveBubbleMsgGuideView()
end

function ImageBubbleMsgGuideNode:ShowBubbleMsgGuideView()
    self:RemoveBubbleMsgGuideView()
    self.bubbleMsgGuideView = ImageBubbleMsgGuideView.New()
    local x,y = self:GetTargetPos()
    local defaultHide = self.actionParam.follow and not self.followTarget --需要跟随一个物体时，默认先隐藏，否则直接显示
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.AddChildView,self.bubbleMsgGuideView,self.actionParam,x,y,defaultHide)
end

function ImageBubbleMsgGuideNode:RemoveBubbleMsgGuideView()
    if self.bubbleMsgGuideView then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveChildView,self.bubbleMsgGuideView)
        self.bubbleMsgGuideView = nil
    end
end

function ImageBubbleMsgGuideNode:StartCloseTimer()
    self:RemoveCloseTimer()
    if self.actionParam.closeTime and self.actionParam.closeTime > 0 then
        self.closeTimer = TimerManager.Instance:AddTimer(1,self.actionParam.closeTime,self:ToFunc("OnCloseTimer"))
    end
end

function ImageBubbleMsgGuideNode:RemoveCloseTimer()
    if self.closeTimer then
        TimerManager.Instance:RemoveTimer(self.closeTimer)
        self.closeTimer = nil
    end
end

function ImageBubbleMsgGuideNode:OnCloseTimer()
    self:RemoveCloseTimer()
    self:RemoveBubbleMsgGuideView()
end

function ImageBubbleMsgGuideNode:FollowTarget()
    if not RunWorld then
        return
    end
    local followData = self.actionParam.follow
    if followData and self.bubbleMsgGuideView then
        local lastTarget = self.followTarget
        local targetEntity = self.followTarget
        if not targetEntity then
            local entitys = PlayerGuideUtils.GetSceneEntity("hero",followData)
            if #entitys == 1 then --若是统领，则不用判断波数了
                targetEntity = entitys[1]
            else
                local targetWave = followData.wave or 0
                local targetIndex = followData.index or 0
                if targetIndex == 0 then
                    targetEntity = entitys[#entitys]
                else
                    for index, entity in ipairs(entitys or {}) do
                        local wave = entity.ObjectDataComponent.group + 1
                        if wave == targetWave and index == targetIndex then
                            targetEntity = entity
                            break
                        end
                    end
                end
            end
        end
        if targetEntity and targetEntity.clientEntity.ClientTransformComponent.gameObject then
            self.followTarget = targetEntity
            local obj = self.followTarget.clientEntity.ClientTransformComponent.gameObject
            if not lastTarget then
                self.bubbleMsgGuideView:Show(self.actionParam)
            end
            local targetPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],obj.transform.position)
            targetPos = self:GetRealTargetPos(targetPos)
            self.bubbleMsgGuideView:SetPos(targetPos)
        end
    end
end

function ImageBubbleMsgGuideNode:OnFollowTargetFinish()
    self.followTarget = nil
end

function ImageBubbleMsgGuideNode:OnUpdate()
    self:FollowTarget()
end