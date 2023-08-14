AssetPath = SingleClass("AssetPath")

AssetPath.model_matcap = "mixed/unit/10000.png"
AssetPath.model_mask = "mixed/unit/111201m.tga"
AssetPath.unit_cubemap = "mixed/unit/unit_cubemap.exr"

AssetPath.shader = "shader"


AssetPath.unitFrozenMat = "mixed/unit/frozen.mat"
AssetPath.unitPetrifyingMat = "mixed/unit/petrifying.mat"
AssetPath.unitFlashMat = "mixed/unit/flash.mat"

AssetPath.commonAtlas = "ui/texture/common1"

AssetPath.font1 = "font/font_1.ttf"
AssetPath.font2 = "font/font_2.ttf"

AssetPath.windowParent = "ui/mixed/window_parent.prefab"
AssetPath.panelParent = "ui/mixed/panel_parent.prefab"

AssetPath.heroItem = "ui/prefab/items/hero_item.prefab"

AssetPath.equipItem = "ui/prefab/items/equip_item.prefab"

AssetPath.propItem = "ui/prefab/items/prop_item.prefab"

AssetPath.playerGuide = "ui/prefab/player_guide/player_guide.prefab"

AssetPath.volumeProfile = "mixed/rendering/volume_profile.asset"

AssetPath.viewModelRoot = "ui/prefab/common/view_model_root.prefab"
AssetPath.debugNode = "ui/prefab/gm/debug_node.prefab"

function AssetPath.GetRoleHeadIcon(job,sex)
    return string.format("ui/icon/role_head/%s_%s.png",job,sex)
end

function AssetPath.GetUnitIconHead(head)
    return string.format("ui/icon/unit_icon/head/%s.png",head)
end

function AssetPath.GetUnitIconHeadObliqueSquare(head)
    return string.format("ui/icon/unit_icon/head_oblique_square/%s.png",head)
end

function AssetPath.GetUnitIconCollection(head)
    return string.format("ui/icon/unit_icon/collection/%s.png",head)
end

function AssetPath.GetUnitIconBattleOperate(head)
	return string.format("ui/icon/unit_icon/battle_operate/%s.png", head)
end

function AssetPath.GetUnitIconBattleSelect(head)
    return string.format("ui/icon/unit_icon/battle_select/%s.png",head)
end

function AssetPath.GetCommanderHeadIconObliqueSquare(id)
	return string.format("ui/icon/commander_head_oblique_square/%s.png",id)
end

function AssetPath.GetCommanderHoriRectIcon(id)
	return string.format("ui/icon/commander_hori_head/%s.png",id)
end

function AssetPath.GetCommanderVertRectIcon(id)
	return string.format("ui/icon/commander_rect_head/%s.png",id)
end

function AssetPath.GetUnitStandCollection(head)
    return string.format("ui/icon/unit_stand/collection/%s.png",head)
end

function AssetPath.GetUnitStandBattleDetails(head)
    return string.format("ui/icon/unit_stand/battle_details/%s.png",head)
end

function AssetPath.GetUnitStandLevUp(head)
    return string.format("ui/icon/unit_stand/lev_up/%s.png",head)
end

function AssetPath.GetBattleHaloIcon(id)
    return string.format("ui/icon/battle_halo/%s.png",id)
end

function AssetPath.GetBattleSelectRewardIcon(id)
    return string.format("ui/icon/battle_select_reward/%s.png",id)
end

function AssetPath.GetDetailsHeadIcon(id)
    return string.format("ui/icon/details_head/%s.png",id)
end

function AssetPath.GetHeroHeadQuality(quality)
    return string.format("ui/texture/battle_result/battle_result_%s.png",quality)
end

function AssetPath.GetSkillIcon(id)
    return string.format("ui/icon/skill/%s.png",id)
end

function AssetPath.GetBattleCommanderSkillIcon(id)
    return string.format("ui/icon/battle_commander_skill/%s.png",id)
end

function AssetPath.GetChestIcon(id,flag)
    if flag then
        return string.format("ui/icon/chest/%s_open.png",id)
    else
        return string.format("ui/icon/chest/%s.png",id)
    end
end

function AssetPath.GetOldChestIcon(id)
    return string.format("ui/icon/chest/%sold.png",id)
end

