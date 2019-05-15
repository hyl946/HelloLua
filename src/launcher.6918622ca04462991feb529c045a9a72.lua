
__PURE_LUA__ = false
--timelib = require "timelib"
--print( "cur time: " .. timelib.getMilliSecond() )

if jit and jit.off then print("jit.off") jit.off() end

_G.kUseSmallResource = true
_G.kScreenWidthDefault = 720
_G.kScreenHeightDefault = 1280
_G.kDefaultSocialPlatform = "ios_all"
_G.kUserLogin = false
_G.isLocalDevelopMode = StartupConfig:getInstance():isLocalDevelopMode()
_G.bundleVersion = MetaInfo:getInstance():getApkVersion()
_G.__use_low_effect = false
_G.launcherVerion = 1
_G.enableSilentDynamicUpdate = true
_G.packageName = MetaInfo:getInstance():getPackageName() 
_G.useSmallResConfig = false
_G.enableMdoPayement = true
_G.kUserSNSLogin = false
_G.test_DripMode = 2
_G.clickOffsetY = 0 -- 点击事件偏移值
_G.isPlayDemo = (StartupConfig:getInstance():getPlatformName() == "play_demo")

_G["MACRO_" .. "DEV" .."_START"] = function () end
_G["MACRO_" .. "DEV" .."_END"] = function () end

if __WIN32 and __LAUNCH_CMD then
  require "hecore.utils"

  local function getLaunchCmds()
    local launchCmds = {}
    local cmds = string.split(__LAUNCH_CMD, " ")
    if #cmds > 1 then
      local key = nil
      for _, v in ipairs(cmds) do
        if string.starts(v, "-") then
          if key then
            launchCmds[key] = true
          end
          key = nil
          if string.len(v) > 0 then
            key = string.sub(v, 2)
          end
        elseif key then
          launchCmds[key] = v
          key = nil
        end
      end
      if key then
        launchCmds[key] = true
      end
    end
    return launchCmds
  end
  _G.launchCmds = getLaunchCmds()
  print("_G.launchCmds=", table.tostring(_G.launchCmds))
  if _G.launchCmds.md5 then
    HeGameInitializer:setMinorVersion(_G.launchCmds.md5)
  end
end

require "hecore.ClassBridge"
if _G.launchCmds then
  __PURE_LUA__ = _G.launchCmds.pureLua or false
end
if __PURE_LUA__ then
	require "plua.myGlobal"
end

_PrintLuaStack = function()
  print('<<###>> java_lua error: \n' .. debug.traceback())
end


if __WP8 then
  require "hecore.wp8.TableFunc"
end

if __WP8 or __IOS then require "bit" end

if __IOS and not LUA_WAX_ENABLE then
  require "hecore.FakeWax"
end

if __IOS then
  require "zoo.util.WaxSimpleCallback"
end

require "zoo.util.PublishActUtil"
require "hecore.utils"
require "hecore.ResourceLoader"
require "zoo.util.DcUtil"
require "zoo.util.UdidUtil"
require "zoo.util.SignatureUtil"
require "zoo.util.CommonAlertUtil"
require "hecore.gsp.GspProxy"
require "zoo.util.PrepackageUtil"
require "zoo.util.GameCrashLogDevUtil"
require "zoo.util.TimerUtil"
require "hecore.debug.printx"
require "zoo.loader.GameLauncherContext"

if __ANDROID then 
  require "zoo.util.WXJPDiffLoginUtil"
end

ResourceLoader.init()

math.randomseed( os.time() * 1000 + math.floor(os.clock() * 1000) )

local isEmulator = false

if not isLocalDevelopMode then 
  print = function() end 
  printx = function() end 
else
  initPrintx( print , { 1  , 0 , -2 , -6 , -99 } , false )  --初始化自定义print，把自己的channelId填进去，过滤你不需要的print
  --initPrintx( print , 1 , false )  --只有李扬的打印，系统打印都不显示
  --initPrintx( print , {1,-1} , false )  --只有李扬的打印和关卡内的系统打印，其余的都不显示
  --initPrintx( print , {1,2,3} , true )  --只有李扬，丹丹，文侃的打印和所有系统打印，其余的都不显示
  print = function (...) 
    printx( 0 , ...)
  end
end

local ori_he_log_err = he_log_error
function he_log_error(str)
    if not PrepackageUtil:isPreNoNetWork() then
        ori_he_log_err(str)
    end
end
local ori_he_log_warning = he_log_warning
function he_log_warning(str)
    if not PrepackageUtil:isPreNoNetWork() then
        ori_he_log_warning(str)
    end
end
local ori_he_log_info = he_log_info
function he_log_info(str)
    if not PrepackageUtil:isPreNoNetWork() then
        ori_he_log_info(str)
    end
end

