-- 数据定义
UIDefine = UIDefine or {}


UIDefine.ViewType =
{
    window = 1, --窗体
    panel = 2, --面板
    item = 3, -- item
}

UIDefine.CacheMode =
{
    destroy = 1,--删除
    hide = 2,--隐藏
}


UIDefine.canvasRoot = nil
UIDefine.canvasTrans = nil
UIDefine.uiCamera = nil

UIDefine.calcPosNode = nil
UIDefine.mixedTrans = nil