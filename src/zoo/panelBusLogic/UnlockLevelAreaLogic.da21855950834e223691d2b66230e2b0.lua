
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月13日 15:08:41
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.model.MetaModel"

---------------------------------------------------
-------------- UnlockLevelAreaLogic
---------------------------------------------------

assert(not UnlockLevelAreaLogic)
UnlockLevelAreaLogic = class()


UnlockLevelAreaLogicUnlockType = {

	USE_STAR		= 1,
	USE_WINDMILL_COIN	= 2,
	REQUEST_FRIEND_TO_HELP	= 3,
	USE_FRIEND		= 4,
	USE_DOWN_NEW_APK = 5,
	USE_TASK_LEVEL = 6,
	USE_ANIMAL_FRIEND = 7,
	USE_UNLOCK_AREA_LEVEL = 8,
	USE_SNS = 9,
	USE_SIM_FRIEND = 10,
	TIME_UNLOCK = 12
}

local function checkUnlockType(unlockType)

	assert(unlockType == UnlockLevelAreaLogicUnlockType.USE_STAR or
		unlockType == UnlockLevelAreaLogicUnlockType.USE_WINDMILL_COIN or
		unlockType == UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP or
		unlockType == UnlockLevelAreaLogicUnlockType.USE_FRIEND or 
		unlockType == UnlockLevelAreaLogicUnlockType.USE_DOWN_NEW_APK or 
		unlockType == UnlockLevelAreaLogicUnlockType.USE_ANIMAL_FRIEND or 
		unlockType == UnlockLevelAreaLogicUnlockType.USE_TASK_LEVEL or 
		unlockType == UnlockLevelAreaLogicUnlockType.USE_UNLOCK_AREA_LEVEL or
		unlockType == UnlockLevelAreaLogicUnlockType.USE_SNS or
		unlockType == UnlockLevelAreaLogicUnlockType.USE_SIM_FRIEND or
		unlockType == UnlockLevelAreaLogicUnlockType.TIME_UNLOCK
		)
end

