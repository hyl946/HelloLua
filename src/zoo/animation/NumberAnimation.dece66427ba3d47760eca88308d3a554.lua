--Reast.Li  QQ176041249

NumberAnimation = {}



--[[

num 数字，仅支持正整数 
font 字体
color 颜色
speed 动画时长，默认1秒
widInterval 水平间隔 
heiInterval 垂直间隔
align 对齐方式  默认center ， 可选left，right
maskHeight 遮罩的高度，默认为一个字符高度
fixEndY  Y轴修正，用于修正不同的字体出现的布局差异（尤其是发光字体）

return 返回一个Layer实例，内含动画，动画在返回的瞬间已经开始播放

]]
function NumberAnimation:createNumberFlipAnimation(num , font , scale , color , speed , widInterval , heiInterval , align , maskHeight , fixEndY , delayPlay)

	if not num or type(num) ~= "number" then return end
	if not font then font = "微软雅黑" end
	if not scale then scale = 1 end
	if not color then color = ccc4(255,255,255,255) end
	if not speed then speed = 1 end
	if not widInterval then widInterval = 10 end
	if not heiInterval then heiInterval = 10 end
	
	if not fixEndY then fixEndY = 0 end
	if not align then align = "center" end
	if not delayPlay then delayPlay = 0 end


	local container = Layer:create()

	local numstr = tostring(num)
	local numlen = string.len(numstr)
	local numList = {}
	for i = 1 , numlen do
		table.insert( numList , string.sub(numstr, i, i) )
	end

	local textContainer = Layer:create()
	textContainer.partList = {}
	local textList = {}

	for i = 1 , #numList do

		local n = tonumber( numList[i] )
		local textAnimationPart = {}

		if n >= 5 then
			-- n = 5  [0,1,2,3,4,5]
			for ia = n - 5 , n do
				table.insert( textAnimationPart , tostring(ia) )
			end
		else
			-- n = 3  [8,9,0,1,2,3]
			local fixCount = math.abs( n - 5 )
			for ia = 10 - fixCount , 9 do
				table.insert( textAnimationPart , tostring(ia) )
			end

			for ia = 0 , n do
				table.insert( textAnimationPart , tostring(ia) )
			end
		end

		table.insert( textList , textAnimationPart )
	end

	local sizeNumText = BitmapText:create( "0" , getGlobalDynamicFontMap(font) , -1, kCCTextAlignmentCenter )
	local size1 = sizeNumText:getGroupBounds().size

	local numTextSize = nil
	for i = 1 , #textList do

		local part = textList[i]
		local partContainer = Layer:create()
		

		for ia = 1 , #part do
			local t = BitmapText:create( part[ia] , getGlobalDynamicFontMap(font) , -1, kCCTextAlignmentCenter)
			t:setAnchorPoint( ccp(0,0) )
			t:setColor(color)
			--t:setPosition(  ccp( size1.width / 2 , ( ( size1.height + heiInterval) * ( ia - 1 ) )   ) )
			t:setPosition(  ccp( 0 , ( ( size1.height + heiInterval) * ( ia - 1 ) )   ) )
			--printx( 1 , "  ============================   partContainer add " , ( size1.height + heiInterval ) * ia )
			partContainer:addChild(t)
			--printx( 1 , "  ============================   partContainer.size.height " , partContainer:getGroupBounds().size.height )
		end

		local size2 = partContainer:getGroupBounds().size
		partContainer:setPosition( ccp( ( size1.width + widInterval ) * ( i - 1 ) , size2.height ) )
		--partContainer:setPosition( ccp( ( size1.width + widInterval ) * ( i - 1 ) , 0 ) )
		textContainer:addChild(partContainer)

		table.insert( textContainer.partList , partContainer )
	end

	local progressMask = LayerColor:create()
	local textContainerWidth = textContainer:getGroupBounds().size.width
	local textContainerHeight = textContainer:getGroupBounds().size.height
	if not maskHeight then maskHeight = size1.height + heiInterval end
	--if not maskHeight then maskHeight = size1.height + 0 end

	progressMask:changeWidthAndHeight( textContainerWidth + 0 , maskHeight + 0)
	local clippingNode = ClippingNode.new(CCClippingNode:create(progressMask.refCocosObj))
	clippingNode:addChild(textContainer)
	--textContainer:setPositionX(10)
	----[[
	for i = 1 , #textContainer.partList do
		local actArr2 = CCArray:create()
		if delayPlay > 0 then
			actArr2:addObject( CCDelayTime:create( delayPlay ) )
		end
		actArr2:addObject( CCDelayTime:create( (speed / 5) * (#textContainer.partList - i) ) )
		local partSize = textContainer.partList[i]:getGroupBounds().size
		--printx( 1 , "  -------------------------   ")
		--printx( 1 , "  partSize.height  = " , partSize.height , "  heiInterval = " , heiInterval , " numTextSize.height = " , numTextSize.height)
		actArr2:addObject( CCEaseSineOut:create( 
			CCMoveTo:create( speed , ccp( textContainer.partList[i]:getPositionX() , (partSize.height * -1) + size1.height + fixEndY ) ) ) )
			--CCMoveTo:create( 1 , ccp( textContainer.partList[i]:getPositionX() , -378 ) ) ) )

		textContainer.partList[i]:runAction( CCSequence:create(actArr2) )
	end
	--]]
	clippingNode:setPositionX( textContainerWidth / -2 )
	container:addChild(clippingNode)

	container:setScale(scale)

	local containerOrigin = container:getGroupBounds().origin

	--[[
	return container , 
	{
		x = (textContainerWidth * scale) / -2 , y = (numTextSize.height * scale) / 2 , 
		width = textContainerWidth * scale , height = numTextSize.height * scale
	}
	]]

	return container , 
	{
		x = containerOrigin.x , y = containerOrigin.y , 
		width = textContainerWidth * scale , height = size1.height * scale
	}
end