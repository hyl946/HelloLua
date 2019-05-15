
local Feed = require('zoo.panel.askForHelp.component.Feed')

local ShowoffPanel = class(BasePanel)
function ShowoffPanel:create(doneeUid, levelIdx, rewardItems, onFinished)
    local instance = ShowoffPanel.new()
    instance:loadRequiredResource('ui/AskForHelp/PassLevelShowOff.json')
    instance:init(doneeUid, levelIdx, rewardItems, onFinished)
    return instance
end

function ShowoffPanel:dispose( ... )
    for _,v in ipairs(self.items) do
        v:dispose()
    end

	ArmatureFactory:remove(self.armatureName, self.armatureName)
    BasePanel.dispose(self)
end

function ShowoffPanel:init(doneeUid, levelIdx, rewardItems, onFinished)
    self.items = {}
    self.doneeUid = doneeUid
    self.levelIdx = levelIdx or 1
    self.rewardItems = rewardItems or {}
    self.onFinished = onFinished
    self.animPlayed = false

    self.hasSpecialItem = false
    self.armatureName = 'AskForHelp/interface/passlevel'
    if table.size(self.rewardItems) == 3 then
        self.armatureName = 'AskForHelp/interface/passlevelEx'
        self.hasSpecialItem = true
    end
    self.spriteFrameName = "askforhelp/interface/res/frame/head0000"

    local ui = self.builder:buildGroup('askforhelp/interface/showoff_panel')
    BasePanel.init(self, ui)
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

	local vOrig = Director:sharedDirector():getVisibleOrigin()
	local vSize = Director:sharedDirector():getVisibleSize()

    -- shareDisabled
    local shareDisabled = AskForHelpManager:getInstance():shareDisabled()

    -- NotifyBtn
    local btnNotify = GroupButtonBase:create(ui:getChildByName("notifyBtn"))
    btnNotify:setVisible(false)

    -- ShareBtn
    local btnShare = GroupButtonBase:create(ui:getChildByName("shareBtn"))
    local caption = localize('askforhelp.passlevel.showoff.btnShare')
    if shareDisabled then
        caption = localize('askforhelp.passlevel.showoff.btnShare.noShare')
    end
    btnShare:setString(caption)
    btnShare:addEventListener(DisplayEvents.kTouchTap, function() self:onShareBtnTapped(true) end)
    self.btnShare = btnShare
    local szCon = self.ui:getContentSize()
    btnShare:setPositionX(vSize.width/2)

    local close = ui:getChildByName("closeBtn")
    close:setPositionX((vSize.width - self:getPositionX()) / self:getScale() - 60)
    close:setPositionY(-self:getPositionY() / self:getScale() - 60)
    close:setTouchEnabled(true)
    close:setButtonMode(true)
    close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped(false) end)
    self.close = close

    self.ui:runAction(CCCallFunc:create(function ( ... )
     --    local kDarkOpacity = 150
	    -- local darkLayer = LayerColor:createWithColor(ccc3(0, 0, 0), vSize.width*1024, vSize.height*1024)
     --    darkLayer:ignoreAnchorPointForPosition(false)
     --    darkLayer:setAnchorPoint(ccp(0,0))
	    -- darkLayer:setOpacity(kDarkOpacity)
	    -- self.ui:addChildAt(darkLayer, 0)
     --    local ptOri = self.ui:convertToNodeSpace(ccp(vOrig.x, vOrig.y))
     --    darkLayer:setPosition(ccp(ptOri.x, ptOri.y))
        self:runAnimation()
    end))
end

