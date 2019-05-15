QuickTableRender_New = class(CocosObject)

local minScale = 1 	-- 0.8
local maxScale = 1

local function parseTime(str, default)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str, pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

function QuickTableRender_New:create( width, height, data )
	width = 650 
	height = 124 
	-- bg不能设置visible为false，因为bg是全部显示对象的容器。。。
	local sp = CCSprite:createWithSpriteFrameName("StarAchievenmentPanel_New/itemnodemainbg0000")
	local s = QuickTableRender_New.new(sp)
	s.bg = sp
	s:init(width, height, data)
	return s
end
function QuickTableRender_New:ctor( )
	-- body
end

function QuickTableRender_New:init( width, height, data )
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
	self.isLockUI = false
	if self.data.isUnlock then
		if (self.data.index == 1 and self.data.star_amount >= self.data.total_amount) or
		   (self.data.index > 1  and self.data.star_amount >= self.data.total_amount ) then
		   self.fg = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/itemnodemainbg20000")
		   self.fg:setPosition(ccp(contentSize.width/2, contentSize.height/2))
		   self.sbn:addChild(self.fg)
		   self:addFgFullStarAnim()
		   self.isFull =true
		else
			self.fg = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/itemnodemainbg30000")
			self.fg:setPosition(ccp(contentSize.width/2, contentSize.height/2))
		end

		self.sbn:addChild(self.fg)
		self:addStarsArea()
	else
		self.isLockUI = true
		local lock = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/lockicon0000")
		local x = contentSize.width * 0.85
		local y = contentSize.height / 2
		lock:setPosition(ccp(x, y))
		self.sbn:addChild(lock)
		self.lockIcon = lock
		self.lockIconPosX = x
		self.lockIconPosY = y
	end
	
	self:addLevelArea()

	self:setScale(minScale)
end

local function createFontSprite( key, fontType )
	local str = fontType == 1 and "star_fnt_" or "level_fnt_"

	local frameName = str..key.."0000"

	-- if _G.isLocalDevelopMode then printx(100, " frameName = ", frameName ) end

	local sprite = Sprite:createWithSpriteFrameName( frameName )
	return sprite

end

function QuickTableRender_New:addStarsArea( ... )

	-- self.trunkStarShow = self:__createStarShow(true, self.data.star_amount, self.data.total_amount)

	-- if self.data.index ~= 1 then --隐藏星星显示
	-- 	self.hideStarShow = self:__createStarShow(false, self.data.hideStar_amount, self.data.hideStar_total_amount)
	-- end
	local ownStar = self.data.star_amount
	local totalStar = self.data.total_amount

	local progressValue = ownStar / totalStar
	if progressValue >=1 then
		progressValue = 1 
	end

	-- if _G.isLocalDevelopMode then printx(100, " self.data = ",  table.tostring( self.data ) ) end

	-- if _G.isLocalDevelopMode then printx(100, " ownStar = ",  ownStar ) end
	-- if _G.isLocalDevelopMode then printx(100, " totalStar = ",  totalStar ) end
	-- if _G.isLocalDevelopMode then printx(100, " progressValue = ",  progressValue ) end
	
	local bgWidh1 = 327
	local bgWidh2 = 319

	local bgHight1 = 32
	local bgHight2 = 25

	if self.isFull then
		self.progressbg = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/progressbgfull0000")
	--	self.progressbg = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/progressbg0000")
	else
		self.progressbg = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/progressbg0000")
	end

	self:addChild( self.progressbg )
	self.progressbg:setAnchorPoint(ccp(0,0))
	self.progressbg:setPositionXY( 180, 28 )

	self.progressbar = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/progressbar0000")
	self:addChild( self.progressbar )
	self.progressbar:setAnchorPoint(ccp(0,0))
	self.progressbar:setPositionXY( (bgWidh1-bgWidh2)/2+180 ,(bgHight1-bgHight2)/2+28.5 )

	self.progressbar:setScaleX( progressValue )

	self.starticon = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/starticon0000")
	self:addChild( self.starticon )
	self.starticon:setAnchorPoint(ccp(0,0))
	self.starticon:setPositionXY( 160, 20 )
	
	-- if _G.isLocalDevelopMode then printx(100, " keyList = ", table.tostring( keyList ) ) end

	local starString =  ownStar.."/"..totalStar

	local text = BitmapText:create( starString , "fnt/hud.fnt")
    text:setPreferredSize(200, 50)
    text:setAnchorPoint(ccp(0.5,0))
    text:setPositionXY(330, 23 )
    text:setScale(1.25)
    self:addChild( text )


