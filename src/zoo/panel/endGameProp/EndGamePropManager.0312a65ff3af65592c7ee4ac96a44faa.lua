--=====================================================
-- EndGamePropManager
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  EndGamePropManager.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/09/29
-- descrip:   最终加五步面板用的数据管理
--=====================================================

EndGamePropManager = class()
local instance = nil

local PropList = table.const{
	kAddMove = {itemId = 10004, goodId = 278, discountGoodsId = 280, discountNolimitGoodsId = 296, extraRewardGoodsId = 297},
	kBombAddMove = {itemId = 10078, goodId = 472, discountGoodsId = 473},
	kRivive = {itemId = 10040, goodId = 279, discountGoodsId = 281},
	kAddTime = {itemId = 16, goodId = 155, discountGoodsId = 155},
	kOlympicAddMove = {itemId = 10068, goodId = 252, discountGoodsId = 252},
	kThirdAnniversaryAddMove = {itemId = 10077, goodId = 361, discountGoodsId = 361},
    kJamSpeardAddMove = {itemId = 10104, goodId = 554, discountGoodsId = 554},
} 

EndGameButtonTypeAndroid = table.const{
	kDiscountWindMill = 1,
	kNormalWindMill = 2,
	kOneYuan = 3,
	kDiscountNoLimit = 4,
	kDiscountRmb = 5,
	kNormalRmb = 6,
	kPropEnough = 7,
}

EndGameButtonTypeIos = table.const{
	kDiscountWindMill = 1,
	kNormalWindMill = 2,
	kOneYuan = 3,
	kDiscountNoLimit = 4,
	kExtraReward = 5,
	kPropEnough = 6,
	kRmb = 7,
}

EndGamePropShowType = table.const{
	kNormal = 1,
	kDiscount = 2,
	kDiscountNoLimit = 3,
}


function EndGamePropManager.getInstance()
	if not instance then
		instance = EndGamePropManager.new()
		instance:init()
	end
	return instance
end

function EndGamePropManager:init()

end

function EndGamePropManager:getGoodsId(itemId)
	for k,v in pairs(PropList) do
		if v.itemId == itemId then return v.goodId end
	end
end

function EndGamePropManager:getDiscountGoodsId(itemId)
	for k,v in pairs(PropList) do
		if v.itemId == itemId then return v.discountGoodsId end
	end
end

function EndGamePropManager:getDiscountLimitGoodsId(itemId)
	for k,v in pairs(PropList) do
		if v.itemId == itemId then return v.discountNolimitGoodsId end
	end
end

function EndGamePropManager:getExtraRewardGoodsId(itemId)
	for k,v in pairs(PropList) do
		if v.itemId == itemId then return v.extraRewardGoodsId end
	end
end

function EndGamePropManager:getAndroidBuyGoodsId(itemId, levelId, isWeekly)
	local goodId = self:getGoodsId(itemId)
	local showType = EndGamePropShowType.kNormal 
	local userGroup = EndGamePropABCTest.getInstance():getUserGroup()

	local B1 = GiftPack:isEnabledInGroupMustNewer('B1')
	if not self:checkAnyDiscountGoodsBuyed(itemId) and (not B1 or isWeekly) then 
		goodId = self:getDiscountGoodsId(itemId)
		showType = EndGamePropShowType.kDiscount
	end

	--[[
	if userGroup and userGroup == EndGameUserGrop.kGroup3 then
		local discountNolimitGoodsId = self:getDiscountLimitGoodsId(itemId)
		if discountNolimitGoodsId then 
			if not EndGamePropManager.getInstance():checkGoodsBuyedByLevel(levelId, discountNolimitGoodsId) and 
			   not EndGamePropManager.getInstance():checkNormalDiscountGoodsBuyed(itemId) then	--兼容老版本买过打折的
				goodId = discountNolimitGoodsId
				showType = EndGamePropShowType.kDiscountNoLimit
			end
		else
			if not self:checkNormalDiscountGoodsBuyed(itemId) then 
				goodId = self:getDiscountGoodsId(itemId)
				showType = EndGamePropShowType.kDiscount
			end
		end
	else
		if not self:checkAnyDiscountGoodsBuyed(itemId) then 
			goodId = self:getDiscountGoodsId(itemId)
			showType = EndGamePropShowType.kDiscount
		end
	end
	]]
	return goodId, showType
end

function EndGamePropManager:isAddMoveProp(itemId)
	return itemId == PropList.kAddMove.itemId
end

