
module("rpc", package.seeall)

require "hecore.class"
require "hecore.utils"
require "hecore.zlib"
require "hecore.EventDispatcher"

require "zoo.util.UserContext"

local uuid = require "hecore.uuid"

--
-- Constants Definition --------------------------------------------------
--

SendingPriority = table.const {
    kHigh = "high",
    kNormal = "normal",
    kLow = "low"
}

ChannelEvent = table.const {
    kAvailable = "available",
    kServerError = "serverError",
    kIOError = "ioError",
    kTimeout = "timeout",
    kComplete = "complete"
}

InternalError = table.const {
    kDefaultError = -1,
    kNetworkError = -2,
    kTimeoutError = -3,
    kServerError = -4,
    kNoNetwork = -6,
    kServiceUnavailable = -7,
}

HttpStatus = table.const {
    HTTP_STATUS_NONE = 0,
    HTTP_OK = 200,
    HTTP_NULL_PTR = 206,
    HTTP_SERVICE_UNAVAILABLE = 503,
}

HEADER_COUNTER_FOR_OUTOFBAND = -999
GIP_SESSION_KEY_DELAY = 60 * 15                     -- 15分钟

--
-- RpcRequest --------------------------------------------------
--

local RpcRequest = class()
local RpcResponse = class()

function RpcRequest:ctor(endpoint, data, handler, priority, outOfBand)
    self.endpoint = endpoint
    self.data = data
    self.handler = handler
    self.priority = priority
    self.outOfBand = outOfBand
end

function RpcResponse:ctor(endpoint, data, err, message, isEvent)
    self.endpoint = endpoint
    self.data = data
    self.error = err
    self.message = message
    self.isEvent = isEvent
end

--
-- HTTPChannel --------------------------------------------------
--

-- callback = function(retry) end               -- retry:boolean
-- function(callback) end
networkErrorIntercaptor = nil

HTTPChannel = class(EventDispatcher)

local sendCallback
local isJustBlockRequest -- use for add speed limit for HttpRequest

function HTTPChannel:ctor()
    self.closed = true
end

function HTTPChannel:send(url, bytes, timeout, retryTimes)
    self.closed = false
    self.timeout = timeout
    self.retryTimes = retryTimes
    local request = HttpRequest:createPost(url)
    if isJustBlockRequest and not _G.skipHttpSpeedLitmit then
        isJustBlockRequest = false
        request:setLowSpeedLimit(5 * 1000)
        request:setLowSpeedTimeoutSeconds(15)
    end
    request:setConnectionTimeoutMs(timeout * 1000)
    request:setTimeoutMs(30 * 1000)

    request:addHeader("Content-Type:application/octet-stream")
    request:setPostData(bytes, bytes:len())
    
    
    local callbackHanler       -- 必须前置声明，否则在闭包本身内访问为nil
    local channel= self
    callbackHanler = function(response)
        channel:close()
        
        if response.httpCode ~= 200 and type(networkErrorIntercaptor) == "function" then
            networkErrorIntercaptor(function(retry) 
                    if retry then 
                        channel:send(url, bytes, timeout, retryTimes) 
                    else
                        sendCallback(response, channel) 
                    end
                end)
        else
            sendCallback(response, channel)
        end
    end
    
    if PrepackageUtil:isPreNoNetWork() then
        local fake_response = {httpCode = HttpStatus.HTTP_STATUS_NONE}
        channel:close()
        sendCallback(fake_response, channel)
    else
        HttpClient:getInstance():sendRequest(callbackHanler, request)
    end
end

function HTTPChannel:close()
    self.closed = true
end

function HTTPChannel:dispose()
end

sendCallback = function(response, channel)
    local validateHttp = function(dnsSuccess)
        printx(0, "=========    validate http    =========")

        local request = HttpRequest:createPost('119.29.247.253')
        request:setConnectionTimeoutMs(2 * 1000)
        request:setTimeoutMs(30 * 1000)

        request:addHeader("Content-Type:application/octet-stream")
        request:setPostData(nil, 0)

        local callbackHanler = function(response)
            local ipSuccess = (response.httpCode == 200)
            if(ipSuccess) then
                local msg = "validate http: dns:" .. tostring(dnsSuccess) .. ', ip:' .. tostring(ipSuccess)
                he_log_error(msg)
            end
