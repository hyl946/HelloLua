MissionBubbleItem = class(BasePanel)

MissionBubbleItemState = {
	
	kInProgress = 1,
	kDone = 2,
	kRewarded = 3,
}

local function checkTimeInToday(timestamp)
	if timestamp then
		if timestamp > 9999999999 then
			timestamp = math.floor( timestamp / 1000 )
		end

		local nowDate = os.date("%x", Localhost:timeInSec())
		local finishDate = os.date("%x", timestamp)
		
		return nowDate == finishDate
	end

	return false
end

local function checkTimeInSameDay(timestamp1 , timestamp2)
	if timestamp1 and timestamp2 then
		if timestamp1 > 9999999999 then
			timestamp1 = math.floor( timestamp1 / 1000 )
		end

		if timestamp2 > 9999999999 then
			timestamp2 = math.floor( timestamp2 / 1000 )
		end

		local day1 = os.date("%x", timestamp1)
		local day2 = os.date("%x", timestamp2)
		
		return day1 == day2
	end

	return false
end

function MissionBubbleItem:create(bubblePosition , onReward , onDoMission)
	local instance = MissionBubbleItem.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_1)
	--instance:loadRequiredResource(PanelConfigFiles.mission_2)
	instance:init(bubblePosition, onReward , onDoMission)
	return instance
end

function MissionBubbleItem:init(bubblePosition , onReward , onDoMission)
	local ui = self:buildInterfaceGroup("missionPanel_MissionItem")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)
	--ui:setPosition( ccp(-150 , 0) )
	self.bubblePosition = bubblePosition
	self.data = nil

	self.sprite_light = ui:getChildByName("sprite_light")
	self.uiWidth = self.sprite_light:getContentSize().width 

	self.label_progress = ui:getChildByName("label_progress")
	self.progressBar_fg = ui:getChildByName("progressBar_fg")
	self.progressBar_bg = ui:getChildByName("progressBar_bg")

	self.icon_done = ui:getChildByName("icon_done")
	
	self.rewardBtnRes	= self.ui:getChildByName("btn_reward")
	self.rewardBtn		= GroupButtonBase:create(self.rewardBtnRes)
	self.rewardBtn:setString("领取")

	self.doMissionBtnRes	= self.ui:getChildByName("btn_do")
	self.doMissionBtn		= GroupButtonBase:create(self.doMissionBtnRes)
	self.doMissionBtn:setString("前往")

	local function onRewardButtonTap(event)
		if onReward and type(onReward) == "function" then
			onReward(self.bubblePosition)
		end
	end

	local function onDoMissionButtonTap(event)
		if onDoMission and type(onDoMission) == "function" then
			onDoMission(self.bubblePosition)
		end
	end

	self.rewardBtn:addEventListener(DisplayEvents.kTouchTap, onRewardButtonTap)
	self.doMissionBtn:addEventListener(DisplayEvents.kTouchTap, onDoMissionButtonTap)

	self.label_titel = ui:getChildByName("label_titel")
	self.label_titel:setScale(0.6)
	self.label_titel:setPositionX( self.label_titel:getPosition().x + 20 )

	self.label_des = ui:getChildByName("label_des")
	self.label_des:setScale(0.7)
	self.label_des:setWidth(230)
	self.label_des:setLineBreakWithoutSpace(true)
	self.label_des:setAlignment(kCCTextAlignmentCenter)
	

	self.label_des_bg = ui:getChildByName("label_des_bg")

	self.label_num_1 = ui:getChildByName("label_num_1")
	self.sprite_item_1 = ui:getChildByName("sprite_item_1")
	self.sprite_item_Pos_1 = 
		ccp( self.sprite_item_1:getPosition().x , self.sprite_item_1:getPosition().y )
	self.sprite_item_Size_1 = 
		{ width=self.sprite_item_1:getContentSize().width , height=self.sprite_item_1:getContentSize().height}
	self.sprite_item_Index_1 = self.ui:getChildIndex( self.sprite_item_1 )
	self.sprite_item_1:removeFromParentAndCleanup(true)

	self.label_num_2 = ui:getChildByName("label_num_2")
	self.sprite_item_2 = ui:getChildByName("sprite_item_2")
	self.sprite_item_Pos_2 = 
		ccp( self.sprite_item_2:getPosition().x , self.sprite_item_2:getPosition().y )
	self.sprite_item_Size_2 = 
		{ width=self.sprite_item_2:getContentSize().width , height=self.sprite_item_2:getContentSize().height }
	self.sprite_item_Index_2 = self.ui:getChildIndex( self.sprite_item_2 )
	self.sprite_item_2:removeFromParentAndCleanup(true)

	self.sprite_bg = ui:getChildByName("sprite_bg")
	self.sprite_bg:setAnchorPoint(ccp(0.5,0.5))
	self.sprite_bg:setPosition(ccp( 196 , -185 ) ) 


	self.sprite_done_bg_1 = ui:getChildByName("sprite_done_bg_1")

	self.label_done = ui:getChildByName("label_done")
	self.label_done_originPos = ccp( self.label_done:getPosition().x , self.label_done:getPosition().y )
	self.label_done:setScale(0.7)
	self.label_done:setWidth(220)
	--self.label_done:setPreferredSize(220 , 50)

	self.label_done:setLineBreakWithoutSpace(true)
	self.label_done:setAlignment(kCCTextAlignmentCenter)

	self.label_done_bg = ui:getChildByName("label_done_bg")

	self.icon_done:setVisible(false)

	if self.bubblePosition ~= 1 then
		self.label_des:setColor(ccc3(255,255,255))

		self:playBubbleAnimation()
		self:stopLightAnimation()
	else
		self:stopBubbleAnimation()
		self:playLightAnimation()
	end

	self:updateState( MissionBubbleItemState.kRewarded )