GameLauncherContext:getInstance():onLauncher()
---------------------------------------------------------------------------------  Resource Initialize
if __WP8 then
  local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
  isLowDevice = frameSize.width < 500 and Wp8Utils:isLowMemoryDevice()
  _G.kUseSmallResource = isLowDevice
  _G.__use_small_res = isLowDevice
  _G.__use_low_effect = true
  _G.kDefaultSocialPlatform = "windowsphone"
  _G.kUserLogin = false
  _G.enableSilentDynamicUpdate = true
  _G.requireConnectSDK = false
  _G.useSmallResConfig = false
  _G.enableWeiboLogin = false
  _G.enableMdoPayement = false
  _G.kUserSNSLogin = false
  _G.disableActivity = true
  HeDCLog:getInstance():setDcUniqueKey("animal_wpcn_prod")
  HeDCLog:getInstance():setStore(_G.kDefaultSocialPlatform)
  HeDCLog:getInstance():setPlatform(_G.kDefaultSocialPlatform)
  if (not __WIN32 and not __DEBUG) then print = function() end end
elseif __ANDROID then
    local notificationUtil = luajava.bindClass("com.happyelements.hellolua.share.NotificationUtil")
    notificationUtil:onLuaStartup()
    if _G.isLocalDevelopMode then printx(0, "runGame():notificationUtil:onLuaStartup()") end

    _G.kDefaultCmPayment = SignatureUtil:getDefaultCmPayment( packageName )

    local function checkEmulator()
        local qemuFile = luajava.newInstance("java.io.File", "/system/lib/libc_malloc_debug_qemu.so")
        local mtpFile = luajava.newInstance("java.io.File", "/dev/mtp_usb")
        local accessoryFile = luajava.newInstance("java.io.File", "/dev/usb_accessory")
        if qemuFile:exists() and not mtpFile:exists() and not accessoryFile:exists() then
            isEmulator = true
        end
    end
    pcall(checkEmulator)

    local function initLastModifyVersion()
      local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
      _G.androidLastModifyVersion = MainActivityHolder.ACTIVITY:getLatestModify()
    end
    pcall(initLastModifyVersion)

    -- GspProxy:setGameUserId("12345") 
elseif __IOS then
    _G.__IOS_QQ = true
    GspEnvironment:getInstance():setGameUserId("12345")
elseif __WIN32 then
    _G.bundleVersion = "1.65"
end

local osVersionStr = MetaInfo:getInstance():getOsVersion() or ""
local vs = osVersionStr:split(".")
_G.sysOSVersion = tonumber(tostring(vs[1]).."."..tostring(vs[2] or 0)) or 99

if _G.launchCmds and _G.launchCmds.majorVer then
  _G.bundleVersion = _G.launchCmds.majorVer
end

HeGameDefault:setUserId("12345")
HeGameDefault:setCheckSumFactor("t*1%7z^opd@awe2&c")

-- CCDirector:sharedDirector():setDisplayStats(false)

---------------------------------------------------------------------------------  Startup
require "hecore.WrapAssert"
local function startGameDirectly()
    require "hecore.utils"
    require "hecore.ResourceLoader"
    require "zoo.util.DcUtil"
    require "zoo.util.UdidUtil"
    require "zoo.util.SignatureUtil"

    require "zoo.common.SetNotificationNode"
    require "zoo.common.LogService"
    require "zoo.config.PlatformConfig"
    require "zoo.MainApplication"
end

local dynamicUpdatePassFilterFile = {
  "hecore.lua_debugger",
  "hecore.mobdebug",
}
local function startGameAfterDynamicUpdate()
    local function unrequire(m)
        for k,v in pairs(dynamicUpdatePassFilterFile) do
          if m == v then
            return
          end
        end
        --if m == "hecore.lua_debugger" or m == "hecore.mobdebug" then return end
        package.loaded[m] = nil
        _G[m] = nil
        -- if _G.isLocalDevelopMode then printx(0, "unrequire:"..m) end
    end

    local function beginWithString(String,Start)
        return string.sub(String,1,string.len(Start))==Start
    end

    -- 动态更新后需要unrequire之前加载的lua,加载新的lua
    for k,v in pairs(package.loaded) do
        local packageName = tostring(k) or ""
        if beginWithString(packageName, "zoo.") or beginWithString(packageName, "hecore.") then unrequire(packageName) end
    end
    
    startGameDirectly()
end

local function dynamicUpdate()
    local dynamicUpdateProcessor = require("zoo.loader.DynamicUpdateProcessor")
    dynamicUpdateProcessor:start(startGameAfterDynamicUpdate, startGameDirectly)
end

local function trafficAlert()
    DcUtil:install()
    local trafficAlertProcessor = require("zoo.loader.TrafficAlertProcessor")
    trafficAlertProcessor:start(dynamicUpdate)
end

local function prePackageCheck()
    PrepackageUtil:prePackageCheck(trafficAlert)
end

local function lowDeviceDetect()
    local lowDeviceDetectProcessor = require("zoo.loader.LowDeviceDetectProcessor")
    lowDeviceDetectProcessor:start(prePackageCheck)

    if _G.isCheckPlayModeActive and tostring(_G.isCheckPlayModeActive) == "2" then

      _G.__use_small_res = true
      _G.__use_low_effect = true
      CCDirector:sharedDirector():setContentScaleFactor(0.625)

    end
