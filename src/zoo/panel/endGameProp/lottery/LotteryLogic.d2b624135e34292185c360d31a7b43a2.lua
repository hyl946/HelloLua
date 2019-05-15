local LotteryServer = require 'zoo.panel.endGameProp.lottery.LotteryServer'

local FreeLotteryStrategy = require 'zoo.panel.endGameProp.lottery.FreeLotteryStrategy'


local LotteryLogic = class()

LotteryLogic.MODE = {
	kFREE = 1,
	kNORMAL = 2,
	kNEW = 3, -- 张辉 2019/02/19 http://wiki.happyelements.net/pages/viewpage.action?pageId=36702232
}

local COST = 10
local INIT_REWARDS = {{itemId = ItemType.DIAMONDS, num = 15}}
local LOTTERY_TIME = nil

--只是一种编码风格的尝试，看到这不要在意这些细节
local NIL = {}
setmetatable(NIL, {__call = function ( ... )
	if _G.isLocalDevelopMode then
		printx(61, 'called nil function', ...)
	end
end})

function LotteryLogic:isNewEnable( ... )
	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
	return MaintenanceManager:getInstance():isEnabledInGroup('NewStepsLotteryGROUP', "ON", uid)
end

function LotteryLogic:isFreeEnable( ... )

	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
	return MaintenanceManager:getInstance():isEnabledInGroup('NewFiveStepsLotteryFree', 'A1', uid) and false

end

function LotteryLogic:setLotteryTime( lotteryTime )
	LOTTERY_TIME = lotteryTime
end

function LotteryLogic:getLotteryTime( ... )
	return LOTTERY_TIME
end

function LotteryLogic:timeInSec( ... )
	if LOTTERY_TIME then
		return LOTTERY_TIME / 1000
	else
		return Localhost:timeInSec()
	end
end

function LotteryLogic:getLeftFreeDrawCount( ... )

	self:lazyInitStrategy()

	local data = self.freeLotteryStrategy:getData()
	-- printx(61, table.tostring(data))

	-- return self.freeLotteryStrategy:getLeftFreeDrawCount(self)

	-- 2019/02/18 技术关闭 免费抽步数
	-- 后续其他功能的开发不在考虑和免费抽步数的兼容
 	return 0
	
end


function LotteryLogic:shouldShowBBSPanel( ... )
	self:lazyInitStrategy()
	return self.freeLotteryStrategy:shouldShowBBSPanel()
end

function LotteryLogic:lazyInitStrategy( ... )
	if not self.freeLotteryStrategy then
		self.freeLotteryStrategy = FreeLotteryStrategy:createStrategy()
	end
end

function LotteryLogic:getLotteryReward(lotteryMode, onSuccess, onFail, onCancel)

	if __WIN32 then
		-- (onSuccess or NIL)({{itemId=2, num=1}})
		-- return
	end

	local lotteryCost = COST
	local voucherCost = 0

	if lotteryMode == LotteryLogic.MODE.kFREE then
		lotteryCost = 0
	end

	if lotteryMode == LotteryLogic.MODE.kNEW then
		voucherCost = self:getNewCost()
		lotteryCost = 0
	end

	if not self:canDrawLottery(lotteryMode) then
		return (onFail or NIL)()
	end

	local rewardIndex, rewards 

	if lotteryMode == LotteryLogic.MODE.kFREE then
		rewardIndex, rewards = LotteryServer:getInstance():freeLotteryReward()
	elseif lotteryMode == LotteryLogic.MODE.kNORMAL then
		rewardIndex, rewards = LotteryServer:getInstance():lotteryReward()
	elseif lotteryMode == LotteryLogic.MODE.kNEW then
		rewardIndex, rewards = LotteryServer:getInstance():newLotteryReward()
	end
	if not rewardIndex then
		return (onFail or NIL)()
	end

	local drawMS = Localhost:time()

	local http = Add5Lottery.new(true)
	http:ad(Events.kComplete, function ( evt )

		UserManager:getInstance():addRewards(rewards)
        UserService:getInstance():addRewards(rewards)


        if lotteryMode == LotteryLogic.MODE.kNORMAL then
        	UserManager:getInstance():addUserPropNumber(ItemType.DIAMONDS, -lotteryCost)
			UserService:getInstance():addUserPropNumber(ItemType.DIAMONDS, -lotteryCost)
			GainAndConsumeMgr.getInstance():consumeItem(DcFeatureType.kAddFiveSteps, ItemType.DIAMONDS, lotteryCost, self.levelId, nil, DcSourceType.kFSLottery)
        	GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kAddFiveSteps, rewards, DcSourceType.kFSLottery)
		elseif lotteryMode == LotteryLogic.MODE.kFREE then
			local ts = self:timeInSec() * 1000
			self:lazyInitStrategy()
			self.freeLotteryStrategy:onLotteryFinish(self, ts)
        	GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kAddFiveSteps, rewards, DcSourceType.kFSLottery)
		elseif lotteryMode == LotteryLogic.MODE.kNEW then
        	UserManager:getInstance():addUserPropNumber(ItemType.VOUCHER, -voucherCost)
			UserService:getInstance():addUserPropNumber(ItemType.VOUCHER, -voucherCost)
			GainAndConsumeMgr.getInstance():consumeItem(DcFeatureType.kAddFiveSteps, ItemType.VOUCHER, voucherCost, self.levelId, nil, DcSourceType.kFSNewLottery)
			self:afterLottery(drawMS)
        	GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kAddFiveSteps, rewards, DcSourceType.kFSNewLottery)
		end

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		end

		if onSuccess then
			onSuccess(rewards)
		end

	end)

	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onCancel)
	http:load(lotteryCost, rewards, LOTTERY_TIME, voucherCost)

