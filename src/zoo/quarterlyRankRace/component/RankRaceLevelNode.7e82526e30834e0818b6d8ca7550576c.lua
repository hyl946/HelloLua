
local RankRaceLevelNode = class(BaseUI)

local NumPosConfig = {
	{x = 0, y = 140},	
	{x = 0, y = 140},	
	{x = 0, y = 140},	
	{x = 0, y = 140},	
	{x = 0, y = 140},	
	{x = 0, y = 185},	
}

local FlagPosConfig = {
	{x = -5, y = 224},	
	{x = -7, y = 224},	
	{x = -5, y = 224},	
	{x = -7, y = 224},	
	{x = -5, y = 224},	
	{x = -7, y = 282},	
}

local LockPosConfig = {
	{x = 10, y = 25},	
	{x = 8, y = 25},	
	{x = 10, y = 25},	
	{x = 8, y = 25},	
	{x = 10, y = 25},	
	{x = 90, y = 0},	
}

local function bIsInGoldExcludeIndexes( num )
    local ExtraGoldExcludeIndexes = RankRaceMgr.getInstance().data:getExtraGoldExcludeIndexes()
    if ExtraGoldExcludeIndexes and type(ExtraGoldExcludeIndexes) == 'table'  then
        for i,v in pairs(ExtraGoldExcludeIndexes) do
            if v == num then
                return true
            end
        end
    end

    return false
end

local function getDayStartTimeByTSCur(ts) --传入毫秒
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function RankRaceLevelNode:ctor()
end

