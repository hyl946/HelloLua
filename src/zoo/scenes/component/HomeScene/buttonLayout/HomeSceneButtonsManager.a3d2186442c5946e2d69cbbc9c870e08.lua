local RightPositionConfig = {
	[1] = {
		[1] = {c = 1, r = 2},
	},
	[2] = {
		[2] = {c = 1, r = 3},
		[1] = {c = 1, r = 2}, 
	},
	[3] = {
		[3] = {c = 1, r = 4},
		[2] = {c = 1, r = 3},
		[1] = {c = 1, r = 2},  
	},
	[4] = {
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2}, 
	},
	[5] = {
							  [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
							  
	},
	[6] = {
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[7] = {
							  [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[8] = {
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[9] = {
						      [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[10] = {
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[11] = {
							   [11] = {c = 1, r = 7},
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[12] = {
		[12] = {c = 2, r = 7}, [11] = {c = 1, r = 7},
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[13] = {
							   [13] = {c = 1, r = 8},
		[12] = {c = 2, r = 7}, [11] = {c = 1, r = 7},
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[14] = {
		[14] = {c = 2, r = 8}, [13] = {c = 1, r = 8},
		[12] = {c = 2, r = 7}, [11] = {c = 1, r = 7},
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[15] = {
								[15] = {c = 1, r = 9},
		[14] = {c = 2, r = 8}, [13] = {c = 1, r = 8},
		[12] = {c = 2, r = 7}, [11] = {c = 1, r = 7},
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
	[16] = {
		[16] = {c = 2, r = 9}, [15] = {c = 1, r = 9},
		[14] = {c = 2, r = 8}, [13] = {c = 1, r = 8},
		[12] = {c = 2, r = 7}, [11] = {c = 1, r = 7},
		[10] = {c = 2, r = 6}, [9] = {c = 1, r = 6},
		[8] = {c = 2, r = 5}, [7] = {c = 1, r = 5},
		[6] = {c = 2, r = 4}, [5] = {c = 1, r = 4},
		[4] = {c = 2, r = 3}, [2] = {c = 1, r = 3}, 
		[3] = {c = 2, r = 2}, [1] = {c = 1, r = 2},
	},
}

local function getPositionByRowColumnIndex(r, c)
	local rowMargin = 5
	local rowHeight = 110
	local colMargin = 5
	local colWidth = 110
	local ox = 15
	local oy = 20

	return ccp(-(colMargin * (c - 1) + (c - 1) * colWidth), (rowMargin * r + (r - 1) * rowHeight))
end



HomeSceneButtonsManager = class()

HomeSceneButtonType = table.const{
	kNull = 0,
	kBag = 1,
	kFriends = 2,
	kTree = 3,
	kMail = 4,
	kStarReward = 5,
	kMark = 6,
    kCdkeyBtn = 7,
	kMission = 8,
	kRealName = 9,
	kWDJRemove = 10,
	kWXJPHub = 11,
	kWXJPGroup = 12,
	kMiTalkRemove = 13,
	kOppoLaunch = 14,
	kAchieve = 15,
}

local instance = nil
function HomeSceneButtonsManager.getInstance()
	if not instance then
		instance = HomeSceneButtonsManager.new()
		instance:init()
	end
	return instance
end

function HomeSceneButtonsManager:init()
	self.btnGroupBar = nil
	self.allBtnTypeTable = {}
	self.finalBtnTypeTable = {}
	self.widthDelta = 118
	self.heightDelta = 134
	self.xOriPos = -75
	self.yOriPos = 70
	self.bgSizeWidth = 180
	self.bgSizeHeight = 134
	self.btns = {}

	self.container = Layer:create()
	HomeScene:sharedInstance():addChild(self.container)

	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local btnSize = {width = 110, height = 110}
	local _x = visibleOrigin.x + visibleSize.width - btnSize.width + 40
	local _y = visibleOrigin.y + btnSize.height - 35
	self.container:setPosition(ccp(_x, _y))
	self.container:setVisible(false)

end
 
function HomeSceneButtonsManager:addBtnToContainer(iconInstance)
	if iconInstance:getParent() then
		printx(3, 'HomeSceneButtonsManager:addBtn 错误', iconInstance.indexKey)
		iconInstance:removeFromParentAndCleanup(false)
	end
	self.container:addChild(iconInstance)
end

-- anchorIsCenter: icon的anchor是否是中心(不同的anchor后面对齐的时候是不同的)
function HomeSceneButtonsManager:addBtn(iconInstance, anchorIsCenter)
	printx(3, 'HomeSceneButtonsManager:addBtn', iconInstance.indexKey)
	assert(iconInstance)
	assert(not iconInstance.isDisposed)
	for k, v in pairs(self.btns) do
		if v.ui.indexKey == iconInstance.indexKey then
			printx(3, '重复添加按钮', iconInstance.indexKey)
			printx(3, debug.traceback())
			--debug.debug()
		end
	end
	if not anchorIsCenter then
		anchorIsCenter = false -- 大部分的icon都是左上角
	end

	-- 禁用tip
	if iconInstance.disableTip then
		iconInstance:disableTip()
	end
	iconInstance:stopOnlyTipAnim()

	table.insert(self.btns, {ui = iconInstance, anchorIsCenter = anchorIsCenter})
	
	self:addBtnToContainer(iconInstance)
	self:sortBtns()
end

function HomeSceneButtonsManager:removeBtnByRef(ref)
	for k, v in pairs(self.btns) do
		if v.ui == ref then
			table.remove(self.btns, k)
			v.ui:removeFromParentAndCleanup(false)
		end
	end
	self:sortBtns()
end

function HomeSceneButtonsManager:removeBtnsBySide(side)
	local newBtns = {}
	for k, v in pairs(self.btns) do
		printx(3, 'removeBtnsBySide', side, v.ui.indexKey, v.ui.homeSceneRegion)
		if v.ui.homeSceneRegion ~= side then
			table.insert(newBtns, v)
		else
			v.ui:removeFromParentAndCleanup(false)
		end
	end
	self.btns = newBtns
	self:sortBtns()
end

function HomeSceneButtonsManager:getButtonCount()
	-- return #self.allBtnTypeTable
	return #self.btns
end

function HomeSceneButtonsManager:getBarBgSize()
	return self.bgSizeWidth, self.bgSizeHeight	
end

function HomeSceneButtonsManager:getBtns()
	return self.finalBtnTable
end

function HomeSceneButtonsManager:sortBtns()
	local function _sort(v1, v2)
		return v1.ui.showPriority > v2.ui.showPriority
	end
	table.sort(self.btns, _sort)
	self.finalBtnTable = {}
	local count = #self.btns

	if not RightPositionConfig[count] then
		return
	end

	local config = RightPositionConfig[count]
	for k, v in pairs(config) do
		if self.finalBtnTable[v.r] == nil then
			self.finalBtnTable[v.r] = {}
		end
	end

	for i, v in ipairs(self.btns) do
		local btnConfig = {}
		btnConfig.btn = v.ui
		local posConfig = getPositionByRowColumnIndex(config[i].r, config[i].c)
		btnConfig.posX, btnConfig.posY = posConfig.x, posConfig.y
		btnConfig.anchorIsCenter = v.anchorIsCenter
		-- printx(3, config[i].r, self.finalBtnTable[config[i].r])
		table.insert(self.finalBtnTable[config[i].r], btnConfig)
	end

end

-- 返回值为false则显示在主界面上
function HomeSceneButtonsManager:getStarRewardButtonShowState()
	local rewardLevelToPushMeta = StarRewardModel:getInstance():update().currentPromptReward
	if rewardLevelToPushMeta then
		local curTotalStar = UserManager:getInstance().user:getTotalStar()
		local rewardTotalStar = rewardLevelToPushMeta.starNum
		if curTotalStar >= rewardTotalStar then
			return false
		else
			for i,v in ipairs(MetaManager.getInstance().star_reward) do
				if v.starNum == rewardTotalStar then 
					local starMinus = rewardTotalStar - v.delta 
					if curTotalStar > starMinus then 
						return false
					end
				end
			end
			return true
		end
	else
		return true
	end
end

function HomeSceneButtonsManager:addLayerColorWrapper(ui,anchorIsCenter)
	local layer = LayerColor:create()
    layer:setOpacity(0)
    if anchorIsCenter then
    	ui:setPosition(ccp(0,0))
    else -- anchor是左上角
    	ui:setPosition(ccp(-96/2, 96/2))
    end
    printx(3, 'addLayerColorWrapper', ui.indexKey)
    layer:addChild(ui)

    return layer
end

function HomeSceneButtonsManager:getStarRewardButtonShowPos()
	local nodePos = nil
	local topLevelId = UserManager:getInstance().user:getTopLevelId() 
	if topLevelId then 
		local showRewardBtnLevelId = topLevelId + 1 
		if topLevelId%15 == 0 then 
			showRewardBtnLevelId = topLevelId - 1
		end
		self:setRewardBtnPosLevelId(showRewardBtnLevelId)
		local rewardBtnLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[showRewardBtnLevelId]
		if rewardBtnLevelNode then 
			nodePos = rewardBtnLevelNode:getPosition()
		end
	end
	return nodePos
end

function HomeSceneButtonsManager:getRewardBtnPosLevelId()
	if self.showRewardBtnLevelId then return self.showRewardBtnLevelId end

	local topLevelId = UserManager:getInstance().user:getTopLevelId() 
	if topLevelId then 
		local showRewardBtnLevelId = topLevelId + 1 
		if topLevelId%15 == 0 then 
			showRewardBtnLevelId = topLevelId - 1
		end
		self:setRewardBtnPosLevelId(showRewardBtnLevelId)
		return showRewardBtnLevelId
	end
	return 0
end

function HomeSceneButtonsManager:setRewardBtnPosLevelId(levelId)
	self.showRewardBtnLevelId = levelId	
end

function HomeSceneButtonsManager:getFriendNumByLevel(levelId)
	local friendNum = 0
	local friends = FriendManager.getInstance().friends
	if friends then 
		for k,v in pairs(friends) do
			if v.topLevelId and v.topLevelId == levelId then 
				friendNum = friendNum + 1
			end
		end
	end
	return friendNum
end

function HomeSceneButtonsManager:getInviteButtonShowPos()
	local nodePos = nil
	local topLevelId = UserManager:getInstance().user:getTopLevelId() 
	if topLevelId then 
		local minLevelId = topLevelId - 3 
		local maxLevelId = topLevelId + 3
		local maxNormalLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

		if maxLevelId%15 > 0 and maxLevelId%15 <=3 then 
			minLevelId = minLevelId - 3
			maxLevelId = maxLevelId - 3
		end

		if minLevelId < 1 then 
			minLevelId = 1
		end

		if maxLevelId > maxNormalLevelId then 
			maxLevelId = maxNormalLevelId
		end


		local isLadybugNoticeBtn
		local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
		if LadybugABTestManager:isNew() then
			local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
			isLadybugNoticeBtn = function ( level )
				local ret = LadybugDataManager:getInstance():isNoticeButtonNode(level)
				return ret
			end
		else
			isLadybugNoticeBtn = function ( ... )
				return false
			end
		end


		local friendNum = 0
		local shouldInit = true
		local inviteBtnLevelId = minLevelId
		for i=minLevelId, maxLevelId do
			if i ~= topLevelId and i ~= self.showRewardBtnLevelId and (not ModuleNoticeConfig.hasNoticeInLevel(i)) and self.inciteBtnLevelId ~= i and (not isLadybugNoticeBtn(i)) then 
				local tempNum = self:getFriendNumByLevel(i)
				if shouldInit then 
					shouldInit = false
					friendNum = tempNum
					inviteBtnLevelId = i
				else
					if tempNum <= friendNum then
						friendNum = tempNum 
						inviteBtnLevelId = i
					end
				end
			end
		end

		self:setInviteBtnPosLevelId(inviteBtnLevelId)
		local inviteBtnLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[inviteBtnLevelId]
		if inviteBtnLevelNode then 
			nodePos = inviteBtnLevelNode:getPosition()
		end
	end
	return nodePos
end

function HomeSceneButtonsManager:getInciteButtonShowPos()
	local nodePos = nil
	local topLevelId = UserManager:getInstance().user:getTopLevelId() 
	if topLevelId then 
		local minLevelId = topLevelId - 3 
		local maxLevelId = topLevelId + 3
		local maxNormalLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

		local unlockLevelId = math.ceil(topLevelId/15)*15

		if maxLevelId >= unlockLevelId - 1 and maxLevelId <= unlockLevelId + 3 then
			maxLevelId = unlockLevelId - 2
			minLevelId = maxLevelId - 6
		end
		
		-- if maxLevelId%15 > 0 and maxLevelId%15 <=3 then 
		-- 	minLevelId = minLevelId - 3
		-- 	maxLevelId = maxLevelId - 3
		-- end

		if minLevelId < 1 then 
			minLevelId = 1
		end

		if maxLevelId > maxNormalLevelId then 
			maxLevelId = maxNormalLevelId
		end

		local isLadybugNoticeBtn
		local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
		if LadybugABTestManager:isNew() then
			local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
			isLadybugNoticeBtn = function ( level )
				local ret = LadybugDataManager:getInstance():isNoticeButtonNode(level)
				return ret
			end
		else
			isLadybugNoticeBtn = function ( ... )
				return false
			end
		end


		local friendNum = 0
		local shouldInit = true
		local inciteBtnLevelId = minLevelId
		for i=minLevelId, maxLevelId do
			if i ~= topLevelId and i ~= self.showRewardBtnLevelId and not ModuleNoticeConfig.hasNoticeInLevel(i) and self.inviteBtnLevelId ~= i and (not isLadybugNoticeBtn(i)) then 
				local tempNum = self:getFriendNumByLevel(i)
				if shouldInit then 
					shouldInit = false
					friendNum = tempNum
					inciteBtnLevelId = i
				else
					if tempNum <= friendNum then
						friendNum = tempNum 
						inciteBtnLevelId = i
					end
				end
			end
		end

		self.inciteBtnLevelId = inciteBtnLevelId
		local inciteBtnLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[inciteBtnLevelId]
		if inciteBtnLevelNode then 
			nodePos = inciteBtnLevelNode:getPosition()
		end
	end
	return nodePos
end

function HomeSceneButtonsManager:getInviteButtonLevelId()
	if self.inviteBtnLevelId then return self.inviteBtnLevelId end

	local topLevelId = UserManager:getInstance().user:getTopLevelId() 
	if topLevelId then 
		local minLevelId = topLevelId - 3 
		local maxLevelId = topLevelId + 3
		local maxNormalLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()

		if maxLevelId%15 > 0 and maxLevelId%15 <=3 then 
			minLevelId = minLevelId - 3
			maxLevelId = maxLevelId - 3
		end

		if minLevelId < 1 then 
			minLevelId = 1
		end

		if maxLevelId > maxNormalLevelId then 
			maxLevelId = maxNormalLevelId
		end

		local friendNum = 0
		local shouldInit = true
		local inviteBtnLevelId = minLevelId
		for i=minLevelId,maxLevelId do
			if i ~= topLevelId and i ~= self.showRewardBtnLevelId and self.inciteBtnLevelId ~= i then 
				local friendStack = HomeScene:sharedInstance().worldScene.levelFriendPicStacksByLevelId[i]
				if friendStack then 
					local tempNum = #friendStack.friendPics
					if shouldInit then 
						shouldInit = false
						friendNum = tempNum
						inviteBtnLevelId = i
					else
						if tempNum <= friendNum then
							friendNum = tempNum 
							inviteBtnLevelId = i
						end
					end
				else
					shouldInit = false
					inviteBtnLevelId = i
				end
			end
		end
		self:setInviteBtnPosLevelId(inviteBtnLevelId)
		return inviteBtnLevelId
	end
	return 0
end

function HomeSceneButtonsManager:setInviteBtnPosLevelId(levelId)
	self.inviteBtnLevelId = levelId	
end

function HomeSceneButtonsManager:shouldShowMarkBtnOnHomeScene()

    if not UserManager:getInstance().markV2Active then
	    local markModel = MarkModel:getInstance()
	    markModel:calculateSignInfo()
	    if markModel.canSign then
		    return true
	    else 
		    local index, time = MarkModel:getInstance():getCurrentIndexAndTime()
		    if index and index ~= 0 then 
			    return true
		    end
		    return false
	    end
    else
        if UserManager:getInstance().markV2TodayIsMark ~= nil then
            return not UserManager:getInstance().markV2TodayIsMark
        else
            return false
        end
    end
end

--------------------------------
--true  显示在主界面
--false 显示在按钮组
---------------------------------
function HomeSceneButtonsManager:shouldShowFruitBtnOnHomeScene()
	if not kUserLogin then --离线默认不显示剩余采摘次数
		return false
	end

	local show = FruitTreeButtonModel:isNeedShow() 
	return show
end

function HomeSceneButtonsManager:setBtnGroupBar(btnGroupBar)
	self.btnGroupBar = btnGroupBar
end

function HomeSceneButtonsManager:getBtnGroupBar()
	return self.btnGroupBar
end

function HomeSceneButtonsManager:flyToBtnGroupBar(btnIcon, worldOriPos, startCallback, endCallback, anchorIsCenter, cleanup)
	local posXDelta = 0
	local posYDelta = 0
	local scene = HomeScene:sharedInstance()
	btnIcon = self:addLayerColorWrapper(btnIcon, true)
	btnIcon:setPosition(ccp(worldOriPos.x + posXDelta, worldOriPos.y + posYDelta))
	scene:addChild(btnIcon)
	local worldEndPos = scene.hideAndShowBtn:getPositionInWorldSpace()
	local hideBtnSize = CCSizeMake(96, 96)

	local sequence = CCArray:create()
	local spawn = CCArray:create()
	spawn:addObject(CCEaseBackIn:create(CCMoveTo:create(1, worldEndPos)))
	spawn:addObject(CCScaleTo:create(1, 0.7))
	if startCallback then 
		sequence:addObject(CCCallFunc:create(startCallback))
	end
	sequence:addObject(CCSpawn:create(spawn))
	sequence:addObject(CCCallFunc:create(function ()
		btnIcon:removeFromParentAndCleanup(cleanup)
		if endCallback then 
			endCallback()
		end
	end))
	btnIcon:stopAllActions()
	btnIcon:runAction(CCSequence:create(sequence))
end

function HomeSceneButtonsManager:canForcePop()
	if GameGuide:sharedInstance():getHasCurrentGuide()
		or BindPhoneGuideLogic:get().isGuideOnScreen == true
	then 
		return false
	end

	local userDefault = CCUserDefault:sharedUserDefault()
    local hasTutor = userDefault:getBoolForKey("homescene.button.hide.tutor")
    if hasTutor then
    	return false
    end

    local scene = HomeScene:sharedInstance()
    local layer = scene.guideLayer
    local targetBtn = scene.hideAndShowBtn

	return targetBtn ~= nil
end

function HomeSceneButtonsManager:showButtonHideTutor(close_cb)
	local userDefault = CCUserDefault:sharedUserDefault()
	userDefault:setBoolForKey("homescene.button.hide.tutor", true)
    userDefault:flush()

    local scene = HomeScene:sharedInstance()
    local layer = scene.guideLayer
    local targetBtn = scene.hideAndShowBtn
    if targetBtn then 

    	local guidePanel = CocosObject:create()
    	guidePanel.popoutShowTransition = function( ... )
    		HomeScene:sharedInstance().hideAndShowBtn:removeTip()
	    	HomeSceneButtonsManager:getInstance().hasGuideOnScreen = true
	    	local worldPos = targetBtn:getPositionInWorldSpace()
	    	local trueMask = GameGuideUI:mask(180, 1, ccp(worldPos.x, worldPos.y), 1.2, false, false, false, false, true)
	        trueMask.setFadeIn(0.2, 0.3)

	        local touchLayer = LayerColor:create()
	        touchLayer:setColor(ccc3(255,0,0))
	        touchLayer:setOpacity(0)
	        touchLayer:setAnchorPoint(ccp(0.5, 0.5))
	        touchLayer:ignoreAnchorPointForPosition(false)
	        touchLayer:setPosition(ccp(worldPos.x, worldPos.y))
	        touchLayer:changeWidthAndHeight(100, 100)
	        touchLayer:setTouchEnabled(true, 0, true)

	        local function onTrueMaskTap()
	        	if close_cb then close_cb() end
	            --点击关闭引导
	            if not trueMask.isDisposed and trueMask:getParent() ~= nil then 
	            	trueMask:removeFromParentAndCleanup(true)
	            end

	            PopoutManager.sharedInstance():remove(guidePanel)
	            HomeSceneButtonsManager:getInstance().hasGuideOnScreen = false

	      --       if AchiUIManager:hasGuide() then
			    --     GameGuide:sharedInstance():forceStopGuide()
			    --     GameGuide:sharedInstance():tryStartGuide()
			    -- end
	        end

	        local function onTouchLayerTap()
	            --关了自己
	            onTrueMaskTap()
	            --展开
	            if scene.showButtonGroup then 
	            	scene:showButtonGroup()
	            end
	        end
	        touchLayer:addEventListener(DisplayEvents.kTouchTap, onTouchLayerTap)
	        trueMask:addChild(touchLayer)

	        trueMask:addEventListener(DisplayEvents.kTouchTap, onTrueMaskTap)

	        local tutorText = "tutorial.inactive.icons.hidden"
	        if PlatformConfig:isQQPlatform() then 
	        	tutorText = "tutorial.inactive.icons.hidden1"
	        end
	        local action = {
	        	text = tutorText, 
				panType = "up", panAlign = "winY", panPosY = 600,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5, touchDelay = 1,
				panelName = 'guide_dialogue_home_scene_btn_bar'
		    }
	        local panel = GameGuideUI:panelS(nil, action, false)
	        panel:setScale(0.9)
	        local panelPos = panel:getPosition()
	        panel:setPosition(ccp(panelPos.x + 30, worldPos.y+350))
	        local function addTipPanel()
	            trueMask:addChild(panel)
	        end
	        trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(addTipPanel)))

	        local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
	        hand:setScale(0.6)
	        hand:setAnchorPoint(ccp(0, 1))
	        hand:setPosition(ccp(worldPos.x , worldPos.y))
	        hand:setFlipX(true)
	        trueMask:addChild(hand)

	        if layer then
	            layer:addChild(trueMask)
	        end
	    end

		PopoutQueue.sharedInstance():push(guidePanel, false, true)
	else
		if close_cb then close_cb() end
    end
end