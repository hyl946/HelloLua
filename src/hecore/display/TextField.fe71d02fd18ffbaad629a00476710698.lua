-------------------------------------------------------------------------
--  Class include: TextField, BitmapText, TextInput
-------------------------------------------------------------------------

require "hecore.display.CocosObject"
require "hecore.display.Layer"

-- TextField -> CCLabelTTF
-- BitmapText -> CCLabelBMFont

kVerticalTextAlignment = {kCCVerticalTextAlignmentTop, kCCVerticalTextAlignmentCenter, kCCVerticalTextAlignmentBottom}
kTextAlignment = {kCCTextAlignmentLeft, kCCTextAlignmentCenter, kCCTextAlignmentRight}



--
-- TextField ---------------------------------------------------------
--

TextField = class(CocosObject);

function TextField:toString()
	return string.format("TextField [%s]", self.name and self.name or "nil");
end
function TextField:getVisibleChildrenList(dst, excluce)
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
function TextField:getString() return self.refCocosObj:getString() end
function TextField:setString(v) self.refCocosObj:setString(v) return self end	
function TextField:setString2( v )
    local labelTxt = v
    labelTxt = TextUtil:ensureTextWidth(labelTxt or '', self:getFontSize(), self:getDimensions())
    self:setString(labelTxt)
end

--ccColor3B
function TextField:getColor() return self.refCocosObj:getColor() end
function TextField:setColor(v) 
  self.refCocosObj:setColor(v) 
  --HeDisplayUtil:setFontFillColor(self.refCocosObj, v)
end

function TextField:getHorizontalAlignment() return self.refCocosObj:getHorizontalAlignment() end
function TextField:setHorizontalAlignment(v) self.refCocosObj:setHorizontalAlignment(v) end

function TextField:getVerticalAlignment() return self.refCocosObj:getVerticalAlignment() end
function TextField:setVerticalAlignment(v) self.refCocosObj:setVerticalAlignment(v) end

function TextField:getDimensions() return self.refCocosObj:getDimensions() end
function TextField:setDimensions(v) self.refCocosObj:setDimensions(v) end

function TextField:getFontSize() return self.refCocosObj:getFontSize() end
function TextField:setFontSize(v) self.refCocosObj:setFontSize(v) end

function TextField:getFontName() return self.refCocosObj:getFontName() end
function TextField:setFontName(v) self.refCocosObj:setFontName(v) end

--CCSize &shadowOffset, float shadowOpacity, float shadowBlur, bool mustUpdateTexture
function TextField:enableShadow(shadowOffset, shadowOpacity, shadowBlur, mustUpdateTexture) 
  if mustUpdateTexture == nil then mustUpdateTexture = true end
  HeDisplayUtil:enableShadow(self.refCocosObj, shadowOffset, shadowOpacity, shadowBlur, mustUpdateTexture) 
end
function TextField:disableShadow(mustUpdateTexture) 
  if mustUpdateTexture == nil then mustUpdateTexture = true end
  HeDisplayUtil:disableShadow(self.refCocosObj, mustUpdateTexture)
end

--ccColor3B &strokeColor, float strokeSize, bool mustUpdateTexture
--[[
function TextField:enableStroke(strokeColor, strokeSize, mustUpdateTexture) 
  if mustUpdateTexture == nil then mustUpdateTexture = true end
  HeDisplayUtil:enableStroke(self.refCocosObj, strokeColor, strokeSize, mustUpdateTexture) 
end
function TextField:disableStroke(mustUpdateTexture) 
  if mustUpdateTexture == nil then mustUpdateTexture = true end
  HeDisplayUtil:disableStroke(self.refCocosObj, mustUpdateTexture)
end
]]
function TextField:setFontFillColor(tintColor, mustUpdateTexture) 
  if mustUpdateTexture == nil then mustUpdateTexture = true end
  HeDisplayUtil:setFontFillColor(self.refCocosObj, tintColor, mustUpdateTexture)
end

function TextField:addStroke( strokeColor, strokeSize, opacity, degree )
  degree = degree or 36
  opacity = opacity or 255
  local stroke = CocosObject.new(HeDisplayUtil:createStroke(self.refCocosObj, strokeSize, strokeColor, opacity, degree))
  local parent = self:getParent()
  if parent then
    local index = parent:getChildIndex(self)
    parent:addChildAt(stroke, index)
    local position = self:getPosition()
    local size = self:getContentSize()
    stroke:setPositionXY(position.x+size.width/2, position.y - size.height/2)
  end
  return stroke
end

--static creation function
function TextField:create(str, fontName, fontSize, dimensions, hAlignment, vAlignment)
  str = str or ""
  fontName = fontName or "Helvetica"
  fontSize = fontSize or 12
  dimensions = dimensions or CCSizeMake(0,0)
  hAlignment = hAlignment or kCCTextAlignmentLeft
  vAlignment = vAlignment or kCCVerticalTextAlignmentTop
  local label = CCLabelTTF:create(str, fontName, fontSize, dimensions, hAlignment, vAlignment)
  return TextField.new(label)
end

function TextField:createCopy(label)
  local copy =  TextField:create(label:getString(), 
                                 label:getFontName(), 
                                 label:getFontSize(), 
                                 label:getDimensions(),
                                 label:getHorizontalAlignment(),
                                 label:getVerticalAlignment())
  copy:setAnchorPoint(ccp(label:getAnchorPoint().x, label:getAnchorPoint().y))
  copy:setPosition(ccp(label:getPosition().x, label:getPosition().y))
  copy:setColor(ccc3(label:getColor().r, label:getColor().g, label:getColor().b))
  copy:setOpacity(label:getOpacity())
  return copy
end

--added interfaces by jet.zhao<<

 TextRollEvents = {
  kRollProcess = "RollProcess",
  kRollFinished = "RollFinished"
}

