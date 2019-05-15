require "hecore.ui.LayoutBuilder"

--测试功能
require 'zoo.quarterlyRankRace.plugins.PluginConfig'

local simplejson = require("cjson")
local builderCached = {}
local configCached = {}

local kDrawDebugRect = false
local kInterfaceGroupLayoutType = {kImage = 0, kText = 1, kGroup = 2}
local kInterfaceAlignType = {kTop = 1, kLeft = 2, kBottom = 4, kRight = 8, kVCenter = 16, kHCenter = 32}

InterfaceBuilder = class()
function InterfaceBuilder:ctor( json, filePath )
	self.config = json
	self.filePath = filePath
end

--
-- static ---------------------------------------------------------
--
function InterfaceBuilder:preloadJson(filePath)
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
	local config = configCached[filePath]
	if not config then
		local path = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath) 
		local t, fsize = lua_read_file(path)   
		config = table.deserialize(t) --simplejson.decode(t)
		if not config then -- 解析失败
			he_log_error("InterfaceBuilder fail, preloadJson: "..filePath)
	     	assert(false)
	     	return nil
	    end
		configCached[filePath] = config
	end
	return config
end
function InterfaceBuilder:removeLoadedJson(filePath)
	if configCached[filePath] ~= nil then 
		configCached[filePath] = nil
	end
end
local releaseIgnoreList = {}
function InterfaceBuilder:addIgnore(filePath)
	table.insert(releaseIgnoreList, filePath)
end

function InterfaceBuilder:preloadAsset( filePath )
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
	local config = InterfaceBuilder:preloadJson(filePath)
	local fileSeparater = "/"
	local separatedFilePath = filePath:split(fileSeparater)
	local prefix = ""
	for index = 1,#separatedFilePath - 1 do
		prefix = prefix ..separatedFilePath[index] .. fileSeparater
	end

	local plist = prefix .. config.config
	local image = prefix .. config.image
	local realPlistPath, realPngPath = SpriteUtil:addSpriteFramesWithFile(plist, image)
	config.plistPath = plist
	config.realPlistPath = realPlistPath
	config.realPngPath = realPngPath
	return config
end
function InterfaceBuilder:unloadAsset(filePath)
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
	local config = InterfaceBuilder:preloadJson(filePath)
	local found = table.indexOf(releaseIgnoreList, filePath) ~= nil
	if config and config.realPngPath and not found then
		SpriteUtil:removeLoadedPlist( config.plistPath )
		if not __WP8 then
			CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(config.realPngPath))
			local realPlistPath = config.realPlistPath
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(realPlistPath)
		else
			CCTextureCache:sharedTextureCache():removeUnusedTextures()
		end
		builderCached[filePath] = nil
	end
	
end

function InterfaceBuilder:getRealResourceName(filePath)
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
	return filePath
end

function InterfaceBuilder:createWithContentsOfFile(filePath)
	filePath = InterfaceBuilder:getRealResourceName(filePath)
	local builder = builderCached[filePath]

	if builder then InterfaceBuilder:preloadAsset(filePath)
	else
		local config = InterfaceBuilder:preloadAsset(filePath)
		builder = InterfaceBuilder.new(config, filePath)
		builderCached[filePath] = builder
	end
	return builder
end

function InterfaceBuilder:create( filePath )
	filePath = InterfaceBuilder:getRealResourceName(filePath)
	local builder = builderCached[filePath]
	if not builder then 
		local config = InterfaceBuilder:preloadJson(filePath)
		builder = InterfaceBuilder.new(config, filePath)
		builderCached[filePath] = builder
	end
	return builder
end

