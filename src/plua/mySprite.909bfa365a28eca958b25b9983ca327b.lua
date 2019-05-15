-------------------------------------------------------------------------
--  Class include: Sprite, SpriteUtil, Scale9Sprite, SpriteColorAdjust
-------------------------------------------------------------------------

require "hecore.display.CocosObject"

local reuseAnimationCtrl = require("hecore.ReuseAnimationCtrl")

--local __kTexturePixelFormat__ = {}


--globalTexture = CCTextureCache:sharedTextureCache():addImage(CCFileUtils:sharedFileUtils():fullPathForFilename("mylua/bg.png"))

--
-- Sprite ---------------------------------------------------------
--
--[[local resmap = {}
local curTextureId = 0--]]
function createCCSprite(resName)
	--[[if resmap[resName] ~= nil then
		return CCSprite:createWithTexture(resmap[resName]) 
	end
	local resName = "mylua/t" .. (curTextureId % 10) .. ".png"
	local tex = CCTextureCache:sharedTextureCache():addImage(CCFileUtils:sharedFileUtils():fullPathForFilename(resName))
	resmap[resName] = tex
	curTextureId = curTextureId + 1--]]
	--return CCSprite:createWithTexture(nil)
	return CCLayer:create()
end

mySprite = class(CocosObject);

function mySprite:toString()
	return string.format("Sprite [%s]", self.name and self.name or "nil");
end

function mySprite:getVisibleChildrenList(dst, excluce)
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
function mySprite:getBlendFunc() 
	return self.refCocosObj_setBlendFunc 
end

function mySprite:setBlendFunc(v) 
	self.refCocosObj_setBlendFunc = v 
end	

--ccColor3B
function mySprite:getColor() 
	return self.refCocosObj_setColor 
end

function mySprite:setColor(v) 
	self.refCocosObj_setColor = v
end

