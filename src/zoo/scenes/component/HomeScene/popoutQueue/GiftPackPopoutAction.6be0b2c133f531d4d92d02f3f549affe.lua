--[[
 * GiftPackPopoutAction
 * @date    2019-01-13 15:27:19
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

GiftPackPopoutAction = class(HomeScenePopoutAction)

function GiftPackPopoutAction:ctor()
	self.name = "GiftPackPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter)
end

function GiftPackPopoutAction:checkCanPop()
	self:onCheckPopResult(self:canForcePop())
end

function GiftPackPopoutAction:getPoptime()
	local userDefault = CCUserDefault:sharedUserDefault()
	return tonumber(userDefault:getStringForKey("giftpack.poptime")) or 0
end

function GiftPackPopoutAction:setPoptime()
	local userDefault = CCUserDefault:sharedUserDefault()
	local time = tostring(Localhost:timeInSec())
	userDefault:setStringForKey("giftpack.poptime", time)
   	userDefault:flush()
end


function GiftPackPopoutAction:canForcePop()
	if not GiftPack:isEnabled() then
		return false 
	end

	if not GiftPack:hasAnyReward() then
		return false
	end

	local poptime = self:getPoptime()
	local now = Localhost:timeInSec()

	return compareDate(os.date('*t', now), os.date('*t', poptime or 0)) ~= 0
end

function GiftPackPopoutAction:popout(next_action)
	MarketManager:sharedInstance():loadConfig()
	local index = MarketManager:sharedInstance():getGiftPackPageIndex()
	if index ~= 0 then
		local panel =  createMarketPanel(index, nil, next_action)
		if panel then
			GiftPack:dc('canyu', 'shop_push', {t1 = 1})
			self:setPoptime()
			panel:popout()
		else
			next_action()
		end
	else
		next_action()
	end
end