function EndGamePropManager:isBombAddMoveProp(itemId)
	return itemId == PropList.kBombAddMove.itemId
end

function EndGamePropManager:isReviveProp(itemId)
	return itemId == PropList.kRivive.itemId
end

function EndGamePropManager:isAddTimeProp(itemId)
	return itemId == PropList.kAddTime.itemId
end

function EndGamePropManager:checkAnyDiscountGoodsBuyed(itemId)
	local discountGoodsId = self:getDiscountGoodsId(itemId)
	local discountNolimitGoodsId = self:getDiscountLimitGoodsId(itemId)
	local extraRewardGoodsId = self:getExtraRewardGoodsId(itemId)
	local goodsInfo = GoodsIdInfoObject:create(discountGoodsId)
	local discountOneYuanGoodsId = goodsInfo:getOneYuanGoodsId()
	local goods = MetaManager:getInstance():getGoodMeta(discountGoodsId)

	local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(discountGoodsId)
	local buyedNoLimitDicount = 0 
	local buyedNoLimitOneYuan = 0
	if discountNolimitGoodsId then 
		buyedNoLimitDicount = UserManager:getInstance():getDailyBoughtGoodsNumById(discountNolimitGoodsId)
		local goodsInfo2 = GoodsIdInfoObject:create(discountNolimitGoodsId)
		local noLimitOneYuanGoodsId = goodsInfo2:getOneYuanGoodsId()
		buyedNoLimitOneYuan = UserManager:getInstance():getDailyBoughtGoodsNumById(noLimitOneYuanGoodsId)
	end

	local buyedOneYuan = UserManager:getInstance():getDailyBoughtGoodsNumById(discountOneYuanGoodsId)
	if buyed >= goods.limit or buyedNoLimitDicount >= goods.limit  or buyedOneYuan >= goods.limit or buyedNoLimitOneYuan >= goods.limit then
		return true
	end
	return false
end
						
function EndGamePropManager:checkNormalDiscountGoodsBuyed(itemId)
	local discountGoodsId = self:getDiscountGoodsId(itemId)
	local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(discountGoodsId)
	local goodsInfo = GoodsIdInfoObject:create(discountGoodsId)
	local discountOneYuanGoodsId = goodsInfo:getOneYuanGoodsId()
	local goods = MetaManager:getInstance():getGoodMeta(discountGoodsId)
	local buyedOneYuan = UserManager:getInstance():getDailyBoughtGoodsNumById(discountOneYuanGoodsId)
	if buyed >= goods.limit or buyedOneYuan >= goods.limit then
		return true
	end
	return false
end

function EndGamePropManager:checkGoodsBuyedByLevel(levelId, goodsId)
	local goodsBuyedLimit = 1
	local buyed = UserManager:getInstance():getDailyBuyedGoodsNumByLevel(levelId, goodsId)
	if buyed >= goodsBuyedLimit then 
		return true
	end
	return false
end

function EndGamePropManager:checkExtraRewardGoodsBuyed(itemId)
	local extraRewardGoodsId = self:getExtraRewardGoodsId(itemId)
	if extraRewardGoodsId then 
		local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(extraRewardGoodsId)
		local goods = MetaManager:getInstance():getGoodMeta(extraRewardGoodsId)
		if buyed >= goods.limit then
			return true
		else
			return false
		end
	else
		return true
	end
end

function EndGamePropManager:getItemNum(itemId)
	local itemNum = 0 
	local timeProps = UserManager:getInstance():getTimePropsByRealItemId(itemId)
	if #timeProps > 0 then
		for _,v in pairs(timeProps) do
			itemNum = itemNum + v.num
		end
	else
		local prop = UserManager:getInstance():getUserProp(itemId)
		if prop then 
			itemNum = prop.num 
		end
	end
	return itemNum, hasTimeProp
end

