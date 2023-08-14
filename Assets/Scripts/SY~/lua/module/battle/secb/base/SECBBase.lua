SECBBase = BaseClass("SECBBase")

function SECBBase:__Init()
    self.world = nil
    self.variables = {}
end

function SECBBase:__Delete()
end

function SECBBase:SetWorld(world)
    self.world = world
end

function SECBBase:InitVariable(key,value)
    if value then
        self[key] = value
        self.variables[key] = value
    else
        self.variables[key] = "nil"
    end
end

function SECBBase:ResetVariable()
    for key,value in pairs(self.variables) do
        if v == "nil" then
            self[key] = nil
        else
            self[key] = value
        end
    end
end