function TextField:createWithUIAdjustment(adjustRect, placeholderLabel, hasRotation)
	-- assert(#{...} == 0)

	placeholderLabel:removeFromParentAndCleanup(false)

	local uiAdjustData = {}

	-- -------------------------
	-- Get Info From adjustRect
	-- ------------------------
	if adjustRect then

		local adjustRectParent	= adjustRect:getParent()
		local adjustRectSize	= adjustRect:getGroupBounds(adjustRectParent).size
		local adjustRectPos	= adjustRect:getPosition()

		 uiAdjustData.rectSize	= {width = adjustRectSize.width, height = adjustRectSize.height}
		 uiAdjustData.rectPos	= {x = adjustRectPos.x, y = adjustRectPos.y}
     if hasRotation then
       uiAdjustData.rotation = adjustRect:getRotation()
      end
	 end

	--
	-- Get Info From placeholderLabel
	---
	local fntFile 		= placeholderLabel.fntFile
	local hAlignment	= placeholderLabel.hAlignment

	uiAdjustData.hAlignment = hAlignment

	
	--------------------------
	-- Check If It's A Dynamic Label
	-- -----------------------------
	local newLabel	= false

	if fntFile then
		-- It's A Dynamic Label

		newLabel	= BitmapText:create("", fntFile, -1, kCCTextAlignmentLeft)
		newLabel:ignoreAnchorPointForPosition(false)
		newLabel:setAnchorPoint(ccp(0,1))

		placeholderLabel:dispose()

	else
		-- It's A Static Label
		--newLabel	= TextField:create("")
		return placeholderLabel
	end

	newLabel.labelType = "for_ui_adjustment"
	newLabel.uiAdjustData = uiAdjustData

	-----------------------
	-- If Set Rect Visible
	-- ---------------------
	local config = UIConfigManager:sharedInstance():getConfig()
	local showUIAdjustRect	= config.textField_showUIAdjustRect

	if not showUIAdjustRect then
		if adjustRect then
			adjustRect:setVisible(false)
		end
	end
	
	return newLabel
end

function TextField:beginRollText( fromNum, toNum, format )
  format = format or "%d"
  local currentNum
  local function updateText( dt )
    if currentNum >= toNum then
      self:endRollText()
      return
    end
    currentNum = currentNum + 1
    self:setString(string.format(format, currentNum))
    self:dispatchEvent(Event.new(TextRollEvents.kRollProcess, 1, self))
  end
  currentNum = fromNum
  self.updateTextEntry = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateText, 0, false)
end

function TextField:endRollText(  )
  if self.updateTextEntry then
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTextEntry)
    self.updateTextEntry = nil
    self:dispatchEvent(Event.new(TextRollEvents.kRollFinished, nil, self))
  end
end

