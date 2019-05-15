
local UIHelper = require 'zoo.panel.UIHelper'

local FLGRewardPanel = class(BasePanel)

local defaultGiftData = {
	sender = {
		profile = ProfileRef.new(),
	},
	rewards = {
		{itemId = 10086, num = 1},
		{itemId = 10086, num = 1},
		{itemId = 10086, num = 1},
		{itemId = 10086, num = 1},
	}
}

local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'


function FLGRewardPanel:create(giftData)
    local panel = FLGRewardPanel.new()
    panel:init(giftData or defaultGiftData)
    return panel
end

function FLGRewardPanel:init(giftData)
	self.giftData = giftData

	local ui = UIHelper:createUI("ui/get_rewards_bg.json", "get_rewards_bg/panel")
    UIUtils:adjustUI(ui, 222, nil, nil, 1724)
	BasePanel.init(self, ui)

    self.ui:getChildByPath('closeBtn_1'):setVisible(false)
    self.ui:getChildByPath('closeBtn_2'):setVisible(false)


	self.ui:getChildByPath('btn'):setVisible(false)
    self.ui:getChildByPath('label'):setVisible(false)


	local container = Layer:create()
	self.ui:addChild(container)
	container:setPositionY(-250)

    local animNode = UIHelper:createArmature2('skeleton/full_level_gift', 'FullLevelGift/anim')
    container:addChild(animNode)
    animNode:ad(ArmatureEvents.COMPLETE, function ( ... )
    	if self.isDisposed then return end
    	self:onAnimComplete(...)
    end)

    UIUtils:wrapNodeFunc(animNode, 'playByIndex', function ( _, actionIndex, playTimes )
    	if self.isDisposed then return end
    	self.animNode_actionIndex = actionIndex
    end)

    animNode:setPosition(ccp(169, -300))
    self.animNode = animNode


    local headIcon = Layer:create()
    headIcon:ignoreAnchorPointForPosition(false)
    headIcon:setAnchorPoint(ccp(0, 1))
    headIcon:changeWidthAndHeight(132, 132)
    UIHelper:loadUserHeadIcon(headIcon, giftData.sender.profile)
    headIcon:setPosition(ccp((180 - 132)/2, 180))


    local headIconCon = animNode:getCon('aft')
    headIconCon:addChild(headIcon.refCocosObj)
    self.headIconToDispose = headIcon

	local text2 = TextField:create("", nil, 30 , CCSizeMake(200, 0), kCCTextAlignmentCenter)
	UIHelper:setUserName(text2, giftData.sender.profile:getDisplayName())
	text2:setAnchorPoint(ccp(0.5, 0))
	text2:setPosition(ccp(180/2-2, 0))
	headIconCon:addChild(text2.refCocosObj)
	text2:dispose()


	local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/2@RewardItem')


    itemUI:setRewardItem(giftData.rewards[1])
    itemUI:setPositionX((188.9 - 176)/2)
    itemUI:setPositionY((193 + 178)/2)

    local iconCon = animNode:getCon('icon')
    iconCon:addChild(itemUI.refCocosObj)
    self.itemUI = itemUI
    itemUI:setPositionX(21)


    local inputLayer = LayerColor:createWithColor(hex2ccc3('FFFFFF'), 180, 180)
    inputLayer:setOpacity(false)
    inputLayer:setAnchorPoint(ccp(0.5, 0.5))
    inputLayer:ignoreAnchorPointForPosition(false)
    inputLayer:setPosition(ccp(160 + 285 + 35, -300 - 465 + 32))
    container:addChild(inputLayer)
    inputLayer:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(function ( ... )
    	if self.isDisposed then return end
    	self:onGetRewardBtn()
    end))
    self.inputLayer = inputLayer



    local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
    hand:setAnchorPoint(ccp(0, 1))
    hand:setPosition(ccp(90, 90))
    inputLayer:addChild(hand)
    self.hand = hand
end


local function clampRewardsNum( rewards )
    return table.map(function ( v )
        -- return {itemId = v.itemId, num = math.min(5, v.num)}

        if v.itemId == 2 or v.itemId == 14 then
        	return v
        end
        return {itemId = v.itemId, num = math.min(v.num, 16)}
    end, rewards)
