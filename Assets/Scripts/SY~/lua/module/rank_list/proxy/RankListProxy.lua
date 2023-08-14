RankListProxy = BaseClass("RankListProxy",Proxy)

function RankListProxy:__Init()
end

function RankListProxy:__InitProxy()
    -- self:BindMsg(11700)
end

function RankListProxy:__InitComplete()
end

function RankListProxy:GetTestDatas()
    local datas = {}
    table.insert(datas, {
        rank = 1,
        lastRank = 10,
        name =  "测试1",
        division = 1,
        trophy = 6572,
    })
    table.insert(datas, {
        rank = 4,
        lastRank = 10,
        name =  "测试2",
        division = 3,
        trophy = 1234,
    })
    table.insert(datas, {
        rank = 15,
        lastRank = 10,
        name =  "测试3",
        division = 5,
        trophy = 500,
    })
    for i = 1, 10, 1 do
        table.insert(datas, {
            rank = i,
            lastRank = 10-i,
            name =  "测试"..i,
            division = 5,
            trophy = 500*i,
        })
    end
    return datas
end