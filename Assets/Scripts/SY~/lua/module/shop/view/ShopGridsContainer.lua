ShopGridsContainer = BaseClass("ShopGridsContainer",BaseView)

function ShopGridsContainer:__Init(layoutInfo,gridTemp,shopGridItemCtrl)
    --[[
        layoutInfo = {
            columnCount   = 3,
            gridSize      = {x=200, y=285}
            spacing       = {x=30, y=30}
        }
    ]]

    self.belongShop = nil

    self.layoutInfo = layoutInfo
    self.gridTemp = gridTemp
    self.shopGridItemCtrl = shopGridItemCtrl

    self.shopGridAnimIndex = 1

    self.gridDatas = {}
    self.grids = {}
    self.bgs = {}
end

function ShopGridsContainer:__Delete()
    self:RemoveGrids()
    for i, v in ipairs(self.bgs) do
        GameObject.Destroy(v)
    end
end

function ShopGridsContainer:__CacheObject()
    self.gridLayoutGroup = self:Find("main",GridLayoutGroup)
    self.bgParent = self:Find("bg")
    self.bgTemp = self:Find("bg/bg_temp").gameObject
    self.itemParent = self:Find("main")
end

function ShopGridsContainer:__Create()
    self.gridLayoutGroup.padding.left = self.layoutInfo.padding.left
    self.gridLayoutGroup.padding.right = self.layoutInfo.padding.right
    self.gridLayoutGroup.padding.top = self.layoutInfo.padding.top
    self.gridLayoutGroup.padding.bottom = self.layoutInfo.padding.bottom
    self.gridLayoutGroup.cellSize.x = self.layoutInfo.gridSize.x
    self.gridLayoutGroup.cellSize.y = self.layoutInfo.gridSize.y
    self.gridLayoutGroup.spacing.x = self.layoutInfo.spacing.x
    self.gridLayoutGroup.spacing.y = self.layoutInfo.spacing.y
    self.gridLayoutGroup.constraintCount = self.layoutInfo.columnCount

    UnityUtils.SetAnchoredPosition(self.bgTemp.transform, 0.5, -308-self.layoutInfo.padding.top)
end

function ShopGridsContainer:SetData(shopType, gridDatas)
    self.gridDatas = gridDatas
    self.belongShop = shopType
end

function ShopGridsContainer:__Show()
    local count = 0
    -- local anim = --TODO BaseView需新增动画资源加载接口，直接传入路径加载
    for i, gridData in ipairs(self.gridDatas) do
        local grid = self.grids[i]
        if not grid then
            grid = ShopGridItem.Create(self.gridTemp)
            grid.transform:SetParent(self.itemParent)
            grid.transform:Reset()
            self.grids[i] = grid
        end
        grid:SetData(self.belongShop, gridData)
        grid:SetAnim(AssetPath.shopGridItemCtrl,self.shopGridItemCtrl)  --TODO BaseView需新增动画资源加载接口，直接传入路径加载
        grid:Show()
        count = i
    end

    local row = math.ceil(count/self.layoutInfo.columnCount)
    local width = self.transform.rect.width
    local height = row > 1 and (self.layoutInfo.gridSize.y + self.layoutInfo.spacing.y) * (row-1) + self.layoutInfo.gridSize.y or self.layoutInfo.gridSize.y
    height = height  + 20 -- 20: paddingTop

    UnityUtils.SetSizeDelata(self.transform,width,height)

    self:SetRowBg(row)

    for i = count+1, #self.grids do
        self.grids[i]:Hide()
    end
end

function ShopGridsContainer:SetRowBg(row)
    for i = 2, row do
        local bg = GameObject.Instantiate(self.bgTemp)
        bg.transform:SetParent(self.bgParent)
        bg.transform:Reset()
        local posX = self.bgTemp.transform.anchoredPosition.x
        local offsetY = self.bgTemp.transform.anchoredPosition.y
        local posY = (-self.layoutInfo.gridSize.y - self.layoutInfo.spacing.y) * (i-1)
        posY = posY + offsetY
        UnityUtils.SetAnchoredPosition(bg.transform, posX, posY)

        table.insert(self.bgs,bg)
    end
end

function ShopGridsContainer:RemoveGrids()
    for k, v in pairs(self.grids) do
        v:Destroy()
    end
end