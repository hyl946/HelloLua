
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê12ÔÂ17ÈÕ 11:46:00
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- UserPicture
---------------------------------------------------
UserPictureState = {
	EXPANDED	= 1,
	HIDEED		= 2,
	ANIMATING	= 3,
}

assert(not UserPicture)
assert(BaseUI)
UserPicture = class(BaseUI)


function UserPicture:init()
	--assert(#{...} == 0)
	
	self.headFrame = HeadFrameType:setProfileContext():getCurHeadFrame()
	self.state = UserPictureState.HIDEED

	self.isActivityHeadFrame = false
	self.headFrameExpire = 0

	-- if self.headFrame and table.exist(kHeadFrameEnum, tonumber(self.headFrame)) and self.headFrameExpire > 0 then
	-- 	self.isActivityHeadFrame = true
	-- end

	-- Get UI Resource 
	local resourceName = '2017_02_08/newUserIcon_2017_02_08'
	if self.isActivityHeadFrame then 
		resourceName = "newUserIcon_activity"
	end

	self.pic = ResourceManager:sharedInstance():buildGroup(resourceName)

	if not self.layer then 
		self.layer = Layer:create()
		BaseUI.init(self, self.layer)
	end
	self.layer:addChild(self.pic)

	-- ---------------
	-- Get UI Component
	-- ----------------
	self.newUserIcon	= self.pic:getChildByName("newUserIcon")
	self.label		= self.newUserIcon:getChildByName("label")
	self.userIcon		= self.newUserIcon:getChildByName("userIcon")
	if self.isActivityHeadFrame then 
		 local function convertSecondFormat(secs)
            --secs = math.floor(secs / 1000)
            local day = math.floor(secs / (3600*24))
            secs = secs - day*3600*24
            local hour = math.floor(secs/3600)
            secs = secs - hour*3600
            local min = math.floor(secs/60)
            --secs = secs - min*60
            --local sec = secs
            local str 
            if day > 0 then
            	if day > 9 then 
            		str = string.format("%02d天后", day)
            	else
            		str = string.format("%01d天后", day)
            	end
            else
            	if hour > 9 then 
            		str = string.format("%02d时%02d分", hour, min)
            	else
            		str = string.format("%01d时%02d分", hour, min)
            	end
            end
            return str
        end

		self.detailbg = self.pic:getChildByName("detailbg")
		self.detail1 = self.pic:getChildByName("detail1")
		self.detail2 = self.pic:getChildByName("detail2")
		self.detail1:setString(localize('head.frame.text.for.activity.' .. self.headFrame))
		self.detail2:setString(convertSecondFormat(tonumber(self.headFrameExpire)).."过期")
	
		self.size = self.detailbg:getContentSize()
		self.size = {width = self.size.width, height = self.size.height}
		self.detailbg:setPositionX(self.detailbg:getPositionX() - self.size.width)
		self.detail1:setPositionX(self.detail1:getPositionX() - self.size.width)
		self.detail2:setPositionX(self.detail2:getPositionX() - self.size.width)
		self:setDetailVisible(false)

  		self.clippingNode = SimpleClippingNode:create()
		self.pic:addChildAt(self.clippingNode, 1)
		self.clippingNode:setContentSize(CCSizeMake(300, 100))
		self.clippingNode:setRecalcPosition(true)
		self.detailbg:removeFromParentAndCleanup(false)
		self.detail1:removeFromParentAndCleanup(false)
		self.detail2:removeFromParentAndCleanup(false)
		self.clippingNode:addChild(self.detailbg)
		self.clippingNode:addChild(self.detail1)
		self.clippingNode:addChild(self.detail2)
		self.clippingNode:setVisible(false)
	end

	assert(self.newUserIcon)
	assert(self.label)
	assert(self.userIcon)

	-- self.userIcon:setVisible(false)
	self:updateProfile()

	local labelKey		= "user.picture"
	local labelValue	= Localization:getInstance():getText(labelKey, {})
	self.label:setString(labelValue)

	local function onUpdateProfile( evt )
		self:updateProfile()
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kProfileUpdate, onUpdateProfile)

	self.HIDDEN_DELTA = 4
	self.SHOW_DELTA = 99

	self.newUserIcon:setTouchEnabled(true)
	self.newUserIcon:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:onTapped()
		if UserManager.getInstance():hasPassedLevel(kMaxLevels) then
			local worldScene = HomeScene:sharedInstance().worldScene
			if worldScene then
				worldScene:onTopPictureClicked()
			end
		elseif not UserManager.getInstance():hasPassedLevel(kMaxLevels-1) then
		    local topLevel = UserManager:getInstance():getUserRef():getTopLevelId()
    		local noStack = not self.owner or not self.owner.levelFriendPicStacksByLevelId[topLevel]
        	local function checkShowInfo()
        		local noWin = not PopoutManager:sharedInstance():haveWindowOnScreen()
				if noWin and noStack then
		            require("zoo.PersonalCenter.FriendInfoPanel"):create()
		            DcUtil:UserTrack({category='ui', sub_category="G_my_card_click ",t1="0",t2=0}, true)
		        end
	        end
	        if noStack then
		        setTimeOut(checkShowInfo,0.3)
		    end
		end
	end)

