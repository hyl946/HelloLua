
local BaseBottomPanel = class(BasePanel)

function BaseBottomPanel:_close()

	if self.isDisposed then return end

	self.allowBackKeyTap = false

	local panelSize = self.ui:getGroupBounds(self).size
	local panelWidth = panelSize.width
	local panelHeight = panelSize.height

	self:runAction(CCSequence:createWithTwoActions(
		CCEaseSineIn:create(CCMoveBy:create(0.3, ccp(0, 10-panelHeight))),
		CCCallFunc:create(function ( ... )
			PopoutManager:sharedInstance():remove(self)
		end)
	))

end

function BaseBottomPanel:popout()

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local panelSize = self.ui:getGroupBounds(self).size
	local panelWidth = panelSize.width
	local panelHeight = panelSize.height

	self:setPositionX(visibleOrigin.x + (visibleSize.width - panelWidth)/2)
	self:setPositionY(- visibleSize.height)
	-- self:setPositionY(panelHeight - visibleSize.height)

	self:runAction(CCEaseSineOut:create(CCMoveBy:create(0.3, ccp(0, panelHeight - 10))))

	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function BaseBottomPanel:onCloseBtnTapped( ... )
    self:_close()
end


local SelectShareWayPanel = class(BaseBottomPanel)

function SelectShareWayPanel:create()
    local panel = SelectShareWayPanel.new()
	panel:loadRequiredResource("ui/panel_summer_weekly_share2.json")
    panel:init()
    return panel
end

function SelectShareWayPanel:init()
    local ui = self:buildInterfaceGroup("SummerWeeklyRacePanel/select/select")

	BaseBottomPanel.init(self, ui)


    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.friendsBtn = self.ui:getChildByName('btn1')
    self.feedsBtn = self.ui:getChildByName('btn2')

    -- self.friendsBtn.label = self.friendsBtn:getChildByName('label')
    -- self.feedsBtn.label = self.feedsBtn:getChildByName('label')

  


    local uid = UserManager.getInstance().user.uid or "00"
	local uidGroup = tonumber(string.sub(tostring(uid), -2)) or 0
	local useGroup1 = true
	if uidGroup >= 0 and uidGroup < 50 then 
		useGroup1 = false
	end

	-- if useGroup1 then 
		-- self.friendsBtn.label:setString("微信好友")
		-- self.feedsBtn.label:setString("朋友圈")
	-- else
	-- 	self.friendsBtn.label:setString("分享给好友")
	-- 	self.feedsBtn.label:setString("更多人可见")
	-- end

	self.friendsBtn:setTouchEnabled(true)
	self.feedsBtn:setTouchEnabled(true)

	self.friendsBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:_close()
		if self.btn1_cb then
			self.btn1_cb()
		end
	end)
	self.feedsBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:_close()
		if self.btn2_cb then
			self.btn2_cb()
		end
	end)
end


function SelectShareWayPanel:popout(btn1_cb, btn2_cb)
	self.btn1_cb = btn1_cb
	self.btn2_cb = btn2_cb
    BaseBottomPanel.popout(self)
end

return SelectShareWayPanel