end

function MissionBubbleItem:updateState(state)
	if self.state == state then
		--return
	end
	self.state = state
	if state == MissionBubbleItemState.kInProgress then
		if self.bubblePosition == 1 then
			self.sprite_light:setVisible(true)
		end
		self.sprite_bg:setVisible(true)

		self.doMissionBtn:setVisible(true)
		self.rewardBtn:setVisible(false)

		self.label_progress:setVisible(true)
		self.progressBar_fg:setVisible(true)
		self.progressBar_bg:setVisible(true)

		self.label_titel:setVisible(true)
		self.label_des:setVisible(true)
		self.label_des_bg:setVisible(false)

		self.label_num_1:setVisible(true)
		if self.itemIcon_1 then self.itemIcon_1:setVisible(true) end
		self.label_num_2:setVisible(true)
		if self.itemIcon_2 then self.itemIcon_2:setVisible(true) end

		self.sprite_done_bg_1:setVisible(false)
		self.label_done:setVisible(false)
		self.label_done_bg:setVisible(false)

		self.icon_done:setVisible(false)

		--self:playBubbleAnimation()
		--self:stopLightAnimation()
	elseif state == MissionBubbleItemState.kDone then
		if self.bubblePosition == 1 then
			self.sprite_light:setVisible(true)
		end
		self.sprite_bg:setVisible(true)

		self.doMissionBtn:setVisible(false)
		self.rewardBtn:setVisible(true)

		self.label_progress:setVisible(true)
		self.progressBar_fg:setVisible(true)
		self.progressBar_bg:setVisible(true)

		self.label_titel:setVisible(true)
		self.label_des:setVisible(true)
		self.label_des_bg:setVisible(false)

		self.label_num_1:setVisible(true)
		if self.itemIcon_1 then self.itemIcon_1:setVisible(true) end
		self.label_num_2:setVisible(true)
		if self.itemIcon_2 then self.itemIcon_2:setVisible(true) end

		self.sprite_done_bg_1:setVisible(false)
		self.label_done:setVisible(false)
		self.label_done_bg:setVisible(false)

		self.icon_done:setVisible(false)

		--self:stopBubbleAnimation()
		--self:playLightAnimation()
	elseif state == MissionBubbleItemState.kRewarded then

		--self:stopBubbleAnimation()
		--self:stopLightAnimation()

		self.sprite_light:setVisible(false)
		self.sprite_bg:setVisible(false)
		self.doMissionBtn:setVisible(false)
		self.rewardBtn:setVisible(false)

		self.label_progress:setVisible(false)
		self.progressBar_fg:setVisible(false)
		self.progressBar_bg:setVisible(false)

		self.label_titel:setVisible(false)
		self.label_des:setVisible(false)
		self.label_des_bg:setVisible(false)

		self.label_num_1:setVisible(false)
		if self.itemIcon_1 then self.itemIcon_1:setVisible(false) end
		self.label_num_2:setVisible(false)
		if self.itemIcon_2 then self.itemIcon_2:setVisible(false) end

		self.sprite_done_bg_1:setVisible(true)
		self.label_done:setVisible(true)
		self.label_done_bg:setVisible(false)
		self:setDoneDesText(5) --"没有更多任务啦"

		--[[
		if string.len( str ) > 21 then
			self.label_done_bg:setScale(1)
		else
			self.label_done_bg:setScale(1)
			self.label_done_bg:setScaleY(0.55)
			local widPerLen = 250/21
			local tarWid = string.len( str ) * widPerLen
			self.label_done_bg:setScaleX( tarWid / self.label_done_bg:getGroupBounds().size.width )
		end

		self.label_done_bg:setPositionX( ((self.ui:getGroupBounds().size.width - self.label_done_bg:getGroupBounds().size.width) / 2) + 10 )
		]]
		self.icon_done:setVisible(true)
	end

