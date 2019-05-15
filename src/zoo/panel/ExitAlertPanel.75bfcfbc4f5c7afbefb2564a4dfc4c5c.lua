ExitAlertPanel = class(BasePanel)

local CANCEL_ACTION_TYPE = {WITH_ENERGY = 1, ASK_GIFT = 2, PLAY_WEEK_RACE = 3, NO_ACTION = 4}
local Cur_Pop_Panel = nil

local Cur_MiAds_Panel = nil

local function convertUdidToNumber()
  local udid = MetaInfo:getInstance():getUdid()
  if udid then
    local subStr = string.sub(udid, -5)
    if subStr then
      return tonumber(subStr, 16) or 0
    end
  end
  return 0
end

function ExitAlertPanel:create(okCallBack, cancelCallBack)
	if __ANDROID and PlatformConfig.name == PlatformNameEnum.kMI and 
			MaintenanceManager:getInstance():isAvailbleForUid("MiAdsExitAlert", convertUdidToNumber()) then
		--[[ or PlatformConfig.name == PlatformNameEnum.kMiPad 
			or PlatformConfig.name == PlatformNameEnum.kMiTalk ]]
		local miadsPanel = ExitAlertPanel:createMiAdsExitAlertPanel(okCallBack, cancelCallBack)
		if miadsPanel then return miadsPanel end
	end

	local panel = ExitAlertPanel.new()
	panel:loadRequiredResource("ui/exit_alert_panel.json")
	panel:init(okCallBack, cancelCallBack)
	Cur_Pop_Panel = panel
	return panel
end

function ExitAlertPanel:removeExitAlert(notEnterBackground)
	if Cur_Pop_Panel ~= nil then
		Cur_Pop_Panel:onCloseBtnTapped()
		Cur_Pop_Panel = nil
	end
	if Cur_MiAds_Panel ~= nil then
		if Cur_MiAds_Panel.cancelCallBack then Cur_MiAds_Panel.cancelCallBack() end
		Cur_MiAds_Panel.cancelCallBack = nil
		if notEnterBackground then
			if Cur_MiAds_Panel.dialog then Cur_MiAds_Panel.dialog:dismiss() end
			Cur_MiAds_Panel = nil
		end
	end
end

function ExitAlertPanel:removeExitAlertOnEnterForeground()
	-- 解决原生dialog.dismiss()不能在onEnterBackground中调用的问题
	if Cur_MiAds_Panel ~= nil then
		if Cur_MiAds_Panel.cancelCallBack then Cur_MiAds_Panel.cancelCallBack() end
		if Cur_MiAds_Panel.dialog then Cur_MiAds_Panel.dialog:dismiss() end
		Cur_MiAds_Panel = nil
	end
end

function ExitAlertPanel:createMiAdsExitAlertPanel(okCallBack, cancelCallBack)
	local osVer = getOSVersionNumber() or 0
	if osVer < 4.4 then return nil end -- 只支持4.4及以上系统
	
	local javaLatestModify = 0
	pcall(function()
		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
		javaLatestModify = MainActivityHolder.ACTIVITY:getLatestModify()
	end)
	if javaLatestModify < 8 then return nil end

	local dialogBuilder = nil
	local function tryPopAdsExitDialog()
		local MiAdsManager = luajava.bindClass("com.happyelements.miads.MiAdsManager")
		if MiAdsManager and MiAdsManager:isAdsSdkReady() then
			local dialogListener = luajava.createProxy("com.happyelements.miads.ExitDialogListener", {
					onButtonTapped = function(btnType)
						Cur_MiAds_Panel = nil
						if btnType == 1 then
							if okCallBack then okCallBack() end
						else
							if cancelCallBack then cancelCallBack() end
						end
					end,
					onDialogCancel = function(byUser)
						if cancelCallBack then cancelCallBack() end
					end,
					onAdPresent = function()
						DcUtil:UserTrack({category = "mi_screen", sub_category = "show_scuess"})
					end,
					onAdClick = function()
						DcUtil:UserTrack({category = "mi_screen", sub_category = "click"})
					end,
					onAdDismissed = function()
					end,
					onAdFailed = function(msg)
						DcUtil:UserTrack({category = "mi_screen", sub_category = "loadError", msg = msg})
					end,
					onAdLoaded = function()
					end
				})
			local MiAdsExitDialogBuilder = luajava.bindClass("com.happyelements.miads.MiAdsExitDialogBuilder")
			dialogBuilder = MiAdsExitDialogBuilder:createBuilder()
			dialogBuilder:setDialogListener(dialogListener)
		end
	end
	pcall(tryPopAdsExitDialog)

	if not dialogBuilder then
		return nil
	end

	local panel = {}
	panel.popout = function()
		dialogBuilder:showDialog()
		panel.dialog = dialogBuilder:getDialog()
		panel.okCallBack = okCallBack
		panel.cancelCallBack = cancelCallBack

		Cur_MiAds_Panel = panel
	end
	return panel
