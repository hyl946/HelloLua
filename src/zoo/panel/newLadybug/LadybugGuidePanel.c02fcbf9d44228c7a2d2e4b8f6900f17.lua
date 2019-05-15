local function createMask(posGrp, radius, cubeWidth, cubeHeight, clickCallback, force, clickOther, opacity)
	if force == nil then
		force = false
	end
	local opacity = opacity or 200.0 
	local touchDelay = touchDelay or 0.5
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))

	for k, pos in pairs(posGrp) do
		local node

		if radius then

			node = Sprite:createWithSpriteFrameName("circle0000")
			radius = radius or 1
			node:setScale(radius)
		end

		if cubeWidth and cubeHeight then
			node = LayerColor:create()
			node:changeWidthAndHeight(cubeWidth, cubeHeight)
			node:ignoreAnchorPointForPosition(false)
			node:setAnchorPoint(ccp(0.5, 0.5))
		end


		node:setPosition(ccp(pos.x, pos.y))
		local blend = ccBlendFunc()
		blend.src = GL_ZERO
		blend.dst = GL_ONE_MINUS_SRC_ALPHA
		node:setBlendFunc(blend)
		mask:addChild(node)
	end

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

	local hitRange = 80
	local function onTouch(evt)
		if force then
			local touchPos = trueMaskLayer:convertToNodeSpace(evt.globalPosition)
			for index, pos in pairs(posGrp) do
				local dist2 = (pos.x - touchPos.x)*(pos.x - touchPos.x) + (pos.y - touchPos.y)*(pos.y - touchPos.y)
				if dist2 < hitRange*hitRange then
					if clickCallback then clickCallback() end
					return 
				end
			end
			if clickOther then
				clickOther()
			end
		else
			if clickCallback then clickCallback() end
		end
	end
	local function beginSetTouch() trueMaskLayer:ad(DisplayEvents.kTouchTap, onTouch) end
	local arr = CCArray:create()
	trueMaskLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	trueMaskLayer.setFadeIn = function(maskDelay, maskFade)
		layerSprite:setOpacity(0)
		layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeIn:create(maskFade)))
	end	
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end



local GuideOnePanel = class(Layer)


function GuideOnePanel:init(origin, size, onClose)
	self.onClose = onClose
	self:initLayer()

	local action = {
    	text = '', 
		panType = "up", panAlign = "winY", panPosY = origin.y + 70,
		maskDelay = 0, maskFade = 0 ,panDelay = 0, touchDelay = 1,
		panelName = 'guide_dialogue_999_2'
    }
    local panel = GameGuideUI:panelS(nil, action, '点击任意处继续')

    local pos = ccp(
    	origin.x + size.width/2,
    	origin.y + size.height/2
    )

    local mask = createMask({pos}, nil, size.width, size.height, function ( ... )
    	if self.isDisposed then return end
    	self:close()
    end, nil, nil, 0)
    mask:ignoreAnchorPointForPosition(false)
    mask:setAnchorPoint(ccp(0, 0))
    mask:setPosition(ccp(0, 0))

    self:addChild(mask)
    self:addChild(panel)

	local wSize = CCDirector:sharedDirector():getWinSize()
    self:setPosition(ccp(0, -wSize.height))

    local visibleSize =  Director:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local x = (visibleSize.width - panel:getGroupBounds().size.width)/2 + visibleOrigin.x
    panel:setPositionX(x)
end


function GuideOnePanel:popout()
	PopoutManager:sharedInstance():add(self, false, false)
end


function GuideOnePanel:close( ... )
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
	if self.onClose then
		self.onClose()
	end
end




local GuideTowPanel = class(Layer)


function GuideTowPanel:init(pos)
	self:initLayer()
	local action = {
    	text = '', 
		panType = "up", panAlign = "winY", panPosY = pos.y - 100,
		maskDelay = 0, maskFade = 0 ,panDelay = 0, touchDelay = 1,
		panelName = 'guide_dialogue_999_2'
    }
    local panel = GameGuideUI:panelS(nil, action, '点击任意处继续')

	local wSize = CCDirector:sharedDirector():getWinSize()


    local mask = createMask({pos}, 1.2, nil, nil, function ( ... )
    	if self.isDisposed then return end
    	self:close()
    end)
    mask:ignoreAnchorPointForPosition(false)
    mask:setAnchorPoint(ccp(0, 0))
    mask:setPosition(ccp(0, 0))

    self:addChild(mask)
    self:addChild(panel)

    self:setPosition(ccp(0, -wSize.height))
end

function GuideTowPanel:popout()
	PopoutQueue:sharedInstance():push(self, false, false)
end


function GuideTowPanel:close( ... )
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end
























local LadybugGuidePanel = {}

function LadybugGuidePanel:createGuideOne(...)
    local panel = GuideOnePanel.new()
    panel:init(...)
    return panel
end

function LadybugGuidePanel:createGuideTwo(...)
    local panel = GuideTowPanel.new()
    panel:init(...)
    return panel
end


return LadybugGuidePanel
	