--IOS系统样式的下载进度

UpdatePackageProgress = class(BasePanel)

-- --前面一部分进度显示的快一些
-- local FAKE_POINT = 0.3
-- --缩放倍数,FAKE_POINT*FAKE_FORE_RATE需要小于1
-- local FAKE_FORE_RATE = 2
-- local FAKE_BACK_RATE = (1-FAKE_POINT*FAKE_FORE_RATE)/(1-FAKE_POINT)

function UpdatePackageProgress:create()
	local a = UpdatePackageProgress.new()
	a:init()
    a:popout()
	return a
end

function UpdatePackageProgress:setProgress(now,total)
	now = now or 0
	total = math.max(total or 0,0)
	local percent = total>0 and now/total or 0
	percent = math.min(percent,1)

    local function formatSize(value)
        if not value then return 0 end
        return math.floor(value/1024/1024*100)/100 .. "M"
    end

    -- local fakeSize,fakePercent=0,0
    -- if percent<FAKE_POINT then
    --     fakePercent = percent*FAKE_FORE_RATE
    -- else
    --     fakePercent = FAKE_POINT*FAKE_FORE_RATE+(percent-FAKE_POINT)*FAKE_BACK_RATE
    -- end
    -- fakeSize = total * fakePercent

	local nowSize = formatSize(now)
	local totalSize = formatSize(total)
	local str = "您已连接无线网络，当前有版本更新，需要下载%s，下载过程不影响正常游戏。"
	self.descLabel:setString(string.format(str,totalSize))
	self.infoLabel:setString(string.format("下载中： %s / %s",nowSize,totalSize))
	self.progressLabel:setString(math.floor(percent*1000)*0.1 .. "%")

	self.progressBar:setPositionX(self.progressBar.width*(percent-1))
end

function UpdatePackageProgress:init()
    self:loadRequiredResource(PanelConfigFiles.panel_game_setting)
    self.ui = self:buildInterfaceGroup("downloadProgressPanel")
	BasePanel.init(self, self.ui)

    local childs = {
        "scale9Bg",
		"hotArea",
		"line_hoverBtn",
		"centerBtnLabel",
		"progressBg",
		"progressBar",
		"progressLabel",
		"infoLabel",
		"descLabel",
    }
    for i,v in ipairs(childs) do
        self[v] = self.ui:getChildByName(v)
    end

    self.centerBtnLabel:setString("继续游戏")

    local barMask = SpriteColorAdjust:createWithSpriteFrameName('_downloadProgressPanel/progressBar0000')
    barMask:setAnchorPoint(ccp(0, 1))

	local pos= self.progressBar:getPosition()
	local barParent = self.progressBar:getParent()
	local idx = barParent:getChildIndex(self.progressBar)
	self.progressBar:removeFromParentAndCleanup(false)
	self.barClippingNode =  ClippingNode.new(CCClippingNode:create(barMask.refCocosObj))
	self.barClippingNode:addChild(self.progressBar)
	self.barClippingNode:setPosition(ccp(pos.x, pos.y))
	self.barClippingNode:setAlphaThreshold(0.01)
	barParent:addChildAt(self.barClippingNode, idx)

	self.progressBar:setPosition(0,0)

	local size = self.progressBar:getContentSize()
	self.progressBar.width = size.width

    local function onClose(event)
        print("UpdatePackageProgress:onClose()")
        local fn = self.closeCallback
        self:onClose()
        local _ = self.closeCallback and self.closeCallback()
    end
    self.hotArea:setTouchEnabled(true,0, false)
    self.hotArea:setButtonMode(true)
    self.hotArea:addEventListener(DisplayEvents.kTouchTap, onClose)

    UpdatePackageManager:getInstance():setProgressCallback(handler(self,self.setProgress))

    -- local function onUpdate(dt)
    --     local max = 123000000
    --     self.testNow = self.testNow or math.random()*max
    --     self.testNow = self.testNow+100000
    --     self:setProgress(self.testNow,max)
    --     if self.testNow>max*1.2 then
    --         self.testNow = 0
    --     end
    -- end
    -- self:scheduleUpdateWithPriority(onUpdate, 0)
end

function UpdatePackageProgress:onClose()
    print("UpdatePackageProgress:onClose()")
    UpdatePackageManager:getInstance():setProgressCallback(nil)

    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self,true)
end

function UpdatePackageProgress:popout()
    self.allowBackKeyTap = true
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

    PopoutManager:sharedInstance():add(self, false)
    -- self:popoutShowTransition()
end

function UpdatePackageProgress:onKeyBackClicked(...)
    print("UpdatePackageProgress:onKeyBackClicked()")

    if self.allowBackKeyTap then
        self:onClose()
    end
end

return UpdatePackageProgress

