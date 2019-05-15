

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月12日 16:33:31
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- RankListItem
---------------------------------------------------

assert(not RankListItem)
assert(BaseUI)
RankListItem = class(BaseUI)

function RankListItem:init(ui, levelFlag,...)
	assert(ui)
	assert(#{...} == 0)

	-- Init Base Class
	BaseUI.init(self, ui)

	-- ---------------
	-- Get UI Reousece
	-- -----------------
	self.levelFlag = levelFlag
	self.rankLabel		= self.ui:getChildByName("rankLabel")
	self.userNameLabel	= self.ui:getChildByName("userNameLabel")
	self.userScoreLabel	= self.ui:getChildByName("userScoreLabel")

	self.goldCrown		= self.ui:getChildByName("goldCrown")
	self.silverCrown	= self.ui:getChildByName("silverCrown")
	self.brassCrown		= self.ui:getChildByName("brassCrown")
	self.rankLabelBg	= self.ui:getChildByName("rankLabelBg")

	self.ui:getChildByName('frameHeader'):removeFromParentAndCleanup(true)

	self.userIconPlaceholder = self.ui:getChildByName("userIconPlaceholder")

	assert(self.rankLabel)
	assert(self.userNameLabel)
	assert(self.userScoreLabel)

	assert(self.goldCrown)
	assert(self.silverCrown)
	assert(self.brassCrown)
	assert(self.rankLabelBg)

	assert(self.userIconPlaceholder)

	--ios 的系统字体比安卓偏上 调整一下
	if __IOS then
		local oriPosY = self.rankLabel:getPositionY()
		self.rankLabel:setPositionY(oriPosY - 3)
	end

	----------------------
	-- Init UI Component
	-- ------------------
	self.goldCrown:setVisible(false)
	self.silverCrown:setVisible(false)
	self.brassCrown:setVisible(false)
	--self.highLightBg:setVisible(false)

	----------------------
	-- Add Event Listener
	-- ------------------
	local function headDisposed(...)
		self.headDisposed = true
	end
	self.userIconPlaceholder:ad(Events.kDispose, headDisposed)

	-- 活动中需要修改UI，自己头像上需要加一个装饰，在此特殊处理
	self.headDeco = self.ui:getChildByName("headdeco")


	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		self:setMainBGColorWithData_Purple()
	elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then 
		self:setMainBGColorWithData_Green()
	end
    
    ui:setTouchEnabled(true, 0, false)
    ui:ad(DisplayEvents.kTouchBegin, function(event)
        self.lastTouchPos = event.globalPosition
    end)
    ui:ad(DisplayEvents.kTouchEnd, function(event,x,y)
	    if self.lastTouchPos then
	        local distance = ccpDistance(self.lastTouchPos, event.globalPosition)
	        if distance<10 then
	        	local function showFriendInfoPanel()
		            require("zoo.PersonalCenter.FriendInfoPanel"):create(self.uid)
		            local dcKey = self.uid==UserManager:getInstance().uid and 0 or FriendManager.getInstance():getFriendInfo(self.uid) and 1 or 2
			        DcUtil:UserTrack({category='ui', sub_category="G_my_card_click ",t1="4",t2=dcKey}, true)
		        end
	        	if self.owner and self.owner.ui and self.owner.tabBtnY then
	        		local pos = self.owner.ui:convertToNodeSpace(event.globalPosition)
	        		if pos.y<self.owner.tabBtnY-50 then
						showFriendInfoPanel()
	        		end
	        	else
	        		showFriendInfoPanel()
	        	end

	        end
	    end
    end)

end

function RankListItem:setData(rank, userName, userScore, headUrl, isSelf, star, userId, data)

	assert(type(rank) 	== "number")
	assert(type(userName)	== "string")
	assert(type(userScore)	== "number")

	self.uid = userId

	self.rankLabel:setVisible(true)
	self.rankLabelBg:setVisible(true)
	
	if rank > 99 then
		self.rankLabel:setFontSize(24)
		self.rankLabel:setPositionX(self.rankLabel:getPositionX() - 3)
		self.rankLabelBg:setScale(1.1)
	else
		self.rankLabel:setFontSize(30)
	end
	self.rankLabel:setString(tostring(rank))

	local nickName = TextUtil:ensureTextWidth(nameDecode(userName), self.userNameLabel:getFontSize(), self.userNameLabel:getDimensions())
	if nickName then 
		self.userNameLabel:setString(nickName) 
	else
		self.userNameLabel:setString(nameDecode(userName)) 
	end

	self.userScoreLabel:setString(tostring(userScore))

	if not headUrl then
		headUrl = '0'
	end

	if self.headUrl ~= headUrl then
		self.headUrl = headUrl
		-- if headUrl ~= nil then
			if self.clipping then self.clipping:removeFromParentAndCleanup(true) end
			local function onImageLoadFinishCallback(clipping)
				if not self.userIconPlaceholder or self.userIconPlaceholder.isDisposed then return end
				if self.headDisposed then return end
				-- local holderSize = self.userIconPlaceholder:getContentSize()
				local holderSize = CCSizeMake(50, 50)
				local clippSize = clipping:getContentSize()
				local scale = holderSize.width / clippSize.width

				local percent = 0.98
				local offsetX = 0

				clipping:setScale(scale*percent)
				clipping:setPosition(ccp(holderSize.width*0.5+offsetX , holderSize.height*0.5))
				self.clipping = clipping
				-- 加个背景，避免透明头像显示出底图案
				-- local bg = LayerColor:createWithColor(hex2ccc3("FFFFFF"), 98, 98)
				-- bg:setPosition(ccp(7, 12))
				-- self.userIconPlaceholder:addChild(bg)

				self.userIconPlaceholder:addChild(self.clipping)

			end

			local head = HeadImageLoader:createWithFrame(userId, headUrl, nil, 3, data.profile)
			onImageLoadFinishCallback(head)

		-- else
			-- if self.clipping then self.clipping:removeFromParentAndCleanup(true) end
			-- self.clipping = nil
		-- end
	end
	-- 活动中需要修改UI，自己头像上需要加一个装饰，在此特殊处理
	-- if self.headDeco then
		-- self.headDeco:setVisible(isSelf)
	-- end

	if rank >= 1 and rank <= 3 then

		self.rankLabel:setVisible(false)
		self.rankLabelBg:setVisible(false)

		if rank == 1 then
			self.goldCrown:setVisible(true)
		elseif rank == 2 then
			self.silverCrown:setVisible(true)
		elseif rank == 3 then
			self.brassCrown:setVisible(true)
		end
	end

	self.fourStarFlag = self.ui:getChildByName("fourStarFlag")
	self.fourStarFlag:setVisible(false)

	if self.__showFourStarFlag ~= false and star then 
		local pos = self.userScoreLabel:getPosition()
		self.userScoreLabel:setPosition(ccp(pos.x - 20, pos.y))

		if star == 4 then 
			self.fourStarFlag:setVisible(true)
			
			self:showFourStarShine()
		end
	end
end

function RankListItem:showFourStarShine()
	if self.isDisposed then return end

	if not self.fourStarShine then 
		self.fourStarShine = Sprite:createWithSpriteFrameName('four_star_shine_0000.png')
		self.fourStarShine:setAnchorPoint(ccp(0,0))
		self.fourStarFlag:addChild(self.fourStarShine)
		self.fourStarShine:setPosition(ccp(5, 16))
	end
	self.fourStarShine:setVisible(true)
	local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("four_star_shine_%04d.png", 0, 31), 1/30)
	self.fourStarShine:play(animate, 0, 3, function ()
		self:hideFourStarShine()
	end)