function InterfaceBuilder:alignInterfaceInbox( interface, boundingBox, needScale, alignment )
	local scaled = true
	if needScale ~= nil then scaled = needScale end

	if interface and interface.refCocosObj then
		if type(alignment) ~= "number" then alignment = kInterfaceAlignType.kVCenter + kInterfaceAlignType.kHCenter end
		local alignments = {}
		local n1, n2, n3 = alignment, 0, 1
		while n1 > 1 do
			n2 = n1 % 2
			if n2 == 1 then
				alignments[n3] = true
			end
			n1 = (n1 - n2) / 2
			n3 = n3 * 2
		end
		if n1 == 1 then
			alignments[n3] = true
		end

		local size = interface:getContentSize()

		local height = size.height
		local width = size.width
		local scale = 1
		if scaled then scale = math.min(boundingBox.height/height, boundingBox.width/width) end
		width = size.width * scale 
		height = size.height * scale
		interface:setScale(scale)

		--printx(0, "===========alignInterfaceInbox", scale, width, height)

		local x, y = boundingBox.x, boundingBox.y
		if alignments[kInterfaceAlignType.kHCenter] then
			x = boundingBox.x + (boundingBox.width - width) / 2
		elseif alignments[kInterfaceAlignType.kLeft] then
			-- do nothing
		elseif alignments[kInterfaceAlignType.kRight] then
			x = boundingBox.x + boundingBox.width - width
		end

		if alignments[kInterfaceAlignType.kVCenter] then
			y = boundingBox.y - (boundingBox.height - height) / 2
		elseif alignments[kInterfaceAlignType.kTop] then
			-- do nothing
		elseif alignments[kInterfaceAlignType.kBottom] then
			y = boundingBox.y - boundingBox.height + height
		end
		interface:setPosition(ccp(x, y))
	end
end

function InterfaceBuilder:centerInterfaceInbox( interface, boundingBox, forceScale )
	local scaled = true
	if forceScale ~= nil then scaled = forceScale end

	if interface and interface.refCocosObj then
		local size = interface:getContentSize()

		local height = size.height
		local scale = 1
		if scaled then scale = boundingBox.height/height end
		local width = size.width * scale 
		height = size.height * scale

		interface:setScale(scale)
		local x = boundingBox.x + (boundingBox.width - width) / 2
		local y = boundingBox.y - (boundingBox.height - height) / 2 -- by flash export, Y = -y
		interface:setPosition(ccp(x, y))
	end
end

--按宽度适配
function InterfaceBuilder:centerInterfaceInbox2( interface, boundingBox, forceScale )
	local scaled = true
	if forceScale ~= nil then scaled = forceScale end

	if interface and interface.refCocosObj then
		local size = interface:getContentSize()

		local width = size.width
		local scale = 1
		if scaled then scale = boundingBox.width/width end
		local width = size.width * scale 
		local height = size.height * scale

		interface:setScale(scale)
		local x = boundingBox.x + (boundingBox.width - width) / 2
		local y = boundingBox.y - (boundingBox.height - height) / 2 -- by flash export, Y = -y
		interface:setPosition(ccp(x, y))
	end
end

-- for left aligning text
function InterfaceBuilder:leftAligneInterfaceInbox( interface, boundingBox, forceScale )
	local scaled = true
	if forceScale ~= nil then scaled = forceScale end

	if interface and interface.refCocosObj then
		local size = interface:getContentSize()

		local height = size.height
		local scale = 1
		if scaled then scale = boundingBox.height/height end
		local width = size.width * scale 
		height = size.height * scale

		interface:setScale(scale)
		local x = boundingBox.x
		local y = boundingBox.y - (boundingBox.height - height) / 2 -- by flash export, Y = -y
		interface:setPosition(ccp(x, y))
	end
end
-- for right aligning text
function InterfaceBuilder:rightAligneInterfaceInbox( interface, boundingBox, forceScale )
	local scaled = true
	if forceScale ~= nil then scaled = forceScale end

	if interface and interface.refCocosObj then
		local size = interface:getContentSize()

		local height = size.height
		local scale = 1
		if scaled then scale = boundingBox.height/height end
		local width = size.width * scale 
		height = size.height * scale

		interface:setScale(scale)
		local x = boundingBox.x + boundingBox.width - width
		local y = boundingBox.y - (boundingBox.height - height) / 2 -- by flash export, Y = -y
		interface:setPosition(ccp(x, y))
	end
end