function mySprite:setFlipX(bool, ...)
	assert(#{...} == 0)
	--self.refCocosObj:setFlipX(bool)
end

function mySprite:setFlipY(bFlipY) 
	--self.refCocosObj:setFlipY(bFlipY) 
end

function mySprite:isOpacityModifyRGB() 
	return self.refCocosObj_setOpacityModifyRGB or false 
end

function mySprite:setOpacityModifyRGB(v) 
	self.refCocosObj_setOpacityModifyRGB = v
end


--CCSpriteFrame
function mySprite:isFrameDisplayed(v) 
	--return self.refCocosObj:isFrameDisplayed(v) 
	return true
end

function mySprite:setDisplayFrame(v) 
	self.refCocosObj_setDisplayFrame = v
end
function mySprite:displayFrame() 
	return self.refCocosObj_setDisplayFrame 
end
function mySprite:setUserData(v)
	self.refCocosObj_setUserData = v
end

function mySprite:getTexture(...)
	--assert(#{...} == 0)
	--return self.refCocosObj:getTexture()
	
	return self.refCocosObj_setTexture or globalTexture
end

function mySprite:setTexture(texture, ...)
	--assert(#{...} == 0)
	self.refCocosObj_setTexture = texture
end

--CCRect
function mySprite:setTextureRect(v) 
	self.refCocosObj_setTextureRect = v
end

function mySprite:getTextureRect() 
	return self.refCocosObj_setTextureRect or CCRectMake(0, 0, 0, 0)
end
--CCRect rect, bool rotated, CCSize size
function mySprite:setTextureRect2(rect, rotated, size) 
	--self.refCocosObj:setTextureRect(rect, rotated, size) 
end

function mySprite:play(animate, delay, repeatTimes, onRepeatFinishCallback, removeAfterRepeatFinished)
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
mySpriteColorAdjust = class(mySprite)

function mySpriteColorAdjust:adjustColor( hue, saturation, brightness, contrast )
  --[[self.refCocosObj:adjustHue(hue)
  self.refCocosObj:adjustSaturation(saturation)
  self.refCocosObj:adjustBrightness(brightness)
  self.refCocosObj:adjustContrast(contrast)--]]
end

function mySpriteColorAdjust:applyAdjustColorShader()
--  self.refCocosObj:applyAdjustColorShader()
end
function mySpriteColorAdjust:clearAdjustColorShader()
--  self.refCocosObj:clearAdjustColorShader()
end

function mySpriteColorAdjust:create( fileName )
  --[[if not fileName then 
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
  end--]]
	local retSprite = mySpriteColorAdjust.new(createCCSprite(fileName))
	retSprite.filename = fileName
	return retSprite
end

function mySpriteColorAdjust:createWithSpriteFrameName( frameName )
  --[[local retSprite = SpriteColorAdjust.new(HESpriteColorAdjust:createWithSpriteFrameName(frameName))
  retSprite.frameName = frameName
  return retSprite;--]]
	return mySpriteColorAdjust:create(frameName)
end

function mySpriteColorAdjust:createWithTexture(heTexture)
  --[[local retSprite = SpriteColorAdjust.new(HESpriteColorAdjust:createWithTexture(heTexture))
  return retSprite--]]
	return mySpriteColorAdjust:create(heTexture)
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

function mySprite:createEmpty(...)
	assert(#{...} == 0)

	local luaSprite = mySprite.new(CCSprite:create())
	return luaSprite
end

function mySprite:create(fileName)
		
	
--[[  if not fileName then 
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
  end--]]
	local retSprite = mySprite.new(createCCSprite(fileName))
	retSprite.filename = fileName
	return retSprite

end

function mySprite:isFake()
  --[[if(self.refCocosObj) then
    return self.refCocosObj:isFake()
  end--]]
  return false
end

function mySprite:createWithSpriteFrameName(frameName)
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

    --[[local ccobject = CCSprite:createWithSpriteFrameName(frameName)
    local retSprite = Sprite.new(ccobject)
    retSprite.frameName = frameName
    return retSprite;--]]
	local retSprite = mySprite.new(createCCSprite(fileName))
	retSprite.filename = fileName
	return retSprite
end

--[[
function Sprite:dispose()
    CocosObject.dispose(self, self.__reused)
end
]]

function mySprite:createWithSpriteFrame(frame)
  --return Sprite.new(CCSprite:createWithSpriteFrame(frame));
	return mySprite:create(frame)
end

function mySprite:createWithTexture(texture)
  --return Sprite.new(CCSprite:createWithTexture(texture));
	return mySprite:create(texture)
end

function mySprite:clone(copyParentAndPos)
  local pos = self:getPosition()
  if self.filename ~= nil then
    local retSprite = mySprite:create(self.filename);
    if copyParentAndPos then
      if self:getParent() ~= nil then
        self:getParent():addChild(retSprite);
      end
      retSprite:setPosition(ccp(pos.x, pos.y))
    end
    return retSprite
  end

  if self.frameName ~= nil then
    local retSprite = mySprite:createWithSpriteFrameName(self.frameName)
    if copyParentAndPos then
      if self:getParent() ~= nil then
        self:getParent():addChild(retSprite);
      end
      retSprite:setPosition(ccp(pos.x, pos.y))
    end
    return retSprite
  end

  return mySprite:createEmpty()
end

function mySprite:setCascadeOpacityEnabled(v) 
	--self.refCocosObj:setCascadeOpacityEnabled(v) 
end
function mySprite:setCascadeColorEnabled(v) 
	--self.refCocosObj:setCascadeColorEnabled(v) 
end

--
-- SpriteUtil ---------------------------------------------------------
--

mySpriteUtil = {};

function mySpriteUtil:buildAnimatedSprite(timePerFrame, pattern, begin, length, isReversed)
  --local frames = SpriteUtil:buildFrames(pattern, begin, length, isReversed)
  local sprite = createCCSprite("buildAnimatedSprite")--CCSprite:createWithSpriteFrame(frames[1])
  local animate = mySpriteUtil:buildAnimate(frames, timePerFrame)
  return mySprite.new(sprite), animate
end

--Creates a sprite that it's texture repeated to fill the whole content area.
function mySpriteUtil:buildRepeatedSprite(fileName, repeatRect)
  --[[if not fileName then 
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
  sprite:getTexture():setTexParameters(p)--]]
	local sprite = createCCSprite(fileName)
  return mySprite.new(sprite)
end


function mySpriteUtil:setTexturePixelFormat(fileName, pixelFormat)
  --__kTexturePixelFormat__[fileName] = pixelFormat
end


local loadedPlistSprite = {}
local scaledResource = {}
function mySpriteUtil:addSpriteFramesWithFile(plistFilename, textureFileName)
  local prefix = string.split(plistFilename, ".")[1]
  local realPlistPath = mySpriteUtil:getRealResourceName(plistFilename)
  local realPngPath = mySpriteUtil:getRealResourceName(textureFileName)
  if __use_small_res then  
    scaledResource[plistFilename] = realPlistPath
    scaledResource[textureFileName] = realPngPath
  end

  if loadedPlistSprite[plistFilename] then 
    return realPlistPath, realPngPath 
  end

  local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
  
--[[  local function loadSpriteFrames()
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

  loadSpriteFrames()--]]

  return realPlistPath, realPngPath
end

function mySpriteUtil:addSpriteFrameCacheAsync(plistFilename, textureFileName, completeCallback)
  local prefix = string.split(plistFilename, ".")[1]
  local realPlistPath = mySpriteUtil:getRealResourceName(plistFilename)
  local realPngPath =  mySpriteUtil:getRealResourceName(textureFileName)
  if __use_small_res then  
    scaledResource[plistFilename] = realPlistPath
    scaledResource[textureFileName] = realPngPath
  end

  if loadedPlistSprite[plistFilename] then 
    return realPlistPath, realPngPath 
  end

--[[  local function textureLoaded(tex)
    if _G.isLocalDevelopMode then printx(0, "Async load texture:", textureFileName) end
    if __kTexturePixelFormat__[textureFileName] then
      CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[textureFileName])
      CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(realPlistPath, tex)
      CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    else
      CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(realPlistPath, tex)
    end
    loadedPlistSprite[plistFilename] = true

    if completeCallback and type(completeCallback) == 'function' then
      completeCallback()
    end
  end

  local loader = AsyncTextureLoader:create()
  loader:loadTexture(realPngPath, textureLoaded)--]]
	if completeCallback and type(completeCallback) == 'function' then
		  completeCallback()
		end
  return realPlistPath, realPngPath
end

function mySpriteUtil:removeLoadedPlist( plistFilename )
  if plistFilename and loadedPlistSprite[plistFilename] ~= nil then
    loadedPlistSprite[plistFilename] = nil
  end
end

function mySpriteUtil:getRealResourceName( fileName )
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

function mySpriteUtil:cacheTexture(textureFileName)
  --[[if __kTexturePixelFormat__[textureFileName] then
    CCTexture2D:setDefaultAlphaPixelFormat(__kTexturePixelFormat__[textureFileName])
    CCTextureCache:sharedTextureCache():addImage(textureFileName)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  else
    CCTextureCache:sharedTextureCache():addImage(textureFileName)
  end--]]
end

--Creates multiple frames by pattern.
-- Example:
-- create array of CCSpriteFrame [walk0001.png -> walk0020.png]
-- local frames = SpriteUtil:buildFrames("walk%04d.png", 1, 20)
function mySpriteUtil:buildFrames(pattern, begin, length, isReversed)
  --[[if not pattern then 
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

  return frames--]]
	return {}
end

-- Example:
--  local frames    = SpriteUtil:buildFrames("walk_%02d.png", 1, 20)
--  local animation = SpriteUtil:buildAnimate(frames, 0.5 / 20) -- in 0.5s play 20 frames
function mySpriteUtil:buildAnimate(frames, time)
  --https://github.com/dualface/quick-cocos2d-x/blob/master/framework/client/display.lua#newAnimation
  --[[local count = #frames
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

  return animate--]]
	return CCAnimate:create()
end




--
-- Scale9Sprite ---------------------------------------------------------
--

local kZeroCapInsets = CCRectMake(0,0,0,0)

myScale9Sprite = class(CocosObject);

function myScale9Sprite:toString()
  return string.format("Scale9Sprite [%s]", self.name and self.name or "nil");
end
function myScale9Sprite:getVisibleChildrenList(dst, excluce)
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
function myScale9Sprite:getOriginalSize() 
	--return self.refCocosObj:getOriginalSize() 
	return CCSizeMake(0, 0)
end
--CCSize
function myScale9Sprite:getPreferredSize() 
	return self.refCocosObj_setPreferredSize or  CCSizeMake(0, 0)
end
function myScale9Sprite:setPreferredSize(v) 
	self.refCocosObj_setPreferredSize = v
end
--CCRect
function myScale9Sprite:getCapInsets() 
	return self.refCocosObj_setCapInsets or CCRectMake(0, 0, 0, 0) 
end
function myScale9Sprite:setCapInsets(v) 
	self.refCocosObj_setCapInsets = v
end

function myScale9Sprite:resizableSpriteWithCapInsets(v) 
	--return self.refCocosObj:resizableSpriteWithCapInsets(v) 
	return self.refCocosObj
end
function myScale9Sprite:setSpriteFrame(v) 
	--self.refCocosObj:setSpriteFrame(v) 
end

--
--
-- static create function ---------------------------------------------------------
--

function myScale9Sprite:create(fileName, capInsets)
  --[[capInsets = capInsets or kZeroCapInsets
  local sprite = CCScale9Sprite:create(capInsets, fileName)
    return Scale9Sprite.new(sprite)--]]
	local sprite = createCCSprite(fileName)
	return myScale9Sprite.new(sprite)
end

function myScale9Sprite:createWithSpriteFrame(spriteFrame, capInsets)
  --[[capInsets = capInsets or kZeroCapInsets
    local sprite = CCScale9Sprite:createWithSpriteFrame(spriteFrame, capInsets)
    return Scale9Sprite.new(sprite)--]]
	local sprite = createCCSprite(spriteFrame)
	return myScale9Sprite.new(sprite)
end

function myScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
 --[[ capInsets = capInsets or kZeroCapInsets
    local sprite = CCScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
    return Scale9Sprite.new(sprite)--]]
	
	local sprite = createCCSprite(spriteFrameName)
	return myScale9Sprite.new(sprite)
end


--
-- Scale9SpriteColorAdjust ---------------------------------------------------------
--
myScale9SpriteColorAdjust = class(myScale9Sprite)

function myScale9SpriteColorAdjust:toString()
  return string.format("Scale9SpriteColorAdjust [%s]", self.name and self.name or "nil");
end

function myScale9SpriteColorAdjust:adjustColor( hue, saturation, brightness, contrast )
  --[[self.refCocosObj:adjustHue(hue)
  self.refCocosObj:adjustSaturation(saturation)
  self.refCocosObj:adjustBrightness(brightness)
  self.refCocosObj:adjustContrast(contrast)--]]
end
function myScale9SpriteColorAdjust:applyAdjustColorShader()
--  self.refCocosObj:applyAdjustColorShader()
end
function myScale9SpriteColorAdjust:clearAdjustColorShader()
--  self.refCocosObj:clearAdjustColorShader()
end

--
--
-- static create function ---------------------------------------------------------
--

function myScale9SpriteColorAdjust:createWithSpriteFrameName(spriteFrameName, capInsets)
  --capInsets = capInsets or kZeroCapInsets
    local sprite =  createCCSprite(spriteFrameName) --HEScale9Sprite:createWithSpriteFrameName(spriteFrameName, capInsets)
    return myScale9SpriteColorAdjust.new(sprite)
end

Scale9SpriteColorAdjust = myScale9SpriteColorAdjust
Scale9Sprite = myScale9Sprite
SpriteUtil = mySpriteUtil
Sprite = mySprite
SpriteColorAdjust = mySpriteColorAdjust