--            debug.debug()
        end

        HttpClient:getInstance():sendRequest(callbackHanler, request)
    end


    if response.httpCode == HttpStatus.HTTP_OK then
         channel:dispatchEvent(Event.new(ChannelEvent.kComplete, response, channel))
--         validateHttp(true)
    else
         channel:dispatchEvent(Event.new(ChannelEvent.kIOError, response.httpCode, channel))
--         validateHttp(false)
    end
end

--
-- ChannelRegistry ----------------------------------------------
--

local ChannelRegistry = class(EventDispatcher)

function ChannelRegistry:ctor(channelClass, maxChannel)
    self.channelClass = channelClass
    self.maxChannel = type(maxChannel) == "number" and math.max(1, maxChannel) or 1
    self.enabledPool = {}
    self.busyingPool = {}
end

function ChannelRegistry:apply()
    local channel
    if #self.enabledPool > 0 then
        channel = table.remove(self.enabledPool)
    elseif #self.busyingPool < self.maxChannel then
        channel = self.channelClass.new()
    end
    if channel then table.insert(self.busyingPool, channel) end
    return channel
end

function ChannelRegistry:release(channel)
    local index = table.indexOf(self.busyingPool, channel)
    if index then
        if (not channel.closed) then channel:close() end
        table.remove(self.busyingPool, index)
        table.insert(self.enabledPool, channel)
        self:dispatchEvent(Event.new(ChannelEvent.kAvailable, null, self))
    end
end

function ChannelRegistry:dispose()
    for i, channel in ipairs(self.enabledPool) do
        channel:dispose()
    end
    for i, channel in ipairs(self.busyingPool) do
        channel:dispose()
    end

    self.channelClass = nil
    self.enabledPool = nil
    self.busyingPool = nil
end

--
-- RpcProcessor ----------------------------------------------
--

local RpcProcessor = class()

local checkAuthorizable
local getQueueEffectiveLength
local extractAllStack
local getAllStackLength
local onChannelCallback
local startCommunication
local doProcess

function RpcProcessor:ctor(url, timeout, retryTimes, channelClass, maxChannel, sessionKeySource, skDelay)
    self.url = url
    self.timeout = timeout
    self.retryTimes = retryTimes
    self.sessionKeySource = sessionKeySource
    self.skDelay = skDelay
    self.queue = {}
    self.holders = {}
    self.stackRegistry = {}
    self.outOfBandQueue = {}
    self.convertorRegistry = {}
    self.handlerRegistry = {}

    self.channelRegistry = ChannelRegistry.new(channelClass, maxChannel)
    self.channelRegistry:addEventListener(ChannelEvent.kAvailable, function(event)
            local processor = event.context
            processor:process(false, event)
        end, self)
end

function RpcProcessor:process(immediately, event)
    if #self.outOfBandQueue > 0 or checkAuthorizable(self, immediately) then 
        local timediff = self.timediff or 0
        if self.sessionKey and self.timestamp and self.timestamp - timediff > os.time() + self.skDelay then
            doProcess(event, self)
        elseif not self.sessionRefreshing then
            local processor = self
            local callback = function(sessionKey, timestamp)
                processor.sessionRefreshing = nil
                processor.sessionKey = sessionKey
                processor.timestamp = timestamp
                processor.convertorRegistry.assembleConvertor:updata(sessionKey)
                doProcess(event, processor)
            end
            self.sessionRefreshing = true
            self.sessionKeySource(callback, self.sessionKey)
        end
    end
end

function RpcProcessor:dispose()
    self.channelRegistry:removeEventListener(ChannelEvent.kAvailable, doProcess)
    self.channelRegistry:dispose()
    self.queue = nil
    self.holders = nil
    self.stackRegistry = nil
    self.channelRegistry = nil
    self.convertorRegistry = nil
    self.handlerRegistry = nil
end

checkAuthorizable = function(processor, immediately)
    local length = immediately and #processor.queue or getQueueEffectiveLength(processor.queue)
    processor.authorizedToSend = length > 0 or getAllStackLength(processor.stackRegistry) > 0
    return processor.authorizedToSend
