
myTextField = class(CocosObject);

function myTextField:toString()
	return string.format("TextField [%s]", self.name and self.name or "nil");
end
function myTextField:getVisibleChildrenList(dst, excluce)
	return {}
end


function myTextField:getString() return self.string or "" end
function myTextField:setString(v) self.string = v end	


function myTextField:getColor() return self.refCocosObj:getColor() end
function myTextField:setColor(v) 
  self.refCocosObj:setColor(v) 
end

function myTextField:getHorizontalAlignment() return self.refCocosObj:getHorizontalAlignment() end
function myTextField:setHorizontalAlignment(v) self.refCocosObj:setHorizontalAlignment(v) end

function myTextField:getVerticalAlignment() return self.refCocosObj:getVerticalAlignment() end
function myTextField:setVerticalAlignment(v) self.refCocosObj:setVerticalAlignment(v) end

function myTextField:getDimensions() return self.refCocosObj:getDimensions() end
function myTextField:setDimensions(v) self.refCocosObj:setDimensions(v) end

function myTextField:getFontSize() return self.refCocosObj:getFontSize() end
function myTextField:setFontSize(v) self.refCocosObj:setFontSize(v) end

function myTextField:getFontName() return self.refCocosObj:getFontName() end
function myTextField:setFontName(v) self.refCocosObj:setFontName(v) end


function myTextField:enableShadow(shadowOffset, shadowOpacity, shadowBlur, mustUpdateTexture) 
  
end
function myTextField:disableShadow(mustUpdateTexture) 
  
end

function myTextField:setFontFillColor(tintColor, mustUpdateTexture) 

end

function myTextField:addStroke( strokeColor, strokeSize, opacity, degree )

end

--static creation function
function myTextField:create(str, fontName, fontSize, dimensions, hAlignment, vAlignment)
  local label = CCLabelTTF:create(str, fontName, fontSize, dimensions, hAlignment, vAlignment)
  return TextField.new(label)
end

function myTextField:createCopy(label)
  local copy =  TextField:create()
  return copy
end


function myTextField:createWithUIAdjustment(adjustRect, placeholderLabel, hasRotation)
	return myTextField:create()
end

function myTextField:beginRollText( fromNum, toNum, format )
  
end

function myTextField:endRollText(  )
  
end

function myTextField:setPreferredSize(width, height, ...)
	
end

function myTextField:getPreferredSize(...)
	return CCSizeMake(10, 10)
end

myBitmapText = class(CocosObject);

function myBitmapText:toString()
	return string.format("TextField [%s]", self.name and self.name or "nil");
end
function myBitmapText:getVisibleChildrenList(dst, excluce)
end
--
-- public props ---------------------------------------------------------
--
function myBitmapText:setText( v )
  --self.refCocosObj:setString(v) 
  self.refCocosObj_string = v
end

function myBitmapText:setTextDelay( v )
end

function myBitmapText:getString() 
	--return self.refCocosObj:getString() 
	return self.refCocosObj_string
end

function myBitmapText:setString(v) 
	self.refCocosObj_string = v
end	

function myBitmapText:setAlignment(alignment) 
  self.alignment = alignment
  --self.refCocosObj:setAlignment(alignment) 
end
function myBitmapText:setLineBreakWithoutSpace(breakWithoutSpace) 
	--self.refCocosObj:setLineBreakWithoutSpace(breakWithoutSpace) 
end

function myBitmapText:getFntFile() 
	--return self.refCocosObj:getFntFile() 
	return self.refCocosObj_FntFile
end --string

function myBitmapText:setFntFile(v) 
	--self.refCocosObj:setFntFile(v) 
	self.refCocosObj_FntFile = v
end

--ccColor3B
function myBitmapText:getColor() 
	--return self.refCocosObj:getColor() 
	return self.refCocosObj_color
end

function myBitmapText:setColor(v) 
	--self.refCocosObj:setColor(v) 
	self.refCocosObj_color = v
end

