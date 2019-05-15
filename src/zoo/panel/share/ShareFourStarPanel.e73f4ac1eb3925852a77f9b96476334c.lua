require 'zoo.panel.share.ShareBasePanel'

ShareFourStarPanel = class(ShareBasePanel)

function ShareFourStarPanel:ctor()

end

function ShareFourStarPanel:init()
	--初始化文案内容
	ShareBasePanel.init(self, self.shareType)
	self.levelId = self.achiManager:get(AchiDataType.kLevelId)

	self:runNpcAction()
	self:runLevelNumAction()
	self:runStarGroup1Action()
	self:runStarGroup2Action()
	self:runStarGroup3Action()
	self:runCircleLightAction()
end

function ShareFourStarPanel:getShareTitleName()
	return Localization:getInstance():getText(self.shareTitleKey,{})
end

function ShareFourStarPanel:runNpcAction()
	local npcUi = self.ui:getChildByName("npc")
	if npcUi then
		npcUi:setOpacity(0)
		local oriPos = npcUi:getPosition()
		npcUi:setPosition(ccp(oriPos.x+10, oriPos.y-80))
		local sequenceArr = CCArray:create()
		-- local delayTime = CCDelayTime:create(0)
		local spwanArr = CCArray:create()
		spwanArr:addObject(CCEaseBackOut:create(CCMoveBy:create(0.15, ccp(-10, 80))))
		spwanArr:addObject(CCFadeTo:create(0.15, 255))
		-- sequenceArr:addObject(delayTime)
		sequenceArr:addObject(CCSpawn:create(spwanArr))

		npcUi:stopAllActions();
		npcUi:runAction(CCSequence:create(sequenceArr));
	end
end

function ShareFourStarPanel:runLevelNumAction()
	local levelIdPosUI = self.ui:getChildByName("levelNumPos")
	levelIdPosUI:setOpacity(0)
	if self.levelId then 
		local levelIdUI = self.ui:getChildByName("levelNum")
		levelIdUI:setOpacity(0)
		levelIdUI:setText(tostring(self.levelId))
		levelIdUI:setAnchorPointCenterWhileStayOrigianlPosition()
		
		local pos = levelIdPosUI:getPosition()
		levelIdUI:setPosition(ccp(pos.x+10, pos.y-80))

		local sequenceArr = CCArray:create()
		-- local delayTime = CCDelayTime:create(0)
		local spwanArr = CCArray:create()
		spwanArr:addObject(CCEaseBackOut:create(CCMoveBy:create(0.15, ccp(-10, 80))))
		spwanArr:addObject(CCFadeTo:create(0.15, 255))
		-- sequenceArr:addObject(delayTime)
		sequenceArr:addObject(CCSpawn:create(spwanArr))


		levelIdUI:stopAllActions();
		levelIdUI:runAction(CCSequence:create(sequenceArr));
	end
end

function ShareFourStarPanel:runStarGroup1Action()
	local starGroup1 = self.ui:getChildByName("starGroup1")
	if starGroup1 then 
		local starGroup1Table = {}
		for i=1,8 do
			local smallYellowStar = {}
			smallYellowStar.ui = starGroup1:getChildByName("star"..i)
			smallYellowStar.ui:setOpacity(0)
			table.insert(starGroup1Table, smallYellowStar)
		end

		for i,v in ipairs(starGroup1Table) do
			local sequenceArr = CCArray:create()
			local delayTime = CCDelayTime:create(0.9)
			local fadeTo = CCFadeTo:create(0.15, 255)
			sequenceArr:addObject(delayTime)
			sequenceArr:addObject(fadeTo)
			v.ui:stopAllActions();
			v.ui:runAction(CCSequence:create(sequenceArr));
		end
	end
end

function ShareFourStarPanel:runStarGroup2Action()
	local starGroup2 = self.ui:getChildByName("starGroup2")
	if starGroup2 then 
		local starGroup2Table = {}
		for i=1,4 do
			local yellowStar = {}
			yellowStar.ui = starGroup2:getChildByName("star"..i)
			yellowStar.ui:setOpacity(0)
			yellowStar.endPos = yellowStar.ui:getPosition()
			if i==1 then 
				yellowStar.ui:setPosition(ccp(yellowStar.endPos.x+50, yellowStar.endPos.y-20))
				yellowStar.moveByX = -50
				yellowStar.moveByY = 20
			elseif i==2 then 
				yellowStar.ui:setPosition(ccp(yellowStar.endPos.x+5, yellowStar.endPos.y-10))
				yellowStar.moveByX = -5
				yellowStar.moveByY = 10
			elseif i==3 then 
				yellowStar.ui:setPosition(ccp(yellowStar.endPos.x-5, yellowStar.endPos.y-15))
				yellowStar.moveByX = 5
				yellowStar.moveByY = 15
			elseif i==4 then 
				yellowStar.ui:setPosition(ccp(yellowStar.endPos.x-10, yellowStar.endPos.y-20))
				yellowStar.moveByX = 10
				yellowStar.moveByY = 20
			end

			table.insert(starGroup2Table, yellowStar)
		end
		for i,v in ipairs(starGroup2Table) do
			local sequenceArr = CCArray:create()
			local delayTime = CCDelayTime:create(0.3 + 0.15*(i-1))
			local spwanArr = CCArray:create()
			spwanArr:addObject(CCMoveBy:create(0.2, ccp(v.moveByX, v.moveByY)))
			spwanArr:addObject(CCFadeTo:create(0.3, 255))
			sequenceArr:addObject(delayTime)
			sequenceArr:addObject(CCSpawn:create(spwanArr))

			v.ui:stopAllActions();
			v.ui:runAction(CCSequence:create(sequenceArr));
		end
	end
