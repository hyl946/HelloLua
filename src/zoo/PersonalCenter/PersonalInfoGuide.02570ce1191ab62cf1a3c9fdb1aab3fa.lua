-- local function copyNodeTree( node )
-- 	local ret = node:clone()
-- 	local anchorPoint = node:getAnchorPoint()
-- 	local pos = node:getPosition()
-- 	local sx, sy = node:getScaleX(), node:getScaleY()
-- 	ret:setAnchorPoint(ccp(anchorPoint.x, anchorPoint.y))
-- 	ret:setPosition(ccp(pos.x, pos.y))
-- 	ret:setScaleX(sx)
-- 	ret:setScaleY(sy)
-- 	ret:setVisible(node:isVisible())
-- 	for _, v in ipairs(node:getChildrenList()) do
-- 		local child = copyNodeTree(v)
-- 		ret:addChild(child)
-- 	end
-- 	return ret
-- end

-- local function toMask( sp, width, height )
-- 	local clipNode = ClippingNode.new(CCClippingNode:create(sp.refCocosObj))
-- 	clipNode:setAlphaThreshold(0.32)
-- 	sp:setPosition(ccp(0, 0))
-- 	sp:dispose()
-- 	local l = LayerColor:createWithColor(ccc3(255, 0, 0), width, height)
-- 	l:setAnchorPoint(ccp(0.5, 0.5))
-- 	l:ignoreAnchorPointForPosition(false)
-- 	clipNode:addChild(l)
-- 	clipNode:setPosition(ccp(width/2, height/2))
-- 	local layer = CCRenderTexture:create(width, height, kCCTexture2DPixelFormat_RGBA8888, 0x88F0)
-- 	layer:setPosition(ccp(width / 2, height / 2))
-- 	layer:begin()
-- 	clipNode:visit()
-- 	layer:endToLua()
-- 	if __WP8 then layer:saveToCache() end
-- 	clipNode:dispose()
-- 	local blend = ccBlendFunc()
-- 	blend.src = GL_ZERO
-- 	blend.dst = GL_ONE_MINUS_SRC_ALPHA
-- 	layer:getSprite():setBlendFunc(blend)
-- 	return CocosObject.new(layer)
-- end

local function skipButton(skipText, onTouch)
	local layer = LayerColor:create()
	layer:setOpacity(0)
	layer:changeWidthAndHeight(200, 80)
	layer:ignoreAnchorPointForPosition(false)
	-- layer:setPosition(ccp(0, vOrigin.y + vSize.height - 50))
	layer:setTouchEnabled(true, 0, true)
	layer:ad(DisplayEvents.kTouchTap, onTouch)
	layer:setOpacity(0)
	layer:setAnchorPoint(ccp(0, 0))
	layer:setColor(ccc3(136, 255, 136))


	local text = TextField:create(skipText, nil, 32)
	text:setPosition(ccp(50, 25))
	text:setColor(ccc3(136, 255, 136))
	text:setOpacity(0)
	text:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0), CCFadeIn:create(0)))
	text:setAnchorPoint(ccp(0, 0))
	layer:addChild(text)

	return layer
end


local function mask(opacity, touchDelay, position, radius, square, width, height, oval, skipClick, shadowNodes)
	touchDelay = touchDelay or 0
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))



	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	if __WP8 then layer:saveToCache() end

	mask:dispose()

	local layerSprite = layer:getSprite()
	local obj = CocosObject.new(layer)
	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)


	trueMaskLayer:setTouchEnabled(true, 0, true)
	trueMaskLayer:addChild(shadowNodes)
	local function onTouch() GameGuide:sharedInstance():onGuideComplete() end
	local function beginSetTouch() trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) end
	local arr = CCArray:create()
	if not skipClick then
		trueMaskLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	end
	trueMaskLayer.setFadeIn = function(maskDelay, maskFade)

		if playFocusEffect then

			local anchor = layerSprite:getAnchorPoint()
			local anchorPos = ccp(anchor.x*layerSprite:getContentSize().width, anchor.y*layerSprite:getContentSize().height)

			local scaleTime = 0.3
			local oScaleX, oScaleY = layerSprite:getScaleX(), layerSprite:getScaleY()
			layerSprite:setScaleX(oScaleX*10)
			layerSprite:setScaleY(oScaleY*10)

			-- 保持在当前anchor下缩放，目标坐标保持静止的补偿向量
			local function getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return ccp(d_to_a.x*(oScaleX-dScaleX), d_to_a.y*(oScaleY-dScaleY))
			end

			local function getCompensateMove(time, oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				local dir = getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return CCMoveBy:create(time, dir)
			end

			-------------------------------------------------------
			---- 计算补偿位移需要的向量
			local d_to_o = ccp(position.x, position.y)
			local a_to_o = anchorPos
			local d_to_a = ccp(d_to_o.x - a_to_o.x, d_to_o.y - a_to_o.y)
			local action = getCompensateMove(scaleTime, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-- if _G.isLocalDevelopMode then printx(0, d_to_o.x, d_to_o.y, d_to_a.x, d_to_a.y, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY) debug.debug() end
			local compensateDir = getCompensateDir(layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-------------------------------------------------------

			-- anchor不变的情况下，将缩放中心放到目标位置
			layerSprite:setPositionX(layerSprite:getPositionX()-compensateDir.x)
			layerSprite:setPositionY(layerSprite:getPositionY()-compensateDir.y)

			local focusAction = CCSpawn:createWithTwoActions(CCScaleTo:create(scaleTime, oScaleX, oScaleY), action)
			local focusFadeIn = CCSpawn:createWithTwoActions(CCFadeIn:create(maskFade), focusAction)

			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), focusFadeIn))
		else
			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeIn:create(maskFade)))
		end

	end	
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end