function myBitmapText:getOpacity() 
	--return self.refCocosObj:getOpacity() 
	return self.refCocosObj_opacity or 255
end

function myBitmapText:setOpacity(v) 
	--self.refCocosObj:setOpacity(v) 
	self.refCocosObj_opacity = v
end

function myBitmapText:isOpacityModifyRGB() 
	--return self.refCocosObj:isOpacityModifyRGB() 
	return self.refCocosObj_opacityModifyRGB
end

function myBitmapText:setOpacityModifyRGB(v) 
	self.refCocosObj_opacityModifyRGB = v
end

function myBitmapText:changeFntFile(fntFile)
  self:setFntFile(fntFile)
end

function myBitmapText:setWidth( v )
  --self.refCocosObj:setWidth(v)
end

function myBitmapText:create(str, fntFile, width, alignment, imageOffset)

  return myBitmapText.new(createCCSprite("a"))
end

function myBitmapText:setPreferredSize(width, height, ...)
	self.preferredWidth	= width
	self.preferredHeight	= height
end

function myBitmapText:getPreferredSize(...)
	--assert(#{...} == 0)
	
	local size = CCSizeMake(self.preferredWidth, self.preferredHeight)
	return size
end

------------------------------------------------------------
-- 创建时如果指定了文本的宽度，传入的字符串会被做折行的处理，
-- 导致颜色对不上，因此最好不传入宽度
------------------------------------------------------------
local function parseRichText(text, defaultColor)
  local list = {}

  return list
end 

function myBitmapText:setRichText(text, defaultColor)

end

function myBitmapText:setRichTextWithWidth(text, width, defaultColor, fontScale)

end



myBMFontLabelBatch = class(CocosObject)

function myBMFontLabelBatch:createLabel(str, ...)
	local layer = CocosObject:create()
	layer:addChild(createCCSprite("a"))
	return layer
end

function myBMFontLabelBatch:create(imageFile, fontFile, capacity, ...)

	  
	local newLabelBMFontBatch = myBMFontLabelBatch.new(createCCSprite("a"))
	return newLabelBMFontBatch
end

myLabelBMMonospaceFont = class(myBMFontLabelBatch)
function myLabelBMMonospaceFont:ctor()

end

function myLabelBMMonospaceFont:init(charWidth, charHeight, charInterval, fntFile, imageFile, capacity, ...)
	local layer = CCLayer:create()
	self:setRefCocosObj(layer)
end


function myLabelBMMonospaceFont:charSize(utf8InitialChar, ...)
	
end

function myLabelBMMonospaceFont:setCascadeOpacityEnabled( v )

end
function myLabelBMMonospaceFont:getString()
  return self.string
end

function myLabelBMMonospaceFont:setString(str, ...)

  if type(str) ~= "string" then str = tostring(str) end
  if self.string == str then return end
	self.string = str
end

function myLabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile, ...)
	local newLabelBMMonospaceFont = myLabelBMMonospaceFont.new()
	newLabelBMMonospaceFont:init(charWidth, charHeight, charInterval, fntFile)
	return newLabelBMMonospaceFont
end

function myLabelBMMonospaceFont:copyToCenterLayer()
	local string = self:getString()
	local newLabelBMMonospaceFont = myLabelBMMonospaceFont.new()
	newLabelBMMonospaceFont:setRefCocosObj(createCCSprite("a"))
	newLabelBMMonospaceFont.name = "label"
	if string then newLabelBMMonospaceFont:setString(string) end  
	local layer = CocosObject:create()
	layer:addChild(newLabelBMMonospaceFont)
	return layer
end

function myLabelBMMonospaceFont:setOpacity(alpha)

end

function myLabelBMMonospaceFont:delayFadeIn(time1, time2)
 
end

function myLabelBMMonospaceFont:delayFadeOut(time1, time2)

end

LabelBMMonospaceFont = myLabelBMMonospaceFont

BMFontLabelBatch = myBMFontLabelBatch

BitmapText = myBitmapText

TextField = myTextField
