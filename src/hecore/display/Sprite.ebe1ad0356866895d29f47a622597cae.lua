-------------------------------------------------------------------------
--  Class include: Sprite, SpriteUtil, Scale9Sprite, SpriteColorAdjust
-------------------------------------------------------------------------

require "hecore.display.CocosObject"

local reuseAnimationCtrl = require("hecore.ReuseAnimationCtrl")

local __kTexturePixelFormat__ = {}



--
-- Sprite ---------------------------------------------------------
--

Sprite = class(CocosObject);

function Sprite:toString()
	return string.format("Sprite [%s]", self.name and self.name or "nil");
end
function Sprite:getVisibleChildrenList(dst, excluce)
  local name = self.name
  local valid = self:isVisible()
  if valid and excluce and #excluce > 0 then
    for i,v in ipairs(excluce) do
      if name and v == name then 
        valid = false
        break
      end
    end
  end
  if valid then 
	  table.insert(dst, self) 
	  for i,v in ipairs(self.list) do
		  v:getVisibleChildrenList(dst, excluce)
	  end
  end
end

--
-- public props ---------------------------------------------------------
--
--ccBlendFunc
function Sprite:getBlendFunc() return self.refCocosObj:getBlendFunc() end
function Sprite:setBlendFunc(v) self.refCocosObj:setBlendFunc(v) end	

--ccColor3B
function Sprite:getColor() return self.refCocosObj:getColor() end
function Sprite:setColor(v) self.refCocosObj:setColor(v) end

function Sprite:setFlipX(bool, ...)
	assert(#{...} == 0)
	self.refCocosObj:setFlipX(bool)
end
function Sprite:setFlipY(bFlipY) self.refCocosObj:setFlipY(bFlipY) end

function Sprite:isOpacityModifyRGB() return self.refCocosObj:isOpacityModifyRGB() end
function Sprite:setOpacityModifyRGB(v) self.refCocosObj:setOpacityModifyRGB(v) end


--CCSpriteFrame
function Sprite:isFrameDisplayed(v) return self.refCocosObj:isFrameDisplayed(v) end
function Sprite:setDisplayFrame(v) self.refCocosObj:setDisplayFrame(v) end
function Sprite:displayFrame() return self.refCocosObj:displayFrame() end
function Sprite:setUserData(v) self.refCocosObj:setUserData(v) end

function Sprite:getTexture(...)
	assert(#{...} == 0)
	return self.refCocosObj:getTexture()
end

function Sprite:setTexture(texture, ...)
	assert(#{...} == 0)
	self.refCocosObj:setTexture(texture)
end

--CCRect
function Sprite:setTextureRect(v) self.refCocosObj:setTextureRect(v) end
function Sprite:getTextureRect() return self.refCocosObj:getTextureRect() end
--CCRect rect, bool rotated, CCSize size
function Sprite:setTextureRect2(rect, rotated, size) self.refCocosObj:setTextureRect(rect, rotated, size) end

function Sprite:play(animate, delay, repeatTimes, onRepeatFinishCallback, removeAfterRepeatFinished)
  local repeatAction = nil
  local context = self
  if type(repeatTimes) == "number" and repeatTimes > 0 then
    local function onRepeatFinished()
      if onRepeatFinishCallback then onRepeatFinishCallback() end
      if removeAfterRepeatFinished then context:removeFromParentAndCleanup(true) end
    end
    repeatAction = CCSequence:createWithTwoActions(CCRepeat:create(animate, repeatTimes), CCCallFunc:create(onRepeatFinished))
  else repeatAction = CCRepeatForever:create(animate) end
  
  if type(delay) == "number" and delay > 0 then
    self:setVisible(false)
    --repeatAction is a C++ object, we need to retain it's reference count.
    repeatAction:retain()
    local function onDelayTimeFinished()
      context:setVisible(true)
      context:stopAllActions()
      context:runAction(repeatAction)
      
      --after the delay time, release the reference count for GC
      repeatAction:release()
    end
    self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(onDelayTimeFinished)))
  else
    self:runAction(repeatAction)
  end
end

--
-- Sprite ---------------------------------------------------------
--
SpriteColorAdjust = class(Sprite)

function SpriteColorAdjust:adjustColor( hue, saturation, brightness, contrast )
  self.refCocosObj:adjustHue(hue)
  self.refCocosObj:adjustSaturation(saturation)
  self.refCocosObj:adjustBrightness(brightness)
  self.refCocosObj:adjustContrast(contrast)
end
function SpriteColorAdjust:applyAdjustColorShader()
  self.refCocosObj:applyAdjustColorShader()
end
function SpriteColorAdjust:clearAdjustColorShader()
  self.refCocosObj:clearAdjustColorShader()
end

function SpriteColorAdjust:create( fileName )
  if not fileName then 
    if _G.isLocalDevelopMode then printx(0, "build sprite fail. no filename") end 
    return
  end
  
  if string.byte(fileName) == 35 then 
    -- start with "#"
    local sprite = HESpriteColorAdjust:createWithSpriteFrameName(string.sub(fileName, 2))
    local retSprite = SpriteColorAdjust.new(sprite)
    retSprite.filename = fileName;
    return retSprite
  else
    local sprite = nil
    if __kTexturePixelFormat__[fileName] then
      CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[fileName])
      sprite = HESpriteColorAdjust:create(fileName)
      CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    else
      sprite = HESpriteColorAdjust:create(fileName)
    end
    local retSprite = SpriteColorAdjust.new(sprite)
    retSprite.filename = fileName;
    return retSprite
  end
