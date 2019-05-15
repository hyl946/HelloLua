require "zoo.config.NetworkConfig"
require "zoo.animation.CountDownAnimation"
require "zoo.scenes.component.HomeScene.iconButtons.IconButtonManager"
require "zoo.ActivityCenter.ActivityCenterButton"
require "zoo.scenes.ActivityCenterScene"
require "zoo.ActivityCenter.ActivityCenterPanel"
require "zoo.ActivityCenter.ActivityCenterItemPanel"

ActivityCenter = {}

ActivityCenterType = {
	kAct = 1,
	kFeature = 2
}

kActivityCenterAsPanel = true

function ActivityCenter:init()
	self.features = {}
	self.visibleDatas = {}
	self.jsonRes = {}

	-- self:pushFeature(require "zoo.ActivityCenter.AccountBindingData")
end

function ActivityCenter:useNew()
	self:registerEvent()
	return true
	
	-- if __WIN32 then
	-- 	self:registerEvent()
	-- 	return true 
	-- end
	
	-- local enabled = MaintenanceManager:getInstance():isEnabled("ActCenterFeature", false)

	-- if not enabled then
	-- 	self:print("ActCenterFeature == false")
	-- 	return false 
	-- end

	-- local uid = tonumber(UserManager.getInstance().user.uid)
	-- if uid then
	-- 	local r = uid % 100
	-- 	local num = MaintenanceManager:getInstance():getValue("ActCenterFeature")
	-- 	self:print(r, tostring(num), 1)
	-- 	if r < (tonumber(num) or 0) then
	-- 		self:registerEvent()
	-- 		return true
	-- 	end
	-- end
	-- return false
end

function ActivityCenter:registerEvent()
	if not self.hasRegister then
		self.hasRegister = true

		Notify:register("ActivityCenterDataChangeEvent", self.onFeatureStatusChange, self )
		Notify:register("ActivityCenterShowGuideEvent", self.tryShowGuide, self )
		Notify:register("ActivityCenterCloseItemEvent", self.closeItem, self)
		Notify:register("ActivityCenterPopCenterActEvent", self.tryPopoutCenter, self)
		Notify:register("ActivityCenterPopCenterFeatureEvent", self.forcePopoutFeature, self)
		Notify:register("ActivityCenterSyncDataEvent", self.onSyncData, self)
		Notify:register("ActivityCenterExitEvent", self.exitActivityCenter, self)
		Notify:register("ActivityStatusChangeEvent", self.onActivityStatusChange, self)
	end
end

function ActivityCenter:onSyncData( t, dataOrConfig )
	if not dataOrConfig or not t then return end

	local id = dataOrConfig.cid or dataOrConfig.id
	local data = self.visibleDatas[id]

	if not data then return end

	if t == "success" then
		data.isSynced = true
	else
		data.isSynced = false
	end

	if data.isSynced then
		local scene = self:getActivityCenterPanel()
		if scene and not scene.isDisposed and self:isInActivityScene() then
			scene:refreshPanel(data)
		end
	else
		CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
	end
end

function ActivityCenter:showCenterBtn(scene, suppressFlyAnimation)
	if self:checkCondition() then
		self:createCenterBtn(scene, suppressFlyAnimation)
	end
end

function ActivityCenter:getVisibleDatas( ... )
	return self.visibleDatas
end

function ActivityCenter:pushFeature( data )
	if data.id == nil then
		self:print("[error] no id!")
		return
	end

	for _,featureData in ipairs(self.features) do
		if featureData.id == data.id then
			self:print(data.id,":features add again!")
			return
		end
	end

	if data.isVisible == nil or type(data.isVisible) ~= "function" then
		self:print(data.id,"add isVisible function please!")
		return
	end

	table.insert(self.features, data)

	local mt = {
		__index = function ( t, k )
			if k == "isForcePop" then
				return ActivityCenter.isForcePop
			end
			return nil
		end
	}
	setmetatable(data, mt)
end

function ActivityCenter:getPriority( data )
	if data.type == ActivityCenterType.kAct then
		return data.config.actPriority or -100
	elseif data.type == ActivityCenterType.kFeature then
		if data.id == "AccountBinding" then
			return -1
		end
	end

	return -100
