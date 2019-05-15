
ActCollectionLogic = {}

function ActCollectionLogic:init(mainLogic)
	self.mainLogic = mainLogic	

	self.curMoveNum = 0 			--两次触发之间移动的步数
	self.genCollectMoveLimit = 0    --移动多少步触发
	self.genCollectLimit = 0 		--当关可生成上限
	self.genCollectNum = 0 			--当关已生成数量

	self.chestPosX = nil
	self.chestPosY = nil
	self.chest = nil

    self.CollectInGameTargetPanel = nil
    self.CollectInGameTargetPanelType = 0

	self.isEffectLevel, levelId = self:checkIsEffetLevel()
	if self.isEffectLevel then 
		FrameLoader:loadArmature('tempFunctionRes/CountdownParty/skeleton/countdown_party_chest', 'countdown_party_chest', 'countdown_party_chest')
		local isQATest = false
		if isQATest then 
			self.genCollectMoveLimit = 2
			self.genCollectLimit = 999
		else
			self.genCollectMoveLimit, self.genCollectLimit = self:getCollectConfig(levelId)
		end
		if self.genCollectMoveLimit <= 0 or self.genCollectLimit <= 0 then 
			self.isEffectLevel = false
		end
	end
end

function ActCollectionLogic:getDataForRevert()
	local actCollectionRevertData = {}

	actCollectionRevertData.curMoveNum = self.curMoveNum
	actCollectionRevertData.genCollectNum = self.genCollectNum

	return actCollectionRevertData
end

function ActCollectionLogic:setByRevertData(actCollectionRevertData)
	if actCollectionRevertData then
		self.curMoveNum = actCollectionRevertData.curMoveNum or 0
		self.genCollectNum = actCollectionRevertData.genCollectNum or 0
	end
end

function ActCollectionLogic:getCollectConfig(levelId)
	local moveLimit = 0
	local genLimit = 0
	levelId = tonumber(levelId)
	if levelId then 
		if levelId > 0 and levelId < 50 then 
			moveLimit = 8
			genLimit = 1
		elseif levelId >= 50 and levelId <= 99 then 
			moveLimit = 8
			genLimit = 2
		elseif levelId >= 100 and levelId <= 199 then 
			moveLimit = 7
			genLimit = 3
		elseif levelId >= 200 and levelId <= 399 then 
			moveLimit = 5
			genLimit = 5
        elseif levelId >= 400 and levelId <= 799 then 
			moveLimit = 4
			genLimit = 6
        elseif levelId >= 800 and levelId <= 1299 then 
			moveLimit = 4
			genLimit = 7
        else
			moveLimit = 4
			genLimit = 7
		end
	end
	return moveLimit, genLimit
end

function ActCollectionLogic:checkIsEffetLevel()
	if self.mainLogic then 
        if not CountdownPartyManager.getInstance():shouldShowActCollection(self.mainLogic.level) 
--            and not DragonBuffManager.getInstance():shouldShowActCollection(self.mainLogic.level)
--            and not Qixi2018CollectManager.getInstance():shouldShowActCollection(self.mainLogic.level)
--            and not Qixi2018CollectManager.getInstance():shouldShowOppoActCollection(self.mainLogic.level)
            and not Thanksgiving2018CollectManager.getInstance():shouldShowActCollection(self.mainLogic.level)  then 
			return false 
		end
	else
		return false
	end

	return true, self.mainLogic.level
end

function ActCollectionLogic:isActEffectedLevel()
	return self.isEffectLevel
end

function ActCollectionLogic:addUseMove()
	self.curMoveNum = self.curMoveNum + 1
end

function ActCollectionLogic:resetUseMove()
	self.curMoveNum = 0
end

function ActCollectionLogic:checkGenLimit()
	if self.genCollectNum >= self.genCollectLimit then 
		return false 
	end

	if self.curMoveNum < self.genCollectMoveLimit then 
		return false
	end

	return true
end

