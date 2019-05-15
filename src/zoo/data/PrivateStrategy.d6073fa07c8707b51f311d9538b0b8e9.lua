
local  privateStrategySwitch = true
local Alert = require "zoo.panel.Alert"


local txt_Alert_EditHead = "亲爱的玩家，此操作可能会涉及到您的个人信息，但我们会对您所使用的内容予以严格保密，请您放心继续操作。点击继续才可以使用此功能。"
local txt_Alert_Phone    = "亲爱的玩家，此操作可能会涉及到您的个人信息，但我们会对您所输入的内容予以严格保密，请您放心继续操作。点击继续才可以使用此功能。"
local txt_Alert_Location = "亲爱的玩家，游戏当前需要获取您的地理位置方便排行榜等功能的调用，我们会对您的信息严格保密，请您放心继续操作。点击继续才可以使用此功能。"

PrivateStrategy = {}

function PrivateStrategy:sharedInstance()
	PrivateStrategy:updateKeyData()
	return PrivateStrategy
end

function PrivateStrategy:updateKeyData(  )
	local oldKey =  CCUserDefault:sharedUserDefault():getBoolForKey("Alert_EditHead" , false)
	if oldKey then
		UserLocalLogic:setBAFlag(kBAFlagsIdx.kEditHead)
		CCUserDefault:sharedUserDefault():setBoolForKey("Alert_EditHead", false)
	end

	oldKey =  CCUserDefault:sharedUserDefault():getBoolForKey("Alert_Phone" , false)
	if oldKey then
		UserLocalLogic:setBAFlag(kBAFlagsIdx.kAlertPhone)
		CCUserDefault:sharedUserDefault():setBoolForKey("Alert_Phone", false)
	end

	oldKey =  CCUserDefault:sharedUserDefault():getBoolForKey("Alert_Location" , false)
	if oldKey then
		UserLocalLogic:setBAFlag(kBAFlagsIdx.kAlertLocation)
		CCUserDefault:sharedUserDefault():setBoolForKey("Alert_Location", false)
	end

	oldKey =  CCUserDefault:sharedUserDefault():getBoolForKey("Alert_Friends" , false)
	if oldKey then
		UserLocalLogic:setBAFlag(kBAFlagsIdx.kAlertFriends)
		CCUserDefault:sharedUserDefault():setBoolForKey("Alert_Friends", false)
	end
end

function PrivateStrategy:getKeyWithUid(key)
	return key .. "_" .. tostring(UserManager.getInstance().uid)
end

function PrivateStrategy:daysSinceAlertLastShow(alertTimeKey)
	local lastAlertTime = CCUserDefault:sharedUserDefault():getIntegerForKey(alertTimeKey , 0)
	return calcDateDiff(os.date("*t", Localhost:timeInSec()), os.date("*t", lastAlertTime))
end

function PrivateStrategy:updateAlertShowTime(alertTimeKey)
    CCUserDefault:sharedUserDefault():setIntegerForKey(alertTimeKey , Localhost:timeInSec())
	CCUserDefault:sharedUserDefault():flush()
end

--编辑头像时	上传头像时：玩家点击"+"后弹出说明面板，点击【继续】后出现拍照等按钮。
function PrivateStrategy:Alert_EditHead( finishCallback )

	if privateStrategySwitch == false then
		if finishCallback then
   			finishCallback()
   		end
   		return
	end

	local agree = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kEditHead)
   	if agree then
   		if finishCallback then
   			finishCallback()
   		end
   	else
   		-- local alertTimeKey = self:getKeyWithUid("Alert_EditHead")
   		-- if self:daysSinceAlertLastShow(alertTimeKey) < 3 then
   			-- if finishCallback then
	   		-- 	finishCallback()
	   		-- end
   		-- 	return
   		-- end

   		local function okCallback()
	    	UserLocalLogic:setBAFlag(kBAFlagsIdx.kEditHead)
    		if finishCallback then finishCallback() end
	    end

   		local text = txt_Alert_EditHead
	    local params={}
	    params.isConfirm = true
	    params.isLeft = true
	    params.isAutoSize = true
	    params.title = "政策说明"
	    params.info = text
	    params.strOK = "继续"
	    params.strCancel = "取消"
	    params.okCallback = okCallback
	    local alertPanel = Alert:create(params)
	    alertPanel:closeBackKeyTap()

	    -- self:updateAlertShowTime(alertTimeKey)
	    -- CCUserDefault:sharedUserDefault():setBoolForKey("Alert_EditHead", true)
    	-- CCUserDefault:sharedUserDefault():flush()
   	end