end

function MissionBubbleItem:getRewardIconGlobalPosition(propIndex)

	if self["itemIcon_" .. tostring(propIndex)] then
		local item = self["itemIcon_" .. tostring(propIndex)]
		if item then
			return self.ui:convertToWorldSpace( ccp( item:getPosition().x , item:getPosition().y) )
		end
	end

	return ccp(0,0)
end

function MissionBubbleItem:updateInfo(data)
	if not data then
		return
	end

	self.data = data

	self.label_titel:setText("." .. tostring(self.bubblePosition) .. ".")
	self.label_des:setText( tostring(data.des) )
	self.label_des:setPositionX( ( (self.uiWidth - (self.label_des:getContentSize().width * 0.7) ) / 2 ) - 5 )

	--[[
	if string.len( tostring(data.des) ) > 24 then
		self.label_des_bg:setScale(1)
	else
		self.label_des_bg:setScaleY(0.55)
		local widPerLen = 250/24
		local tarWid = string.len( tostring(data.des) ) * widPerLen
		self.label_des_bg:setScaleX( tarWid / self.label_des_bg:getGroupBounds().size.width )
	end

	self.label_des_bg:setPositionX( ((self.uiWidth - self.label_des_bg:getGroupBounds().size.width) / 2) + 10 )
	
	--printx( 1 , "   self.label_des_bg  -----------    " , self.label_des_bg:getGroupBounds().size.width )
	]]

	if self.state ~= MissionBubbleItemState.kRewarded then
		if self.itemIcon_1 then
			self.itemIcon_1:removeFromParentAndCleanup(true)
			self.itemIcon_1 = nil
		end

		if self.itemIcon_2 then
			self.itemIcon_2:removeFromParentAndCleanup(true)
			self.itemIcon_2 = nil
		end

		local function buildPropIcon(propIndex , propId)
			
			local icon = ResourceManager:sharedInstance():buildItemGroup(propId)
			self["itemIcon_" .. tostring(propIndex)] = icon
			
			icon:setAnchorPoint( ccp(0,1) )
			icon:setScale(0.7)

			icon:setPosition( ccp( 
				self["sprite_item_Pos_" .. tostring(propIndex)].x + ((self["sprite_item_Size_" .. tostring(propIndex)].width - icon:getGroupBounds().size.width)/2) , 
				self["sprite_item_Pos_" .. tostring(propIndex)].y - ((self["sprite_item_Size_" .. tostring(propIndex)].height - icon:getGroupBounds().size.height)/2) 
				) )
			if not self.progressBar_bg:isVisible() then
				icon:setPositionY( icon:getPositionY() + 15 )
			end
			self.ui:addChildAt( icon , self["sprite_item_Index_" .. tostring(propIndex)] )
		end

		if data.rewards then

			if #data.rewards == 2 then

				self.sprite_item_Pos_1.x = 59

				buildPropIcon( 1 , data.rewards[1].propId )
				
				if data.rewards[1].num > 99 then
					self.label_num_1:setScaleX(0.6)
					self.label_num_1:setScaleY(0.9)
					self.label_num_1:setPositionY( self.itemIcon_1:getPositionY() - 22 )
					self.sprite_item_Pos_1.x = 54
				else
					self.label_num_1:setScale(1)
					self.label_num_1:setPositionY( self.itemIcon_1:getPositionY() - 15 )
				end

				self.label_num_1:setText( "x" .. tostring(data.rewards[1].num) )
				self.label_num_1:setPositionX( self.sprite_item_Pos_1.x + 85 )

				buildPropIcon( 2 , data.rewards[2].propId )
				
				if data.rewards[2].num > 99 then
					self.label_num_2:setScaleX(0.6)
					self.label_num_2:setScaleY(0.9)
					self.label_num_2:setPositionY( self.itemIcon_2:getPositionY() - 22 )
					self.sprite_item_Pos_1.x = 54
				else
					self.label_num_2:setScale(1)
					self.label_num_2:setPositionY( self.itemIcon_2:getPositionY() - 15)
				end
				
				self.label_num_2:setText( "x" .. tostring(data.rewards[2].num) )
				self.label_num_2:setPositionX( self.itemIcon_2:getPositionX() + 58 )

			elseif #data.rewards == 1 then
				self.sprite_item_Pos_1.x = 110

				buildPropIcon( 1 , data.rewards[1].propId )
				
				if data.rewards[1].num > 99 then
					self.label_num_1:setScaleX(0.6)
					self.label_num_1:setScaleY(0.9)
					self.label_num_1:setPositionY( self.itemIcon_1:getPositionY() - 22 )
					self.sprite_item_Pos_1.x = 105
				else
					self.label_num_1:setScale(1)
					self.label_num_1:setPositionY( self.itemIcon_1:getPositionY() - 15 )
				end

				self.label_num_1:setText( "x" .. tostring(data.rewards[1].num) )
				self.label_num_1:setPositionX( self.sprite_item_Pos_1.x + 85 )

				self.label_num_2:setText( "" )

			end
		end
	end

	local str = "明日还有任务哦~"
	local strType = 1

	if self.bubblePosition == 4 then
		strType = 2
		--str = "领取任务1奖励后开启"
	else
		strType = 3
		--str = "联网领取任务"
	end

	local specialMissionDuration = math.floor( MissionLogic:getInstance():getSpecialMissionDuration() / 1000 )
	if data.createTime and data.createTime > 0 then
		if data.createTime > 9999999999 then
			data.createTime = math.floor( data.createTime / 1000 )
		end
		if data.createTime + specialMissionDuration < Localhost:timeInSec() then
			if self.bubblePosition == 4 then
				if checkTimeInToday(data.createTime) then
					strType = 4
					--str = "任务失败"
				else
					strType = 2
					--str = "领取任务1奖励后开启"
				end
			end
		end
	end

	if data.finishTime and data.finishTime > 0 then
		
		--  已完成  未开启  完成任务1开启
		if checkTimeInToday(data.finishTime) then
			
			if self.bubblePosition == 4 then

				if checkTimeInToday(data.createTime) then
					strType = 1
					--str = "明日还有任务哦~"
				else
					strType = 2
					--str = "领取任务1奖励后开启"
				end
				
			else
				strType = 1
				--str = "明日还有任务哦~"
			end
		else
			if self.bubblePosition == 4 then
				strType = 2
				--str = "领取任务1奖励后开启"
			else
				strType = 3
				--str = "联网领取任务"

				--没有更多任务啦~
				--请重新开启面板
			end
			
		end
	end

	--手机日期错误，请调整~
	self:setDoneDesText(strType)
	
	if not data.showDoButton then
		self.doMissionBtn:setVisible(false)
	end
	