function AssetPath.GetChestDetailsStand(iconId)
	return string.format("ui/icon/chest_details_stand/%s.png",iconId)
end

function AssetPath.GetRaceTypeIcon(raceType)
    return string.format("ui/icon/race_type/%s.png",raceType)
end

function AssetPath.GetShopItemIcon(itemId)
	return string.format("ui/icon/shop/%s.png",itemId)
end

function AssetPath.GetBattleHeroDetailsBgs(quality)
    local bgs = {
        bg=string.format("ui/icon/battle_hero_details_bg/bg_%s.png",quality),
        bg2=string.format("ui/icon/battle_hero_details_bg/bg2_%s.png",quality),
        bg3=string.format("ui/icon/battle_hero_details_bg/bg3_%s.png",quality)
    }

    return bgs
end

function AssetPath.GetBackpackCommanderNameTexture(id)
    local nameImgZH = string.format("ui/icon/backpack_commander_name_zh/%s.png",id)
    local nameImgEN = string.format("ui/icon/backpack_commander_name_en/%s.png",id)
    return nameImgZH,nameImgEN
end

function AssetPath.GetFlyingTextStateImg(state)
	return string.format("ui/icon/battle_flying_text_state/%s.png",state)
end

function AssetPath.GetAudioByBgm(audioId)
    return string.format("audio/bgm/%s.ogg",audioId)
end

function AssetPath.GetAudioByUI(audioId)
    return string.format("audio/ui/%s.ogg",audioId)
end

function AssetPath.GetAudioByCommom(audioId)
    return string.format("audio/common/%s.ogg",audioId)
end

function AssetPath.GetAudioByGroup(audioId)
    return string.format("audio/group/%s.ogg",audioId)
end

local natureIconIndex =
{
    [GDefine.Nature.all] = "0",
    [GDefine.Nature.water] = "3",
    [GDefine.Nature.fire] = "1",
    [GDefine.Nature.wind] = "2",
    [GDefine.Nature.light] = "3",
    [GDefine.Nature.dark] = "3",
}
function AssetPath.GetNatureIcon(id)
    return string.format("ui/icon/nature/%s.png",natureIconIndex[id])
end

function AssetPath.GetItemIcon(iconId)
	return string.format("ui/icon/item/%s.png",iconId)
end

function AssetPath.GetBattlepassItemIcon(iconId)
	return string.format("ui/icon/battlepass/%s.png",iconId)
end

function AssetPath.GetPveItemShortIcon(icon)
	return string.format("ui/icon/pve_item_short/%s.png",icon)
end

function AssetPath.GetPveItemLongIcon(icon)
	return string.format("ui/icon/pve_item_long/%s.png",icon)
end

function AssetPath.GetFuncOpenIcon(icon)
	return string.format("ui/icon/func_open/%s.png",icon)
end

function UITex(path)
	return "ui/texture/" .. path .. ".png"
end


--图集映射
----------------------------------------------
AssetPath.RaceTypeToIcon =
{
	[GDefine.RaceType.ren_zu]  = UITex("common1/common1_36"),
	[GDefine.RaceType.an_yuan] = UITex("common1/common1_37"),
	[GDefine.RaceType.shen_zu] = UITex("common1/common1_35"),
}


AssetPath.JobToIcon = {
	[GDefine.JobIndex.zhanshi] = UITex("battle_operate/36"),
	[GDefine.JobIndex.fashi] = UITex("battle_operate/37"),
	[GDefine.JobIndex.sheshou] = UITex("battle_operate/38"),
	[GDefine.JobIndex.fuzhu] = UITex("battle_operate/39"),
	[GDefine.JobIndex.zhaohuan] = UITex("battle_operate/40"),
}

AssetPath.JobToIconBackpack = {
	[GDefine.JobIndex.zhanshi] = UITex("common1/common1_79"),
	[GDefine.JobIndex.fashi] = UITex("common1/common1_81"),
	[GDefine.JobIndex.sheshou] = UITex("common1/common1_80"),
	[GDefine.JobIndex.fuzhu] = UITex("common1/common1_78"),
	[GDefine.JobIndex.zhaohuan] = UITex("common1/common1_87"),
}

AssetPath.CampGreyIcon ={
	[0] = "common_camp_grey_0",
    [1] = "common_camp_grey_1",
	[2] = "common_camp_grey_2",
	[3] = "common_camp_grey_3",
	[4] = "common_camp_grey_4",
	[5] = "common_camp_grey_5",
}