end

function QuickTableRender_New:__createStarShow(isTrunkStar, ownStar, totalStar)
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

function QuickTableRender_New:stopCountDown()
	if self.oneSecondTimer then 
		self.oneSecondTimer:stop()
		self.oneSecondTimer = nil
	end

end

function QuickTableRender_New:updateLockIconPos(  )
	if self.lockIcon and not self.lockIcon.isDisposed then
		self.lockIcon:setScale(0.6)
		self.lockIcon:setPositionXY( self.lockIconPosX -30 , self.lockIconPosY + 30  )
	end
end

function QuickTableRender_New:createStringForLastNode_2( textString ,scaleValue)
	
	self:updateLockIconPos()
	if not scaleValue then
		scaleValue = 1.0
	end
	if self.timeStr == textString then
		-- if _G.isLocalDevelopMode then printx(100, "createStringForLastNode_2 self.timeStr == textString return " ) end
		return
	end
	if not self.labelTable then
		self.labelTable = {}
	end
	for i=1,#self.labelTable do
		local labelNode = self.labelTable[i]
		labelNode:removeFromParentAndCleanup(true)
	end

    local textTable = {}
	textTable[1] = BitmapText:create( textString , "fnt/register2.fnt")

	local _color = hex2ccc3('406CCD')
	local posX = 650/2
	local posY = 40

	local totalWidth = 0

	for i=1,#textTable do
		local textNode = textTable[i]
		textNode:setScale( scaleValue )
		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
	end

	local leftPosX = posX - totalWidth/2 

	for i=1,#textTable do
		local textNode = textTable[i]
		local leftNode = textTable[i-1]
		textNode:setAnchorPoint(ccp(0.5,0.5))
		
		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
		if leftNode then
			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
		end
		textNode:setPositionXY( myPosX , posY )
		self:addChild( textNode )
		table.insert( self.labelTable , textNode )
		textNode:setColor(_color)
	end
	self.timeStr = timeStr

--	create7BitmapText( unlockTimeData.month , unlockTimeData.day , unlockTimeData.hour ,650/2 , y ,self ,hex2ccc3('406CCD') )
end

function QuickTableRender_New:createStringForLastNode_1( endTime )
	
	self:updateLockIconPos()
	local now = Localhost:timeInSec()
	local deltaInSec = endTime - now

	local d = math.floor(deltaInSec / (3600 * 24))
	local h = math.floor(deltaInSec % (3600 * 24) / 3600)
	local m = math.floor(deltaInSec % (3600 * 24) % 3600 / 60)
	local s = math.floor(deltaInSec % (3600 * 24) % 3600 % 60)

	local isOver = deltaInSec <= 0
	local timeStr 
	if d > 0 then 
		timeStr = localize(string.format("%d天%d小时", d, h))
	else
		timeStr = localize(string.format("%02d:%02d:%02d", h, m, s))
	end
	timeStr = "倒计时 " .. timeStr

	if self.timeStr == timeStr then
		-- if _G.isLocalDevelopMode then printx(100, "createStringForLastNode_1 self.timeStr == timeStr return " ) end
		return
	end
	if not self.labelTable then
		self.labelTable = {}
	end
	for i=1,#self.labelTable do
		local labelNode = self.labelTable[i]
		labelNode:removeFromParentAndCleanup(true)
	end

    local textTable = {}
	textTable[1] = BitmapText:create(  "倒计时 (" , "fnt/register2.fnt")

	if d > 0 then 
		textTable[2] = BitmapText:create(  d.."" , "fnt/hud.fnt")
		textTable[3] = BitmapText:create(  "天" , "fnt/register2.fnt")
		textTable[4] = BitmapText:create(  h.."" , "fnt/hud.fnt")
		textTable[5] = BitmapText:create(  "小时" , "fnt/register2.fnt")
		textTable[2]:setScale(1.2)
		textTable[4]:setScale(1.2)
	else
		local hString = h<10 and "0"..h or h
		local mString = m<10 and "0"..m or m
		local sString = s<10 and "0"..s or s
		textTable[2] = BitmapText:create(  hString.."" , "fnt/hud.fnt")
		textTable[3] = BitmapText:create(  ":" , "fnt/register2.fnt")
		textTable[4] = BitmapText:create(  mString.."" , "fnt/hud.fnt")
		textTable[5] = BitmapText:create(  ":" , "fnt/register2.fnt")
		textTable[6] = BitmapText:create(  sString.."" , "fnt/hud.fnt")
		textTable[2]:setScale(1.2)
		textTable[4]:setScale(1.2)
		textTable[6]:setScale(1.2)
	end

	local _color = hex2ccc3('406CCD')
	local posX = 650/2
	local posY = 40

	local totalWidth = 0

	for i=1,#textTable do
		local textNode = textTable[i]
		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
	end

	local leftPosX = posX - totalWidth/2 

	for i=1,#textTable do
		local textNode = textTable[i]
		local leftNode = textTable[i-1]
		textNode:setAnchorPoint(ccp(0.5,0.5))
		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
		if leftNode then
			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
		end
		textNode:setPositionXY( myPosX , posY )
		self:addChild( textNode )
		table.insert( self.labelTable , textNode )
		textNode:setColor(_color)
	end
	self.timeStr = timeStr
