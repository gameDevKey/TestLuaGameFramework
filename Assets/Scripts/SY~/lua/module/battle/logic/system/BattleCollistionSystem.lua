BattleCollistionSystem = BaseClass("BattleCollistionSystem",SECBClientEntitySystem)

function BattleCollistionSystem:__Init()
    self.mapBeginX = -4500
    self.mapBeginZ = 8500
    self.mapWidth = 9000
    self.mapHeight = 17000
	self.mapRow = 10
    self.mapCol = 6
	self.gridNum = self.mapRow * self.mapCol
    self.mapGridSize = 1700
	--TODO:找个合适的地方
	self.mapCenterX = self.mapBeginX + 4500
	self.mapCenterZ = self.mapBeginZ - 8500

	self.rowColToGrid = {}
	self.gridToRowCol = {}

    self.gridEntitys = {}
    self.entityGrids = {}

	self.rangeToGrids = {}
	self.posToGridRowCol = {}

	--
	self.occupyGridNode = nil
    self.occupyGridMeshFilter = nil
    self.occupyGridMaterial = nil
	self.occupyGridVertices = {}
	self.occupyRefreshGridVertices = {}

	self.debugGridNode = nil
    self.debugGridMeshFilter = nil
    self.debugGridMaterial = nil
	self.debugGridVertices = {}
	self.debugRefreshGridVertices = {}
end

function BattleCollistionSystem:__Delete()
	for k,v in pairs(self.entityGrids) do
		v.grids:Delete()
	end

	for k,v in pairs(self.gridEntitys) do
		v:Delete()
	end
end

function BattleCollistionSystem:OnInitSystem()
    
end

function BattleCollistionSystem:OnLateInitSystem()
	for grid = 1,self.mapRow * self.mapCol do
		local row = FPMath.Divide(grid - 1,self.mapCol) + 1
		local col = (grid - 1) % self.mapCol + 1
		if not self.rowColToGrid[row] then
			self.rowColToGrid[row] = {}
		end
		self.rowColToGrid[row][col] = grid
		self.gridToRowCol[grid] = {row,col}
	end 
end

function BattleCollistionSystem:Init(gridBeginX,gridBeginZ)

end

function BattleCollistionSystem:GetGridEntitys(grid)
	return self.gridEntitys[grid]
end

function BattleCollistionSystem:GetRangeEntitys(beginGrid,endGrid)
	local entityGrids = self:GetRangeGrids(beginGrid,endGrid)
	local entityGroups = {}

	for i,grid in ipairs(entityGrids) do
		if self.gridEntitys[grid] then
			table.insert(entityGroups,self.gridEntitys[grid])
		end
	end

	return entityGroups
end

function BattleCollistionSystem:GetRangeGrids(beginGrid,endGrid)
	if not self.rangeToGrids[beginGrid] then
		self.rangeToGrids[beginGrid] = {}
	end

	if not self.rangeToGrids[beginGrid][endGrid] then
		local beginRow,beginCol = self.gridToRowCol[beginGrid][1],self.gridToRowCol[beginGrid][2]
		local endRow,endCol = self.gridToRowCol[endGrid][1],self.gridToRowCol[endGrid][2]

		local grids = {}
		for row = beginRow,endRow do
			for col = beginCol,endCol do
				local grid = self.rowColToGrid[row][col]
				table.insert(grids,grid)
			end
		end
		self.rangeToGrids[beginGrid][endGrid] = grids
	end

	return self.rangeToGrids[beginGrid][endGrid]
end

function BattleCollistionSystem:GetEntityGrids(entityUid)
	local grids = {}
	for v in self.entityGrids[entityUid].grids:Items() do
		local grid = v.value
		table.insert(grids,grid)
	end
	return grids
end

function BattleCollistionSystem:RemoveEntity(entity)
	local entityUid = entity.uid
	if not self.entityGrids[entityUid] then
		return
	end

	for v in self.entityGrids[entityUid].grids:Items() do
		local grid = v.value
		self.gridEntitys[grid]:RemoveByIndex(entityUid)
		if self.gridEntitys[grid].length <= 0 then
			self.gridEntitys[grid]:Delete()
			self.gridEntitys[grid] = nil
		end
	end

	self.entityGrids[entityUid].grids:Delete()
	self.entityGrids[entityUid] = nil

	if DEBUG_COLLISTION_OCCUPY_GRID then
		self:ActiveOccupyGrids(true)
	end
