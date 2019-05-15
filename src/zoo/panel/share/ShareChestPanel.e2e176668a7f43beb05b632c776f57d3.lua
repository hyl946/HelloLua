require 'zoo.panel.share.ShareBasePanel'

ShareChestPanel = class(ShareBasePanel)

function ShareChestPanel:ctor()
	
end

function ShareChestPanel:init()
	ShareBasePanel.init(self)

	self:initChest()
	self:runChestAction()
	self:runChestUpAction()
	self:runChestLightAction()
	self:runChestUpOpenAction()
	self:runNpcAction()

	self:runCircleLightAction()
	self:runStarParticle()
	self:runStarGroup3Action()
end

function ShareChestPanel:getShareTitleName()
	return Localization:getInstance():getText(self.shareTitleKey,{})
end


function ShareChestPanel:initChest()
	self.chestUI = self.ui:getChildByName("chest")
	self.chestLight = self.chestUI:getChildByName("chestLight")
	self.chestLight:setOpacity(0)
	self.chestUp = self.chestUI:getChildByName("chestUp")
	self.chestUpOpen = self.chestUI:getChildByName("chestUpOpen")
	self.chestUpOpen:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.3))
	self.chestUpOpen:setOpacity(0)
end

function ShareChestPanel:runChestAction()
	local oriPos = self.chestUI:getPosition()
	self.chestUI:setPosition(ccp(oriPos.x, oriPos.y + 200))
	local sequenceArr = CCArray:create()
	sequenceArr:addObject(CCDelayTime:create(0.1))
	sequenceArr:addObject(CCEaseBackOut:create(CCMoveBy:create(0.2, ccp(0, -200))))
	sequenceArr:addObject(CCRotateBy:create(0.05, -1))
	sequenceArr:addObject(CCRotateBy:create(0.05, 2))
	sequenceArr:addObject(CCRotateBy:create(0.05, -1))

	self.chestUI:stopAllActions()
	self.chestUI:runAction(CCSequence:create(sequenceArr))
end

function ShareChestPanel:runChestUpAction()
	local sequenceArr = CCArray:create()
	sequenceArr:addObject(CCDelayTime:create(0.35))
	sequenceArr:addObject(CCFadeTo:create(0.1))

	self.chestUp:stopAllActions()
	self.chestUp:runAction(CCSequence:create(sequenceArr))
end

function ShareChestPanel:runChestLightAction()
	local sequenceArr = CCArray:create()
	sequenceArr:addObject(CCDelayTime:create(0.4))
	sequenceArr:addObject(CCFadeTo:create(0.01, 255))
	sequenceArr:addObject(CCFadeTo:create(1, 0))

	self.chestLight:stopAllActions()
	self.chestLight:runAction(CCSequence:create(sequenceArr))
end

function ShareChestPanel:runChestUpOpenAction()
	local sequenceArr = CCArray:create()
	sequenceArr:addObject(CCDelayTime:create(0.38))
	sequenceArr:addObject(CCFadeTo:create(0.01, 255))
	sequenceArr:addObject(CCScaleTo:create(0.1, 1.03, 1.05))
	sequenceArr:addObject(CCScaleTo:create(0.05, 1, 1))

	self.chestUpOpen:stopAllActions()
	self.chestUpOpen:runAction(CCSequence:create(sequenceArr))
end

function ShareChestPanel:runNpcAction()
	local npcUi = self.ui:getChildByName("npc")
	if npcUi then
		npcUi:setOpacity(0)
		local oriPos = npcUi:getPosition()
		npcUi:setPosition(ccp(oriPos.x, oriPos.y-350))
		local spwanArr = CCArray:create()
		spwanArr:addObject(CCEaseBackOut:create(CCMoveBy:create(0.2, ccp(0, 350))))
		spwanArr:addObject(CCFadeTo:create(0.2, 255))

		npcUi:stopAllActions();
		npcUi:runAction(CCSpawn:create(spwanArr));
	end
