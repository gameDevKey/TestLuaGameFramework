BattleDefine = StaticClass("BattleDefine")

BattleDefine.WorldState =
{
    none = 0,
    preload = 1,
    ready = 2,
    running = 3,
    pause = 4,
    stop = 5,
}

BattleDefine.WorldType = 
{
    pvp = 1,
    pve = 2,
}

BattleDefine.rootNode = nil
BattleDefine.mainPanel = nil
BattleDefine.nodeObjs = {}
BattleDefine.uiObjs = {}

BattleDefine.coreVersion = "1"

BattleDefine.localCheck = true
BattleDefine.isJit = true

BattleDefine.Anim =
{
    born = "born",
    idle = "stand",
    run = "move",
    die = "dead",
    hit = "hit",
}

BattleDefine.Camp =
{
    attack = 1,
    defence = 2,
}

BattleDefine.CampPlaceIndex =
{
    [BattleDefine.Camp.attack] = {4,2,3,9,7,8},
    [BattleDefine.Camp.defence] = {2,4,3,7,9,8},
}

BattleDefine.CampGridPlaceIndex =
{
    [BattleDefine.Camp.attack] = {3,4,2,5,1,6},
    [BattleDefine.Camp.defence] = {4,3,5,2,6,1},
}

BattleDefine.GridStance =
{
    [BattleDefine.Camp.attack] =
    {
        [1] = 49,
        [2] = 50,
        [3] = 51,
        [4] = 52,
        [5] = 53,
        [6] = 54,
    },
    [BattleDefine.Camp.defence] =
    {
        [1] = 6,
        [2] = 5,
        [3] = 4,
        [4] = 3,
        [5] = 2,
        [6] = 1,
    }
}

BattleDefine.StancePos =
{
    [0] = {x=102.18,y=7.499999,z=313.85},
    [1] =
    {
        [-1] = {z=4500},
        [-2] = {x=0,y=0,z=-5500}, --守护者出现位置
        [0] = {x=0,y=670,z=-7000}, --主堡位置

        --
        [1] = {x=-4500,y=0,z=-5080},

        [2] = {x=-3076,y=0,z=-4500},
        [3] = {x=0,y=0,z=-4500},
        [4] = {x=3076,y=0,z=-4500},

        [5] = {x=-4800,y=0,z=-6580},

        --
        [6] = {x=-1800,y=0,z=-7080},

        [7] = {x=-3076,y=0,z=-5500},
        [8] = {x=0,y=0,z=-5500},
        [9] = {x=3076,y=0,z=-5500},

        [10] = {x=-1200,y=0,z=-9080},

        --
        [11] = {x=1800,y=0,z=-9080},

        [12] = {x=-3700,y=0,z=-10580},
        [13] = {x=300,y=0,z=-10580},
        [14] = {x=4300,y=0,z=-10580},


        [15] = {x=4800,y=0,z=-9080},
    },
    [-1] =
    {
        [-1] = {z=-4500},
        [-2] = {x=0,y=0,z=5500}, --守护者出现位置
        [0] = {x=0,y=670,z=7000}, --主堡位置

        --
        [1] = {x=4500,y=0,z=5080},

        [2] = {x=3076,y=0,z=4500},
        [3] = {x=0,y=0,z=4500},
        [4] = {x=-3076,y=0,z=4500},

        [5] = {x=4800,y=0,z=7080},

        --
        [6] = {x=1800,y=0,z=7080},

        [7] = {x=3076,y=0,z=5500},
        [8] = {x=-0,y=0,z=5500},
        [9] = {x=-3076,y=0,z=5500},

        [10] = {x=1200,y=0,z=9080},

        --
        [11] = {x=-1800,y=0,z=9080},

        [12] = {x=4300,y=0,z=10580},
        [13] = {x=300,y=0,z=10580},
        [14] = {x=-3700,y=0,z=10580},

        [15] = {x=-4800,y=0,z=9080},
    }
}

BattleDefine.PlaceSlotNum = 15
BattleDefine.PlaceGridCol = 5

BattleDefine.ViewSlotIndex = {[2]=true,[3]=true,[4]=true,[7]=true,[8]=true,[9]=true,[12]=true,[13]=true,[14]=true}