--	create7BitmapText( unlockTimeData.month , unlockTimeData.day , unlockTimeData.hour ,650/2 , y ,self ,hex2ccc3('406CCD') )
end

function QuickTableRender_New:initCountdown( endTime )
	-- isByUpdate 标记 这个方法是不是从自己的倒计时进来的
	local function onTick( isByUpdate )
		if self.isDisposed then return end
	    local timeStr, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
	    local labelString = Localization:getInstance():getText("unlock.cloud.new.area.lock")
	    if isOver then 
	    	self:stopCountDown(  )
	    	self:showNewLevelOnTimeText( isByUpdate )
	    else
	    	labelString = "倒计时 "..timeStr
	    	self:createStringForLastNode_1( endTime )
	    end
	end

	-- if _G.isLocalDevelopMode then printx(100, " labelString = ", labelString ) end
	if not self.doNotOnTick then
		self.oneSecondTimer = OneSecondTimer:create()
	    self.oneSecondTimer:setOneSecondCallback(function ()
	        onTick( true )
	    end)
	    self.oneSecondTimer:start()
	    onTick( false )
	end
	
end
function QuickTableRender_New:showNewLevelOnTimeText( isByUpdate )
	if not isByUpdate then
		isByUpdate = false
	end

	if NewVersionUtil:hasDynamicUpdate() then 
		self:createStringForLastNode_2(localize("发现新版本！请联网重新登录游戏进行更新！"),0.8)
	elseif NewVersionUtil:hasPackageUpdate() then 
		self:createStringForLastNode_2(localize("发现新版本！请到应用商店或在游戏内更新！"),0.8)
	elseif not NewAreaOpenMgr.getInstance():checkNextCountdownAreaVersionAvailable() then
		self:createStringForLastNode_2(localize("发现新版本！请到应用商店更新！") ,0.8 )
	else
		if isByUpdate  then
			self:createStringForLastNode_1( Localhost:timeInSec() )
		else
			self:createStringForLastNode_2(localize("error.tip.731527") , 0.7)	
		end

	end
	
end

