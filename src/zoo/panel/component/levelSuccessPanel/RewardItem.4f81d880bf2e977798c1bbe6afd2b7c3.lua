


-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月18日 15:56:41
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- RewardItem
---------------------------------------------------

assert(not RewardItem)
assert(BaseUI)
RewardItem = class(BaseUI)

function RewardItem:init(ui, rewardId, isInterfaceBuilder,panelType, ...)
	assert(ui)
	assert(rewardId ~= nil)
	assert(#{...} == 0)

	-- Init Base Class
	BaseUI.init(self, ui)
	self.isInterfaceBuilder = isInterfaceBuilder
	self.panelType = panelType

	printx( 1 , "      WTFFFFFFFFFFFFFFFFFFFFFFFFFFF!!!!!!!!!!!!!!!!!!!!!!   panelType = " , panelType)
	-- ------------------
	-- Get UI Resource
	-- --------------------
	self.rewardIconPlaceholder	= self.ui:getChildByName("rewardIconPlaceholder")
	self.numberLabel		= self.ui:getChildByName("numberLabel")

	assert(self.rewardIconPlaceholder)
	assert(self.numberLabel)
	
	-- --------------------------
	-- Get Data About UI Resource
	-- ---------------------------
	self.placeHolderPos	= self.rewardIconPlaceholder:getPosition()
	local placeHolderSize	= self.rewardIconPlaceholder:getGroupBounds().size
	local halfWidth		= placeHolderSize.width / 2
	local halfHeight	= placeHolderSize.height / 2

	self.placeHolderCenter	= ccp(self.placeHolderPos.x + halfWidth, self.placeHolderPos.y - halfHeight)

	--------------------
	--- Get Data
	------------------
	--self.itemType	= itemType
	self.number	= 0
	self.rewardId	= rewardId

	--------------
	---- Update View
	-------------
	if self.rewardId then
		self:setRewardId(self.rewardId)
	else
		self:setVisible(false)
	end

	self.numberLabel:removeFromParentAndCleanup(false)
	self:addChild(self.numberLabel)
	if isInterfaceBuilder then
		self.numberLabel:setText(tostring(self.number))
	else
		self.numberLabel:setString(tostring(self.number))
	end

	if self.panelType == LevelSuccessPanelTpye.kOlympic then
		local numberLabelSize = self.numberLabel:getGroupBounds().size
		self.numberLabel:setPositionX( self.placeHolderPos.x - numberLabelSize.width - 15 )
		--self.numberLabel:setToParentRight()
	else
		self.numberLabel:setToParentCenterHorizontal()
	end
	
end

function RewardItem:getPlaceHolderCenterInParentSpace(...)
	assert(#{...} == 0)

	he_log_warning("a simple method, this may return wrong result, when this item is scaled !")
	local selfPos = self:getPosition()
	return ccp(selfPos.x + self.placeHolderCenter.x, selfPos.y + self.placeHolderCenter.y)
end

function RewardItem:setRewardId(rewardId, ...)
	assert(rewardId)
	assert(type(rewardId) == "number")
	assert(#{...} == 0)

	self:setVisible(true)
	self.rewardId = rewardId

	local rewardItem = nil 
	rewardItem = ResourceManager:sharedInstance():buildItemGroup(rewardId)
	self.rewardIconPlaceholder:setVisible(false)

	local placeHolderSize	= self.rewardIconPlaceholder:getGroupBounds().size
	local rewardItemSize	= rewardItem:getGroupBounds().size

	local deltaWidth	= placeHolderSize.width - rewardItemSize.width
	local deltaHeight	= placeHolderSize.height - rewardItemSize.height
	local halfDeltaWidth	= deltaWidth / 2
	local halfDeltaHeight	= deltaHeight / 2

	rewardItem:setPosition(ccp(self.placeHolderPos.x + halfDeltaWidth, self.placeHolderPos.y - halfDeltaHeight))
	self.ui:addChild(rewardItem)
end

function RewardItem:getRewardId(...)
	assert(#{...} == 0)

	return self.rewardId
end

function RewardItem:addNumber(deltaNumber, ...)
	assert(deltaNumber)
	assert(#{...} == 0)

	local curNumber = self.number
	local newNumber	= curNumber + deltaNumber

	if newNumber < 0 then newNumber = 0 end

	self.number = newNumber
	if self.isInterfaceBuilder then
		self.numberLabel:setText(tostring(self.number))
	else
		self.numberLabel:setString(tostring(self.number))
	end

	if self.panelType == LevelSuccessPanelTpye.kOlympic then
		local numberLabelSize = self.numberLabel:getGroupBounds().size
		self.numberLabel:setPositionX( self.placeHolderPos.x - numberLabelSize.width - 15 )
		--self.numberLabel:setToParentRight()
	else
		self.numberLabel:setToParentCenterHorizontal()
	end
	
end

function RewardItem:create(ui, rewardId, isInterfaceBuilder,panelType, ...)
	assert(ui)
	assert(rewardId ~= nil)
	assert(#{...} == 0)

	local newRewardItem = RewardItem.new()
	newRewardItem:init(ui, rewardId, isInterfaceBuilder,panelType)
	return newRewardItem
end