end

function MissionBubbleItem:setDoneDesText(strType)
	local str = "明日还有任务哦~"
	if strType == 1 then
		str = "明日还有任务哦~"
		self.label_done:setPositionY( self.label_done_originPos.y )
	elseif strType == 2 then
		--str = "领取任务1奖励后开启"
		str = "    领取任务1    “奖励”后开启" --空格都是有用的
		self.icon_done:setVisible(false)
		self.label_done:setPositionY( self.label_done_originPos.y - 25 )
	elseif strType == 3 then
		str = "联网领取任务"
		self.icon_done:setVisible(false)
		self.label_done:setPositionY( self.label_done_originPos.y - 25 )
	elseif strType == 4 then
		str = "任务失败"
		self.icon_done:setVisible(false)
		self.label_done:setPositionY( self.label_done_originPos.y - 25 )
	elseif strType == 5 then
		str = "没有更多任务啦~"
		self.icon_done:setVisible(false)
		self.label_done:setPositionY( self.label_done_originPos.y - 25 )
	elseif strType == 6 then
		str = "请重新开启面板"
		self.icon_done:setVisible(false)
		self.label_done:setPositionY( self.label_done_originPos.y - 25 )
	end
	self.label_done:setText(str)
	self.label_done:setPositionX( 
		((self.uiWidth - (self.label_done:getContentSize().width * 0.7) ) / 2 ) - 5   )
	--if _G.isLocalDevelopMode then printx(0,  "RRRRRRR       " , self.label_titel:getContentSize().height ) end