end

function SpriteColorAdjust:createWithSpriteFrameName( frameName )
  local retSprite = SpriteColorAdjust.new(HESpriteColorAdjust:createWithSpriteFrameName(frameName))
  retSprite.frameName = frameName
  return retSprite;
end

function SpriteColorAdjust:createWithTexture(heTexture)
  local retSprite = SpriteColorAdjust.new(HESpriteColorAdjust:createWithTexture(heTexture))
  return retSprite
end

--
--
-- static create function ---------------------------------------------------------
--

-- create a sprite with **the** image filename or sprite frame name. sprite frame name have prefix '#'.
--Example:
--  create with an image
--  sprite = SpriteUtil:buildSprite("hello1.png")
--  or with a sprite frame
--  sprite = SpriteUtil:buildSprite("#frame0001")

function Sprite:createEmpty(...)
	assert(#{...} == 0)

	local luaSprite = Sprite.new(CCSprite:create())
	return luaSprite
end

function Sprite:create(fileName)
  if not fileName then 
    if _G.isLocalDevelopMode then printx(0, "build sprite fail. no filename") end 
    return
  end
  
  if string.byte(fileName) == 35 then 
    -- start with "#"
    local sprite = CCSprite:createWithSpriteFrameName(string.sub(fileName, 2))
    local retSprite = Sprite.new(sprite)
    retSprite.filename = fileName;
    return retSprite
  else
    local sprite = nil
    if __kTexturePixelFormat__[fileName] then
      CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[fileName])
      sprite = CCSprite:create(fileName)
      CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    else
      sprite = CCSprite:create(fileName)
    end
    local retSprite = Sprite.new(sprite)
    retSprite.filename = fileName;
    return retSprite
  end
end

function Sprite:isFake()
  if(self.refCocosObj) then
    return self.refCocosObj:isFake()
  end
  return false
end

function Sprite:createWithSpriteFrameName(frameName)
  --[[
    local ccobject = reuseAnimationCtrl:query(frameName, reuseAnimationCtrl.CATEGORY.DISPLAYABLE)
    if(ccobject == nil) then
      ccobject = CCSprite:createWithSpriteFrameName(frameName)
      reuseAnimationCtrl:collectInitialState(ccobject, frameName, reuseAnimationCtrl.CATEGORY.DISPLAYABLE)
    end

    local retSprite = Sprite.new(ccobject)
    retSprite.frameName = frameName
    retSprite.__reused = reuseAnimationCtrl.enabled
    return retSprite;
    ]]

    local ccobject = CCSprite:createWithSpriteFrameName(frameName)
    local retSprite = Sprite.new(ccobject)
    retSprite.frameName = frameName
    return retSprite;
end

--[[
function Sprite:dispose()
    CocosObject.dispose(self, self.__reused)
end
]]

function Sprite:createWithSpriteFrame(frame)
  return Sprite.new(CCSprite:createWithSpriteFrame(frame));
end

function Sprite:createWithTexture(texture)
  return Sprite.new(CCSprite:createWithTexture(texture));
end

function Sprite:createWithTextureRectRotated( texture, rect, rotated )
  return Sprite.new(CCSprite:createWithTexture(texture, rect, rotated))
end

function Sprite:clone(copyParentAndPos)
  local pos = self:getPosition()
  if self.filename ~= nil then
    local retSprite = Sprite:create(self.filename);
    if copyParentAndPos then
      if self:getParent() ~= nil then
        self:getParent():addChild(retSprite);
      end
      retSprite:setPosition(ccp(pos.x, pos.y))
    end
    return retSprite
  end

  if self.frameName ~= nil then
    local retSprite = Sprite:createWithSpriteFrameName(self.frameName)
    if copyParentAndPos then
      if self:getParent() ~= nil then
        self:getParent():addChild(retSprite);
      end
      retSprite:setPosition(ccp(pos.x, pos.y))
    end
    return retSprite
  end

  return Sprite:createEmpty()
