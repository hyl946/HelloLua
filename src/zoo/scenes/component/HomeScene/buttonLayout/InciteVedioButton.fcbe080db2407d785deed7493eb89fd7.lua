
InciteVedioButton = class(BaseUI)

function InciteVedioButton:ctor()
end

function InciteVedioButton:init()
	self.ui	= ResourceManager:sharedInstance():buildGroup("treeInciteVedioBtn")
	BaseUI.init(self, self.ui)

    local version = InciteManager:getSceneUIVersion(EntranceType.kPassLevel)
    local isNewUi = version and version>=3
    self.isNewUi = isNewUi
    print("self.isNewUi",version,self.isNewUi)

    if not isNewUi then
        print("self.isNewUi 000",version,self.isNewUi)
        FrameLoader:loadArmature('skeleton/incite_homescene_star')
    else
        print("self.isNewUi 111",version,self.isNewUi)
        FrameLoader:loadArmature('skeleton/VideoAdIcon')
    end

	self.wrapper = LayerColor:create()
    self.wrapper:setColor(ccc3(255,0,0))
    self.wrapper:setOpacity(0)
    self.wrapper:setContentSize(CCSizeMake(133, 143))
    self.wrapper:setPosition(ccp(-133/2, 0))
	self.wrapper:setTouchEnabled(true, 0, true)
	self.ui:addChild(self.wrapper)

	local function update()
        if self.isDisposed then
        	if self.schedule then
        		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
				self.schedule = nil
			end
        	return 
        end

        local time = InciteManager:getRemaindTime()
        local nextCd = InciteManager:getRewardCountdown()
        local showDot = time > 0 and nextCd <= 0

        self.numTip:setVisible(showDot)
        if showDot then
            if self.light then
                self.light:runAction(CCRepeatForever:create(CCRotateBy:create(12, 360)))
            end
            if self.animNode then
                if not isNewUi then
                    self.animNode:setVisible(true)
                elseif self.animNode.isStop then
                    self.animNode:playByIndex(0)
                    self.animNode.isStop = false
                end
            end
        else
            if self.light then
                self.light:stopAllActions()
            end

             if self.animNode then
                if not isNewUi then
                    self.animNode:setVisible(false)
                else
                    self.animNode.isStop = true
                    self.animNode:gotoAndStopByIndex(0)
                end
            end
        end
		
    	self:setRemaind(time)
    end
    
    self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)

    if not isNewUi then
        local light = self.ui:getChildByName("light")
        light:removeFromParentAndCleanup(false)

        local ph = self.ui:getChildByName("ph")
        local pos = ph:getPosition()
        local size = ph:getGroupBounds().size

        ph:setVisible(false)

        local clipping = SimpleClippingNode:create()
        clipping:setContentSize(CCSizeMake(size.width, size.height))
        clipping:setRecalcPosition(true)
        clipping:setAnchorPoint(ccp(0, 1))
        clipping:ignoreAnchorPointForPosition(false)
        clipping:setPosition(ccp(pos.x, pos.y))
        clipping:addChild(light)

        light:setAnchorPointCenterWhileStayOrigianlPosition()
        light:setScale(1.5)
        light:setOpacity(160)
        light:setPosition(ccp(size.width / 2, size.height / 2))

        self.light = light

        self.ui:addChildAt(clipping, 1)

        self.animNode = ArmatureNode:create("incite_homescene_star")
        self.animNode:setAnchorPoint(ccp(0, 1))
        self.animNode:setScale(0.8)
        self.animNode:setPosition(ccp(15, 95))
        self.ui:addChild(self.animNode)
        self.animNode:playByIndex(0)
    else
        for _,name in ipairs({"light", "ph", "play", "iconLabel"}) do
            self.ui:getChildByName(name):setVisible(false)
        end
        local t = self.ui:getChildByName("t")
        -- t:setScale(0.8)
        t:setPositionX(-46)

        self.animNode = ArmatureNode:create("VideoAd/icon")

        self.animNode:setAnchorPoint(ccp(0, 1))
        -- self.animNode:setScale(0.8)
        self.animNode:setPosition(ccp(-48, 100))
        self.ui:addChildAt(self.animNode, 0)
        self.animNode:playByIndex(0)
    end

    self.numTip = getRedNumTip()
    self.numTip:setPositionXY(41, 99)

    if isNewUi then
        -- self.numTip:setScale(0.8)
        local num = self.animNode:getSlot("reddot")
        local sprite = Sprite:createEmpty()
        self.numTip:setPositionXY(18, -20)
        sprite:addChild(self.numTip)
        num:setDisplayImage(sprite.refCocosObj)
    else
        self.ui:addChild(self.numTip)
    end


    update()
end

function InciteVedioButton:dispose( ... )
    BaseUI.dispose(self)

    if not self.isNewUi then
        FrameLoader:unloadArmature('skeleton/incite_homescene_star', true)
    end
end

function InciteVedioButton:setRemaind( time )
    self.numTip:setNum(time)
end

function InciteVedioButton:create()
	local btn = InciteVedioButton.new()
	btn:init()
	return btn
end