end

function RankListItem:hideFourStarShine()
	if self.isDisposed then return end
	if self.fourStarShine then 
		 self.fourStarShine:setVisible(false)
	end
end

function RankListItem:create(ui , levelFlag)
	local newItem = RankListItem.new()
	newItem:init(ui,levelFlag)
	return newItem
end

function RankListItem:setShowFourStarFlag(bShow)
	self.__showFourStarFlag = bShow
end

function RankListItem:setMainBGColorWithData_Purple()

	--色度 
	--饱和度
	--亮度
	--对比度

	local mainBG = self.ui:getChildByName("_bg")
	if mainBG then
		mainBG:adjustColor(1 , 0  , -0.125196, 0.1828137)
	--	mainBG:adjustColor(1 , 1  , -0.15, 0.1828137)
		mainBG:applyAdjustColorShader()
	end
	
	if self.userScoreLabel then
		self.userScoreLabel:setColor((ccc3(93,64,168)))
	end
	if self.userNameLabel then
		self.userNameLabel:setColor((ccc3(93,64,168)))
	end
	if self.userIconPlaceholder then
		self.userIconPlaceholder:adjustColor(1 , 0 , 0 , 0 )
		self.userIconPlaceholder:applyAdjustColorShader()
	end

	

end


function RankListItem:setMainBGColorWithData_Green()

	--色度 
	--饱和度
	--亮度
	--对比度
	--	LevelDiffcultFlag.kExceedinglyDifficult
	-- local mainBG = self.ui:getChildByName("_bg")
	-- if mainBG then
	-- 	mainBG:adjustColor(1 , 0  , -0.125196, 0.1828137)
	-- --	mainBG:adjustColor(1 , 1  , -0.15, 0.1828137)
	-- 	mainBG:applyAdjustColorShader()
	-- end
	
	if self.userScoreLabel then
		self.userScoreLabel:setColor((ccc3(126,174,82)))
	end
	if self.userNameLabel then
		self.userNameLabel:setColor((ccc3(126,174,82)))
	end
	-- if self.userIconPlaceholder then
	-- 	self.userIconPlaceholder:adjustColor(1 , 0 , 0 , 0 )
	-- 	self.userIconPlaceholder:applyAdjustColorShader()
	-- end

	

end