require('zoo.animation.NumberAnimation')
local Thanksgiving2018CircleCtrl = require('zoo.localActivity.Thanksgiving2018.Thanksgiving2018CircleCtrl')

local Thanksgiving2018InGameProgressPanel = class(BasePanel)

function Thanksgiving2018InGameProgressPanel:ctor()
end

function Thanksgiving2018InGameProgressPanel:init()

    FrameLoader:loadArmature('skeleton/QixiSkeletion', 'QixiSkeletion', 'QixiSkeletion')

    local groupName = "ThankGivingPanel/ingamepanel"
	self.ui = self:buildInterfaceGroup(groupName)
    BasePanel.init(self, self.ui)

    self.MoonLight = self.ui:getChildByName('light')
    self.MoonLight:setVisible(false)

    local fntFile = "fnt/dlseven_innum.fnt"
    self.Thanksgiving2018CircleCtrl = Thanksgiving2018CircleCtrl:create( self.ui, ccp(196-32/0.7,-18), 0, fntFile, 1.2, kCCTextAlignmentLeft, 4, 18  )
    self.Thanksgiving2018CircleCtrl:setNumber( 0, false )

    self.NeedShowNum = 0

    return true
end

function Thanksgiving2018InGameProgressPanel:dispose()
    FrameLoader:unloadArmature( 'skeleton/QixiSkeletion', true )

    BasePanel.dispose(self)
end

function Thanksgiving2018InGameProgressPanel:MoonLightBlink()
    local moonLightPos = self.MoonLight:getPosition()

    local node = ArmatureNode:create('QixiSkeletion/moonlight')
    node:playByIndex(0, 1)
    node:setPosition( ccp(moonLightPos.x-19/0.7,moonLightPos.y+14/0.7))
    local function animationCallback()
        node:removeFromParentAndCleanup(true)
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)

    self.ui:addChild( node )
end

function Thanksgiving2018InGameProgressPanel:update( bAni, bAniEndCallBack )
	if self.isDisposed then return end

    local bAni = bAni or false
--	local curNum, maxNum = Qixi2018CollectManager.getInstance():getProgressShowNum()

    local getNum = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
    if mainLogic then
        getNum = mainLogic.actCollectionNum*10
    end

	--更新目标数量
    self.NeedShowNum = getNum

    self.Thanksgiving2018CircleCtrl:setNumber( self.NeedShowNum, bAni, bAniEndCallBack )
end

function Thanksgiving2018InGameProgressPanel:MoveOutPanel( moveEndCallBack )
    if self.isDisposed then return end

	local arr = CCArray:create()
    arr:addObject( CCDelayTime:create(0.5 ) )
	arr:addObject( CCMoveTo:create(0.3, ccp(0, 0) ))
    arr:addObject(CCCallFunc:create(function ()
	 	if moveEndCallBack then moveEndCallBack() end
	end))

    self.ui:stopAllActions()
	self.ui:runAction(CCSequence:create(arr))
end

function Thanksgiving2018InGameProgressPanel:MoveInPanel( moveEndCallBack )
    if self.isDisposed then return end

    local instance = self

	local arr = CCArray:create()
	arr:addObject( CCMoveTo:create(0.3, ccp(250, 0) ) )
    arr:addObject(CCCallFunc:create(function ()

        local function MoveEndCallBack()
            setTimeOut( function()
                if moveEndCallBack then moveEndCallBack() end 
            end, 1 )
        end
        instance:update( true, MoveEndCallBack )
	 	
	end))

    self.ui:stopAllActions()
	self.ui:runAction(CCSequence:create(arr))
end

function Thanksgiving2018InGameProgressPanel:create(panelType)
	local panel = Thanksgiving2018InGameProgressPanel.new()
	panel.panelType = panelType
    panel:loadRequiredResource("tempFunctionRes/CountdownParty/ThankGivingPanel.json")
    if panel:init() then 
    	return panel
    end
end

return Thanksgiving2018InGameProgressPanel