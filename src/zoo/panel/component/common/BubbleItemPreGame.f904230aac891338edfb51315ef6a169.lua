require 'zoo.panel.component.common.BubbleItem'

BubbleItemPreGame = class(BubbleItem)

function BubbleItemPreGame:init(ui, itemType, isTimeProp)
	--assert(ui ~= nil)
	assert(ui)
	assert(type(itemType) == "number")


	self.isTimeProp = (isTimeProp == true)
	self.ui = ui

	if not self.ui then
		self.ui = ResourceManager:sharedInstance():buildGroup("common/bubbleItemPreGame")
	end

	if self.isTimeProp then
		self.numTip = getRedNumTip()
	else
	    self.numTip = getGreenNumTip()
	end
	self.numTip:setPositionXY(127, -25)

	--------------
	-- Init Base
	-- -----------
	BaseUI.init(self, self.ui)

	--------------
	-- Get UI Resouece
	--------------
	-- self.numberLabel	= self.ui:getChildByName("numberLabel")
	-- self.red_numberBg		= self.ui:getChildByName("red_numberBg")
	-- self.green_numberBg		= self.ui:getChildByName("green_numberBg")
	-- self.numberBg = self.green_numberBg
		



	self.bubble		= self.ui:getChildByName("bubble"):getChildByName('sprite')
	self.itemPlaceholder	= self.ui:getChildByName("itemPlaceholder")

	assert(self.bubble)
	assert(self.itemPlaceholder)

	----------------
	--- Get Data About UI
	----------------------
	self.itemPlaceholderPos 	= self.itemPlaceholder:getPosition()
	self.itemPlaceholderSize	= self.itemPlaceholder:getGroupBounds().size
	self.itemPlaceholderSize	= {width = self.itemPlaceholderSize.width, height = self.itemPlaceholderSize.height}

	self.bubbleOriginScaleX	= self.bubble:getScaleX()
	self.bubbleOriginScaleY	= self.bubble:getScaleY()

	self.centerX	= self.itemPlaceholderPos.x + self.itemPlaceholderSize.width / 2
	self.centerY	= self.itemPlaceholderPos.y - self.itemPlaceholderSize.height / 2

	-- ----------
	-- Get Data
	-- -----------
	self.itemType		= itemType
	self.isNumberVisible	= true
	
	self.BUBBLE_ANIM_STATE_NONE			= 1
	self.BUBBLE_ANIM_STATE_NORMAL_ANIM_PLAYING	= 2
	self.BUBBLE_ANIM_STATE_EXPLODED_ANIM_PLAYING	= 3
	self.BUBBLE_ANIM_STATE_TOUCHED_ANIM_PLAYING	= 4
	self.bubbleAnimState				= self.BUBBLE_ANIM_STATE_NONE


	self.itemNumberChangeCallback = false

	------------------
	-- Get Item Number
	-- --------------
	-- self.itemNumber	= UserManager:getInstance():getUserPropNumber(self.itemType)

	--马俊松修改 关卡内的道具和前置道具 显示的形式同步
	local realItemId = ItemType:getRealIdByTimePropId( self.itemType )
	self.itemNumber	= UserManager:getInstance():getAllTimePropNumberWithRealItemID( realItemId )
	if  self.itemNumber <= 0  then
		self.itemNumber	= UserManager:getInstance():getUserPropNumberWithAllType( self.itemType )
	end
	
	-----------------
	---- Init UI Resource
	--------------------
	self.itemPlaceholder:setVisible(false)

	if self.itemNumber == 0 then
		self:setNumberVisible(false)
	end

	self:checkVideoAdItem()

	-- -------------
	-- Update View
	-- -------------
	local realPropId = ItemType:getRealIdByTimePropId(self.itemType)

	local manualAdjustX	= -5
	local manualAdjustY	= 0

	local itemRes = nil

	local version = InciteManager:getSceneUIVersion(EntranceType.kStartLevel)
	local showVideoIcon = self.isVideoAdOpen and (
		version == 1  or
		(version == 2 and false) or
		version == 3)

	if showVideoIcon then
		itemRes = ResourceManager:sharedInstance():buildGroup("pre_item_video_ad")

		local ph = itemRes:getChildByName("ph")
		ph:setVisible(false)
		local pos = ph:getPosition()
		local size = ph:getGroupBounds().size

		local item = ResourceManager:sharedInstance():buildItemSprite(realPropId)
		itemRes:addChildAt(item, 2)

		local isize = item:getContentSize()
		local width = isize.width
		if self.itemType == 10087 then
			width = width - 40
		end
		item:setAnchorPoint(ccp(0.5, 0.5))
		item:setScale(size.width/width)
		item:setPosition(ccp(pos.x + size.width/2 - 2, pos.y - size.height/2 - 5))
		manualAdjustY = manualAdjustY - 10
		manualAdjustX = manualAdjustX + 6
		local size = itemRes:getGroupBounds().size
		itemRes:setContentSize(CCSizeMake(size.width, size.height))
		itemRes:ignoreAnchorPointForPosition(false)
	else
		itemRes	= ResourceManager:sharedInstance():buildItemSprite(realPropId)
	end

	self.itemRes = itemRes

	local itemResSize	= self.itemRes:getGroupBounds().size
	local halfDeltaWidth 	= (self.itemPlaceholderSize.width - itemResSize.width) / 2
	local halfDeltaHeight	= (self.itemPlaceholderSize.height - itemResSize.height) / 2
	local centerPosX	= self.itemPlaceholderPos.x + halfDeltaWidth
	local centerPosY	= self.itemPlaceholderPos.y - halfDeltaHeight

	centerPosX = centerPosX + manualAdjustX
	centerPosY = centerPosY + manualAdjustY

	self.itemRes:setPosition(ccp(centerPosX, centerPosY))
	self.ui:addChild(self.itemRes)
	self.ui:addChild(self.numTip)
	
	self.itemRes:setAnchorPointCenterWhileStayOrigianlPosition()

	self.numTip:setNum(self.itemNumber)
	--------------------
	-- Animation Data
	-- ------------------
	local data = {}
	self.data = data

	data[1] = {}
	data[1][1]	= {	28.95,	-4.50,	1.047,	1.047,	7}
	data[1][2]	= {	27.20,	4.75,	0.283,	0.283,	13}
	
	data[2] = {}
	data[2][1]	= {	7.55,	-19.40,	1.309,	1.309,	7}
	data[2][2]	= {	-2.20,	-14.85,	0.244,	0.244,	13}

	data[3]	= {}
	data[3][1]	= {	7.80,	-26.05,	0.566,	0.566,	7}
	data[3][2]	= {	0,	-25.55,	0.22,	0.22,	12}

	data[4] = {}
	data[4][1]	= {	9.0,	-45.90,	0.566,	0.566,	7}
	data[4][2]	= {	3.9,	-48.25,	0.178,	0.178,	12}

	data[5]	= {}
	data[5][1]	= {	9.7,	-51.20,	0.861,	0.861,	7}
	data[5][2]	= {	4.25,	-57.15,	0.209,	0.209,	12}

	data[6]	= {}
	data[6][1]	= {	37.5,	-62.7,	0.387,	0.387,	7}
	data[6][2]	= {	38.10,	-68.25,	0.278,	0.278,	11}

	data[7] = {}
	data[7][1]	= {	57.85,	-57.80,	1.309,	1.309,	7}
	data[7][2]	= {	65.40,	-65.35,	0.244,	0.244,	13}

	data[8] = {}
	data[8][1]	= {	60.45,	-51.20,	0.566,	0.566,	7}
	data[8][2]	= {	65.9,	-54.80,	0.275,	0.275,	12}

	data[9] = {}
	data[9][1]	= {	61.40,	-35.90,	0.387,	0.387,	7}
	data[9][2]	= {	66.45,	-36,	0.265,	0.265,	12}

	data[10] = {}
	data[10][1]	= {	62.40,	-10.25,	0.861,	0.861,	7}
	data[10][2]	= {	69.45,	-4.35,	0.276,	0.276,	13}

	------------------------------------------------------------
	------------------------------------------------------------

	data[11] = {}
	data[11][1] = { 32.15,	1.05,	1.413, 1.413,	7}
	data[11][2] = {	30.25,	19.30,	0.564,	0.564,	13}

	data[12] = {}
	data[12][1] = {	11.20,	-9.80,	0.973,	0.973,	7}
	data[12][2] = {	2.15,	-1.05,	0.421,	0.421,	13}

	data[13] = {}
	data[13][1] = { 7.30,	-10.70,	0.447,	0.447,	7}
	data[13][2] = { 1.55,	-6.05,	0.291,	0.291,	13}

	data[14] = {}
	data[14][1] = {	-2.65,	-30,	1.413,	1.413,	7}
	data[14][2] = {-18.55,	-27.50,	0.38,	0.38,	15}

	data[15] = {}
	data[15][1] = {-4.25,	-40.05,	0.424,	0.424,	7}
	data[15][2] = {-15.55,	-39.60,	0.181,	0.181,	13}

	data[16] = {}
	data[16][1] = {-7.30,	-42.30,	0.785,	0.785,	7}
	data[16][2] = {-14.80,	-43.25,	0.273,	0.273,	14}

	data[17] = {}
	data[17][1] = { -0.20,	-57.15,	0.424,	0.424,	7}
	data[17][2] = {-5,	-59.55,	0.255,	0.255,	13}

	data[18] = {}
	data[18][1] = {14.05,	-68.45,	1.031,	1.031,	7}
	data[18][2] = {8.65,	-76.20,	0.318,	0.318,	14}

	data[19] = {}
	data[19][1] = {65.35,	-56.55,	2.025, 2.025, 7}
	data[19][2] = {81.20,	-69.30,	0.438, 0.438, 15}

	data[20] = {}
	data[20][1] = {74.8,	-47.55,	0.447, 0.447,	7}
	data[20][2] = {82.55,	-49.70,	0.291,	0.291,	13}

	data[21] = {}
	data[21][1] = {72.65,	-19.65,	1.054, 1.054,	7}
	data[21][2] = {83.15,	-16.25,	0.302, 0.302,	13}

	data[22] = {}
	data[22][1] = {62.05,	-17.60,	0.608,	0.608,	7}
	data[22][2] = {67.80,	-12.60,	0.362,	0.362,	12}

	data[23] = {}
	data[23][1] = {66.85,	-8.30,	1.50,	1.50,	7}
	data[23][2] = {76.85,	-2.75,	0.52,	0.52,	14}

	data[24] = {}
	data[24][1] = {42.80,	-8.30,	0.608,	0.608,	7}
	data[24][2] = {44.35,	10.0,	0.412,	0.412,	14}

