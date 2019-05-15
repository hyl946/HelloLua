require "hecore.utils"
require "hecore.luaJavaConvert"
require "zoo.config.NetworkConfig"

GspModuleName = table.const {
  CUSTOMERSUPPORT = "CUSTOMERSUPPORT",
  NOTIFICATION = "NOTIFICATION",
  AD = "AD",
  PAYMENT = "PAYMENT"
}

GspRetCode = table.const {
  SUCCESS = 0
}

GspPaymentChannel = table.const {
  GOOGLEIAB = "GOOGLEIAB",
  GASH = "GASH"
}

GspPaymentEvent = table.const {
  onSuccess = "onSuccess",
  onFailed = "onFailed",
  onAbort = "onAbort",
  onPending = "onPending"
}

GspGetValidSkuListEvent = table.const {
  onSuccess = "onSuccess",
  onError = "onError"
}

local GspProxyAndroid = {}

function GspProxyAndroid:init()
  if not self.instance then
    self.instance = luajava.bindClass("com.happyelements.android.gsp.GspProxy"):getInstance()
  end

  if _G.isPrePackage and not (_G.isPrePackageNoNetworkMode or self.isInited ) then
    self.isInited = true
    self.instance:onCreate(StartupConfig:getInstance():getPlatformName())
  end
  pcall(function ()
    self.instance:setGamePlatfromForGSP(StartupConfig:getInstance():getPlatformName())
    self.instance:setHostForGSP(NetworkConfig.dynamicHost)
  end)
end

function GspProxyAndroid:showCustomerDiaLog()
  self.instance:showCustomerDiaLog()
end

function GspProxyAndroid:getFaqRepayCount(userId,lastFaqPingTime,url)
  self.instance:getFaqRepayCount(userId,lastFaqPingTime,url)
end

function GspProxyAndroid:setGameUserId(uid)
  self.instance:setGameUserIdForGSP(uid)
  luajava.bindClass("com.happyelements.android.UserIdHolder"):setUserId(uid)

  if uid then
    require "zoo.push.PushManager"
	PushManager:setAccount(tostring(uid))
	PushManager:setAlias(tostring(uid))
  end
end

function GspProxyAndroid:setFAQurl(url)
  self.instance:setHelpUrlForGsp(url)  
end

function GspProxyAndroid:setExtraParams(params)
  self.instance:setExtraParams(luaJavaConvert.table2Map(params))  
end

local function createTransactionCallback(callback)
  local transactionCallback = luajava.createProxy("com.happyelements.gsp.android.payment.TransactionCallback",
    {
      onSuccess = function(orderId)
        callback(GspPaymentEvent.onSuccess, { orderId = orderId })
      end,
      onFailed = function(errorCode, message)
        callback(GspPaymentEvent.onFailed, { errorCode = errorCode:getValue(), message = message })
      end,
      onAbort = function(orderId)
        callback(GspPaymentEvent.onAbort, { orderId = orderId })
      end,
      onPending = function(orderId)
        callback(GspPaymentEvent.onPending, { orderId = orderId })
      end
    }
  )
  return transactionCallback
end

function GspProxyAndroid:getValidSkuList(channelId, channelParams, filterSkuIds, locale, callback)
  local m_callback = luajava.createProxy("com.happyelements.gsp.android.base.CallbackBase",
    {
      onSuccess = function(data)
        local t1 = luaJavaConvert.list2Table(data)
        local t2 = {}
        for i,v in ipairs(t1) do
          local t = {}
          t.currency = v:getCurrency()
          t.description = v:getDescription()
          t.orgData = v:getOrgData()
          t.price = v:getPrice()
          t.skuId = v:getSkuId()
          t.title = v:getTitle()
          t.type = v:getType()
          table.insert(t2, t)
        end
        callback(GspGetValidSkuListEvent.onSuccess, t2)
      end,
      onError = function(errorCode, message)
        callback(GspGetValidSkuListEvent.onError, { errorCode = errorCode:getValue(), message = message })
      end
    }
  )
  -- self.instance:getPaymentProxy():getValidSkuList(channelId, luaJavaConvert.table2Map(channelParams), luaJavaConvert.table2List(filterSkuIds), locale, m_callback)
end

local GspProxyIOS = {}

GspProxy = nil

if __ANDROID then
  GspProxyAndroid:init()
  GspProxy = GspProxyAndroid
elseif __IOS then
  GspProxy = GspProxyIOS
end

