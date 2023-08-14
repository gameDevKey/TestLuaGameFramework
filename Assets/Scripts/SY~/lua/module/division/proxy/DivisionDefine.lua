DivisionDefine = StaticClass("DivisionDefine")

DivisionDefine.InfoType = {
    RankInfo = 1,
    UnlockInfo = 2,
    UnlockInfoMulti = 3,
    RewardInfo = 4,
}

DivisionDefine.InfoConfig = {
    [DivisionDefine.InfoType.RankInfo] = {
        width = 720,
        height = 530,
        centerX = 5,
        centerY = -457,
    },
    [DivisionDefine.InfoType.UnlockInfo] = {
        width = 720,
        height = 900,
        centerX = 5,
        centerY = -457,
    },
    [DivisionDefine.InfoType.UnlockInfoMulti] = {
        width = 720,
        height = 900,
        centerX = 5,
        centerY = -457,
    },
    [DivisionDefine.InfoType.RewardInfo] = {
        width = 720,
        height = 300,
        centerX = 5,
        centerY = -200,
    },
}

DivisionDefine.RewardStatus = {
    Lock = 1, --未解锁
    Unclaimed = 2, --可领
    Receive = 3, --已领
}