end

function Sprite:setCascadeOpacityEnabled(v) self.refCocosObj:setCascadeOpacityEnabled(v) end
function Sprite:setCascadeColorEnabled(v) self.refCocosObj:setCascadeColorEnabled(v) end

--
-- SpriteUtil ---------------------------------------------------------
--

SpriteUtil = {};

function SpriteUtil:buildAnimatedSprite(timePerFrame, pattern, begin, length, isReversed)
  local frames = SpriteUtil:buildFrames(pattern, begin, length, isReversed)
  local sprite = CCSprite:createWithSpriteFrame(frames[1])
  local animate = SpriteUtil:buildAnimate(frames, timePerFrame)
  return Sprite.new(sprite), animate
end

--Creates a sprite that it's texture repeated to fill the whole content area.
function SpriteUtil:buildRepeatedSprite(fileName, repeatRect)
  if not fileName then 
    if _G.isLocalDevelopMode then printx(0, "build repeated sprite fail. no filename") end 
    return
  end
  if not repeatRect then
    local winsize = CCDirector:sharedDirector():getWinSize()
    repeatRect = CCRectMake(0,0,winsize.width, winsize.height)
  end
  local p = ccTexParams()
  p.minFilter = GL_LINEAR -- GL_LINEAR, 0x2601
  p.magFilter = GL_LINEAR
  p.wrapS = GL_REPEAT -- GL_REPEAT, 0x2901
  p.wrapT = GL_LINEAR
  local sprite = CCSprite:create(fileName, repeatRect)
  sprite:getTexture():setTexParameters(p)
  return Sprite.new(sprite)
end

-- mapping texture's CCTexture2DPixelFormat with filename.
-- common use: kTexture2DPixelFormat_RGB565 kTexture2DPixelFormat_RGB888 kTexture2DPixelFormat_RGBA8888 
-- kTexture2DPixelFormat_RGBA4444 kTexture2DPixelFormat_RGB5A1 kCCTexture2DPixelFormat_A8
-- kCCTexture2DPixelFormat_PVRTC4 kCCTexture2DPixelFormat_PVRTC2
function SpriteUtil:setTexturePixelFormat(fileName, pixelFormat)
  __kTexturePixelFormat__[fileName] = pixelFormat
end

--Adds multiple Sprite Frames from a plist file. The texture will be associated with the created sprite frames.
-- if texture contains special pixel format, use setTexturePixelFormat first.
local loadedPlistSprite = {}
local scaledResource = {}
function SpriteUtil:addSpriteFramesWithFile(plistFilename, textureFileName)
  local prefix = string.split(plistFilename, ".")[1]
  local realPlistPath = SpriteUtil:getRealResourceName(plistFilename)
  local realPngPath = SpriteUtil:getRealResourceName(textureFileName)
  if __use_small_res then  
    -- realPlistPath = prefix .. "@2x.plist"
    -- realPngPath = prefix .. "@2x.png"
    scaledResource[plistFilename] = realPlistPath
    scaledResource[textureFileName] = realPngPath
  end

  if loadedPlistSprite[plistFilename] then 
    --[[
    if plistFilename == "ui/panel_add_step.plist" then -- 线上问题排查
      if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("add_step_panel/cell/bg_newDrak0000") then
        if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("panel_add_step_loaded") end
        return realPlistPath, realPngPath
      end
      he_log_error("plist loaded but spriteframe lost:"..plistFilename .. ", cache incorrectly")
    else
      return realPlistPath, realPngPath 
    end
    ]]
    return realPlistPath, realPngPath 
  end

  local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
  
  local function loadSpriteFrames()
    if __kTexturePixelFormat__[textureFileName] then
      CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[textureFileName])
      sharedSpriteFrameCache:addSpriteFramesWithFile(realPlistPath, realPngPath)
      CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
      loadedPlistSprite[plistFilename] = true
    else
      sharedSpriteFrameCache:addSpriteFramesWithFile(realPlistPath, realPngPath)
      loadedPlistSprite[plistFilename] = true
    end
  end

  loadSpriteFrames()

  --[[
  if plistFilename == "ui/panel_add_step.plist" then -- 线上问题排查
    local frameName = "add_step_panel/cell/bg_newDrak0000"
    if nil==CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName) then
      he_log_error("plist loaded but spriteframe lost:"..plistFilename .. ", load incorrectly")

      sharedSpriteFrameCache:removeSpriteFramesFromFile(plistFilename)
      loadedPlistSprite[plistFilename] = nil

      loadSpriteFrames()
      if nil==CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName) then
        he_log_error("plist loaded but spriteframe lost:"..plistFilename .. ", load incorrectly again")

        local tex = HeTexture:create(realPngPath)
        if(tex == nil) then
          he_log_error("plist loaded but spriteframe lost:"..plistFilename .. ", load incorrectly again2")
        end
      end

    end
  end
  --]]

  return realPlistPath, realPngPath