end

function MissionBubbleItem:setAdditionalRewardVisible(showAdditionalReward)

	if self.state == MissionBubbleItemState.kRewarded then
		return 
	end
	
	if self.itemIcon_1 then
		self.itemIcon_1:setVisible(showAdditionalReward)
	end

	if self.label_num_1 then
		self.label_num_1:setVisible(showAdditionalReward)
	end
end

function MissionBubbleItem:updateProgress(currValue , targetValue)
	
	if currValue < 0 or self.state == MissionBubbleItemState.kRewarded then
		self.label_progress:setVisible(false)
		self.progressBar_fg:setVisible(false)
		self.progressBar_bg:setVisible(false)


		if self.itemIcon_1 then
			self.itemIcon_1:setPositionY( self.itemIcon_1:getPositionY() + 20 )
		end
		
		if self.itemIcon_2 then
			self.itemIcon_2:setPositionY( self.itemIcon_2:getPositionY() + 20 )
		end
	else
		self.label_progress:setVisible(true)
		self.progressBar_fg:setVisible(true)
		self.progressBar_bg:setVisible(true)

		if currValue > targetValue then
			currValue = targetValue
		end
		self.label_progress:setString( currValue .. "/" .. targetValue )
		self.progressBar_fg:setScaleX( currValue / targetValue )
	end

end

function MissionBubbleItem:playBubbleAnimation()
	local actArr = CCArray:create()
	actArr:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.9, 0.95 , 1) ) )
	actArr:addObject( CCEaseSineIn:create( CCScaleTo:create( 0.9, 1 , 0.95) ) )
	actArr:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.6, 1 , 1) ) )
	--actArr:addObject( CCEaseSineIn:create( CCScaleTo:create( 1, 0) ) )
	self.sprite_bg:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
end

function MissionBubbleItem:stopBubbleAnimation()
	self.sprite_bg:stopAllActions()
	self.sprite_bg:setScale(1,1)
end

function MissionBubbleItem:playLightAnimation()
	self.sprite_light:setVisible(true)
	local actArr = CCArray:create()
	actArr:addObject( CCEaseSineOut:create( CCFadeTo:create( 0.8, 100) ) )
	actArr:addObject( CCEaseSineIn:create( CCFadeTo:create( 0.8, 255) ) )
	self.sprite_light:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
end

function MissionBubbleItem:stopLightAnimation()
	self.sprite_light:stopAllActions()
	self.sprite_light:setVisible(false)
end

