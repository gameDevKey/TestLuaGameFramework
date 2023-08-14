TestAnimConfig = TestAnimConfig or {}

TestAnimConfig.anims = {}

--anim1
local anim = {}
anim.name = "anim1"
anim.nodes = {}
anim.rootId = 1

local node = {}
node.id = 1
node.class = "ParallelAnim"
node.childs = {2,3}
node.name = nil
anim.nodes[node.id] = node

local node = {}
node.id = 2
node.class = "ScaleAnim"
node.childs = {}
node.name = nil
node.path = "BtnEnterGame"
node.time = 3
node.toValue = Vector3(1,2,3)
anim.nodes[node.id] = node

local node = {}
node.id = 3
node.class = "RotationLocalAnim"
node.childs = {}
node.name = nil
node.path = "BtnEnterGame"
node.time = 3
node.toValue = Vector3(50,80,0)
anim.nodes[node.id] = node

table.insert(TestAnimConfig.anims,anim)


--anim2
local anim = {}
anim.name = "anim2"
anim.nodes = {}
anim.rootId = 4

local node = {}
node.id = 4
node.class = "ToAlphaAnim"
node.childs = {}
node.name = nil
node.path = "Version/VerionText"
node.time = 3
node.toAlpha = 0.5
node.component = Text
anim.nodes[node.id] = node

table.insert(TestAnimConfig.anims,anim)