--
-- methods ---------------------------------------------------------
--
local function sortByIndex(a, b) return a.index < b.index end

local function hex2ccc3( color )
	local textColor = tostring(color)
  	if #textColor > 6 then textColor = string.sub(textColor, 2, 7) end
  	local integer = tonumber(textColor, 16)
  	local ret = HeDisplayUtil:ccc3FromUInt(integer)
  	return ret
end
local function getFontFace( designedFont )
	return getGlobalDynamicFontMap(designedFont)
end

local function addDebugBounds( layout, parentLayer )
	if not kDrawDebugRect then return end
	local bounds = layout:getGroupBounds()
	local boundsLayer = LayerColor:create()
	boundsLayer:setColor(ccc3(128,55,144))
	boundsLayer:setOpacity(80)
	boundsLayer:changeWidthAndHeight(bounds.size.width, bounds.size.height)
	boundsLayer:setAnchorPoint(ccp(0,0))
	boundsLayer:setPosition(ccp(bounds.origin.x, bounds.origin.y))
	if parentLayer then parentLayer:addChild(boundsLayer) end
end

local function setCocosRotation( obj, symbol )
	local rotation, skewX, skewY 
	if type(symbol.rotation) == "number" then rotation = symbol.rotation end
	if type(symbol.skewX) == "number" then skewX = symbol.skewX end
	if type(symbol.skewY) == "number" then skewY = symbol.skewY end

	if rotation ~= nil then obj:setRotation(rotation)
	else
		if skewX ~= nil and skewY ~= nil then
			obj:setRotationX(skewX)
			obj:setRotationY(skewY)
		end
	end
end

local function transformObjectByConfig( image, symbol )
	image.name = symbol.id

	assert( image.refCocosObj , "InterfaceBuilder Error symbolId=" .. tostring(symbol.id) )

	image:setPosition(ccp(symbol.x, -symbol.y))
	image:setScaleX(symbol.scaleX)
	image:setScaleY(symbol.scaleY)
	setCocosRotation(image, symbol)
	
	if symbol.type == kInterfaceGroupLayoutType.kImage and symbol.id == kHitAreaObjectName then
    	image:setVisible(false)
  	end
end

--
-- parse images ---------------------------------------

