
local WeeklyExtraTargetBar = class(BaseUI)

function WeeklyExtraTargetBar:create()
	local target = WeeklyExtraTargetBar.new()
	target:init()
	return target
end

function WeeklyExtraTargetBar:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function WeeklyExtraTargetBar:unloadRequiredResource()
	if self.panelConfigFile then
		InterfaceBuilder:unloadAsset(self.panelConfigFile)
	end
end

function WeeklyExtraTargetBar:init()
	FrameLoader:loadArmature('skeleton/weekly_2018s1_target', 'weekly_2018s1_target', 'weekly_2018s1_target')

	self:loadRequiredResource("flash/weekly/WeeklyTarget.json")
	self.ui = self.builder:buildGroup("weekly_target_2017_s4/keyGroup")
	BaseUI.init(self, self.ui)

	for i=1,4 do
		local keyUI = self.ui:getChildByName("key"..i)
		self["keyLight"..i] = keyUI:getChildByName("light")
		self["keyLight"..i]:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		self["keyLight"..i]:setVisible(false)
		self["keyDark"..i] = keyUI:getChildByName("dark")
	end

	self.curTargetIndex = 0
end

function WeeklyExtraTargetBar:showGetTarget()
	self.curTargetIndex = self.curTargetIndex + 1
	for i=1,4 do
		if i < self.curTargetIndex then 
			self["keyLight"..i]:setVisible(true)
		elseif i == self.curTargetIndex then
			local ani = ArmatureNode:create('2018_s1_target_anim/ani_show_key')
			self["keyLight"..i]:setVisible(true)
			self["keyLight"..i]:setOpacity(0)

			self["keyLight"..i]:addChild(ani)
			ani:setPosition(ccp(-3, 53))

			ani:addEventListener(ArmatureEvents.COMPLETE, function ()
				self["keyLight"..i]:setOpacity(255)
				ani:removeFromParentAndCleanup(true)
			end)
			ani:play("a", 1)

			-- self["keyLight"..i]:setScale(0)
			-- local arr = CCArray:create()
			-- arr:addObject(CCFadeTo:create(0.3, 255))
			-- arr:addObject(CCScaleTo:create(0.3, 1.2))
			-- self["keyLight"..i]:stopAllActions()
			-- self["keyLight"..i]:runAction(CCSequence:createWithTwoActions(CCSpawn:create(arr), CCScaleTo:create(0.1, 1)))
		end
	end
end

function WeeklyExtraTargetBar:getPassTargetNum()
	return self.curTargetIndex	
end

function WeeklyExtraTargetBar:dispose()
	if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
	BaseUI.dispose(self)
end

return WeeklyExtraTargetBar