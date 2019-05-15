require "zoo.panel.basePanel.BasePanel"
require "zoo.baseUI.ButtonWithShadow"

local SpringFestival2019PropInfoPanel = class(BasePanel)

-- local InGamePropsId = {
-- 	10001,10010,10002,10003,10004,10005, 10052
-- }

function SpringFestival2019PropInfoPanel:create(gameBoardLogic)
	local panel = SpringFestival2019PropInfoPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_buy_prop)
	if panel:init(gameBoardLogic) then
		return panel
	else
		panel = nil
		return nil
	end
end

function SpringFestival2019PropInfoPanel:init(gameBoardLogic)

--    if GameSpeedManager:getGameSpeedSwitch() > 0 then
--		GameSpeedManager:resuleDefaultSpeed()
--	end

	FrameLoader:loadArmature( "skeleton/Spring2019PropAnim" )

    local panelType = 1

	-- 初始化数据
	self.exitCallback = nil

	-- 初始化面板
	self.panel = self:buildInterfaceGroup("PropInfoPanel")
	BasePanel.init(self, self.panel)

	-- 获取控件
	self.bg = self.panel:getChildByName("yellowBg")
	self.panelTitle = self.panel:getChildByName("panelTitle")
	self.panelBtn = self.panel:getChildByName("panelBtn")
	self.panelBtn = GroupButtonBase:create(self.panelBtn)

	-- 屏幕适配
	local wSize = CCDirector:sharedDirector():getWinSize()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local realVisibleSize = CCDirector:sharedDirector():ori_getVisibleSize()

	self.background = LayerGradient:create()
	self.background:changeWidthAndHeight(realVisibleSize.width, realVisibleSize.height)
	self.background:setStartColor(ccc3(255, 216, 119))
    self.background:setEndColor(ccc3(247, 187, 129))
    self.background:setStartOpacity(255)
    self.background:setEndOpacity(255)
    self.background:ignoreAnchorPointForPosition(false)
    self.background:setAnchorPoint(ccp(0, 1))
    self.background:setPositionY(_G.__EDGE_INSETS.top)
    local index = self.panel:getChildIndex(self.bg)
    self.panel:addChildAt(self.background,index)
	local backgroundSize = vSize
	local bgSize = self.bg:getGroupBounds().size
	self.bg:setPositionX((vSize.width - bgSize.width) / 2)
	self.bg:setPreferredSize(CCSizeMake(bgSize.width, backgroundSize.height - 217)) -- upper 81, lower 136
	bgSize = self.bg:getGroupBounds().size
	self.panelBtn:setPositionY(68 - vSize.height)

	-- 设置文字（需要更新本地化文件）
	self.panelTitle:setText(Localization:getInstance():getText("prop.info.panel.title"))
	local size = self.panelTitle:getContentSize()
	local scale = 65 / size.height
	self.panelTitle:setScale(scale)
	self.panelTitle:setPositionX((vSize.width - size.width * scale) / 2)
	self.panelBtn:setString(Localization:getInstance():getText("prop.info.panel.close.txt"))

	-- 添加遮罩（可动区域）
	local listVHeight = bgSize.height - 40
	self.clippingNode = ClippingNode:create(CCRectMake(0, 0, bgSize.width - 40, listVHeight))
	self.clippingNode:setPosition(ccp(self.bg:getPositionX() + 25, self.bg:getPositionY() - 20 - listVHeight))
	self:addChild(self.clippingNode)
	self.propVisualList = Layer:create()
	self.propVisualList:setPosition(ccp(0, listVHeight))
	self.clippingNode:addChild(self.propVisualList)

	-- 设置道具说明列表