function ShowoffPanel:runAnimation()
    FrameLoader:loadArmature('skeleton/AskForHelp/share_askforhelper_animation', 'share_askforhelper_animation', 'share_askforhelper_animation')

    local anim = ArmatureNode:create(self.armatureName, true)
    anim:playByIndex(0, 1)
    anim:setPosition(ccp(360, -800))
    self.ui:addChild(anim)

    -- fill items
    local rewards = self.rewardItems
    local cons = {1, 2, 4}
    for _,itemId in ipairs(cons) do
        local itemSlot = anim:getSlot("con" ..tostring(itemId))
        if itemSlot then
            if not rewards[itemId] then
                itemSlot:setDisplayImage(false)
            else
		        local itemCon =  tolua.cast(itemSlot:getCCDisplay(), "CCSprite")

		        if ItemType:isTimeProp(itemId) then
		        	itemId = ItemType:getRealIdByTimePropId(itemId)
		        end

                -- item
                local item
                if itemId == 1 then
                    item = Sprite:createWithSpriteFrameName(self.spriteFrameName)
                else
                    item = ResourceManager:sharedInstance():buildItemSprite(itemId)
                end
                
		        item:setAnchorPoint(ccp(0.5,0.5))
                item:setPosition(ccp(110, 120))
                item:setScale(1.05)
		        itemCon:addChild(item.refCocosObj)
                self.items[itemId] = item

                -- n99
                if itemId ~= 1 then
	                local n99 = BitmapText:create('x'..tostring(rewards[itemId]), "fnt/event_default_digits.fnt")
                    n99:setAnchorPoint(ccp(0.5, 0.5))
                    n99:setPosition(ccp(110, 68))
                    n99:setScale(1.07)
                    itemCon:addChild(n99.refCocosObj)
                    n99:dispose()
                end
            end
        end
    end

    local titleSlot = anim:getSlot("red")
    local spcon = tolua.cast(titleSlot:getCCDisplay(), "CCSprite")
    if spcon then
        local charWidth = 35
        local charHeight = 35
        local charInterval = 32
        local fntFile = "fnt/share.fnt"
        local titleStr = localize('askforhelp.passlevel.showoff.banner')
        if self.hasSpecialItem then
            titleStr = localize("askforhelp.passlevel.showoff.banner.getNewHeadFrame")
        end
        local newCaptain = BitmapText:create(titleStr, fntFile, -1, kCCTextAlignmentCenter)
        newCaptain:setPosition(ccp(280, 80))

        spcon:addChild(newCaptain.refCocosObj)
        newCaptain:dispose()
    end
end

function ShowoffPanel:onCloseBtnTapped()
    self:onClose()
end

function ShowoffPanel:onShareBtnTapped(shouldShare)
    self.btnShare:setEnabled(false)

    local function onShareFinished(ret)
        if self.isDisposed then return end
        self.btnShare:setEnabled(true)
        if ret then
            if AskForHelpManager:getInstance():shareDisabled() then
                self:onClose()
            end
            self.btnShare:setString("炫耀一下")
        end
    end
    
    local function onSuccess()
        DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_show_pyq_success', t1=self.levelIdx})
        onShareFinished(true)
    end
    local function onFail()
        onShareFinished(false)
    end
    local function onCancel()
        onShareFinished(false)
    end
    local function onFlyFinished()
        if self.hasSpecialItem then
            Feed:shareNewHeadFrame(self.levelIdx, onSuccess, onFail, onCancel)
        else
            Feed:sharePassLevel(self.levelIdx, onSuccess, onFail, onCancel)
        end
    end

    if self.animPlayed then
        onFlyFinished()
    else
        self.animPlayed = true
            -- fly fly fly
        local rewards = self.rewardItems or {}
        local animArray = {}
        for i, v in pairs(rewards) do
            if i ~= 1 then
	    	    local item = self.items[i]
	    	    local bounds = item:getGroupBounds()
                local startPos = ccp(bounds:getMidX(), bounds:getMidY())
   
                local anim = FlyItemsAnimation:create({{itemId = i, num = v}})
                anim:setWorldPosition(startPos)
                table.insert(animArray, anim)
            end
        end

	    local counter = 0
        local function callback( ... )
        	counter = counter + 1
        	if counter >= #animArray then
                onFlyFinished()
        	end 
        end

        for _, anim in ipairs(animArray) do
        	anim:setFinishCallback(callback)
        	anim:play()
        end
    end
    DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_show_pyq', t1=self.levelIdx})
end

function ShowoffPanel:popout()
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 210)
    self.allowBackKeyTap = true
end

function ShowoffPanel:onClose()
    if type(self.onFinished) == "function" then self.onFinished() end
    
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

return ShowoffPanel

--[[ 飞头像框
    if i == 1 then
        require 'zoo.scenes.component.HomeScene.flyToAnimation.FlySpecialItemAnimation'
        anim = FlySpecialItemAnimation:create({itemId = i, num = v}, 
        self.spriteFrameName,
        HomeScene:sharedInstance().hideAndShowBtn:getPositionInWorldSpace())
    else
--]]