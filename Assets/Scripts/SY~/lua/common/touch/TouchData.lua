-- 数据定义
TouchData = BaseClass("TouchData")

function TouchData:__Init()
    self.isDown = false
    self.lastPos = Vector2()
    self.noticeMoveed = false
end

function TouchData:__Delete()

end