end

function ActivityCenter:checkCondition()
	local ret = false
	--check feature
	for _,data in ipairs(self.features) do
		if data:isVisible() then
			ret = true
			self.visibleDatas[data.id] = data
		else
			self.visibleDatas[data.id] = nil
		end
	end

	return ret
end

function ActivityCenter:onBindingDataChange(bindingData)
	-- local data = (require "zoo.ActivityCenter.AccountBindingData")
	-- data:onUpdate(bindingData)
	-- self:showCenterBtn()
end

function ActivityCenter:updateHomeIconBtnStatus()
	local scene = HomeScene:sharedInstance()
	local btn = scene and scene.activityButton or nil

	if btn and btn ~= true and btn.onIconStatusChange then
		btn:onIconStatusChange()
		Notify:dispatch("ActivityIconShowTipEvent")
	end
end

function ActivityCenter:onActConfigLoadEnd()
	--check activity
	local centerAct = ActivityUtil:getCenterActivitys()
	if #centerAct <= 0 then
		return
	end

	local count = #centerAct
	for _,info in pairs(centerAct) do
		local function loadIconSuccess()
			self:onActivityLoadIconFinished(info)
			count = count - 1
			if count <= 0 then
				self:updateHomeIconBtnStatus()
				local scene = self:getActivityCenterPanel()
				if scene and not scene.isDisposed and self:isInActivityScene() then
					scene:refreshItem()
				end
			end
		end

		local config = require("activity/" .. info.source)
		if config and config.__preInit and type(config.__preInit) == "function" then
			config.__preInit(info)
		end

		ActivityUtil:loadCenterIconRes(info.source,info.version, loadIconSuccess)
	end
end

function ActivityCenter:onActivityStatusChange( source )
	local scene = self:getActivityCenterPanel()
	if scene and not scene.isDisposed and self:isInActivityScene() then
		local config = require("activity/" .. source)
		local data = self.visibleDatas[config.cid]
		
		if data then
			data.config = config
			scene:refreshItemStatus(data)
		end
	end

	self:updateHomeIconBtnStatus()
end

--[[
info = {
	id  = "",
	num = 1, 有值附新值，没有不改变
	hasAward = true,有值附新值，没有不改变
}
--]]
function ActivityCenter:onFeatureStatusChange( info )
	local scene = self:getActivityCenterPanel()
	if scene and not scene.isDisposed and self:isInActivityScene() then
		local data = self.visibleDatas[info.id]
		if data then
			data.num = info.num or data.num
			data.hasAward = info.hasAward or data.hasAward
			scene:refreshItemStatus(data)
		end
	end

	self:updateHomeIconBtnStatus()
end

function ActivityCenter:getMsgNum( data )
	if data.type == ActivityCenterType.kAct then
		return ActivityUtil:getMsgNum(data.actInfo.source) or 0
	elseif data.type == ActivityCenterType.kFeature then
		return data.num or 0
	end

	return data.num or 0
end

function ActivityCenter:hasRewardMark( data )
	if data.type == ActivityCenterType.kAct then
		return ActivityUtil:hasRewardMark(data.actInfo.source)
	elseif data.type == ActivityCenterType.kFeature then
		return data.hasAward
	end

	return data.hasAward or false
end

function ActivityCenter:isNewFeature(data)
	if data.type == ActivityCenterType.kAct then
		if data.config.isNewFeature and type(data.config.isNewFeature) == "function" then
			return data.config.isNewFeature()
		else
			if data.config.getBeginTime and type(data.config.getBeginTime) == "function" then
				local time = data.config.getBeginTime()
				if type(time) == "table" then
					time = os.time(time)
				end
				local now = Localhost:timeInSec()
				if (now - time) / 3600 / 24 <= 3 then
					return true
				end
			end
		end
	elseif data.type == ActivityCenterType.kFeature then
		if data.isNewFeature and type(data.isNewFeature) == "function" then
			return data.isNewFeature()
		end
	end

	return false
end