function QuickTableRender_New:addLevelArea( ... )
	-- body
	local x = self:getContentSize().width / 4 - 32
	x = 200
	local y = self:getContentSize().height / 2
	if not self.isLockUI then
		y = 90 
	end

	local unlockTime = false 
	if self.data.isTopLevelArea and self.data.lastAreaIsLock  then
		unlockTime = true
	end
	
	local minLevel = (self.data.index - 1) * 15 + 1
	local maxLevel = self.data.index * 15
	local scale = 2/3
	
	if unlockTime then
    	y = 40 
    	self:createStringForLastNode_2(  Localization:getInstance():getText("unlock.cloud.new.area.lock") ,0.7 )
		local countdownAreaId = NewAreaOpenMgr.getInstance():getNextCountdownArea()
		local countdownAreaId_Now = NewAreaOpenMgr.getInstance():getCurCountdownArea()
		if countdownAreaId  then 
			local now = Localhost:timeInSec()
			local endTime = NewAreaOpenMgr.getInstance():getCountdownEndTime( countdownAreaId_Now or countdownAreaId )
			if endTime > now then
				if endTime > 0 and not _G.isPrePackage then 
					self:initCountdown( endTime )
				end
			else
				self:showNewLevelOnTimeText()
			end
			
		end
	    y = 90 
    end

    local function create4BitmapText( minLevel , maxLevel ,posX , posY , panel ,_color)

    	local textTable = {}
    	textTable[1] = BitmapText:create(  "第" , "fnt/register2.fnt")
    	textTable[2] = BitmapText:create(  minLevel.."" , "fnt/hud.fnt")
    	textTable[3] = BitmapText:create(  " ~ " , "fnt/register2.fnt")
    	textTable[4] = BitmapText:create(  maxLevel.."" , "fnt/hud.fnt")
    	textTable[5] = BitmapText:create(  "关" , "fnt/register2.fnt")


    	textTable[2]:setScale(1.2)
    	textTable[4]:setScale(1.2)

    	local totalWidth = 0

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		totalWidth = totalWidth + textNode:getContentSize().width * textNode:getScale()
    	end

    	local leftPosX = posX - totalWidth/2 

    	for i=1,#textTable do
    		local textNode = textTable[i]
    		local leftNode = textTable[i-1]
    		textNode:setAnchorPoint(ccp(0.5,0.5))
    		local myPosX = leftPosX + textNode:getContentSize().width/2 * textNode:getScale()
    		if leftNode then
    			myPosX = leftNode:getPositionX() + leftNode:getContentSize().width/2 *leftNode:getScale() + textNode:getContentSize().width/2*textNode:getScale()
    		end
    		textNode:setPositionXY( myPosX , posY )
    		panel:addChild( textNode )
    		textNode:setColor(_color)
    	end

    end 

    if  not self.isFull then
    	if self.isLockUI then
    		--蓝色
    		create4BitmapText( minLevel , maxLevel , 650/2 -5 , 90 ,self ,hex2ccc3('406CCD') )
    		if not unlockTime then
            	local levelAreaString = "尚未解锁"
				local text = BitmapText:create(  levelAreaString , "fnt/register2.fnt")
			    -- text:setPreferredSize(200, 50)
			    text:setAnchorPoint(ccp(0.5,0.5))
			    -- text:setScale( 0.5 )
			    text:setPositionXY( 650/2-5, 40 )
			    text:setColor(hex2ccc3('406CCD'))
			    self:addChild( text )
    		end

    	else
    		--蓝色
    		create4BitmapText( minLevel , maxLevel , 650/2 -5 , y ,self ,hex2ccc3('406CCD') )
    	end
    else
    	--黄色
    	create4BitmapText( minLevel , maxLevel , 650/2 -5, y ,self ,hex2ccc3('DD9A51') )
    end

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
		y = self:getContentSize().height / 2
		icon:setPosition(ccp(50,y + addY))
	end

	self.icon = icon
end

function QuickTableRender_New:hideIcon( ... )
	-- body
	if self.icon then
		self.icon:setVisible(false)
	end
end

function QuickTableRender_New:changeScale( value )

	-- -- body
	-- self:setScale(value)
	-- if self.icon then
	-- 	self.icon:setVisible(true)
	-- end
	-- local alpha = value - minScale
	-- self.fg:setAlpha( maxScale - alpha * 5)
end

function QuickTableRender_New:addFgFullStarAnim( ... )
	-- self:runAction(AnimationUtil.getForeverCall(2.5, function()
	-- 	self:__addAGroupStar(5, 15, 3, 520, 5)
	-- 	self:__addAGroupStar(5, 15, 90, 520, 5)
	-- 	self:__addAGroupStar(2, 5, 15, 8, 80)
	-- 	self:__addAGroupStar(2, 542, 15, 8, 80)
	-- 	self:__addAGroupStar(2, 80, 15, 250, 80)
	-- end), true)

	self.starsbg1 = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/starsbg10000")
	self:addChild( self.starsbg1 )
	self.starsbg1:setAnchorPoint(ccp(0,1))
	self.starsbg1:setPositionXY( 0,124 )

	self.full_jiaobiao = Sprite:createWithSpriteFrameName("StarAchievenmentPanel_New/full_jiaobiao0000")
	self:addChild( self.full_jiaobiao )
	self.full_jiaobiao:setAnchorPoint(ccp(1,0))
	self.full_jiaobiao:setPositionXY( 650 , 5 )
	

end

function QuickTableRender_New:__addAGroupStar(num, startX, startY, rectWidth, rectHeight)
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