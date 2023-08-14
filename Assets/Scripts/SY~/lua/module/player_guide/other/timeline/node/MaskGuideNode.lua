MaskGuideNode = BaseClass("MaskGuideNode",BaseGuideNode)

function MaskGuideNode:__Init()
    self.hight = {}
    self.width = {}
    self.position = {}
end

function MaskGuideNode:OnStar()
    self.maskGuideView = MaskGuideView.New()
    self.maskGuideView:Show(self.args)
end

function MaskGuideNode:OnUpdate()
    self.battleButtle = GameObject.Find(self.args.path)
    self.maskGuideView:SetParent(self.battleButtle.transform)
end

function MaskGuideNode:__Show()
    
end