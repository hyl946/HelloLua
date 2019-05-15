
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年12月 6日 21:19:09
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- UseEnergyBottleLogic
---------------------------------------------------

assert(not UseEnergyBottleLogic)
UseEnergyBottleLogic = class()

function UseEnergyBottleLogic:init(energyType, feature, source)
	assert(type(energyType) == "number")

	assert(energyType == ItemType.SMALL_ENERGY_BOTTLE or
		energyType == ItemType.MIDDLE_ENERGY_BOTTLE or
		energyType == ItemType.LARGE_ENERGY_BOTTLE or 
		energyType == ItemType.INFINITE_ENERGY_BOTTLE or
		energyType == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE)

	self.energyType = energyType
	self.feature = feature
	self.source = source

	self.successCallback = false
end

function UseEnergyBottleLogic:setSuccessCallback(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.successCallback = callback
end

function UseEnergyBottleLogic:setFailCallback(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.failCallback = callback
end

function UseEnergyBottleLogic:setUsedNum( nUsedNum )
	self.nUsedNum = nUsedNum
end

function UseEnergyBottleLogic:start(popWaitTip, ...)
	--assert(type(popWaitTip) == "boolean")
	assert(#{...} == 0)

	local function successCallback()

		-- Add The Energy
		local numberOfEnergyToAdd = false

		if self.energyType == ItemType.SMALL_ENERGY_BOTTLE then
			numberOfEnergyToAdd = 1
			UserManager:getInstance():getUserRef():addEnergy(numberOfEnergyToAdd)
		elseif self.energyType == ItemType.MIDDLE_ENERGY_BOTTLE then
			numberOfEnergyToAdd = 5
			UserManager:getInstance():getUserRef():addEnergy(numberOfEnergyToAdd)
		elseif self.energyType == ItemType.LARGE_ENERGY_BOTTLE then
			numberOfEnergyToAdd = 30
			UserManager:getInstance():getUserRef():addEnergy(numberOfEnergyToAdd)
		elseif self.energyType == ItemType.INFINITE_ENERGY_BOTTLE then
			local useNum = self.nUsedNum or 1
			local oldBuff = UserManager:getInstance().userExtend:getNotConsumeEnergyBuff()
			local newBuff = 0
			if oldBuff < Localhost:time() then
				newBuff = Localhost:time() + 3600 * 1000 * useNum
			else
				newBuff = oldBuff + 3600 * 1000 * useNum
			end
			UserManager:getInstance().userExtend:setNotConsumeEnergyBuff(newBuff)
		elseif self.energyType == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
			local oldBuff = UserManager:getInstance().userExtend:getNotConsumeEnergyBuff()
			local newBuff = 0
			if oldBuff < Localhost:time() then
				newBuff = Localhost:time() + 60 * 1000 * self.nUsedNum
			else
				newBuff = oldBuff + 60 * 1000 * self.nUsedNum
			end
			UserManager:getInstance().userExtend:setNotConsumeEnergyBuff(newBuff)
		else 
			assert(false)
		end

		-- Callback
		if self.successCallback then
			self.successCallback()
		end

	end

	local function failCallback(evt)
		if self.failCallback then
			self.failCallback(evt)
		end
	end


	--usesProp 请求居然不能传数量过去、所以要同时使用nUsedNum个相同道具、必须传nUsedNum个相同itemId过去
	local itemList = {}
	for i = 1, (self.nUsedNum or 1) do
		table.insert(itemList, self.energyType)
	end

	local logic = UsePropsLogic:create(UsePropsType.NORMAL, 0, 0, itemList)
	logic:setFeatureAndSource(self.feature, self.source)
	logic:setSuccessCallback(successCallback)
	logic:setFailedCallback(failCallback)
	logic:start(popWaitTip)
end

function UseEnergyBottleLogic:create(energyType, feature, source)
	assert(type(energyType) == "number")

	local newUseEnergyBottlLogic = UseEnergyBottleLogic.new()
	newUseEnergyBottlLogic:init(energyType, feature, source)
	return newUseEnergyBottlLogic
end
