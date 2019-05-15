require "hecore.EventDispatcher"
require "hecore.ui.LayoutBuilder"

kFrameLoaderType = {
	json = ".json",
	plist = ".plist",
	xml = ".xml",
	zip = ".zip",
	mp3 = ".mp3",
	sfx = ".sfx",
	png = ".png",
	jpg = ".jpg",
	pvr = ".pvr",
	skeleton = ".skeleton",

	level = '.level',
	meta = '.meta',
}
FrameLoader = class(EventDispatcher)

function FrameLoader:ctor()
	self.list = {}
	self.loading = false
	self.loaded = 0
end

function FrameLoader:add( resource, type )
	table.insert(self.list, {resource, type})
end

function FrameLoader:addRandom( resource, type )
	local pos = math.random(1, #self.list)
	table.insert(self.list, pos, {resource, type})
end

function FrameLoader:load()
	if #self.list < 1 then 
		self:onLoaderCompleted()
		return
	end

	local funcId = nil
	local context = self
	local function onFrameLoaderTick()
		local time = os.clock()
		repeat
			local b = os.clock()

			context:syncLoad()
			context.loaded = context.loaded + 1
			if context.loaded > #context.list then
				if funcId ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(funcId) end
				context:onLoaderCompleted()
				break
			end

			local now = os.clock()

			if now - b > 1/90 then
				break
			end

			if now - time > 1/60 then
				break
			end
			
		until(false)
	end

	if self.loading then
		if _G.isLocalDevelopMode then printx(0, "ERROR: alread loading") end
	else
		self.loading = true
		self.loaded = 1
		funcId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onFrameLoaderTick)
	end
end

function FrameLoader:loadPngOnly( filePath, noCacheTexture )
    local realPngPath = SpriteUtil:getRealResourceName( filePath )
    local sprite = Sprite:create(realPngPath)
    if noCacheTexture then
    	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(realPngPath))
    end
    return sprite
end

function FrameLoader:loadImageWithPlist( filePath )
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
	local prefix = string.split(filePath, ".")[1]
	local pngPath = prefix..".png"
	local pf = ResourceConfigPixelFormat[filePath]
	if pf ~= nil then
		SpriteUtil:setTexturePixelFormat(pngPath, pf)
		if _G.isLocalDevelopMode then printx(0, "setTexturePixelFormat:", pngPath, pf) end
	end
	--if _G.isLocalDevelopMode then printx(0, string.format("loading plist: %s %s", filePath, pngPath)) end
	SpriteUtil:addSpriteFramesWithFile(filePath, pngPath)
end

------------------------
--force = true 时删除CCSpriteFrameCache中的内容，慎用
----------------------
function FrameLoader:unloadImageWithPlists( plists, force )
	local function doUnload(filePath)
		filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
		local prefix = string.split(filePath, ".")[1]
		local pngPath = prefix..".png"
		local realPngPath = SpriteUtil:getRealResourceName( pngPath )
		SpriteUtil:removeLoadedPlist( filePath )
		if not __WP8 then
			CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(realPngPath))
			if force then
				local realPlistPath = SpriteUtil:getRealResourceName(filePath)
				CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(realPlistPath)
			end
		else
			CCTextureCache:sharedTextureCache():removeUnusedTextures()
		end
	end

	if type(plists)=="string" then
		doUnload(plists)
	elseif type(plists)=="table" then
		for i,filePath in ipairs(plists) do
			doUnload(filePath)
		end
	end
end

--------------------------------------------------------------------
-- @resourceSrc		directory path of skeleton animation
-- @skeletonName	define in skeleton.xml, such as <dragonBones name="skeletonName" frameRate="24" version="2.3">
-- @textureName		define in texture.xml such as <TextureAtlas name="textureName" imagePath="texture.png">
--------------------------------------------------------------------
local kFrameLoaderArmatures = {}
function FrameLoader:loadArmature( resourceSrc, skeletonName, textureName )
	if ResourceArmaturePixelFormat[resourceSrc] ~= nil then
	    CCTexture2D:setDefaultAlphaPixelFormat(ResourceArmaturePixelFormat[resourceSrc])
	end

	local groups = resourceSrc:split("/")
	if groups[1] == "skeleton" then
		skeletonName = skeletonName or groups[2]
		textureName = textureName or groups[2]
	end

	local armaturePath = resourceSrc
	resourceSrc = FrameLoader:getRealResourceName(resourceSrc)
	-- if __use_small_res then
	-- 	ArmatureFactory:add(resourceSrc.."@2x", skeletonName, textureName)
	-- else
		-- local t1 = _utilsLib.mstime()
		ArmatureFactory:add(resourceSrc, skeletonName, textureName)
		-- print('loaddragon_frame:' .. skeletonName .. '_' .. textureName)
		-- local t2 = _utilsLib.mstime()
	-- end
	kFrameLoaderArmatures[armaturePath] = {resPath = resourceSrc, skeletonName = skeletonName, textureName = textureName}

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	-- return t2-t1
end