function RankRaceLevelNode:init(ui, nodeIndex)
	self.ui = ui
	self.nodeIndex = nodeIndex
	BaseUI.init(self, ui)

	FrameLoader:loadArmature('skeleton/rank_race_flag', 'rank_race_flag', 'rank_race_flag')

	self.labelBarUI = self.ui:getChildByName("labelBar")
	if nodeIndex == 1 then 
		self.labelBarUI:setVisible(false)
	else
		local addLabel = BitmapText:create('', 'fnt/login_alert_cash_num.fnt')
    	addLabel:setAnchorPoint(ccp(0.5, 0.5))
    	self.labelBarUI:addChild(addLabel)
    	addLabel:setScale(1.5)
    	local addRate = RankRaceMgr.getInstance():getTargetBuff(nodeIndex)
    	addLabel:setText("+" .. addRate .. "%")
    	local barSize = self.labelBarUI:getChildByName("bg"):getContentSize()
    	addLabel:setPosition(ccp(barSize.width/2 - 20, -barSize.height/2 + 2))
	end

	self.nodeMainUI = self.ui:getChildByName("main")
	self.nodeDarkBg = self.nodeMainUI:getChildByName("dark")
	self.nodeLightBg = self.nodeMainUI:getChildByName("light")

	self.darkNum = Sprite:createWithSpriteFrameName("2018_s1_rank_race/part_level_node/cells/numD"..nodeIndex.."0000")
	self.lightNum = Sprite:createWithSpriteFrameName("2018_s1_rank_race/part_level_node/cells/numL"..nodeIndex.."0000")
	self.nodeMainUI:addChild(self.darkNum)
	self.darkNum:setPosition(ccp(NumPosConfig[nodeIndex].x, NumPosConfig[nodeIndex].y))
	self.nodeMainUI:addChild(self.lightNum)
	self.lightNum:setPosition(ccp(NumPosConfig[nodeIndex].x, NumPosConfig[nodeIndex].y))

	self.circleLight = self.ui:getChildByName("circleLight")
	self.circleLight:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	self.circleLight:setVisible(false)

	--初始化旗子
	self.flag = ArmatureNode:create('2018_s1_rank_race_flag/flag')
	self.flag:update(0.001)
	self.nodeMainUI:addChild(self.flag)
	self.flag:setPosition(ccp(FlagPosConfig[nodeIndex].x, FlagPosConfig[nodeIndex].y))

	self.tomorrowFlag = self.ui:getChildByName("flag")
	self.tomorrowFlag:setVisible(false)
	self.nodeLight = self.ui:getChildByName("nodeLight")
	self.nodeLight:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	self.nodeLight:setVisible(false)

	self.ui:setTouchEnabled(true, 0, false)
	self.ui:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onLevelNodeTap()
	end)


    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
    if self.nodeIndex == 6 then
        local labelBarY = self.ui:getChildByName("labelBarY")
        local icon = labelBarY:getChildByName("icon")
        local icon2 = labelBarY:getChildByName("icon2")

        if SaijiIndex == 1 then
            icon2:setVisible(false)
        else
            icon:setVisible(false)
        end
    else

        if SaijiIndex == 1 then
             --气泡
            local bubble = self.ui:getChildByName("bubble")
            bubble:setVisible(false)
        else
            --气泡
            local bubble = self.ui:getChildByName("bubble")
            bubble:setVisible(false)
            local bInExclude = bIsInGoldExcludeIndexes( self.nodeIndex )

            local pos = ccp(0,0)
            local NumPos = ccp(0,0)
            if self.nodeIndex==3 or self.nodeIndex==5 then
                pos = ccp(-30-19/0.7,62-8/0.7)
                NumPos = ccp(52-75/0.7,95)
            else
                pos = ccp(82-14/0.7,64-13/0.7)
                NumPos = ccp(64,90)
            end

            local addNum = RankRaceMgr.getInstance().data:getMetaValue('first_pass_gold_'..self.nodeIndex) or 0

            local GetNumlabel = TextField:create("x"..addNum, nil, 30)
	        GetNumlabel:setAnchorPoint(ccp(0, 0.5))
	        GetNumlabel:setPosition(NumPos)
            GetNumlabel:setColor( hex2ccc3('ff6601') )
	        bubble:addChild(GetNumlabel)

            local label = TextField:create("", nil, 30)
	        label:setAnchorPoint(ccp(0.5, 0.5))
	        label:setPosition(pos)
            label:setColor( hex2ccc3('ab6730') )
	        bubble:addChild(label)
                
            local function updateTime()

                local CurTime = Localhost:timeInSec()
                local TodayStartTime = getDayStartTimeByTSCur( Localhost:timeInSec() )
                local NextDayStartTime = TodayStartTime + 86400

                local CDTime = NextDayStartTime - CurTime
                if CDTime < 0 then
                    CDTime = 0
                    bubble:setVisible(false)
                end
            
                local time = convertSecondToHHMMSSFormat(CDTime)
                label:setString(time)
            end

            local array = CCArray:create()
            array:addObject(CCDelayTime:create(1))
            array:addObject(CCCallFunc:create(updateTime))
            label:runAction( CCRepeatForever:create( CCSequence:create(array) ) )

            updateTime()

            if not bInExclude and self.nodeIndex == RankRaceMgr.getInstance().data.unlockIndex then
                bubble:setVisible(true)
            end

            self.bubble = bubble
        end
    end

	self:update()
end

function RankRaceLevelNode:onLevelNodeTap()
	if self.nodeState == RankRaceMgr.LevelNodeState.kOpen then 
		if self.nodeTapCallback then self.nodeTapCallback() end
	else
		if RankRaceMgr.getInstance():isTomorrowSameWeek() and 
			RankRaceMgr.getInstance():getData().unlockIndex + 1 == self.nodeIndex then 
			CommonTip:showTip(localize("rank.race.main.4", {n = RankRaceMgr.getInstance():getData().unlockIndex}), "negative", nil, 3)
		else
			CommonTip:showTip(localize("rank.race.main.5"), "negative", nil, 3)
		end
	end
end

