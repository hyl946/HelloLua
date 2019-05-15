local IconTestBtnBase = class(IconButtonBase)

function IconTestBtnBase:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_activity_icon')
	IconButtonBase.init(self, self.ui)
end

IconTestBtnL1 = class(IconTestBtnBase)
function IconTestBtnL1:create()
	local instance = IconTestBtnL1.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_L_1)
	instance:init()
	return instance
end

IconTestBtnL2 = class(IconTestBtnBase)
function IconTestBtnL2:create()
	local instance = IconTestBtnL2.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_L_2)
	instance:init()
	return instance
end

IconTestBtnL3 = class(IconTestBtnBase)
function IconTestBtnL3:create()
	local instance = IconTestBtnL3.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_L_3)
	instance:init()
	return instance
end

IconTestBtnL4 = class(IconTestBtnBase)
function IconTestBtnL4:create()
	local instance = IconTestBtnL4.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_L_4)
	instance:init()
	return instance
end


IconTestBtnR1 = class(IconTestBtnBase)
function IconTestBtnR1:create()
	local instance = IconTestBtnR1.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_R_1)
	instance:init()
	return instance
end

IconTestBtnR2 = class(IconTestBtnBase)
function IconTestBtnR2:create()
	local instance = IconTestBtnR2.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_R_2)
	instance:init()
	return instance
end

IconTestBtnR3 = class(IconTestBtnBase)
function IconTestBtnR3:create()
	local instance = IconTestBtnR3.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_R_3)
	instance:init()
	return instance
end

IconTestBtnR4 = class(IconTestBtnBase)
function IconTestBtnR4:create()
	local instance = IconTestBtnR4.new()
	instance:initShowHideConfig(ManagedIconBtns.TEST_R_4)
	instance:init()
	return instance
end