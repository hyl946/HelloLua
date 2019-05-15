
require 'zoo.quarterlyRankRace.plugins.BasePlugin'
local UIHelper = require 'zoo.panel.UIHelper'

local RewardItem = class(BasePlugin)

function RewardItem:onPluginInit( ... )
	if not BasePlugin.onPluginInit(self, ...) then return false end
		
	local holder = self:getChildByPath('holder')
	holder:setVisible(false)
	local num = self:getChildByPath('num')
	local numSize = self:getChildByPath('numSize')


	self.holder = holder
	self.num = num

	self.flagPH = self:getChildByPath('flagPH')
	if self.flagPH then
		self.flagPH:setVisible(false)
	end

	self.flagOffsetX = 0
	self.flagOffsetY = 0

	if numSize then
		numSize:setVisible(false)
		self.withSize = true
		self.num = TextField:createWithUIAdjustment(numSize, num)
		self:addChild(self.num)
	end
	

	return true
end


local function normalizeNum(num)
	if num >= 10000 then
		return tostring(num/10000)..'万'
	else
		return tostring(num)
	end
end

function RewardItem:setRewardItem( rewardItem, showTimeFlag, useNewTxt, fntName, useBigFlag , specialItemsConfig )

	local timeLimitFlagName = '___auto_time_limit_flag_20190118'
	if true then
		local timeLimitFlag = self:getChildByName(timeLimitFlagName)
		if timeLimitFlag then
			timeLimitFlag:removeFromParentAndCleanup(true)
		end
	end

	if specialItemsConfig == nil then
		specialItemsConfig = {}
	end
	showTimeFlag = showTimeFlag == nil and false or showTimeFlag
	if ItemType:isHeadFrame(rewardItem.itemId) then
		self.num:setVisible(false)
		--buildFrameUI
		local frameId = ItemType:convertToHeadFrameId(rewardItem.itemId)
		local userId = UserManager:getInstance().user.uid
		local frameUI = HeadFrameType:buildUI(frameId, 1, userId)
        local holder = frameUI:getChildByName('head')
        holder:setAnchorPointCenterWhileStayOrigianlPosition()
        holder:setScale(1.2 * holder:getScaleX())
        local size = holder:getContentSize()
        local center = ccp(size.width/2, size.height/2)
        local posInFrameUI = frameUI:convertToNodeSpace(holder:convertToWorldSpace(center))
        UIHelper:move(frameUI:getChildByPath('headFrame'), -posInFrameUI.x, -posInFrameUI.y)
        UIHelper:move(holder, -posInFrameUI.x, -posInFrameUI.y)
        frameUI:getChildByPath('headFrame'):setTag(HeDisplayUtil.kIgnoreGroupBounds)
		UIUtils:positionNode(self.holder, frameUI, true)
		holder:setVisible(false)

	elseif ItemType:isHonor(rewardItem.itemId) then
		local frameName = 'xf/' .. rewardItem.itemId .. '0000'
		if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName) then
			local sp = Sprite:createWithSpriteFrameName(frameName)
			UIUtils:positionNode(self.holder, sp, true)
		end

		local numText = tostring(rewardItem.num)
		if rewardItem.num >= 10000 then
			numText = string.format('%s', normalizeNum(rewardItem.num))
		end
		self.num:setVisible(true)
		if self.withSize  then
			self.num:setString('x' .. numText)
		else
			self.num:setText('x' .. numText)

			if useNewTxt then
				local UIHelper = require 'zoo.panel.UIHelper'
				UIHelper:setRightText(self.num, 'x' .. numText, fntName)
			end
		end

		
	else
		local nDisplayNum = rewardItem.num

		if ItemType:isMergableItem(rewardItem.itemId) then
			nDisplayNum = 1
		end

		local numText = tostring(nDisplayNum)
		if nDisplayNum >= 10000 then
			numText = string.format('%s', normalizeNum(nDisplayNum))
		end

		self.num:setVisible(true)
		if self.withSize  then
			self.num:setString('x' .. numText)
		else
			self.num:setText('x' .. numText)

			if useNewTxt then
				local UIHelper = require 'zoo.panel.UIHelper'
				UIHelper:setRightText(self.num, 'x' .. numText, fntName)
			end
		end


        local ItemSprite

        --对黄宝石特殊处理
        if rewardItem.itemId == ItemType.RACE_TARGET_1 then
            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
            if SaijiIndex == 1 then
                ItemSprite = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
            else
                ItemSprite = ResourceManager:sharedInstance():buildItemSprite( ItemType.RACE_TARGET_2 )
            end
        else
        	if specialItemsConfig[rewardItem.itemId ] then
				if specialItemsConfig[rewardItem.itemId ].frameName then
					ItemSprite = Sprite:createWithSpriteFrameName(specialItemsConfig[rewardItem.itemId ].frameName)
					local btNum = BitmapText:create(tonumber( rewardItem.num ) or 0, 'fnt/prop_amount.fnt', -1, kCCTextAlignmentLeft)
					btNum:setTag(HeDisplayUtil.kIgnoreGroupBounds)
					btNum:setAnchorPoint(ccp(0.5, 0.5))
					btNum:setPosition(ccp(53, 24))
					btNum:setScale(0.7)
					ItemSprite:addChild( btNum )
				else
					ItemSprite = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(rewardItem.itemId, rewardItem.num)
				end
			else
				ItemSprite = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(rewardItem.itemId, rewardItem.num)
			end
        end

		UIUtils:positionNode(self.holder, ItemSprite, true)

		if showTimeFlag then



			local flag = ResourceManager:sharedInstance():createTimeLimitFlag(rewardItem.itemId, useBigFlag == nil and true or false)
			if flag then
				flag.name = timeLimitFlagName
				self:addChild(flag)
				if self.flagPH then
					local pos = self.flagPH:getPosition()
					flag:setPosition(ccp(pos.x + self.flagOffsetX, pos.y + self.flagOffsetY))
				else
					local bounds = self.holder:getGroupBounds(self)
					flag:setPositionX(bounds:getMidX() + self.flagOffsetX)
					flag:setPositionY(bounds.origin.y + self.flagOffsetY)
				end
			end
		end
	end

end

function RewardItem:setFlagOffset( ox, oy )
	if self.isDisposed then return end
	self.flagOffsetX = ox
	self.flagOffsetY = oy
end


return RewardItem