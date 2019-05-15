local PermissionAlertPanel = require "zoo.permission.PermissionAlertPanel"

PermissionManager = class()

PermissionsConfig = {
	["READ_CALENDAR"] 				= "read_calendar", 				--"android.permission.READ_CALENDAR"
	["WRITE_CALENDAR"] 				= "write_calendar",				--"android.permission.WRITE_CALENDAR"
	["CAMERA"] 						= "camera",						--"android.permission.CAMERA"
	["READ_CONTACTS"] 				= "read_contacts",				--"android.permission.READ_CONTACTS"
	["WRITE_CONTACTS"] 				= "write_contacts",				--"android.permission.WRITE_CONTACTS"
	["GET_ACCOUNTS"] 				= "get_accounts",				--"android.permission.GET_ACCOUNTS",
	["ACCESS_FINE_LOCATION"] 		= "access_fine_location",		--"android.permission.ACCESS_FINE_LOCATION"
	["ACCESS_COARSE_LOCATION"] 		= "access_coarse_location",		--"android.permission.ACCESS_COARSE_LOCATION"
	["RECORD_AUDIO"] 				= "record_audio",				--"android.permission.RECORD_AUDIO"
	["READ_PHONE_STATE"] 			= "read_phone_state",			--"android.permission.READ_PHONE_STATE"
	["CALL_PHONE"] 					= "call_phone",					--"android.permission.CALL_PHONE"
	["READ_CALL_LOG"] 				= "read_call_log",				--"android.permission.READ_CALL_LOG"
	["WRITE_CALL_LOG"] 				= "write_call_log",				--"android.permission.WRITE_CALL_LOG"
	["ADD_VOICEMAIL"]				= "add_voicemail",				--"android.permission.ADD_VOICEMAIL"
	["USE_SIP"] 					= "use_sip",					--"android.permission.USE_SIP"
	["PROCESS_OUTGOING_CALLS"] 		= "process_outgoing_calls",		--"android.permission.PROCESS_OUTGOING_CALLS"
	["BODY_SENSORS"] 				= "body_sensors",				--"android.permission.BODY_SENSORS"
	["SEND_SMS"] 					= "send_sms",					--"android.permission.SEND_SMS"
	["RECEIVE_SMS"] 				= "receive_sms",				--"android.permission.RECEIVE_SMS"
	["READ_SMS"] 					= "read_sms",					--"android.permission.READ_SMS"
	["RECEIVE_WAP_PUSH"] 			= "receive_wrap_push",			--"android.permission.RECEIVE_WAP_PUSH"
	["RECEIVE_MMS"] 				= "receive_mms",				--"android.permission.RECEIVE_MMS"
	["READ_EXTERNAL_STORAGE"] 		= "read_external_storage",		--"android.permission.READ_EXTERNAL_STORAGE"
	["WRITE_EXTERNAL_STORAGE"] 		= "write_external_storage",		--"android.permission.WRITE_EXTERNAL_STORAGE"
}  

local instance
function PermissionManager.getInstance()
	if not instance then
		instance = PermissionManager.new()
		instance:init()
	end
	return instance
end

function PermissionManager:init()
	if __ANDROID then 
		self._instance = luajava.bindClass("com.happyelements.android.permissions.PermissionProxy"):getInstance()
	elseif __IOS then
		--There should be a unified class like PermissionProxy control the permissions for ios. (to do)
	end
end

function PermissionManager:gotoSetting()
	if __ANDROID then 
		self._instance:gotoSetting()
	end
end
--__ANDROID
function PermissionManager:hasPermissions(permissionNames)
	if __ANDROID then
		local permissionList = luajava.newInstance("java.util.ArrayList")
		for i,v in ipairs(permissionNames) do
			assert(table.keyOf(PermissionsConfig, v), "invalid permission:" .. v)
			permissionList:add(v)
		end
		return self._instance:hasPermissions(permissionList)
	end
	return true
end

function PermissionManager:hasPermission(permissionName)
	if __ANDROID then
		return self._instance:hasPermission(permissionName)
	elseif __IOS and permissionName == PermissionsConfig.ACCESS_FINE_LOCATION then
		return LocationManager_All:hasPermissions()
	end
	return true
end

function PermissionManager:showPermissionAlertPanel(permissionName, onSuccess, onFail)
	local panel = PermissionAlertPanel:create(permissionName, onSuccess, onFail)
	panel:popout()
end

function PermissionManager:buildCallback(onSuccess, onFail)
	assert(type(onSuccess) == "function", "invalid funtion onSuccess")

	local function _onDeny(permissionErrMsg)
		if onFail then onFail() end
	end

	local function _onDenyNeverAsk(permissionErrMsg)
		if onFail then onFail() end
		self:gotoSetting()
	end

	local sdkCallback = luajava.createProxy("com.happyelements.android.permissions.PermissionCallback", {
        onGrant = onSuccess,
        onDeny = _onDeny,
        onDenyNeverAsk = _onDenyNeverAsk
    })
	return sdkCallback
end

function PermissionManager:requestEach(permissionName, onSuccess, onFail)
	assert(table.keyOf(PermissionsConfig, permissionName), "invalid permission:" .. permissionName)

	if self:hasPermission(permissionName) then
		if onSuccess then onSuccess() end
	else
		if __ANDROID then 
			self:showPermissionAlertPanel(permissionName, function ()
				self._instance:requestPermissionsEach(permissionName, self:buildCallback(onSuccess, onFail))
			end, onFail)
		elseif __IOS then
			if permissionName == PermissionsConfig.ACCESS_FINE_LOCATION then
				self:showPermissionAlertPanel(permissionName, function ()
					LocationManager_All:gotoPermissionsSetting()
				end, onFail)
			else
				if onFail then onFail() end
			end
		else
			if onFail then onFail() end
		end
	end
end

function PermissionManager:requestCombined(permissionNames, onSuccess, onFail)
	local _permissionNames = {}
	if _G.isLocalDevelopMode then
		for i,v in ipairs(permissionNames) do
			assert(table.keyOf(PermissionsConfig, v), "invalid permission:" .. v)
		end
	else
		_permissionNames = permissionNames
	end

	if self:hasPermissions(_permissionNames) then
		if onSuccess then onSuccess() end
	else
		local permissionList = luajava.newInstance("java.util.ArrayList")
		for i,v in ipairs(_permissionNames) do
			permissionList:add(v)
		end
		self._instance:requestPermissionsCombined(permissionList, self:buildCallback(onSuccess, onFail))
	end
end