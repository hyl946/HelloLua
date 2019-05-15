--[[
 * WinAd
 * @date    2018-08-29 15:19:52
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

WinAd = class()

function WinAd:ctor( name, flag )
	self.name = name
	self.flag = flag
end

function WinAd:initSdk(placementId, cb)
	self.cb = cb
end

function WinAd:isInitialized()
	return true
end

function WinAd:isSupported()
	return true
end

function WinAd:isPlaying()
	return false
end

function WinAd:play( placementId )
	if VideoAdUnitTest then
		VideoAdUnitTest:play(self.cb, placementId)
	else
		setTimeOut(function ()
			if self.cb then 
				self.cb:onAdsFinished(placementId, AdsFinishState.kCompleted) 
			end
		end, 0)
	end
end

function WinAd:loadAd( placementId )
	setTimeOut(function ()
		if self.cb then 
			self.cb:onAdsReady(placementId)
		end
	end, 0)
end

function WinAd:isReady( placementId )
	return true
end