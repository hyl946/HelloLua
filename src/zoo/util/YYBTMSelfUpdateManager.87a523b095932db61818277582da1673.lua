-- -- 20180423 彻底废弃旧版应用宝 msdk 自更新，改用ysdk

-- -- 20180110 应用宝登录接入ysdk ysdk暂时不支持省流量更新 所以注释掉这里的入口
-- -- if PlatformConfig:isPlatform(PlatformNameEnum.kQQ) then
-- --     --应用宝省流量更新逻辑
-- --     local checkUpdateEnableResult = function(result)
-- --         printx( 1 , "   YYB Update  yybUpdateMaintenanceIsOn = " .. tostring(result))
-- --         if result then
-- --             YYBTMSelfUpdateManager:getInstance():showUpdatePanel(self)
-- --         else
-- --             if YYBTMSelfUpdateManager:getInstance().isSkiped == false then
-- --                 -- self:loadAnnouncement()
-- --                 BroadcastManager:getInstance():initFromConfig()
-- --                 self.progressBar:setVisible(true)
-- --                 self:doLoadResource()
-- --                 YYBTMSelfUpdateManager:getInstance().isSkiped = true
-- --             end
-- --         end
-- --     end
-- --     self.progressBar:setVisible(false)
-- --     YYBTMSelfUpdateManager:getInstance():checkUpdateEnable(checkUpdateEnableResult)
-- -- else
--     -- self:doLoadResource()
-- -- end


-- require "zoo.panel.UpdateNewVersionPanel"
-- require 'zoo.panel.PrePackageUpdatePanel'

-- YYBTMSelfUpdateManager = class(EventDispatcher)

-- local manager = nil 
-- local loadingBar = nil

-- function YYBTMSelfUpdateManager:getInstance( ... )
-- 	if not manager then
-- 		manager = YYBTMSelfUpdateManager.new()
-- 		local clazz = luajava.bindClass("com.happyelements.animal.yybtmselfupdatesdk.YYBTMSelfUpdateProxy")
-- 		if clazz then
-- 			manager.javaProxyInstance = clazz:getInstance()
-- 		end
		
-- 		manager.isNeedUpdate = true
--         manager.isSkiped = false
-- 		printx( 1 , "  YYBTMSelfUpdateManager:getInstance   javaProxyInstance = " .. tostring(manager.javaProxyInstance))

-- 	end

-- 	return manager
-- end


-- function YYBTMSelfUpdateManager:checkSelfUpdate()


-- end

-- function YYBTMSelfUpdateManager:checkYYBInstallState()


-- end

-- function YYBTMSelfUpdateManager:checkUpdateEnable(callback)

--    	local url = NetworkConfig.maintenanceURL
-- 	local uid = UserManager.getInstance().uid or "12345"
-- 	local params = string.format("?name=maintenance&uid=%s&_v=%s", uid, _G.bundleVersion)
-- 	url = url .. params
-- 	local request = HttpRequest:createGet(url)
--     local timeout = 3
--     local connection_timeout = 3

--     print("YYBTMSelfUpdateManager:checkUpdateEnable",url)

--     if __WP8 then 
--         connection_timeout = 5
--         timeout = 30
--     end

--     request:setConnectionTimeoutMs(connection_timeout * 1000)
--     request:setTimeoutMs(timeout * 1000)

--     local checkMaintenance = function( src )
-- 		if _G.isLocalDevelopMode then printx(0, "MaintenanceManager:fromXML") end
-- 		if not src then return end

-- 		local needUpdate = false

-- 		for k,v in pairs(src) do	
-- 			if type(v) == "table" then	
-- 				if tonumber(v.id) == 43 
-- 					and tostring(v.name) == "YYBExpressUpdate" 
-- 					and tostring(v.enable) == "true" then

-- 					needUpdate = true
-- 				end
-- 			end		
-- 		end

-- 		return needUpdate
-- 	end
   
--     local function onRegisterFinished( response )

--     	local yybUpdateMaintenanceIsOn = false

--     	if response.httpCode ~= 200 then 
--     		if _G.isLocalDevelopMode then printx(0, "get maintenance config error") end	
--     		yybUpdateMaintenanceIsOn = false
--     	else
--     		local message = response.body
--     		local metaXML = xml.eval(message)
--     		local confList = xml.find(metaXML, "maintenance")
--     		yybUpdateMaintenanceIsOn = checkMaintenance(confList)
--     	end

