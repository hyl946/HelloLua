-------------------------------------------------------------------------
--  Class include: AdvertiseAndroid, AdvertiseIOS, AdvertiseSDK
-------------------------------------------------------------------------

require "hecore.class"

--
-- AdvertiseAndroid ---------------------------------------------------------
--
-- initialize
local instanceAndroid = nil
AdvertiseAndroid = {}

function AdvertiseAndroid.getInstance()
	if not instanceAndroid then instanceAndroid = AdvertiseAndroid end
	return instanceAndroid
end

function AdvertiseAndroid:presentDomobListOfferWall(userID)
	
end
function AdvertiseAndroid:presentLimeiListOfferWall(userID)
end


--
-- AdvertiseIOS ---------------------------------------------------------
--
-- initialize
local instanceIOS = nil
AdvertiseIOS = {}

function AdvertiseIOS.getInstance()
	if not instanceIOS then instanceIOS = AdvertiseIOS end
	return instanceIOS
end

function AdvertiseIOS:presentDomobListOfferWall(userID)
	if userID then
		-- OfferWallController:getInstance():presentDomobListOfferWall(userID)
	end
end

function AdvertiseIOS:presentLimeiListOfferWall(userID)
	if userID then
		-- OfferWallController:getInstance():presentLimeiListOfferWall(userID)
	end
end

function AdvertiseIOS:presentAdwoListOfferWall(userID)
	if userID then
		-- OfferWallController:getInstance():presentAdwoListOfferWall(userID)
	end
end

--
-- AdvertiseSDK ---------------------------------------------------------
--
AdvertiseSDK = class()
function AdvertiseSDK:ctor()
	if __IOS then
		self.sdk = AdvertiseIOS:getInstance()
	end
end

function AdvertiseSDK:presentDomobListOfferWall()
	if UserManager.getInstance():isPlayerRegistered() and self.sdk then
		self.sdk:presentDomobListOfferWall(tostring(UserManager.getInstance().uid))
		return true
	end
	return false
end
function AdvertiseSDK:presentLimeiListOfferWall()
	if UserManager.getInstance():isPlayerRegistered() and self.sdk then
		self.sdk:presentLimeiListOfferWall(tostring(UserManager.getInstance().uid))
		return true
	end
	return false
end
function AdvertiseSDK:presentAdwoListOfferWall()
	if UserManager.getInstance():isPlayerRegistered() and self.sdk then
		self.sdk:presentAdwoListOfferWall(tostring(UserManager.getInstance().uid))
		return true
	end
	return false
end

function AdvertiseSDK:presentDomobAD()
	-- local configGamePauseAD = MaintenanceManager:getInstance().GamePauseAD
	-- if __IOS and configGamePauseAD and configGamePauseAD.enable then
	if MaintenanceManager:getInstance():isEnabled("GamePauseAD") and __IOS then
	--if __IOS then
		--OfferWallController:getInstance():presentDomobAD()
	end
end

function AdvertiseSDK:presentFishbowlAD()
	--if __IOS then
	if MaintenanceManager:getInstance():isEnabled("GamePauseAD") and __IOS then
		local filePath = "share/fishbowlAds.jpg"
		local winSize = CCDirector:sharedDirector():getVisibleSize()
		local origin = CCDirector:sharedDirector():getVisibleOrigin()
		local adSprite = Sprite:create(filePath)
	    local logoSize = adSprite:getContentSize()
		local scale = winSize.width/logoSize.width
		adSprite:setScale(scale)
	    adSprite:setAnchorPoint(ccp(0.5, 1))
	    adSprite:runAction(CCFadeIn:create(0.35))
	    
	    local function onTouchAD( evt )
	    	local url = NSURL:URLWithString("http://itunes.apple.com/app/id469027061")
	    	UIApplication:sharedApplication():openURL(url)
	    end
	    local labelLayer = Layer:create()
	    labelLayer:addChild(adSprite)
		labelLayer:setPosition(ccp(winSize.width/2, winSize.height + origin.y))
		labelLayer:setTouchEnabled(true)
		labelLayer:addEventListener(DisplayEvents.kTouchTap, onTouchAD)

		CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(filePath))
	    return labelLayer
	end
	return nil
end

function AdvertiseSDK:dismissDomobAD()
	if __IOS then
		-- OfferWallController:getInstance():dismissDomobAD()
	end
end