end

getQueueEffectiveLength = function(queue)
    local length = 0
    for i, request in ipairs(queue) do
        if SendingPriority.kLow ~= request.priority then length = length + 1 end
    end
    return length
end

extractAllStack = function(stackRegistry)
    local requests = {}
    for k, stack in pairs(stackRegistry) do
        local request = stack:extract()
        if request then table.insert(requests, request) end
    end
    return requests
end

getAllStackLength = function(stackRegistry)
    local size = 0
    for k, stack in pairs(stackRegistry) do
        if stack.request then size = size + 1 end
    end
    return size
end

doProcess = function(event, processor)
    if (not event) or ChannelEvent.kAvailable == event.name then
        processor = processor or event.context
        local channelRegistry = processor.channelRegistry
        if (not processor.queueSending) and processor.authorizedToSend then
            local channel = channelRegistry:apply()
            if channel then
                local requests = table.union(processor.queue, extractAllStack(processor.stackRegistry))
                local endpoints = {} for i, v in ipairs(requests) do table.insert(endpoints, v.endpoint) end
                local sessionString = " uid: "..processor.uid .. " sk:" .. processor.sessionKey
                he_log_info(" [RPC] startCommunication: " .. table.concat(endpoints, ",") .. sessionString)
                table.removeAll(processor.queue)
                processor.queueSending = true
                processor.authorizedToSend = false
                startCommunication(processor, channel, requests)
            end
        end
        local outOfBandQueue = processor.outOfBandQueue
        if #outOfBandQueue > 0 then
            local channel = channelRegistry:apply()
            if channel then
                local requests = {}
                for i, request in ipairs(outOfBandQueue) do
                    table.insert(requests, request)
                end
                table.removeAll(outOfBandQueue)
                startCommunication(processor, channel, requests, true)
            end
        end
    end
end

startCommunication = function(processor, channel, requests, outOfBand)
    local convertorRegistry = processor.convertorRegistry
    local assembleConvertor = convertorRegistry.assembleConvertor
    if convertorRegistry.packageConvertors then
        for i, convertor in ipairs(convertorRegistry.packageConvertors) do
            requests = convertor:convertD(requests)
        end
    end
    if assembleConvertor then
        local bytes = assembleConvertor:convertD(requests, processor.uid)
        if convertorRegistry.binaryConvertors then
            for i, convertor in ipairs(convertorRegistry.binaryConvertors) do
                bytes = convertor:convertD(bytes)
            end
        end

        local url = processor.url .. (string.find(processor.url, "?") and "&uid=" or "?uid=") .. processor.uid .. "&_t=" .. os.time() .. "&_v=" .. bundleVersion 
		--白名单
        --url = url .. "&whiteList=qatest"
        
        if _G.isLocalDevelopMode then
            local endpointStr = ""
            for i, v in ipairs(requests) do 
                endpointStr = endpointStr .. v.endpoint .."_"
            end
            url = url .. "&_m=" .. endpointStr
        end

        local holder = table.const {
            url = url,
            bytes = bytes,
            requests = requests,
            outOfBand = outOfBand and true or false
        }
        processor.holders[channel] = holder
        
        --he_log_info("communication url " .. url)

        channel:addEventListener(ChannelEvent.kComplete, onChannelCallback, processor)
        channel:addEventListener(ChannelEvent.kIOError, onChannelCallback, processor)
        channel:addEventListener(ChannelEvent.kServerError, onChannelCallback, processor)
        channel:send(url, bytes, processor.timeout, processor.retryTimes)
    else
        he_log_error("Error : missing protocol assemble convertor for RpcTransponder")
    end
end

local ignoreErrorType = {
    [203] = true, -- the request before this one failed
    [206] = true, -- nullptr error,handler by server
}