end

function ShareFourStarPanel:runStarGroup3Action()
	local starGroup3 = self.ui:getChildByName("starGroup3")
	if starGroup3 then 
		local starGroup3Table = {}
		for i=1,5 do
			local whiteStar = {}
			whiteStar.ui = starGroup3:getChildByName("star"..i)
			whiteStar.ui:setAnchorPointCenterWhileStayOrigianlPosition()
			whiteStar.ui:setOpacity(0)
			
			if i==1 then 
				whiteStar.delayTime = 0.8
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==2 then 
				whiteStar.delayTime = 1.2
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==3 then 
				whiteStar.delayTime = 0.8
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==4 then 
				whiteStar.delayTime = 1.0
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==5 then
				whiteStar.delayTime = 1.2
				whiteStar.oriScale = whiteStar.ui:getScale()
			end
			whiteStar.ui:setScale(0)
			table.insert(starGroup3Table, whiteStar)
		end

		for i,v in ipairs(starGroup3Table) do
			local sequenceArr = CCArray:create()
			local delayTime = CCDelayTime:create(v.delayTime)
			local spwanArr1 = CCArray:create()
			local spwanArr2 = CCArray:create()
			local tempTime = 0.4
			spwanArr1:addObject(CCFadeTo:create(tempTime, 255))
			spwanArr1:addObject(CCScaleTo:create(tempTime, v.oriScale))
			spwanArr1:addObject(CCRotateBy:create(tempTime*3, 270))
			spwanArr2:addObject(CCFadeTo:create(tempTime, 0))
			spwanArr2:addObject(CCScaleTo:create(tempTime, 0))
			spwanArr2:addObject(CCRotateBy:create(tempTime*3, 270))

			sequenceArr:addObject(delayTime)
			sequenceArr:addObject(CCSpawn:create(spwanArr1))
			sequenceArr:addObject(CCSpawn:create(spwanArr2))
			
			v.ui:stopAllActions();
			v.ui:runAction(CCSequence:create(sequenceArr));
		end
	end
end

function ShareFourStarPanel:runCircleLightAction()
	local circleLightUi = self.ui:getChildByName("circleLightBg")
	if circleLightUi then 
		parentUiPos = circleLightUi:getPosition()
		local circle = circleLightUi:getChildByName("bg2")
		circle:setVisible(false)
		local bg = circleLightUi:getChildByName("bg")
		local posAdjust = circleLightUi:getPosition()
		bg:setAnchorPointCenterWhileStayOrigianlPosition(posAdjust)
		bg:setOpacity(0)
		local sequenceArr = CCArray:create()
		sequenceArr:addObject(CCDelayTime:create(0.7))
		sequenceArr:addObject(CCFadeTo:create(0.1, 255))

		bg:stopAllActions()
		bg:runAction(CCSequence:create(sequenceArr))
		bg:runAction((CCRepeatForever:create(CCRotateBy:create(0.1, 6))))

		local light = circleLightUi:getChildByName("bg1")
		light:setAnchorPointCenterWhileStayOrigianlPosition()
		light:setOpacity(0)
		local sequenceArr1 = CCArray:create()
		sequenceArr1:addObject(CCDelayTime:create(0.7))
		local function fadeCallBack()
			light:setOpacity(50)
		end
		sequenceArr1:addObject(CCCallFunc:create(fadeCallBack))
		sequenceArr1:addObject(CCScaleTo:create(0.7, 4.5))
		light:stopAllActions()
		light:runAction(CCSequence:create(sequenceArr1))
	end
end

function ShareFourStarPanel:getShareLinkTitleMessage( ... )	
	local title = Localization:getInstance():getText("show_new_title80")
	local message = Localization:getInstance():getText("show_new_text80",{ num=self.levelId })

	return title,message
end

--override
function ShareFourStarPanel:onShareBtnTapped()

	if ShareUtil:getConfig(self.config.id) ~= nil then
		self:sendShareLinkByConfig(self.config.id)
	else
		local function endCallback()
			self:sendShareImage()
		end
		ShareManager:createFourStarShareImg(endCallback, self.levelId)
	end
end

function ShareFourStarPanel:create(shareId)
	local panel = ShareFourStarPanel.new()
	panel:loadRequiredResource("ui/NewSharePanel.json")
	panel.ui = panel:buildInterfaceGroup('ShareFourStarPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end