AssetPath.CampLightIcon ={
	[0] = "base_camp_light_0",
    [1] = "base_camp_light_1",
	[2] = "base_camp_light_2",
	[3] = "base_camp_light_3",
	[4] = "base_camp_light_4",
	[5] = "base_camp_light_5",
}

AssetPath.CampBlackIcon  ={
	[0] = "base_camp_black_0",
    [1] = "base_camp_black_1",
	[2] = "base_camp_black_2",
	[3] = "base_camp_black_3",
	[4] = "base_camp_black_4",
	[5] = "base_camp_black_5",
}

AssetPath.QualityLevel ={
	[2] = "common_10",
	[3] = "common_11",
	[4] = "common_12",
	[5] = "common_13",
}


AssetPath.QualityToFrame = {
	[GDefine.Quality.green]  = UITex("common1/common1_4"),
	[GDefine.Quality.bule]   = UITex("common1/common1_3"),
	[GDefine.Quality.purple] = UITex("common1/common1_2"),
	[GDefine.Quality.orange] = UITex("common1/common1_1"),
}

AssetPath.QualityToIconBg = {
	[GDefine.Quality.green]  = UITex("common1/common1_8"),
	[GDefine.Quality.bule]   = UITex("common1/common1_7"),
	[GDefine.Quality.purple] = UITex("common1/common1_6"),
	[GDefine.Quality.orange] = UITex("common1/common1_5"),
	[0] = UITex("common1/common1_9"),
}

AssetPath.QualityToSliderFill = {
	[GDefine.Quality.green]  = UITex("common1/common1_14"),
	[GDefine.Quality.bule]   = UITex("common1/common1_13"),
	[GDefine.Quality.purple] = UITex("common1/common1_12"),
	[GDefine.Quality.orange] = UITex("common1/common1_11"),
}

AssetPath.QualityToArrow = {
	[GDefine.Quality.green]  = UITex("common1/common1_19"),
	[GDefine.Quality.bule]   = UITex("common1/common1_18"),
	[GDefine.Quality.purple] = UITex("common1/common1_17"),
	[GDefine.Quality.orange] = UITex("common1/common1_16"),
}

AssetPath.QualityToImg = {
	[GDefine.Quality.green]  = UITex("common1/common1_23"),
	[GDefine.Quality.bule]   = UITex("common1/common1_22"),
	[GDefine.Quality.purple] = UITex("common1/common1_21"),
	[GDefine.Quality.orange] = UITex("common1/common1_20"),
}

AssetPath.QualityToNameBg = {
	[GDefine.Quality.green]  = UITex("common1/common1_64"),
	[GDefine.Quality.bule]   = UITex("common1/common1_65"),
	[GDefine.Quality.purple] = UITex("common1/common1_66"),
	[GDefine.Quality.orange] = UITex("common1/common1_67"),
}

AssetPath.QualityToUnitItemBg = {
	[GDefine.Quality.green]  = UITex("common1/common1_75"),
	[GDefine.Quality.bule]   = UITex("common1/common1_74"),
	[GDefine.Quality.purple] = UITex("common1/common1_76"),
	[GDefine.Quality.orange] = UITex("common1/common1_77"),
	[0] = UITex("common1/common1_73"),
}

AssetPath.QualityToUnitDetailsIconBg = {
	[GDefine.Quality.green]  = "ui/texture/common1/common1_71.png",
	[GDefine.Quality.bule]   = "ui/texture/common1/common1_70.png",
	[GDefine.Quality.purple] = "ui/texture/common1/common1_69.png",
	[GDefine.Quality.orange] = "ui/texture/common1/common1_68.png",
	[0] = "ui/texture/common1/common1_72.png",  -- 空位
	[-1] = "ui/texture/common1/common1_89.png", -- 锁定
}

AssetPath.QualityToItemSquare = {
	[GDefine.Quality.green]  = "ui/texture/common1/common1_98.png",
	[GDefine.Quality.bule]   = "ui/texture/common1/common1_96.png",
	[GDefine.Quality.purple] = "ui/texture/common1/common1_97.png",
	[GDefine.Quality.orange] = "ui/texture/common1/common1_99.png",
}

