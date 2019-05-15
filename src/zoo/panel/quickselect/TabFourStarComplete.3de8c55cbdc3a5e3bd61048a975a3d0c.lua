require 'zoo.panel.component.common.VerticalScrollable'

SpecialVScrollable = class(VerticalScrollable)

function SpecialVScrollable:ctor()

end

function SpecialVScrollable:init(width, height, useClipping, useBlockingLayers)
	VerticalScrollable.init(self, width, height, useClipping, useBlockingLayers)
end

function SpecialVScrollable:create(width, height, useClipping, useBlockingLayers)
	local vs = SpecialVScrollable.new()
	vs:init(width, height, useClipping, useBlockingLayers, specialPartSize)
	return vs
end

function SpecialVScrollable:onTouchEnd(event)
	self.last_y = event.globalPosition.y
	self.last_x = event.globalPosition.x

	if not self:isIgnoreHorizontalMove() then
		-- if move not started, or if horizontal move, then return
		if not self:checkMoveStarted(self.last_x, self.last_y) 
			or self:getScrollDirection() ~= ScrollDirection.kVertical 
		then 
			return 
		end
	end

	for i, v in ipairs(self.speedometers) do
		v:stopMeasure()
	end

	self.yOffset = self.container:getPositionY()
	local speed = self:getSwipeSpeed()
	if self.yOffset > self.topMostOffset then
		self:__moveTo(self.topMostOffset, 0.3)
	elseif self.yOffset < self.bottomMostOffset + self.height then 
		if self.upDir then 
			self:__moveTo(self.bottomMostOffset + self.height, 0.3)
		else
			self:__moveTo(self.bottomMostOffset, 0.3)
		end
	elseif speed ~= 0 then
		self:slide(speed)
	end
	self:updateContentViewArea()
end

function SpecialVScrollable:slide(speed)
	local scheduler = Director:sharedDirector():getScheduler()
	local resistance = 500
	local duration = math.abs(speed / resistance)
	local distance = speed / resistance * 1500

	local function __unschdule()
		print ('__unschdule')
		if self.schedId ~= nil then
			scheduler:unscheduleScriptEntry(self.schedId)
			self.schedId = nil
		end
	end

	local action = CCSequence:createWithTwoActions(
	                CCEaseExponentialOut:create(
	                 CCMoveBy:create(duration, ccp(0, distance))
	                 ),
	                CCCallFunc:create(__unschdule)
	              	)

	self.container:runAction(action)

	local function __check()
		if _G.isLocalDevelopMode then printx(0, '__check') end
		if not self.isDisposed then 
			self.yOffset = self.container:getPositionY()
			if self.yOffset > self.topMostOffset then

				self.container:stopAllActions()
				self:__moveTo(self.topMostOffset, 0.3)
				__unschdule()
			elseif self.yOffset < self.bottomMostOffset + self.height then
				self.container:stopAllActions()
				if self.upDir then 
					self:__moveTo(self.bottomMostOffset + self.height, 0.3)
				else
					self:__moveTo(self.bottomMostOffset, 0.3)
				end
				__unschdule()
			end
			self:updateContentViewArea()
		else 
			__unschdule()
		end
	end
	__unschdule()
	if self.schedId == nil then 
		self.schedId = scheduler:scheduleScriptFunc(__check, 1/60, false)
	end
end


--------------------------TabFourStarComplete----------------------------
TabFourStarComplete = class(Layer)

function TabFourStarComplete:ctor()
	
end