function ActCollectionLogic:handleTurn(callback)
	local mainLogic = self.mainLogic
    local gameItemData = mainLogic.gameItemMap
    local gameBoardData = mainLogic.boardmap

    local priTable = {}
    priTable[1] = {} 		--普通小动物
    priTable[2] = {}		--小动物特效
    priTable[3] = {}		--水晶球
    priTable[4] = {} 		--含羞草_普通小动物
    priTable[5] = {}		--含羞草_小动物特效
    priTable[6] = {}		--含羞草_水晶球
    priTable[7] = {} 		--牢笼_普通小动物
    priTable[8] = {}		--牢笼_小动物特效
    priTable[9] = {}		--牢笼_水晶球

    local priMax = 9
    local function insertTargets(priority, info)
    	if priority <= priMax then 
    		table.insert(priTable[priority], info)
    		priMax = priority
    	end
    end

    for r = 1, #gameItemData do 
        for c = 1, #gameItemData[r] do
        	local data = gameItemData[r][c]
        	if not data.hasActCollection then 
	        	if data.ItemType == GameItemType.kAnimal and AnimalTypeConfig.isColorTypeValid(data._encrypt.ItemColorType) and data._encrypt.ItemColorType ~= AnimalTypeConfig.kDrip then
	        		local posInfo = {}
	        		posInfo.r = r
	        		posInfo.c = c
	        		if AnimalTypeConfig.isSpecialTypeValid(data.ItemSpecialType) and data.ItemSpecialType ~= AnimalTypeConfig.kColor then 
		        		if data.beEffectByMimosa > 0 then 
		        			insertTargets(5, posInfo)
		        		elseif data.cageLevel > 0 then 
		        			insertTargets(8, posInfo)
	        			elseif data:isAvailable() and not data:hasLock() and not data:hasAnyFurball() then 
	        				insertTargets(2, posInfo)
		        		end
	        		else
	        			if data.beEffectByMimosa > 0 then 
	        				insertTargets(4, posInfo)
	        			elseif data.cageLevel > 0 then 
	        				insertTargets(7, posInfo)
	        			elseif data:isAvailable() and not data:hasLock() and not data:hasAnyFurball() then 
	        				insertTargets(1, posInfo)
	        			end
	        		end
	        	elseif data.ItemType == GameItemType.kCrystal then 
	        		local posInfo = {}
	        		posInfo.r = r
	        		posInfo.c = c
        			if data.beEffectByMimosa > 0 then 
        				insertTargets(6, posInfo)
        			elseif data.cageLevel > 0 then 
        				insertTargets(9, posInfo)
        			elseif data:isAvailable() and not data:hasLock() and not data:hasAnyFurball() then 
        				insertTargets(3, posInfo)
	        		end
	        	end
	        end
        end
    end
    local targetNum = #priTable[priMax]
    if targetNum > 0 then 
    	local targets = {}
    	table.insert(targets, priTable[priMax][mainLogic.randFactory:rand(1, targetNum)])
	    local action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kAct_Collection_Turn,
				nil,
				nil,				
				GamePlayConfig_MaxAction_time)	
	    action.turnTargets = targets 
	    self.genCollectNum = self.genCollectNum + 1
	   	-- action.turnTargets = {{r = 7, c = 7}} --test
		if callback then 
			action.completeCallback = function () callback() end
		end

		self.mainLogic:addGlobalCoreAction(action)
		return true
	end

	return false
end

local function getItemPosition(x, y)
	local tempX = (x - 0.5) * GamePlayConfig_Tile_Width
	local tempY = (GamePlayConfig_Max_Item_Y - y - 0.5) * GamePlayConfig_Tile_Width
	return ccp(tempX, tempY)
end

function ActCollectionLogic:playGenFlyAni(parentLayer, x, y, callback)
	-- if not parentLayer then return end
	-- local sprite = Sprite:createWithSpriteFrameName("item_act_collection.png")

	-- local startPos
	-- local deltaX
	-- if x >= 360 then 
	-- 	startPos = getItemPosition(1, 5)
	-- 	deltaX = -120
	-- else
	-- 	startPos = getItemPosition(9, 5)
	-- 	deltaX = 120
	-- end
	-- sprite:setPosition(ccp(startPos.x + deltaX, startPos.y))
	-- parentLayer:addChild(sprite)
	
	-- local endPosX = x - 0.5 * GamePlayConfig_Tile_Width
	-- local endPosY = y - 0.5 * GamePlayConfig_Tile_Width

	-- local distance = math.sqrt((endPosX - startPos.x) * (endPosX - startPos.x) + (endPosY - startPos.y) * (endPosY - startPos.y))
	-- local flyTime = distance/1000

	-- local arr = CCArray:create()
	-- local arr1 = CCArray:create()
	-- arr1:addObject(CCEaseSineOut:create(CCMoveTo:create(flyTime, ccp(endPosX, endPosY))))
	-- -- arr1:addObject(CCScaleTo:create(flyTime, 0.9))

	-- arr:addObject(CCDelayTime:create(0.3))
	-- arr:addObject(CCSpawn:create(arr1))
	-- arr:addObject(CCCallFunc:create(function ()
	-- 	sprite:removeFromParentAndCleanup(true)
	-- 	if callback then callback() end
	-- end))
	-- sprite:runAction(CCSequence:create(arr))


	local container = CocosObject:create()
	local sp1 = Sprite:createWithSpriteFrameName("item_act_collection.png")
	local sp2 = Sprite:createWithSpriteFrameName("item_act_collection.png")
	sp1:setScale(0)
	sp2:setScale(0)
	container:addChild(sp1)
	container:addChild(sp2)

	local aniTime = 0.4
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(aniTime+0.2, 1.5))
	arr:addObject(CCFadeTo:create(aniTime+0.2, 0))
	sp1:runAction(CCSequence:createWithTwoActions(CCSpawn:create(arr), CCCallFunc:create(function ()	
		if sp1 then sp1:removeFromParentAndCleanup(true) end
		if sp2 then sp2:removeFromParentAndCleanup(true) end
		if callback then callback() end
	end)))

	sp2:runAction(CCScaleTo:create(aniTime, 1))

	local posX = x - 0.5 * GamePlayConfig_Tile_Width
	local posY = y - 0.5 * GamePlayConfig_Tile_Width
	container:setPosition(ccp(posX, posY))
	parentLayer:addChild(container)