function RankRaceLevelNode:update()

    --刷新气泡
    if self.bubble then
        local bInExclude = bIsInGoldExcludeIndexes( self.nodeIndex )
        if not bInExclude and self.nodeIndex <= RankRaceMgr.getInstance().data.unlockIndex then
            self.bubble:setVisible(true)
        else
            self.bubble:setVisible(false)
        end
    end

    --获取地鼠宝石tip
    local function ShowGoldTip()
         RankRaceMgr.getInstance():tryShowGetGoldTip()
    end
    local seq = CCArray:create()
	seq:addObject(CCDelayTime:create(0.8))
	seq:addObject(CCCallFunc:create(ShowGoldTip))
	self.ui:runAction(CCSequence:create(seq))

	local nodeState = RankRaceMgr.getInstance():getLevelNodeSate(self.nodeIndex)
	if not self.nodeState then 
		self.nodeState = nodeState
		if nodeState == RankRaceMgr.LevelNodeState.kOpen then 		--初始化开
			self.nodeDarkBg:setVisible(false)
			self.darkNum:setVisible(false)
			self.flag:play("light", 0)

			self:updateNodeLightShow()
		elseif nodeState == RankRaceMgr.LevelNodeState.kLock then 	--初始化关
			self.nodeLightBg:setVisible(false)
			self.lightNum:setVisible(false)
			self.flag:play("dark", 0)
			if not self.lock then 
				self.lock = gAnimatedObject:createWithFilename("gaf/rank_race_lock/rank_race_lock.gaf")
				self.ui:addChild(self.lock)
				self.lock:setPosition(ccp(LockPosConfig[self.nodeIndex].x, LockPosConfig[self.nodeIndex].y))
				self.lock:gotoAndStop("p")
			end

			self:updateTomorrowShow()
		end
	else
		if nodeState == self.nodeState then 
			self:updateTomorrowShow()
			self:updateNodeLightShow()
			return 
		else
			self.nodeState = nodeState
			self:updateTomorrowShow()
			if nodeState == RankRaceMgr.LevelNodeState.kOpen then 		--关-->开
				self:playLockToOpen(function ()
					self:updateNodeLightShow()
				end)
			elseif nodeState == RankRaceMgr.LevelNodeState.kLock then 	--开-->关
				self.nodeDarkBg:setVisible(true)
				self.nodeLightBg:setVisible(false)
				self.darkNum:setVisible(true)
				self.lightNum:setVisible(false)
				self.flag:play("dark", 0)
				if not self.lock then 
					self.lock = gAnimatedObject:createWithFilename("gaf/rank_race_lock/rank_race_lock.gaf")
					self.ui:addChild(self.lock)
					self.lock:setPosition(ccp(LockPosConfig[self.nodeIndex].x, LockPosConfig[self.nodeIndex].y))
					self.lock:gotoAndStop("p")
				end
				self:updateNodeLightShow()
			end
		end
	end	


end

function RankRaceLevelNode:updateTomorrowShow()
	if self.isDisposed then return end
	local function showFlag()
		if not self.tomorrowFlag:isVisible() then 
			self.tomorrowFlag:setOpacity(0)
			self.tomorrowFlag:setVisible(true)
			self.tomorrowFlag:runAction(CCFadeTo:create(0.2, 255))
		end
	end

	local function hideFlag()
		if self.tomorrowFlag:isVisible() then 
			self.tomorrowFlag:stopAllActions()
			self.tomorrowFlag:setVisible(false)
		end
	end

	local leftFreeNum = RankRaceMgr.getInstance():getData().leftFreePlay or 0
	if leftFreeNum <= 0 and 
		self.nodeState == RankRaceMgr.LevelNodeState.kLock and 
		RankRaceMgr.getInstance():isTomorrowSameWeek() and 
		RankRaceMgr.getInstance():getData().unlockIndex + 1 == self.nodeIndex and 
		self.nodeIndex ~= 1 then 
		local calStatus = tonumber(RankRaceMgr.getInstance():getData():getStatus())
	    if calStatus and (calStatus == 2 or calStatus == 3) then 
	    	hideFlag() 
	    else
	    	showFlag()
	    end
	else
		hideFlag()
	end
end

function RankRaceLevelNode:updateNodeLightShow()
	if self.isDisposed then return end
	if self.nodeState == RankRaceMgr.LevelNodeState.kOpen and 
		RankRaceMgr.getInstance():getData().unlockIndex == self.nodeIndex then 
		if not self.nodeLight:isVisible() then 
			self.nodeLight:setVisible(true)
			self.nodeLight:setOpacity(0)
			
			local arr = CCArray:create()
			local arr1 = CCArray:create()
			local arr2 = CCArray:create()
			arr1:addObject(CCScaleTo:create(1, 1.05))
			arr1:addObject(CCFadeTo:create(1, 255))
			arr:addObject(CCSpawn:create(arr1))
			arr2:addObject(CCScaleTo:create(1, 1))
			arr2:addObject(CCFadeTo:create(1, 125))
			arr:addObject(CCSpawn:create(arr2))
			self.nodeLight:stopAllActions()
			self.nodeLight:runAction(CCRepeatForever:create(CCSequence:create(arr)))
		end
	else
		self.nodeLight:setScale(1)
		self.nodeLight:stopAllActions()
		self.nodeLight:setVisible(false)
	end
