require "hecore.display.CocosObject"
require "hecore.display.Layer"
require "hecore.display.Sprite"
require "hecore.display.TextField"

TextUtil = class()

function TextUtil:buildRichText(text, width, fontName, fontSize, fontColor)
	fontName = fontName or "微软雅黑"
	fontSize = fontSize or 30.0
	fontColor = fontColor or ccc3(0, 0, 255)

	local minSize = CCLabelTTF:create("A",fontName,fontSize):getContentSize()
	local lineHeight = minSize.height
	if width < minSize.width then width = minSize.width end

	local cacheWidths = {}
	local cacheLabels = {}
	local function createLabel(text)
		if cacheLabels[text] and cacheLabels[text]:getParent() then 
			 cacheLabels[text] = nil
		end
		if not cacheLabels[text] then 
			cacheLabels[text] = CCLabelTTF:create(text,fontName,fontSize)
		end
		return cacheLabels[text]
	end
	local function measureWidth(text)
		if not cacheWidths[text] then 
			local label = createLabel(text)
			cacheWidths[text] = label:getContentSize().width
		end
		return cacheWidths[text]
	end

	local container = CCNode:create()

	local list = {}
	local stack = {
		{ text=text, color=string.format("%02x%02x%02x", fontColor.r, fontColor.g, fontColor.b) }
	}

	local function handleText(text, color)
		local tmpTxt = text
		while string.len(tmpTxt) > 0 do
			local endPos = string.find(tmpTxt, "\n")
			if endPos then
				if endPos > 1 then
					table.insert(list,{ text=string.sub(tmpTxt, 1, endPos - 1),color=color })
				end
				table.insert(list,{ text="\n",color=color })
				if endPos >= string.len(tmpTxt) then
					tmpTxt = ""
				else
					tmpTxt = string.sub(tmpTxt, endPos + 1)
				end
			else
				table.insert(list,{ text=tmpTxt, color=color })
				tmpTxt = ""
			end
		end
	end

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

			handleText(text1, stack[#stack].color)
			-- table.insert(list,{ text=text1,color=stack[#stack].color })
			table.insert(stack,{ text=text2,color=color })
		else
			local text1 = string.sub(stack[#stack].text,1,s2-1)
			local text2 = string.sub(stack[#stack].text,e2+1,#stack[#stack].text)

			handleText(text1, stack[#stack].color)
			-- table.insert(list,{ text=text1,color=stack[#stack].color})
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

	local function addLabel( label )
		label:setAnchorPoint(ccp(0,0))
		label:setPositionX(posX)
		label:setPositionY(posY)

		container:addChild(label)
		table.insert(labels,label)
	end

	for k,v in pairs(list) do
		if v.text == "\n" then
			posX = 0
			posY = posY - lineHeight
		else
			local t = {}
			for uchar in string.gfind(v.text, "[%z\1-\127\194-\244][\128-\191]*") do
				t[#t + 1] = uchar
			end

			local function sub( s,e )
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
					local str1 = sub(start,_end)

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

					local str2 = sub(start,math.min(#t,_end + 1))
					local w2 = measureWidth(str2)

					if posX + w1 <= width and posX + w2 > width then 
						str = str1
						newLine = true
						break
					end

					if posX + w1 > width then 
						if _end - start < 1 then 
							str = str1
							newLine = true
							break
						end
						_end = _end - math.ceil(len / i) 
						if _end < start then _end = start end
					elseif posX + w2 <= width then 
						_end = _end + math.ceil(len / i)
						if _end > #t then _end = #t end
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
	end

	container:setContentSize(CCSizeMake(width,math.abs(posY) + lineHeight))
	for _,v in pairs(labels) do
		v:setPositionY(v:getPositionY() + math.abs(posY))
	end

	container:setAnchorPoint(ccp(0, 1))
	container:ignoreAnchorPointForPosition(false)

	return CocosObject.new(container)
end

function TextUtil:ensureTextWidth( originStr, fontSize, dimension, moreStr )
	if type(originStr) == "string" then
		moreStr = moreStr or "..."
		if string.len(originStr) > 0 then
			local ret = ""
			local field = TextField:create()
			field:setFontSize(fontSize)
			field:setString(" ")
			local spaceWidth = field:getContentSize().width
			local charTab = {}
			for uchar in string.gfind(originStr, "[%z\1-\127\194-\244][\128-\191]*") do
				charTab[#charTab + 1] = uchar
			end
			for i = 1, #charTab do
				local ipt = {}
				for j = 1, i do table.insert(ipt, charTab[j]) end
				if i < #charTab then table.insert(ipt, moreStr) end
				field:setString(table.concat(ipt).." ")
				if field:getContentSize().width > dimension.width + spaceWidth then
					break
				end
				ret = table.concat(ipt)
			end
			field:dispose()
			return ret
		else
			return ""
		end
	end
	return nil
end


function TextUtil:fixFontSize( originStr, fontSize, dimension )
	while fontSize >= 1 do
		local success = true
		if string.len(originStr) > 0 then
			local ret = ""
			local field = TextField:create()
			field:setFontSize(fontSize)
			field:setString(originStr)
			if field:getContentSize().width > dimension.width then
				success = false
			end
			field:dispose()
		else
			return fontSize
		end

		if success then
			return fontSize
		end

		fontSize = fontSize - 1
	end
	return fontSize
end

function TextUtil:buildTextLink(text, onClick, fontSize, fontColor, widthAdjust)
	local node = CocosObject.new(CCNode:create())

	node.linkText = TextField:create(text, nil, fontSize or 28)
	node.linkText:setAnchorPoint(ccp(0, 0))
	node.linkText:setColor(fontColor)

	node.textShadow = TextField:create(text, nil, fontSize or 28)
	node.textShadow:setAnchorPoint(ccp(0, 0))
	node.textShadow:setPosition(ccp(1, -1))
	node.textShadow:setColor(ccc3(255, 255, 255))

	widthAdjust = tonumber(widthAdjust) or 0
	node.underline = LayerColor:create()
	local linkSize = node.linkText:getContentSize()
	node.underline:changeWidthAndHeight(linkSize.width + widthAdjust, 2)
	node.underline:setColor(fontColor)
	node.underline:setScaleY(1.5)
	node.underline:setPosition(ccp(0 - widthAdjust / 2, -2))
	-- set content size
	node:setContentSize(CCSizeMake(linkSize.width, linkSize.height))

	-- add touch layer
	local touchLayer = LayerColor:createWithColor(ccc3(255, 0, 0))
	touchLayer:setOpacity(0)
	touchLayer:changeWidthAndHeight(linkSize.width + 10, linkSize.height + 16)
	touchLayer:setPosition(ccp(-5, -8))
	touchLayer:setTouchEnabled(true, 0, true)
	touchLayer:addEventListener(DisplayEvents.kTouchTap, function()
		if type(onClick) == "function" then onClick() end
		end)
	node:addChild(touchLayer)

	node:addChild(node.textShadow)
	node:addChild(node.linkText)
	node:addChild(node.underline)

	return node
end

RichTextField = class(Layer);

function RichTextField:ctor()
	Layer.ctor(self)
end

function RichTextField:create( fontName , fontSize , hInterval , vInterval , hAlignment, vAlignment , warpWidth )
	
	if not fontName then fontName = "微软雅黑" end
	if not fontSize then fontSize = 26 end
	if not hInterval then hInterval = 0 end
	if not vInterval then vInterval = 15 end
	if not hAlignment then hAlignment = "bottom" end
	if not vAlignment then vAlignment = "left" end
	if not warpWidth then warpWidth = 0 end

	local text = RichTextField.new()
	text.fontName = fontName
	text.fontSize = fontSize
	text.hInterval = hInterval
	text.vInterval = vInterval
	text.hAlignment = hAlignment
	text.vAlignment = vAlignment
	text.warpWidth = warpWidth

	text:init()

	return text
end

function RichTextField:init()
	Layer.initLayer(self)
	self.partList = {}
	self.rowList = {}
	self.bodyContainer = Layer:create()
	self:addChild(self.bodyContainer)
end

function RichTextField:addBitmapText(text , scale , font , color , hInterval)
	if not text then assert(text) return end

	if not scale then scale = 1 end
	if not font then font = "Bradley Hand ITC" end
	if not color then color = ccc4(255,255,255,255) end
	
	if not hInterval then hInterval = self.hInterval end

	if #self.rowList == 0 then
		local layer = Layer:create() 
		table.insert( self.rowList , layer )
		self.bodyContainer:addChild( layer )
	end

	local container = self.rowList[#self.rowList]

	local bitmapText = BitmapText:create( text , getGlobalDynamicFontMap(font) , -1, kCCTextAlignmentLeft)
	local sourceHeight = bitmapText:getGroupBounds().size.height
	bitmapText:setScale(scale)
	
	if color ~= "origin" then
		bitmapText:setColor(color)
	end
	
	local size1 = container:getGroupBounds().size
	local size2 = bitmapText:getGroupBounds().size
	local size3 = self.bodyContainer:getGroupBounds().size

	if self.warpWidth > 0 then
		if size1.width + size2.width + hInterval > self.warpWidth then

			local newLayer = Layer:create() 
			table.insert( self.rowList , newLayer )
			newLayer:setPositionY( (size3.height + self.vInterval) * -1 )
			self.bodyContainer:addChild( newLayer )
			container = newLayer

			bitmapText:setPositionX( size2.width / 2 )
		else
			bitmapText:setPositionX( size1.width + (size2.width / 2) + hInterval )
		end
	else
		bitmapText:setPositionX( size1.width + (size2.width / 2) + hInterval )
	end
	
	local fixY = 0
	if scale > 1 then 
		fixY = -10 *  (scale - 1)
	end

	if self.hAlignment == "bottom" then
		bitmapText:setPositionY( (size2.height / 2) + fixY )
	elseif self.hAlignment == "top" then
		bitmapText:setPositionY( (size2.height / -2) + fixY )
	elseif self.hAlignment == "center" then
		--do nothing is just center
	end

	container:addChild(bitmapText)
end

function RichTextField:addView(view , hInterval , viewRect)
	if not view then assert(view) return end

	if not hInterval then hInterval = self.hInterval end

	if #self.rowList == 0 then
		local layer = Layer:create() 
		table.insert( self.rowList , layer )
		self.bodyContainer:addChild( layer )
	end

	local container = self.rowList[#self.rowList]

	local size1 = container:getGroupBounds().size
	local size2 = view:getGroupBounds().size
	local origin = view:getGroupBounds().origin
	if viewRect then
		size2 = { width = viewRect.width , height = viewRect.height }
		origin = { x = viewRect.x , y = viewRect.y }
	end
	local size3 = self.bodyContainer:getGroupBounds().size

	local viewContainer = LayerColor:create()
	viewContainer:changeWidthAndHeight( size2.width , size2.height )
	viewContainer:setOpacity(0)
	view:setPositionX( origin.x * -1 )
	view:setPositionY( origin.y * -1 )

	viewContainer:addChild(view)

	if self.warpWidth > 0 then
		if size1.width + size2.width + hInterval > self.warpWidth then

			local newLayer = Layer:create() 
			table.insert( self.rowList , newLayer )
			newLayer:setPositionY( (size3.height + self.vInterval) * -1 )
			self.bodyContainer:addChild( newLayer )
			container = newLayer

			viewContainer:setPositionX( 0 )
		else
			viewContainer:setPositionX( size1.width + hInterval )
		end
	else
		viewContainer:setPositionX( size1.width + hInterval )
	end

	local fixY = 0

	if self.hAlignment == "bottom" then
		viewContainer:setPositionY( fixY )
	elseif self.hAlignment == "top" then
		viewContainer:setPositionY( (size2.height * -1) + fixY )
	elseif self.hAlignment == "center" then
		--do nothing is just center
	end

	--viewContainer:setPositionY( (size2.height / 2) + fixY )
	container:addChild(viewContainer)
end