require "zoo.panel.share.sharePanelVerB.ShareBasePanel_B"

local ArmatureSourceRefCount = {}
local _loadArmatureWithRefCount = function(armatureSource)
    local refCount = ArmatureSourceRefCount[armatureSource] or 0
    if refCount <= 0 then 
        FrameLoader:loadArmature(armatureSource, skeletonName, textureName) 
    end
    ArmatureSourceRefCount[armatureSource] = refCount + 1
end

local _unloadArmatureWithRefCount = function(armatureSource)
    local refCount = ArmatureSourceRefCount[armatureSource] or 0
    refCount = refCount - 1
    if refCount <= 0 then
        ArmatureSourceRefCount[armatureSource] = nil
        FrameLoader:unloadArmature(armatureSource, true)
    else
        ArmatureSourceRefCount[armatureSource] = refCount
    end
end


ArmatureShareBasePanel_B = class(ShareBasePanel_B)

function ArmatureShareBasePanel_B:init(armatureSource, skeletonName, textureName, armatureName)
    _loadArmatureWithRefCount(armatureSource)
    self.ui = Layer:create()
    self.armatureSource = armatureSource
    self.armatureName = armatureName

    ShareBasePanel_B.init(self)
end

function ArmatureShareBasePanel_B:initUI()
    ShareBasePanel_B.initBg(self)
    self:initArmature()
    self:initCloseBtn()
    ShareBasePanel_B.initShareBtn(self)
    --self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
end

function ArmatureShareBasePanel_B:initArmature()
    self.armatureNode = ArmatureNode:create(self.armatureName, true)
    self.ui:addChild(self.armatureNode)
end

function ArmatureShareBasePanel_B:initCloseBtn()
    local closeBtn_slot = self.armatureNode:getSlot("closeBtn")
    if not closeBtn_slot then 
        ShareBasePanel_B.initCloseBtn(self)
        return
    end
    
    local closeBtnCC = tolua.cast(closeBtn_slot:getCCDisplay(),"CCSprite")

    local btnSize = closeBtnCC:getContentSize()
    local closeBtnLayer = Layer:create()
    local closeBtnSprite = Sprite:createWithSpriteFrame(closeBtnCC:displayFrame())
    closeBtnLayer:addChild(closeBtnSprite)
    closeBtnLayer:setPosition(ccp(btnSize.width/2, btnSize.height/2))

    closeBtnCC:addChild(closeBtnLayer.refCocosObj)
 
	local function onCloseBtnTapped()
        self:removePopout()
    end
    closeBtnLayer:setTouchEnabled(true)
    closeBtnLayer:setButtonMode(true)
	closeBtnLayer:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

    self.closeBtn_slot = closeBtn_slot
    self.closeBtn = closeBtnLayer
end

function ArmatureShareBasePanel_B:onEnterHandler(event)
    ShareBasePanel_B.onEnterHandler(self, event)
    if event == "enter" then
        self:runAnimation()
    end
end

function ArmatureShareBasePanel_B:runAnimation()
    self.armatureNode:playByIndex(0, 1)
end

function ArmatureShareBasePanel_B:dispose()
    if self.isDisposed then
        return
    end
    ShareBasePanel_B.dispose(self)
    setTimeOut(_unloadArmatureWithRefCount(self.armatureSource), 0)
end

function ArmatureShareBasePanel_B:popoutShowTransition()
    -- local vs = Director:sharedDirector():getVisibleSize()
    -- local vo = Director:sharedDirector():getVisibleOrigin()
    -- local scale = vs.height / 1280
    -- self:setScale(scale)
    -- self:setPositionY(0)
    -- self:setPositionX(0 - (960 * self:getScale() - 720) / 2)

    -- self.bgGradient:setScale(math.max(1, 1 / scale))
    -- self.bgGradient:setScale(1)
    -- self.bgGradient:setPosition(self.bgGradient:getParent():convertToNodeSpace(ccp(0, 0)))

    -- local pos = ccp(vo.x + vs.width, vo.y + vs.height)
    -- pos = self.ui:convertToNodeSpace(pos)
    -- self.closeBtnRes:setPosition(ccp(pos.x - 50, pos.y - 50))
end