end

function ActCollectionLogic:playGetFlyAni(r, c)

	local scene = Director:sharedDirector():getRunningScene()

	if not self.chest then 
		local pos = self.mainLogic:getGameItemPosInView(1, 1)
		self.chestPosX = 55
		self.chestPosY = pos.y + 85

		self.chest = ArmatureNode:create("countdown_party_chest/chest")
		if self.chest then 
			self.chest:setPosition(ccp(self.chestPosX - 45, self.chestPosY + 45))
			scene:addChild(self.chest)
		end
	end

	local startPos = self.mainLogic:getGameItemPosInView(r, c)

	local flyContainer = CocosObject:create()
	local whiteBg = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_item0000")
	whiteBg:setScale(0.8)
	local itemIcon = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_item0000")
	local itemIconSize = itemIcon:getContentSize()
	local num = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_num0000")
	local numSize = num:getContentSize()

	flyContainer:addChild(whiteBg)
	whiteBg:setPosition(ccp(-itemIconSize.width/2, 0))
	flyContainer:addChild(itemIcon)
	itemIcon:setPosition(ccp(-itemIconSize.width/2, 0))
	flyContainer:addChild(num)
	num:setPosition(ccp(numSize.width/2, 0))


	flyContainer:setPosition(ccp(startPos.x, startPos.y))
	scene:addChild(flyContainer)

	local distance = math.sqrt((self.chestPosX - startPos.x) * (self.chestPosX - startPos.x) + (self.chestPosY - startPos.y) * (self.chestPosY - startPos.y))
	local flyTime = distance/1000
	if flyTime < 0.2 then 
		flyTime = 0.2
	elseif flyTime > 0.5 then 
		flyTime = 0.5
	end
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.1, 1.2))
	arr:addObject(CCScaleTo:create(0.1, 1))
	arr:addObject(CCDelayTime:create(0.2))
	arr:addObject(CCCallFunc:create(function ()
		if self.chest then 
			self.chest:play("box", 1)
		end

		local arr1 = CCArray:create()
		arr1:addObject(CCDelayTime:create(flyTime*0.8))
		arr1:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(flyTime*0.2 + 0.1, 1.3), CCFadeTo:create(flyTime*0.2 + 0.1, 0)))
		whiteBg:runAction(CCSequence:create(arr1))

		local arr2 = CCArray:create()
		arr2:addObject(CCScaleTo:create(flyTime, 0.8))
		arr2:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(flyTime*0.8), CCFadeTo:create(flyTime*0.2, 0)))
		itemIcon:runAction(CCSpawn:create(arr2))

		num:runAction(CCFadeTo:create(flyTime/3*2, 0))
	end))
	arr:addObject(CCEaseSineOut:create(CCMoveTo:create(flyTime, ccp(self.chestPosX + itemIconSize.width/2, self.chestPosY))))
	arr:addObject(CCDelayTime:create(0.1))
	arr:addObject(CCCallFunc:create(function ()
		flyContainer:removeFromParentAndCleanup(true)
	end))
	flyContainer:runAction(CCSequence:create(arr))
end