onChannelCallback = function(event)
    local channel = event.target
    local processor = event.context
    local holder = processor.holders[channel] 

    processor.holders[channel] = nil
    channel:removeEventListener(ChannelEvent.kComplete, onChannelCallback)
    channel:removeEventListener(ChannelEvent.kIOError, onChannelCallback)
    channel:removeEventListener(ChannelEvent.kServerError, onChannelCallback)
    
    if not holder.outOfBand then
        processor.queueSending = false
    end
    processor.channelRegistry:release(channel)

    local handlerRegistry = processor.handlerRegistry
    local convertorRegistry = processor.convertorRegistry
    local responses, err, ts
    
    if ChannelEvent.kComplete == event.name then
        local http_response = event.data
        local bytes = http_response.body
        local headers = http_response.headers
        if not headers or not table.includes(headers, "Content-Type: application/octet-stream") then
            bytes = nil
        end
        local binaryConvertors = convertorRegistry.binaryConvertors
        if binaryConvertors then
            for i = #binaryConvertors, 1, -1 do
                if not bytes then break end
                bytes = binaryConvertors[i]:convertU(bytes)
            end
        end
        if bytes then
            responses, err, ts = convertorRegistry.assembleConvertor:convertU(bytes)
            if type(ts) == "number" then
                local diff = os.difftime(ts, os.time())
                if not processor.timediff or math.abs(processor.timediff - diff) > 300 then
                    processor.timediff = diff                 -- 系统比UTC慢了多少秒
                    --system.saveString("__g_utcDiffSeconds", tostring(processor.timediff))       -- 提供在弱联网时校准时间
                    _G.__g_utcDiffSeconds = processor.timediff
                end
            end
        else
            err = InternalError.kNetworkError                                   -- 解析错误
        end
    elseif ChannelEvent.kTimeout == event.name then
        err = InternalError.kTimeoutError
    elseif ChannelEvent.kIOError == event.name then
        local httpStatusCode = event.data
        -- he_log_error("http status code == '" .. httpStatusCode .. "'")
        if httpStatusCode == HttpStatus.HTTP_STATUS_NONE then 
            err = InternalError.kNoNetwork
        elseif httpStatusCode == HttpStatus.HTTP_SERVICE_UNAVAILABLE then
            err = InternalError.kServiceUnavailable
        else
            err = InternalError.kNetworkError
        end
    elseif ChannelEvent.kServerError == event.name then
        err = InternalError.kServerError
    else
        err = InternalError.kDefaultError
    end

    if err then                                                   -- global error
        err = tonumber(err)

        local errorHandlers = handlerRegistry[tostring(err)] or handlerRegistry[tostring(InternalError.kDefaultError)]
        if errorHandlers then
            local endpoints = {}
            for i, r in ipairs(holder.requests) do table.insert(endpoints, r.endpoint) end
            for i, handler in ipairs(errorHandlers) do
                -- 全局错误传播可以阻断
                if handler:handleError(endpoints, err, holder.requests) then break end           
            end
        else
            if err > 0 and not ignoreErrorType[err] then
                he_log_error("missing handler for global error '" .. err .. "'")
            end
        end

        for i, request in ipairs(holder.requests) do
            local handler = request.handler
            if handler then
                local handlerType = type(handler)
                if handlerType == "function" then
                    stopPropagate = handler(request.endpoint, nil, err)

                    local function checkBanCallback( result , datas )
                        if result and datas then
                            local panel = UserBanPanel:create( UserBanLogic.onCloseGame , UserBanLogic.onContact , datas )
                            if panel then panel:popout() end
                        end
                    end

                    UserBanLogic:checkBan( err , checkBanCallback )
                elseif handlerType == "table" then

                    local ecodeHandler = handler[err]               -- number err
                    local errorHandler = handler["error"]
                    if ecodeHandler then
                        stopPropagate = ecodeHandler(request.endpoint, err)
                    elseif errorHandler then
                        stopPropagate = errorHandler(request.endpoint, err)
                    end
                end
            end
        end
    else
        local packageConvertors = convertorRegistry.packageConvertors
        if packageConvertors then
            for i = #packageConvertors, 1, -1 do
                responses = packageConvertors[i]:convertU(responses)
            end
        end
        local requestIndex = 1
        for i, response in ipairs(responses) do
            --he_log_info("response: " .. response.endpoint)
            err = response.error and tonumber(response.error)
            local request = holder.requests[requestIndex]
            local stopPropagate = false
            if err and not ignoreErrorType[err] then 
                he_log_error("RPC ERROR " .. response.endpoint .. "-" .. tostring(err))
            end

            if err == HttpStatus.HTTP_NULL_PTR or (err == 203 and response.endpoint ~= "user" and response.endpoint ~= "syncEnd") then
                err = InternalError.kNoNetwork
            end

            -- 紧急事件处理
            if response.isEvent then
                GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kEmergency, response))
            end

            if request and request.endpoint == response.endpoint then requestIndex = requestIndex + 1 else request = nil end
            
            if request and request.handler then
                local handler = request.handler
                local handlerType = type(handler)
                if handlerType == "function" then
                    stopPropagate = handler(response.endpoint, response.data, err)
                elseif handlerType == "table" then
                    local completeHandler = handler["complete"]
                    if response.error then
                        local ecodeHandler = handler[err]               -- number err
                        local errorHandler = handler["error"]
                        if ecodeHandler then
                            stopPropagate = ecodeHandler(response.endpoint, err)
                        elseif errorHandler then
                            stopPropagate = errorHandler(response.endpoint, err)
                        end
                    elseif completeHandler then
                        stopPropagate = completeHandler(response.endpoint, response.data)
                    end
                end
            end
            
            if not stopPropagate then
                if err then
                    local errorHandlers = handlerRegistry[tostring(err)] or handlerRegistry[tostring(InternalError.kDefaultError)]
                    if errorHandlers then
                        for i, handler in ipairs(errorHandlers) do
                            handler:handleError({response.endpoint}, err)
                        end
                    else
                        if err > 0 and not ignoreErrorType[err] then
                            he_log_error("missing handler for endpoint error '" .. err .. "'")
                        end
                    end
                else
                    local responseHandlers = handlerRegistry[response.endpoint]
                    if responseHandlers then
                        for i, handler in ipairs(responseHandlers) do
                            handler:handleResponse(response.endpoint, response.data)
                        end
                    end
                end
            end
        end
    end
