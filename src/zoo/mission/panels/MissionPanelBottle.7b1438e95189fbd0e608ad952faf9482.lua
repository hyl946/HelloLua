MissionPanelBottle = class(BasePanel)

function MissionPanelBottle:create()
	local instance = MissionPanelBottle.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_1)
	--instance:loadRequiredResource(PanelConfigFiles.mission_2)
	instance:init()
	return instance
end

function MissionPanelBottle:init()
	local ui = self:buildInterfaceGroup("missionPanel_Bottle")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)
	--ui:setPosition( ccp(-150 , 0) )
	self.top = ui:getChildByName("top")
	self.bottom = ui:getChildByName("bottom")
	self.uiWidth = self.top:getGroupBounds().size.width 

	self.text_progress = ui:getChildByName("text_progress")
	self.text_progress:setScale(0.5)
	self.text_progress:setWidth(230)
	self.text_progress:setLineBreakWithoutSpace(true)
	self.text_progress:setAlignment(kCCTextAlignmentCenter)
	self.text_progress:setText("0/3")

	--[[
	self.text_progress_des = ui:getChildByName("text_progress_des")
	self.text_progress_des:setScale(0.6)
	self.text_progress_des:setWidth(230)
	self.text_progress_des:setLineBreakWithoutSpace(true)
	self.text_progress_des:setAlignment(kCCTextAlignmentCenter)
	self.text_progress_des:setText("已完成")
	]]


	local water = ui:getChildByName("water")
	water:setAnchorPoint( ccp(0,0) ) 
	water:setPosition( ccp(0,0) )
	
	self.ui:removeChild(water , false)
	local stencilNode = CCLayerColor:create(
		ccc4(255,255,255,255), water:getContentSize().width + 100 , water:getContentSize().height)
	stencilNode:setPosition( ccp( -50 , -15 ) )
	local clipingnode = ClippingNode.new(CCClippingNode:create(stencilNode))
    clipingnode:addChild(water)

    self.maskedWater = clipingnode
    self.waterMask = stencilNode

    self.ui:addChildAt(self.maskedWater , 1)
    self.maskedWater:setPosition( ccp (24 , -365) )

	local wave = MissionAnimation:getInstance():createWaveAnimation()
	wave:setPosition( ccp(205,-180) )
	wave:setScaleX(1.01)
	self.ui:addChildAt(wave , 2)
	self.wave = wave
	self.waveLevel = 3


	self.items = {}
	self.itemContainer = Sprite:createEmpty()
	self.itemContainer:setPosition(ccp( 75 , -80 ))
	self.ui:addChildAt(self.itemContainer , 3)

	for i=1,4 do
		local item = Sprite:createEmpty()
		local ball = self:buildInterfaceGroup("missionPanel_waterBall")
		ball.icon = ball:getChildByName("icon")
		ball.text_num = ball:getChildByName("text_num")
		ball.bg = ball:getChildByName("bg")
		ball.icon:setPosition( ccp( ball.icon:getPosition().x - 6 , ball.icon:getPosition().y + 4) )
		ball.icon_Pos = ball.icon:getPosition()
		local rectSize = ball.icon:getGroupBounds().size
		ball.icon_Size = {width = rectSize.width, height = rectSize.height}
		--ball:setVisible(false)

		item:addChild(ball)
		item:setPosition(ccp( (i - 1) * 60 , 0 ))
		self.itemContainer:addChild(item)
		table.insert( self.items , ball )
		self:playWaterBallAnimation(ball , i)
	end

	self.maxWaterLevel = 3
	self:setWaveLevel(1 , true)

	self.ui:setTouchEnabled(true)
	self.ui:addEventListener(DisplayEvents.kTouchTap , function( ... ) self:onTouchTapped() end )
end

local waterBallPosition = {
	kFrame1 = {
		[1] = {x = 0 , y = 0} ,
		[2] = {x = 0 , y = -20} ,
		[3] = {x = 0 , y = -10} ,
		[4] = {x = 0 , y = 0} ,
	},
	kFrame2 = {
		[1] = {x = -10 , y = 10} ,
		[2] = {x = -15 , y = 0} ,
		[3] = {x = -5 , y = -15} ,
		[4] = {x = 0 , y = 0} ,
	},
	kFrame3 = {
		[1] = {x = -5 , y = -5} ,
		[2] = {x = -3 , y = -20} ,
		[3] = {x = 5 , y = 0} ,
		[4] = {x = 5 , y = 15} ,
	},
}