local PersonalInfoGuide = {}

local StepOnePanel = class(BasePanel)

function StepOnePanel:create()
    local panel = StepOnePanel.new()
    panel:init()
    return panel
end

function StepOnePanel:init()
	BasePanel.init(self, Layer:create())



	local action = 
    {
        panAlign = "viewY", panPosY = 0,
        panelName = 'guide_dialogue_id_1',
        panDelay = 0.3,
    }

    local panel = GameGuideUI:panelS(nil, action, false)
    self.ui:addChild(panel)

    local vs = Director:sharedDirector():getVisibleSize()

    local scene = HomeScene:sharedInstance()
    local accountBtn 
    if scene and scene.settingButtonUI then
    	accountBtn = scene.settingButtonUI.accountBtn
    end


    if accountBtn and (not accountBtn.isDisposed) then
    	local bounds = accountBtn:getGroupBounds()
    	local pos = ccp(bounds:getMidX(), bounds:getMidY())
    	local width = bounds.size.width
    	panel:setPositionXY(pos.x, pos.y - vs.height)


    	local worldPos = accountBtn:convertToWorldSpace(ccp(0, 0))

    	local revertPos = accountBtn:getPosition()
    	revertPos = ccp(revertPos.x, revertPos.y)

    	local revertParent = accountBtn:getParent()
    	accountBtn:removeFromParentAndCleanup(false)

    	accountBtn:setPosition(worldPos)

    	local hand = GameGuideAnims:handclickAnim(0, 0)
	    self.ui:addChild(hand)
	    hand:setPosition(ccp(worldPos.x, worldPos.y - vs.height))


    	local mask = mask(200, 0, ccp(pos.x + 40, pos.y + 40), nil, false, nil, nil, nil, true, accountBtn)

		self.ui:addChildAt(mask, 0)   
		mask:setPositionY(-vs.height)



		self.cancelGuide = function ( ... )
    		if self.isDisposed then return end
			if accountBtn and (not accountBtn.isDisposed) then
				accountBtn:removeFromParentAndCleanup(false)
				if revertParent and (not revertParent.isDisposed) then
					revertParent:addChild(accountBtn)
				end
				accountBtn:setPosition(revertPos)
			end

			self:_close()
    	end


		local function createTouchBtn( ... )
			-- body
			if self.isDisposed then return end

			local touchTap = Layer:create()
			touchTap:ignoreAnchorPointForPosition(false)
			touchTap:setAnchorPoint(ccp(0.5, 0.5))
			touchTap:changeWidthAndHeight(150, 150)
			touchTap:setTouchEnabled(true)
			touchTap:ad(DisplayEvents.kTouchTap, function ( ... )

				if self.isDisposed then return end
				if accountBtn and (not accountBtn.isDisposed) then
					PersonalInfoGuide.shouldShowGuideTwo = true
					accountBtn:removeFromParentAndCleanup(false)
					if revertParent and (not revertParent.isDisposed) then
						revertParent:addChild(accountBtn)
					end
					accountBtn:setPosition(revertPos)
					accountBtn.wrapper:dp(DisplayEvent.new(DisplayEvents.kTouchTap))
				end

				self:_close()

			end)
			touchTap:setPositionXY(pos.x, pos.y - vs.height)
			self.ui:addChild(touchTap)
		end
		setTimeOut(createTouchBtn, 0)
    end


end

function StepOnePanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function StepOnePanel:popout(cb)

    DcUtil:UserTrack({category='ui', sub_category="my_card_guide"}, true)

	local ori_Origin = CCDirector:sharedDirector():ori_getVisibleOrigin()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	self:setPositionY(- origin.y + ori_Origin.y)

	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = false



	local skipBtn = skipButton('跳过', function ( ... )
		PersonalInfoGuide.shouldShowGuideTwo = false
		GameGuide:sharedInstance():onGuideComplete()
    	if self.cancelGuide then
    		self.cancelGuide()
    	end
    end)

    self.ui:addChild(skipBtn)

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kLEFT, -35)
	layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kTOP,  -10)


	if cb then cb() end
end



local StepTwoPanel = class(BasePanel)

function StepTwoPanel:create()
    local panel = StepTwoPanel.new()
    panel:init()
    return panel
end