--707,0,707
BattleDefine.StanceOffsetDir =
{
    [1] =
    {
        [1] = {x={dir={x=0,y=0,z=0},index=0},y={dir={x=0,y=0,z=0},index=0}},
    },
    [2] =
    {
        [1] = {x={dir={x=-1000,y=0,z=0},index=500},y={dir={x=0,y=0,z=0},index=0}},
        [2] = {x={dir={x=1000,y=0,z=0}},y={dir={x=0,y=0,z=0}}},
    },
    [3] =
    {
        [1] = {x={dir={x=-1000,y=0,z=0}},y={dir={x=0,y=0,z=0}}},
        [2] = {x={dir={x=0,y=0,z=0}},y={dir={x=0,y=0,z=0}}},
        [3] = {x={dir={x=1000,y=0,z=0}},y={dir={x=0,y=0,z=0}}},
    },
    [4] =
    {
        [1] = {x={dir={x=-1000,y=0,z=0}},y={dir={x=0,y=0,z=1000}}},

        [1] = {x=-707,y=0,z=707},
        [2] = {x=707,y=0,z=707},
        [3] = {x=-707,y=0,z=-707},
        [4] = {x=707,y=0,z=-707},
    },
    [5] =
    {
        [1] = {x=-707,y=0,z=707},
        [2] = {x=707,y=0,z=707},
        [3] = {x=0,y=0,z=0},
        [4] = {x=-707,y=0,z=-707},
        [5] = {x=707,y=0,z=-707},
    },
    [6] =
    {
        [1] = {x=-707,y=0,z=707},
        [2] = {x=0,y=0,z=1000},
        [3] = {x=707,y=0,z=707},
        [4] = {x=-707,y=0,z=-707},
        [5] = {x=0,y=0,z=-1000},
        [6] = {x=707,y=0,z=-707},
    },
}


