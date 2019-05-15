QuickTableRender = class(CocosObject)

local minScale = 1 	-- 0.8
local maxScale = 1
function QuickTableRender:create( width, height, data )
	-- bg不能设置visible为false，因为bg是全部显示对象的容器。。。
	local sp = CCSprite:createWithSpriteFrameName("background_new_2017/b_10000")
	local s = QuickTableRender.new(sp)
	s.bg = sp
	s:init(width, height, data)
	return s
end
function QuickTableRender:ctor( )
	-- body
end

function QuickTableRender:init( width, height, data )
	-- body
	self.width = width
	self.height = height
	self.data = data
	self.sbn = SpriteBatchNode:createWithTexture(self.refCocosObj:getTexture())
	self:addChild(self.sbn)
	self:setContentSize(CCSizeMake(self:getContentSize().width, height))
	local contentSize = self:getContentSize()
	
	-- if _G.isLocalDevelopMode then printx(0, "~~isUnlock",self.data.isUnlock,self.data.index) end
	-- @TEST
	-- self:setAlpha( 0.3)

	if self.data.isUnlock then
		if (self.data.index == 1 and self.data.star_amount >= self.data.total_amount) or
		   (self.data.index > 1 and self.data.hideStar_total_amount > 0 and self.data.star_amount >= self.data.total_amount and self.data.hideStar_amount >= self.data.hideStar_total_amount) then
		   self.fg = Sprite:createWithSpriteFrameName("background_new_2017/b_20000")
		   self.fg:setPosition(ccp(contentSize.width/2, contentSize.height/2))
		   self.sbn:addChild(self.fg)
		   self:addFgFullStarAnim()
		else
			self.fg = Sprite:createWithSpriteFrameName("background_new_2017/b_00000")
			self.fg:setPosition(ccp(contentSize.width/2, contentSize.height/2))
		end

		self.sbn:addChild(self.fg)
		self:addStarsArea()
	else
		local lock = Sprite:createWithSpriteFrameName("star_area_lock0000")
		local x = contentSize.width * 0.85
		local y = contentSize.height / 2
		lock:setPosition(ccp(x, y))
		self.sbn:addChild(lock)
	end
	
	self:addLevelArea()


	self:setScale(minScale)
end

local function createFontSprite( key, fontType )
	local str = fontType == 1 and "star_fnt_" or "level_fnt_"
	local sprite = Sprite:createWithSpriteFrameName(str..key.."0000")
	return sprite
end

function QuickTableRender:addStarsArea( ... )
	self.trunkStarShow = self:__createStarShow(true, self.data.star_amount, self.data.total_amount)

	if self.data.index ~= 1 then --隐藏星星显示
		self.hideStarShow = self:__createStarShow(false, self.data.hideStar_amount, self.data.hideStar_total_amount)
	end

	-- if self.data.index == 74 then --test code
	-- local starAmount = 0
	-- local totalAmount = 55
	-- Director.run():runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function()
	-- 	if starAmount > 55 then return end
	-- 	self.trunkStarShow = self:__createStarShow(true, starAmount, totalAmount)
	-- 	self:__createStarShow(false, starAmount, totalAmount)
	-- 	starAmount = starAmount + 1
	-- end))))
	-- end
end

