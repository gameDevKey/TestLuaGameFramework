Controller = BaseClass("Controller",BaseModule)
Controller.__ctrl = true

function Controller:__Init()
	self:__InitCtrl()
end


function Controller:__InitCtrl() end
function Controller:__InitComplete() end
function Controller:__Clear() end