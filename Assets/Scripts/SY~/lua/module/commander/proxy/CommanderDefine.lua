CommanderDefine = StaticClass("CommanderDefine")


CommanderDefine.Mode =
{
    pvp = 1,
    pve = 2,
}

CommanderDefine.chestItemId = 105


CommanderDefine.QualityToIconBg =
{
    [GDefine.Quality.white]  = UITex("commander/main/32"),
    [GDefine.Quality.green]  = UITex("commander/main/4"),
	[GDefine.Quality.bule]   = UITex("commander/main/2"),
	[GDefine.Quality.purple] = UITex("commander/main/23"),
	[GDefine.Quality.orange] = UITex("commander/main/1"),
    [GDefine.Quality.red] = UITex("commander/main/38"),
    [GDefine.Quality.colourful] = UITex("commander/main/39"),
}

CommanderDefine.ChestQualityAnims =
{
    idle =
    {
        ["normal_idle"] = "9300000_idle_01",
        ["can_open_idle"] = "9300000_idle",
    },
    open = 
    {
        [GDefine.Quality.white] = "9400000_open_white",
        [GDefine.Quality.green] = "9400000_open_green",
        [GDefine.Quality.bule] = "9400000_open_blue",
        [GDefine.Quality.purple] = "9400000_open_purple",
        [GDefine.Quality.orange] = "9400000_open_orange",
        [GDefine.Quality.red] = "9400000_open_red",
        [GDefine.Quality.colourful] = "9400000_open_colour",
    },
    open_idle = 
    {
        [GDefine.Quality.white] = "9400000_open_idle_white",
        [GDefine.Quality.green] = "9400000_open_idle_green",
        [GDefine.Quality.bule] = "9400000_open_idle_blue",
        [GDefine.Quality.purple] = "9400000_open_idle_puple",
        [GDefine.Quality.orange] = "9400000_open_idle_orange",
        [GDefine.Quality.red] = "9400000_open_idle_red",
        [GDefine.Quality.colourful] = "9400000_open_idle_colour",
    },
    close = 
    {
        [GDefine.Quality.white] = "9600000_close_white",
        [GDefine.Quality.green] = "9600000_close_green",
        [GDefine.Quality.bule] = "9600000_close_blue",
        [GDefine.Quality.purple] = "9600000_close_purple",
        [GDefine.Quality.orange] = "9600000_close_orange",
        [GDefine.Quality.red] = "9600000_close_red",
        [GDefine.Quality.colourful] = "9600000_close_colour",
    }
}

CommanderDefine.LayerOrder =
{
    ["chest_effect"] = 1,
    ["chest_info_node"] = 2,
}