end

function BattleCollistionSystem:EntityAddToGrid(entity)
	local entityUid = entity.uid
    local pos = entity.TransformComponent:GetPos()
	local radius = entity.CollistionComponent:GetRadius()

	--local curGrid = self:PosToGrid(pos.x,pos.z)
	-- if self.entityGrids[entityUid] and self.entityGrids[entityUid].curGrid == curGrid then
	-- 	return
	-- end

	local beginGrid = self:PosToGrid(pos.x - radius,pos.z + radius)
    local endGrid = self:PosToGrid(pos.x + radius,pos.z - radius)

	local curEntityGrids = self.entityGrids[entityUid]
	if curEntityGrids and curEntityGrids.beginGrid == beginGrid and curEntityGrids.endGrid == endGrid then
		return
	end

	local rangeGrids = self:GetRangeGrids(beginGrid,endGrid)

	local removeGrids = {}
	if curEntityGrids then
		for v in curEntityGrids.grids:Items() do
			removeGrids[v.value] = true
		end
	else
		self.entityGrids[entityUid] = {}
		self.entityGrids[entityUid].beginGrid = 0
		self.entityGrids[entityUid].endGrid = 0
		self.entityGrids[entityUid].grids = SECBList.New()
	end

	for i,grid in ipairs(rangeGrids) do
		if not self.gridEntitys[grid] then
			self.gridEntitys[grid] = SECBList.New()
		end

		if not self.entityGrids[entityUid].grids:ExistIndex(grid) then
			self.entityGrids[entityUid].grids:Push(grid,grid)
			self.gridEntitys[grid]:Push(entityUid,entityUid)
		else
			removeGrids[grid] = nil
		end
	end

	for grid,_ in pairs(removeGrids) do
		self.entityGrids[entityUid].grids:RemoveByIndex(grid)
		self.gridEntitys[grid]:RemoveByIndex(entityUid)
	end

	self.entityGrids[entityUid].beginGrid = beginGrid
	self.entityGrids[entityUid].endGrid = endGrid

	if DEBUG_COLLISTION_OCCUPY_GRID then
		self:ActiveOccupyGrids(true)
	end
end

function BattleCollistionSystem:PosToGrid(x,z)
	local posInfo = self:GetPosToGridRowCol(x,z)
	return posInfo[1]
	--local row,col = self:PosToRowCol(x,z)
	--return self:RowColToGrid(row,col)
end

function BattleCollistionSystem:PosToRowCol(x,z)
	if x < self.mapBeginX then 
		x = self.mapBeginX
	elseif x > self.mapBeginX + self.mapWidth then 
		x = self.mapBeginX + self.mapWidth
	end

	if z > self.mapBeginZ then 
		z = self.mapBeginZ
	elseif z < self.mapBeginZ - self.mapHeight then 
		z = self.mapBeginZ - self.mapHeight
	end

	x = x - self.mapBeginX
	z = self.mapBeginZ - z

	local row = FPMath.Divide(z,self.mapGridSize) + 1
	if row > self.mapRow then row = self.mapRow end

	local col = FPMath.Divide(x,self.mapGridSize) + 1
	if col > self.mapCol then col = self.mapCol end

	return row,col
end

function BattleCollistionSystem:GetPosToGridRowCol(x,z)
	if not self.posToGridRowCol[x] then
		self.posToGridRowCol[x] = {}
	end

	if not self.posToGridRowCol[x][z] then
		local row,col = self:PosToRowCol(x,z)
		local grid = self:RowColToGrid(row,col)
		self.posToGridRowCol[x][z] = {grid,row,col}
	end

	return self.posToGridRowCol[x][z]
end

--行列从1开始
function BattleCollistionSystem:RowColToGrid(row,col)
	return self.rowColToGrid[row][col]
end

function BattleCollistionSystem:GetRowColByGrid(grid)
	return self.gridToRowCol[grid][1],self.gridToRowCol[grid][2]
end