end

local hadShowedSplash = false

local function gamePreGameSetting()
  if __PRE_GAME_SETTING then
    pcall(function ( ... )
        loadstring(__PRE_GAME_SETTING)()
    end)
  end
  if __SPLASH_AD_ENABLED then
    require 'hecore.notify.Notify'
    require "zoo.ads.SplashAds"
    Notify:dispatch("SplashAdShowEvent")
    hadShowedSplash = true
  end
end

--开屏广告和presetting的处理过程
--android: 在MainActivity:onCreate中发起异步http请求获取presetting、也会异步的去创建glsurface, 在glsurface的成功回调里边 调用luancher.lua, 如果此时http也已经返回那么处理开屏广告，否则就不展示广告。 
--ios: ios的presetting请求总是在 launcher被执行之后才能返回，所以对于ios，在presetting成功之后，多一步主动回调AfterGetPresetting 的过程，在此时去展示开屏广告

function AfterGetPresetting( ... )
  if not hadShowedSplash then
    gamePreGameSetting()
  end
end

require "zoo.util.SafeArea"
if __ANDROID and isEmulator then
    local builder = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
    builder:toast("开心消消乐暂时不支持在模拟器上运行！")
else
    gamePreGameSetting()
    lowDeviceDetect()
end


if(_G.GL_MAX_TEXTURE_SIZE) then
  if(false) then
    he_log_error("GL_MAX_TEXTURE_SIZE: " .. tostring(GL_MAX_TEXTURE_SIZE))
  end
end



-----------------------------------------------------
-- profiler

require("hecore/profiler")


if __PURE_LUA__ then
	require "zoo.net.Localhost"
	local cacheLocalUserData = Localhost.getInstance():readLastLoginUserData()
	
	if nil == cacheLocalUserData then
		MetaManager.getInstance():initialize()
		UserManager.getInstance():createNewUser()
	else
		if nil == cacheLocalUserData.user then
			MetaManager.getInstance():initialize()
			UserManager.getInstance():createNewUser()
		end
	end
	
	local function update(dt)
		myActionManager.getInstance():update(dt)
		myCCDirect.sharedDirector():update(dt)
	end
	--CCDirector_bak:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
	
	while(true) do
		update(1/60)
	end
	
end


------------------------------------------------------
-- test


_G._CLOUD_TEST_MODE = false




local function _testLoop()
  local list = {}
  for i = 1, 10000 do
    list[i] = i
  end
  local t1 = os.time()
  local total = 0
  for i = 1, 10000 do
    for j = 1, 10000 do
      list[i] = list[i] + list[j]
      list[i] = list[i] + list[10001 - j]
      list[10001 - i] = list[10001 - i] + list[j]
      list[10001 - i] = list[10001 - i] + list[10001 - j]
      total = total + list[i]
    end
  end
  local t2 = os.time()
  he_log_error("====================================================")
  he_log_error("LUA LOOP")
  he_log_error(t2 - t1)
  he_log_error("====================================================")
end
--_testLoop()


local _callLuaTest_v = 0
function _callLuaTest()
  _callLuaTest_v = _callLuaTest_v + 1
end

local function callNativeTest()
  local t1 = os.clock()
  for i = 1, 10000 do
    local v = _gameNative._luaCallTest(i)
  end
  local t2 = os.clock()
  he_log_error("====================================================")
  he_log_error("callNativeTest")
  he_log_error(t2 - t1)
  he_log_error("====================================================")
end
--callNativeTest()

local function _callFunTest()
  return 0
end
local function callFunTest()
  local t1 = os.clock()
  for i = 1, 10000 do
    local v = _callFunTest()
  end
  local t2 = os.clock()
  he_log_error("====================================================")
  he_log_error("callFunTest")
  he_log_error(t2 - t1)
  he_log_error("====================================================")
end
--callFunTest()

-- function PrintTable ( t )  
--     local print_r_cache={}
--     local function sub_print_r(t,indent)
--         if (print_r_cache[tostring(t)]) then
--             print(indent.."*"..tostring(t))
--         else
--             print_r_cache[tostring(t)]=true
--             if (type(t)=="table") then
--                 for pos,val in pairs(t) do
--                     if (type(val)=="table") then
--                         print(indent.."["..pos.."] => "..tostring(t).." {")
--                         sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
--                         print(indent..string.rep(" ",string.len(pos)+6).."}")
--                     elseif (type(val)=="string") then
--                         print(indent.."["..pos..'] => "'..val..'"')
--                     else
--                         print(indent.."["..pos.."] => "..tostring(val))
--                     end
--                 end
--             else
--                 print(indent..tostring(t))
--             end
--         end
--     end
--     if (type(t)=="table") then
--         print(tostring(t).." {")
--         sub_print_r(t,"  ")
--         print("}")
--     else
--         sub_print_r(t,"  ")
--     end
--     print()
-- end


--test crash
-- ahjshkhdlfas:hajlhfkjahflk()