end

function LotteryLogic:getFreeModeStrategyTag( ... )
	self:lazyInitStrategy()
	return self.freeLotteryStrategy:getTag()
end

function LotteryLogic:getCost( ... )
	return COST
end

function LotteryLogic:getLeftDrawCount( ... )
	return math.floor((UserManager:getInstance():getUserPropNumber(ItemType.DIAMONDS) or 0) / COST)
end

function LotteryLogic:getLeftNewDrawCount( ... )
	return math.floor((UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER) or 0) / self:getNewCost())
end

function LotteryLogic:getNeededVoucherNum( ... )
	local cost = self:getNewCost()
	local myVoucherNum = UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER)
	return math.max(cost - myVoucherNum, 0)
end

function LotteryLogic:canDrawLottery( lotteryMode )
	if lotteryMode == LotteryLogic.MODE.kFREE then
		return self:getLeftFreeDrawCount() > 0
	elseif lotteryMode == LotteryLogic.MODE.kNORMAL then
		local diamondsNum = UserManager:getInstance():getUserPropNumber(ItemType.DIAMONDS) or 0
		return diamondsNum >= COST
	elseif lotteryMode == LotteryLogic.MODE.kNEW then
		local voucherNum = UserManager:getInstance():getUserPropNumber(ItemType.VOUCHER) or 0
		return voucherNum >= self:getNewCost()
	end
end

--每次打开转盘面板调用一次
function LotteryLogic:reset( ... )
	-- body
	LotteryServer:getInstance():reset()
end

function LotteryLogic:setLevelId( levelId )
	self.levelId = levelId
end

function LotteryLogic:getLotteryConfig( lotteryMode )
	if lotteryMode == LotteryLogic.MODE.kNORMAL then
		return LotteryServer:getInstance():getLotteryConfig()
	elseif lotteryMode == LotteryLogic.MODE.kFREE then
		return LotteryServer:getInstance():getFreeLotteryConfig()
	elseif lotteryMode == LotteryLogic.MODE.kNEW then
		return LotteryServer:getInstance():getNewLotteryConfig()
	end
end


function LotteryLogic:getNewCost( discount )

	if discount == true then
		return 20
	end

	if discount == false then
		return 40
	end

	local hadUsedAddFiveSteps = false
	for _, v in ipairs({
		ItemType.ADD_FIVE_STEP,
		ItemType.TIMELIMIT_ADD_FIVE_STEP,
		ItemType.ADD_1_STEP,
		ItemType.ADD_2_STEP,
		ItemType.ADD_15_STEP,
	}) do
		if GamePlayContext:getInstance():hadUsedProp(v) then
			hadUsedAddFiveSteps = true
			break
		end
	end

	local uid = UserManager:getInstance().uid or "12345"
	local lastPlayId = CCUserDefault:getStringForKey('lottery.lastPlayId.' .. uid, '') or ''

	local curPlayId = GamePlayContext:getInstance():getIdStr()
	if curPlayId ~= lastPlayId and (not hadUsedAddFiveSteps) then
		return self:getNewCost(true), true
	else
		return self:getNewCost(false), false
	end
end

function LotteryLogic:afterLottery()
	local uid = UserManager:getInstance().uid or "12345"
	CCUserDefault:setStringForKey('lottery.lastPlayId.' .. uid, GamePlayContext:getInstance():getIdStr())

	local c = self:getCurGameplayContextDrawCount()
	CCUserDefault:setIntegerForKey('lottery.cur.context.draw.count' .. uid, c + 1)
end

function LotteryLogic:getCurGameplayContextDrawCount( ... )
	local uid = UserManager:getInstance().uid or "12345"
	local lastPlayId = CCUserDefault:getStringForKey('lottery.lastPlayId.' .. uid, '') or ''
	if lastPlayId == GamePlayContext:getInstance():getIdStr() then
		return CCUserDefault:getIntegerForKey('lottery.cur.context.draw.count' .. uid, 0), 0
	else
		return 0
	end
end

return LotteryLogic