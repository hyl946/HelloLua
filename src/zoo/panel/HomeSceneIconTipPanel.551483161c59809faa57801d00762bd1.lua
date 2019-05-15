HomeSceneIconTipPanel = class(BasePanel)

function HomeSceneIconTipPanel:create(moduleNoticeID , descTxt)
    local instance = HomeSceneIconTipPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.home_scene_icon_tip_panel)
    instance:init(moduleNoticeID , descTxt)
    return instance
end

function HomeSceneIconTipPanel:init(moduleNoticeID , descTxt)

	local ui = self:buildInterfaceGroup("homeSceneIconTipPanel/TipPanel")
    --local ui = self.builder:buildGroup("homeSceneIconTipPanel/TipPanel")
    BasePanel.init(self, ui)

    self.rectBG = self.ui:getChildByName("rectBG")
    self.rectBG:setOpacity(0)

    self.panelBG = self.ui:getChildByName("panelBG")

    self.descLabel = self.ui:getChildByName("desc")
    self.descLabel:setString( descTxt )

    self.iconList = {}

    for i = 1 , 7 do
    	self.iconList[i] = self.ui:getChildByName("icon_" .. tostring(i))
    	self.iconList[i]:setVisible(false)
    end

    self.currIcon = self.iconList[moduleNoticeID]
    self.currIcon:setVisible(true)

    self:enableAutoClose( function () 
    		self:fadeOut()
    	end)
    
    local function onTimeout() self:fadeOut() end
	local duration = 2

    self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, duration, false)

end


function HomeSceneIconTipPanel:popout()
    self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, false, true)
    self:setPositionForPopoutManager()

    local originPos = ccp( self:getPositionX() , self:getPositionY() )
    local size = self.ui:getGroupBounds().size

    self:setPosition( ccp( originPos.x + size.width/2 , originPos.y - size.height/2 ) )
    self:setScale(0)

    self:runAction( CCEaseBackOut:create(CCMoveTo:create(0.2, originPos)) )
    self:runAction( CCSequence:createWithTwoActions(CCEaseBackOut:create(CCScaleTo:create(0.2, 1)), CCCallFunc:create(onScaled)) )
end


function HomeSceneIconTipPanel:fadeOut()
	if self.schedule and not self.ui.isDisposed then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
		local function doFade()
			if not self.ui.isDisposed then
				self.panelBG:runAction(CCFadeOut:create(0.2))
				self.currIcon:runAction(CCFadeOut:create(0.2))
				if self.descLabel then self.descLabel:runAction(CCFadeOut:create(0.2)) end
			end
		end
		self:stopAllActions()
		local fade = CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 100)), CCCallFunc:create(doFade))
		local function removeSelf()
			if not self.ui.isDisposed then 
				self.allowBackKeyTap = false
				PopoutManager:sharedInstance():remove(self, true)
			end
		end
		self:runAction(CCSequence:createWithTwoActions(fade, CCCallFunc:create(removeSelf)))
	else return end
end


function HomeSceneIconTipPanel:enableAutoClose(closeFunc)
	local function onTouchCurrentLayer(eventType, x, y)
		if not self.isDisposed then
	        local worldPosition = ccp(x, y)
	        local panelGroupBounds = self.ui:getGroupBounds()
	        if panelGroupBounds:containsPoint(worldPosition) then
	        	--printx( 1 , "   onTouchCurrentLayer  11111111111111111111111111111111111111111")
	        else
	        	--printx( 1 , "   onTouchCurrentLayer  22222222222222222222222222222222222222222")
	        	self:disableAutoClose()
	        	if closeFunc then
	        		closeFunc()
	        	end
	        end
	        return true
	    end
	end
	self.ui:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    self.ui.refCocosObj:setTouchEnabled(true)
end

function HomeSceneIconTipPanel:disableAutoClose()
    if not self.isDisposed then
		self.ui:unregisterScriptTouchHandler()
		self.ui.refCocosObj:setTouchEnabled(false) 
	end
end