end

function UserPicture:update()
	if self.pic then
		self.pic:removeFromParentAndCleanup(true)
		self.pic = nil
	end
	self.headUrl = nil
	self:init()
end

function UserPicture:updateProfile()
	local profile = UserManager.getInstance().profile
	if profile and profile.headUrl ~= self.headUrl then
		if self.clipping then self.clipping:removeFromParentAndCleanup(true) end
		local framePos = self.userIcon:getPosition()
		local frameSize = self.userIcon:getContentSize()

		local clipping =  HeadImageLoader:createWithFrame(profile.uid, profile.headUrl, nil, 2)
		local clippingSize = clipping:getContentSize()
		local iconSize = self.userIcon:getContentSize()
		local childIndex = self.newUserIcon:getChildIndex(self.userIcon)
		local scale = frameSize.width/clippingSize.width
		clipping:setScale(scale)
		clipping:setPosition(ccp(framePos.x + frameSize.width/2, framePos.y - frameSize.height/2))
		self.newUserIcon:addChildAt(clipping, childIndex)
		self.clipping = clipping
		self.headUrl = profile.headUrl	
		self.userIcon:setVisible(false)

	end
end

function UserPicture:setLabelVisible(visible, ...)
	assert(type(visible) == "boolean")
	assert(#{...} == 0)

	self.label:setVisible(visible)
end

function UserPicture:create(owner)
	--assert(#{...} == 0)

	local newUserPicture = UserPicture.new()
	newUserPicture.owner = owner
	newUserPicture:init()
	return newUserPicture
end

function UserPicture:onTapped(...)
	if self.isActivityHeadFrame then
		if self.state == UserPictureState.EXPANDED then 
			self.state = UserPictureState.ANIMATING
			self:hideDetailAnimation()
		elseif self.state == UserPictureState.HIDEED then 
			self.state = UserPictureState.ANIMATING
			self:showDetailAnimation()
		end
	end
end

function UserPicture:showDetailAnimation()
	if self.isActivityHeadFrame then
		self.clippingNode:setVisible(true) 
		self.pic:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.4),
			CCCallFunc:create(function() self.state = UserPictureState.EXPANDED end)))
		self.detailbg:runAction(CCSequence:createWithTwoActions(
			CCMoveTo:create(0.2, ccp(self.detailbg:getPositionX(), self.detailbg:getPositionY())),
			CCMoveTo:create(0.1, ccp(self.detailbg:getPositionX() + self.size.width, self.detailbg:getPositionY()))))
		self.detail1:runAction(CCSequence:createWithTwoActions(
			CCMoveTo:create(0.2, ccp(self.detail1:getPositionX(), self.detail1:getPositionY())),
			CCMoveTo:create(0.1, ccp(self.detail1:getPositionX() + self.size.width, self.detail1:getPositionY()))))
		self.detail2:runAction(CCSequence:createWithTwoActions(
			CCMoveTo:create(0.2, ccp(self.detail2:getPositionX(), self.detail2:getPositionY())),
			CCMoveTo:create(0.1, ccp(self.detail2:getPositionX() + self.size.width, self.detail2:getPositionY()))))

		self:setDetailVisible(true)
	end
end

function UserPicture:hideDetailAnimation()
	if self.isActivityHeadFrame then 
		self.pic:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.3),
			CCCallFunc:create(function() self.clippingNode:setVisible(false) self:setDetailVisible(false) self.state = UserPictureState.HIDEED end)))
		self.detailbg:runAction(CCMoveTo:create(0.2, ccp(self.detailbg:getPositionX() - self.size.width, self.detailbg:getPositionY())))
		self.detail1:runAction(CCMoveTo:create(0.2, ccp(self.detail1:getPositionX() - self.size.width, self.detail1:getPositionY())))
		self.detail2:runAction(CCMoveTo:create(0.2, ccp(self.detail2:getPositionX() - self.size.width, self.detail2:getPositionY())))
		self:setDetailVisible(true)
	end
end

function UserPicture:setDetailVisible(bVisible)
	self.detailbg:setVisible(bVisible)
	self.detail1:setVisible(bVisible)
	self.detail2:setVisible(bVisible)
end