end

function RankRaceLevelNode:playLockToOpen(endCallback)
	local oneFrameTime = 1/30
	local delayTime1 = oneFrameTime * 24

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(delayTime1))
	arr:addObject(CCScaleTo:create(oneFrameTime * 3, 1, 0.825))
	arr:addObject(CCScaleTo:create(oneFrameTime * 6, 0.915, 1.175))
	arr:addObject(CCScaleTo:create(oneFrameTime * 5, 1.085, 0.883))
	arr:addObject(CCScaleTo:create(oneFrameTime * 4, 1, 1))
	if endCallback then 
		arr:addObject(CCDelayTime:create(oneFrameTime * 5))
		arr:addObject(CCCallFunc:create(endCallback))
	end
	self.nodeMainUI:stopAllActions()
	self.nodeMainUI:runAction(CCSequence:create(arr))

	local arr1 = CCArray:create()
	arr1:addObject(CCDelayTime:create(delayTime1))
	arr1:addObject(CCFadeTo:create(oneFrameTime * 6, 0))
	arr1:addObject(CCHide:create())
	self.nodeDarkBg:stopAllActions()
	self.nodeDarkBg:runAction(CCSequence:create(arr1))

	self.nodeLightBg:setOpacity(0)
	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(delayTime1))
	arr2:addObject(CCShow:create())
	arr2:addObject(CCFadeTo:create(oneFrameTime * 6, 255))
	self.nodeLightBg:stopAllActions()
	self.nodeLightBg:runAction(CCSequence:create(arr2))

	local arr3 = CCArray:create()
	arr3:addObject(CCDelayTime:create(delayTime1 + oneFrameTime * 2))
	arr3:addObject(CCShow:create())
	local oriScale = self.circleLight:getScaleX()
	arr3:addObject(CCScaleTo:create(oneFrameTime * 5, 1.23 * oriScale, 1.23 * oriScale))
	arr3:addObject(CCFadeTo:create(oneFrameTime * 13, 0))
	arr3:addObject(CCHide:create())
	self.circleLight:stopAllActions()
	self.circleLight:runAction(CCSequence:create(arr3))

	local arr4 = CCArray:create()
	arr4:addObject(CCDelayTime:create(delayTime1))
	arr4:addObject(CCFadeTo:create(oneFrameTime * 8, 0))
	arr4:addObject(CCHide:create())
	self.darkNum:stopAllActions()
	self.darkNum:runAction(CCSequence:create(arr4))

	self.lightNum:setOpacity(0)
	local arr5 = CCArray:create()
	arr5:addObject(CCDelayTime:create(delayTime1))
	arr5:addObject(CCShow:create())
	arr5:addObject(CCFadeTo:create(oneFrameTime * 6, 255))
	self.lightNum:stopAllActions()
	self.lightNum:runAction(CCSequence:create(arr5))

	self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime1 + oneFrameTime * 5), 
		CCCallFunc:create(function ()
			if self.flag then 
				self.flag:removeAllEventListeners()
				self.flag:addEventListener(ArmatureEvents.COMPLETE, function()
						self.flag:play("light", 0)
					end)
				self.flag:play("dtol", 1)
			end
		end)))

	if self.lock then 
		self.lock:playSequence("p", false, true, ASSH_RESTART)
		self.lock:setSequenceDelegate("p", function ()
			self.lock:removeFromParentAndCleanup(true)
			self.lock = nil
		end)
		self.lock:start()
	end
end

function RankRaceLevelNode:setNodeTapCallback(tapCallback)
	self.nodeTapCallback = tapCallback
end

function RankRaceLevelNode:dispose()
	BaseUI.dispose(self)
end

function RankRaceLevelNode:create(ui, nodeIndex)
	local node = RankRaceLevelNode.new()
	node:init(ui, nodeIndex)
	return node
end

return RankRaceLevelNode