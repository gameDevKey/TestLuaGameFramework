CollectionDefine = StaticClass("CollectionDefine")

CollectionDefine.SortMode =
{
    none           = 0,  -- 未排序
    by_unit_id     = 1,  -- 按单位id
    by_quality_h2l = 2,  -- 按品质排序(从高到低)
    by_quality_l2h = 3,  -- 按品质排序(从低到高)
}

CollectionDefine.SortModeMapping =
{
    [CollectionDefine.SortMode.by_unit_id] = { title = TI18N("默认"), fn = "SortByUnitId" },
    [CollectionDefine.SortMode.by_quality_h2l] = { title = TI18N("品质"), fn = "SortByQualityFromHighToLow" },
    [CollectionDefine.SortMode.by_quality_h2l] = { title = TI18N("品质"), fn = "SortByQualityFromLowToHigh" },
}

CollectionDefine.ItemQualityToPath =
{
    [GDefine.Quality.green] = { filled = UITex("collection/main/24"), bg = UITex("collection/main/1") },
    [GDefine.Quality.bule] = { filled = UITex("collection/main/25"), bg = UITex("collection/main/2") },
    [GDefine.Quality.purple] = { filled = UITex("collection/main/26"), bg = UITex("collection/main/3") },
    [GDefine.Quality.orange] = { filled = UITex("collection/main/27"), bg = UITex("collection/main/4") },
}

CollectionDefine.DetailsQualityImg =
{
    [GDefine.Quality.green] = UITex("collection/details/1"),
    [GDefine.Quality.bule] = UITex("collection/details/2"),
    [GDefine.Quality.purple] = UITex("collection/details/3"),
    [GDefine.Quality.orange] = UITex("collection/details/4"),
}

CollectionDefine.DetailsQualityEffectId =
{
    [GDefine.Quality.green] = 9400010,
    [GDefine.Quality.bule] = 9400011,
    [GDefine.Quality.purple] = 9400012,
    [GDefine.Quality.orange] = 9400013,
}

CollectionDefine.JobToIcon = {
	[GDefine.JobIndex.zhanshi] = UITex("collection/main/5"),
	[GDefine.JobIndex.fashi] = UITex("collection/main/6"),
	[GDefine.JobIndex.sheshou] = UITex("collection/main/7"),
	[GDefine.JobIndex.fuzhu] = UITex("collection/main/8"),
	[GDefine.JobIndex.zhaohuan] = UITex("collection/main/9"),
}

function CollectionDefine.GetDetailsStandPath(head)
    local path = {}
    path.inverted = string.format("ui/icon/unit_stand/collection/%d.png",head)
    path.shadow = string.format("ui/icon/unit_stand/collection/%d.png",head)
    path.stand = string.format("ui/icon/unit_stand/collection/%d.png",head)
    return path
end