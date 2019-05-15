--[[
 * InciteConfig
 * @date    2018-08-27 19:22:54
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
require "zoo.panel.incite.IosAd"
require "zoo.panel.incite.WinAd"

local WIN32_ADS = 0
local UNITY_ADS = 1
local APPLOVIN_ADS = 2
local VUNGLE_ADS = 3
local CHANCE_ADS = 4
local MOBVISTA_ADS 	= 5
local WINDSDK_ADS = 6
local CENTRIXLINK_ADS = 7
local IRON_SOURCE_ADS = 8
local ADMOB_ADS = 9
local SIGMOB_ANDROID = 10
local ANDROID_360 = 11
local ANDROID_ALI = 12

AdsFinishState = {
	kNotCompleted = 0,
	kCompleted = 1,
	kFinishError = 2,
}

EntranceType = {
	kPassLevel = 1,
	kFAQ = 2,
	kStartLevel = 3,
	kTree = 4,
}

AdsError = {
	kUnknow = 0,
	kNotInitialized = 1,
	kInitializedFailed = 2,
	kNotSupported = 3,
	kPlayError = 4,
	kSDKInternalError = 5,
	kVideoNotReady = 6,
	kVideoRequestError = 7,
	kNetError = 8,
}

local function create_ios(flag, name )
	if not __IOS then
		return {}
	end
	return {
		flag = flag,
		delegate = IosAd.new(name, flag)
	}
end

local function create_android(flag, delegateName)
	if not __ANDROID then
		return {}
	end

	local delegate
	pcall(function ()
		delegate = luajava.bindClass(delegateName).INSTANCE
	end)

	return {
		flag = flag,
		delegate = delegate,
	}
end

InciteConfig = {
	["Win32Ad"] = {flag = WIN32_ADS, delegate = WinAd.new()},
	["Windmill"] = create_ios(WINDSDK_ADS, "Windmill"),
	["SigmobAndroid"] = create_android(SIGMOB_ANDROID, "com.happyelements.AndroidAnimal.ads.SigmobAd"),
	["360"] = create_android(ANDROID_360, "com.happyelements.AndroidAnimal.ads.lib360ad.QihooAd"),
	["alisdk"] = create_android(ANDROID_ALI, "com.happyelements.AndroidAnimal.ads.AliAd"),
}