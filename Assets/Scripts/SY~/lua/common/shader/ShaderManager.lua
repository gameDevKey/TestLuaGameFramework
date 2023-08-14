ShaderManager = SingleClass("ShaderManager")

function ShaderManager:__Init( )
    EventManager.Instance:AddEvent(EventDefine.preload_complete,self:ToFunc("OnPreloadComplete"))
    self.shaderLoader = nil
end


function ShaderManager:OnPreloadComplete()
    local shaders = {}
    --table.insert(shaders,{file = "shader/ui/outline_ex.shader", type = AssetType.Object} )
    -- table.insert(shaders,{file = "shader/vertexlitfastcutout.shader", type = AssetType.Object} )
    -- table.insert(shaders,{file = "shader/fastmatcap.shader", type = AssetType.Object} )
    table.insert(shaders,{file = "shader/SYPackages/character/character_lit.shader", type = AssetType.Object} )
    table.insert(shaders,{file = "shader/SYPackages/ShadersCache/Charactors/Toon/Toon_Lit.shader", type = AssetType.Object} )
    self.shaderLoader = AssetBatchLoader.New()
    self.shaderLoader:Load(shaders,self:ToFunc("OnShaderComplete"))
end

function ShaderManager:OnShaderComplete()
    local _ = self.shaderLoader:GetAsset("shader/SYPackages/character/character_lit.shader")
    AssetLoaderProxy.Instance:AddReference("shader/SYPackages/character/character_lit.shader")

    local _ = self.shaderLoader:GetAsset("shader/SYPackages/ShadersCache/Charactors/Toon/Toon_Lit.shader")
    AssetLoaderProxy.Instance:AddReference("shader/SYPackages/ShadersCache/Charactors/Toon/Toon_Lit.shader")

    -- self.vertexlitfastcutout = self.shaderLoader:GetAsset("shader/vertexlitfastcutout.shader")
    -- AssetLoaderProxy.Instance:AddReference("shader/vertexlitfastcutout.shader")

    -- self.unitShader = self.shaderLoader:GetAsset("shader/fastmatcap.shader")
    -- AssetLoaderProxy.Instance:AddReference("shader/fastmatcap.shader")

    -- self.heroShader = self.shaderLoader:GetAsset("shader/nprshading/shader/standardnpr.shader")
    -- AssetLoaderProxy.Instance:AddReference("shader/nprshading/shader/standardnpr.shader")
    
    self:RemoveLoader()
end

function ShaderManager:RemoveLoader()
    if self.shaderLoader then
        self.shaderLoader:Destroy()
        self.shaderLoader = nil
    end
end