function TabFourStarComplete:initLayer()
	Layer.initLayer(self)

	--容器layer
	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)

	--分享部分
	local sharePartUI = self.hostPanel:buildInterfaceGroup("tabFourStarLevelContent")
	sharePartUI:getChildByName("level_rect"):setVisible(false)
	local sharePartSize = sharePartUI:getGroupBounds().size
	local panelScale = self.hostPanel:getScale()
	local _width = sharePartSize.width
	local _height = sharePartSize.height 

	local shareArea = sharePartUI:getChildByName("share_area")
	local shareBtn = GroupButtonBase:create(shareArea:getChildByName("btn"))
	shareBtn:setString(Localization:getInstance():getText("share.feed.button.achive"))
	local function onShareBtnTap( evt )
		DcUtil:shareAllFourStarClick()
		self:onShareBtnTap()
	end
	shareBtn:addEventListener(DisplayEvents.kTouchTap, onShareBtnTap)
	layer:addChild(sharePartUI)

	--滚动部分
	local level_vertical_scrollable = SpecialVScrollable:create(_width, _height, true, false)
	sharePartUI.scrollable = level_vertical_scrollable

	local posY2NodeMap = {}


	--关卡花部分
	local dataList = FourStarManager:getInstance():getFourStarLevels()
	local offset_x = nil
	local x_index = nil
	local cell_size = CCSizeMake(150, 175)
	local context = self
	for i=1,#dataList do
		local data = dataList[i]
        local flowerType = kFlowerType.kFourStar
        if JumpLevelManager.getInstance():hasJumpedLevel( data.level ) then
        	flowerType = kFlowerType.kJumped
        end
		local node = FlowerNodeUtil:createWithSize(flowerType, data.level, data.star, cell_size,true)
		node.levelId = data.level
		node:setTouchEnabled(true, 0, true)
		
		local function onTapped( evt )	
			local pos = evt.globalPosition
			if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
				local levelId = node.levelId
				if levelId <= UserManager.getInstance().user:getTopLevelId() then
					context:onShowLevelStartPanel()
					local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
				    startGamePanel:popout(false)
				else
					CommonTip:showTip(Localization:getInstance():getText("fourstar_tips"), 1)
				end
			else
				-- if _G.isLocalDevelopMode then printx(0, "-------------------") end
			end
		end
		node:ad(DisplayEvents.kTouchTap, onTapped)

		if not x_index then
			x_index = math.floor(_width/cell_size.width)
			offset_x = (_width - x_index*cell_size.width) / (x_index - 1)
		end
		local x_p = ((i- 1)%x_index ) * (cell_size.width + offset_x) - 0
		node:setPositionX(x_p)
		local y_p = (-math.floor((i-1)/x_index)*cell_size.height) - _height
		node:setPositionY(y_p)

		local y_index = math.floor(y_p + 0.5)
		posY2NodeMap[y_index] = posY2NodeMap[y_index] or {}
		table.insert(posY2NodeMap[y_index], node)

		node.scrollable = level_vertical_scrollable
		layer:addChild(node)
	end

	layer.updateViewArea = function ( _, top, bottom )
		
		for y_index, nodeGrp in pairs(posY2NodeMap) do
			local v = true
			if -y_index >= top - cell_size.height - 20 and -y_index <= bottom + cell_size.height + 20 then
				v = true
			else
				v = false
			end

			for _, node in pairs(nodeGrp) do
				if node.isDisposed then return end
				node:setVisible(v)
			end
		end
		
	end

	level_vertical_scrollable:setContent(layer)
	self:addChild(level_vertical_scrollable)
end

function TabFourStarComplete:onShowLevelStartPanel()
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self.hostPanel:onCloseBtnTapped()
end

function TabFourStarComplete:onShareBtnTap()
	self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

	local shareCallback = {
		onSuccess = function(result)
			self:onShareSucceed()
		end,
		onError = function(errCode, errMsg)
			self:onShareFailed()
		end,
		onCancel = function()
			self:onShareFailed()
		end,
	}
	local function endCallback()
		local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
		local shareType, delayResume = SnsUtil.getShareType()
		SnsUtil.sendImageMessage( shareType, nil, nil, thumb, self.shareImagePath, shareCallback )
	end

	ShareManager:createFourStarShareImg(endCallback)
end


function TabFourStarComplete:onShareFailed()
	local scene = Director:sharedDirector():getRunningScene()
	if scene then
		local shareFailedLocalKey = "share.feed.faild.tips"
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
	 		shareFailedLocalKey = "share.feed.faild.tips.mitalk" 
	 	end
		CommonTip:showTip(Localization:getInstance():getText(shareFailedLocalKey), 'negative', nil, 2)
	end
end

function TabFourStarComplete:onShareSucceed()
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kMiTalk) 
 	else
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kWechat)
 	end
end

function TabFourStarComplete:create(hostPanel)
	local layer = TabFourStarComplete.new()
	layer.hostPanel = hostPanel
	layer:initLayer()
	return layer
end