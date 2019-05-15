--GameCrashLogDevUtil.lua
function showErrorLog(crashMsg)
  if __WIN32 then return false end
  
  if not crashMsg or string.len(crashMsg) == 0 then
    crashMsg = "There is no crash message"
  end

  local visiableToUser = false
  if StartupConfig:getInstance():isLocalDevelopMode() then
    visiableToUser = true
  end

  if not visiableToUser then
    local userType = UserManager and UserManager.getInstance().userType or 0
    if userType == 1 then
      visiableToUser = true
    end 
  end

  -- if not visiableToUser then
  --   if MaintenanceManager and MaintenanceManager:getInstance():isEnabled("showCrashLog") then
  --     visiableToUser = true
  --   end
  -- end

  if visiableToUser then
    local ErrorLogScene = require("zoo.scenes.ErrorLogScene")
    if not ErrorLogScene then 
      return false 
    end

    ClipBoardUtil.copyText(crashMsg)
    local errorLogScene = ErrorLogScene:create(crashMsg)
    local scene = CCDirector:sharedDirector():getRunningScene()
    if scene then
      CCDirector:sharedDirector():replaceScene(errorLogScene.refCocosObj) 
    else
      CCDirector:sharedDirector():runWithScene(errorLogScene.refCocosObj)
    end
    return true
  else
    return false
  end
end

local crashHandled = false -- 防止处理时出错发生循环调用
-- params
--    string crashMsg,崩溃日志
--    boolean isLuaError 是否是lua线程崩溃
-- return
--    boolean 返回true关闭游戏
function onAnimalCrashOccurred(crashMsg, isLuaError)
  if crashHandled then return true end
  crashHandled = true

  _G.__GAME_CRASHED__ = true
  _G.__GAME_CRASH_MSG__ = crashMsg

  if GlobalEventDispatcher then
    GlobalEventDispatcher:getInstance():dp(Event.new("lua_crash", {errorMsg=crashMsg}))
  end
  local success, ret = pcall(showErrorLog, crashMsg)
  if success then
    if type(ret) == "boolean" and ret == true then
      return false
    end
  else
    he_log_error("showErrorLog failed:"..tostring(ret))
  end
  return true
end