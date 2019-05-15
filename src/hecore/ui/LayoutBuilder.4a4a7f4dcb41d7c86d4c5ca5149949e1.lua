
require "hecore.utils"
require "hecore.display.Director"
require "hecore.display.TextField"


local kDrawDebugRect = false

if kDrawDebugRect then
	he_log_warning("dont't forget to set variabel kDrawDebugRect to false")
end

local configCached = {}
local builderCached = {}

kGroupLayoutType = {kImage = 0, kText = 1, kGroup = 2}

local globalFontMapping = {}

LayoutBuilder = class()
function LayoutBuilder:ctor(config)
  self.config = config
  self.fontMapping = {}
  self.fontBuilderFunc = {}

  self.contentScaleFactor	= 1 --CCDirector:sharedDirector():getContentScaleFactor()
end

function LayoutBuilder:getJsonFilePath(...)
	assert(#{...} == 0)

	assert(self.jsonFilePath)
	return self.jsonFilePath
end

--自己addjson的素材  要想不常住内存还可重复调用  二次调用时要调这个清缓存
function LayoutBuilder:deleteConfig(filePath)
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
	local fullFilePath = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)
	ResourceManager:sharedInstance().layoutBuilderByFileName[fullFilePath] = nil
	builderCached[filePath] = nil
	configCached[filePath] = nil
end

function LayoutBuilder:createWithContentsOfFile(filePath)
	filePath = ResourceManager:sharedInstance():getMappingFilePath(filePath)
  local aBuilder = builderCached[filePath]
  if aBuilder then
    return aBuilder
  end
  local config = configCached[filePath]
  if not config then
    local path = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)    
    --[[local file = io.open(path, "r")
    if not file then
      if _G.isLocalDevelopMode then printx(0, "LayoutBuilder fail, file not exist: "..filePath) end
      assert(false)
      return;
    end

    local t = file:read("*all")
    io.close(file)]]
    
    local t, fsize = lua_read_file(path)
    config = table.deserialize(t) -- simplejson.decode(t)
    
    if not config then -- 解析失败
		he_log_error("LayoutBuilder fail, createWithContentsOfFile: "..filePath)
     	assert(false)
     	return nil
    end

    configCached[filePath] = config
  end
  local fileSeparater = "/"

  local separatedFilePath = filePath:split(fileSeparater)
--  local prefix = separatedFilePath[1]..fileSeparater
--  if #separatedFilePath == 1 then prefix = "" end

	local prefix = ""
	for index = 1,#separatedFilePath - 1 do
		prefix = prefix ..separatedFilePath[index] .. fileSeparater
	end

	local plist = prefix .. config.config
	local image = prefix .. config.image
  
	SpriteUtil:addSpriteFramesWithFile(plist, image)
	aBuilder = LayoutBuilder.new(config)
	aBuilder.jsonFilePath = filePath
	aBuilder.imageFilePath	= image

	builderCached[filePath] = aBuilder
	return aBuilder
end