end

function ExitAlertPanel:init(okCallBack, cancelCallBack)
	self.ui = self:buildInterfaceGroup("exit_alert_panel/Panel")
	local scene = Director:sharedDirector():run()
	if scene:is(HomeScene) then
		local user = UserManager.getInstance().user
		if user ~= nil then
			if user:getEnergy() >= 5 then --提醒玩家还有剩余精力
				self.cancelAction = CANCEL_ACTION_TYPE.WITH_ENERGY
			else
				local friendNum = FriendManager:getInstance():getFriendCount()
			    local todayWantsCount = #UserManager:getInstance():getWantIds()
				if friendNum > 0 and todayWantsCount < 1 then --好友数量＞0，且未获得每日首次索要奖励（中级精力瓶）
					self.cancelAction = CANCEL_ACTION_TYPE.ASK_GIFT
				else
					local userTopLevel = UserManager:getInstance():getUserRef():getTopLevelId() or 0

					if RankRaceMgr:getInstance():isEnabled() then
						if RankRaceMgr:getInstance():getLeftFreePlay() > 0 then --免费闯关次数＞0
						   self.cancelAction = CANCEL_ACTION_TYPE.PLAY_WEEK_RACE
						end
					elseif SeasonWeeklyRaceManager:getInstance():isLevelReached(userTopLevel) then -- 已解锁
						if SeasonWeeklyRaceManager:getInstance():getLeftPlay() > 0 then --免费闯关次数＞0
						   self.cancelAction = CANCEL_ACTION_TYPE.PLAY_WEEK_RACE
						end
					end
				end
			end
		end
	end

	if self.cancelAction == nil then self.cancelAction = CANCEL_ACTION_TYPE.NO_ACTION end

	self.okCallBack = okCallBack
	self.cancelCallBack = cancelCallBack
    BasePanel.init(self, self.ui)

    self:setPositionForPopoutManager()

    self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:clkCloseBtn() end)

    self.okBtn = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
	self.okBtn:addEventListener(DisplayEvents.kTouchTap,function() self:clkOKBtn() end)
    self.cancelBtn = GroupButtonBase:create(self.ui:getChildByName("cancelBtn"))
	self.cancelBtn:addEventListener(DisplayEvents.kTouchTap,function() self:clkCancelBtn() end)
    self.energyDesc = self.ui:getChildByName("energyTf")
    if self.cancelAction == CANCEL_ACTION_TYPE.ASK_GIFT or
       self.cancelAction == CANCEL_ACTION_TYPE.PLAY_WEEK_RACE or
       (self.cancelAction == CANCEL_ACTION_TYPE.NO_ACTION and scene:is(HomeScene)) then
       local fullEnergyTimeOff = UserService:getInstance():getExactFullEnergyTimeInSec()
        if fullEnergyTimeOff > 0 then
       		local targetTime = os.time() + fullEnergyTimeOff - Localhost:getTodayStart()
       		local timeKey
       		if targetTime > 86400 then 
       			timeKey = "exit.alert.panel.nextday.energyfull"
       			targetTime = targetTime - 86400
       		else 
       			timeKey = "exit.alert.panel.today.energyfull" 
       		end
       		local timeStr = getTimeFormatString(targetTime)
       		timeStr = string.sub(timeStr, 1, 5)
       		self.energyDesc:setString(localize(timeKey,  {time=timeStr}))
   	   	end
    end

    self.cancelBtn.groupNode:getChildByName("lable1"):setVisible(false)
    self.cancelBtn.groupNode:getChildByName("lable2"):setVisible(false)
    self.cancelBtn.groupNode:getChildByName("lable4"):setVisible(false)
    self.bg1 = self.ui:getChildByName("bg1")
    self.bg2 = self.ui:getChildByName("bg2")
    self.bg3 = self.ui:getChildByName("bg3")
    self.bg4 = self.ui:getChildByName("bg4")
    self.bg1:setVisible(false)
    self.bg2:setVisible(false)
    self.bg3:setVisible(false)
    self.bg4:setVisible(false)
    if self.cancelAction == CANCEL_ACTION_TYPE.WITH_ENERGY then 
    	self.bg1:setVisible(true) 
    	self.cancelBtn.groupNode:getChildByName("lable1"):setVisible(true)
    elseif self.cancelAction == CANCEL_ACTION_TYPE.ASK_GIFT then 
    	self.bg2:setVisible(true)
    	self.cancelBtn.groupNode:getChildByName("lable2"):setVisible(true)
    elseif self.cancelAction == CANCEL_ACTION_TYPE.PLAY_WEEK_RACE then 
    	self.bg3:setVisible(true)
    	self.cancelBtn.groupNode:getChildByName("lable2"):setVisible(true)
    else 
    	self.bg4:setVisible(true)
    	self.cancelBtn.groupNode:getChildByName("lable4"):setVisible(true)
   	end
