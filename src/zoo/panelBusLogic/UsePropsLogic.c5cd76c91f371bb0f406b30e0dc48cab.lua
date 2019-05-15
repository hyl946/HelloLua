
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年12月 5日 16:19:20
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- UsePropsLogic
---------------------------------------------------

UsePropsType = table.const {
	TEMP = 1,
	NORMAL = 2,
	EXPIRE = 3,
	FAKE = 4,
}

assert(not UsePropsLogic)
UsePropsLogic = class()

function UsePropsLogic:init(usePropType, levelId, param, itemList,revertPropInfo,...)
	assert(type(usePropType) == "number")
	assert(type(levelId) == "number")
	assert(param)
	assert(type(itemList) == "table")
	assert(#{...} == 0)

	local typeValid = false
	for _,v in pairs(UsePropsType) do
		if usePropType == v then 
			typeValid = true
			break
		end
	end
	assert(typeValid, "usePropType invalid:"..tostring(usePropType))

	self.itemType = usePropType
	self.levelId	= levelId
	self.param		= param or 0
	self.itemList	= itemList

	-- 返回的道具
	if revertPropInfo then
		self.returnType = revertPropInfo.usePropType
		self.returnItemId = revertPropInfo.propId
		self.returnExpireTime = revertPropInfo.expireTime
	end

	self.successCallback = false
end

function UsePropsLogic:setSuccessCallback(callbackFunc, ...)
	assert(type(callbackFunc) == "function")
	assert(#{...} == 0)

	self.successCallback = callbackFunc
end

function UsePropsLogic:setFeatureAndSource(feature, source)
	self.feature = feature
	self.source = source
end

function UsePropsLogic:start(popWaitTip, ...)
	--assert(type(popWaitTip) == "boolean")
	assert(#{...} == 0)

	local function onSendMsgSuccessCallback()
		local feature = self.feature or DcFeatureType.kStagePlay
		local source = self.source or DcSourceType.kIngamePropConsume
		local dcInfo = {}		--打点时为相同itemId的道具做batch
		for k,itemId in pairs(self.itemList) do
			if self.itemType == UsePropsType.NORMAL then
				UserManager:getInstance():addUserPropNumber(itemId, -1)
			elseif self.itemType == UsePropsType.EXPIRE then 
				UserManager:getInstance():useTimeProp(itemId)
			end

			if not dcInfo[itemId] then
				dcInfo[itemId] = 1
			else
				dcInfo[itemId] = dcInfo[itemId] + 1
			end
		end
		for itemId, num in pairs(dcInfo) do
			GainAndConsumeMgr.getInstance():consumeItem(feature, itemId, num, self.levelId, nil, source)
		end

		if self.returnType and self.returnItemId then
			if self.returnType == UsePropsType.NORMAL then
				UserManager.getInstance():addUserPropNumber(self.returnItemId,1)
			elseif self.returnType == UsePropsType.EXPIRE and self.returnExpireTime then
				UserManager.getInstance():addTimeProp(self.returnItemId,1,self.returnExpireTime)
			end
		end

		-- Callback
		if self.successCallback then
			self.successCallback()
		end
	end


	local function onSendMsgFailed(evt)
		if self.failedCallback then
			self.failedCallback(evt)
		end
		
		DcUtil:log(AcType.kExpire30Days, {category = "use_item", sub_category = "use_failed", fail_reason=tostring(evt and evt.data)})
	end
	
	self:sendUsePropsHttp(popWaitTip, onSendMsgSuccessCallback, onSendMsgFailed)
end

function UsePropsLogic:setFailedCallback(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.failedCallback = callback
end

function UsePropsLogic:sendUsePropsHttp(popWaitTip, sendMsgSuccessCallback, sendMsgFailedCallback, ...)
	--assert(type(popWaitTip) == "boolean")
	assert(false == sendMsgSuccessCallback or type(sendMsgSuccessCallback) == "function")
	assert(false == sendMsgFailedCallback or type(sendMsgFailedCallback) == "function")
	assert(#{...} == 0)

	--  <request>
	--	  <property code="type" type="int" desc="1:临时道具,2:背包道具" />
	--	  <property code="levelId" type="int" desc="当前关卡" />
	--	  <property code="param" type="int" desc="param" />
	--	  <list code="itemList" ref="int" desc="使用道具" />
	--  </request>
	--function UsePropsHttp:load(itemType, levelId, gameMode, param, itemList)

	local function onSuccess(evt)
		if sendMsgSuccessCallback then
			sendMsgSuccessCallback(evt)
		end
	end

	local function onFailed(evt)
		--if self.failedCallback then
		--	self.failedCallback()
		--end

		if sendMsgFailedCallback then
			sendMsgFailedCallback(evt)
		end
	end

	local http = UsePropsHttp.new(popWaitTip)
	http:addEventListener(Events.kComplete, onSuccess)
	---- For Test purpose
	--http:addEventListener(Events.kComplete, onFailed)
	http:addEventListener(Events.kError, onFailed)

	---- itemType
	--local propType = false
	--if isTempProperty then
	--	if _G.isLocalDevelopMode then printx(0, "use tempProperty !!") end
	--	propType = 1
	--else
	--	if _G.isLocalDevelopMode then printx(0, "use non temProperty !") end
	--	propType = 2
	--end

	local propType = self.itemType

	-- levelId
	local levelId = self.levelId

	-- param
	local param = self.param

	-- itemList
	local itemList = self.itemList

	http:load(
		propType, levelId, param, itemList,
		self.returnType,self.returnItemId,self.returnExpireTime
	)
end

function UsePropsLogic:create(usePropType, levelId, param, itemList,revertPropInfo, ...)
	assert(type(usePropType) == "number")
	assert(levelId)
	assert(param)
	assert(itemList)
	assert(#{...} == 0)

	local newUsePropsCallback = UsePropsLogic.new()
	newUsePropsCallback:init(usePropType, levelId, param, itemList,revertPropInfo)
	return newUsePropsCallback
end