end

--
-- AbsRpcStack, ConcatRpcStack, KeeplastRpcStack ---------------------------
--

AbsRpcStack = class()

function AbsRpcStack:ctor(endpoint, keepSequence)
    self.endpoint = endpoint
    self.keepSequence = nil ~= keepSequence and keepSequence or true
end

function AbsRpcStack:extract()
    local req = request
    self.request = nil
    return req
end

ConcatRpcStack = class(AbsRpcStack)

function ConcatRpcStack:ctor(endpoint, keepSequence, propName)
    self.propName = propName
end

function ConcatRpcStack:push(request)
    local paramArray = request.data[self.propName]
    if type(paramArray) ~= "table" then
        he_log_error("invalidate request pushed into concat stack for endpoint '" .. self.endpoint .. "', with property type '" .. type(paramArray) .. "'")
    elseif self.request then
        local baseArray = self.request.data[self.propName]
        for i, v in ipairs(paramArray) do
            table.insert(baseArray, v)
        end
    else
        self.request = request
    end
end

KeeplastRpcStack = class(AbsRpcStack)

function KeeplastRpcStack:push(request)
    self.request = request
end

KeepfirstRpcStack = class(AbsRpcStack)

function KeepfirstRpcStack:push(request)
    if not self.request then
        self.request = request
    end
end

--
-- RpcTransponder ----------------------------------------------------------
--

RpcTransponder = class()

local isQueueFull
local doCallProcess

function RpcTransponder:ctor(config, sessionKeySource)
    self.queueSize = config.queueSize or 5
    self.flushInterval = config.flushInterval or 10      -- 10s, not really use it
    self.defaultPriority = config.defaultPriority or SendingPriority.kHigh

    self.time = 0
    self.blocked = false
    self.processor = RpcProcessor.new(
        config.url,
        config.timeout or 30,                   -- 30s, not supported currently
        config.retryTimes or 0,                 -- no retry, not supported currently
        config.channelClass or HTTPChannel,     -- http protocol
        config.maxChannel or 1,                 -- http channel count, great than 1 is not supported
        sessionKeySource,
        GIP_SESSION_KEY_DELAY
    )
    local function update(dt)
      self:update(dt)
    end
    
    CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