function MissionPanelBottle:playWaterBallAnimation(ball , ballIndex)
	local xy = waterBallPosition["kFrame1"][ballIndex]
	ball:setPosition( ccp( xy.x , xy.y ) )
	ball.playfarame = 1
	local ontime = function ()
		if ball.playfarame == 3 then
			ball.playfarame = 1
		else
			ball.playfarame = ball.playfarame + 1
		end

		local newpos = waterBallPosition["kFrame" .. tostring(ball.playfarame)][ballIndex]
		ball:setPosition( ccp( newpos.x , newpos.y ) )
	end

	local actArr = CCArray:create()
	actArr:addObject( CCDelayTime:create( 1/3 ) )
	actArr:addObject( CCCallFunc:create( ontime ) )
	ball:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
end

local wavePosition = {
	kLevel1 = {
		waterMaskY = -120,
		waveY = -282,
		waveScale = 1,
		itemContainerY = -200,
	},
	kLevel2 = {
		waterMaskY = -65,
		waveY = -227,
		waveScale = 1.05,
		itemContainerY = -150,
	},
	kLevel3 = {
		waterMaskY = -15,
		waveY = -180,
		waveScale = 1.01,
		itemContainerY = -100,
	},
}

function MissionPanelBottle:setWaveLevel(level , noAnime , callback)
	if level and type(level) == "number" then

		if level < 1 then level = 1 end
		if level > self.maxWaterLevel then level = self.maxWaterLevel end

		self.waveLevel = level

		self.waterMask:stopAllActions()
		self.wave:stopAllActions()

		local function onFin()

			self.text_progress:setText( tostring(self.waveLevel - 1) .. "/" .. tostring(self.maxWaterLevel) )
			self.text_progress:setPositionX( ( (self.uiWidth - (self.text_progress:getContentSize().width * 0.5) ) / 2 ) + 8 )

			if callback and type(callback) == "function" then
				callback()
			end
		end

		if noAnime then

			self.waterMask:setPosition(ccp(-50 , wavePosition["kLevel" .. tostring(level)].waterMaskY))

			self.wave:setPosition(ccp(self.wave:getPosition().x , wavePosition["kLevel" .. tostring(level)].waveY))
			self.wave:setScaleX(wavePosition["kLevel" .. tostring(level)].waveScale)

			self.itemContainer:setPosition(
				ccp( self.itemContainer:getPosition().x , wavePosition["kLevel" .. tostring(level)].itemContainerY  ))
			onFin()
		else

			local actArr = CCArray:create()
			actArr:addObject( CCEaseSineOut:create( 
				CCMoveTo:create( 1 , ccp( -50 , wavePosition["kLevel" .. tostring(level)].waterMaskY ) ) 
				) )
			actArr:addObject( CCCallFunc:create( onFin ) )
			self.waterMask:runAction( CCSequence:create(actArr) )

			self.wave:runAction( 
				CCEaseSineOut:create( CCMoveTo:create( 1 , 
					ccp( self.wave:getPosition().x , wavePosition["kLevel" .. tostring(level)].waveY ) ) ) )
			self.wave:runAction( 
				CCEaseSineOut:create( CCScaleTo:create( 1 , wavePosition["kLevel" .. tostring(level)].waveScale , 1 ) ) )

			self.itemContainer:runAction( 
				CCEaseSineOut:create( CCMoveTo:create( 1 , 
					ccp( self.itemContainer:getPosition().x , wavePosition["kLevel" .. tostring(level)].itemContainerY ) ) ) )

		end

		
	end
end

function MissionPanelBottle:getWaveLevel()
	return self.waveLevel or 1
end