function StepTwoPanel:init()
	BasePanel.init(self, Layer:create())



	local action = 
    {
        panAlign = "viewY", panPosY = 0,
        panelName = 'guide_dialogue_id_2',
        panDelay = 0.3,
    }

    local panel = GameGuideUI:panelS(nil, action, false)
    self.ui:addChild(panel)

    local vs = Director:sharedDirector():getVisibleSize()

    local scene = HomeScene:sharedInstance()


    if PersonalInfoGuide.panel and (not PersonalInfoGuide.panel.isDisposed) then
   		local editBtn = PersonalInfoGuide.panel.editBtnUI

   		if editBtn then

	    	local bounds = editBtn:getGroupBounds()
	    	local pos = ccp(bounds:getMidX(), bounds:getMidY())
	    	local width = bounds.size.width
	    	local height = bounds.size.height
	    	panel:setPositionXY(pos.x - 50, pos.y - vs.height + 20)

	    	local worldPos = editBtn:convertToWorldSpace(ccp(0, 0))

	    	local revertPos = editBtn:getPosition()
	    	revertPos = ccp(revertPos.x, revertPos.y)

	    	local revertParent = editBtn:getParent()
	    	local revertIndex = revertParent:getChildIndex(editBtn)
	    	editBtn:removeFromParentAndCleanup(false)

	    	editBtn:setPosition(worldPos)


	    	local hand = GameGuideAnims:handclickAnim(0, 0)
		    self.ui:addChild(hand)

		    local handPos = editBtn:convertToWorldSpace(ccp(59, -27))
		    hand:setPosition(ccp(handPos.x, handPos.y - vs.height))


	    	local mask = mask(200, 0, ccp(pos.x + width/2, pos.y + height/2), nil, false, nil, nil, nil, true, editBtn)

			self.ui:addChildAt(mask, 0)   
			mask:setPositionY(-vs.height)




			self.cancelGuide = function ( ... )
	    		if self.isDisposed then return end
				if editBtn and (not editBtn.isDisposed) then
					GameGuide:sharedInstance():onGuideComplete()
					editBtn:removeFromParentAndCleanup(false)
					if revertParent and (not revertParent.isDisposed) then
						revertParent:addChildAt(editBtn, revertIndex)
					end
					editBtn:setPosition(revertPos)
				end
				self:_close()
	    	end


			local function createTouchBtn( ... )
				if self.isDisposed then return end
				local touchTap = Layer:create()
				touchTap:ignoreAnchorPointForPosition(false)
				touchTap:setAnchorPoint(ccp(0.5, 0.5))
				touchTap:changeWidthAndHeight(100, 100)
				touchTap:setTouchEnabled(true)
				touchTap:ad(DisplayEvents.kTouchTap, function ( ... )
					if self.isDisposed then return end
					if editBtn and (not editBtn.isDisposed) then
						editBtn:removeFromParentAndCleanup(false)
						if revertParent and (not revertParent.isDisposed) then
							revertParent:addChildAt(editBtn, revertIndex)
						end
						editBtn:setPosition(revertPos)
						editBtn:dp(DisplayEvent.new(DisplayEvents.kTouchTap))

					end
					self:_close()
				end)
				touchTap:setPositionXY(pos.x, pos.y - vs.height)

				self.ui:addChild(touchTap)
			end
			setTimeOut(createTouchBtn, 0)
		end
    end
end

function StepTwoPanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	GameGuide:sharedInstance():onGuideComplete()
end

function StepTwoPanel:popout(cb)
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = false

	local ori_Origin = CCDirector:sharedDirector():ori_getVisibleOrigin()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()
	self:setPositionY(- origin.y + ori_Origin.y)


	local skipBtn = skipButton('跳过', function ( ... )
		PersonalInfoGuide.shouldShowGuideTwo = false
    	if self.cancelGuide then
    		self.cancelGuide()
    	end
    end)

    self.ui:addChild(skipBtn)

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kLEFT, -35)
	layoutUtils.setNodeRelativePos(skipBtn, layoutUtils.MarginType.kTOP,  -10)

	
	if cb then cb() end
end



function PersonalInfoGuide:popGuide( cb , isForce )

	local function doGuide(  )
		if not HomeScene:sharedInstance().settingButtonUI then
			local settingButton = HomeScene:sharedInstance().settingButton
			if settingButton and settingButton.ui then
				settingButton.ui:dp(DisplayEvent.new(DisplayEvents.kTouchTap))
			end
		end
		StepOnePanel:create():popout(cb)
	end 

	local PersonalInfoReward = require 'zoo.PersonalCenter.PersonalInfoReward'
	local function onSuccess( ... )
		print("function PersonalInfoGuide:popGuide onSuccess")
		doGuide()
	end 
	local function onFail( ... )
		print("function PersonalInfoGuide:popGuide onFail")
		-- PopoutQueue:sharedInstance():popAgain(true , PopoutLayerPriority.Guide_PersonalInfoPanel)
		if cb then cb() end
	end 
	PersonalInfoReward:trigger(onSuccess , onFail)
end


function PersonalInfoGuide:popGuideTwo(  )
	StepTwoPanel:create():popout()
	PersonalInfoGuide.shouldShowGuideTwo = false
end



return PersonalInfoGuide