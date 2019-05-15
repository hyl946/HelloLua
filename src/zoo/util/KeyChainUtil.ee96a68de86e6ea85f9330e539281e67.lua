KeyChainUtil = {}

local project = "animal"
KeyChainType = {
	APPLE_TOKEN = {group = "com.apple.token", withPrefix = false},
	SHARE_GROUP = {group = "group.happyelements.sharedata", withPrefix = false},  -- 正式包才有
	APP_GROUP 	= {group = "com.happyelements.1OSAnimal", withPrefix = true}, -- 测试包和正式包group前缀不同
}

function KeyChainUtil:getValue(key, dftValue, keyChainType)
	if __IOS then
		keyChainType = keyChainType or KeyChainType.APP_GROUP
		-- 无值时ret会返回"",注意处理
		local ret = AppController:readDataFromKeychainGroup_key_group_prefix(project, key, keyChainType.group, keyChainType.withPrefix)
		if ret == nil or ret == "" then
			return dftValue
		else
			return ret
		end
	elseif __ANDROID then
		local AndroidKeyChainUtils = luajava.bindClass("com.happyelements.android.AndroidKeyChainUtils")
		return AndroidKeyChainUtils:getKeyChain(project, key, dftValue)
	else
		return CCUserDefault:sharedUserDefault():getStringForKey(key, dftValue) 
	end
end

function KeyChainUtil:setValue(key, value, keyChainType)
	local ret = true
	if __IOS then
		keyChainType = keyChainType or KeyChainType.APP_GROUP
		ret = AppController:writeDataToKeychainGroup_key_value_group_prefix(project, key, value, keyChainType.group, keyChainType.withPrefix)
	elseif __ANDROID then
		local AndroidKeyChainUtils = luajava.bindClass("com.happyelements.android.AndroidKeyChainUtils")
		ret = AndroidKeyChainUtils:setKeyChain(project, key, value)
	else
		CCUserDefault:sharedUserDefault():setStringForKey(key, value) 
	end
	return ret
end