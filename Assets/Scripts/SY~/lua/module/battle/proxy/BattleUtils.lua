BattleUtils = StaticClass("BattleUtils")


function BattleUtils.CalPerMilValue(value,pct)
	return value * VFactor(pct,1000)
end


function BattleUtils.CalMagnitude(x1,y1,x2,y2)
    return FPMath.Sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function BattleUtils.GetConfAttr(attrName)
    return GDefine.AttrNameToId[attrName] or BattleDefine.AttrNameToId[attrName]
end

function BattleUtils.CloneUnitData(baseAttrList,unitLevConf,unitStarConf,attrRatio)
    local attrs = {}

    --使用当前属性
    if attrRatio == 0 then
        local attrRatios = {}
        for i,v in ipairs(unitStarConf.attr_list) do
            attrRatios[v[1]] = v[2]
        end

        for i,v in ipairs(unitLevConf.attr_list) do
            local attrName = v[1]
            local attrId = GDefine.AttrNameToId[attrName]
            local attrVal = v[2]
    
            local ratio = attrRatios[attrName] or BattleDefine.AttrRatio
            local value = FPMath.Divide(attrVal * ratio,BattleDefine.AttrRatio)
            table.insert(attrs,{attr_id = attrId,attr_val = value})
        end
    else
        for i,v in ipairs(baseAttrList) do
            local attrVal = FPMath.Divide(v.attr_val * attrRatio,BattleDefine.AttrRatio)
            table.insert(attrs,{attr_id = v.attr_id,attr_val = attrVal})
        end
    end

    local skills = {}
    for i,v in ipairs(unitLevConf.skill_list) do
        local skillInfo = {}
        skillInfo.skill_id = v[1]
        skillInfo.skill_level = v[2]
        table.insert(skills,skillInfo)
    end

    local skillLevUp = {}
    for i,v in ipairs(unitStarConf.skill_lv_up) do
        local skillId = skills[v[1]].skill_id
        local skillLev = v[2]
        skillLevUp[skillId] = skillLev
    end

    local skillCover = {}
    for i,v in ipairs(unitStarConf.skill_cover) do
        skillCover[v[1]] = v[2]
    end

    for i = #skills, 1,-1 do
        local skillInfo = skills[i]
        if skillLevUp[skillInfo.skill_id] then
            skillInfo.skill_level = skillLevUp[skillInfo.skill_id]
        end

        if skillCover[skillInfo.skill_id] then
            if skillCover[skillInfo.skill_id] == 0 then
                table.remove(skills,i)
            else
                skillInfo.skill_id = skillCover[skillInfo.skill_id]
            end
        end
    end

    return attrs,skills
end


function BattleUtils.GetUnitAttrListByStar(starConf,lvConf)
    local attrList = {}
    local attrDatas = {}

    for i,v in ipairs(lvConf.attr_list) do
        local attrData = {attr_id = GDefine.AttrNameToId[v[1]],attr_val = v[2]}
        table.insert(attrList,attrData)
        attrDatas[attrData.attr_id] = attrData
    end

    for i,v in ipairs(starConf.attr_list) do
        local attrId = GDefine.AttrNameToId[v[1]]
        local ratio = v[2]
        local attrData = attrDatas[attrId]

        local value = attrData and attrData.attr_val or 0
        value = FPMath.Divide(value * ratio,BattleDefine.AttrRatio)

        if attrData then
            attrData.attr_val = value
        else
            table.insert(attrList,{attr_id = attrId,attr_val = value})
        end
    end

    return attrList
end

function BattleUtils.CloneUnitDataByAttrList(baseAttrList,unitLevConf,unitStarConf,attrList)
    local attrs = {}

	for i,v in ipairs(baseAttrList) do
		local attrVal = v.attr_val
		local customAttr = attrList and attrList[GDefine.AttrIdToName[v.attr_id]]
		if customAttr then
			if customAttr.fixedVal then
				attrVal = customAttr.fixedVal
			elseif customAttr.ratio then
				attrVal = FPMath.Divide(v.attr_val * customAttr.ratio,BattleDefine.AttrRatio)
			end
		end
		table.insert(attrs,{attr_id = v.attr_id,attr_val = attrVal})
	end

    local skills = {}
    for i,v in ipairs(unitLevConf.skill_list) do
        local skillInfo = {}
        skillInfo.skill_id = v[1]
        skillInfo.skill_level = v[2]
        table.insert(skills,skillInfo)
    end

    local skillLevUp = {}
    for i,v in ipairs(unitStarConf.skill_lv_up) do
        local skillId = skills[v[1]].skill_id
        local skillLev = v[2]
        skillLevUp[skillId] = skillLev
    end

    local skillCover = {}
    for i,v in ipairs(unitStarConf.skill_cover) do
        skillCover[v[1]] = v[2]
    end

    for i = #skills, 1,-1 do
        local skillInfo = skills[i]
        if skillLevUp[skillInfo.skill_id] then
            skillInfo.skill_level = skillLevUp[skillInfo.skill_id]
        end

        if skillCover[skillInfo.skill_id] then
            if skillCover[skillInfo.skill_id] == 0 then
                table.remove(skills,i)
            else
                skillInfo.skill_id = skillCover[skillInfo.skill_id]
            end
        end
    end

    return attrs,skills
end