function UnlockLevelAreaLogic:init(lockedCloudId, ...)
	assert(type(lockedCloudId) == "number")
	assert(#{...} == 0)

	self.lockedCloudId = lockedCloudId

	--if _G.isLocalDevelopMode then printx(0, "UnlockLevelAreaLogic:init Called !") end
	--if _G.isLocalDevelopMode then printx(0, "self.lockedCloudId: " .. self.lockedCloudId) end
	--debug.debug()

	self.onSuccessCallback		= false
	self.onFailCallback		= false
	self.onHasNotEnoughStarCallback	= false

	self.minLevel = MetaManager.getInstance():getLevelAreaById(self.lockedCloudId).minLevel
end

--------------------------------
---- Set Event Callback
-------------------------------

function UnlockLevelAreaLogic:setOnSuccessCallback(onSuccessCallback, ...)
	assert(type(onSuccessCallback) == "function")
	assert(#{...} == 0)

	self.onSuccessCallback = onSuccessCallback
end

function UnlockLevelAreaLogic:setOnFailCallback(onFailCallback, ...)
	assert(type(onFailCallback) == "function")
	assert(#{...} == 0)

	self.onFailCallback	= onFailCallback
end

function UnlockLevelAreaLogic:setOnCancelCallback(onCancelCallback, ...)
	assert(type(onCancelCallback) == "function")
	assert(#{...} == 0)

	self.onCancelCallback = onCancelCallback
end

function UnlockLevelAreaLogic:setOnHasNotEnoughStarCallback(onHasNotEnoughStarCallback, ...)
	assert(type(onHasNotEnoughStarCallback) == "function")
	assert(#{...} == 0)

	self.onHasNotEnoughStarCallback = onHasNotEnoughStarCallback
end

function UnlockLevelAreaLogic:getGoodsId(unlockCloudId)
	local goodsMeta = MetaManager.getInstance():getGoodsMetaByAreaId(unlockCloudId)
	if not goodsMeta then
		assert(false, "no goods meta for areaId:"..tostring(unlockCloudId))
	end
	return goodsMeta.id
end

function UnlockLevelAreaLogic:start(unlockType, friendIds, androidPayParamTable , datas, wxNotify)
	checkUnlockType(unlockType)
	assert(type(friendIds) == "table")

	-- ----------------
	-- Success Callback
	-- ------------------
	local function onSendUnlockLevelAreaSuccess()

		if _G.isLocalDevelopMode then printx(0, "send unlock area success !") end
		-----------------------------------------------
		-- Advance Top Level
		-- Need Manually Advance THe Top Level Id
		-- Because: in Use Qcash TO Unlock The CLoud, New Top Leve Id Is Not Returned From Server
		-- -------------------------------------------------------
		if unlockType ~= UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP then
			local logic = AdvanceTopLevelLogic:create(self.minLevel - 1)
			logic:startWithoutCheckLockedCloud()
		end

		if self.onSuccessCallback then
			self.onSuccessCallback()
		end

		if MissionManager then
			local triggerContext = TriggerContext:create(TriggerContextPlace.UNLOACK_AREA)
			triggerContext:addValue( "unLockLevelAreaData" , {unlockType=unlockType,friendIds=friendIds} )
			MissionManager:getInstance():checkAll(triggerContext)
		end
	end

	-- ------------------
	-- Failed Callback
	-- ----------------
	local function onSendUnlockLevelAreaFailed(errorCode)
		if self.onFailCallback then
			self.onFailCallback(errorCode)
		end
	end

	local function onSendUnlockLevelAreaCanceled()
		if self.onCancelCallback then
			self.onCancelCallback()
		end
	end
	---------------
	-- Use Star
	-- -----------
	if unlockType == UnlockLevelAreaLogicUnlockType.TIME_UNLOCK then
		local function withNet()
			self:sendUnlockLevelAreaMessage(
			unlockType, friendIds, onSendUnlockLevelAreaSuccess, onSendUnlockLevelAreaFailed, onSendUnlockLevelAreaCanceled)
		end
		local function withoutNet()
  			CommonTip:showTip(localize('dis.connect.warning.tips'), 'negative')
  			onSendUnlockLevelAreaFailed()
		end
		RequireNetworkAlert:callFuncWithLogged(withNet, withoutNet)
	elseif unlockType == UnlockLevelAreaLogicUnlockType.USE_STAR then
		local function onHasNotEnoughStarCallback(userTotalStar, neededStar)
			if self.onHasNotEnoughStarCallback then
				self.onHasNotEnoughStarCallback(userTotalStar, neededStar)
			end
		end

		-- Check If Has Enough Start
		if self:ifHasEnoughStar() then
			self:sendUnlockLevelAreaMessage(unlockType, {}, onSendUnlockLevelAreaSuccess, onSendUnlockLevelAreaFailed)
		else
			-- Not Has Enough Star
			local useableStar 	= self:getUseableStar()
			local neededStar	= self:getNeededStar()
			onHasNotEnoughStarCallback(useableStar, neededStar)
		end
	---------------------
	-- Use Windmill Coin
	-- -------------------
	elseif unlockType == UnlockLevelAreaLogicUnlockType.USE_WINDMILL_COIN then
		local itemId	= self.lockedCloudId
		local goodsId = self:getGoodsId(itemId)
		if _G.isLocalDevelopMode then printx(0, "UnlockLevelAreaLogicUnlockType.USE_WINDMILL_COIN") end
		if _G.isLocalDevelopMode then printx(0, itemId, goodsId) end

		if androidPayParamTable and androidPayParamTable.isRmbPay then 
			local logic = IngamePaymentLogic:create(goodsId, GoodsType.kItem, DcFeatureType.kLevelArea, DcSourceType.kUnlockArea)
        	logic:specialBuy(androidPayParamTable.adDecision ,androidPayParamTable.adPaymentType,
        			 		 onSendUnlockLevelAreaSuccess, onSendUnlockLevelAreaFailed, onSendUnlockLevelAreaCanceled,
        					 androidPayParamTable.adRepayChooseTable, androidPayParamTable.sourePanel)
		else
			local dcWindmillInfo = DCWindmillObject:create()
	        dcWindmillInfo:setGoodsId(goodsId)

	        local logic = WMBBuyItemLogic:create()
	        local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kLevelArea, DcSourceType.kUnlockArea)
	        logic:buy(goodsId, 1, dcWindmillInfo, buyLogic, onSendUnlockLevelAreaSuccess, onSendUnlockLevelAreaFailed, onSendUnlockLevelAreaCanceled, onSendUnlockLevelAreaCanceled)
		end

	-- Request Friend To Help
	elseif unlockType == UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP or
		   unlockType == UnlockLevelAreaLogicUnlockType.USE_FRIEND or
		   unlockType == UnlockLevelAreaLogicUnlockType.USE_ANIMAL_FRIEND or
		   unlockType == UnlockLevelAreaLogicUnlockType.USE_SIM_FRIEND or
		   unlockType == UnlockLevelAreaLogicUnlockType.USE_TASK_LEVEL then
		local npc = nil
		if datas and datas.npc then npc = datas.npc end
		self:sendUnlockLevelAreaMessage(
			unlockType, friendIds, onSendUnlockLevelAreaSuccess, onSendUnlockLevelAreaFailed, onSendUnlockLevelAreaCanceled ,
			npc, nil, wxNotify
			)
	elseif unlockType == UnlockLevelAreaLogicUnlockType.USE_SNS then
		local auth = nil
		if datas and datas.auth then auth = datas.auth end
		self:sendUnlockLevelAreaMessage(
			unlockType, friendIds, onSendUnlockLevelAreaSuccess, onSendUnlockLevelAreaFailed, onSendUnlockLevelAreaCanceled , 
			nil ,  auth )
	elseif unlockType == UnlockLevelAreaLogicUnlockType.USE_DOWN_NEW_APK or 
		   unlockType == UnlockLevelAreaLogicUnlockType.USE_UNLOCK_AREA_LEVEL then
		onSendUnlockLevelAreaSuccess()
	else
		assert(false)
	end
end

function UnlockLevelAreaLogic:sendUnlockLevelAreaMessage(unlockType, friendIds, onSuccessCallback, onFailCallback, onCancelCallback, npcNumber , snsName, wxNotify)
	checkUnlockType(unlockType)
	assert(type(friendIds) == "table")
	assert(type(onSuccessCallback) == "function")
	assert(type(onFailCallback) == "function")

	assert(unlockType ~= UnlockLevelAreaLogicUnlockType.USE_WINDMILL_COIN)

	-- 1	: use star to unlock
	-- 3	: ask friend to help
	-- 4	: use friend to unlock

	local function onSuccess(event)
		onSuccessCallback(event.data)
	end

	local function onFailed(event)
		onFailCallback(event.data)
	end

	local function onCancel()
		if onCancelCallback then onCancelCallback() end
	end

	local http = UnLockLevelAreaHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	http:setCancelCallback(onCancel)
	if unlockType == UnlockLevelAreaLogicUnlockType.USE_STAR or unlockType == UnlockLevelAreaLogicUnlockType.USE_TASK_LEVEL then 
		http:load(unlockType, friendIds , npcNumber , snsName)
	else 
		http:syncLoad(unlockType, friendIds , npcNumber , snsName, wxNotify) 
	end
end

function UnlockLevelAreaLogic:getNeededStar(...)
	assert(#{...} == 0)

	-- Get Needed Star
	local neededStar = 0x7FFFFFF

	local metaModel		= MetaModel:sharedInstance()
	local curLevelAreaData	= metaModel:getLevelAreaDataById(self.lockedCloudId)

	if self:isNew() then
		neededStar	= tonumber(curLevelAreaData.starArea)
	else
		neededStar	= tonumber(curLevelAreaData.star)
	end

	return neededStar
end

function UnlockLevelAreaLogic:isNew( ... )
	local uid = 12345
	if UserManager:getInstance().user then
		uid = tostring(UserManager:getInstance().user.uid or 0)
	end

	return MaintenanceManager:getInstance():isEnabledInGroup('UnlockNewStar', 'A', uid) or __WIN32
end

function UnlockLevelAreaLogic:ifHasEnoughStar(...)
	assert(#{...} == 0)

	-- Get Needed Star
	local neededStar = self:getNeededStar()

	-- Get User Cur Total Star
	local useableStar 	= self:getUseableStar()

	if useableStar >= neededStar then
		return true
	end

	return false
end

function UnlockLevelAreaLogic:create(lockedCloudId, ...)
	assert(type(lockedCloudId) == "number")
	assert(#{...} == 0)

	local newUnlockLevelAreaLogic = UnlockLevelAreaLogic.new()
	newUnlockLevelAreaLogic:init(lockedCloudId)
	return newUnlockLevelAreaLogic
end

function UnlockLevelAreaLogic:getLevelRangeContainsLevelId( levelId )
	local levelRangeStart = math.floor((levelId - 1) / 15) * 15 + 1
	local levelRangeEnd = levelRangeStart + 15 - 1
	return levelRangeStart, levelRangeEnd
end

local function getUserStarInLevelRange( levelRangeStart, levelRangeEnd )
	local sumOfStar = 0
	for levelId = levelRangeStart, levelRangeEnd do
		local star = 0
		local score = UserManager.getInstance():getUserScore(levelId)
		if score then
			star = score.star or 0
		end
		sumOfStar = star + sumOfStar
	end
	return sumOfStar
end

function UnlockLevelAreaLogic:getUseableStar( ... )
	if self:isNew() then

		local topLevelId = 1
		if UserManager:getInstance().user then
			topLevelId = UserManager:getInstance().user:getTopLevelId()
		end

		local levelRangeStart ,levelRangeEnd = self:getLevelRangeContainsLevelId(topLevelId)

		return getUserStarInLevelRange(levelRangeStart ,levelRangeEnd)

	else
		return UserManager:getInstance().user:getTotalStar()
	end
end