function QuickTableRender:__createStarShow(isTrunkStar, ownStar, totalStar)
	local contentSize = self:getContentSize()
	local star_bg_width = 64
	local x = contentSize.width * 0.76
	local y = contentSize.height/2
	local keyStr = "trunk"
	local starShow
	if not isTrunkStar then 
		keyStr = "hide" 
		x = x + 84
	end

	local useClipNode = false
	if ownStar > 0 and totalStar > 0 then
		local star = Sprite:createWithSpriteFrameName("star_display/" .. keyStr .. "_star0000")
		star:setAnchorPoint(ccp(0, 0))
		local starBg = Sprite:createWithSpriteFrameName("star_display/star_display_star_bg0000")
		starBg:setAnchorPoint(ccp(0.5, 0.5))
		local starMask = Sprite:createWithSpriteFrameName("star_display/star_mask0000")
		starMask:setAnchorPoint(ccp(0, 0))
		local starSize = star:getContentSize()
		local barHeight = 60 * (ownStar / totalStar) + 4.5
		if _G.__use_small_res then
			barHeight = 60 * (ownStar / totalStar)
		end
		if ownStar >= totalStar then barHeight = 80 end
		if isTrunkStar then star:setPositionXY(0, 2) end
		starMask:setScaleY(barHeight / 10)
		local clipNode = ClippingNode.new(CCClippingNode:create(starMask.refCocosObj))
		starMask:dispose()
		clipNode:setAlphaThreshold(0.1)
		clipNode:addChild(star)
		starBg:addChild(clipNode)
		-- starBg:addChild(star)
		starShow = starBg
		useClipNode = true
		-- local testMask = Sprite:createWithSpriteFrameName("star_display/star_mask0000")--测试代码
		-- testMask:setAnchorPoint(ccp(0, 0))
		-- testMask:setScaleY(barHeight / 10)
		-- testMask:setAlpha(0.2)
		-- starBg:addChild(testMask)
	else
		starShow = Sprite:createWithSpriteFrameName("star_display/star_display_star_bg0000")
	end
	starShow:setPosition(ccp(x, y))
	if useClipNode then  self:addChild(starShow)
	else self.sbn:addChild(starShow) end

	local txtX = x
	local txtY = y - 5
	if totalStar > 0 and (isTrunkStar or 
						 (not isTrunkStar and self.data.isBranchOpen)) then-- 
		local keyList = {}
		if math.floor(ownStar / 10) > 0 then
			keyList[#keyList + 1] = math.floor(ownStar / 10)
		end
		keyList[#keyList + 1] = ownStar % 10
		keyList[#keyList + 1] = "to"
		if math.floor(totalStar / 10) > 0 then
			keyList[#keyList + 1] = math.floor(totalStar / 10)
		end
		keyList[#keyList + 1] = totalStar % 10
				
		local numScale = 0.8
		local numWidth = 12
		txtX = txtX - numWidth * numScale * (#keyList / 2)
		
		if ownStar < totalStar then 
			if not isTrunkStar then 
				txtX = txtX + 2
			else
				txtX = txtX + 2
			end
		else
			if not isTrunkStar then txtX = txtX + 3 end
		end

		for k = 1, #keyList do 
			local key = keyList[k]
			local sp = createFontSprite(key, 1)
			sp:setScale(numScale)
			if k > 1 then txtX = txtX + numWidth * numScale end
			sp:setPosition(ccp(txtX + 3, txtY))
			if useClipNode then self:addChild(sp) 
			else self.sbn:addChild(sp) end
		end
	else--未开启的隐藏关
		local lockedShow
		if totalStar <= 0 then
			lockedShow = Sprite:createWithSpriteFrameName("star_display/star_hideArea_nolevel0000")
			lockedShow:setPosition(ccp(txtX + 3, txtY - 1))
		else
			lockedShow = Sprite:createWithSpriteFrameName("star_display/star_hideArea_locked0000")
			lockedShow:setPosition(ccp(txtX + 3, txtY + 3))
		end
		self.sbn:addChild(lockedShow)
	end

	return starShow
end

function QuickTableRender:addLevelArea( ... )
	-- body

	local x = self:getContentSize().width / 4 - 32
	local y = self:getContentSize().height / 2
	local minLevel = (self.data.index - 1) * 15 + 1
	local maxLevel = self.data.index * 15
	local scale = 2/3

	local function addChar(char, space_scale, size_scale, isLast)
		local c = createFontSprite(char, 0)
		c:setPosition(ccp(x, y))
		if isLast then
			c:setPositionX(c:getPositionX() + 15)
		end
		x = x + c:getContentSize().width * space_scale
		c:setScale(size_scale or 1)
		self.sbn:addChild(c)
	end

	local function addNumString(num)
		local minLevelStr = tostring(num)
		for i = 1, string.len(minLevelStr) do
			local char = string.sub(minLevelStr, i, i)
			local space_scale = scale
			local size_scale = 1
			if num >= 1000 then
				space_scale = space_scale * 0.75
				size_scale = 0.9
			end
			addChar(char, space_scale, size_scale)
		end
	end

	addChar('di', scale)
	addNumString(minLevel)
	addChar('to', scale)
	addNumString(maxLevel)
	addChar('guan', scale, 1, true)

	-- 不显示礼盒
	local function isHidden()
		return tonumber(self.data.index) == 5
	end

	local str = "area_icon_"..self.data.index.."0000"
	local icon
	if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str) and (not isHidden()) then
		icon = Sprite:createWithSpriteFrameName(str)
		self.sbn:addChild(icon)
		icon:setScale(0.7)

		local maunalAdjustPosY = {
			-- [66] = 1,
			-- [40] = 2,
			-- [36] = -3,
			-- [34] = -2,
			-- [28] = -4,
			-- [14] = -5,
			-- [4] = -2,
			-- [6] = -4,
			-- [2] = -1,
			-- [1] = -3,
		}

		local addY = maunalAdjustPosY[self.data.index] or 0

		icon:setPosition(ccp(50,y + addY))
	end

	self.icon = icon
end

function QuickTableRender:hideIcon( ... )
	-- body
	if self.icon then
		self.icon:setVisible(false)
	end
end

function QuickTableRender:changeScale( value )

	-- -- body
	-- self:setScale(value)
	-- if self.icon then
	-- 	self.icon:setVisible(true)
	-- end
	-- local alpha = value - minScale
	-- self.fg:setAlpha( maxScale - alpha * 5)
end

function QuickTableRender:addFgFullStarAnim( ... )
	self:runAction(AnimationUtil.getForeverCall(2.5, function()
		self:__addAGroupStar(5, 15, 3, 520, 5)
		self:__addAGroupStar(5, 15, 90, 520, 5)
		self:__addAGroupStar(2, 5, 15, 8, 80)
		self:__addAGroupStar(2, 542, 15, 8, 80)
		self:__addAGroupStar(2, 80, 15, 250, 80)
	end), true)
end

function QuickTableRender:__addAGroupStar(num, startX, startY, rectWidth, rectHeight)
	for i=1, num do
		local star = Sprite:createWithSpriteFrameName("quick_select_level_resources/quick_select_level/fg_star_cell0000")
		star:setScale(0.4 + 0.4 * math.random())
		local function startCallBack( ... )
			if star ~= nil and not star.isDisposed then
	   			star:setVisible(true)
	   		end
		end
		local function endCallBack( ... )
			if star ~= nil and not star.isDisposed then
				star:removeFromParentAndCleanup(true)
			end
		end
		local posX, posY, anim = AnimationUtil.getRectBlinkStarParam(startX, startY, rectWidth, rectHeight, 0.7, 2, 4, startCallBack, endCallBack, 720)
		star:setPositionXY(posX, posY)
	   	self.sbn:addChildAt(star, self.sbn:getChildIndex(self.fg) + 1)
	   	star:setVisible(false)
	   	star:runAction(anim)
	end
end