function BattleUtils.CheckTerrainHit(pos)
	local ray = BaseUtils.ScreenPointToRay(BattleDefine.nodeObjs["main_camera"],pos)
    local isHit,hitInfo,b,c,d = BattleDefine.nodeObjs["terrain_collider"]:Raycast(ray,Mathf.Infinity)
    if not isHit then
        return false,nil
	else
		return true,hitInfo.point
    end
end

function BattleUtils.CreateVerticeGrid(args)
    local meshFilter = args.meshFilter
    local material = args.material

    local uv = {}
	local triangles = {}
    local vertices = args.vertices

    local gridNum = args.gridNum
    local onRowCol = args.onRowCol
    local maxRow = args.maxRow
    local maxCol = args.maxCol
    local width = args.width
    local height = args.height
    local beginX = args.beginX
    local beginZ = args.beginZ
    local posY = args.posY

    material:SetTextureScale("_MainTex",Vector2(maxCol,maxRow))

	for i=1,gridNum do
		local row,col = onRowCol(i)

		local x = (beginX + (( col - 1 ) * width)) * 0.001
        local y = posY
		local z = (beginZ - (( row - 1 ) * height)) * 0.001

		local index = (i - 1) * 4

		local pos = vertices[ index + 1 ] or Vector3()
		pos.x = x
		pos.y = y
		pos.z = z
		vertices[index + 1] = pos

		local x2 = x + ( width * 0.001 )
		local pos = vertices[ index + 2 ] or Vector3()
		pos.x = x2
		pos.y = y
		pos.z = z
		vertices[index + 2] = pos

		local z3 = z - ( height * 0.001 )
		local pos = vertices[ index + 3 ] or Vector3()
		pos.x = x
		pos.y = y
		pos.z = z3
		vertices[index + 3] = pos

		local x4 = x + ( width * 0.001 )
		local z4 = z - ( height * 0.001 )
		local pos = vertices[ index + 4 ] or Vector3()
		pos.x = x4
		pos.y = y
		pos.z = z4
		vertices[index + 4] = pos

        local pos = uv[ index + 1 ] or Vector2()
		pos.x = (col - 1) / maxCol
		pos.y = 1 - ((row - 1) / maxRow)
		uv[ index + 1 ] = pos

		local pos = uv[ index + 2 ] or Vector2()
		pos.x = col / maxCol
		pos.y = uv[ index + 1 ].y
		uv[ index + 2 ] = pos

		local pos = uv[ index + 3 ] or Vector2()
		pos.x = uv[ index + 1 ].x
		pos.y = 1 - ( row / maxRow)
		uv[ index + 3 ] = pos

		local pos = uv[ index + 4 ] or Vector2()
		pos.x = uv[ index + 2 ].x
		pos.y = uv[ index + 3 ].y
		uv[ index + 4 ] = pos

		local beginIndex = (i - 1) * 6
		triangles[beginIndex + 1] = index + 2
	    triangles[beginIndex + 2] = index + 0
	    triangles[beginIndex + 3] = index + 1
	    triangles[beginIndex + 4] = index + 2
	    triangles[beginIndex + 5] = index + 1
	    triangles[beginIndex + 6] = index + 3
	end

	meshFilter.mesh = Mesh()
	meshFilter.mesh.vertices = vertices
	meshFilter.mesh.triangles = triangles
	meshFilter.mesh.uv = uv
	meshFilter.mesh:RecalculateNormals()
end


function BattleUtils.SetRefreshVertice(vertices,refreshVertices,index,flag)
	local pos = refreshVertices[ index + 1 ] or Vector3()
	pos.x = flag and vertices[index + 1].x or 0
	pos.y = flag and vertices[index + 1].y or 0
	pos.z = flag and vertices[index + 1].z or 0
	refreshVertices[index + 1] = pos 

	local pos = refreshVertices[ index + 2 ] or Vector3()
	pos.x = flag and vertices[index + 2].x or 0
	pos.y = flag and vertices[index + 2].y or 0
	pos.z = flag and vertices[index + 2].z or 0
	refreshVertices[index + 2] = pos 

	local pos = refreshVertices[ index + 3 ] or Vector3()
	pos.x = flag and vertices[index + 3].x or 0
	pos.y = flag and vertices[index + 3].y or 0
	pos.z = flag and vertices[index + 3].z or 0
	refreshVertices[index + 3] = pos 

	local pos = refreshVertices[ index + 4 ] or Vector3()
	pos.x = flag and vertices[index + 4].x or 0
	pos.y = flag and vertices[index + 4].y or 0
	pos.z = flag and vertices[index + 4].z or 0
	refreshVertices[index + 4] = pos
end


function BattleUtils.GetReplayFile(fileName)
	local folder = nil
	if BaseSetting.channel == ChannelDefine.wxgame then
		return ""
	end

    if GDefine.platform == GDefine.PlatformType.Android or GDefine.platform == GDefine.PlatformType.IPhonePlayer then
        folder = BaseSetting.persistentPath .. "回放数据/"
    else
        folder = CS.System.Environment.GetFolderPath(CS.System.Environment.SpecialFolder.DesktopDirectory) .. "/回放数据/"
    end
	return IOUtils.GetAbsPath(folder .. fileName .. ".data")
end


--二次贝塞尔曲线
function BattleUtils.Curve2(beginPos,centerPos,endPos,t)
    return (beginPos * (FPFloat.Precision - t) + centerPos * t) * (FPFloat.Precision - t) + (centerPos * (FPFloat.Precision - t) + endPos * t) * t
end