function ActivityCenter:checkNeedUpdate()
	local hasDelete = false
	local acts = ActivityUtil:getCenterActivitys()
	local rmt = {}
	for id,data in pairs(self.visibleDatas) do
		if data.type == ActivityCenterType.kAct then
			local has = false
			for _,info in ipairs(acts) do
				local config = require("activity/" .. info.source)
				if data.id == config.cid then
					has = true
				end
			end
			if not has then
				hasDelete = true
				table.insert(rmt, data)
			end
		end
	end

	for _,data in ipairs(rmt) do
		self:removeVisibleData(data)
	end

	local hasNew = false
	local acts = ActivityUtil:getCenterActivitys()
	for _,info in ipairs(acts) do
		local config = require("activity/" .. info.source)
		local data = self.visibleDatas[config.cid or "_x_"]
		if not data then
			hasNew = true
		end
	end

	return hasDelete or hasNew
end

function ActivityCenter:closeItem( id )
	local data = self.visibleDatas[id]
	self.visibleDatas[id] = nil
	local scene = self:getActivityCenterPanel()
	if scene and not scene.isDisposed and self:isInActivityScene() and data then
		scene:runAction(CCCallFunc:create(function ( ... )
			scene:refreshItem(data)
		end))
	end
end

function ActivityCenter:removeVisibleData(data)
	self:closeItem(data.id)
end

function ActivityCenter:loadActRes(data)
	local info = data.actInfo

	local function onSuccess( ... )
		ActivityUtil:unLoadResIfNecessary(info.source)

		local config = require("activity/" .. info.source)

		data.config = config
		data.panelCls = require("activity/" .. config.panelClsName)

		if config.syncFileName then
			data.sync = require("activity/" .. config.syncFileName)
		end

		if config.startLua then
			require("activity/" .. config.startLua)
		end

		local scene = self:getActivityCenterPanel()
		if scene and not scene.isDisposed and self:isInActivityScene() then
			scene:refreshPanel(data)
		end
	end
	local function onError( ... )
		-- body
	end
	local function onProcess( info )
		local scene = self:getActivityCenterPanel()
		if scene and not scene.isDisposed and self:isInActivityScene() then
			scene:onDownloadResProcess(data, info)
		end
	end

	ActivityUtil:loadRes(info.source,info.version,onSuccess,onError,onProcess)
end

function ActivityCenter:onActivityLoadIconFinished( info )
	local config = require("activity/" .. info.source)

	local data = self.visibleDatas[config.cid]
	
	if data and not ActivityUtil:needUpdate(info.source) then
		self:createCenterBtn()
		return
	end

	data = {config = config}
	data.actInfo = info
	data.isVisible = config.isSupport
	data.id = config.cid
	data.type = ActivityCenterType.kAct

	local mt = {
		__index = function ( t, k )
			if k == "isForcePop" then
				return self.isForcePop
			end
			return config[k]
		end
	}
	setmetatable(data, mt)

	for _,path in ipairs(config.cicon) do
		local f,e = string.find(path, "_normal_img.png")
		if f then
			data.ciconPerfix = "activity/"..string.sub(path,1,f-1)
			break
		end
	end

	self.visibleDatas[data.id] = data

	self:createCenterBtn()
end

function ActivityCenter:createCenterBtn(scene, suppressFlyAnimation)
	scene = scene or HomeScene:sharedInstance()
	local btn = scene.activityButton
	if scene and (type(btn) ~= "table") and self:hasCenterItem() then
		local activityButton = ActivityCenterButton:create()
		scene:addIcon(activityButton, false, suppressFlyAnimation)
		scene.activityButton = activityButton
	end
end

function ActivityCenter:hasCenterItem()
	local hasData = false
	for k,v in pairs(self.visibleDatas) do
		hasData = true
		break
	end
	return hasData
end

function ActivityCenter:removeCenterBtn()
	local scene = HomeScene:sharedInstance()
	if scene and type(scene.activityButton) == "table" then
		scene:removeIcon(scene.activityButton, true)
		scene.activityButton = nil
	end
end

function ActivityCenter:loadResources( json )
	local res = {json = json, builder = InterfaceBuilder:createWithContentsOfFile(json)}
	self.jsonRes[json] = res

	return res.builder
