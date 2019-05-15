--[[
 * AdNode
 * @date    2018-08-27 19:25:26
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AdNode = class()

function AdNode:ctor(name, flag, delegate, placementIds)
	self.name = name
	self.flag = flag
	self.delegate = delegate
	self.isInit = false
	self.placementIds = placementIds or {}
end

function AdNode:initSdk()
	if self.isInit then return end
	self:print("init sdk:", self.name, table.tostring(self.placementIds))
	if pcall(function ()
		self.delegate:initSdk("notused", self:callback())
		self:loadAd()
	end) then
		self.isInit = true
	else
		self:onAdsError(AdsError.kInitializedFailed, self.name .. "init fail")
	end
end

function AdNode:print( ... )
	InciteManager:print(...)
end

function AdNode:isInitialized()
	if not self.isInit then return false end
	return self.delegate:isInitialized()
end

function AdNode:isSupported()
	if __ANDROID then
		local osVersion = getOSVersionNumber() or 1
		return osVersion >= 4.1
	end
	return self.delegate:isSupported()
end

function AdNode:isPlaying()
	if not self.isInit then return false end
	return self.delegate:isPlaying()
end

function AdNode:play(entranceType)
	if not self.isInit then return end
	local placementId = self.placementIds[entranceType]
	self:print("play ad:", self.name, placementId)
	self.delegate:play(placementId)
end

function AdNode:isReady(entranceType)
	if not self.isInit then return false end
	local placementId = self.placementIds[entranceType]
	return self.delegate:isReady(placementId)
end

function AdNode:onAdsReady( placementId )
	InciteManager:onAdsReady( self.name, placementId )
end

function AdNode:onAdsPlayed( placementId )
	InciteManager:onAdsPlayed( self.name, placementId )
end

function AdNode:onAdsFinished( placementId, state )
	InciteManager:onAdsFinished( self.name, placementId, state )
end

function AdNode:onAdsError( code, msg )
	if code == AdsError.kInitializedFailed then
		self.isInit = false
	end
	InciteManager:onAdsError( self.name, code, msg )
end

function AdNode:loadAd()
	for et,placementId in pairs(self.placementIds) do
		if InciteManager:isEntryEnable( et ) then
			pcall(function ()
				self:print("loadAd: ", placementId)
				if placementId then
					self.delegate:loadAd(placementId)
				end
			end)
		end
	end
end

function AdNode:tryLoadAd()
	self:loadAd()
end

function AdNode:onEnterForground()
	if not self.isInit then return end

	self:print("onEnterForground :", self:isPlaying())
	if self:isPlaying() and __IOS then
		local scene = Director:sharedDirector():getRunningScene()
		scene:runAction(CCCallFunc:create(function ()
			Director:sharedDirector():pause()
		end))
	end

	self:tryLoadAd()
end

function AdNode:onAdsClicked()
	InciteManager:onAdsClicked( self.name )
end

function AdNode:callback()
	local context = self

	if __IOS then
		waxClass{"IosAdsCallbackImpl", NSObject, protocols = {"IosAdsCallback"}}
		function IosAdsCallbackImpl:ads_onError_msg( ads, code, msg )
			context:onAdsError(code, msg)
		end
		function IosAdsCallbackImpl:ads_onReady( ads, placementId )
			context:onAdsReady( placementId )
		end
		function IosAdsCallbackImpl:ads_onPlayStarted( ads, placementId )
			context:onAdsPlayed(placementId)
		end
		function IosAdsCallbackImpl:onClickAds( ads )
			context:onAdsClicked()
		end
		function IosAdsCallbackImpl:ads_onPlayFinished_state( ads, placementId, state )
			context:onAdsFinished(placementId, state)
		end
		return IosAdsCallbackImpl:init()
	elseif __ANDROID then
		return luajava.createProxy("com.happyelements.android.ads.InvokeCallbackAds",
		    {
		      onAdsReady = function(placementId)
		    	context:onAdsReady( placementId )
		      end,
		      onAdsPlayed = function(placementId)
		        context:onAdsPlayed(placementId)
		      end,
		      onAdsClicked = function(placementId)
		        context:onAdsClicked()
		      end,
		      onAdsFinished = function(placementId, state)
		        context:onAdsFinished(placementId, state)
		      end,
		      onAdsError = function ( placementId, code, message )
		      	context:onAdsError(code, message)
		      end
		    }
  		)
  	elseif __WIN32 then
  		return self
	end
end