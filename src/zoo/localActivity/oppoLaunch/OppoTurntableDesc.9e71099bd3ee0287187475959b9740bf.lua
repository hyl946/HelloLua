
OppoTurntableDesc = class(BasePanel)

function OppoTurntableDesc:ctor()
end

function OppoTurntableDesc:init()
	self.isVivo = OppoLaunchManager:isVivo()
	self.isMi = OppoLaunchManager:isMi()

	if self.isVivo then 
		self.ui = self:buildInterfaceGroup("oppo_launch_desc/VivoTurntableDesc")
	elseif self.isMi then
		self.ui = self:buildInterfaceGroup("oppo_launch_desc/MiTurntableDesc")
	else
		self.ui = self:buildInterfaceGroup("oppo_launch_desc/OppoTurntableDesc")
	end
    BasePanel.init(self, self.ui)

    self.closeBtn = self.ui:getChildByName('closeBtn')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)

    local desc1 = self.ui:getChildByName("label_desc1")
	if desc1.width and desc1.height then
	    desc1:setPreferredSize(desc1.width, desc1.height)
	end

	local str = "第1步：从[#099BF2]OPPO游戏中心[/#]开启游戏，获得专属特权"
	if self.isVivo then
		str = "第1步：从[#099BF2]vivo游戏中心“我的游戏”或任意位置[/#]启动游戏，获得专属特权"
	elseif self.isMi then
		str = "第1步：从[#099BF2]小米游戏中心任意位置[/#]启动游戏，获得专属特权"
	end

	desc1:setRichTextWithWidth(localize(str, {n = '\n', s = ' '}), 18, '663300', 0.9)   

	local desc2 = self.ui:getChildByName("label_desc2")
	if desc2.width and desc2.height then
	    desc2:setPreferredSize(desc2.width, desc2.height)
	end
	desc2:setRichTextWithWidth(localize("第2步：闯到20关的玩家在游戏内转盘抽奖，赢取奖励！", {n = '\n', s = ' '}), 18, '663300', 0.9)   

	if self.isVivo then
	elseif self.isMi then
		local btnUI = self.ui:getChildByName("gotoBtn")
		if btnUI then 
			self.gotoButton = GroupButtonBase:create(btnUI)
			self.gotoButton:setString("去小米游戏中心")
			self.gotoButton:addEventListener(DisplayEvents.kTouchTap,  function ()
					OppoLaunchManager.getInstance():launchGameCenter()
				end)
		end
	else
		local btnUI = self.ui:getChildByName("gotoBtn")
		if btnUI then 
			self.gotoButton = GroupButtonBase:create(btnUI)
			self.gotoButton:setString("去oppo游戏中心")
			self.gotoButton:addEventListener(DisplayEvents.kTouchTap,  function ()
					OppoLaunchManager.getInstance():launchGameCenter()
				end)
		end
	end
end

function OppoTurntableDesc:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)

    local uisize = self:getGroupBounds().size
	local director = Director:sharedDirector()
    local origin = director:getVisibleOrigin()
    local size = director:getVisibleSize()
    local hr = size.height / uisize.height
    local wr = size.width / uisize.width
    if hr < 1 then
    	self:setScale((hr < wr) and hr or wr)
    end

    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
        
    self:setPosition(ccp(centerPosX, centerPosY))
end

function OppoTurntableDesc:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false

	OppoLaunchManager.getInstance():updateBtnLastShowTime()
end

function OppoTurntableDesc:create()
	local panel = OppoTurntableDesc.new()
    panel:loadRequiredResource(PanelConfigFiles.oppo_turntable_desc)
    panel:init()
    return panel
end