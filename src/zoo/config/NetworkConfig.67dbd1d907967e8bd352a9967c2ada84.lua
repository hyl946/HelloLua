-- 为了测试修改成测试服务器
local dynamicHost = "http://10.130.137.97/"

-- local dynamicHost = "http://well.happyelements.net/mobile/";
-- local dynamicHost = "http://c4413078.ngrok.io/"; -- 王阳 的 4g 访问 97 dev

-- local dynamicHost = "http://animalmobile.happyelements.cn/";
-- local dynamicHost = "http://mobile.app100718846.twsapp.com/";

-- local dynamicHost = "http://10.130.136.67/"; -- 柴智的机器
-- local dynamicHost = "http://10.130.136.61/"; -- 小强的机器
-- local dynamicHost = "http://10.130.138.45:8080/"; -- 邓喆
-- local dynamicHost = "http://10.130.137.118/" -- 方州的机器
-- local dynamicHost = "http://10.130.139.200:8083/animal-web" --熊熊的机器
-- local dynamicHost = 'http://10.130.136.100/' -- 王阳
-- local dynamicHost = "http://10.130.136.89/";
-- local dynamicHost = "http://10.130.136.139/"; --团子
-- local dynamicHost = "http://10.130.148.156:8080/";
-- local dynamicHost = "http://10.130.150.214:8010/animal-web/"--王阳

if __IOS_FB then
	dynamicHost = "http://animal.he-games.com/" -- IOS_FB线上
 	-- dynamicHost = "http://10.130.148.156:8080/";
	-- dynamicHost = "http://10.130.136.136:80/";
	-- dynamicHost = "http://10.130.136.29:8011/"; -- IOS_FB DEV
end

if not StartupConfig:getInstance():isLocalDevelopMode() then -- release 版本
	dynamicHost = StartupConfig:getInstance():getDynamicHost()
else
	-- require "zoo.util.NetworkUtil"
	-- if (__ANDROID or __IOS) and not NetworkUtil:isEnableWIFI() then
	-- 	dynamicHost = "http://91d39d05.ngrok.io/"
	-- end
end

if __WP8 then
	dynamicHost = StartupConfig:getInstance():getDynamicHost()
end

NetworkConfig = {
	alwaysShowCG = false,
	noNetworkMode = false,
	useLocalServer = true,
	showDebugButtonInPreloading = false,
	mockQzoneSk = nil, --"mobile3",
	writeLocalDataStorage = true,  --for test, all local HTTP serverce do not write data to player device.
	redirectURL = dynamicHost .. "redirect.jsp",
	rpcURL = dynamicHost .. "protocol",--"http://well.happyelements.net/animal-mobile/protocol",
	registerURL = dynamicHost .. "reg",--"http://well.happyelements.net/animal-mobile/reg",
	maintenanceURL = dynamicHost .. "config",
	appstoreURL = "itms-apps://itunes.apple.com/app/id791532221",
	dynamicHost = dynamicHost,
	qqDownloadURL = "http://a.app.qq.com/o/simple.jsp?pkgname=com.happyelements.AndroidAnimal.qq",
	wxzQQDowanloadURL = "http://a3.app.qq.com/o/simple.jsp?pkgname=com.happyelements.AndroidAnimal.qq",
	wxzHEDowanloadURL = "http://a.app.qq.com/o/simple.jsp?pkgname=com.happyelements.AndroidAnimal",
}

local AlternativeShareHost = 'http://animaltgz.happyelements.cn/'

function NetworkConfig:getShareHost( ... )
	if not _G.isLocalDevelopMode then
		if PlatformConfig:isQQPlatform() then
			return AlternativeShareHost
		end
	end
	return NetworkConfig.dynamicHost
end

-- "http://well.happyelements.net/protocol", --"http://10.130.136.29/protocol?uid=" .. tostring(uid),

--http://10.130.137.97/config?name=static
--http://animalmobile.happyelements.cn/config?name=static
--http://10.130.137.97/ciservice/projects/com.happyelements.1OSAnimal/1.1.248/HelloLua.ipa