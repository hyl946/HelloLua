require "hecore.utils"
require 'zoo.ui.layout.mylayout'

ResCallbackEvent = table.const {
  onSuccess = "onSucess",
  onError = "onError",
  onProcess = "onProcess",
  onPrompt = "onPrompt"
}

ResourceLoader = { }

function ResourceLoader.init()
  return ResManager:getInstance():initStaticConfig();
end

function ResourceLoader.getCurVersion()
  return ResManager:getInstance():getCurVersion()
end

function ResourceLoader.getFileSize(virtualPath)
  return ResManager:getInstance():getFileSize(virtualPath)
end 

function ResourceLoader.loadRequiredRes(callback)
  local function onSuccess(data)
    callback(ResCallbackEvent.onSuccess, { items = data })
  end
  local function onError(errorCode, item)
    callback(ResCallbackEvent.onError, { errorCode = errorCode, item = item })
  end
  local function onProcess(process)
    callback(ResCallbackEvent.onProcess, process)
  end
  ResManager:getInstance():loadRequiredRes(onSuccess, onError, onProcess)
end

function ResourceLoader.loadRequiredResWithPrompt(callback, isNeedSpeedLimit)
  isNeedSpeedLimit = isNeedSpeedLimit or false
  if _G.isLocalDevelopMode then printx(0, "ResourceLoader.loadRequiredResWithPrompt(callback)") end
  local function onSuccess(data)
    if _G.isLocalDevelopMode then printx(0, "ResourceLoader.loadRequiredResWithPrompt(callback):onSuccess") end
    callback(ResCallbackEvent.onSuccess, { items = data })
  end
  local function onError(errorCode, item)
    if _G.isLocalDevelopMode then printx(0, "ResourceLoader.loadRequiredResWithPrompt(callback):onError") end
    callback(ResCallbackEvent.onError, { errorCode = errorCode, item = item })
  end
  local function onProcess(process)
    if _G.isLocalDevelopMode then printx(0, "ResourceLoader.loadRequiredResWithPrompt(callback):onProcess") end
    callback(ResCallbackEvent.onProcess, process)
  end
  local function onPrompt(data)
    if _G.isLocalDevelopMode then printx(0, "ResourceLoader.loadRequiredResWithPrompt(callback):onPrompt") end
    callback(ResCallbackEvent.onPrompt, { status = data, resultHandler = function(r) 
            ResManager:getInstance():notifyPromptResult(r)
          end })
  end
  ResManager:getInstance():loadRequiredResWithPrompt(onSuccess, onError, onProcess, onPrompt, isNeedSpeedLimit)
  if _G.isLocalDevelopMode then printx(0, "~ResourceLoader.loadRequiredResWithPrompt(callback)") end
end

function ResourceLoader.loadSpecifiedRes(virtualPaths, callback)
  local function onSuccess(data)
    callback(ResCallbackEvent.onSuccess, data)
  end
  local function onError(errorCode, item)
    callback(ResCallbackEvent.onError, { errorCode = errorCode, item = item })
  end
  local function onProcess(process)
    callback(ResCallbackEvent.onProcess, process)
  end
  ResManager:getInstance():loadSpecifiedRes(virtualPaths, onSuccess, onError, onProcess)
end

function ResourceLoader.loadThirdPartyRes(urls, callback)
  local function onSuccess(data)
    callback(ResCallbackEvent.onSuccess, data)
  end
  local function onError(errorCode, item)
    callback(ResCallbackEvent.onError, { errorCode = errorCode, item = item })
  end
  ResManager:getInstance():loadThirdPartyRes(urls, onSuccess, onError)
end


