SECBPluginSystem = BaseClass("SECBPluginSystem",SECBSystem)

function SECBPluginSystem:__Init()
    self.plugins = {}
end

function SECBPluginSystem:__Delete()
    for i,v in ipairs(self.plugins) do
        v:Delete()
    end
end

function SECBPluginSystem:OnLateInitSystem()
    self:OnInitPlugin()
end

function SECBPluginSystem:AddPlugin(pluginType)
    local name = pluginType.NAME or pluginType.__className
    local plugin = pluginType.New()
    plugin:SetWorld(self.world)
    self[name] = plugin
    table.insert(self.plugins,plugin)
end

--
function SECBPluginSystem:OnInitPlugin()
end