function TextField:setPreferredSize(width, height, ...)
	assert(type(width) == "number")
	assert(type(height) == "number")
	assert(#{...} == 0)

	self.preferredWidth	= width
	self.preferredHeight	= height
end

function TextField:getPreferredSize(...)
	assert(#{...} == 0)

	local size = CCSizeMake(self.preferredWidth, self.preferredHeight)
	return size
end

function TextField:createStaticRichText(_text, _width, _fontName, _fontSize, _fontColor)
	local width = _width or 9999
	local fontName = _fontName or "Droid Sans Fallback"
	local fontSize = _fontSize or 30
	local fontColor = _fontColor or "000000"

	local cacheWidths = {}
	local cacheLabels = {}
	local function createLabel(text)
		if cacheLabels[text] and cacheLabels[text]:getParent() then 
			 cacheLabels[text] = nil
		end
		if not cacheLabels[text] then 
			cacheLabels[text] = CCLabelTTF:create(text, fontName, fontSize)
		end
		return cacheLabels[text]
	end
	local function measureWidth(text)
		if not cacheWidths[text] then 
			local label = createLabel(text)
			cacheWidths[text] = label:getContentSize().width

			-- if _G.isLocalDevelopMode then printx(0, "measureWidth " .. text) end
		end
		return cacheWidths[text]
	end

	local container = CCNode:create()

	-- text = string.rep("有个事通知你一下，村长表示明天可以出院了。1232132.",1)
	-- text = string.rep("有个事通知[#FFFF00]你一下，村长[#FF0000]表示明天可以出院了。12[/#]32132.[/#]",10)
	-- text = "[#FF0000]" .. text .. "[/#]1232"

	local list = {}
	local stack = {
		{text=_text, color=fontColor}
	}
	while #stack > 0 do 
		local s2,e2 = string.find(stack[#stack].text,"%[/#%]")
		if not s2 then 
			s2 = #stack[#stack].text + 1
			e2 = #stack[#stack].text - 1
		end

		local temp = string.sub(stack[#stack].text,1,s2-1)
		local s1,e1,color = string.find(temp,"%[#([0-9A-Fa-f]-)%]")

		if s1 then 
			local text1 = string.sub(stack[#stack].text,1,s1-1)
			local text2 = string.sub(stack[#stack].text,e1+1,#stack[#stack].text)

			table.insert(list,{ text=text1,color=stack[#stack].color })
			table.insert(stack,{ text=text2,color=color })
		else
			local text1 = string.sub(stack[#stack].text,1,s2-1)
			local text2 = string.sub(stack[#stack].text,e2+1,#stack[#stack].text)

			table.insert(list,{ text=text1,color=stack[#stack].color})
			table.remove(stack,#stack)
			if #stack > 0 then 
				stack[#stack].text = text2
			end
		end

	end
	
	list = table.filter(list,function( v ) return string.len(v.text) > 0 end)

	local posX=0
	local posY=0
	local labels = {}
	local lineHeight = nil

	local function addLabel(label)
		label:setAnchorPoint(ccp(0,0))
		label:setPositionX(posX)
		label:setPositionY(posY)

		container:addChild(label)
		if not lineHeight then 
			lineHeight = label:getContentSize().height
		end
		table.insert(labels, label)
	end

	for k,v in pairs(list) do
		local t = {}
		for uchar in string.gfind(v.text, "[%z\1-\127\194-\244][\128-\191]*") do
			t[#t + 1] = uchar
		end

		local function sub(s,e)
			local t2 = {}
			for i=s,e do
				t2[i-s+1] = t[i]
			end
			return table.concat(t2,"")
		end

		local start = 1
		while start <= #t do
			local str = ""
			local len = #t - start + 1
			local _end = #t
			local i = 2
			local newLine = false
			while true do 
				newLine = false
				local str1 = sub(start,math.min(_end, start + width))
				if str1 == "" then
					str = ""
					_end = start - 1
					newLine = true
					break
				end

				local w1 = measureWidth(str1)
					if _end == #t and posX + w1 <= width then --or str1 == "" 
					str = str1
					break
				end

				local str2 = sub(start,math.min(math.min(#t,_end + 1), start + width))
				local w2 = measureWidth(str2)

				if posX + w1 <= width and posX + w2 > width then 
					str = str1
					newLine = true
					break
				end

				if posX + w1 > width then 
					_end = _end - math.ceil(len / i) 
				elseif posX + w2 <= width then 
					_end = _end + math.ceil(len / i)
				end
				i = i * 2
			end
			start = _end + 1

			if str ~= "" then 
				local label = createLabel(str)--CCLabelTTF:create(str,fontName,fontSize)
				label:setColor(HeDisplayUtil:ccc3FromUInt(tonumber(v.color,16)))
				addLabel(label)

				posX = posX + label:getContentSize().width
			end

			if newLine then 
				posX = 0
				posY = posY - lineHeight
			end
		end
	end
	container:setContentSize(CCSizeMake(width,math.abs(posY) + lineHeight))
	for _,v in pairs(labels) do
		v:setPositionY(v:getPositionY() + math.abs(posY))
	end
	return CocosObject.new(container)
end

--added interfaces by jet.zhao>>


--
-- BitmapText ---------------------------------------------------------
--


BitmapText = class(CocosObject);

function BitmapText:toString()
	return string.format("TextField [%s]", self.name and self.name or "nil");
end
function BitmapText:getVisibleChildrenList(dst, excluce)
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

--[[
BitmapText的实现是个batchNode ，每个字符是一个子sprite。 
当调用setText更改它的内容的时候，假如字符串改短了， 
它的实现会复用 一部分子sprite， 隐藏另一部分子sprite（没有删除）。   
之后 如果调用 getContentSize获取宽度，值是正确的。 
但如果调用getGroupBounds获取宽度，就会不对，因为它还包括了  已经隐藏的子sprite。 
所以当字符串改短之后， 会发现getGroupBounds取得的宽度 还是之前的值。  
]]
--forceUpdate 用于修正这个错误

function BitmapText:setText( v, forceUpdate )
  self.refCocosObj:setString(v)
	if forceUpdate then

		for i = 0, 1024 do
			if self.refCocosObj:getChildByTag(i) then
				self.refCocosObj:removeChildByTag(i)
			end
		end
		-- self.refCocosObj:removeAllChildrenWithCleanup(true)
		self.refCocosObj:setScaleX(self.refCocosObj:getScaleX())
	end
end

function BitmapText:setTextDelay( v )
  self.cacheStr = v

  local function updateStr()
    if self.setTextDelayTimerId then
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry( self.setTextDelayTimerId )
      self.setTextDelayTimerId = nil
    end
    
    if self.cacheStr then
      
      if not self.isDisposed then
        self:setText( self.cacheStr )
      end
      self.cacheStr = nil
      
    end
  end

  if not self.setTextDelayTimerId then
    self.setTextDelayTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( updateStr , 0 , false )
  end
end

function BitmapText:setRectPositionX(newXPos)
	if self.uiAdjustData and self.uiAdjustData.rectPos then
		local rectPos = self.uiAdjustData.rectPos
		rectPos.x = newXPos
	end
end 

function BitmapText:getString() return self.refCocosObj:getString() end
function BitmapText:setString(v, forceUpdate) 

	self:setScale(1)
	-- self.refCocosObj:setString(v) 
	self:setText(v, forceUpdate)

	if self.labelType == "for_ui_adjustment" then

		local selfParent	= self:getParent()

		local rectSize		= self.uiAdjustData.rectSize
		local rectPos		= self.uiAdjustData.rectPos
		local hAlignment	= self.uiAdjustData.hAlignment
    local rotation = self.uiAdjustData.rotation

		if rectSize then
			-- Scale Size
			local selfSize		= self:getContentSize()
			local deltaScaleY	= rectSize.height / selfSize.height
			self:setScale(deltaScaleY)

			-- Alignment
			--local newSize	= self:getGroupBounds(selfParent).size
			local newSize = {} 
			newSize.width 	= selfSize.width * deltaScaleY
			newSize.height	= selfSize.height * deltaScaleY

			if hAlignment == kCCTextAlignmentLeft then
				self:setPosition(ccp(rectPos.x, rectPos.y))

			elseif hAlignment == kCCTextAlignmentRight then
				self:setPosition(ccp(rectPos.x + rectSize.width - newSize.width, rectPos.y))

			elseif hAlignment == kCCTextAlignmentCenter then
				 local deltaWidth 	= rectSize.width - newSize.width
				 local halfDeltaWidth	= deltaWidth / 2
				 self:setPosition(ccp(rectPos.x + halfDeltaWidth, rectPos.y))
			else
				assert(false)
			end
		else
			self:setAlpha(0.5)
		end
    if rotation then
      self:setRotation(rotation)
    end
	else
		-- Adjust The Width And Height To Preferred Size
		assert(self.preferredWidth)
		assert(self.preferredHeight)

		local contentSize = self:getContentSize() 
		local neededScaleY = self.preferredHeight / contentSize.height
		local neededScaleX = self.preferredWidth / contentSize.width

		-- Get The Smallest Scale Need To Apply
		local smallestScale = false
		
		if neededScaleX < neededScaleY then
			smallestScale = neededScaleX
		else
			smallestScale = neededScaleY
		end

		self:setScaleX(smallestScale)
		self:setScaleY(smallestScale)

	  local position = self:getPosition()
	  local offsetX = self.offsetX or 0
	  
	  if self.alignment == kCCTextAlignmentRight then
	    self:setPositionXY(self.preferredWidth - contentSize.width + offsetX, position.y)
	  elseif self.alignment == kCCTextAlignmentCenter then  
	    local anchor = self:getAnchorPoint()
	    local x = (self.preferredWidth - contentSize.width)/2 + offsetX
	    if self.offsetY == nil then self.offsetY = position.y end
	    local y = self.offsetY
	    self:setPositionXY(x + contentSize.width * anchor.x, y - contentSize.height * (1-anchor.y))
	  end
	end
end	

--修复setString函数字符串超过预设宽度，缩小后位置不对的问题
function BitmapText:setStringEx(v) 

	self:setScale(1)
	self.refCocosObj:setString(v) 

	if self.labelType == "for_ui_adjustment" then

		local selfParent	= self:getParent()

		local rectSize		= self.uiAdjustData.rectSize
		local rectPos		= self.uiAdjustData.rectPos
		local hAlignment	= self.uiAdjustData.hAlignment
    local rotation = self.uiAdjustData.rotation

		if rectSize then
			-- Scale Size
			local selfSize		= self:getContentSize()
			local deltaScaleY	= rectSize.height / selfSize.height
			self:setScale(deltaScaleY)

			-- Alignment
			--local newSize	= self:getGroupBounds(selfParent).size
			local newSize = {} 
			newSize.width 	= selfSize.width * deltaScaleY
			newSize.height	= selfSize.height * deltaScaleY

			if hAlignment == kCCTextAlignmentLeft then
				self:setPosition(ccp(rectPos.x, rectPos.y))

			elseif hAlignment == kCCTextAlignmentRight then
				self:setPosition(ccp(rectPos.x + rectSize.width - newSize.width, rectPos.y))

			elseif hAlignment == kCCTextAlignmentCenter then
				 local deltaWidth 	= rectSize.width - newSize.width
				 local halfDeltaWidth	= deltaWidth / 2
				 self:setPosition(ccp(rectPos.x + halfDeltaWidth, rectPos.y))
			else
				assert(false)
			end
		else
			self:setAlpha(0.5)
		end
    if rotation then
      self:setRotation(rotation)
    end
	else
		-- Adjust The Width And Height To Preferred Size
		assert(self.preferredWidth)
		assert(self.preferredHeight)

		local contentSize = self:getContentSize() 
		local neededScaleY = self.preferredHeight / contentSize.height
		local neededScaleX = self.preferredWidth / contentSize.width

		-- Get The Smallest Scale Need To Apply
		local smallestScale = false
		
		if neededScaleX < neededScaleY then
			smallestScale = neededScaleX
		else
			smallestScale = neededScaleY
		end
        smallestScale = 1

		self:setScaleX(smallestScale)
		self:setScaleY(smallestScale)

	  local position = self:getPosition()
	  local offsetX = self.offsetX or 0
	  
	  if self.alignment == kCCTextAlignmentRight then
	    self:setPositionXY(self.preferredWidth - contentSize.width*smallestScale + offsetX, position.y)
	  elseif self.alignment == kCCTextAlignmentCenter then  
	    local anchor = self:getAnchorPoint()
	    local x = (self.preferredWidth - contentSize.width*smallestScale)/2 + offsetX
	    if self.offsetY == nil then self.offsetY = position.y end
	    local y = self.offsetY
	    self:setPositionXY(x + contentSize.width*smallestScale * anchor.x, y - contentSize.height*smallestScale * (1-anchor.y))
	  end
	end
end	

function BitmapText:setAlignment(alignment) 
  self.alignment = alignment
  self.refCocosObj:setAlignment(alignment) 
end
function BitmapText:setLineBreakWithoutSpace(breakWithoutSpace) self.refCocosObj:setLineBreakWithoutSpace(breakWithoutSpace) end

function BitmapText:getFntFile() return self.refCocosObj:getFntFile() end --string
function BitmapText:setFntFile(v) self.refCocosObj:setFntFile(v) end

--ccColor3B
function BitmapText:getColor() return self.refCocosObj:getColor() end
function BitmapText:setColor(v) self.refCocosObj:setColor(v) end

function BitmapText:getOpacity() return self.refCocosObj:getOpacity() end
function BitmapText:setOpacity(v) self.refCocosObj:setOpacity(v) end

function BitmapText:isOpacityModifyRGB() return self.refCocosObj:isOpacityModifyRGB() end
function BitmapText:setOpacityModifyRGB(v) self.refCocosObj:setOpacityModifyRGB(v) end

function BitmapText:changeFntFile(fntFile)
  if not fntFile then 
    if _G.isLocalDevelopMode then printx(0, "create bitmap font fail. nill of fnt file") end
    return nil 
  end
  if ResourceFntPixelFormat[fntFile] ~= nil then
    CCTexture2D:setDefaultAlphaPixelFormat(ResourceFntPixelFormat[fntFile])
  end

  local prefix = string.split(fntFile, ".")[1]
  local realFntFile = ResourceManager:sharedInstance():getMappingFilePath(fntFile)
  if __use_small_res then  
    realFntFile = prefix .. "@2x.fnt"
  end

  self:checkRollbackTex(realFntFile)
  

  self:setFntFile(realFntFile)

  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
end

function BitmapText:setNumWithAnim(num, duration, setter)
	if self.isDisposed then return end
	local startNum = tonumber(self:getString() or 0) or 0
	local endNum = num

	local delta = endNum - startNum
	if math.abs(delta) < 0.01 then
		return
	end

	local function createSetNumAction( num )
        return CCCallFunc:create(function ( ... )
            if self.isDisposed then return end
            if setter then
            	setter(num)
            else
            	self:setText(tostring(num))
            end
        end)
    end

    duration = duration or 2

    if duration <= 0 then
    	duration = 1/60
    end

	local interval = (duration or 2) / math.abs(delta)

	local array = CCArray:create()

	for i = startNum, endNum, delta / math.abs(delta) * (math.max(interval, 1/24.0) / interval) do
		array:addObject(CCDelayTime:create(math.max(interval, 1/24.0)))
		array:addObject(createSetNumAction(math.floor(i)))
	end

	array:addObject(createSetNumAction(endNum))

	local action = CCSequence:create(array)
	action:setTag(20181119)
	self:stopActionByTag(20181119)

	self:runAction(action)
end

function BitmapText:setWidth( v )
  self.refCocosObj:setWidth(v)
end

function BitmapText:checkRollbackTex( realFntFile )
	local realPNG = string.gsub(realFntFile, '.fnt', '.png')
  	if TextureSceneConfig and TextureSceneConfig:isReplaced(realPNG) then
  		TextureSceneConfig:rollbackByKey(realPNG)
  		TextureSceneConfig:setNotReplaced(realPNG)
  	end
end

function BitmapText:create(str, fntFile, width, alignment, imageOffset)
  if not fntFile then 
    if _G.isLocalDevelopMode then printx(0, "create bitmap font fail. nill of fnt file") end
    return nil 
  end

  if ResourceFntPixelFormat[fntFile] ~= nil then
    CCTexture2D:setDefaultAlphaPixelFormat(ResourceFntPixelFormat[fntFile])
  end

  local prefix = string.split(fntFile, ".")[1]
  local realFntFile = ResourceManager:sharedInstance():getMappingFilePath(fntFile)

  self:checkRollbackTex(realFntFile)


  if __use_small_res then  
    realFntFile = prefix .. "@2x.fnt"
  end

  str = str or ""
  width = width or -1
  alignment = alignment or kCCTextAlignmentLeft
  imageOffset = imageOffset or CCPointMake(0,0)
  local label = CCLabelBMFont:create(str, realFntFile, width, alignment, imageOffset)
  label.alignment = alignment

  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  return BitmapText.new(label)
end

function BitmapText:setPreferredSize(width, height, ...)
	assert(type(width) == "number")
	assert(type(height) == "number")
	assert(#{...} == 0)

	self.preferredWidth	= width
	self.preferredHeight	= height
end

function BitmapText:getPreferredSize(...)
	assert(#{...} == 0)
	
	local size = CCSizeMake(self.preferredWidth, self.preferredHeight)
	return size
end

------------------------------------------------------------
-- 创建时如果指定了文本的宽度，传入的字符串会被做折行的处理，
-- 导致颜色对不上，因此最好不传入宽度
------------------------------------------------------------
local function parseRichText(text, defaultColor)
  local list = {}
  local stack = {
    { text=text,color=defaultColor }
  }
  while #stack > 0 do 
    local s2,e2 = string.find(stack[#stack].text,"%[/#%]")
    if not s2 then 
      s2 = #stack[#stack].text + 1
      e2 = #stack[#stack].text - 1
    end

    local temp = string.sub(stack[#stack].text,1,s2-1)
    local s1,e1,color = string.find(temp,"%[#([0-9A-Fa-f]-)%]")

    if s1 then 
      local text1 = string.sub(stack[#stack].text,1,s1-1)
      local text2 = string.sub(stack[#stack].text,e1+1,#stack[#stack].text)

      table.insert(list,{ text=text1,color=stack[#stack].color })
      table.insert(stack,{ text=text2,color=color })
    else
      local text1 = string.sub(stack[#stack].text,1,s2-1)
      local text2 = string.sub(stack[#stack].text,e2+1,#stack[#stack].text)

      table.insert(list,{ text=text1,color=stack[#stack].color})
      table.remove(stack,#stack)
      if #stack > 0 then 
        stack[#stack].text = text2
      end
    end
  end
  
  list = table.filter(list,function(v) return string.len(v.text) > 0 end)
  return list
end 

function BitmapText:setRichText(text, defaultColor)
  local list = parseRichText(text, defaultColor)
  -- 计算每段颜色的开始索引和长度
  local realText = ""
  local charColors = {} 
  local index = 0 -- start by 0
  for k,v in pairs(list) do
    for uchar in string.gfind(v.text, "[%z\1-\127\194-\244][\128-\191]*") do
      if uchar ~= '\n' then
        table.insert(charColors, {index=index, char=uchar, color=v.color})
      end
      index = index + 1
    end
    realText = realText..v.text
  end
  -- 设置文本内容
  if self.preferredWidth and self.preferredHeight then -- 需要适应大小
    self:setString(realText)
  else
    self.refCocosObj:setString(realText)
  end
  -- 替换颜色
  local maxCount = self.refCocosObj:getChildren():count()
  for i, v in ipairs(charColors) do
    local charSprite = self.refCocosObj:getChildByTag(v.index)
    if v.color and charSprite then
      local sprite = tolua.cast(charSprite, "CCSprite")
      if sprite then sprite:setColor(HeDisplayUtil:ccc3FromUInt(tonumber(v.color,16))) end
    end
  end
end

-- since 1.37 临时解决自动换行问题
-- width：一行的中文字符长度限制
function BitmapText:setRichTextWithWidth(text, width, defaultColor, fontScale)
  width = width or 99999
  fontScale = fontScale or 1
  local list = parseRichText(text, defaultColor)
  -- 计算每段颜色的开始索引和长度
  local realText = ""
  local charColors = {} 
  local index = 0 -- start by 0
  local lineWidth = 0
  for k,v in pairs(list) do
    local fixText = ""
    for uchar in string.gfind(v.text, "[%z\1-\127\194-\244][\128-\191]*") do
      if uchar ~= '\n' then
        local charWidth = 1
        if uchar == " " then
          charWidth = 0.25
        elseif tonumber(uchar) then
          charWidth = 0.65
        end
        if lineWidth >= width or (lineWidth + charWidth > width) then
          fixText = fixText.."\n"
          index = index + 1
          lineWidth = 0
        end
        lineWidth = lineWidth + charWidth
        
        table.insert(charColors, {index=index, char=uchar, color=v.color})
      else
        lineWidth = 0
      end
      fixText = fixText..uchar
      index = index + 1
    end
    realText = realText..fixText
  end
  -- 设置文本内容
  if self.preferredWidth and self.preferredHeight then -- 需要适应大小
    self:setString(realText)
  else
    self.refCocosObj:setString(realText)
  end
  -- 替换颜色
  local maxCount = self.refCocosObj:getChildren():count()
  for i, v in ipairs(charColors) do
    local charSprite = self.refCocosObj:getChildByTag(v.index)
    if v.color and charSprite then
      local sprite = tolua.cast(charSprite, "CCSprite")
      if sprite then sprite:setColor(HeDisplayUtil:ccc3FromUInt(tonumber(v.color,16))) end
    end
  end

  if fontScale ~= 1 then
    self:setScale(fontScale)
  end
end

--
-- TextInput ---------------------------------------------------------
--

-- kEditBoxInputMode = { 
--     kEditBoxInputModeAny=0,                        //开启任何文本的输入键盘（含换行）
--     kEditBoxInputModeEmailAddr=1,                  //开启 邮件地址 输入类型键盘
--     kEditBoxInputModeNumeric=2,                    //开启 数字符号 输入类型键盘
--     kEditBoxInputModePhoneNumber=3,                //开启 电话号码 输入类型键盘
--     kEditBoxInputModeUrl=4,                        //开启 URL 输入类型键盘
--     kEditBoxInputModeDecimal=5,                    //开启 数字 输入类型键盘（含小数点）
--     kEditBoxInputModeSingleLine=6                  //开启任何文本的输入键盘（不含换行）
-- }
-- kEditBoxInputFlag = { 
--     kEditBoxInputFlagPassword=0,                   //密码形式
--     kEditBoxInputFlagSensitive=1,                  //敏感数据输入
--     kEditBoxInputFlagInitialCapsWord=2,            //每个单词首字符大写，并有提示
--     kEditBoxInputFlagInitialCapsSentence=3,        //第一句首字符大写，并有提示
--     kEditBoxInputFlagInitialCapsAllCharacters=4    //自动大写
-- }
-- kKeyboardReturnType = {
--     kKeyboardReturnTypeDefault=0,                  //默认类型, "←"
--     kKeyboardReturnTypeDone=1,                     //Done字样, "确定"
--     kKeyboardReturnTypeSend=2,                     //Send字样, "发送"
--     kKeyboardReturnTypeSearch=3,                   //Search字样, "搜索"
--     kKeyboardReturnTypeGo=4,                       //Go字样, "链接"
--     kKeyboardReturnTypeNext=5,
-- }

kTextInputEvents = {
  kBegan = "began", kEnded = "ended", kChanged = "changed", kReturn = "return", kGotFocus = "gotFocus", kLostFocus = "lostFocus",
} 

TextInput = class(CocosObject);

function TextInput:toString()
  return string.format("TextInput [%s]", self.name and self.name or "nil");
end

--
-- public props ---------------------------------------------------------
--
function TextInput:getText() return self.refCocosObj:getText() end
function TextInput:setText(v) self.refCocosObj:setText(v) end

--ccColor3B
function TextInput:setFontColor(v) self.refCocosObj:setFontColor(v) end
function TextInput:setPlaceholderFontColor(v) self.refCocosObj:setPlaceholderFontColor(v) end

function TextInput:getPlaceHolder() return self.refCocosObj:getPlaceHolder() end
function TextInput:setPlaceHolder(v) return self.refCocosObj:setPlaceHolder(v) end


function TextInput:getMaxLength() return self.refCocosObj:getMaxLength() end
function TextInput:setMaxLength(v) self.refCocosObj:setMaxLength(v) end

--EditBoxInputMode
function TextInput:setInputMode(v) self.refCocosObj:setInputMode(v) end
--EditBoxInputFlag
function TextInput:setInputFlag(v) self.refCocosObj:setInputFlag(v) end
--KeyboardReturnType
function TextInput:setReturnType(v) self.refCocosObj:setReturnType(v) end

function TextInput:openKeyBoard()
  -- 回调时调用有可能已经被销毁 
  if self.refCocosObj then
    self.refCocosObj:openKeyBoard() 
  end
end

function TextInput:closeKeyBoard() self.refCocosObj:closeKeyBoard() end

function TextInput:setAnchorPoint(v)
  --setAnchorPoint is not supported. by default, anchor point is set to the center.
end
--
--
-- static create function ---------------------------------------------------------
--
local function getRefCocosObject( wrapper, shouldDispose )
  if _G.isLocalDevelopMode then printx(0, type(wrapper, "wrapper")) end
  local ret = nil
  if type(wrapper) == "userdata" then
    ret = wrapper
  elseif type(wrapper) == "table" and type(wrapper.is) == "function" then
    ret = wrapper.refCocosObj
    if shouldDispose and type(wrapper.dispose) == "function" then 
      if wrapper.parent then wrapper:removeFromParentAndCleanup(true)
      else wrapper:dispose() end
    end
  end
  return ret
end

function TextInput:create(size, pNormal9SpriteBg, pPressed9SpriteBg, pDisabled9SpriteBg, releaseScale9Sprite)
  local shouldDispose = true
  if releaseScale9Sprite ~= nil then shouldDispose = releaseScale9Sprite end

  local pressed9SpriteBg = getRefCocosObject(pPressed9SpriteBg, shouldDispose)
  local disabled9SpriteBg = getRefCocosObject(pDisabled9SpriteBg, shouldDispose)
  local normal9SpriteBg = getRefCocosObject(pNormal9SpriteBg, shouldDispose)

  if not size or not normal9SpriteBg then
    if _G.isLocalDevelopMode then printx(0, "create text input fail. invalid params.") end
  end

  local textInput = nil
  local function editBoxEventHandler( event )
    local evt = Event.new(event, nil, textInput)
    if textInput and textInput:hasEventListenerByName(event) then textInput:dispatchEvent(evt) end
  end

  local text = CCEditBox:create(size, normal9SpriteBg, pressed9SpriteBg, disabled9SpriteBg)
  text:registerScriptEditBoxHandler(editBoxEventHandler)

  textInput = TextInput.new(text)
  return textInput
end

---------------------------------------------------
--              TextInputIm
---------------------------------------------------
-- fix TextInput display error on iOS
---------------------------------------------------
TextInputIm = class(Layer)
function TextInputIm:create(size, pNormal9SpriteBg, pPressed9SpriteBg, pDisabled9SpriteBg, releaseScale9Sprite)
  if not __IOS then
    local textInput = TextInput:create(size, pNormal9SpriteBg, pPressed9SpriteBg, pDisabled9SpriteBg, releaseScale9Sprite)
    return textInput
  else
    local textInput = TextInputIm.new()
    textInput:init(size, pNormal9SpriteBg)
    return textInput
  end
end

function TextInputIm:init(size, pNormal9SpriteBg)
  self:initLayer()
  pNormal9SpriteBg:setPreferredSize(CCSizeMake(size.width, size.height))
  self:addChild(pNormal9SpriteBg)
  local groupBounds = CCLayerColor:create(ccc4(255,255,255,255), size.width, size.height)
  groupBounds:setTag(kHitAreaObjectTag)
  groupBounds:setOpacity(0)
  self.refCocosObj:addChild(groupBounds)
  InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.common_ui)
  local inputBg1 = Scale9Sprite:createWithSpriteFrameName("ui_commons/ui_fontsize_rect0000")
  inputBg1:setOpacity(0)
  local inputBg2 = Scale9Sprite:createWithSpriteFrameName("ui_commons/ui_fontsize_rect0000")
  inputBg2:setOpacity(0)
  self.textInput = TextInput:create(CCSizeMake(size.width - 10, size.height), inputBg1, inputBg2)
  self.textInput:setPositionY(Director:sharedDirector():getWinSize().height * 2)
  self:addChild(self.textInput)
  self.label = TextField:create()
  self.label:setFontSize(size.height * 60 / 100)
  self.label:setDimensions(CCSizeMake(size.width - 10, size.height * 61 / 100))
  self.label:setString("")
  self.label:setColor(ccc3(255, 255, 255))
  self.label:setPositionY(-size.height / 7)
  self.label:setVisible(false)
  self:addChild(self.label)
  self.placeHolder = TextField:create()
  self.placeHolder:setFontSize(size.height * 61 / 100)
  self.placeHolder:setDimensions(CCSizeMake(size.width - 10, size.height * 61 / 100))
  self.placeHolder:setString("")
  self.placeHolder:setColor(ccc3(156, 164, 160))
  self.placeHolder:setPositionY(-size.height / 7)
  self:addChild(self.placeHolder)
  local touchLayer = LayerColor:create()
  touchLayer:setContentSize(CCSizeMake(size.width, size.height))
  touchLayer:setOpacity(0)
  touchLayer:setPositionXY(-size.width / 2, -size.height / 2)
  self:addChild(touchLayer)
  touchLayer:setTouchEnabled(true)
  local function onTap() self:openKeyBoard() end
  touchLayer:addEventListener(DisplayEvents.kTouchTap, onTap)
  local function onEnd() self:cancelKeyboard() end
  self.textInput:addEventListener(kTextInputEvents.kEnded, onEnd)

  for k,v in pairs({
    "dispatchEvent",
    "hasEventListener",
    "hasEventListenerByName",
    "addEventListener",
    "removeEventListener",
    "removeEventListenerByName",
    "removeAllEventListeners",
    "dp", 
    "he", 
    "hn", 
    "ad", 
    "rm", 
    "rma",
  }) do
    self[v] = function ( ... )
      local params = { ... } 
      params[1] = self.textInput
      return self.textInput[v](unpack(params))
    end
  end

  
end

function TextInputIm:getText() return self.textInput:getText() end
function TextInputIm:setText(v)
  if type(v) ~= "string" then return end
  self.textInput:setText(v)
  self.label:setString(v)
  if string.len(v) > 0 then
    self.label:setVisible(true)
    self.placeHolder:setVisible(false)
  else
    self.label:setVisible(false)
    self.placeHolder:setVisible(true)
  end
end

--ccColor3B
function TextInputIm:setFontColor(v)
  self.textInput:setFontColor(v)
  self.label:setColor(v)
end
function TextInputIm:setPlaceholderFontColor(v)
  self.textInput:setPlaceholderFontColor(v)
  self.placeHolder:setColor(v)
end

function TextInputIm:getPlaceHolder() return self.textInput:getPlaceHolder() end
function TextInputIm:setPlaceHolder(v)
  self.textInput:setPlaceHolder(v)
  self.placeHolder:setString(v)
end

function TextInputIm:getMaxLength() return self.textInput:getMaxLength() end
function TextInputIm:setMaxLength(v) self.textInput:setMaxLength(v) end

--EditBoxInputMode
function TextInputIm:setInputMode(v) self.textInput:setInputMode(v) end
--EditBoxInputFlag
function TextInputIm:setInputFlag(v) self.textInput:setInputFlag(v) end
--KeyboardReturnType
function TextInputIm:setReturnType(v) self.textInput:setReturnType(v) end

function TextInputIm:openKeyBoard()
  self.label:setVisible(false)
  self.placeHolder:setVisible(false)
  self.textInput:setPositionX(-13)
  self.textInput:setPositionY(-5)
  self.textInput:openKeyBoard()
end

function TextInputIm:closeKeyBoard()
  self.textInput:closeKeyBoard()
  self:cancelKeyboard()
end

function TextInputIm:cancelKeyboard()
  self.textInput:setPositionY(Director:sharedDirector():getWinSize().height * 2)
  local text = self.textInput:getText()
  if string.len(text) > 0 then
    self.label:setString(text)
    self.label:setVisible(true)
    self.placeHolder:setVisible(false)
  else
    self.label:setVisible(false)
    self.placeHolder:setVisible(true)
  end
end

function TextInputIm:setAnchorPoint(v)
  -- setAnchorPoint is not supported. by default, anchor point is set to the center.
end

---------------------------------------------------
-------------- LabelBMFontBatch
---------------------------------------------------

assert(not BMFontLabelBatch)
BMFontLabelBatch = class(CocosObject)

function BMFontLabelBatch:createLabel(str, ...)
	assert(type(str) == "string")
	assert(#{...} == 0)

	local cppSprite = self.refCocosObj:createLabel(str)
	assert(cppSprite)
	local luaSprite = Sprite.new(cppSprite)
	assert(luaSprite.refCocosObj)

	return luaSprite
end

function BMFontLabelBatch:create(imageFile, fontFile, capacity, ...)
	assert(type(imageFile) == "string")
	assert(type(fontFile) == "string")
	assert(type(capacity) == "number")
	assert(#{...} == 0)

	  local prefix = string.split(fontFile, ".")[1]
	  local imagePrefix = string.split(imageFile, ".")[1]

	  local realFntFile = fontFile
	  local realImageFile = imageFile

	  if __use_small_res then  
	    realFntFile = prefix .. "@2x.fnt"
	    realImageFile = imagePrefix .. "@2x.png"
	  end
	  
	local batch = LabelBMFontBatch:create(realImageFile, realFntFile, capacity)
	assert(batch)

	local newLabelBMFontBatch = BMFontLabelBatch.new(batch)
	return newLabelBMFontBatch
end

---------------------------------------------------
-------------- LabelBMMonospaceFont
---------------------------------------------------

assert(not LabelBMMonospaceFont)
LabelBMMonospaceFont = class(BMFontLabelBatch)
function LabelBMMonospaceFont:ctor()
  self.isInitializedLabel = false
end
function LabelBMMonospaceFont:init(charWidth, charHeight, charInterval, fntFile, imageFile, capacity, ...)
	assert(type(charWidth) == "number")
	assert(type(charHeight) == "number")
	assert(type(charInterval) == "number")
	assert(type(fntFile) == "string")
	assert(#{...} == 0)

	-----------------
	-- Init Base UI
	-- --------------
	--Layer.initLayer(self)
	local prefix = string.split(fntFile, ".")[1]
  local imagePrefix
  if imageFile then
    imagePrefix= string.split(imageFile, ".")[1]
  else
    imagePrefix = prefix
  end

  local realFntFile = fntFile
  local realImageFile = imageFile
  if not realImageFile then
    realImageFile = prefix .. ".png"
  end

  if __use_small_res then  
    realFntFile = prefix .. "@2x.fnt"
    realImageFile = imagePrefix .. "@2x.png"
  end
    
  local batch = LabelBMFontBatch:create(realImageFile, realFntFile, capacity or 20)
  self:setRefCocosObj(batch)

	self:ignoreAnchorPointForPosition(false)

	-----------
	-- Data
	-- ---------
	self.charWidth		= charWidth
	self.charHeight		= charHeight
	self.charInterval	= charInterval
	self.fntFile		= fntFile
  self.imageFile = imageFile
  self.capacity = capacity or 20

	self:setContentSize(CCSizeMake(self.charWidth, self.charHeight))
end


--
-- Return The Char Length Of A UTF-8 String
--
function LabelBMMonospaceFont:charSize(utf8InitialChar, ...)
	assert(utf8InitialChar)
	assert(#{...} == 0)

	-- UTF-8 Reference:
	-- 0xxxxxxx - 1 byte UTF-8 codepoint (ASCII character)
	-- 110yyyxx - First byte of a 2 byte UTF-8 codepoint
	-- 1110yyyy - First byte of a 3 byte UTF-8 codepoint
	-- 11110zzz - First byte of a 4 byte UTF-8 codepoint
	-- 10xxxxxx - Inner byte of a multi-byte UTF-8 codepoint
	
	if not utf8InitialChar then
		return 0
	elseif utf8InitialChar > 240 then
		return 4
	elseif utf8InitialChar > 225 then
		return 3
	elseif utf8InitialChar > 192 then
		return 2
	else
		return 1
	end
end

function LabelBMMonospaceFont:iterateString(str, ...)
	assert(type(str) == "string")
	assert(#{...} == 0)

	local individualUTF8Chars =  {}

	local byteLength = string.len(str)

	--for index = 1, byteLength do
	--	local initialChar = 
	--end

	local byteIndex = 1
	
	while byteIndex <= byteLength do

		local initialByte = string.byte(str, byteIndex)
		local utfCharLength	= self:charSize(initialByte)
		local individualChar	= string.sub(str, byteIndex, byteIndex + utfCharLength - 1)
		table.insert(individualUTF8Chars, individualChar)

		byteIndex = byteIndex + utfCharLength
	end

	return individualUTF8Chars
end

function LabelBMMonospaceFont:setCascadeOpacityEnabled( v )
  self.refCocosObj:setCascadeOpacityEnabled(v)
end
function LabelBMMonospaceFont:getString()
  return self.string
end
function LabelBMMonospaceFont:setString(str, ...)
	assert(#{...} == 0)

  if type(str) ~= "string" then str = tostring(str) end
  if self.string == str then return end
	self.string = str

	-- -----------------
	-- Remove Previous 
	-- ----------------
	--self:removeChildren(true)

	-----------------------------
	-- Create The Individual Char
	-- ------------------------
  if self.charsLabel and #self.charsLabel > 0 then
    for k,v in pairs(self.charsLabel) do
      if v and v.refCocosObj then
        if v:getParent() then v:removeFromParentAndCleanup(true) 
        else v:dispose() end 
      end
    end
  end
	self.charsLabel = {}
  self:removeChildren(true)

	local stringChars = self:iterateString(str)
	--if _G.isLocalDevelopMode then printx(0, "number of chars: " .. #stringChars) end

	--local strLength = string.len(str)
	local strLength = #stringChars

	for index = 1, strLength do

		--local char = string.sub(str, index, index)
		local char = stringChars[index]
		local charLabel = self:createLabel(char)

		local size = charLabel:getContentSize()
		charLabel:setScale(math.min(self.charWidth / size.width, self.charHeight / size.height))
		self.charsLabel[index] = charLabel
	end

	--------------------
	-- Position Each Char
	-- ----------------
	local startX = self.charWidth / 2
	local startY = self.charHeight / 2

	for index = 1, strLength do
		self.charsLabel[index]:setPosition(ccp(startX, startY))
		startX = startX + self.charInterval
		self:addChild(self.charsLabel[index])
	end

	-------------------
	-- Set Self Content Size
	-- ----------------------
	if strLength == 0 then
		self:setContentSize(CCSizeMake(self.charWidth, self.charHeight))
	else
		local contentHeight = self.charHeight
		local contentWidth = (strLength - 1) * self.charInterval + self.charWidth
		self:setContentSize(CCSizeMake(contentWidth, contentHeight))
	end
end

function LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile, ...)
	assert(type(charWidth) == "number")
	assert(type(charHeight) == "number")
	assert(type(charInterval) == "number")
	assert(type(fntFile) == "string")
	assert(#{...} == 0)

	local newLabelBMMonospaceFont = LabelBMMonospaceFont.new()
	newLabelBMMonospaceFont:init(charWidth, charHeight, charInterval, fntFile)
	return newLabelBMMonospaceFont
end

function LabelBMMonospaceFont:copyToCenterLayer()
  local position = self:getPosition()
  local size = self:getContentSize()
  local anchor = self:getAnchorPoint()
  local string = self:getString()
  local newLabelBMMonospaceFont = LabelBMMonospaceFont.new()
  newLabelBMMonospaceFont.name = "label"
  newLabelBMMonospaceFont:init(self.charWidth, self.charHeight, self.charInterval, self.fntFile, self.imageFile, self.capacity)
  if string then newLabelBMMonospaceFont:setString(string) end  
  newLabelBMMonospaceFont:setAnchorPoint(ccp(anchor.x, anchor.y))
  newLabelBMMonospaceFont:setPosition(ccp(-size.width/2, size.height/2))

  local layer = CocosObject:create()
  layer:setPosition(ccp(position.x+size.width/2, position.y-size.height/2))
  layer:addChild(newLabelBMMonospaceFont)
  return layer
end

function LabelBMMonospaceFont:setOpacity(alpha)
  assert(type(alpha) == "number")
  for k, v in ipairs(self.charsLabel) do
    v:setOpacity(alpha)
  end
end

function LabelBMMonospaceFont:delayFadeIn(time1, time2)
  for k, v in ipairs(self.charsLabel) do
    v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(time1), CCFadeIn:create(time2)))
  end
end

function LabelBMMonospaceFont:delayFadeOut(time1, time2)
  for k, v in ipairs(self.charsLabel) do
    v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(time1), CCFadeOut:create(time2)))
  end
end

if __PURE_LUA__ then
	require "plua.myTextField"
end