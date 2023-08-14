BattleEntityDefine = StaticClass("BattleEntityDefine")

BattleEntityDefine.EntityCreateType =
{
    hero = 1,
    home = 2,
    commander = 3,
    skill_hit = 4,
    fly_to_target_hit = 5,
    cry_link_hit = 6,
    backstab_hit = 7,
    skill_behavior_hit = 8,
    fly_track_hit = 9,
    transport = 10,--装载机
    magic_card = 11,--魔法卡
    force_move_by_center = 12,--自中心强制位移
    parabolic_jump = 13,  -- 抛物线跳跃
    bouncing_bullet = 14, -- 弹射子弹
    knock_back = 15, -- 击退
    loop_link_hit = 16,--循环连接命中
    transfigure = 17,--变身
}

BattleEntityDefine.EntityBindComponents =
{
    [BattleEntityDefine.EntityCreateType.hero] = 
    {
        logic = 
        {
            "ObjectDataComponent",
            "TransformComponent",
            "TagComponent",
            "AnimComponent",
            "MoveComponent",
            "RotateComponent",
            "StateComponent",
            "BehaviorComponent",
            "SkillComponent",
            "HitComponent",
            "AttrComponent",
            "KvDataComponent",
            "CampComponent",
            "CollistionComponent",
            "BuffComponent",
            "AreaFixComponent",
            "AIComponent",
            "AreaComponent",
        },
        client =
        {
            "ClientTransformComponent",
            "ClientAnimComponent",
            "UIComponent",
            "EffectComponent",
            "SyncComponent",
            "ClientRangeComponent",
            "ClientBuffComponent",
            "ShaderEffectComponent",
            "HeroTposeComponent",
        }
    },

    [BattleEntityDefine.EntityCreateType.home] = 
    {
        logic = 
        {
            "ObjectDataComponent",
            "TransformComponent",
            "TagComponent",
            "StateComponent",
            "BehaviorComponent",
            "SkillComponent",
            "HitComponent",
            "AttrComponent",
            "KvDataComponent",
            "CampComponent",
            "CollistionComponent",
            "BuffComponent"
        },
        client =
        {
            "ClientTransformComponent",
            "EffectComponent",
            "UIComponent",
            "ClientRangeComponent",
            "HomeTposeComponent",
        }
    },

    [BattleEntityDefine.EntityCreateType.commander] = 
    {
        logic = 
        {
            "ObjectDataComponent",
            "TransformComponent",
            "TagComponent",
            "AnimComponent",
            "RotateComponent",
            "StateComponent",
            "BehaviorComponent",
            "SkillComponent",
            "AttrComponent",
            "KvDataComponent",
            "CampComponent",
            "BuffComponent",
            "CollistionComponent",
            "AIComponent"
        },
        client =
        {
            "ClientTransformComponent",
            "ClientAnimComponent",
            "EffectComponent",
            "SyncComponent",
            "ClientRangeComponent",
            "ClientBuffComponent",
            "ShaderEffectComponent",
            "HeroTposeComponent",
        }
    },

    [BattleEntityDefine.EntityCreateType.magic_card] = 
    {
        logic = 
        {
            "ObjectDataComponent",
            "TagComponent",
            "CampComponent",
            "TransformComponent",
            "SingleSkillComponent",
            "BuffComponent",
            "BehaviorComponent",
           -- "AttrComponent",
        },
        client =
        {
            "ClientTransformComponent"
        }
    },

    [BattleEntityDefine.EntityCreateType.skill_hit] = 
    {
        logic = 
        {
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        }
    },
    [BattleEntityDefine.EntityCreateType.fly_to_target_hit] = 
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "MoveComponent",
            "RotateComponent",
            "BehaviorComponent",
            "CampComponent"
        },
        client =
        {
            "ClientTransformComponent",
            "EffectComponent",
        }
    },
    [BattleEntityDefine.EntityCreateType.cry_link_hit] = 
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
        client =
        {
            "ClientTransformComponent",
            "EffectComponent",
        }
    },
    [BattleEntityDefine.EntityCreateType.backstab_hit] = 
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
        client =
        {
            "ClientTransformComponent",
            "EffectComponent",
        }
    },
    [BattleEntityDefine.EntityCreateType.skill_behavior_hit] = 
    {
        logic = 
        {
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        }
    },
    [BattleEntityDefine.EntityCreateType.fly_track_hit] = 
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "BehaviorComponent",
            "MoveComponent",
            "RotateComponent",
            "CampComponent"
        },
        client =
        {
            "ClientTransformComponent",
            -- "EffectComponent",
        }
    },
    [BattleEntityDefine.EntityCreateType.transport] = 
    {
        logic = 
        {
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
    },
    [BattleEntityDefine.EntityCreateType.force_move_by_center] = 
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
    },
    [BattleEntityDefine.EntityCreateType.parabolic_jump] = 
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
    },
    [BattleEntityDefine.EntityCreateType.bouncing_bullet] = 
    {
        logic =
        {
            "TransformComponent",
            "TagComponent",
            "MoveComponent",
            "RotateComponent",
            "BehaviorComponent",
            "CampComponent"
        },
        client =
        {
            "ClientTransformComponent",
            "EffectComponent",
        }
    },
    [BattleEntityDefine.EntityCreateType.knock_back] =
    {
        logic = 
        {
            "TransformComponent",
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
    },
    [BattleEntityDefine.EntityCreateType.loop_link_hit] = 
    {
        logic = 
        {
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
    },
    [BattleEntityDefine.EntityCreateType.transfigure] =
    {
        logic = 
        {
            "TagComponent",
            "BehaviorComponent",
            "CampComponent"
        },
    },
}