function LayoutBuilder:getGroups(...)
	assert(#{...} == 0)

	assert(self.config)

	return self.config.groups
end

function LayoutBuilder:getGroup(groupName, ...)
	assert(#{...} == 0)

	local result = self.config.groups[groupName]
	assert(result)
	return result
end

local function setBasicTransformation(image, symbol, parent)
  image.name = symbol.id

  local contentScaleFactor = 1 --CCDirector:sharedDirector():getContentScaleFactor()
  
  --image:setPosition(ccp(symbol.x, -symbol.y))
  -- Add contentScaleFactor Support
  image:setPosition(ccp(symbol.x / contentScaleFactor, - symbol.y / contentScaleFactor))
  image:setScaleX(symbol.scaleX)
  image:setScaleY(symbol.scaleY)

  if symbol.rotation ~= nil then
    if symbol.rotation ~= 0 then image:setRotation(symbol.rotation) end
  else
    image:setRotationX(symbol.skewX)
    image:setRotationY(symbol.skewY)
  end
  
  parent:addChild(image)
  if symbol.type == kGroupLayoutType.kImage and symbol.id == kHitAreaObjectName then
    image:setVisible(false)
  end
end

local function buildText(symbol, builder)

  local contentScaleFactor = 1 --CCDirector:sharedDirector():getContentScaleFactor()

  local hAlignment = kCCTextAlignmentLeft
  if symbol.alignment == "center" then
    hAlignment = kCCTextAlignmentCenter 
  elseif symbol.alignment == "right" then
    hAlignment = kCCTextAlignmentRight
  end
    
  local text
--  if symbol.textType == "static" then
--    text = TextField:create("text",builder:getFontFace(symbol.face), symbol.size, CCSizeMake(symbol.width, symbol.height), hAlignment, kCCVerticalTextAlignmentTop)
--    text:setColor(builder:hex2ccc3(symbol.fillColor))
--  else
--    if symbol.dynamicName then
--      text = BitmapText:create("bitmap", builder:getFontFace(symbol.face), symbol.width, hAlignment)
--    end
--  end
	if symbol.textType == "static" then
		text = TextField:create("",builder:getFontFace(symbol.face), symbol.size, CCSizeMake(symbol.width, symbol.height), hAlignment, kCCVerticalTextAlignmentTop)
		text:setColor(builder:hex2ccc3(symbol.fillColor))

		text:setPreferredSize(symbol.width, symbol.height)
	elseif symbol.textType == "dynamic" then
		-- A Bitmap Font Is More Possible To Provide Character "0" than "bitmap"
		--text = BitmapText:create("00", builder:getFontFace(symbol.face), symbol.width, hAlignment)
		--text = BitmapText:create("00", getGlobalDynamicFontMap(symbol.face), symbol.width, hAlignment)

		local fntFile	= getGlobalDynamicFontMap(symbol.face)
		text = BitmapText:create("", getGlobalDynamicFontMap(symbol.face), -1, hAlignment)

		text.fntFile 	= fntFile
		text.hAlignment = hAlignment
        text.fntColor = string.sub(symbol.fillColor, 2)

		assert(symbol.width)
		assert(symbol.height)
		text:setPreferredSize(symbol.width, symbol.height)
	else
		assert(false)
	end

  if text then
    text.name = symbol.id
    --text:setPosition(ccp(symbol.x, -symbol.y))
    -- Add contentScaleFactor Support
    text:setPosition(ccp(symbol.x / contentScaleFactor, -symbol.y / contentScaleFactor))
    text:setAnchorPoint(ccp(0,1))
    if symbol.rotation ~= nil then
      if symbol.rotation ~= 0 then text:setRotation(symbol.rotation) end
    else
      text:setRotationX(symbol.skewX)
      text:setRotationY(symbol.skewY)
    end
  end
  return text
end

local function sortBoneDepthList(a, b)
  return a.index < b.index;
end

local function addDebugBounds(layout, parentLayer)
  if not kDrawDebugRect then return end

  local contentScaleFactor	= 1 --CCDirector:sharedDirector():getContentScaleFactor()

  local bounds = layout:getGroupBounds()
  local boundsLayer = LayerColor:create()
  boundsLayer:setColor(ccc3(128,55,144))
  boundsLayer:setOpacity(89)
  boundsLayer:changeWidthAndHeight(bounds.size.width, bounds.size.height)
  boundsLayer:setAnchorPoint(ccp(0,0))
  --boundsLayer:setPosition(ccp(bounds.origin.x, bounds.origin.y))
  -- Add contentScaleFactor Support
  boundsLayer:setPosition(ccp(bounds.origin.x / contentScaleFactor, bounds.origin.y / contentScaleFactor))
  parentLayer:addChild(boundsLayer)

  --layout:addChild(boundsLayer)
  layout.debugBoundsLayer = boundsLayer
  layout.debugBoundsLayer:setVisible(false)

  boundsLayer.touchEnabled = false
  boundsLayer.touchChildren = false
end

function LayoutBuilder:buildBatchGroup(batchMode, groupName, imageSuffix, ...)
	assert(batchMode == "batch" or batchMode == "sprite")
	assert(type(groupName) == "string")
	assert(#{...} == 0)

	-- Check Version Number, Then Call The Proper Func
	assert(self.config)
	assert(self.config.version)

	local version = self.config.version

	if version == 1 then
		 -- Version 1, For Handle The Layout Jason File Format Version 1
		return self:buildBatchGroup_version1(batchMode, groupName, imageSuffix)
	elseif version == 2 then
		-- For Handle The Layout Jason File Format Version 2
		return self:buildBatchGroup_version2(batchMode, groupName, imageSuffix)
	else
		assert(false, "Only Layout Jason File Version 1 And 2 Support !")
	end

	return nil
end

function LayoutBuilder:buildBatchGroup_version1(batchMode, groupName, imageSuffix, uniqName, ...)
	assert(batchMode == "batch" or batchMode == "sprite")
	assert(type(groupName) == "string")
	assert(#{...} == 0)

	assert(self.config)

	-- Get Group
	local group = self.config.groups[groupName];
	assert(group, "not group: " .. groupName)
  
	imageSuffix = imageSuffix or "0000"

	-- Create A Batch Sprite As The Root Layer
	assert(self.imageFilePath)
	-- self.imageFilePath = SpriteUtil:getRealResourceName(self.imageFilePath)
	local _imageFile = SpriteUtil:getRealResourceName(self.imageFilePath)
	local texture = CCTextureCache:sharedTextureCache():addImage(_imageFile)
	assert(texture)

	local batchNode = false
	if batchMode == "batch" then
		batchNode = SpriteBatchNode:createWithTexture(texture)
	elseif batchMode == "sprite" then
		batchNode = SpriteColorAdjust:createEmpty()
		batchNode:setTexture(texture)
	end

 	batchNode.symbolName = groupName
 	if _G.RegionsCollectEnable then
	 	uniqName = uniqName and (uniqName .. "_" .. groupName) or groupName
	 	batchNode.uiNodeUniqName = uniqName
	end

	table.sort(group, sortBoneDepthList);

	for k,symbol in ipairs(group) do
		if symbol.type == kGroupLayoutType.kImage then

			local image = nil
			-- Not Support The Scale 9 Sprite Yet ! There Has A Method To Support
			if type(symbol.scalingGrid) == "boolean" and symbol.scalingGrid then
				local assertFalseMsg = "build batch group not support scale 9 sprite yet ! \n"
				assertFalseMsg = assertFalseMsg .. "in group: " .. groupName .. " component: " .. symbol.id
				assert(false, assertFalseMsg)
			else
				image = SpriteColorAdjust:createWithSpriteFrameName(symbol.image .. imageSuffix)
				assert(image)
				image:setAnchorPoint(ccp(0,1))

				---- Create The CCSpriteBatchNode At This Time
				---- Because We Can Know The Texture To Use Now
				--if not batchNode then
				--	batchNode = 
				setBasicTransformation(image, symbol, batchNode)
			end

			if image and symbol.alphaPercent ~= nil then
				image:setOpacity(symbol.alphaPercent * 2.55) -- * 255 / 100
			end
		elseif symbol.type == kGroupLayoutType.kText then
				local assertFalseMsg = "build batch group not support CCLabel*  yet ! \n"
				assertFalseMsg = assertFalseMsg .. "in group: " .. groupName .. " component: " .. symbol.id
				-- assert(false, assertFalseMsg)

		elseif symbol.type == kGroupLayoutType.kGroup then

			local layout = self:buildBatchGroup_version1("sprite", symbol.image, imageSuffix, uniqName )
			if layout then
				setBasicTransformation(layout, symbol, batchNode)
			end
		end
	end

	return batchNode
end


function LayoutBuilder:buildBatchGroup_version2(batchMode, groupName, imageSuffix, uniqName, ...)
	assert(batchMode == "batch" or batchMode == "sprite")
	assert(type(groupName) == "string")
	assert(#{...} == 0)

	assert(self.config)
	assert(self.config.groups[groupName].canBatch)
	-- Get Group
	local group = self.config.groups[groupName].components;
	assert(group, "not group: " .. groupName)
  
	imageSuffix = imageSuffix or "0000"

	-- Get The Texture
	assert(self.imageFilePath)
	-- self.imageFilePath = SpriteUtil:getRealResourceName(self.imageFilePath)
	local _imageFile = SpriteUtil:getRealResourceName(self.imageFilePath)
	local texture = CCTextureCache:sharedTextureCache():addImage(self._imageFile)
	assert(texture)

	local batchNode = false
	if batchMode == "batch" then
		batchNode = SpriteBatchNode:createWithTexture(texture)
	elseif batchMode == "sprite" then
		batchNode = SpriteColorAdjust:createEmpty()
		batchNode:setTexture(texture)
	end

	batchNode.name = groupName
 	batchNode.symbolName = groupName
 	if _G.RegionsCollectEnable then
	 	uniqName = uniqName and (uniqName .. "_" .. groupName) or groupName
	 	batchNode.uiNodeUniqName = uniqName
	end

	table.sort(group, sortBoneDepthList);

	for k,symbol in ipairs(group) do
		if symbol.type == kGroupLayoutType.kImage then

			local image = nil
			-- Not Support The Scale 9 Sprite Yet ! There Has A Method To Support
			if type(symbol.scalingGrid) == "boolean" and symbol.scalingGrid then
				local assertFalseMsg = "build batch group not support scale 9 sprite yet ! \n"
				assertFalseMsg = assertFalseMsg .. "in group: " .. groupName .. " component: " .. symbol.id
				assert(false, assertFalseMsg)
			else
				image = SpriteColorAdjust:createWithSpriteFrameName(symbol.image .. imageSuffix)
				assert(image)
				image:setAnchorPoint(ccp(0,1))

				---- Create The CCSpriteBatchNode At This Time
				---- Because We Can Know The Texture To Use Now
				--if not batchNode then
				--	batchNode = 
				setBasicTransformation(image, symbol, batchNode)
			end

			if image and symbol.alphaPercent ~= nil then
				image:setOpacity(symbol.alphaPercent * 2.55) -- * 255 / 100
			end

		elseif symbol.type == kGroupLayoutType.kText then
				local assertFalseMsg = "build batch group not support CCLabel*  yet ! \n"
				assertFalseMsg = assertFalseMsg .. "in group: " .. groupName .. " component: " .. symbol.id
				assert(false, assertFalseMsg)

		elseif symbol.type == kGroupLayoutType.kGroup then

			local layout = self:buildBatchGroup_version2("sprite", symbol.image, imageSuffix, uniqName)
			if layout then
				setBasicTransformation(layout, symbol, batchNode)
			end
		end
	end

	return batchNode
end

function LayoutBuilder:build(groupName, imageSuffix, ...)
	assert(#{...} == 0)

	-- Check Version Number, Then Call The Proper Func
	assert(self.config)
	assert(self.config.version)

	local version = self.config.version

	if version == 1 then
		return self:build_version1(groupName, imageSuffix)
	elseif version == 2 then
		return self:build_version2(groupName, imageSuffix, false)
	else
		assert(false, "Only Layout Jason File Version 1 And 2 Support !")
	end

	return nil
end

function LayoutBuilder:build_version2(groupName, imageSuffix, cascade, uniqName, ...)
	assert(#{...} == 0)

	assert(self.config)
	local group = self.config.groups[groupName].components
	assert(group, "build failed . no group: " .. groupName)
	imageSuffix = imageSuffix or "0000"
	local cascadeEnabled = false
	if cascade ~= nil then cascadeEnabled = cascade end

	---- Not Use Batch Node Has The Hight Priority
	--if not self.config.groups[groupName].useBatch then
	--	useBatch = false
	--end

	-- Check If This Can Batch 
	if self.config.groups[groupName].canBatch and 
		--useBatch then
		self.config.groups[groupName].useBatch then
		return self:buildBatchGroup_version2("batch", groupName, imageSuffix)
	end

	local groupLayer = nil
	if groupName:find("_color_") ~= nil then
		cascadeEnabled = true
		groupLayer = SpriteColorAdjust:createEmpty()
		groupLayer:setCascadeOpacityEnabled(cascadeEnabled)
		groupLayer:setCascadeColorEnabled(cascadeEnabled)
		groupLayer:setAnchorPoint(ccp(0,0))
	else
		groupLayer = Layer:create()
		cascadeEnabled = false
	end	
	groupLayer.name = groupName
 	groupLayer.symbolName = groupName
 	if _G.RegionsCollectEnable then
	 	uniqName = uniqName and (uniqName .. "_" .. groupName) or groupName
	 	groupLayer.uiNodeUniqName = uniqName
	end

	table.sort(group, sortBoneDepthList);

	for k, symbol in ipairs(group) do

		if symbol.type == kGroupLayoutType.kImage then

			local image = nil
			if type(symbol.scalingGrid) == "boolean" and symbol.scalingGrid then
				image = assert(Scale9SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
				image.name = symbol.id
				--image:setPosition(ccp(symbol.x, -symbol.y))
				-- Add ContentScaleFactor Support
				image:setPosition(ccp(symbol.x / self.contentScaleFactor, - symbol.y / self.contentScaleFactor))

				--local contentSize = image:getContentSize()
				--image:setPreferredSize(CCSizeMake(contentSize.width*symbol.scaleX, contentSize.height*symbol.scaleY))
				image:setPreferredSize(CCSizeMake(symbol.width, symbol.height))
				if symbol.rotation ~= nil then
					if symbol.rotation ~= 0 then image:setRotation(symbol.rotation) end
				else
					image:setRotationX(symbol.skewX)
					image:setRotationY(symbol.skewY)
				end
        
				groupLayer:addChild(image)
			else
				image = assert(SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
				setBasicTransformation(image, symbol, groupLayer)
			end

			if symbol.alphaPercent ~= nil then
				image:setOpacity(symbol.alphaPercent * 2.55) -- * 255 / 100
			end
      
			image:setAnchorPoint(ccp(0,1))
			image:setCascadeOpacityEnabled(cascadeEnabled)
			image:setCascadeColorEnabled(cascadeEnabled)
			addDebugBounds(image, groupLayer)
		elseif symbol.type == kGroupLayoutType.kText then

			local builder = self.fontBuilderFunc[symbol.id]
			builder = builder or buildText
			local text = builder(symbol, self)

			if text then
				text:setCascadeOpacityEnabled(cascadeEnabled)
		      	text:setCascadeColorEnabled(cascadeEnabled)
				groupLayer:addChild(text)
				addDebugBounds(text, groupLayer)
			end
		elseif symbol.type == kGroupLayoutType.kGroup then
			local layout = self:build_version2(symbol.image, imageSuffix, cascadeEnabled, uniqName)
			
			if layout then
				setBasicTransformation(layout, symbol, groupLayer)
				addDebugBounds(layout, groupLayer)
			end
		end
	end

  if kDrawDebugRect then
    local boundsLayer = LayerColor:create()
    boundsLayer:setColor(ccc3(128,155,144))
    boundsLayer:changeWidthAndHeight(4,4)
    boundsLayer:setAnchorPoint(ccp(0,0))
    groupLayer:addChild(boundsLayer)
  end

  addDebugBounds(groupLayer, groupLayer)
  
  return groupLayer, group
end

--
-- Note:
-- This Function Extend The self:build Function With Each Child's setCascadeOpacityEnabled Set.
-- This Design Is Not Proper ! Current Only For Saving Time And Keep Compability With Previous Design
--
he_log_warning("redesign LayoutBuilder !")

function LayoutBuilder:buildWithCustomeProperty(groupName, imageSuffix, customPropertyFunc, ...)
	assert(#{...} == 0)

	--if _G.isLocalDevelopMode then printx(0, "build group name: " .. groupName) end


  if not self.config then
    if _G.isLocalDevelopMode then printx(0, "build ui fail. no config:"..groupName) end
    return nil
  end
  local group = self.config.groups[groupName];
  if not group then
    if _G.isLocalDevelopMode then printx(0, "build ui fail. no group:"..groupName) end
    return nil
  end
  
  imageSuffix = imageSuffix or "0000"
  

	local groupLayer = Layer:create()

	if type(customPropertyFunc) == "function" then
		customPropertyFunc(groupLayer)
	end

  groupLayer.name = groupName
  groupLayer.symbolName = groupName

  table.sort(group, sortBoneDepthList);
  for k, symbol in ipairs(group) do
    if symbol.type == kGroupLayoutType.kImage then
      local image = nil
      if type(symbol.scalingGrid) == "boolean" and symbol.scalingGrid then
        image = assert(Scale9SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
        image.name = symbol.id
	image:setPosition(ccp(symbol.x / self.contentScaleFactor, - symbol.y / self.contentScaleFactor))
        image:setPreferredSize(CCSizeMake(symbol.width, symbol.height))
        if symbol.rotation ~= nil then
          if symbol.rotation ~= 0 then image:setRotation(symbol.rotation) end
        else
          image:setRotationX(symbol.skewX)
          image:setRotationY(symbol.skewY)
        end
        
        groupLayer:addChild(image)
      else
        image = assert(SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
        setBasicTransformation(image, symbol, groupLayer)
      end
      	if symbol.alphaPercent ~= nil then
			image:setOpacity(symbol.alphaPercent * 2.55) -- * 255 / 100
		end
      image:setAnchorPoint(ccp(0,1))
      addDebugBounds(image, groupLayer)

      if type(customPropertyFunc) == "function" then
	      customPropertyFunc(image)
      end

    elseif symbol.type == kGroupLayoutType.kText then
      local builder = self.fontBuilderFunc[symbol.id]
      builder = builder or buildText
      local text = builder(symbol, self)
      if text then
      	--text:setCascadeOpacityEnabled(cascadeEnabled)
	--  	text:setCascadeColorEnabled(cascadeEnabled)

	if type(customPropertyFunc) == "function" then
		customPropertyFunc(text)
	end

        groupLayer:addChild(text)
        addDebugBounds(text, groupLayer)
      end
    elseif symbol.type == kGroupLayoutType.kGroup then
      local layout = self:buildWithCustomeProperty(symbol.image, imageSuffix, customPropertyFunc)
      if layout then
        setBasicTransformation(layout, symbol, groupLayer)
        addDebugBounds(layout, groupLayer)
      end
    end
  end

  if kDrawDebugRect then
    local boundsLayer = LayerColor:create()
    boundsLayer:setColor(ccc3(128,155,144))
    boundsLayer:changeWidthAndHeight(4,4)
    boundsLayer:setAnchorPoint(ccp(0,0))
    groupLayer:addChild(boundsLayer)
  end

  addDebugBounds(groupLayer, groupLayer)
  
  return groupLayer, group
end



function LayoutBuilder:build_version1(groupName, imageSuffix, uniqName)

	--if _G.isLocalDevelopMode then printx(0, "build group name: " .. groupName) end


  if not self.config then
    if _G.isLocalDevelopMode then printx(0, "build ui fail. no config:"..groupName) end
    return nil
  end
  local group = self.config.groups[groupName];
  if not group then
    if _G.isLocalDevelopMode then printx(0, "build ui fail. no group:"..groupName) end
    return nil
  end
  
  imageSuffix = imageSuffix or "0000"
  
  --local groupLayer = Layer:create()
  	local groupLayer = nil
	if groupName:find("_color_") ~= nil then
		cascadeEnabled = true
		groupLayer = SpriteColorAdjust:createEmpty()
		groupLayer:setCascadeOpacityEnabled(cascadeEnabled)
		groupLayer:setCascadeColorEnabled(cascadeEnabled)
		groupLayer:setAnchorPoint(ccp(0,0))
	else
		groupLayer = Layer:create()
		cascadeEnabled = false
	end	

  	groupLayer.name = groupName
  	groupLayer.symbolName = groupName
  	if _G.RegionsCollectEnable then
	 	uniqName = uniqName and (uniqName .. "_" .. groupName) or groupName
	 	groupLayer.uiNodeUniqName = uniqName
	end

  table.sort(group, sortBoneDepthList);
  for k, symbol in ipairs(group) do
    if symbol.type == kGroupLayoutType.kImage then
      local image = nil
      if type(symbol.scalingGrid) == "boolean" and symbol.scalingGrid then
        image = assert(Scale9SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
        image.name = symbol.id
        --image:setPosition(ccp(symbol.x, -symbol.y))
	-- Add ContentScaleFactor Support
	image:setPosition(ccp(symbol.x / self.contentScaleFactor, - symbol.y / self.contentScaleFactor))

        --local contentSize = image:getContentSize()
        --image:setPreferredSize(CCSizeMake(contentSize.width*symbol.scaleX, contentSize.height*symbol.scaleY))
        image:setPreferredSize(CCSizeMake(symbol.width, symbol.height))
        if symbol.rotation ~= nil then
          if symbol.rotation ~= 0 then image:setRotation(symbol.rotation) end
        else
          image:setRotationX(symbol.skewX)
          image:setRotationY(symbol.skewY)
        end
        
        groupLayer:addChild(image)
      else
        image = assert(SpriteColorAdjust:createWithSpriteFrameName(symbol.image..imageSuffix))
        setBasicTransformation(image, symbol, groupLayer)
      end
		if symbol.alphaPercent ~= nil then
			image:setOpacity(symbol.alphaPercent * 2.55) -- * 255 / 100
		end
      image:setCascadeOpacityEnabled(cascadeEnabled)
	  image:setCascadeColorEnabled(cascadeEnabled)
      image:setAnchorPoint(ccp(0,1))
      addDebugBounds(image, groupLayer)
    elseif symbol.type == kGroupLayoutType.kText then
      local builder = self.fontBuilderFunc[symbol.id]
      builder = builder or buildText
      local text = builder(symbol, self)
      if text then
      	text:setCascadeOpacityEnabled(cascadeEnabled)
	  	text:setCascadeColorEnabled(cascadeEnabled)

        groupLayer:addChild(text)
        addDebugBounds(text, groupLayer)
      end
    elseif symbol.type == kGroupLayoutType.kGroup then
      local layout = self:build_version1(symbol.image, imageSuffix, uniqName)
      if layout then
        setBasicTransformation(layout, symbol, groupLayer)
        addDebugBounds(layout, groupLayer)
      end
    end
  end

  if kDrawDebugRect then
    local boundsLayer = LayerColor:create()
    boundsLayer:setColor(ccc3(128,155,144))
    boundsLayer:changeWidthAndHeight(4,4)
    boundsLayer:setAnchorPoint(ccp(0,0))
    groupLayer:addChild(boundsLayer)
  end

  addDebugBounds(groupLayer, groupLayer)
  
  return groupLayer, group
end

--
------------------------------------------------------------------------------------ resize

function LayoutBuilder:resize( ui, fixedHeight )
  local winSize = Director:sharedDirector():getWinSize()
  if winSize.width ~= kScreenWidthDefault or winSize.height ~= kScreenHeightDefault then
    local scaleX = winSize.width/kScreenWidthDefault
    local scaleY = winSize.height/kScreenHeightDefault

    local scale = scaleY
    if fixedHeight then scale = scaleX end
    --if _G.isLocalDevelopMode then printx(0, ui, winSize.width, kScreenWidthDefault, winSize.height, kScreenHeightDefault, scale) end
    ui:setScale(scale)
    return scale
  end
  return 1
end

function LayoutBuilder:transform2Top( ui, resize, fixedHeight )
  local winSize = CCDirector:sharedDirector():getWinSize()
  local transformedX = 0
  if resize then
    local scale = LayoutBuilder:resize(ui, fixedHeight)
    transformedX = (winSize.width - kScreenWidthDefault*scale)/2
  end
  local position = ccp(transformedX, winSize.height)
  ui:setPosition(position)
  return position
end

function LayoutBuilder:transform2Center( ui, resize, fixedHeight )
  local winSize = CCDirector:sharedDirector():getWinSize()
  local bounds = ui:getGroupBounds()
  local transformedX = 0
  if resize then
    local scale = LayoutBuilder:resize(ui, fixedHeight)
    transformedX = (winSize.width - kScreenWidthDefault*scale)/2
  end
  local position = ccp(transformedX+(winSize.width - bounds.size.width)/2, winSize.height-(winSize.height - bounds.size.height)/2)
  ui:setPosition(position)
  return position
end

--
------------------------------------------------------------------------------------ font mapping

--mapping font face designed in Flash Pro to the face that game used.
-- for example, the original font face designed in Flash Pro is "Arial", but in game, we want to use "Helvetica" instead, 
-- than we can use this mapping methods.
function LayoutBuilder:addGlobalFontFace(designedFont, mappingTo)
  globalFontMapping[designedFont] = mappingTo
end

function LayoutBuilder:getGlobalFontFace(designFontName, ...)
	assert(#{...} == 0)
	local face = globalFontMapping[designFontName]
	return face
end

function LayoutBuilder:addFontFace(designedFont, mappingTo)
  self.fontMapping[designedFont] = designedFont
end

function LayoutBuilder:getFontFace(designedFont)
  local face = self.fontMapping[designedFont]
  if not face then
    face = globalFontMapping[designedFont]
  end
  return face
end


-- add a build text function for selected item id.
function LayoutBuilder:addFontBuilderFunc(symbolId, func)
  fontBuilderFunc[symbolId] = func
end

function LayoutBuilder:hex2ccc3(color)
  local textColor = tostring(color)
  if #textColor > 6 then
    textColor = string.sub(textColor, 2, 7)
  end
  local integer = tonumber(textColor, 16)
  local ret = HeDisplayUtil:ccc3FromUInt(integer)
  return ret
end


globalFontMap = {}

function addGlobalDynamicFontMap(designedFont, bitMapFontFile, donotassert ,...)
	assert(type(designedFont) == "string")
	assert(type(bitMapFontFile) == "string")
	assert(#{...} == 0)

	if not donotassert then
		assert(not globalFontMap[designedFont])
	end

	globalFontMap[designedFont] = bitMapFontFile
end

function getGlobalDynamicFontMap(designedFont, ...)
	assert(designedFont)
	assert(#{...} == 0)

	local result = globalFontMap[designedFont]
	assert(result, designedFont .. " not found")
	return result
end

function checkGlobalDynamicFontExist(designedFont)
	return globalFontMap[designedFont] or false
end