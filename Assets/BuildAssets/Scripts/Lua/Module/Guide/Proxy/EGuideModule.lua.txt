EGuideModule = StaticClass("EGuideModule")

EGuideModule.ListenMap = {
    ["进入游戏时"] = "EnterGameGuideTrigger",
    ["移动时"] = "MoveGuideTrigger",
}

EGuideModule.FinderMap = {
    ["屏幕位置"] = "UIPosGuideFinder",
}

EGuideModule.ActionMap = {
    ["延迟"] = "DelayGuideAction",
    ["显示对话框"] = "DialogueGuideAction",
}

EGuideModule.Event = {
    ActiveDialogue = 1,
}

return EGuideModule