--qixi2018
function ActCollectionLogic:setQixiPanelMoveOut( )
    if not self.CollectInGameTargetPanel then return end

    local function moveEndCallBack()
        self.CollectInGameTargetPanelType = 0
    end

    self.CollectInGameTargetPanel:MoveOutPanel( moveEndCallBack )
    self.CollectInGameTargetPanelType = 3
end

function ActCollectionLogic:setQixiPanelMoveIn( )
    if not self.CollectInGameTargetPanel then return end

    local function moveEndCallBack()
        self.CollectInGameTargetPanelType = 2

        self:setQixiPanelMoveOut()
    end

    self.CollectInGameTargetPanel:MoveInPanel( moveEndCallBack )
    self.CollectInGameTargetPanelType = 1
end

function ActCollectionLogic:playGetFlyAniExForQixi(r, c)

    if not self.CollectInGameTargetPanel then

        local scene = Director:sharedDirector():getRunningScene()

        local pos = self.mainLogic:getGameItemPosInView(1, 1)

        local InGameProgressPanel = require 'zoo.localActivity.Thanksgiving2018.Thanksgiving2018InGameProgressPanel'
        self.CollectInGameTargetPanel = InGameProgressPanel:create() 
        self.CollectInGameTargetPanel:setPosition( ccp(-250, pos.y + 100 ))
        self.CollectInGameTargetPanelType = 0 -- 0收起来 1在往出走 2在外面 3在往回走
        scene:addChild(self.CollectInGameTargetPanel)

        self:setQixiPanelMoveIn()
    else
        if self.CollectInGameTargetPanelType ~= 2 then
            self:setQixiPanelMoveIn()
        end
    end

    local scene = Director:sharedDirector():getRunningScene()

    local startPos = self.mainLogic:getGameItemPosInView(r, c)

	local flyContainer = CocosObject:create()
	local whiteBg = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_item0000")
	whiteBg:setScale(0.8)
	local itemIcon = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_item0000")
	local itemIconSize = itemIcon:getContentSize()
	local num = Sprite:createWithSpriteFrameName("countdown_party_flower/countdown_party_fly_num0000")
	local numSize = num:getContentSize()

	flyContainer:addChild(whiteBg)
	whiteBg:setPosition(ccp(-itemIconSize.width/2, 0))
	flyContainer:addChild(itemIcon)
	itemIcon:setPosition(ccp(-itemIconSize.width/2, 0))
	flyContainer:addChild(num)
	num:setPosition(ccp(numSize.width/2, 0))

	flyContainer:setPosition(ccp(startPos.x, startPos.y))
	scene:addChild(flyContainer)

    local icon = self.CollectInGameTargetPanel.ui:getChildByName("icon")
    local iconWorldPos = icon:getParent():convertToWorldSpace( icon:getPosition() )
    local EndPos = ccp( 140, iconWorldPos.y -35.5/2 ) --目标位置

	local distance = math.sqrt((EndPos.x - startPos.x) * (EndPos.x - startPos.x) + (EndPos.y - startPos.y) * (EndPos.y - startPos.y))
	local flyTime = distance/1000
	if flyTime < 0.2 then 
		flyTime = 0.2
	elseif flyTime > 0.5 then 
		flyTime = 0.5
	end
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.1, 1.2))
	arr:addObject(CCScaleTo:create(0.1, 1))
	arr:addObject(CCDelayTime:create(0.2))
	arr:addObject(CCCallFunc:create(function ()

		local arr1 = CCArray:create()
		arr1:addObject(CCDelayTime:create(flyTime*0.8))
		arr1:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(flyTime*0.2 + 0.1, 1.3), CCFadeTo:create(flyTime*0.2 + 0.1, 0)))
		whiteBg:runAction(CCSequence:create(arr1))

		local arr2 = CCArray:create()
		arr2:addObject(CCScaleTo:create(flyTime, 0.8))
		arr2:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(flyTime*0.8), CCFadeTo:create(flyTime*0.2, 0)))
		itemIcon:runAction(CCSpawn:create(arr2))

		num:runAction(CCFadeTo:create(flyTime/3*2, 0))
	end))
	arr:addObject(CCEaseSineOut:create(CCMoveTo:create(flyTime, ccp(EndPos.x + itemIconSize.width/2, EndPos.y))))
	arr:addObject(CCDelayTime:create(0.1))
	arr:addObject(CCCallFunc:create(function ()
		flyContainer:removeFromParentAndCleanup(true)

        if self.CollectInGameTargetPanel then
            self.CollectInGameTargetPanel:MoonLightBlink()
        end

--        self:setQixiPanelMoveOut()
	end))
	flyContainer:runAction(CCSequence:create(arr))
end

--