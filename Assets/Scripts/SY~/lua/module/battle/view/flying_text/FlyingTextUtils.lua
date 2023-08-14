FlyingTextUtils = StaticClass("FlyingTextUtils")

function FlyingTextUtils.FollowEntity(entityUid,rectTrans)
    if entityUid then
        local entity = RunWorld.EntitySystem:GetEntity(entityUid)
        if entity then
            local entityPos = entity.clientEntity.ClientTransformComponent:GetPos()
            local conf = entity.ObjectDataComponent.unitConf
            local y = entityPos.y + (conf.model_height * 0.001 * (conf.scale * 0.001))
            local pos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(entityPos.x,y,entityPos.z))
            UnityUtils.SetAnchoredPosition(rectTrans, pos.x, pos.y)
        end
    end
end

function FlyingTextUtils.GetCritAnimTween(rectTrans,text,beginPos)
    local perSec = 1/60

    local anim0 = TweenSequenceAnim.New({
        TweenDelayAnim.New(perSec*15),
        TweenMoveAnchorYAnim.New(rectTrans,beginPos.y+12, perSec*15)
    })

    local anim1 = TweenSequenceAnim.New({
        TweenScaleAnim.New(rectTrans,Vector3(0.7,0.7,1),0),
        TweenScaleAnim.New(rectTrans,Vector3(2,2,2),perSec*5):SetEase(DG.Tweening.Ease.OutCubic),
        TweenScaleAnim.New(rectTrans,Vector3(1,1,1),perSec*10):SetEase(DG.Tweening.Ease.InCubic),
    })

    local anim2 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(text,0,0),
        TweenGraphicAlphaAnim.New(text,255,perSec*2),
        TweenDelayAnim.New(perSec*13),
        TweenGraphicAlphaAnim.New(text,0,perSec*16)
    })

    return TweenParallelAnim.New({anim0,anim1,anim2})
end

function FlyingTextUtils.GetDmgAnimTween(rectTrans,text,beginPos)
    local perSec = 1/60

    local anim0 = TweenSequenceAnim.New({
        TweenDelayAnim.New(perSec*9),
        TweenMoveAnchorYAnim.New(rectTrans,beginPos.y+20, perSec*13):SetEase(DG.Tweening.Ease.InCubic),
    })

    local anim1 = TweenSequenceAnim.New({
        TweenScaleAnim.New(rectTrans,Vector3(0.85,0.85,1),0),
        TweenScaleAnim.New(rectTrans,Vector3(1.15,1.15,1),perSec*5),
        TweenScaleAnim.New(rectTrans,Vector3(1,1,1),perSec*6),
    })

    local anim2 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(text,0,0),
        TweenGraphicAlphaAnim.New(text,255,perSec),
        TweenDelayAnim.New(perSec*14),
        TweenGraphicAlphaAnim.New(text,0,perSec*7),
    })

    return TweenParallelAnim.New({anim0,anim1,anim2})
end

function FlyingTextUtils.GetHealAnimTween(rectTrans,text,beginPos)
    local perSec = 1/60

    local anim0 = TweenSequenceAnim.New({
        TweenDelayAnim.New(perSec),
        TweenMoveAnchorYAnim.New(rectTrans,beginPos.y+20,perSec*31):SetEase(DG.Tweening.Ease.OutCubic),
    })

    local anim1 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(text,0,0),
        TweenGraphicAlphaAnim.New(text,255,perSec*4),
        TweenDelayAnim.New(perSec*7),
        TweenGraphicAlphaAnim.New(text,0,perSec*23),
    })

    return TweenParallelAnim.New({anim0,anim1})
end

function FlyingTextUtils.GetSkillBannerAnimTween(mainRect,canvasGroupMain,img2,img6Rect,img6,imgName,imgNameRect,pivotRect,img4)
    local perSec = 1/60

    local anim0 = TweenSequenceAnim.New({
        TweenCanvasGroupAlphaAnim.New(canvasGroupMain,255,0),
        TweenDelayAnim.New(perSec*67),
        TweenCanvasGroupAlphaAnim.New(canvasGroupMain,0,perSec*6)
    })

    local anim1 = TweenSequenceAnim.New({
        TweenMoveAnchorYAnim.New(mainRect,-40,0),
        TweenMoveAnchorYAnim.New(mainRect,0,perSec*10),
        TweenDelayAnim.New(perSec*51),
        TweenMoveAnchorYAnim.New(mainRect,40,perSec*12)
    })

    local anim2 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(img2,0,0),
        TweenDelayAnim.New(perSec*10),
        TweenGraphicAlphaAnim.New(img2,255,perSec*10),
    })

    local anim3 = TweenSequenceAnim.New({
        TweenMoveAnchorXAnim.New(img6Rect,-56.5,0),
        TweenDelayAnim.New(perSec*5),
        TweenMoveAnchorXAnim.New(img6Rect,-31.5,perSec*65):SetEase(DG.Tweening.Ease.OutQuint),
    })

    local anim4 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(img6,0,0),
        TweenDelayAnim.New(perSec*5),
        TweenGraphicAlphaAnim.New(img6,255,perSec*10)
    })

    local anim5= TweenSequenceAnim.New({
        TweenMoveAnchorXAnim.New(imgNameRect,30.5,0),
        TweenDelayAnim.New(perSec*5),
        TweenMoveAnchorXAnim.New(imgNameRect,-2.5,perSec*65):SetEase(DG.Tweening.Ease.OutQuint)
    })

    local anim6 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(imgName,0,0),
        TweenDelayAnim.New(perSec*5),
        TweenGraphicAlphaAnim.New(imgName,255,perSec*6),
    })

    local anim7 = TweenSequenceAnim.New({
        TweenMoveAnchorYAnim.New(pivotRect,-53.4,0),
        TweenDelayAnim.New(perSec*5),
        TweenMoveAnchorYAnim.New(pivotRect,-45.4,perSec*36),
    })

    local anim8 = TweenSequenceAnim.New({
        TweenScaleAnim.New(pivotRect,Vector3(1,0,1),0),
        TweenDelayAnim.New(perSec*5),
        TweenScaleAnim.New(pivotRect,Vector3(1,1,1),perSec*17),
    })

    local anim9 = TweenSequenceAnim.New({
        TweenGraphicAlphaAnim.New(img4,0,0),
        TweenDelayAnim.New(perSec*5),
        TweenGraphicAlphaAnim.New(img4,255,perSec*7)
    })

    return TweenParallelAnim.New({anim0,anim1,anim2,anim3,anim4,anim5,anim6,anim7,anim8,anim9})
end