end

function ActivityCenter:unloadResources()
	for json,res in pairs(self.jsonRes) do
		InterfaceBuilder:unloadAsset(json)
	end

	self.jsonRes = {}
end

--force popout feature
function ActivityCenter:forcePopoutFeature( id, cb )
	local data = nil
	for _,featureData in ipairs(self.features) do
		if featureData.id == id then
			data = featureData
			break
		end
	end

	if data then
		if data:isVisible(true) then
			self.isForcePop = true
			self:showActivityCenter(id)
			self.popoutCb = cb
		end
	else
		if cb then cb() end
	end
end

--force popout activity
function ActivityCenter:tryPopoutCenter( actId )
	if not self:useNew() then return false end

	local data = nil
	for id,d in pairs(self.visibleDatas) do
		if d.actId == actId then
			data = d
		end
	end

	if not data then return end

	if data.hasIsolatePanel then
		return false
	else
		self.isForcePop = true
		self:showActivityCenter(data)
		return true
	end
end

function ActivityCenter:checkVisibleData()
	for id,data in pairs(self.visibleDatas) do
		if not data:isVisible() then
			self:removeVisibleData(data)
		end
	end
end

function ActivityCenter:readLocalData()
	local path = HeResPathUtils:getUserDataPath() .. '/activity_center_'..(UserManager:getInstance().uid or '0')
	self.data = self.data or {}

	local file = io.open(path, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            local data = table.deserialize(content) or {}
            for k,v in pairs(data) do
            	self.data[k] = v
            end
        end
    end
end

function ActivityCenter:writeLocalData()
	local path = HeResPathUtils:getUserDataPath() .. '/activity_center_'..(UserManager:getInstance().uid or '0')
	local file = io.open(path,"w")
    if file then 
        file:write(table.serialize(self.data or {}))
        file:close()
    end

    if _G.isLocalDevelopMode then
    	local file = io.open(path..".DEBUG","w")
	    if file then 
	        file:write(table.tostring(self.data or {}))
	        file:close()
	    end
    end
end

function ActivityCenter:showActivityCenter( dataOrId )
	if not self:useNew() then return end
	if not self:hasCenterItem() then
		local text = Localization:getInstance():getText("the.activity.has.ended")
		CommonTipWithBtn:showTip({tip = text, yes = "知道了"}, "negative", nil, nil, nil, true)
		self:removeCenterBtn()
		return
	end
	self:closeGuide()
	self:checkCondition()

	local data = nil
	if type(dataOrId) == "string" then
		data = self.visibleDatas[dataOrId]
	elseif type(dataOrId) == "table" then
		data = dataOrId
	end

	if not self.isForcePop and not data then
		if not self.data or not self.data.idsShowed then
			self:readLocalData()
		end
		self.data.idsShowed = self.data.idsShowed or {}
		local idsShowed = self.data.idsShowed
		local sortDatas = {}
		local function GetIndex(d)
			local cp = self:getPriority(d)
			for idx,sd in ipairs(sortDatas) do
				local tp = self:getPriority(sd)
				if cp < tp then
					return idx
				end
			end
			return nil
		end

		for id,d in pairs(self.visibleDatas) do
			local index = GetIndex(d) or (#sortDatas+1)
			table.insert(sortDatas, index, d)
		end
		
		for _,d in ipairs(sortDatas) do
			if not idsShowed[d.id] then
				data = d
				idsShowed[d.id] = true
				self:writeLocalData()
				break
			end
		end

		if #sortDatas > 0 and not data then
			self.data.idsShowed = {[sortDatas[1].id] = true}
			self:writeLocalData()
		end
	end

	local scene = self:getActivityCenterPanel()
	if not scene then
		self:checkVisibleData()

		if not self:hasCenterItem() then
			local text = Localization:getInstance():getText("the.activity.has.ended")
			CommonTipWithBtn:showTip({tip = text, yes = "知道了"}, "negative", nil, nil, nil, true)
			self:removeCenterBtn()
			return
		end

		if kActivityCenterAsPanel then
			scene = ActivityCenterPanel:create(data)
			scene:popout()
		else
			scene = ActivityCenterScene:create(data)
			Director.sharedDirector():pushScene(scene)
		end
		self.scene = scene
	end

	if data and scene and not scene.isDisposed then
		scene:runAction(CCCallFunc:create(function ( ... )
			scene:onTouchItem( data )
		end))
	end
end

function ActivityCenter:getActivityCenterPanel()
	return self.scene
end

function ActivityCenter:isInActivityScene()
	local inActivityScene = false
	local curScene = Director:sharedDirector():getRunningScene()
	if kActivityCenterAsPanel then
		inActivityScene = curScene and curScene:is(HomeScene)
	else
		inActivityScene = curScene and curScene:is(ActivityCenterScene)
	end
	return inActivityScene
end

function ActivityCenter:exitActivityCenter()
	if kActivityCenterAsPanel then
		if self.scene and not self.scene.isDisposed then
			self.scene:removePopout()
		end
	else
		local curScene = Director:sharedDirector():getRunningScene()
		if curScene and curScene:is(ActivityCenterScene) then
			Director.sharedDirector():popScene()
	    end
	end
	self.scene = nil		

	if self.popoutCb then
		self.popoutCb()
		self.popoutCb = nil
	end
end

function ActivityCenter:tryShowGuide(config)
	Notify:dispatch("AutoPopoutEventAwakenAction", ActivityCenterGuidePopoutAction, config.actId)
end

function ActivityCenter:getGuideKey(config)
	return "activity.center.show.guide." .. config.actId
end

function ActivityCenter:canShowGuide(config)
	if not config or not config.actId then return false end

	local key = self:getGuideKey(config)

	local hasShow = CCUserDefault:sharedUserDefault():getBoolForKey(key, false)
	if hasShow or self.guideRunning then return false end
	return true
end

function ActivityCenter:showGuide(config, next_action)
	if not self:canShowGuide(config) then
		return next_action and next_action()
	end

	local key = self:getGuideKey(config)
	CCUserDefault:sharedUserDefault():setBoolForKey(key, true)

	local scene = HomeScene:sharedInstance()
	if scene and scene.activityButton then
		local btn = scene.activityButton
		local con = scene.iconLayer

		if btn ~= true and IconButtonPool:getBtnState(btn) == IconBtnShowState.HIDE_N_FOLD then
			CCUserDefault:sharedUserDefault():setBoolForKey(key, false)
			return next_action and next_action()
		end

		if not btn:getParent() then
			return next_action and next_action()
		end

		local pos = btn:getPosition()
		local wp = btn:getParent():convertToWorldSpace(pos)
		wp = con:convertToNodeSpace(wp)

		local layer = LayerColor:createWithColor(ccc3(0,0,0), 1400, 1800)
		layer:setOpacity(200)
		con:addChild(layer)

		local newB = ActivityCenterButton:create()
		newB:setPosition(wp)
		con:addChild(newB)

		local action = {
			panelName = "guide_dialogue_act_center",
			panDelay = 0,
			panFade = 0,
		}
		local panel = GameGuideUI:dialogue(nil,action)
		con:addChild(panel)
		panel:setPosition(ccp(wp.x-650, wp.y + 200))

		layer:setTouchEnabled(true, 0, true)
		self.guideRunning = true

		self.closeGuideFunc = function ()
			if next_action then next_action() end
			if layer.isDisposed then return end
			layer:removeFromParentAndCleanup(true)
			newB:removeFromParentAndCleanup(true)
			panel:removeFromParentAndCleanup(true)
			self.guideRunning = false
		end

		layer:addEventListener(DisplayEvents.kTouchTap, function ( ... )
			self:closeGuide()
		end)
	end
end

function ActivityCenter:closeGuide()
	if self.closeGuideFunc and self.guideRunning then
		self.closeGuideFunc()
		self.closeGuideFunc = nil
	end
end

function ActivityCenter:print( ... )
	printx(10, "[ActivityCenter]", ...)
	-- require "hecore.debug.remote"
	-- RemoteDebug:uploadLog(...)
end

ActivityCenter:init()