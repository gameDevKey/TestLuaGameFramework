EntityConfig = StaticClass("EntityConfig")

EntityConfig.Type = Enum.New({
    GamePlay = 1,
    Proj = 2, --弹道
})

EntityConfig.Class = {
    [EntityConfig.Type.GamePlay] = "GamePlayEntity",
    [EntityConfig.Type.Proj] = "ProjEntity",
}

---逻辑组件
EntityConfig.LogicComponents = {
    [EntityConfig.Type.GamePlay] = {
        "TransformComponent",
        "MoveComponent",
        "AttrComponent",
        "SkillComponent",
        "StateComponent",
        "CalcComponent",
    },
    [EntityConfig.Type.Proj] = {
        "TransformComponent",
        "MoveComponent",
    },
}

---渲染组件
EntityConfig.RenderComponents = {
    [EntityConfig.Type.GamePlay] = {
        "TransformRenderComponent",
        "SkinComponent",
        "RangeComponent"
    },
    [EntityConfig.Type.Proj] = {
        "TransformRenderComponent",
        "SkinComponent",
    },
}

return EntityConfig