function EndGamePropManager:isIosOneYuanPayEnable(levelId, itemId, lastGameIsFUUU)
	-- if __IOS and self:isAddMoveProp(itemId) then 
	-- 	local timeProps = UserManager:getInstance():getTimePropsByRealItemId(itemId)
	-- 	local timePropNum = 0
	-- 	if timeProps and #timeProps > 0 then
	-- 		for _,v in pairs(timeProps) do timePropNum = timePropNum + v.num end
	-- 	end
	-- 	if timePropNum > 0 then
	-- 		return false
	-- 	end

	-- 	local prop = UserManager:getInstance():getUserProp(itemId)
	-- 	if prop == nil or prop.num <= 0 then
	-- 		local userExtend = UserManager:getInstance().userExtend
	-- 		if not userExtend then 
	-- 			return false
	-- 		end
	-- 		if MaintenanceManager:getInstance():isEnabled("Cny1Feature") or not userExtend.payUser then
	-- 			local goods = MetaManager:getInstance():getGoodMeta(self:getDiscountGoodsId(itemId))
	-- 			local normGood, discountGood = goods.qCash, goods.discountQCash
	-- 			local userCash = UserManager:getInstance().user:getCash()
	-- 			local needCash = 0

	-- 			local buyed = UserManager:getInstance():getDailyBoughtGoodsNumById(self:getDiscountGoodsId(itemId))
	-- 			if buyed >= goods.limit then
	-- 				needCash = normGood
	-- 			else
	-- 				needCash = discountGood
	-- 			end

	-- 			local fuuuDailyData = FUUUManager:getDailyData()
	-- 			local continuousFailNum = FUUUManager:getLevelContinuousFailNum(levelId)
	-- 			local today = tostring( os.date("%x", os.time()) )
	-- 			if lastGameIsFUUU then
	-- 				if fuuuDailyData then
	-- 					if fuuuDailyData.today == today then
	-- 						if fuuuDailyData.isEnable == false then
	-- 							lastGameIsFUUU = false
	-- 						end
	-- 					else
	-- 						fuuuDailyData.today = today
	-- 						fuuuDailyData.isEnable = true
	-- 					end
	-- 				else
	-- 					fuuuDailyData = {}
	-- 					fuuuDailyData.today = today
	-- 					fuuuDailyData.isEnable = true
	-- 				end
	-- 				if continuousFailNum < FUUUConfig.oneYuanBuyContinuousFailNum then
	-- 					lastGameIsFUUU = false
	-- 				end
	-- 			end
	-- 			if userCash < needCash and lastGameIsFUUU then
	-- 				if fuuuDailyData then
	-- 					fuuuDailyData.today = today
	-- 					fuuuDailyData.isEnable = false
	-- 					FUUUManager:setDailyData(fuuuDailyData)
	-- 				end
	-- 				return true
	-- 			end
	-- 		end
	-- 	end
	-- end
	return false 
end

function EndGamePropManager:isTestLevel(levelId)
	if levelId then 
		return LevelType:isMainLevel(levelId) or LevelType:isHideLevel(levelId)
	end
	return false
end

local validLevelType = {
	GameLevelType.kMainLevel, 
	GameLevelType.kHiddenLevel,
    GameLevelType.kSpring2019,
}


function EndGamePropManager:create( addStepType, levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, onPanelWillPopout, onGetLotteryRewards, onUpdatePropBarDisplay)
	if addStepType == 'SummerWeekly' then
		-- -->EndGameProp*Panel_VerB_old
		if __ANDROID then
			WeekRaceEndGamePropAndroidPanel:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText)  
		else
			WeekRaceEndGamePropIosPanel:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText) 
		end
    elseif addStepType == 'MoleWeekly' then
    	-- -->EndGameProp*Panel_VerB_old
		if __ANDROID then
			MoleWeekRaceEndGamePropAndroidPanel:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText)  
		else
			MoleWeekRaceEndGamePropIosPanel:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText) 
		end
	else
		local isSupportedLevelType = table.exist(validLevelType, levelType)

		local uid = '12345'
	    if UserManager and UserManager:getInstance().user then
	        uid = UserManager:getInstance().user.uid or '12345'
	    end
    
	    -- 目前的配置中，B1这组是100% （19/01/16）
		-- if isSupportedLevelType and MaintenanceManager:getInstance():isEnabledInGroup('FiveStepsTipTest', 'B1', uid) then
		if isSupportedLevelType then
			--  -->EndGamePropBasePanel_VerC
			if __ANDROID then
				EndGamePropAndroidPanel_VerB:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, onPanelWillPopout, onGetLotteryRewards, onUpdatePropBarDisplay)
			else
				EndGamePropIosPanel_VerB:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, onPanelWillPopout, onGetLotteryRewards, onUpdatePropBarDisplay)
			end
		else
			--  -->EndGamePropBasePanel_VerB -->EndGamePropBasePanel
			if __ANDROID then 
				EndGamePropAndroidPanel_VerB_old:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, onPanelWillPopout, onGetLotteryRewards)
			else
				EndGamePropIosPanel_VerB_old:create(levelId, levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, onPanelWillPopout, onGetLotteryRewards)
			end
		end
	end
end