end

function SpriteUtil:addSpriteFrameCacheAsync(plistFilename, textureFileName, completeCallback)
  local prefix = string.split(plistFilename, ".")[1]
  local realPlistPath = SpriteUtil:getRealResourceName(plistFilename)
  local realPngPath =  SpriteUtil:getRealResourceName(textureFileName)
  if __use_small_res then  
    -- realPlistPath = prefix .. "@2x.plist"
    -- realPngPath = prefix .. "@2x.png"
    scaledResource[plistFilename] = realPlistPath
    scaledResource[textureFileName] = realPngPath
  end

  if loadedPlistSprite[plistFilename] then 
    return realPlistPath, realPngPath 
  end

  local function textureLoaded(tex)
    if _G.isLocalDevelopMode then printx(0, "Async load texture:", textureFileName) end
    -- 这个设置pixel format时 texture已经创建 设置是不生效的 需要改cpp 暂时先注释掉
    -- if __kTexturePixelFormat__[textureFileName] then
    --   CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[textureFileName])
    --   CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[textureFileName])
    --   CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(realPlistPath, tex)
    --   CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- else
      CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(realPlistPath, tex)
    -- end
    loadedPlistSprite[plistFilename] = true

    if completeCallback and type(completeCallback) == 'function' then
      completeCallback()
    end
  end

  local loader = AsyncTextureLoader:create()
  loader:loadTexture(realPngPath, textureLoaded)
  return realPlistPath, realPngPath
end

function SpriteUtil:removeLoadedPlist( plistFilename )
  if plistFilename and loadedPlistSprite[plistFilename] ~= nil then
    loadedPlistSprite[plistFilename] = nil
  end
end

function SpriteUtil:getRealResourceName( fileName )
  fileName = ResourceManager:sharedInstance():getMappingFilePath(fileName)
  if __use_small_res then  
    local wordGroup = string.split(fileName, ".")
    local prefix = wordGroup[1]
    local suffix = wordGroup[2]
    local realResourcePath = prefix .. "@2x." .. suffix
    return realResourcePath
  else
    return fileName
  end
end

function SpriteUtil:cacheTexture(textureFileName)
  if __kTexturePixelFormat__[textureFileName] then
    CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[textureFileName])
    CCTextureCache:sharedTextureCache():addImage(textureFileName)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  else
    CCTextureCache:sharedTextureCache():addImage(textureFileName)
  end
end