function MissionPanelBottle:updateWaterBall(index , itemData)

	local ball = self.items[index]

	assert(ball, "MissionPanelBottle:updateWaterBall  ball is nil   index = " .. tostring(index) )

	if ball.propIcon then
		ball.propIcon:removeFromParentAndCleanup(true)
		ball.propIcon = nil
	end

	if itemData.isFriut then
		ball.icon:setVisible(true)
		ball.text_num:setVisible(false)
	else
		ball.icon:setVisible(false)

		local propIcon = nil
		local function buildItemGroup()
			propIcon = ResourceManager:sharedInstance():buildItemGroup( tonumber( itemData.itemId ) )
		end
		
		pcall(buildItemGroup)

		if propIcon then
			propIcon:setAnchorPoint( ccp(0,1) )
			propIcon:setScale(0.7)
			
			propIcon:setPosition( ccp( 
				ball.icon_Pos.x - 0 + ((ball.icon_Size.width - propIcon:getGroupBounds().size.width)/2) , 
				ball.icon_Pos.y + 0 - ((ball.icon_Size.height - propIcon:getGroupBounds().size.height)/2) 
			) )
			ball:addChild( propIcon )
			ball.propIcon = propIcon
			ball.propIcon:getChildAt(0):setOpacity(0)

			if itemData.num and itemData.num < 9 then
				ball.text_num:setVisible(true)
				ball.text_num:setText("x" .. tostring(itemData.num))
			else
				ball.text_num:setVisible(false)
			end
		else
			ball.text_num:setVisible(false)
		end
	end

end

function MissionPanelBottle:buildItems(items)
	assert(items, "MissionPanelBottle:buildItems  items is nil")
	assert(#items == 3, "MissionPanelBottle:buildItems  items num must be 3   , " .. tostring(#items))

	self.bottleReward = items
	local itemList = {}
	for k1,v1 in pairs(items) do
		table.insert( itemList , v1 )
	end

	local rewardIds = {}
	for k, v in pairs(itemList) do
		rewardIds[k] = v.itemId
	end
	self.rewardIds = rewardIds

	local friutIndex = math.random(4)
	local realItems = {}
	for i = 1 , 4 do
		if i == friutIndex then
			table.insert( realItems , {isFriut = true} )
		else
			table.insert( realItems , itemList[#itemList] ) -- {itemId = 10004 , num = 1}
			table.remove( itemList , #itemList )
		end
	end

	--printx( 1 , " WTF    !!!!!!!!!!!!!!!!!!!!!!!   " , table.tostring(realItems))

	for i = 1 , 4 do
		local itemData = realItems[i]

		self:updateWaterBall(i , itemData)
	end

	self:showBalls()
end

function MissionPanelBottle:onTouchTapped()

	if not self.bottleReward then
		self.bottleReward = {}
	end

	local tipData = {}
	for k, v in ipairs(self.bottleReward) do
		local itemId = ItemType:getRealIdByTimePropId( v.itemId )
		table.insert(tipData, {itemId = itemId, num = v.num})
	end
	local tipPanel = BoxRewardTipPanel:create({ rewards=tipData })
	local text = Localization:getInstance():getText("mission.missionPanel.bottle.tips",
													{curr=tonumber(self.waveLevel - 1),total=self.maxWaterLevel})

	tipPanel:setTipString(text)
	
	self.ui:addChild(tipPanel)
	local bounds = self.top:getGroupBounds()
	tipPanel:setArrowPointPositionInWorldSpace( bounds.size.width/2 , bounds:getMidX() , bounds:getMidY() )
end

function MissionPanelBottle:showBalls(callback)
	for i=1,4 do
		
		local ball = self.items[i]

		if ball then

			ball.bg:runAction( CCFadeTo:create(0.5 , 255) )
			ball.icon:runAction( CCFadeTo:create(0.5 , 255) )
			if ball.propIcon then
				ball.propIcon:getChildAt(0):runAction( CCFadeTo:create(0.5 , 255) )
			end
			ball.text_num:runAction( CCFadeTo:create(0.5 , 255) )
		end

	end

	setTimeOut( function () 
			if callback and type(callback) == "function" then
				callback()
			end
		end , 0.5 )
end

function MissionPanelBottle:hideBalls(callback)
	for i=1,4 do
		
		local ball = self.items[i]

		if ball then

			ball.bg:runAction( CCFadeTo:create(0.5 , 0) )
			ball.icon:runAction( CCFadeTo:create(0.5 , 0) )
			if ball.propIcon then
				ball.propIcon:getChildAt(0):runAction( CCFadeTo:create(0.5 , 0) )
			end
			ball.text_num:runAction( CCFadeTo:create(0.5 , 0) )
		end

	end

	setTimeOut( function () 
			if callback and type(callback) == "function" then
				callback()
			end
		end , 0.5 )
	
end