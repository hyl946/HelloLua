PrepackageUtil = {}
PrepackageNetWorkDialogState =  table.const{
	NEXT_SHOW = 0,
	ONLY_NEXT_NO_SHOW = 1,
	NEVER_SHOW = 2
}
-------设置预装包所需的值
function PrepackageUtil:setPrePackageValue()
	---------pre package-------------------------------------------------------
	_G.noMoreTipsForPrePackageNetWork = false
	_G.isPrePackageNoNetworkMode = false
	_G.isPrePackageCannotShowUpdatePanel = false
	_G.prePackageMaxLevel = 180
	---------end----------------------------------------------------------------
	local function safeReadConfig()
	    _G.isPrePackage = StartupConfig:getInstance():getIsPrePackage()
	end
	pcall(safeReadConfig)
	 ----------------------------------------------------------------------------------pre package setting
	if _G.isPrePackage then
	    PrepackageUtil:readFromLocal()
	else
		_G.enterGameTime = 999		
	end
	
end

function PrepackageUtil:updateEgamePrefFiles()
	local function doUpdate()
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local preferences = MainActivityHolder.ACTIVITY:getSharedPreferences("cn_egame_sdk_log", 0)
		local timeInMillis = os.time() * 1000
		local editor = preferences:edit()
		editor:putLong("update_cfg_time", timeInMillis)
		editor:putLong("upload_errorlog_time", timeInMillis)
		editor:putInt("record_policy", 0)
		editor:commit()
	end
	pcall(doUpdate)
end

function PrepackageUtil:initX5Env()
	local function doInitX5Env()
		local MainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
		MainActivity:initX5Environment()
	end
	pcall(doInitX5Env)
end

-----检查是否需要弹出预装包联网提示
function PrepackageUtil:prePackageCheck(callback)
	PrepackageUtil:setPrePackageValue()
	
	if _G.isPrePackage and _G.isPrePackageNoNetworkMode then
		PrepackageUtil:updateEgamePrefFiles()
	end
    callback()
end

function PrepackageUtil:readFromLocal()
	local dialogState = CCUserDefault:sharedUserDefault():getIntegerForKey("PrepackageNetWorkDialogState")
	if dialogState == PrepackageNetWorkDialogState.ONLY_NEXT_NO_SHOW then
		 CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", PrepackageNetWorkDialogState.NEXT_SHOW)
	end
	_G.noMoreTipsForPrePackageNetWork = dialogState > 0
	_G.isPrePackageNoNetworkMode = not CCUserDefault:sharedUserDefault():getBoolForKey("isPrePackageNetworkOpen")
	if __ANDROID then 
		local prepackageUtil = luajava.bindClass("com.happyelements.android.utils.PrepackageUtils")
		if prepackageUtil then
			prepackageUtil:getInstance():setPrePackageNoNetworkMode(_G.isPrePackageNoNetworkMode)
		end
	end
	if _G.isLocalDevelopMode then printx(0, "G.noMoreTipsForPrePackageNetWork = ", _G.noMoreTipsForPrePackageNetWork) end
	if _G.isLocalDevelopMode then printx(0, "G.isPrePackageNoNetworkMode = ", _G.isPrePackageNoNetworkMode) end
	if _G.isLocalDevelopMode then printx(0, "----------------------------------------------------------------------------") end
	--进入游戏次数
	_G.enterGameTime = CCUserDefault:sharedUserDefault():getIntegerForKey("game.userdef.enterGameTime")
	if _G.enterGameTime < 3 then
		_G.enterGameTime = _G.enterGameTime + 1
		CCUserDefault:sharedUserDefault():setIntegerForKey("game.userdef.enterGameTime", _G.enterGameTime)
		-- 需求改了
		-- _G.isPrePackageCannotShowUpdatePanel = true 海淘 能避税 陌生 电话
	end
end

function PrepackageUtil:showBeforeLoadingDialog(callback)
	local prepackageUtil
	local onButton1Click = function(isSaveOption)
		if isSaveOption then
			CCUserDefault:sharedUserDefault():setBoolForKey("isPrePackageNetworkOpen", true)
			local value = PrepackageNetWorkDialogState.NEVER_SHOW
			CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", value)
			if prepackageUtil then
				prepackageUtil:getInstance():setPrePackageNoNetworkMode(false)
			end
		end
		PrepackageUtil:initX5Env()
		_G.isPrePackageNoNetworkMode = false
		callback()
	end

	local onButton2Click = function(isSaveOption) 
		CCUserDefault:sharedUserDefault():setBoolForKey("isPrePackageNetworkOpen", false)
		local value = isSaveOption and PrepackageNetWorkDialogState.NEVER_SHOW or PrepackageNetWorkDialogState.NEXT_SHOW
		CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", value)
		_G.isPrePackageNoNetworkMode = true
		if prepackageUtil then
			prepackageUtil:getInstance():setPrePackageNoNetworkMode(true)
		end
		callback()
	end


	if __ANDROID then 
		prepackageUtil = luajava.bindClass("com.happyelements.android.utils.PrepackageUtils")
		CommonAlertUtil:showPrePackageNetWorkAlertPanel(onButton1Click,  onButton2Click);
	else
		callback()
	end
