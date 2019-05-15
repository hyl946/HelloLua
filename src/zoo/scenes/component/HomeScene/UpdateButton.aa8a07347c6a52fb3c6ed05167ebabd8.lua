require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

UpdateButton = class(IconButtonBase)


function UpdateButton:create()
	local button = UpdateButton.new()
	button:init()
	return button
end

function UpdateButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_update')
    IconButtonBase.init(self, self.ui)
    
    self.up = self.ui:getChildByName("flag_arrow")
    self.up.posX = self.up:getPositionX()
    self.up.posY = self.up:getPositionY()

    self.rewardDot = self:addRedDotReward()
    
    self:setText()

    local rewards = nil
    if UserManager:getInstance().updateInfo then
        rewards = UserManager:getInstance().updateInfo.rewards
    end
    if type(rewards) == "table" and #rewards > 0 then
        self.rewardDot:setVisible(true)
        self:playRedDotJumpAni(self.rewardDot)
        self:playHasRewardAni()
    else
        self.rewardDot:setVisible(false)
    end
    self:startUpAnimation()
end

function UpdateButton:setVisible(value)
    IconButtonBase.setVisible(self,value)
    printx(0,"UpdateButton:setVisible()",value)
end

function UpdateButton:setText(status, percentage)
    printx(0,"UpdateButton:setText()",status, percentage)
    self:setVisible(true)
    if status == "wait" then
        --立即更新
        -- self.confirm:setString(Localization:getInstance():getText("new.version.button.download.zero"))

	elseif status == "ready" then
        --更新就绪
        local str = localize("new.version.button.ready")
        self:setCustomizedLabel(str)

		self:stopUpAnimation()

	elseif status == "ing" then
        local str = localize("new.version.button.processing", {percent = tostring(percentage)})
        self:setCustomizedLabel(str)
	else
		--立即更新
        local str = localize("new.version.icon")
        self:setCustomizedLabel(str)
	end
end

function UpdateButton:startUpAnimation()
	local arr = CCArray:createWithCapacity(2)

	arr:addObject(CCMoveBy:create(10 / 24,ccp(0,9)))
	arr:addObject(CCMoveBy:create(10 / 24,ccp(0,-9)))

	self.up:setPositionXY(self.up.posX,self.up.posY)
	self.up:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function UpdateButton:stopUpAnimation()
	self.up:stopAllActions()
	self.up:setPositionXY(self.up.posX,self.up.posY)
end
