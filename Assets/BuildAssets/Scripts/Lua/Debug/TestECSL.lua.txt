print("---------创建实体")
local world = TestWorld.New()
local entity = world.EntityCreateSystem:CreateTestEntity()

print("---------实体执行逻辑")
entity:DoSomething()

print("---------世界update")
world:Update()

print("---------实体禁用组件")
entity.TestComponent:SetEnable(false)

print("---------世界update")
world:Update()

print("----------再创建一个实体")
local entity = world.EntityCreateSystem:CreateTestEntity()

print("---------世界update")
world:Update()

print("---------实体启用组件")
entity.TestComponent:SetEnable(true)

print("---------世界update")
world:Update()