end

function PrepackageUtil:showSettingNetWorkDialog()
	local onButton1Click = function(isSaveOption)
		local prepackageUtil = luajava.bindClass("com.happyelements.android.utils.PrepackageUtils")
		if isSaveOption then
			CCUserDefault:sharedUserDefault():setBoolForKey("isPrePackageNetworkOpen", true)
			local value =  PrepackageNetWorkDialogState.NEVER_SHOW
			CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", value)
			if prepackageUtil then
				prepackageUtil:getInstance():setPrePackageNoNetworkMode(false)
			end
			PrepackageUtil:restart()
		else
			CCUserDefault:sharedUserDefault():setBoolForKey("isPrePackageNetworkOpen", false)
			CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", PrepackageNetWorkDialogState.NEXT_SHOW)
			if prepackageUtil then
				prepackageUtil:getInstance():setPrePackageNoNetworkMode(true)
			end
			PrepackageUtil:initX5Env()
			_G.isPrePackageNoNetworkMode = false
		end

	end

	local onButton2Click = function(isSaveOption) 
		CCUserDefault:sharedUserDefault():setBoolForKey("isPrePackageNetworkOpen", false)
		local value = isSaveOption and PrepackageNetWorkDialogState.NEVER_SHOW or PrepackageNetWorkDialogState.NEXT_SHOW
		CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", value)
	end
	CommonAlertUtil:showPrePackageNetWorkAlertPanel(onButton1Click,  onButton2Click, true);
end

function PrepackageUtil:showInGameDialog(yescallback) ---实际是commontip
	local text = {
			tip = Localization:getInstance():getText("pre.tips.network.3"),
			yes = Localization:getInstance():getText("give.back.panel.button.notification"),
			no = Localization:getInstance():getText("buy.prop.panel.not.buy.btn"),
		}
	local _yescallback = yescallback or nil 
	CommonTipWithBtn:showTip(text, "positive", _yescallback, nil, nil, true);

end

--param time重启延时的毫秒数
function PrepackageUtil:restart(time)
	if not time then time = 2000 end
	-- if __ANDROID then 
	-- 	local applicationHelper =  luajava.bindClass("com.happyelements.android.ApplicationHelper")
	-- 	applicationHelper:restart(time);
	-- end

    if __ANDROID then
        local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
        local mainActivity = mainActivityHolder.ACTIVITY
        local service = luajava.bindClass("com.happyelements.test.TestService")
        local serviceClass = service:getPrimitive()
        local intent = luajava.newInstance("android.content.Intent", mainActivity, serviceClass)
        local codes = 
          "local function __()\n" ..
          "local a=luajava.bindClass(\"com.happyelements.test.TestServiceUtils\")\n" ..
          "a:relaunchApp(1000)\n" ..
          "print('launchapp, codes done')\n" ..
          "end\n" ..
          "pcall(__)\n"
        intent:putExtra("intentinformation", codes);
        print("launchapp intent sent, codes = " .. codes)
        mainActivity:startService(intent)
        luajava.bindClass("com.happyelements.android.ApplicationHelper"):exitApp()
    end
end

function PrepackageUtil:isPreNoNetWork()
	if _G.isPlayDemo then return true end
	return _G.isPrePackage and _G.isPrePackageNoNetworkMode
	-- return true
end

local isShowDialogByLevelUp = false
function PrepackageUtil:ChangeIsShowNetworkDialog(newLevel)
	if not newLevel then return end
	if newLevel / 10 > 3 and newLevel % 10 == 1 then
		isShowDialogByLevelUp = true
	end
end

function PrepackageUtil:LevelUpShowTipToNetWork()
	if PrepackageUtil:isPreNoNetWork() and isShowDialogByLevelUp then
		-- PrepackageUtil:showInGameDialog()
		PrepackageUtil:showSettingNetWorkDialog()
		isShowDialogByLevelUp = false
	end
end

--检测是否是短代支付（预装包需求）
function PrepackageUtil:checkIsSMSPayment(paymentType)
	local payment = PaymentBase:getPayment(paymentType)
	return payment.mode == PaymentMode.kSms
end