--多单位站位
BattleDefine.MultiStancePos =
{
    [1] = 
    {
        [1] =
        {
            [1] = {xDir=0,xStep=0,xInterval=0,zDir=0,zStep=0,zInterval=0}
        },
        [2] =
        {
            [1] = {xDir=-1,xStep=1000,xInterval=1,zDir=0,zStep=0,zInterval = 0},
            [2] = {xDir=1,xStep=1000,xInterval=1,zDir=0,zStep=0,zInterval = 0}
        },
        [3] =
        {
            [1] = {xDir=0,xStep=0,xInterval=0,zDir=1,zStep=1000,zInterval = 1},
            [2] = {xDir=-1,xStep=1000,xInterval=1,zDir=-1,zStep=1000,zInterval = 1},
            [3] = {xDir=1,xStep=1000,xInterval=1,zDir=-1,zStep=1000,zInterval = 1},
        },
        [4] =
        {
            [1] = {xDir=-1,xStep=1000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
            [2] = {xDir=1,xStep=1000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
            [3] = {xDir=-1,xStep=1000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
            [4] = {xDir=1,xStep=1000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
        },
        [5] =
        {
            [1] = {xDir=0,xStep=0,xInterval=0,zDir=0,zStep=0,zInterval=0},
            [2] = {xDir=-1,xStep=2000,xInterval=1,zDir=1,zStep=2000,zInterval=1},
            [3] = {xDir=1,xStep=2000,xInterval=1,zDir=1,zStep=2000,zInterval=1},
            [4] = {xDir=-1,xStep=2000,xInterval=1,zDir=-1,zStep=2000,zInterval=1},
            [5] = {xDir=1,xStep=2000,xInterval=1,zDir=-1,zStep=2000,zInterval=1},
        },
        [6] =
        {
            [1] = {xDir=-1,xStep=2000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
            [2] = {xDir=0,xStep=0,xInterval=0,zDir=1,zStep=1000,zInterval=1},
            [3] = {xDir=1,xStep=2000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
            [4] = {xDir=-1,xStep=2000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
            [5] = {xDir=0,xStep=0,xInterval=0,zDir=-1,zStep=1000,zInterval=1},
            [6] = {xDir=1,xStep=2000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
        }
    },
    [-1] =
    {
        [1] =
        {
            [1] = {xDir=0,xStep=0,xInterval=0,zDir=0,zStep=0,zInterval=0}
        },
        [2] =
        {
            [1] = {xDir=1,xStep=1000,xInterval=1,zDir=0,zStep=0,zInterval = 0},
            [2] = {xDir=-1,xStep=1000,xInterval=1,zDir=0,zStep=0,zInterval = 0}
        },
        [3] =
        {
            [1] = {xDir=0,xStep=0,xInterval=0,zDir=-1,zStep=1000,zInterval = 1},
            [2] = {xDir=1,xStep=1000,xInterval=1,zDir=1,zStep=1000,zInterval = 1},
            [3] = {xDir=-1,xStep=1000,xInterval=1,zDir=1,zStep=1000,zInterval = 1},
        },
        [4] =
        {
            [1] = {xDir=1,xStep=1000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
            [2] = {xDir=-1,xStep=1000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
            [3] = {xDir=1,xStep=1000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
            [4] = {xDir=-1,xStep=1000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
        },
        [5] =
        {
            [1] = {xDir=0,xStep=0,xInterval=0,zDir=0,zStep=0,zInterval=0},
            [2] = {xDir=1,xStep=2000,xInterval=1,zDir=-1,zStep=2000,zInterval=1},
            [3] = {xDir=-1,xStep=2000,xInterval=1,zDir=-1,zStep=2000,zInterval=1},
            [4] = {xDir=1,xStep=2000,xInterval=1,zDir=1,zStep=2000,zInterval=1},
            [5] = {xDir=-1,xStep=2000,xInterval=1,zDir=1,zStep=2000,zInterval=1},
        },
        [6] =
        {
            [1] = {xDir=1,xStep=2000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
            [2] = {xDir=0,xStep=0,xInterval=0,zDir=-1,zStep=1000,zInterval=1},
            [3] = {xDir=-1,xStep=2000,xInterval=1,zDir=-1,zStep=1000,zInterval=1},
            [4] = {xDir=1,xStep=2000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
            [5] = {xDir=0,xStep=0,xInterval=0,zDir=1,zStep=1000,zInterval=1},
            [6] = {xDir=-1,xStep=2000,xInterval=1,zDir=1,zStep=1000,zInterval=1},
        }
    }
}

--召唤站位(偏移值)
BattleDefine.SummonStancePos =
{
    {x=-750,y=0,z=750},
    {x=0,y=0,z=750},
    {x=750,y=0,z=750},
    -- {x=-750,y=0,z=-750},
    -- {x=0,y=0,z=-750},
    -- {x=-750,y=0,z=-750},
}

BattleDefine.StanceNum = 3

-- 旧版
-- BattleDefine.StancePos =
-- {
--     [0] = {x=101.88,y=7.43,z=312.62},
--     [1] =
--     {
--         [0] = {x=101.88,y=7.43,z=318.74},
--         [1] = {{x=101.88,y=7.43,z=318.74}},
--         [2] = {{x=102.88,y=7.43,z=318.74},{x=100.88,y=7.43,z=318.74}},
--         [3] = {{x=101.88,y=7.43,z=318.74},{x=103.88,y=7.43,z=318.74},{x=99.88,y=7.43,z=318.74}},
--     },
--     [-1] =
--     {
--         [0] = {x=101.88,y=7.43,z=306.5},
--         [1] = {{x=101.88,y=7.43,z=306.5}},
--         [2] = {{x=100.88,y=7.43,z=306.5},{x=102.88,y=7.43,z=306.5}},
--         [3] = {{x=101.88,y=7.43,z=306.5},{x=99.88,y=7.43,z=306.5},{x=103.88,y=7.43,z=306.5}},
--     }
-- }


BattleDefine.EntityTag =
{
    none = 0,
    hero = 1,
    home = 2,
    commander = 3,
    skill_hit = 4,
    unit = 5,
    magic_card = 6,
    clone_unit = 7, --分身
}

BattleDefine.EntitySubTag =
{
    none = 0,
}

BattleDefine.EntityState = 
{
	none = 0,
    born = 1,
	idle = 2,
	move = 3,
    skill = 4,
    die = 5,
    hit = 6,
}

BattleDefine.EntityMoveSubState =
{
	none = 0,
	walk = 1,
	run = 2,
}

BattleDefine.EntityIdleSubState =
{
	none = 0,
	fight_idle = 1, --战斗待机
    fight_to_leisurely = 3, --战斗待机转休闲待机
	leisurely_idle = 4,--休闲待机
}

BattleDefine.EntityHitState =
{
    none = 0,
    anim = 1,
    back_up = 2,
    fly_up = 3,
    stand_up = 4,
}

BattleDefine.EntityDieSubState = 
{
    none = 0,
    death = 1,
}

BattleDefine.EntityAction =
{
    move = 1,
    skill = 2,
}

BattleDefine.ActionType =
{
    none = 0,
    skill = 1,
}

BattleDefine.Attr =
{
    hp = 1,
    extra_hp = 2,
    energy = 3,
    energy_add_rate = 4,
}

BattleDefine.NotAddAttr = 
{
    [GDefine.Attr.max_hp] = true,
    [BattleDefine.Attr.hp] = true,
    [BattleDefine.Attr.extra_hp] = true,
    [BattleDefine.Attr.energy] = true,
}

BattleDefine.AttrRatio = 10000
BattleDefine.TimeRatio = 1000

BattleDefine.AttrIdToName = {
	[BattleDefine.Attr.hp] = "hp",  --生命值
    [BattleDefine.Attr.energy] = "energy",  --能量
    [BattleDefine.Attr.energy_add_rate] = "energy_add_rate",  --能量恢复比例
}

BattleDefine.AttrNameToId =
{
	[BattleDefine.AttrIdToName[BattleDefine.Attr.hp]] = BattleDefine.Attr.hp,
    [BattleDefine.AttrIdToName[BattleDefine.Attr.energy]] = BattleDefine.Attr.energy,
    [BattleDefine.AttrIdToName[BattleDefine.Attr.energy_add_rate]] = BattleDefine.Attr.energy_add_rate,
}


BattleDefine.SkillTimelineNode =
{
    play_anim = "PlayAnim",

    play_self_effect = "PlaySelfEffect",

    play_target_effect = "PlayTargetEffect",

    play_scene_effect = "PlaySceneEffect",

    play_target_pos_scene_effect = "PlayTargetPosSceneEffect",

    do_hit = "DoHit",

    do_behavior_hit = "DoBehaviorHit",

    fly_to_target_hit = "FlyToTargetHit",

    fly_to_target_pos_hit = "FlyToTargetPosHit",

    cry_link_hit = "CryLinkHit",

    backstab_hit = "BackstabHit",

    summon_unit = "SummonUnit",

    fly_track_hit = "FlyTrackHit",

    summon_commander_unit = "SummonCommanderUnit",

    log = "Log",

    transport = "Transport",

    self_do_hit = "SelfDoHit",

    remove_satisfied_buff = "RemoveSatisfiedBuff",

    shake_screen_pos = "ShakeScreenPos",

    force_move_by_center = "ForceMoveByCenter",

    commander_exp_modify = "CommanderExpModify",

    unit_star_modify = "UnitStarModify",

    play_audio = "PlayAudio",

    parabolic_jump = "ParabolicJump",

    bouncing_bullet = "BouncingBullet",

    knock_back = "KnockBack",

    loop_link_hit = "LoopLinkHit",

    summon_clone_unit = "SummonCloneUnit",

    transfigure = "Transfigure",

    fast_charge = "FastCharge",

    delay_die = "DelayDie",

    swallow_then_spit = "SwallowThenSpit",

    rel_skill = "RelSkill",

    pull_targets_to_self = "PullEntity",

    pumped_storage = "PumpedStorage",

    charge_collides_continuously = "ChargeCollidesContinuously",
}

BattleDefine.PerformTimelineNode =
{
    play_anim = "PlayAnim",

    play_self_effect = "PlaySelfEffect",

    play_scene_effect = "PlaySceneEffect",
}

BattleDefine.TargetPosType =
{
    none = 0,
    origin = 1,
    target_forward = 2,
    scene_center = 3,
    self_center = 4,
    enemy_center = 5,
}

BattleDefine.FlyingText = 
{
	hp = 1,
    skill = 2,
    hit_tips = 3,
    action = 4,
    attr = 5,
    state = 6,
    energy = 7,
    skill_unlock = 8,
    shield = 9,
    skill_banner = 10,
}

BattleDefine.FlyingHitTipChar = 
{
    dodge = "1",
    storm = "2",
    offset = "3"
}

BattleDefine.FlyingTextState =
{
    dodge = "dodge",   -- 闪避飘字
}

BattleDefine.maxFlytextNum = 20

BattleDefine.EffectType =
{
    skill = 1,
}


BattleDefine.ComponentInitOrder =
{
    0,
}

BattleDefine.ComponentUpdateOrder =
{
    0,
    CollistionComponent.UPDATE_PRIORITY,
    AreaFixComponent.UPDATE_PRIORITY,
    TransformComponent.UPDATE_PRIORITY,
    102,
}

BattleDefine.ComponentDelOrder =
{
    0,
}

BattleDefine.MoverType =
{
    linera = 1,
    fly_hit_lock_mover = 2,
    parabola = 3,
}

BattleDefine.AssetType = 
{
    crystal = 101,
}

BattleDefine.BattleState =
{
    none = "none",
    enter = "enter",
    battle = "battle",
    solo_battle = "solo_battle",
    over = "over"
}

BattleDefine.GridNum = 15


BattleDefine.RewardQuality =
{
    blue   = 1, --蓝色
    purple = 2, --紫色
    orange = 3, --橙色
}


BattleDefine.HeroQuality =
{
    N   = 1,
    R   = 2, --绿色
    SR  = 3, --蓝色
    SSR = 4, --紫色
    UR  = 5, --橙色
}


BattleDefine.HeroQualityBox =
{
	[BattleDefine.HeroQuality.N] = "common_4",
    [BattleDefine.HeroQuality.R] = "common_3",
    [BattleDefine.HeroQuality.SR] = "common_5",
    [BattleDefine.HeroQuality.SSR] = "common_2",
    [BattleDefine.HeroQuality.UR] = "common_6",
}

BattleDefine.RoleArgs = 
{
    max_hp = 1,
    cur_hp = 2,
}

BattleDefine.MaskBit =
{
    dmg    = 1,
    head   = 2,
    crit   = 4,
    dodge  = 8,
    storm  = 16,--强击
    offset = 32, --偏移
}



BattleDefine.ConfCond =
{
    ["满血"] = 1,
}


BattleDefine.TargetCampType = 
{
    all = 0,
    self = 1,
	friend = 2,
	friend_in_self = 3,
	enemy = 4,
}

BattleDefine.LifeType =
{
    none  = 0,
    youji = 1,
    jixie = 2,
}

BattleDefine.ConfTargetCampType = 
{
    ["全部"] = 0,
    ["自身"] = 1,
    ["友方"] = 2,
    ["友方(包含自己)"] = 3,
    ["敌方"] = 4,
}

BattleDefine.RoadIndex =
{
    none = 0,
    left = 1,
    middle = 2,
    right = 3,
}


BattleDefine.EntityKvType =
{
    last_select_target = 1,
    change_range = 2,
    target_pos = 3,
    last_min_node_index = 4,
    clone_units = 5,
}


BattleDefine.RangeType =
{
    full           = 0, -- 全屏
    circle         = 1, -- 圆形
    aabb           = 2,
    obb            = 3,
    sector         = 4, -- 扇形
    annulus        = 5, -- 环形
    annulus_sector = 6, -- 环扇形
    polygon        = 7, -- 多边形
}

BattleDefine.UnitType = 
{
    hero = 1,
    commander = 2,
    home = 3,
    summon = 4,
    magic_card = 5,
    building = 6,
}

BattleDefine.HomeUnitTypes =
{
    [BattleDefine.UnitType.home] = BattleDefine.UnitType.home,
}

BattleDefine.NotHomeUnitTypes = 
{
    [BattleDefine.UnitType.hero] = BattleDefine.UnitType.hero,
    [BattleDefine.UnitType.commander] = BattleDefine.UnitType.commander,
    [BattleDefine.UnitType.summon] = BattleDefine.UnitType.summon,
    [BattleDefine.UnitType.building] = BattleDefine.UnitType.building,
}

BattleDefine.Operation = 
{
    random_hero = 1,
    select_hero = 2,
    update_hero = 3,
    extend_grid = 4,
    swap_hero_grid = 5,
    sell_hero = 6,
    use_magic_card = 7,
    select_pve_item = 8,
    use_manual_item = 9,

    client_select_hero = 100,
}


BattleDefine.BuffState = 
{
    none = 0,
    frozen = 1,
    not_be_select = 2,
    dizziness = 3,
    petrifying = 4,
    reverse_camp = 5,
    palsy = 6,
    ban_energy_add = 7,
    exempt_debuff = 8,
    ban_rel_skill = 9,
}

BattleDefine.BuffStateInfo =
{
    [BattleDefine.BuffState.frozen] = {isControl = true},
    [BattleDefine.BuffState.dizziness] = {isControl = true},
    [BattleDefine.BuffState.petrifying] = {isControl = true},
}

BattleDefine.MarkState =
{
    none = 0,
    force_move = 1,
    knock_back = 2,
    releasing_skill = 3,
    delay_die = 4,
    move_releasing_skill = 5,

    control = 1000,

    move_to_check_pos = 100,
    move_to_check_pos_complete = 101,
    move_pos = 102,
}

BattleDefine.MarkStateInfo =
{
    [BattleDefine.MarkState.knock_back] = {isControl = true},
    [BattleDefine.MarkState.force_move] = {isControl = true},
}

BattleDefine.ServerOperation =
{
    random_hero = 1,
    select_hero = 2,
    extend_grid = 3,
    swap_hero_grid = 4,
    sell_hero = 5,
}

BattleDefine.BattleResult =
{
    none = 0,
    win = 1,
    lose = 2,
}

BattleDefine.WalkType =
{
    all = 0,
    floor  = 1,
	fly = 2,
}

BattleDefine.UidType =
{
    behavior = 1,
    skill = 2,
    buff = 3,
    magic_event = 4,
    change_range = 5,
    halo = 6,
}


--命中
BattleDefine.HitFrom =
{
    skill = 1,
    buff = 2,
    other = 3,
}

BattleDefine.HitType = 
{
    dmg = 1,
    heal = 2,
    assist = 3,
    energy = 4,
}

BattleDefine.ConfHitType =
{
    ["伤害"] = BattleDefine.HitType.dmg,
    ["治疗"] = BattleDefine.HitType.heal,
}

BattleDefine.HitCalc =
{
    original = 0,
    attr = 1,
    fixed = 2,
    seckill = 3,
    args_val = 4,
    commander_attr = 5,
    skill_hit_result = 6,
    be_hit_value = 7,
}

BattleDefine.AttachCoefMod =
{
    fixed = 1,
    distance = 2,
    hitNum = 3,
    targetBuffOverlay = 4,
    debuffKindCount = 5,
}

BattleDefine.ConfAttachCoefMod =
{
    ["固定值"] = BattleDefine.AttachCoefMod.fixed,
    ["距离"] = BattleDefine.AttachCoefMod.distance,
    ["连续命中次数"] = BattleDefine.AttachCoefMod.hitNum,
    ["目标Buff层数"] = BattleDefine.AttachCoefMod.targetBuffOverlay,
    ["减益效果种类计数"] = BattleDefine.AttachCoefMod.debuffKindCount,
}

BattleDefine.AttrGetMode =
{
    all  = 1, --总属性
    base = 2, --基础属性
    add  = 3, --附加属性
}


BattleDefine.SearchPriority =
{
	default = 1,
	random = 2, --随机
    floor_walk_unit = 3,--地面单位
    fly_walk_unit = 4,--飞行单位
    hp_low = 5,--血量低
    hp_height = 6,--血量高
    hp_ratio_low = 7,--血量比例低
    hp_ratio_height = 8,--血量比例高
    max_hp_low = 9, --血量上限低
    max_hp_height = 10, --血量上限高
    atk_low = 11,--攻击低
    atk_height = 12,--攻击高
	min_to_self_dis = 13, --离自己最近
	max_to_self_dis = 14, --离自己最远
    min_to_self_home_dis = 15,--离我方主堡最近
    max_to_self_home_dis = 16,--离我方主堡最远
    min_to_enemy_home_dis = 17,--离敌方主堡最近
    max_to_enemy_home_dis = 18,--离敌方主堡最远
}

BattleDefine.UpStarType =
{
    growth = 1,
    added = 2,
}

BattleDefine.MaxHitEffectNum = 30


BattleDefine.FollowWalkType =
{
    floor  = 1,
	fly = 2,
    floor_fly = 3,
    home = 4,
}

BattleDefine.OutputType =
{
    atk = 1,
    heal = 2,
    def = 3,
}

BattleDefine.HitDistType =
{
    none = 0,
    far  = 1,
    near = 2,
}

BattleDefine.HpSize =
{
    small = 1,
    middle = 2,
    big = 3,
}

BattleDefine.BridgeState =
{
    none = 0,                                -- 无归属
    attackCamp = BattleDefine.Camp.attack,   -- 归属攻击阵营  1
    defenceCamp = BattleDefine.Camp.defence, -- 归属防守阵营  2
    capturing = 3,                           -- 两阵营争夺中
}

BattleDefine.PvpType = 
{
    pvp = 1,
    reserve = 2,
    debug = 3,
}

BattleDefine.GuideEvent =
{
    begin_battle = 1,
}

BattleDefine.raceType =
{
	ren_zu = 1,
	an_yuan = 2,
	shen_zu = 3,
}

BattleDefine.cameraPos = {}


BattleDefine.ShaderEffect =
{
    frozen = 1,
    petrifying = 2,
    flash = 3,
}

BattleDefine.openSelectTips = true

BattleDefine.hitResultCanBeDodge =
{
    canBeDodge    = 1,  -- 可以被闪避
    canNotBeDodge = 2,  -- 不可被闪避
}

BattleDefine.hitResultCanBeDodgeToBool =
{
    [BattleDefine.hitResultCanBeDodge.canBeDodge]    = true,
    [BattleDefine.hitResultCanBeDodge.canNotBeDodge] = false,
}

if not IS_CHECK then
    BattleDefine.TargetNumTypeIcon=
    {
        [1] = 
        {
            [GDefine.JobIndex.zhanshi] = UITex("battle/101"),
            [GDefine.JobIndex.fashi] = UITex("battle/100"),
            [GDefine.JobIndex.sheshou] = UITex("battle/103"),
            [GDefine.JobIndex.fuzhu] = UITex("battle/99"),
            [GDefine.JobIndex.zhaohuan] = UITex("battle/102"),
        },
        [2] = 
        {
            [GDefine.JobIndex.zhanshi] = UITex("battle/96"),
            [GDefine.JobIndex.fashi] = UITex("battle/95"),
            [GDefine.JobIndex.sheshou] = UITex("battle/98"),
            [GDefine.JobIndex.fuzhu] = UITex("battle/94"),
            [GDefine.JobIndex.zhaohuan] = UITex("battle/97"),
        }
    }
end


BattleDefine.pveItemEffectType =
{
    add_attr = 1,                  -- 增加属性
    strengthen_normal_attack = 2,  -- 强化普攻
    special_skill = 3,             -- 特殊技能
    manual_skill = 4,              -- 手动技能
}

BattleDefine.CountKey =
{
    debuff_all_entity = "debuff_all_entity", -- debuff_全体单位
}

BattleDefine.Dir = 
{
    up = 1,--"上",
    down = 2,--"下",
    left = 3,--"左",
    right = 4,--"右",
    up_left = 5,-- "左上",
    up_right = 6,--"右上",
    down_left = 7,--"左下",
    down_right = 8,--"右下",
}



--TODO:格子
BattleDefine.PlaceInfo =
{
    [1] =
    {
        pos = {x=-3.75,y=0.75,z=-9.8}
    },
    [2] =
    {
        pos = {x=-2.25,y=0.75,z=-9.8}
    },
    [3] =
    {
        pos = {x=-0.75,y=0.75,z=-9.8}
    },
    [4] =
    {
        pos = {x=0.75,y=0.75,z=-9.8}
    },
    [5] =
    {
        pos = {x=2.25,y=0.75,z=-9.8}
    },
    [6] =
    {
        pos = {x=3.75,y=0.75,z=-9.8}
    }
}

BattleDefine.GridColToIndex =
{
    [BattleDefine.Camp.attack] =
    {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4,
        [5] = 5,
        [6] = 6,
    },
    [BattleDefine.Camp.defence] =
    {
        [1] = 6,
        [2] = 5,
        [3] = 4,
        [4] = 3,
        [5] = 2,
        [6] = 1,
    },
}

BattleDefine.PlaceMapGrid =
{
    [BattleDefine.Camp.attack] =
    {
        [37] = true,
        [38] = true,
        [39] = true,
        [40] = true,
        [41] = true,
        [46] = true,

        [47] = true,
        [48] = true,
        [49] = true,
        [50] = true,
        [51] = true,
        [52] = true,

        [53] = true,
        [54] = true,
        [55] = true,
        [56] = true,
        [57] = true,
        [58] = true,

    },
    [BattleDefine.Camp.defence] =
    {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,

        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = true,

        [13] = true,
        [14] = true,
        [15] = true,
        [16] = true,
        [17] = true,
        [18] = true,
    },
}

BattleDefine.PlaceLimitRow =
{
    [BattleDefine.Camp.attack] = {min = 9,max = 7},
    [BattleDefine.Camp.defence] = {min = 1,max = 3},
}
--