--	self:buildPropComment(panelType)
--	self.propComment:setPositionX((bgSize.width - 55 - self.propComment:getGroupBounds().size.width) / 2)
--	self.propVisualList:addChild(self.propComment)
--	self.listHeight = -self.propComment:getGroupBounds().size.height
    self.listHeight = 0

    local SkillPropInfoList = {1,3,4}
    for i,v in ipairs(SkillPropInfoList) do
		self:buildPropListItem(v)
	end

	local propListItemFixedWidth = 631
	for i = 1, #self.propList do
		self.propList[i]:setPosition(ccp((bgSize.width - 40 - propListItemFixedWidth) / 2, self.listHeight))
		self.propVisualList:addChild(self.propList[i])
		self.listHeight = self.listHeight - self.propList[i].height
	end	

	-- 设置互动事件监听
	local function onPanelBtnTapped()
		self:onCloseBtnTapped()
	end
	self.panelBtn:addEventListener(DisplayEvents.kTouchTap, onPanelBtnTapped)

	local function checkTouchArea(positionY)
		local pos = ccp(0, -listVHeight - 70)
		pos = self:convertToWorldSpace(ccp(0, pos.y))
		return not (positionY > pos.y + listVHeight or positionY < pos.y)
	end

	local function onTouchBegin(evt)
		self.propVisualList:stopAllActions()
		self.lastY = evt.globalPosition.y
		self.disableListening = not checkTouchArea(self.lastY)
	end
	local function onTouchMove(evt)
		if self.disableListening then return end
		local nowPos = self.propVisualList:getPosition().y
		local deltaY = evt.globalPosition.y - self.lastY
		if nowPos < listVHeight then
			if math.abs(listVHeight - nowPos) > 10 then
				deltaY = deltaY / ((listVHeight - nowPos) / 10)
			end
		elseif nowPos + self.listHeight > 0 then
			if math.abs(nowPos + self.listHeight) > 10 then
				deltaY = deltaY / ((nowPos + self.listHeight) / 10)
			end
		end
		self.propVisualList:runAction(CCMoveBy:create(0, ccp(0, deltaY)))
		self.lastY = evt.globalPosition.y
	end
	local function onTouchEnd(evt)
		self.propVisualList:stopAllActions()
		local nowPos = self.propVisualList:getPosition().y
		if nowPos < listVHeight then
			self.propVisualList:runAction(CCMoveTo:create(0.2, ccp(0, listVHeight)))
		elseif nowPos + self.listHeight > 0 then
			self.propVisualList:runAction(CCMoveTo:create(0.2, ccp(0, -self.listHeight)))
		end
		self.lastY = nil
		if _G.isLocalDevelopMode then printx(0, nowPos, self.listHeight) end
	end
	if -self.listHeight > listVHeight then
		self.propVisualList:setTouchEnabled(true)
		self.propVisualList:ad(DisplayEvents.kTouchBegin, onTouchBegin)
		self.propVisualList:ad(DisplayEvents.kTouchMove, onTouchMove)
		self.propVisualList:ad(DisplayEvents.kTouchEnd, onTouchEnd)
	end
	local function onPlayClick(evt)
		if not checkTouchArea(evt.globalPosition.y) then return end
		for __, v in ipairs(self.propList) do
			if v.curtain == evt.target then v:playAnime()
			else v:stopAnime() end
		end
	end
	for __, v in ipairs(self.propList) do
		v.curtain:setTouchEnabled(true)
		v.curtain:ad(DisplayEvents.kTouchTap, onPlayClick)
	end

	return true
end

function SpringFestival2019PropInfoPanel:onCloseBtnTapped()
	if self.exitCallback then self.exitCallback() end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/Spring2019PropAnim/texture.png"))
--	if GameSpeedManager:getGameSpeedSwitch() > 0 then
--		GameSpeedManager:changeSpeedForFastPlay()
--	end
end

function SpringFestival2019PropInfoPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self.allowBackKeyTap = true
end

function SpringFestival2019PropInfoPanel:setExitCallback(callback)
	self.exitCallback = callback
end

function SpringFestival2019PropInfoPanel:buildPropComment(commentType)
	self.propComment = self:buildInterfaceGroup("propComment" .. commentType)
	if commentType == 1 then
		self.comment = self.propComment:getChildByName("comment")
		-- 设置文字（需要更新本地化文件）
		self.comment:setString(Localization:getInstance():getText("prop.info.panel.list1"))
		local titleKeys = {
			"prop.info.panel.common",
			"prop.info.panel.limit",
		}
		local descKeys = {
			"prop.info.panel.common.desc",
			"prop.info.panel.limit.desc",
		}
		for i=1,2 do
			local item = self.propComment:getChildByName("item" .. i)

			local title = item:getChildByName("title")
			local desc = item:getChildByName("desc")

			local mark = item:getChildByName("mark2")

			title:setString(Localization:getInstance():getText(titleKeys[i]))
			desc:setString(Localization:getInstance():getText(descKeys[i]))

			desc:setPositionY(mark:boundingBox():getMinY())

			for j=1,3 do
				local num = item:getChildByName("num" .. j)
				if num then
					num:setVisible(i == j)
				end
				local mark = item:getChildByName("mark" .. j)
				if mark then
					-- mark:setVisible(i == j)
					mark:setVisible(i == 2 and j == 2)
				end
			end
		end
	else
		local titleKeys = {
			"prop.info.panel.common",
			"prop.info.panel.limit",
			"prop.info.panel.gift",
		}
		local descKeys = {
			"prop.info.panel.common.desc",
			"prop.info.panel.limit.desc",
			"prop.info.panel.gift.desc",
		}
		for i=1,3 do
			local item = self.propComment:getChildByName("item" .. i)

			local title = item:getChildByName("title")
			local desc = item:getChildByName("desc")

			local mark = item:getChildByName("mark2")

			title:setString(Localization:getInstance():getText(titleKeys[i]))
			desc:setString(Localization:getInstance():getText(descKeys[i]))

			desc:setPositionY(mark:boundingBox():getMinY())

			for j=1,3 do
				local num = item:getChildByName("num" .. j)
				if num then
					num:setVisible(i == j)
				end
				local mark = item:getChildByName("mark" .. j)
				if mark then
					mark:setVisible(i == j)
				end
			end
		end
	end
