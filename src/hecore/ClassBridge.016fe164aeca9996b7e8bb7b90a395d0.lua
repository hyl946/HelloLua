CCSprite = HeSprite
CCParticleBatchNode = HeParticleBatchNode
CCParticleSystem = HeParticleSystem
CCScale9Sprite = HeScale9Sprite
CCSpriteBatchNode = HeSpriteBatchNode
CCSpriteFrame = HeSpriteFrame
CCSpriteFrameCache = HeSpriteFrameCache
CCTexture = HeTexture
CCTextureAtlas = HeTextureAtlas
CCTextureCache = HeTextureCache
CCLabelBMFont = HeLabelBMFont
CCAnimate = HeAnimate
CCAnimation = HeAnimation
CCParticleSystemQuad = HeParticleSystemQuad
CCProgressTimer = HeProgressTimer
CCRenderTexture = HeRenderTexture

-- ori_create = CCNode.create
-- CCNode.create = function (...)
-- 	local obj = ori_create(...)
-- 	if _G.useMemoryTable then
-- 		putOneObjeatInMemoryTable(obj)
-- 	end
-- 	return obj
-- end

local forbiddenEtc = false

if __ANDROID then
	local deviceType = MetaInfo:getInstance():getMachineType() or ""
	if string.sub(deviceType,1,4) == "GT-I" or 
		deviceType == "SM-J3300" then
		forbiddenEtc = true
	end

	-- local deviceProduct = ""
	-- local deviceBrand = ""
	-- local success, ret = pcall(function()
	-- local build = luajava.bindClass("android.os.Build")
	-- 	deviceProduct = string.lower(build.PRODUCT)
	-- 	deviceBrand = string.lower(build.BRAND)
	-- end)
	-- if string.sun(deviceProduct,1,3) == "SM-" and deviceBrand == "samsung" then
	-- 	forbiddenEtc = true
	-- end

end

if forbiddenEtc then
	HeTextureCache:sharedTextureCache():disableETCHardware()
end

myPcall = function ( func, ... )
	local ret = {pcall(func, ...)}
	local st = ret[1]
	if st then
		table.remove(ret, 1)
		return unpack(ret)
	else
		return nil
	end
end