function FrameLoader:unloadArmature( resourceSrc, cleanup )
	local armatureData = kFrameLoaderArmatures[resourceSrc]
	if armatureData then
		ArmatureFactory:remove(armatureData.skeletonName, armatureData.textureName)
		if cleanup then
			CCTextureCache:sharedTextureCache():removeTextureForKey(armatureData.resPath.."/texture.png")
		end
	end
end

function FrameLoader:getRealResourceName(fileName)
	fileName = ResourceManager:sharedInstance():getMappingFilePath(fileName)
	if __use_small_res then
		return fileName.."@2x"
	else
		return fileName
	end
end

function FrameLoader:syncLoad()
	local res = self.list[self.loaded]
	if res then
		local resourceSrc = res[1]
		local resourceType = res[2]
		
		if resourceType == kFrameLoaderType.plist then
			self:loadImageWithPlist(resourceSrc)
		elseif resourceType == kFrameLoaderType.json then			
			--if _G.isLocalDevelopMode then printx(0, "loading json:", resourceSrc) end
			LayoutBuilder:createWithContentsOfFile(resourceSrc)
		elseif resourceType == kFrameLoaderType.skeleton then
			FrameLoader:loadArmature( resourceSrc )
		elseif resourceType == kFrameLoaderType.mp3 then
			SimpleAudioEngine:sharedEngine():preloadBackgroundMusic(resourceSrc)
		elseif resourceType == kFrameLoaderType.sfx then
			--if _G.isLocalDevelopMode then printx(0, resourceSrc) end
			SimpleAudioEngine:sharedEngine():preloadEffect(resourceSrc)
		elseif resourceType == kFrameLoaderType.level then
			LevelMapManager.getInstance():loadSingleLevel(resourceSrc)
		elseif resourceType == kFrameLoaderType.meta then
			MetaManager.getInstance():loadSingleMeta( resourceSrc )
		end
	end
	if self:hasEventListenerByName(Events.kProgress) then
        self:dispatchEvent(Event.new(Events.kProgress, self))
    end 
end

function FrameLoader:getLength()
	return #self.list
end

function FrameLoader:onLoaderCompleted()
	self.list = nil
	if self:hasEventListenerByName(Events.kComplete) then
        self:dispatchEvent(Event.new(Events.kComplete, self))
    end
    collectgarbage("collect")
end


AsyncLoader = class(EventDispatcher)

local instance = nil

function AsyncLoader:ctor()
	self.loading = false
end

function AsyncLoader:getInstance()
	if not instance then
		instance = AsyncLoader.new()
	end
	return instance
end

function AsyncLoader:load()
	self.loading = true

	local counter = 0
	local total = 0
	local function loadedCallback()
		counter = counter + 1	
		if counter >= total then
			self.loading = false
		end
	end
	for i, filePath in ipairs(ResourceConfig.asyncPlist) do
		local prefix = string.split(filePath, ".")[1]
		local pngPath = prefix..".png"
		local pf = ResourceConfigPixelFormat[filePath]
		if pf ~= nil then
			SpriteUtil:setTexturePixelFormat(pngPath, pf)
			if _G.isLocalDevelopMode then printx(0, "setTexturePixelFormat:", pngPath, pf) end
		end
		SpriteUtil:addSpriteFrameCacheAsync(filePath, pngPath, loadedCallback)
		total = total + 1
	end
end

function AsyncLoader:waitingForLoadComplete(completeCallback)
	local function waitingCheck()
		if not self.loading then
			if self.waitingScheduleId ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.waitingScheduleId) end
			if completeCallback and type(completeCallback) == 'function' then
				completeCallback()
			end
		end 
	end

	if self.loading then
		self.waitingScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(waitingCheck)
	else
		if completeCallback and type(completeCallback) == 'function' then
			completeCallback()
		end
	end
end