--     	if callback and type(callback) == "function" then
--     		callback(yybUpdateMaintenanceIsOn)
--     	end
--     end

--     if not PrepackageUtil:isPreNoNetWork() then 
--    		HttpClient:getInstance():sendRequest(onRegisterFinished, request)
--    	else
-- 	    if callback and type(callback) == "function" then
--     		callback(false)
--     	end
--    	end
-- end

-- function YYBTMSelfUpdateManager:showUpdatePanel(preloadingscene)

-- 	self.preloadingscene = preloadingscene
-- 	yybcallback = luajava.createProxy("com.happyelements.animal.yybtmselfupdatesdk.IStartSelfUpdateCallback",
--             {
--                 onDownloadAppProgressChanged = function(receiveDataLen,totalDataLen)
--                      printx( 1 , "  onDownloadAppProgressChanged  " .. tostring(receiveDataLen) .. "/" .. tostring(totalDataLen))
--                      local yybText = 
--                      "已下载   " 
--                      .. tostring( math.floor( (receiveDataLen*100)/(1024*1024) )/100 ) .. "M"
--                      .. "/" 
--                      .. tostring( math.floor( (totalDataLen*100)/(1024*1024) )/100 ) .. "M"

--                      if preloadingscene.yybUpdateLabel and not preloadingscene.yybUpdateLabel.isDisposed then
--                         preloadingscene.yybUpdateLabel:setString(yybText)
--                      end

--                      if preloadingscene.yybUpdateLabelShadow and not preloadingscene.yybUpdateLabelShadow.isDisposed then
--                         preloadingscene.yybUpdateLabelShadow:setString(yybText)
--                      end

--                      local visibleSize = CCDirector:sharedDirector():getVisibleSize()
--                      local progressOffsetY = visibleSize.height - 130

--                      local progressX = visibleSize.width *  tonumber(1 - tonumber(receiveDataLen / totalDataLen))
--                      preloadingscene.receiveDataLen = tonumber(receiveDataLen)
--                      preloadingscene.totalDataLen = tonumber(totalDataLen)

--                 end,
--                 onDownloadAppStateChanged = function(state,errorCode,errorMsg)
--                     printx( 1 , "  onDownloadAppStateChanged state = " .. tostring(state))

--                     if state == 1 then
--                         local winSize = CCDirector:sharedDirector():getVisibleSize()
--                         local origin = CCDirector:sharedDirector():getVisibleOrigin()

--                         printx( 1 , "  winSize  width = " .. tostring(winSize.width) .. "  height = " .. tostring(winSize.height) .. "   x = " .. tostring(winSize.x) .. "   y = " .. tostring(winSize.y))
--                         printx( 1 , "  origin  width = " .. tostring(origin.width) .. "  height = " .. tostring(origin.height) .. "   x = " .. tostring(origin.x) .. "   y = " .. tostring(origin.y))
                        

--                         local progressOffsetY = winSize.height - 130
--                         local labelShadow = TextField:create("", "Helvetica", 26, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
--                         labelShadow:setPosition(ccp(winSize.width/2, origin.y + 30 + progressOffsetY))
--                         labelShadow:setColor(ccc3(46, 76, 38))
--                         preloadingscene:addChild(labelShadow)
--                         preloadingscene.yybUpdateLabelShadow = labelShadow
--                         local label = TextField:create("", "Helvetica", 26, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
--                         label:setPosition(ccp(winSize.width/2, origin.y + 33 + progressOffsetY))
--                         preloadingscene:addChild(label)
--                         preloadingscene.yybUpdateLabel = label

--                         local visibleSize = CCDirector:sharedDirector():getVisibleSize()
--                         local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

--                         local loading_1 = LayerColor.create()
--                         loading_1:setColor(ccc3(255, 255, 255))
--                         loading_1:setOpacity(125)
--                         loading_1:changeWidth(visibleSize.width)
--                         loading_1:changeHeight(15)
--                         loading_1:setPosition(ccp( visibleSize.width * -1 , origin.y + 120 + progressOffsetY))
--                         preloadingscene.yyb_loading_1 = loading_1
--                         preloadingscene:addChild(loading_1)

--                         local loading_2 = LayerColor.create()
--                         loading_2:setColor(ccc3(0, 0, 0))
--                         loading_2:setOpacity(125)
--                         loading_2:changeWidth(visibleSize.width)
--                         loading_2:changeHeight(15)
--                         loading_2:setPosition(ccp(0, origin.y + 120 + progressOffsetY))
--                         preloadingscene.yyb_loading_2 = loading_2
--                         preloadingscene:addChild(loading_2)

--                         local ontimer = function()
--                             if preloadingscene.receiveDataLen ~= nil 
--                             	and preloadingscene.totalDataLen ~= nil 
--                             	and tonumber(preloadingscene.receiveDataLen) > 0 
--                             	and tonumber(preloadingscene.totalDataLen) > 0 then
--                                 local progressX = visibleSize.width *  tonumber(1 - tonumber(preloadingscene.receiveDataLen / preloadingscene.totalDataLen))
--                                	preloadingscene.yyb_loading_1:setPosition(ccp( progressX * -1 , origin.y + 120 + progressOffsetY))
--                                 preloadingscene.yyb_loading_2:setPosition(ccp( visibleSize.width - progressX , origin.y + 120 + progressOffsetY))
                                
--                                 if preloadingscene.receiveDataLen == preloadingscene.totalDataLen then
--                                     TimerUtil.removeAlarm(preloadingscene.yybTimerID)
--                                 end
--                             end
--                         end

--                         preloadingscene.yybTimerID = TimerUtil.addAlarm(ontimer, 0.5 , 0)
                        
--                     elseif state == 0 then
--                         if preloadingscene.yybUpdateLabel and not preloadingscene.yybUpdateLabel.isDisposed then
--                             preloadingscene.yybUpdateLabel:setString("更新已完成，请确认安装")
--                         end

--                         if preloadingscene.yybUpdateLabelShadow and not preloadingscene.yybUpdateLabelShadow.isDisposed then
--                             preloadingscene.yybUpdateLabelShadow:setString("更新已完成，请确认安装")
--                         end
--                     end
--                 end,
--                 onGetUpdateInfo = function(type,datas)
--                     printx( 1 , "  onGetUpdateInfo")
--                     local updateInfo = luaJavaConvert.map2Table(datas)
--                     if updateInfo and tonumber(updateInfo.newApkSize) <= 0 then

--                         if YYBTMSelfUpdateManager:getInstance().isSkiped == false then
--                             -- preloadingscene:loadAnnouncement()
--                             preloadingscene.progressBar:setVisible(true)
--                             preloadingscene:doLoadResource()
--                             YYBTMSelfUpdateManager:getInstance().isSkiped = true
--                         end
--                     end
--                 end,
--                 onUpdateFailed = function(errorId)
--                 	printx( 1 , "   YYB Update Fin   id = " .. tostring(errorId))
--                     if YYBTMSelfUpdateManager:getInstance().isSkiped == false then
--                         -- preloadingscene:loadAnnouncement()
--                         preloadingscene.progressBar:setVisible(true)
--                         preloadingscene:doLoadResource()
--                         YYBTMSelfUpdateManager:getInstance().isSkiped = true
--                     end
--                 end,

--                 onOpenPanelDone = function()
--                     printx( 1 , "   YYB Update onOpenPanelDone ")
--                     YYBTMSelfUpdateManager:getInstance().onOpenPanelDone = true
--                 end,
--             })

-- 	self.javaProxyInstance:showUpdatePanel(yybcallback)
--     ----[[
--     local ontimeout = function()
--         if not YYBTMSelfUpdateManager:getInstance().onOpenPanelDone then
--             if YYBTMSelfUpdateManager:getInstance().isSkiped == false and self.preloadingscene then
--                 -- self.preloadingscene:loadAnnouncement()
--                 self.preloadingscene.progressBar:setVisible(true)
--                 self.preloadingscene:doLoadResource()
--                 YYBTMSelfUpdateManager:getInstance().isSkiped = true
--             end
--         end
--     end

--     self.timeoutTimerID = TimerUtil.addAlarm(ontimeout, 8 , 1)
--     --]]
-- end