end

function ShareChestPanel:runCircleLightAction()
	local circleLightUi = self.ui:getChildByName("circleLightBg")
	if circleLightUi then 
		parentUiPos = circleLightUi:getPosition()
		local bg = circleLightUi:getChildByName("bg")
		local posAdjust = circleLightUi:getPosition()
		bg:setAnchorPointCenterWhileStayOrigianlPosition(ccp(posAdjust.x,posAdjust.y+130))
		bg:setOpacity(0)
		local sequenceArr = CCArray:create()
		sequenceArr:addObject(CCDelayTime:create(0.2))
		sequenceArr:addObject(CCFadeTo:create(0.1, 255))

		bg:stopAllActions()
		bg:runAction(CCSequence:create(sequenceArr))
		bg:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, 6)))

		local light = circleLightUi:getChildByName("bg1")
		light:setAnchorPointCenterWhileStayOrigianlPosition()
		light:setOpacity(0)
		local sequenceArr1 = CCArray:create()
		sequenceArr1:addObject(CCDelayTime:create(0.2))
		local function fadeCallBack()
			light:setOpacity(50)
		end
		sequenceArr1:addObject(CCCallFunc:create(fadeCallBack))
		sequenceArr1:addObject(CCScaleTo:create(0.7, 4.5))
		light:stopAllActions()
		light:runAction(CCSequence:create(sequenceArr1))

		local circle = circleLightUi:getChildByName("bg2")
		circle:setAnchorPointCenterWhileStayOrigianlPosition()
		circle:setOpacity(0)
		local sequenceArr2 = CCArray:create()
		sequenceArr2:addObject(CCDelayTime:create(0.2))
		local function fadeCallBack()
			circle:setOpacity(255)
		end
		sequenceArr2:addObject(CCCallFunc:create(fadeCallBack))
		local spwanArr = CCArray:create()
		spwanArr:addObject(CCScaleTo:create(0.5, 4.5))
		spwanArr:addObject(CCFadeOut:create(0.5))
		sequenceArr2:addObject(CCSpawn:create(spwanArr))
		circle:stopAllActions()
		circle:runAction(CCSequence:create(sequenceArr2))
	end
end

function ShareChestPanel:runStarGroup3Action()
	local starGroup3 = self.ui:getChildByName("starGroup3")
	if starGroup3 then 
		local starGroup3Table = {}
		for i=1,5 do
			local whiteStar = {}
			whiteStar.ui = starGroup3:getChildByName("star"..i)
			whiteStar.ui:setAnchorPointCenterWhileStayOrigianlPosition()
			whiteStar.ui:setOpacity(0)
			
			if i==1 then 
				whiteStar.delayTime = 0.3
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==2 then 
				whiteStar.delayTime = 0.9
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==3 then 
				whiteStar.delayTime = 1.1
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==4 then 
				whiteStar.delayTime = 0.5
				whiteStar.oriScale = whiteStar.ui:getScale()
			elseif i==5 then 
				whiteStar.delayTime = 0.6
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

function ShareChestPanel:runStarParticle()
	if not _G.__use_low_effect then
		local function addParticle()
			local particle = ParticleSystemQuad:create("share/star1.plist")
			particle:setPosition(ccp(370,-480))
			local scale = 1.2
			if _G.__use_small_res then 
				scale = 1.2/0.625
			end
			particle:setScale(scale)
			local childIndex = self.ui:getChildIndex(self.ui:getChildByName("npc"))
			self.ui:addChildAt(particle, childIndex)	
		end 
		self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(addParticle)))
	end
end

function ShareChestPanel:create(shareId)
	local panel = ShareChestPanel.new()
	panel:loadRequiredResource("ui/NewSharePanel.json")
	panel.ui = panel:buildInterfaceGroup('ShareChestPanel')
	panel.shareId = shareId
	panel:init()
	return panel
end