AssetPath.QualityToUnitDetailsWindowBg = {
	[GDefine.Quality.green]  = "ui/single/details/unit_details_28.png",
	[GDefine.Quality.bule]   = "ui/single/details/unit_details_29.png",
	[GDefine.Quality.purple] = "ui/single/details/unit_details_33.png",
	[GDefine.Quality.orange] = "ui/single/details/unit_details_31.png",
}

AssetPath.QualityToUnitDetailsImg = {
	[GDefine.Quality.green]  = "ui/texture/unit_details/unit_details_101.png",
	[GDefine.Quality.bule]   = "ui/texture/unit_details/unit_details_102.png",
	[GDefine.Quality.purple] = "ui/texture/unit_details/unit_details_103.png",
	[GDefine.Quality.orange] = "ui/texture/unit_details/unit_details_104.png",
}

AssetPath.QualityToShopGridImg = {
	[GDefine.Quality.green]  = "ui/texture/shop/main/1.png",
	[GDefine.Quality.bule]   = "ui/texture/shop/main/2.png",
	[GDefine.Quality.purple] = "ui/texture/shop/main/3.png",
	[GDefine.Quality.orange] = "ui/texture/shop/main/4.png",
}

AssetPath.QualityToBattleOperateGrid = {
	[GDefine.Quality.green]  = {frame = UITex("battle_operate/1"), bg = UITex("battle_operate/5")},
	[GDefine.Quality.bule]   = {frame = UITex("battle_operate/2"), bg = UITex("battle_operate/6")},
	[GDefine.Quality.purple] = {frame = UITex("battle_operate/3"), bg = UITex("battle_operate/7")},
	[GDefine.Quality.orange] = {frame = UITex("battle_operate/4"), bg = UITex("battle_operate/8")},
}

AssetPath.QualityToBattleEnemyGrid = {
	[GDefine.Quality.green]  = {quality = UITex("battle_operate/11"), bg = UITex("common1/common1_98")},
	[GDefine.Quality.bule]   = {quality = UITex("battle_operate/12"), bg = UITex("common1/common1_96")},
	[GDefine.Quality.purple] = {quality = UITex("battle_operate/13"), bg = UITex("common1/common1_97")},
	[GDefine.Quality.orange] = {quality = UITex("battle_operate/14"), bg = UITex("common1/common1_99")},
}

AssetPath.QualityFrame ={
	[2] = "common_14",
	[3] = "common_15",
	[4] = "common_16",
	[5] = "common_17",
}

AssetPath.QualityToBattleDetailsBg ={
	[GDefine.Quality.green]  = {9, 13, 5, 1},
	[GDefine.Quality.bule]   = {10, 14, 6, 2},
	[GDefine.Quality.purple] = {11, 15, 7, 3},
	[GDefine.Quality.orange] = {12, 16, 8, 4},
}

function AssetPath.QualityToBattleDetailsBgs(quality)
    local bgs = {
        bg = "ui/single/battle_details/"..AssetPath.QualityToBattleDetailsBg[quality][1]..".png",
        bg2 = "ui/single/battle_details/"..AssetPath.QualityToBattleDetailsBg[quality][2]..".png",
        bg3 = "ui/single/battle_details/"..AssetPath.QualityToBattleDetailsBg[quality][3]..".png",
		skillDescBg = "ui/single/battle_details/"..AssetPath.QualityToBattleDetailsBg[quality][4]..".png",
    }
	LogTable("bgs",bgs)
    return bgs
end

AssetPath.StarStatusToImg ={
	[GDefine.StarStatus.nonMax] = UITex("common1/common1_39"),
	[GDefine.StarStatus.max] = UITex("common1/common1_38"),
}


AssetPath.AttrIdToIcon ={
	[GDefine.Attr.max_hp] = "common_26",
	[GDefine.Attr.atk] = "common_27",
	[GDefine.Attr.atk_speed] = "common_28",
	[GDefine.Attr.move_speed] = "common_29",
	-- [GDefine.Attr.crit_rate] = "common_30"),
	-- [GDefine.Attr.crit_dmg] = "common_30"),
}