end
--玩家点击手机号绑定按钮后弹出	手机号绑定时：玩家点击手机号绑定按钮后弹出
function PrivateStrategy:Alert_Phone( finishCallback )

	if privateStrategySwitch == false then
		if finishCallback then
   			finishCallback()
   		end
   		return
	end
	local agree = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kAlertPhone)
   	if agree then
   		if finishCallback then
   			finishCallback()
   		end
   	else
   		-- local alertTimeKey = self:getKeyWithUid("Alert_Phone")
   		-- if self:daysSinceAlertLastShow(alertTimeKey) < 3 then
   			-- if finishCallback then
	   		-- 	finishCallback()
	   		-- end
   		-- 	return
   		-- end

   		local function okCallback()
	    	UserLocalLogic:setBAFlag(kBAFlagsIdx.kAlertPhone)
    		if finishCallback then finishCallback() end
	    end

   		local text = txt_Alert_Phone
	    local params={}
	    params.isConfirm = true
	    params.isLeft = true
	    params.isAutoSize = true
	    params.title = "政策说明"
	    params.info = text
	    params.strOK = "继续"
	    params.strCancel = "取消"
	    params.okCallback = okCallback
	    local alertPanel = Alert:create(params)
	    alertPanel:closeBackKeyTap()
	    -- CCUserDefault:sharedUserDefault():setIntegerForKey(alertTimeKey , Localhost:timeInSec())
	    -- CCUserDefault:sharedUserDefault():setBoolForKey("Alert_Phone", true)
    	-- CCUserDefault:sharedUserDefault():flush()
    	-- self:updateAlertShowTime(alertTimeKey)
   	end

end
--位置权限 填写个人资料时：点击【编辑】、【未知地区】或【未知】后，弹出说明面板，三处只要弹一次就好，点击继续面板关闭。
function PrivateStrategy:Alert_Location( finishCallback )

	if privateStrategySwitch == false then
		if finishCallback then
   			finishCallback()
   		end
   		return
	end
	local agree = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kAlertLocation)
   	if agree then
   		if finishCallback then
   			finishCallback()
   		end
   	else
   		-- local alertTimeKey = self:getKeyWithUid("Alert_Location")
   		-- if self:daysSinceAlertLastShow(alertTimeKey) < 3 then
   			-- if finishCallback then
	   		-- 	finishCallback()
	   		-- end
   		-- 	return
   		-- end

   		local function okCallback()
	    	UserLocalLogic:setBAFlag(kBAFlagsIdx.kAlertLocation)
    		if finishCallback then finishCallback() end
	    end
   		local text = txt_Alert_Phone
	    local params={}
	    params.isConfirm = true
	    params.isLeft = true
	    params.isAutoSize = true
	    params.title = "政策说明"
	    params.info = text
	    params.strOK = "继续"
	    params.strCancel = "取消"
	    params.okCallback = okCallback
	    local alertPanel = Alert:create(params)
	    alertPanel:closeBackKeyTap()
	    -- CCUserDefault:sharedUserDefault():setIntegerForKey(alertTimeKey , Localhost:timeInSec())
	    -- CCUserDefault:sharedUserDefault():setBoolForKey("Alert_Location", true)
    	-- CCUserDefault:sharedUserDefault():flush()
    	-- self:updateAlertShowTime(alertTimeKey)
   	end

end



--位置权限2 上传位置打点使用单独权限提示
function PrivateStrategy:Alert_Location_DC( finishCallback )
	self.alertLocationParams = nil

	if privateStrategySwitch == false then
		if finishCallback then
   			finishCallback()
   		end
   		return
	end
	local agree = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kLocationDCFlag)
   	if agree then
   		if finishCallback then
   			finishCallback()
   		end
   	else
   		local alertTimeKey = self:getKeyWithUid("Alert_Location_DC_Time")
   		if self:daysSinceAlertLastShow(alertTimeKey) < 3 then
   			return
   		end
	    local function okCallback()
	    	UserLocalLogic:setBAFlag(kBAFlagsIdx.kLocationDCFlag)
    		if finishCallback then finishCallback() end
	    end
	    local function cancelCallback()
	    end
   		local text = txt_Alert_Location
	    local params={}
	    params.isConfirm = true
	    params.isLeft = true
	    params.isAutoSize = true
	    params.title = "政策说明"
	    params.info = text
	    params.strOK = "继续"
	    params.strCancel = "取消"
	    params.cancelCallback = cancelCallback
	    params.okCallback = okCallback

	    self.alertLocationParams = params
	    -- Alert:create(params)
   	end

end

--添加通讯录好友时：点击【添加好友】，弹出说明面板。
function PrivateStrategy:Alert_Friends( finishCallback )

	if privateStrategySwitch == false then
		if finishCallback then
   			finishCallback()
   		end
   		return
	end

	local agree = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kAlertFriends)
   	if agree then
   		if finishCallback then
   			finishCallback()
   		end
   	else
   		-- local alertTimeKey = self:getKeyWithUid("Alert_Friends")
   		-- if self:daysSinceAlertLastShow(alertTimeKey) < 3 then
   			-- if finishCallback then
	   		-- 	finishCallback()
	   		-- end
   		-- 	return
   		-- end

   		local function okCallback()
	    	UserLocalLogic:setBAFlag(kBAFlagsIdx.kAlertFriends)
    		if finishCallback then finishCallback() end
	    end

   		local text = txt_Alert_EditHead
	    local params={}
	    params.isConfirm = true
	    params.isLeft = true
	    params.isAutoSize = true
	    params.title = "政策说明"
	    params.info = text
	    params.strOK = "继续"
	    params.strCancel = "取消"
	    params.okCallback = okCallback
	    local alertPanel = Alert:create(params)
	    alertPanel:closeBackKeyTap()

    	-- self:updateAlertShowTime(alertTimeKey)
	    -- CCUserDefault:sharedUserDefault():setIntegerForKey(alertTimeKey , Localhost:timeInSec())
	    -- CCUserDefault:sharedUserDefault():setBoolForKey("Alert_Friends", true)
    	-- CCUserDefault:sharedUserDefault():flush()
   	end

end

return PrivateStrategy