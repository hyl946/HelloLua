--[[
 * IosAd
 * @date    2018-08-27 19:48:28
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

IosAd = class()

function IosAd:ctor( name, flag )
	self.name = name
	self.flag = flag
	self.ad = IosAds:sharedAds()
end

function IosAd:initSdk(placementId, cb)
	self.ad:setCallback(cb)
	self.ad:init_placementId(self.flag, placementId)
end

function IosAd:isInitialized()
	return self.ad:isInitialized(self.flag)
end

function IosAd:isSupported()
	if __IOS then
		return self.ad:isSupported(self.flag)
	end
	return false
end

function IosAd:isPlaying()
	return self.ad:isPlaying()
end

function IosAd:play( placementId )
	self.ad:play_placementId(self.flag, placementId)
end

function IosAd:isReady( placementId )
	return self.ad:isReady_placementId(self.flag, placementId)
end

function IosAd:loadAd( placementId )
	self.ad:loadAd_placementId(self.flag, placementId)
end