end

function ExitAlertPanel:clkOKBtn( ... )
	if self.cancelClked or self.okClked or self.closeClked then return end

	self.okClked = true
	if self.okCallBack ~= nil then self.okCallBack(self.cancelAction) end
	self:removePanel()
end

function ExitAlertPanel:clkCancelBtn( ... )
	if self.cancelClked or self.okClked or self.closeClked then return end

	self.okCallBack = true
	if self.cancelAction == CANCEL_ACTION_TYPE.WITH_ENERGY then
		local userTopLevel = UserManager:getInstance():getUserRef():getTopLevelId() or 1
		if not UserManager:getInstance():hasPassedLevel(userTopLevel) then
			PopoutManager:sharedInstance():removeAll()
			local startGamePanel = StartGamePanel:create(userTopLevel, GameLevelType.kMainLevel)
			startGamePanel:popout(false)
		end
	elseif self.cancelAction == CANCEL_ACTION_TYPE.ASK_GIFT then
		AskForEnergyPanel:popoutPanel()
	end

	if self.cancelCallBack ~= nil then self.cancelCallBack(self.cancelAction) end
	self:removePanel()

	if self.cancelAction == CANCEL_ACTION_TYPE.PLAY_WEEK_RACE then
		if RankRaceMgr:getInstance():isEnabled() then
			RankRaceMgr:getInstance():openMainPanel()
		else
			SeasonWeeklyRaceManager:getInstance():pocessSeasonWeeklyDecision()
		end
	end
end

function ExitAlertPanel:clkCloseBtn( ... )
	if self.cancelClked or self.okClked or self.closeClked then return end

	self.closeClked = true
	if self.cancelCallBack ~= nil then self.cancelCallBack(self.cancelAction) end
	self:removePanel()
end

function ExitAlertPanel:onCloseBtnTapped( ... )
	if self.cancelCallBack ~= nil then self.cancelCallBack(self.cancelAction) end
	self:removePanel()
end

function ExitAlertPanel:removePanel( ... )
	PopoutManager:sharedInstance():remove(self)
end

function ExitAlertPanel:popout( ... )
	PopoutManager.sharedInstance():add(self, true, false, Director:sharedDirector():getRunningScene(), "topLayer")
	self.allowBackKeyTap = true
	return self
end

