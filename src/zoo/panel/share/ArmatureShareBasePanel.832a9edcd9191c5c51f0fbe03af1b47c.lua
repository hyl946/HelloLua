require 'zoo.panel.share.ShareBasePanel'
ArmatureShareBasePanel = class(ShareBasePanel)

local ArmatureSourceRefCount = {}

function ArmatureShareBasePanel:ctor()

end

function ArmatureShareBasePanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
    --初始化文案内容
    FrameLoader:loadArmature(armatureSource, skeletonName, textureName)

    local refCount = ArmatureSourceRefCount[armatureSource] or 0
    ArmatureSourceRefCount[armatureSource] = refCount + 1

    self.armatureSource = armatureSource
    self.armatureName = armatureName
    self.playPaperGroup = playPaperGroup
    self.ui = self:buildInterfaceGroup('ArmatureAnimSharePanel')
    ShareBasePanel.init(self)
    
end

function ArmatureShareBasePanel:initUI()
    self:initBg()

    -- self.ui:runAction(CCCallFunc:create(function() self:initBg() end))

    self.paperGroup1 = self.ui:getChildByName('paperGroup1')
    self.paperGroup2 = self.ui:getChildByName('paperGroup2')

    if not self.playPaperGroup then
        self.paperGroup1:setVisible(false)
        self.paperGroup2:setVisible(false)
    end

    local ph = self.ui:getChildByName('ph')
    ph:setVisible(false)
    self.node = ArmatureNode:create(self.armatureName, true)
    self.node:setScale(1.15)
    self.ui:addChildAt(self.node, ph:getZOrder())
    self.node:setPosition(ccp(ph:getPositionX(), ph:getPositionY()))

    self:initShareTitle(self:getShareTitleName())
    self:initShareBtn(self.shareType)
    self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

end


function ArmatureShareBasePanel:onEnterHandler(event)
    ShareBasePanel.onEnterHandler(self, event)
    if event == 'enter' then
        self:runAnimation()
    end
end

function ArmatureShareBasePanel:runAnimation()
    self.node:playByIndex(0, 1)
    if self.playPaperGroup then
        self.paperGroup1:setVisible(true)
        self.paperGroup2:setVisible(true)
        self:runPaperGroupAction(self.paperGroup1)
        self:runPaperGroupAction(self.paperGroup2)
    end
end

function ArmatureShareBasePanel:dispose()
    if self.isDisposed then return end
    ShareBasePanel.dispose(self)

    local unload = function()
        local refCount = ArmatureSourceRefCount[self.armatureSource] or 0
        refCount = refCount - 1
        if refCount <= 0 then
            ArmatureSourceRefCount[self.armatureSource] = nil
            FrameLoader:unloadArmature(self.armatureSource, true)
        else
            ArmatureSourceRefCount[self.armatureSource] = refCount
        end
    end
    setTimeOut(unload, 0)
end

function ArmatureShareBasePanel:initShareTitle(titleName)
    if _G.isLocalDevelopMode then printx(0, titleName) end 
    local slot = self.node:getSlot('txt')
    local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    -- text.refCocosObj:release()
    local sprite = Sprite:createEmpty()
    -- sprite:setCascadeOpacityEnabled(true)
    -- sprite:retain()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)

end

function ArmatureShareBasePanel:runPaperGroupAction(paperGroupUi)
    if paperGroupUi then 
        local paperGroup = {}
        for i=1,5 do
            local paper = {}
            paper.ui = paperGroupUi:getChildByName("paper"..i)
            paper.ui:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
            if i==1 then 
                paper.xDelta = 200
            elseif i==2 then 
                paper.xDelta = 100
            elseif i==3 then 
                paper.xDelta = 50
            elseif i==4 then 
                paper.xDelta = -100
            elseif i==5 then 
                paper.xDelta = -200
            end
            paper.yDelta = math.random(-220,-300)
            paper.height = math.random(30,50)
            paper.time = math.random(14,18)/10
            paper.ui:setOpacity(0)
            table.insert(paperGroup, paper)
        end

        for i,v in ipairs(paperGroup) do
            local sequenceArr = CCArray:create()
            local delayTime = CCDelayTime:create(v.delayTime)
            local spwanArr = CCArray:create()
            local tempTime = 0.4
            local fromPostion = v.ui:getPosition()
            --spwanArr:addObject(CCFadeTo:create(1.5, 0))
            local bezierConfig = ccBezierConfig:new()
            bezierConfig.controlPoint_1 = ccp(fromPostion.x +  v.xDelta/4, fromPostion.y +  v.height*8)
            bezierConfig.controlPoint_2 = ccp(fromPostion.x +  v.xDelta/2, fromPostion.y +  v.height*5)
            bezierConfig.endPosition = ccp(v.xDelta, v.yDelta)
            local bezierAction_1 = CCBezierTo:create(v.time, bezierConfig)

            spwanArr:addObject(bezierAction_1)
            sequenceArr:addObject(delayTime)
            sequenceArr:addObject(CCFadeTo:create(0, 255))
            sequenceArr:addObject(CCSpawn:create(spwanArr))
            local function hidePaper()
                v.ui:setVisible(false)
            end
            sequenceArr:addObject(CCCallFunc:create(hidePaper))
            
            v.ui:stopAllActions();
            v.ui:runAction(CCSequence:create(sequenceArr));
            v.ui:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, 30)))
        end
    end
end

function ArmatureShareBasePanel:popoutShowTransition()
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local scale = vs.height/1280
    self:setScale(scale)
    self:setPositionY(0)
    self:setPositionX(0-(960*self:getScale()-720)/2)

    self._bgLayer:setScale(math.max(1, 1/scale))
    self._bgLayer:setPosition(self._bgLayer:getParent():convertToNodeSpace(ccp(0, 0)))

    local pos = ccp(vo.x + vs.width, vo.y+vs.height)
    pos = self.ui:convertToNodeSpace(pos)
    self.closeBtnRes:setPosition(ccp(pos.x-50, pos.y-50))
end

function ArmatureShareBasePanel:initBg()
    local wSize = Director:sharedDirector():getWinSize()
    local bg = self.ui:getChildByName('bg')
    local gradient = LayerGradient:create()
    gradient:setStartColor(ccc3(0, 0, 0))
    gradient:setEndColor(ccc3(0, 0, 0))
    gradient:setStartOpacity(200)
    gradient:setEndOpacity(200)
    gradient:ignoreAnchorPointForPosition(false)
    gradient:setAnchorPoint(ccp(0, 0))
    gradient:setContentSize(CCSizeMake(wSize.width, wSize.height))
    gradient:setPosition(ccp(0, 0))

    bg:getParent():addChildAt(gradient, bg:getZOrder())
    bg:removeFromParentAndCleanup(true) 

    self._bgLayer = gradient

    self.closeBtnRes = self.ui:getChildByName("closeBtn")
    local btnSize = self.closeBtnRes:getGroupBounds().size
    
    -- self.closeBtnRes:setPosition(ccp(pos.x + size.width - btnSize.width / 2, pos.y + size.height - btnSize.height / 2))
    local function onCloseBtnTapped()
        self:removePopout()
    end
    self.closeBtnRes:setTouchEnabled(true)
    self.closeBtnRes:setButtonMode(true)
    self.closeBtnRes:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)
end