local function parseScale9Sprite( symbol, imageSuffix )
	local image = assert(Scale9SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
	assert(image.refCocosObj,"no img:"..tostring(symbol and symbol.image))
	image.name = symbol.id
	image:setPosition(ccp(symbol.x, -symbol.y))
	image:setPreferredSize(CCSizeMake(symbol.width, symbol.height))
	image:setAnchorPoint(ccp(0, 1))
	setCocosRotation(image, symbol)
	
	return image
end
local function parseNormalSprite( symbol, imageSuffix )
	local image = assert(SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
	transformObjectByConfig(image, symbol)
	image:setAnchorPoint(ccp(0, 1))
	return image
end
local function parseImageSymbol( symbol, imageSuffix )
	if type(symbol.scalingGrid) == "boolean" and symbol.scalingGrid then return parseScale9Sprite( symbol, imageSuffix )
	else return parseNormalSprite( symbol, imageSuffix ) end
end

--
-- parse texts ---------------------------------------

local function parseStaticText( symbol, hAlignment )
	local text = TextField:create("", nil, symbol.size, CCSizeMake(symbol.width, symbol.height), hAlignment, kCCVerticalTextAlignmentTop)
	text:setColor(hex2ccc3(symbol.fillColor))
	return text
end
local function parseDynamicText( symbol, hAlignment )
	local fnt = getFontFace(symbol.face)
	local text = BitmapText:create("", fnt, -1, hAlignment)
	assert(text,"no DynamicText:"..tostring(symbol.face).." on txt:"..tostring(symbol.id))
	text.fntFile = fnt
	text.hAlignment = hAlignment
	text.width = symbol.width
	text.height = symbol.height
	return text
end
local function parseText( symbol )
	local hAlignment = kCCTextAlignmentLeft
	if symbol.alignment == "center" then hAlignment = kCCTextAlignmentCenter 
	elseif symbol.alignment == "right" then hAlignment = kCCTextAlignmentRight end
	local text = nil
	if symbol.textType == "static" then text = parseStaticText(symbol, hAlignment)
	else text = parseDynamicText(symbol, hAlignment) end

	text.name = symbol.id
	text:setPosition(ccp(symbol.x, -symbol.y))
	text:setAnchorPoint(ccp(0, 1))
	setCocosRotation(text, symbol)

	return text
end

function InterfaceBuilder:buildGroup( groupName, imageSuffix , usePlugin, batchMode, uniqName)
	if not self.config then
		-- if _G.isLocalDevelopMode then printx(0, "build ui fail. no config:"..groupName) end
		return nil
	end
	local group = self.config.groups[groupName]
	if not group then
		-- if _G.isLocalDevelopMode then printx(0, "build ui fail. no group:"..groupName) end
		return nil
	end
	imageSuffix = imageSuffix or "0000"

	local pluginName = usePlugin and PluginConfig:getPluginName(groupName) or nil
	if usePlugin then
		--printx(61, pluginName, groupName)
	end
	local PluginClass = pluginName and PluginConfig:loadPlugin(pluginName) or nil

	if batchMode ~= false then
		if type(batchMode) ~= "string" then 
			if string.ends(groupName, "_batch_node") then
				batchMode = "batch"
			elseif string.ends(groupName, "_batch_sprite") then -- default
				batchMode = "sprite"
			else
				batchMode = false
			end
		end
	end

	local groupLayer = nil
	if PluginClass then
		groupLayer = PluginClass.new()
		groupLayer.pluginTag = pluginName
	else
		if batchMode then
			local _imageKey = CCFileUtils:sharedFileUtils():fullPathForFilename(self.config.realPngPath)
			local texture = CCTextureCache:sharedTextureCache():textureForKey(_imageKey)
			assert(texture, "texture can not found:"..tostring(_imageKey))
			if batchMode == "batch" then
				groupLayer = SpriteBatchNode:createWithTexture(texture)
			elseif batchMode == "sprite" then
				groupLayer = SpriteColorAdjust:createEmpty()
				groupLayer:setTexture(texture)
			end
		else
			groupLayer = Layer:create()
		end
	end

	groupLayer.name = groupName
	groupLayer.symbolName = groupName
	if _G.RegionsCollectEnable then
	 	uniqName = uniqName and (uniqName .. "_" .. groupName) or groupName
	 	groupLayer.uiNodeUniqName = uniqName
	end
	
	table.sort(group, sortByIndex)
	for k,symbol in ipairs(group) do
		if symbol.type == kInterfaceGroupLayoutType.kImage then
			local image = parseImageSymbol(symbol, imageSuffix)
			if image then 
		      	if type(symbol.alphaPercent) == "number" then
					image:setOpacity(symbol.alphaPercent * 2.55) -- * 255 / 100
				end
				groupLayer:addChild(image)
			end
			addDebugBounds(image, groupLayer)
		elseif symbol.type == kInterfaceGroupLayoutType.kText then
			local text = parseText(symbol)
			groupLayer:addChild(text)
			addDebugBounds(text, groupLayer)
		elseif symbol.type == kInterfaceGroupLayoutType.kGroup then
			local childBatchMode = batchMode and "sprite" or nil
			local layout = self:buildGroup(symbol.image, imageSuffix, usePlugin, childBatchMode, uniqName)
			if layout then
				transformObjectByConfig(layout, symbol)
				groupLayer:addChild(layout)
			end
		end
	end
	if PluginClass then
		groupLayer:onPluginInit()
	end	
	addDebugBounds(groupLayer)
	return groupLayer
end

-- For unknown reason common_ui and properties might be released
InterfaceBuilder:addIgnore(PanelConfigFiles.common_ui)
InterfaceBuilder:addIgnore(PanelConfigFiles.properties)
InterfaceBuilder:addIgnore(PanelConfigFiles.login_panels)