end

function BubbleItemPreGame:checkVideoAdItem()
	local realPropId = ItemType:getRealIdByTimePropId(self.itemId)
	local propData = MetaManager.getInstance().prop[realPropId]
	local toplevelId = UserManager.getInstance().user:getTopLevelId()
	local levelDataInfo = UserService.getInstance().levelDataInfo
	local levelInfo = levelDataInfo:getLevelInfo(toplevelId)
	local failTimes = 0
	local quitTimes = 0

	if levelInfo then
		failTimes = levelInfo.failTimes or 0
		quitTimes = levelInfo.quitTimes or 0
	end

	self.isVideoAdOpen = false
	--激励视频功能开启
	local isOpen = InciteManager:isStartLevelOpen({self.itemId, realPropId})
	-- RemoteDebug:uploadLogWithTag('videoItem()' .. self.itemId .. tostring(isOpen))
	if not isOpen then
		return
	end

	local version = InciteManager:getSceneUIVersion(EntranceType.kStartLevel)
	-- --最高关
	-- local isTopLevel = toplevelId == self.levelId
	-- --失败过
	-- local isFaild = failTimes > 0 or quitTimes > 0
	--物品已解锁
	local isItemUnlock = propData.unlock <= self.levelId
	--没有引导 
	local isNoGuide = (GameGuideData:sharedInstance():containInGuidedIndex(211)
					or UserManager:getInstance():hasGuideFlag(kGuideFlags.PreProps_MagicBird))

	-- local isOpen = isTopLevel and isFaild and isItemUnlock and isOpen and isNoGuide
	local isOpen = isItemUnlock and isOpen and isNoGuide

	-- print("BubbleItemPreGame:checkVideoAdItem()",version,isOpen,isTopLevel , isFaild , isItemUnlock  , isNoGuide)
	-- RemoteDebug:uploadLogWithTag('videoItem()'.. tostring(isOpen) ,"version,isOpen,isTopLevel , isFaild , isItemUnlock  , isNoGuide",version,isOpen,isTopLevel , isFaild , isItemUnlock  , isNoGuide,table.tostring(propData))


	if version then
		if version==1 then
			isOpen = isOpen
						--无道具
						and self.itemNumber == 0
		elseif version>=2 then
			if isOpen then

				local count = UserManager:getInstance():getUserPropNumber(self.itemId)
				-- RemoteDebug:uploadLogWithTag('videoItem()001',goodsID,count)
				if count>0 then
					--没有购物信息，且数量大于0，是限时魔力鸟，改为取普通魔力鸟的购物信息
					self.isVideoAdOpenV2 = true

					-- RemoteDebug:uploadLogWithTag('videoItem()111')

					
				-- elseif __ANDROID then
				-- 	--仅开放风车币支付渠道的免费广告。ios都是风车币支付，安卓需要判断
				-- 	local function handlePayment(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable, typeDisplay)
				-- 		--print("handlePayment()",decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable, typeDisplay)
				-- 		-- RemoteDebug:uploadLogWithTag('handlePayment()',decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable, typeDisplay)

				-- 		if decision == IngamePaymentDecisionType.kPayWithWindMill then
				-- 			self.isVideoAdOpen = true
				-- 			self.isVideoAdOpenV2 = true
				-- 			if self.waitAdState then
				-- 				local _ = self.initView and self:initView()
				-- 			end
				-- 		end
				-- 	end
				-- 	local goodsId = ItemType:getGoodsIDOfPreProps(self.itemId)
				-- 	local goodsIdInfo = goodsId and GoodsIdInfoObject:create(goodsId)
				-- 	--RemoteDebug:uploadLogWithTag('goodsIdInfo()',self.itemId,goodsId,table.tostring(goodsIdInfo))
				-- 	local _ = goodsIdInfo and PaymentManager.getInstance():getAndroidPaymentDecision(goodsIdInfo:getGoodsId(), goodsIdInfo:getGoodsType(), handlePayment)
				else
					self.isVideoAdOpenV2 = true

					-- RemoteDebug:uploadLogWithTag('videoItem()222')

				end

				if not self.isVideoAdOpenV2 then
					isOpen = false
				end
			end
		end
	end

				-- RemoteDebug:uploadLogWithTag('videoItem()rrr',self.isVideoAdOpen)

	self.isVideoAdOpen = isOpen
end

function BubbleItemPreGame:updateItemNumByRealData()
	self.itemNumber	= UserManager:getInstance():getUserPropNumber(self.itemType)
	if self.itemNumber == 0 then
		self:setNumberVisible(false)
	else
		self:setNumberVisible(true)
	end
	self.numTip:setNum(self.itemNumber)
end