end

function RpcTransponder:invalidateSessionKey()
    self.processor.sessionKey = nil
end

function RpcTransponder:changeUID(uid)
    local processor = self.processor
    --he_log_info("change uid from " .. tostring(processor.uid) .. " to " .. tostring(uid))
    -- 外部会通过调用changeUID(nil)的方式来阻断通讯，之后会通过传递非nil值调用来恢复
    if uid and processor.uid and processor.uid ~= uid then      
        local discards = {}
        for i, request in ipairs(processor.queue) do table.insert(discards, request.endpoint) end
        for i, request in ipairs(processor.outOfBandQueue) do table.insert(discards, request.endpoint) end
        for k, stack in pairs(processor.stackRegistry) do 
            local request = stack:extract() 
            if request then table.insert(discards, request.endpoint) end
        end
        processor.keepSequenceRpcStack = nil
        table.removeAll(processor.queue)
        table.removeAll(processor.outOfBandQueue)
        he_log_info("discard all pending requests: " .. table.concat(discards, ","))
        
        local assembleConvertor = processor.convertorRegistry.assembleConvertor
        if assembleConvertor then
            assembleConvertor.uk = nil
            assembleConvertor.counter = 0
        end
    end
    processor.uid = uid
    if not self.blocked then self:flush() end
end

function RpcTransponder:dumpAndClean()
    local processor = self.processor
    local requests = table.union(processor.queue, extractAllStack(processor.stackRegistry))
    for i, request in ipairs(processor.outOfBandQueue) do
        table.insert(requests, request)
    end
    table.removeAll(processor.queue)
    table.removeAll(processor.outOfBandQueue)
    processor.authorizedToSend = false
    
    return requests
end