function BattleCollistionSystem:ActivePreviewGrid(flag)
	self.world.BattleTerrainSystem:ActivePreviewGrid(flag,self.gridNum,self.mapRow,self.mapCol
		,self.mapGridSize,self.mapGridSize,self.mapBeginX,self.mapBeginZ,self:ToFunc("GetRowColByGrid"))
end

function BattleCollistionSystem:ActiveDebugGrid(flag)
	local mapRow = tonumber(self.mapHeight / 1000)
    local mapCol = tonumber(self.mapWidth / 1000)
	local gridNum = mapRow * mapCol

	self.world.BattleTerrainSystem:ActivePreviewGrid(flag,gridNum,mapRow,mapCol
		,1000,1000,self.mapBeginX,self.mapBeginZ,self:ToFunc("DebugGridRowColByGrid"))
end

function BattleCollistionSystem:DebugGridRowColByGrid(grid)
	local mapRow = tonumber(self.mapHeight / 1000)
    local mapCol = tonumber(self.mapWidth / 1000)
	local row = FPMath.Divide(grid - 1,mapCol) + 1
	local col = (grid - 1) % mapCol + 1
	return row,col
end

function BattleCollistionSystem:InitOccupyGrid()
    if self.occupyGridNode then
        return
    end
    
    self.occupyGridNode = BattleDefine.rootNode.transform:Find("grid/collistion_occupy_grid").gameObject
    self.occupyGridMeshFilter = self.occupyGridNode:GetComponent(MeshFilter)
    self.occupyGridMaterial = self.occupyGridNode:GetComponent(MeshRenderer).material

	local args = {}
    args.meshFilter = self.occupyGridMeshFilter
    args.material = self.occupyGridMaterial
    args.vertices = self.occupyGridVertices
    args.gridNum = self.gridNum
    args.onRowCol = self:ToFunc("GetRowColByGrid")
    args.maxRow = self.mapRow
    args.maxCol = self.mapCol
    args.width = self.mapGridSize
    args.height = self.mapGridSize
    args.beginX = self.mapBeginX
    args.beginZ = self.mapBeginZ
	args.posY = 0.02

    BattleUtils.CreateVerticeGrid(args)
end

function BattleCollistionSystem:InitDebugGrid()
    if self.debugGridNode then
        return
    end
    
    self.debugGridNode = BattleDefine.rootNode.transform:Find("grid/collistion_debug_grid").gameObject
    self.debugGridMeshFilter = self.debugGridNode:GetComponent(MeshFilter)
    self.debugGridMaterial = self.debugGridNode:GetComponent(MeshRenderer).material

	local args = {}
    args.meshFilter = self.debugGridMeshFilter
    args.material = self.debugGridMaterial
    args.vertices = self.debugGridVertices
    args.gridNum = self.gridNum
    args.onRowCol = self:ToFunc("GetRowColByGrid")
    args.maxRow = self.mapRow
    args.maxCol = self.mapCol
    args.width = self.mapGridSize
    args.height = self.mapGridSize
    args.beginX = self.mapBeginX
    args.beginZ = self.mapBeginZ
	args.posY = 0.03

    BattleUtils.CreateVerticeGrid(args)
end

function BattleCollistionSystem:ActiveOccupyGrids(flag)
	self:InitOccupyGrid()

	self.occupyGridNode:SetActive(flag)
    if not flag then
        return
	end

	for i=1,self.gridNum do
		local index = (i - 1) * 4
		local active = self.gridEntitys[i] and self.gridEntitys[i].length > 0 or false
		BattleUtils.SetRefreshVertice(self.occupyGridVertices,self.occupyRefreshGridVertices,index,active)
	end

	self.occupyGridMeshFilter.mesh.vertices = self.occupyRefreshGridVertices
	self.occupyGridMeshFilter.mesh:RecalculateNormals()
end


function BattleCollistionSystem:ActiveDebugGrids(flag,grids)
	self:InitDebugGrid()

	self.debugGridNode:SetActive(flag)
    if not flag then
        return
	end

	for i=1,self.gridNum do
		local index = (i - 1) * 4
		local active = grids[i] or false
		BattleUtils.SetRefreshVertice(self.debugGridVertices,self.debugRefreshGridVertices,index,active)
	end

	self.debugGridMeshFilter.mesh.vertices = self.debugRefreshGridVertices
	self.debugGridMeshFilter.mesh:RecalculateNormals()
end