end

local kSpringSkillPropAnimation = {}
kSpringSkillPropAnimation[1] = "Spring2019Anim/Spring2019_Skill1Anim"
kSpringSkillPropAnimation[2] = "Spring2019Anim/Spring2019_Skill2Anim"
kSpringSkillPropAnimation[3] = "Spring2019Anim/Spring2019_Skill3Anim"
kSpringSkillPropAnimation[4] = "Spring2019Anim/Spring2019_Skill4Anim"

local SkillNameList = {
    "投掷特效","分数加成","四连爆炸","魔力特效"
}
local SkillPosOffset = {
    ccp(5,0), ccp(5,0),ccp(3,-4),ccp(0,0)
}

function SpringFestival2019PropInfoPanel:creatTutorialAnimation(SkillID) 
    
	local propName = kSpringSkillPropAnimation[SkillID]
	if propName then
		local node = ArmatureNode:create(propName)
		node:setAnimationScale(1.25)
		node:playByIndex(0)
		node.playAnimation = function( self )
			node:playByIndex(0, 0)
		end
		node.stopAnimation = function ( self )
			node:gotoAndStopByIndex(0, 0)
		end
		node:update(0.001)
		node:stop()
		return node
	else return nil end
end

function SpringFestival2019PropInfoPanel:buildPropListItem(SkillID)

	local animation = self:creatTutorialAnimation(SkillID)
	if not animation then
		return
	end

	local propListItem = self:buildInterfaceGroup("PropListItem")
	propListItem.propIconPlaceholder = propListItem:getChildByName("propIconPlaceholder")
	propListItem.propName = propListItem:getChildByName("propName")
	propListItem.propName:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	propListItem.propDesc = propListItem:getChildByName("propDesc")
	propListItem.animePlaceholder = propListItem:getChildByName("animePlaceholder")
	propListItem.curtain = propListItem:getChildByName("curtain")
	propListItem.btnPlay = propListItem:getChildByName("btnPlay")
	propListItem.btnPlayText = propListItem.btnPlay:getChildByName("text")

	-- 设置文字（需要更新本地化文件）
	propListItem.propName:setString(SkillNameList[SkillID])
	propListItem.propDesc:setString( Localization:getInstance():getText("level.skill.tip.1000"..SkillID, {n = "\n"} ) )


    local sprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/Skill"..SkillID.."0000")
	sprite:ignoreAnchorPointForPosition(false)
	sprite:setAnchorPoint(ccp(0.5, 0.5))
	local phSize = propListItem.propIconPlaceholder:getGroupBounds(propListItem).size
	local pos = propListItem.propIconPlaceholder:getPosition()
	sprite:setPosition(ccp(pos.x + phSize.width/2 + 3+SkillPosOffset[SkillID].x, pos.y - phSize.height / 2+SkillPosOffset[SkillID].y))
	sprite:setScale(0.7)
	propListItem.propIconPlaceholder:getParent():addChild(sprite)
	propListItem.propIconPlaceholder:removeFromParentAndCleanup(true)
	propListItem.btnPlayText:setString(Localization:getInstance():getText("prop.info.panel.anim.play"))

	-- 添加动画
	propListItem.animation = animation
	local ac = propListItem.animation:getAnchorPoint()
	propListItem.animation:setAnchorPoint(ccp(0, 1))
	pos = propListItem.animePlaceholder:getPosition()
	local size = propListItem:getGroupBounds().size
	propListItem.height = size.height
	propListItem.animation:setPosition(ccp(pos.x, pos.y))
	propListItem.animePlaceholder:getParent():addChildAt(propListItem.animation:wrapWithBatchNode(), 0)
	if _G.isLocalDevelopMode then printx(0, size.width, size.height) end
	propListItem.animePlaceholder:removeFromParentAndCleanup(true)
	propListItem.animePlaceholder = nil

	propListItem.playAnime = function()
		propListItem.curtain:setVisible(false)
		propListItem.btnPlay:setVisible(false)
		propListItem.animation:playAnimation()
	end
	propListItem.stopAnime = function()
		propListItem.animation:stopAnimation()
		propListItem.curtain:setVisible(true)
		propListItem.btnPlay:setVisible(true)
	end

	if not self.propList then self.propList = {} end
	table.insert(self.propList, propListItem)
end

function SpringFestival2019PropInfoPanel:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= 722

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end

return SpringFestival2019PropInfoPanel