--Creates multiple frames by pattern.
-- Example:
-- create array of CCSpriteFrame [walk0001.png -> walk0020.png]
-- local frames = SpriteUtil:buildFrames("walk%04d.png", 1, 20)
function SpriteUtil:buildFrames(pattern, begin, length, isReversed)
  if not pattern then 
    if _G.isLocalDevelopMode then printx(0, "build frames fail. no pattern") end 
    return
  end

  local uniqueName = pattern .. begin .. length .. tostring(isReversed)
  local frames = reuseAnimationCtrl:query(uniqueName, reuseAnimationCtrl.CATEGORY.FRAMES)
  if(frames == nil) then
    --https://github.com/dualface/quick-cocos2d-x/blob/master/framework/client/display.lua#newFrames
    local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    frames = {}
    local step = 1
    local last = begin + length - 1
    if isReversed then
      last, begin = begin, last
      step = -1
    end

    for index = begin, last, step do
      local frameName = string.format(pattern, index)
      local frame = sharedSpriteFrameCache:spriteFrameByName(frameName) --CCSpriteFrame* spriteFrameByName(const char *pszName);
      if not frame then if _G.isLocalDevelopMode then printx(0, "invalid frame, name %s", frameName) end end
      frames[#frames + 1] = frame
    end

    reuseAnimationCtrl:initializeInstance(frames, uniqueName, reuseAnimationCtrl.CATEGORY.FRAMES)
    reuseAnimationCtrl:pushback(frames)
  end

  return frames
end

-- Example:
--  local frames    = SpriteUtil:buildFrames("walk_%02d.png", 1, 20)
--  local animation = SpriteUtil:buildAnimate(frames, 0.5 / 20) -- in 0.5s play 20 frames
function SpriteUtil:buildAnimate(frames, time)
  --https://github.com/dualface/quick-cocos2d-x/blob/master/framework/client/display.lua#newAnimation
  local count = #frames
  local array = CCArray:create()
  for i = 1, count do
    array:addObject(frames[i])
  end
  time = time or 1.0 / count

  local adjust = 1
  if CrashResumeGamePlaySpeedUp and GamePlayConfig_replayAdjustValue then
    --adjust = GamePlayConfig_replayAdjustValue
  end
  time = time / adjust

  local animate = CCAnimate:create(CCAnimation:createWithSpriteFrames(array, time))

  return animate
end




--
-- Scale9Sprite ---------------------------------------------------------
--

local kZeroCapInsets = CCRectMake(0,0,0,0)

Scale9Sprite = class(CocosObject);

function Scale9Sprite:toString()
  return string.format("Scale9Sprite [%s]", self.name and self.name or "nil");
end
function Scale9Sprite:getVisibleChildrenList(dst, excluce)
  local name = self.name
  local valid = self:isVisible()
  if valid and excluce and #excluce > 0 then
    for i,v in ipairs(excluce) do
      if name and v == name then 
        valid = false
        break
      end
    end
  end
  if valid then table.insert(dst, self) end
end
--
-- public props ---------------------------------------------------------
--
--CCSize
function Scale9Sprite:getOriginalSize() return self.refCocosObj:getOriginalSize() end
--CCSize
function Scale9Sprite:getPreferredSize() return self.refCocosObj:getPreferredSize() end
function Scale9Sprite:setPreferredSize(v) self.refCocosObj:setPreferredSize(v) end
function Scale9Sprite:setPreferredHeight( h )
  self:setPreferredSize(CCSizeMake(self:getPreferredSize().width, h))
end
function Scale9Sprite:setPreferredWidth( w )
  self:setPreferredSize(CCSizeMake(w, self:getPreferredSize().height))
end

--CCRect
function Scale9Sprite:getCapInsets() return self.refCocosObj:getCapInsets() end
function Scale9Sprite:setCapInsets(v) self.refCocosObj:setCapInsets(v) end

function Scale9Sprite:resizableSpriteWithCapInsets(v) return self.refCocosObj:resizableSpriteWithCapInsets(v) end
function Scale9Sprite:setSpriteFrame(v) self.refCocosObj:setSpriteFrame(v) end

--
--
-- static create function ---------------------------------------------------------
--

function Scale9Sprite:create(fileName, capInsets)
  capInsets = capInsets or kZeroCapInsets
  local sprite = CCScale9Sprite:create(capInsets, fileName)
    return Scale9Sprite.new(sprite)
end

function Scale9Sprite:createWithSpriteFrame(spriteFrame, capInsets)
  capInsets = capInsets or kZeroCapInsets
    local sprite = CCScale9Sprite:createWithSpriteFrame(spriteFrame, capInsets)
    return Scale9Sprite.new(sprite)
end

function Scale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
  capInsets = capInsets or kZeroCapInsets
    local sprite = CCScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
    return Scale9Sprite.new(sprite)
end


--
-- Scale9SpriteColorAdjust ---------------------------------------------------------
--
Scale9SpriteColorAdjust = class(Scale9Sprite);

function Scale9SpriteColorAdjust:toString()
  return string.format("Scale9SpriteColorAdjust [%s]", self.name and self.name or "nil");
end

function Scale9SpriteColorAdjust:adjustColor( hue, saturation, brightness, contrast )
  self.refCocosObj:adjustHue(hue)
  self.refCocosObj:adjustSaturation(saturation)
  self.refCocosObj:adjustBrightness(brightness)
  self.refCocosObj:adjustContrast(contrast)
end
function Scale9SpriteColorAdjust:applyAdjustColorShader()
  self.refCocosObj:applyAdjustColorShader()
end
function Scale9SpriteColorAdjust:clearAdjustColorShader()
  self.refCocosObj:clearAdjustColorShader()
end

--
--
-- static create function ---------------------------------------------------------
--

function Scale9SpriteColorAdjust:createWithSpriteFrameName(spriteFrameName, capInsets)
  capInsets = capInsets or kZeroCapInsets
    local sprite = HEScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
    return Scale9SpriteColorAdjust.new(sprite)
end

if __PURE_LUA__ then
	require "plua.mySprite"
end