end



function FLGRewardPanel:onAnimComplete( evt )
	if self.isDisposed then return end
	if self.animNode_actionIndex == 0 then
		self.inputLayer:setTouchEnabled(true)
	elseif self.animNode_actionIndex == 2 then
		self.animNode:playByIndex(3, 1)
	elseif self.animNode_actionIndex == 3 then
		local bounds = self.itemUI:getGroupBounds()		
		local anim = FlyItemsAnimation:create(
			clampRewardsNum(table.clone(self.giftData.rewards))
		)
		anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
		anim:play()

		self:_close()
		if self.yesCallback then
			self.yesCallback()
		end
	end
end


function FLGRewardPanel:showErrorTip(evt)
	local errcode = evt and evt.data or nil
	if errcode and tonumber(errcode) and tonumber(errcode) > 700000 then
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
		return true
	end
end

function FLGRewardPanel:onGetRewardBtn( ... )
	if self.isDisposed then return end

	DcUtil:UserTrack({category='TopLevelBonus', sub_category='Gift_Unpack'})	

	self.hand:setVisible(false)
	
	FLGLogic:recvGift(self.giftData, function ( ... )
		if self.isDisposed then return end
		if not self.__got then
			self.__got = true
			self.animNode:playByIndex(2, 1)
			self.inputLayer:setTouchEnabled(false)
		end
	end, function ( evt, hadGot )
    	if self.isDisposed then return end
    	self.ui:getChildByPath('closeBtn_2'):setVisible(true)

    	local noDefaultTip = self:showErrorTip(evt)

    	if not noDefaultTip then
			CommonTip:showTip(localize('recieve.panel.nointernet.tip'))
    	end

		self.hand:setVisible(true)

		if hadGot then
			self:_close()
		end
	end, function ( ... )
		if self.isDisposed then return end
		self.ui:getChildByPath('closeBtn_2'):setVisible(true)
		CommonTip:showTip(localize('recieve.panel.nointernet.tip'))
		self.hand:setVisible(true)
	end)
end

function FLGRewardPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function FLGRewardPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self:popoutShowTransition()
end


function FLGRewardPanel:popoutPush()
	PopoutQueue:sharedInstance():push(self, true)
end

function FLGRewardPanel:setCallback( yesCallback, noCallback )
	self.yesCallback = yesCallback
	self.noCallback = noCallback
	return self
end

function FLGRewardPanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	self.allowBackKeyTap = __WIN32
    self.animNode:playByIndex(0, 1)


    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    local vSize = Director:sharedDirector():getVisibleSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'

    -- layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn_1'), layoutUtils.MarginType.kTOP,  0)
    -- layoutUtils.setNodeRelativePos(self.ui:getChildByPath('closeBtn_2'), layoutUtils.MarginType.kTOP,  0)
    local closeBtn_1 = self.ui:getChildByPath('closeBtn_1')
    local closeBtn_2 = self.ui:getChildByPath('closeBtn_2')
    closeBtn_1:removeFromParentAndCleanup(false)
    closeBtn_2:removeFromParentAndCleanup(false)

    self.ui:addChild(closeBtn_1)
    self.ui:addChild(closeBtn_2)

    self.ui:getChildByPath('closeBtn_1'):setPosition(ccp(720, -600))
    self.ui:getChildByPath('closeBtn_2'):setPosition(ccp(720, -600))

end

function FLGRewardPanel:onCloseBtnTapped( ... )
	if self.isDisposed then return end

	FLGLogic:disableRecv()

	if self.noCallback then
		self.noCallback()
	end
    self:_close()
end

function FLGRewardPanel:dispose( ... )
	if self.isDisposed then return end
	-- body
	if self.itemUI and (not self.itemUI.isDisposed) then
		self.itemUI:dispose()
	end
	self.itemUI = nil


	if self.headIconToDispose and (not self.headIconToDispose.isDisposed) then
		self.headIconToDispose:dispose()
	end
	self.headIconToDispose = nil

	

	BasePanel.dispose(self, ...)
end


return FLGRewardPanel