-- handler
------ function(endpoint, data, err)
------ {complete=function(endpoint, data), error=function(endpoint, err)}
------ {complete=function(endpoint, data), 109=function(endpoint, err), 201=function(endpoint, err) ...}
-- handler return value
------ TRUE means stop propagate to registry handler
------ FALSE or NO VALUE means will propagate to registry handler
function RpcTransponder:call(endpoint, data, handler, priority, isLogin)
    data = data or {}
    priority = priority or self.defaultPriority
    --he_log_info("rpc call " .. endpoint .. "[" .. priority .. "]")
    if not data._current_stage then
        UserContext:addGamePlayContextDatas(data)
    end
    -- 在线请求没有这些字段,在这里加一下
    if not data.__offlineRequestTime then
        data.__offlineRequestTime = Localhost:timeInMillis()
    end
    if not data.__id then
        data.__id = uuid:getUUID()
    end
    
    local processor = self.processor
    local rpcStack = processor.stackRegistry[endpoint]
    local rpcRequest = RpcRequest.new(endpoint, data, (not rpcStack) and handler or nil, priority)
    local keepSequenceRpcStack = processor.keepSequenceRpcStack
    isJustBlockRequest = processor.queue and (#processor.queue > 0)

    if rpcStack then
        if keepSequenceRpcStack ~= rpcStack and rpcStack.keepSequence then
            if keepSequenceRpcStack then
                table.insert(processor.queue, keepSequenceRpcStack:extract())
                if isQueueFull(self) then doCallProcess(self) end
            end
            processor.keepSequenceRpcStack = rpcStack
        end
        rpcStack:push(rpcRequest)
    else
        if keepSequenceRpcStack then
            table.insert(processor.queue, keepSequenceRpcStack:extract())
            processor.keepSequenceRpcStack = nil
        end
        if isLogin then
            local assembleConvertor = processor.convertorRegistry.assembleConvertor
            if assembleConvertor then
                assembleConvertor.uk = nil
                assembleConvertor.counter = 0
            end
        
            local tmpQueue = {}
            for i, request in ipairs(processor.queue) do
                table.insert(tmpQueue, request)
            end
            table.removeAll(processor.queue)
            self.blocked = false
            
            table.insert(processor.queue, rpcRequest)
            doCallProcess(self)
            
            for i, request in ipairs(tmpQueue) do
                table.insert(processor.queue, request)
            end
        else
            table.insert(processor.queue, rpcRequest)
        end
        if SendingPriority.kHigh == priority or isQueueFull(self) then
            doCallProcess(self)
        end
    end
end

function RpcTransponder:callOutOfBand(endpoint, data, handler)
    data = data or {}
    local rpcRequest = RpcRequest.new(endpoint, data, handler, SendingPriority.kHigh, true)
    table.insert(self.processor.outOfBandQueue, rpcRequest)
    doCallProcess(self)
end

function RpcTransponder:update(time)
    self.time = self.time + time
    if self.time > self.flushInterval then 
      self.time = 0 
      doCallProcess(self) 
    end
end

function RpcTransponder:isBlocked()
    return self.blocked
end

function RpcTransponder:block()
    self.blocked = true
end

function RpcTransponder:unblock()
    self.blocked = false
end

function RpcTransponder:flush()
    self.blocked = false
    doCallProcess(self, true)
end

function RpcTransponder:dispose()
    processor:dispose()
    self.class = nil
end

function RpcTransponder:registryConvertor(assembleConvertor, binaryConvertors, packageConvertors)
    local convertorRegistry = self.processor.convertorRegistry
    convertorRegistry.assembleConvertor = assembleConvertor
    convertorRegistry.binaryConvertors = binaryConvertors and table.union({}, binaryConvertors) or {}
    convertorRegistry.packageConvertors = packageConvertors and table.union({}, packageConvertors) or {}
end

function RpcTransponder:registryRpcStack(stack)
    self.processor.stackRegistry[stack.endpoint] = stack
end

function RpcTransponder:unregistryRpcStack(stack)
    local stackRegistry = self.processor.stackRegistry
    if stackRegistry[stack.endpoint] == stack then stackRegistry[stack.endpoint] = nil end
end

function RpcTransponder:registryHandler(handler)
    local handlerRegistry = self.processor.handlerRegistry
    if type(handler.endpoints) == "table" then
        for endpoint in pairs(handler.endpoints) do
            handlerRegistry[endpoint] = table.insertIfNotExist(handlerRegistry[endpoint], handler)
        end
    end
    if type(handler.errors) == "table" then
        for err in pairs(handler.errors) do
            err = tostring(err)
            handlerRegistry[err] = table.insertIfNotExist(handlerRegistry[err], handler)
        end
    end
end

function RpcTransponder:unregistryHandler(handler)
    local handlerRegistry = self.processor.handlerRegistry
    if type(handler.endpoints) == "table" then
        for endpoint in pairs(handler.endpoints) do
            table.removeIfExist(handlerRegistry[endpoint], handler)
        end
    end
    if type(handler.errors) == "table" then
        for err in pairs(handler.errors) do
            table.removeIfExist(handlerRegistry[tostring(err)], handler)
        end
    end
end

isQueueFull = function(transponder)
    local queue = transponder.processor.queue
    if #queue > transponder.queueSize then
        local size = 0;
        for i, request in ipairs(queue) do
            if SendingPriority.kLow ~= request.priority then
                size = size + 1
                if size > transponder.queueSize then return true end
            end
        end
    end
    return false
end

doCallProcess = function(transponder, immediately)
    local uid = transponder.processor.uid
    --he_log_info("doCallProcess: blocked-" .. tostring(transponder.blocked) .. " uid-" .. tostring(uid))
    if not transponder.blocked and uid then
        transponder.time = 0
        transponder.processor:process(immediately)
    end
end

--
-- HeaderConvertor ----------------------------------------------------------
--

HeaderConvertor = class()

function HeaderConvertor:convertD(bytes)
    return headercvt.convertD(bytes)
end

function HeaderConvertor:convertU(bytes)
    return headercvt.convertU(bytes)                -- 异常时应由底层处理，并返回nil
end

--
-- CompressConvertor ----------------------------------------------------------
--

CompressConvertor = class()

function CompressConvertor:convertD(bytes)
    return compress(bytes)
end

function CompressConvertor:convertU(bytes)
    return uncompress(bytes)                        -- 异常时应由底层处理，并返回nil
end

--
-- AssembleConvertor ----------------------------------------------------------
--

AssembleConvertor = class()

local pickResponseMeta

function AssembleConvertor:ctor(amf3Enabled, version, metaVersion, appID, language, platformFinder, clientType, uk, counter, others)
    self.amf3Enabled = amf3Enabled
    self.version = version
    self.metaVersion = metaVersion
    self.appID = appID
    self.language = language
    self.platformFinder = platformFinder
    self.clientType = clientType
    self.uk = uk
    self.counter = type(counter) == "number" and counter or 0
    self.others = type(others) == "table" and others or {}
end

function AssembleConvertor:updata(sessionKey)
    self.sessionKey = sessionKey
end

function AssembleConvertor:convertD(requests, uid)
    local header = {
        v = self.version,                       -- version
        mv = self.metaVersion,                  -- meta version
        ct = self.clientType,                   -- client type
        aid = self.appID,                       -- app ID
        lang = self.language,                   -- language
        pf = self.platformFinder(),              -- platform finder [function() return "tencent_qzone" end]
        notify = true,                          -- enable backend notification
        sk = self.sessionKey,                   -- dynamic session key
        uk = self.uk,
        others = self.others,
        uid = uid,
    }
    
    local others = {}
    if self.others then
        for k, v in pairs(self.others) do
            others[k] = v
        end
    end
    local ctxHeaderParams = UserContext:getHeaderOthersParams()
    if ctxHeaderParams then
        for k, v in pairs(ctxHeaderParams) do
            others[k] = v
        end
    end
    header.others = others

    if not header.uk then self.counter = 0 end
    
    -- local headerInfo = {} for k, v in pairs(header) do table.insert(headerInfo, k .. "=" .. tostring(v)) end
    --he_log_info("communication request header: " .. table.concat(headerInfo, ","))

    for i, request in ipairs(requests) do
        if request.outOfBand then header.st = HEADER_COUNTER_FOR_OUTOFBAND break end
    end
 
    if not header.st then
        header.st = self.counter
        self.counter = self.counter + 1
    end

    local data = { header, {} }
    for i, request in ipairs(requests) do
        request.data.method = request.endpoint
        table.insert(data[2], request.data)
    end
    return self.amf3Enabled and amf3.encode(data) or data
end

function AssembleConvertor:convertU(bytes)
    local responseData = nil
    if self.amf3Enabled then
        local ret, errMsg = pcall(function() responseData = amf3.decode(bytes) end)
        if not ret then
            he_log_error("convertU_amf3_decode_error:"..tostring(errMsg))
            return {}, InternalError.kDefaultError, nil
        end
    else
        responseData = bytes
    end
    local responses = {}
    local subHeader = responseData[1]
    local events = responseData[3]
    local code = tonumber(subHeader.errCode)
    local ts = tonumber(subHeader.ts)
    code = code and code > 0 and code or nil
    
    -- local headerInfo = {} for k, v in pairs(subHeader) do table.insert(headerInfo, k .. "=" .. tostring(v)) end
    --he_log_info("communication response header: " .. table.concat(headerInfo, ","))

    if(code) and (subHeader.uk) then
        he_log_error("get_uk_but_have_error_code:"..code)
    end

    if not code then
        if subHeader.uk then 
            self.uk = subHeader.uk 
            --he_log_info("communication uk: " .. tostring(self.uk)) 
        end
        if subHeader.st then self.counter = math.max(self.counter, tonumber(subHeader.st)) end
    end

    for i, response in ipairs(responseData[2]) do
        table.insert(responses, pickResponseMeta(response, ts))
    end
    
    if type(events) == "table" then
        for i, event in ipairs(events) do
            table.insert(responses, pickResponseMeta(event, ts, true))
        end
    end

    return responses, code, ts
end

pickResponseMeta = function(data, ts, isEvent)
    local endpoint = data.method
    local code = tonumber(data.retCode)
    local message = data.extraMsg
    data.method = nil
    data.retCode = nil
    data.extraMsg = nil
    
    return RpcResponse.new(endpoint, data, code ~= 200 and code or nil, message, isEvent)
end

--
-- PackageConvertor ----------------------------------------------------------
--

PackageConvertor = class()

function PackageConvertor:convertD(requests)
    return requests
end

function PackageConvertor:convertU(responses)
    return responses
end