AssetPath.AttrNameToIcon ={
	[GDefine.AttrIdToName[GDefine.Attr.max_hp]] = "common_26",
	[GDefine.AttrIdToName[GDefine.Attr.atk]] = "common_27",
	[GDefine.AttrIdToName[GDefine.Attr.atk_speed]] = "common_28",
	[GDefine.AttrIdToName[GDefine.Attr.move_speed]] = "common_29",
	-- [GDefine.AttrIdToName[GDefine.Attr.crit_rate]] = "common_30"),
	-- [GDefine.AttrIdToName[GDefine.Attr.crit_dmg]] = "common_30"),
}

function AssetPath.GetDivisionIconPath(division)
	division = division or 1
    return string.format("ui/icon/division/%d.png",division)
end

function AssetPath.GetPlayerGuideIconPath(key)
	return string.format("ui/icon/plalyer_guide_icon/%s.png",tostring(key))
end

AssetPath.DivisionEffectType = {
	Gold = 1, --金币
	Diamond = 2, --钻石
	Shine = 3, --光圈
	Arrow = 4,	--箭头
	Outline = 5,	--外发光
	Cloud = 6,	--云朵
	Line = 7,	--斜条
	Cursor = 8,	--游标
}

AssetPath.DivisionEffectID = {
	[AssetPath.DivisionEffectType.Shine] = 9000001,
	[AssetPath.DivisionEffectType.Cloud] = 9000002,
	[AssetPath.DivisionEffectType.Gold] = 9000003,
	[AssetPath.DivisionEffectType.Line] = 9000004,
	[AssetPath.DivisionEffectType.Diamond] = 9000005,
	[AssetPath.DivisionEffectType.Arrow] = 9000006,
	[AssetPath.DivisionEffectType.Cursor] = 9000007,
	[AssetPath.DivisionEffectType.Outline] = 9000008,
}

AssetPath.RewardEffectType = {
	Shine = 1,	--闪烁
}

AssetPath.RewardEffectID = {
	[AssetPath.RewardEffectType.Shine] = 9100001,
}

AssetPath.awardItemAnimCtrl = "anim/ui/reward/award_item.controller"
AssetPath.rankItemAnimCtrl = "anim/ui/division/rank_item.controller"
AssetPath.drawCardItemAnimCtrl = "anim/ui/draw_card/draw_card_award_item.controller"
AssetPath.emailItemAnimCtrl = "anim/ui/email/email_item.controller"
AssetPath.shopNodeCtrl = "anim/ui/shop/shop_node.controller"
AssetPath.shopGridItemCtrl = "anim/ui/shop/shop_grid_item.controller"
AssetPath.collectionItemCtrl = "anim/ui/collection/collection_item.controller"

AssetPath.ItemIdToCurrencyIcon = {
	[GDefine.ItemId.Diamond] = UITex("common1/common1_58"),
	[GDefine.ItemId.Gold] = UITex("common1/common1_57"),
	[GDefine.ItemId.DrawCardTicket] = UITex("common1/common1_93"),
	[GDefine.ItemId.SpeedCard] = UITex("common1/common1_90"),
}

function AssetPath.GetCurrencyIconByItemId(itemId)
	local icon = AssetPath.ItemIdToCurrencyIcon[itemId]
	if not icon then
		LogError(string.format("未配置ItemId对应的货币图标 [ItemId=%s]",itemId))
	end
	return icon or ""
end

function AssetPath.GetDrawCardIconPath(key)
	return string.format("ui/icon/draw_card_icon/%s.png",key)
end

function AssetPath.GetDrawCardQuailtyPath(key)
	return string.format("ui/icon/draw_card_quality/%s.png",key)
end

AssetPath.DrawCardAccChestIcon = {
	[1] = "ui/icon/chest/800001.png",
	[2] = "ui/icon/chest/800002.png",
}

AssetPath.DrawCardAccChestRecvIcon = {
	[1] = "ui/icon/chest/800001_open.png",
	[2] = "ui/icon/chest/800002_open.png",
}

--统帅竖长方形头像
function AssetPath.GetCommanderVerticalHeadIcon(unitId)
	return string.format("ui/icon/commander_vert_head/%s.png",unitId)
end

function AssetPath.GetSkillBannerHeadIcon(unitId)
	return string.format("ui/icon/skill_banner_icon/%d.png",unitId)
end

function AssetPath.GetSkillBannerNameIcon(skillId)
	return string.format("ui/icon/skill_banner_name/%d.png",skillId)
end