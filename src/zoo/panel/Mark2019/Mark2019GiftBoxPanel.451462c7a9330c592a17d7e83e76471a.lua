local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

Mark2019GiftBoxPanel = class(BasePanel)
function Mark2019GiftBoxPanel:create( mainPanel, closeCall, index )
    local panel = Mark2019GiftBoxPanel.new()
    panel:init(mainPanel, closeCall, index)
    return panel
end

function Mark2019GiftBoxPanel:init(mainPanel, closeCall, index)

    self.mainPanel = mainPanel
    self.closeCall = closeCall
    self.ShowIndex = tonumber(index) -- 7 14 ..

    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/selectPanel")
    BasePanel.init(self, ui)

    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local gCenterPos = IntCoord:create(vOrigin.x + vSize.width / 2, vOrigin.y + vSize.height / 2)
    self.gCenterPos = gCenterPos

    local title1 = self.ui:getChildByName('title1')
    title1:setVisible(false)
    self.title1 = title1

    local title2 = self.ui:getChildByName('title2')
    title2:setVisible(false)
    self.title2 = title2

    local tip = self.ui:getChildByName('tip')
    tip:setVisible(false)
    self.tip = tip
    
    local okbtn = self.ui:getChildByName('okbtn')
    self.ok_btn = GroupButtonBase:create(okbtn)
    self.ok_btn:setString("确定")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:ShowGetItemToBag()
        self:onCloseBtnTapped()
    end) 
    self.ok_btn:setVisible(false)
    self.ok_btn:setPositionY( self.ok_btn:getPositionY()+360 )
end

function Mark2019GiftBoxPanel:_close()
    Mark2019Manager.getInstance():removeObserver(self)
    if self.closeCall then self.closeCall() end
    PopoutManager:sharedInstance():remove(self)
end

function Mark2019GiftBoxPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 220)

    self:popoutShowTransition()


    Mark2019Manager.getInstance():DC( 'reward_box', self.ShowIndex )
end

function Mark2019GiftBoxPanel:popoutShowTransition()

    self.bCanClickBtn = false

    Mark2019Manager.getInstance():addObserver(self)

    local asyncRunner = Misc.AsyncFuncRunner:create()

    asyncRunner:add(function ( done )
        if self.isDisposed then return end
        self:GiftMoveOut(done)
    end)

    asyncRunner:add(function ( done )
        if self.isDisposed then return end
        self:GiftShowOut(done)
    end)

    asyncRunner:run()
end

function Mark2019GiftBoxPanel:GiftMoveOut( done )
    if self.isDisposed then return end
    if self.mainPanel.isDisposed then return end

    local index = self.ShowIndex

    local PosIndex = 0
    for i,v in pairs(Mark2019Manager.MarkGiftDay) do
        if v == index then
            PosIndex = i
            break
        end
    end

    if PosIndex == 0 then return end 

    local giftNode =  self.mainPanel.dayBoxList[PosIndex]
    local Pos = giftNode:getPosition()
    local GiftNodeWorldPos = giftNode:getParent():convertToWorldSpace( ccp(Pos.x+32/0.7,Pos.y-32/0.7))

    local balloon_anim = ArmatureNode:create('markAnim2019_2/Reward'..index )
    balloon_anim:playByIndex(0)
    balloon_anim:update(0.001)
    balloon_anim:stop()
    local worldPos = ccp(self.gCenterPos.x, self.gCenterPos.y-120)
    local pos = self.ui:convertToNodeSpace( worldPos )
    balloon_anim:setPosition( pos )
    self.ui:addChildAt( balloon_anim, 3 )
    self.balloon_anim = balloon_anim

    balloon_anim:play("A",0)

--    anim 
    local function callend()
        if done then done() end
    end

    local GiftBoxPos = self.ui:convertToNodeSpace( GiftNodeWorldPos )
    balloon_anim:setPosition( GiftBoxPos )
    balloon_anim:setScale(0.5)

    local useTime = 0.3
    local array3 = CCArray:create()
    array3:addObject( CCMoveTo:create(useTime, ccp(pos.x,pos.y))  )
    array3:addObject( CCScaleTo:create(useTime, 1) )

    local array = CCArray:create()
    array:addObject( CCSpawn:create(array3)  )
    array:addObject(CCCallFunc:create(callend))

    balloon_anim:runAction(CCSequence:create(array))
end

function Mark2019GiftBoxPanel:GiftShowOut()
    local index = self.ShowIndex

    local balloon_anim = self.balloon_anim

    local rewardInfo = Mark2019Manager.getInstance().giftPackInfo[tostring(index)]

    self.replaceNodeList = {}
    for i,v in ipairs(rewardInfo.rewards) do
        local replaceNode = Sprite:createEmpty()
        local icon = Mark2019Manager.getInstance():createIcon(v)
        icon:setScale(1.5)
        replaceNode:addChild( icon )
        replaceNode.icon = icon

	    local targetSlot = balloon_anim:getSlot("reward"..i)
	    replaceNode.refCocosObj:retain()
	    targetSlot:setDisplayImage(replaceNode.refCocosObj, true)
--        replaceNode:dispose()
    
        table.insert( self.replaceNodeList, replaceNode )
    end

    balloon_anim:play("B", 1)
    balloon_anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	balloon_anim:removeAllEventListeners()

        if done then done() end 
    end)

    local function showOkBtn()
        self.ok_btn:setVisible(true)
    end
    
    local array = CCArray:create()
    array:addObject( CCDelayTime:create(2)  )
    array:addObject(CCCallFunc:create(showOkBtn))
    self.ok_btn.groupNode:runAction(CCSequence:create(array))
end

function Mark2019GiftBoxPanel:ShowGetItemToBag()
    if self.isDisposed then return end

    local objectWorldPosList = {}
    for i,v in ipairs(self.replaceNodeList) do
        local icon  = v.icon
        local saveWorldPos = icon:getParent():convertToWorldSpace( icon:getPosition() )
        table.insert( objectWorldPosList, IntCoord:create(saveWorldPos.x, saveWorldPos.y) )

        v:dispose()
    end

    local rewardInfo = Mark2019Manager.getInstance().giftPackInfo[tostring(self.ShowIndex)]

    for i,v in ipairs(objectWorldPosList) do
        local anim = FlyItemsAnimation:create( {rewardInfo.rewards[i]} )
		anim:setScale(1.8)
		anim:setWorldPosition(ccp(v.x, v.y))
		anim:setFinishCallback(function()
			        
		end)
		anim:play()
    end
end

function Mark2019GiftBoxPanel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function Mark2019GiftBoxPanel:onCloseBtnTapped( ... )
    self:_close()
end

function Mark2019GiftBoxPanel:onPassDay()
    self:_close()
end

return Mark2019GiftBoxPanel