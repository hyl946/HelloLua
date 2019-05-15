require 'zoo.panel.share.ArmatureShareBasePanel'
SharePyramidPanel = class(ArmatureShareBasePanel)

function SharePyramidPanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	self.highestLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
end

function SharePyramidPanel:initUI()
	ArmatureShareBasePanel.initUI(self)
	if self.animIndex == 2 then --写关卡数到动画里
		local slot = self.node:getSlot('number')
    	local text = BitmapText:create("", 'fnt/level_seq_n_energy_cd.fnt', 0)
    	text:setPreferredSize(170, 60)
    	text:setString(tostring(self.highestLevel))
    	text:setAnchorPoint(ccp(-0.1, 1))
    	local sprite = Sprite:createEmpty()
    	sprite:addChild(text)
    	slot:setDisplayImage(sprite.refCocosObj)
    elseif self.animIndex == 1 then
    	local rawPos = self.node:getPosition()
    	self.node:setPosition(ccp(rawPos.x - 363, rawPos.y + 900))
	end
end

function SharePyramidPanel:getShareParam(msg, txtID, btn, headImage, nickName)
	local param = ShareBasePanel.getShareParam(self, msg, txtID, btn, headImage, nickName)
	param.type = self.animIndex
	if self.animIndex == 2 then
		param.num = self.highestLevel
	elseif self.animIndex == 3 then
		if self.rank > 0 then 
			param.num = self.rank
			param.subType = 2
		elseif self.friendRank > 0 then 
			param.num = self.friendRank 
			param.subType = 1
		end
	end
	return param
end

function SharePyramidPanel:getShareLinkTitleMessage( ... )	
	local title = Localization:getInstance():getText("show_new_title20")
	local message = ""
	if self.rank > 0 then
		message = Localization:getInstance():getText("show_new_text20",{ num=self.rank })
	elseif self.friendRank > 0 then
		message = Localization:getInstance():getText("show_new_text20_2",{num=self.friendRank})
	else
		message = Localization:getInstance():getText("show_new_text20_1",{num = self.highestLevel})
	end

	return title,message
end

function SharePyramidPanel:getShareImgName()
	return self.config.id .. "_" .. self.animIndex .. ".jpg"
end

function SharePyramidPanel:getShareTitleName()
	if self.rank > 0 then
		-- 全村第{num}个通关全部关卡！
		return Localization:getInstance():getText("show_off_desc_20",{num=self.rank,num1=self.highestLevel})
	elseif self.friendRank > 0 then
		return Localization:getInstance():getText("show_off_desc_20_2",{num=self.friendRank})
	else
		return Localization:getInstance():getText("show_off_desc_20_1",{num = self.highestLevel})
	end
end

function SharePyramidPanel:create(shareId)
	local panel = SharePyramidPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.shareId = shareId
	local rankData = Achievement:get(AchiDataType.kRankData)
	local rank, friendRank = 0,0
	if rankData then
		rank = rankData.rank or 0
		friendRank = rankData.friendRank or 0
	end
	if rank < 1 and friendRank < 1 then 
		panel.animIndex = 1
	else
		panel.animIndex = math.random(3)
	end
	panel.rank = rank
	panel.friendRank = friendRank
	panel:init('skeleton/share_20_' .. panel.animIndex .. '_animation', 
			   'share_20_' .. panel.animIndex .. '_animation', 
			   'share_20_' .. panel.animIndex .. '_animation', 
			   'share_20_' .. panel.animIndex .. '_animation/animation')
	return panel
end

function SharePyramidPanel:initShareTitle(titleName)
    local slot = self.node:getSlot('title')
    local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)
end
