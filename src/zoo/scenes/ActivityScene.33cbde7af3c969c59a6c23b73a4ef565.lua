-- 活动面板

require "hecore.display.Scene"
require "zoo.util.ActivityUtil"
require "zoo.util.NetworkUtil"
require "zoo.ui.InterfaceBuilder"
require "zoo.panel.broadcast.BroadcastManager"


ActivityData = class()

local ActivityStatus = table.const{
	kLoading = 1,
	kNoCache = 2,
	kCache   = 3,
	kHasNewVersion = 4,
	kNeedManualDownload = 5
}

function ActivityData:ctor(activity)
	self.source = activity.source
	self.version = activity.version
end

-- 获取宣传图
function ActivityData:getNoticeImage( cb )
	assert(type(cb) == "function")
	
	local config = require("activity/" .. self.source)
	local function onSuccess()
		if config.notice then
			cb("activity/" .. config.notice)
		else
			cb(nil)
		end
	end

	local function onError()
		cb(nil)
	end
	if ActivityUtil:isResourceLoaded(config.notice,self.version) and not ActivityUtil:needUpdate(self.source) then 
		onSuccess()
	else
		ActivityUtil:loadNoticeImage(self.source,self.version,onSuccess,onError)
	end
end

function ActivityData:getStatus()
	if self.loading then 
		return ActivityStatus.kLoading
	end

	local cacheVersion = ActivityUtil:getCacheVersion(self.source)

	if cacheVersion == self.version then
		return ActivityStatus.kCache
	elseif self:needManualDownload() then 
		return ActivityStatus.kNeedManualDownload
	elseif cacheVersion == "" then 
		return ActivityStatus.kNoCache
	else
		return ActivityStatus.kHasNewVersion
	end
end


function ActivityData:getMsgNum( ... )
	return ActivityUtil:getMsgNum(self.source)
end

function ActivityData:hasRewardMark( ... )
	return ActivityUtil:hasRewardMark(self.source)
end

function ActivityData:getSize( ... )
	return ActivityUtil:getSize(self.source)
end

function ActivityData:needManualDownload( ... )
	if NetworkUtil:isEnableWIFI() then
		return false
	else
		return require("activity/" .. self.source).needManualDownload or false
		-- return self:getSize() >= ActivityUtil:getManualResourceSize()		
	end
end

function ActivityData:isLoaded( ... )
	local config = require("activity/" .. self.source)

	return package.loaded["activity/" .. config.startLua] ~= nil
end

local isStart = {}
function ActivityData:start(hasLoadAnimation,userClick,successCallback,errorCallback,endCallback, needPopCb, DuanMianData, extra)
	local scene = nil

	if not hasLoadAnimation then 
		local curScene = Director:sharedDirector():getRunningScene()
		if curScene and not curScene:is(ActivityScene) then
			scene = HomeScene:sharedInstance()
		end
	end
	
	local config = require("activity/" .. self.source)

	local function onSuccess()
		GameLauncherContext:getInstance():onOneActivityResLoaded( self.source , self.version )
		
		local function popout()
			if needPopCb and not needPopCb() then
				GameLauncherContext:getInstance():onOneActivityStartFinish( self.source , self.version , false)
				return
			end

			if not hasLoadAnimation then
				local home = HomeScene:sharedInstance()
				if home.updateVersionButton and not home.updateVersionButton.isDisposed then 
					if not home.updateVersionButton.wrapper:isTouchEnabled() then 
						if _G.isLocalDevelopMode then printx(0, "home.updateVersionButton enabled false") end
						if errorCallback then
							errorCallback()
						end
						GameLauncherContext:getInstance():onOneActivityStartFinish( self.source , self.version , false )
						return
				 	end
				end
			end

			if successCallback then
				successCallback()
			end

			if isStart[self.source] then
				ActivityUtil:unLoadResIfNecessary(self.source)
				local hasPopCenter = ActivityCenter:tryPopoutCenter( config.actId )


				if not hasPopCenter then
					require("activity/" .. config.startLua)(userClick,endCallback,DuanMianData,extra)
				end
				
				-- 有曝光
				if config.click and config.actId then 
					local http = ClickActivityHttp.new()
					http:load(config.actId)
				end
				

				isStart[self.source] = false
			end
			GameLauncherContext:getInstance():onOneActivityStartFinish( self.source , self.version , true )
		end

		GameLauncherContext:getInstance():onOneActivityStart( self.source , self.version )
		if scene then
			scene:runAction(CCCallFunc:create(popout))
		else
			popout()
		end
	end
	local function onError()
		if errorCallback then
			errorCallback()
		end

		if not hasLoadAnimation then 
			return
		end
		if scene then 
			scene:runAction(CCCallFunc:create(function( ... )
				CommonTip:showTip(Localization:getInstance():getText('activity.scene.error1'),'negative')
			end))
		else
			CommonTip:showTip(Localization:getInstance():getText('activity.scene.error1'),'negative')
			--"您的网络出现问题，请检查后重新进入"
		end
	end
	local function onProcess( ... )
		-- body
	end

	isStart[self.source] = true
	
	if self:isLoaded() and not ActivityUtil:needUpdate(self.source) then 
		-- setTimeOut(onSuccess,0)
		onSuccess(true)
	else
		GameLauncherContext:getInstance():onOneActivityResStartLoad( self.source , self.version )
		if hasLoadAnimation then
			ActivityUtil:loadRes(self.source,self.version,onSuccess,onError)
		else
			ActivityUtil:loadRes(self.source,self.version,onSuccess,onError,onProcess)			
		end
	end

end

function ActivityData:onNoticeShow( ... )
	local config = require("activity/" .. self.source)
	if config.onNoticeShow then
		pcall(config.onNoticeShow)
	end
end



ActivityScene = class(Scene)

function ActivityScene:create()
	local s = ActivityScene.new()
	s:initScene()
	return s	
end

function ActivityScene:ctor()
	self.activityList = {}
	self.cells = {}

	-- ActivityUtil.onActivitySceneMsgNumChange = function( source )
	-- 	for i,v in ipairs(self.activityList) do
	-- 		if v.source == source then 
	-- 			self:updateCellItem(i - 1)
	-- 		end
	-- 	end
	-- end
	self.onActivityStatusChange = function( source )
		for i,v in ipairs(self.activityList) do
			if v.source == source then 
				self:updateCellItem(i - 1)
			end
		end	
	end

	table.insert(ActivityUtil.onActivityStatusChangeCallbacks,{
		obj = self,
		func = self.onActivityStatusChange
	})
end

function ActivityScene:dispose( ... )
	for k,v in pairs(self.cells) do
		v:dispose()
	end
	-- ActivityUtil.onActivitySceneMsgNumChange = nil

	for i,v in ipairs(ActivityUtil.onActivityStatusChangeCallbacks) do
		if v.obj == self and v.func == self.onActivityStatusChange then 
			table.remove(ActivityUtil.onActivityStatusChangeCallbacks,i)
			break
		end
	end

	Scene.dispose(self)
	InterfaceBuilder:unloadAsset("ui/activity_panel.json")
end


function ActivityScene:onInit(Scene, ...)

	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	
	self.builder = InterfaceBuilder:createWithContentsOfFile("ui/activity_panel.json")
	
	-- self.inAcitivtyTime = WorldSceneShowManager:getInstance():isInAcitivtyTime() 
	-- if self.inAcitivtyTime then
	-- 	local plistPath = "ui/activitySpringFestival_panel.plist"
	-- 	if __use_small_res then  
	-- 		plistPath = table.concat(plistPath:split("."),"@2x.")
	-- 	end
	-- 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistPath)
	-- 	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath)
	-- end

	-- local panelUI = self.builder:buildGroup("activity_panel")
	-- panelUI:setPositionXY(visibleOrigin.x,visibleOrigin.y + visibleSize.height)

	-- -- 调整UI大小和位置
	-- local bg = panelUI:getChildByName("bg")
	-- local designSize = bg:getChildByName("blue"):getGroupBounds().size

	-- bg:setScaleY(visibleSize.height/(designSize.height - 1))

	-- local btn = panelUI:getChildByName("btn")
	-- local btnMarginBottom = designSize.height + btn:getPositionY()
	-- btn:setPositionY(-visibleSize.height + btnMarginBottom)

	-- btn = GroupButtonBase:create(btn)
	-- btn:setString(Localization:getInstance():getText("prop.info.panel.close.txt"))
	-- btn:setEnabled(true)
	-- -- btn:setColorMode(kGroupButtonColorMode.blue)
	-- btn:addEventListener(DisplayEvents.kTouchTap,function(event) self:onKeyBackClicked() end)
	
	-- self:addChild(panelUI)

	local background = LayerGradient:create()
	background:changeWidthAndHeight(visibleSize.width, visibleSize.height)
	background:setStartColor(ccc3(255, 216, 119))
    background:setEndColor(ccc3(247, 187, 129))
    background:setStartOpacity(255)
    background:setEndOpacity(255)
    background:ignoreAnchorPointForPosition(false)
    background:setPositionXY(visibleOrigin.x, visibleOrigin.y)
    self:addChild(background)

    local title = self.builder:buildGroup("activity_paneltop")
    title:setPositionXY(visibleOrigin.x, visibleOrigin.y + visibleSize.height)
    self:addChild(title)

    local bottom = self.builder:buildGroup("activity_panelbottom")
    local bottomSize = bottom:getGroupBounds().size
    local btn = bottom:getChildByName("button")
    btn = GroupButtonBase:create(btn)
    btn:setString(Localization:getInstance():getText("prop.info.panel.close.txt"))
	btn:setEnabled(true)
	btn:addEventListener(DisplayEvents.kTouchTap,function(event) self:onKeyBackClicked() end)
	bottom:setPositionX(visibleSize.width / 2 + visibleOrigin.x)
	bottom:setPositionY(bottomSize.height / 4 + visibleOrigin.y)
	self:addChild(bottom)

	-- tableView
	local tablePosY = 120 + visibleOrigin.y
	local tableViewWidth = visibleSize.width
	local tableViewHeight = title:getGroupBounds():getMinY() - tablePosY
	
	self.tableView = self:buildTableView(tableViewWidth,tableViewHeight)
	self.tableView:ignoreAnchorPointForPosition(false)
	self.tableView:setAnchorPoint(ccp(0.5,0))
	self.tableView:setPositionX(visibleOrigin.x + visibleSize.width/2)
	self.tableView:setPositionY(tablePosY)
	self:addChild(self.tableView)

end
function ActivityScene:onEnter(activitys)
	if activitys then
		for k,v in pairs(self.cells) do
			v:dispose()
		end

		self.activityList = {}
		self.cells = {}
		for k,v in pairs(activitys) do
			table.insert(self.activityList,ActivityData.new(v))
		end

		for i,v in ipairs(self.activityList) do
			table.insert(self.cells,self:buildItem(i - 1))
		end
		table.insert(self.cells,self:buildItem(#self.activityList + 1))

		self.tableView:reloadData()

		for i,v in ipairs(self.activityList) do
			if v:getStatus() == ActivityStatus.kNoCache or v:getStatus() == ActivityStatus.kHasNewVersion then  
				self:downLoad(i - 1)
			end
		end

		for i,v in ipairs(self.activityList) do
			v:onNoticeShow()
		end
	end
	BroadcastManager:getInstance():onEnterScene(self)
end

function ActivityScene:onKeyBackClicked()	
	Director.sharedDirector():popScene()
end

function ActivityScene:onEnterForeGround()
	self:dp(Event.new(SceneEvents.kEnterForeground, nil, self));
end

-- 
function ActivityScene:buildTableView(width,height)
	local tableViewRender = 
	{
		setData = function () end
	}
	local context = self
	function tableViewRender:getContentSize(tableView,idx)
		return CCSizeMake(width,283 + 12)
	end
	function tableViewRender:numberOfCells()
		return #context.cells
	end
	function tableViewRender:buildCell(cell,idx)

		local item = context.cells[idx + 1]

		local size = item:getChildByName("bg"):getGroupBounds().size

		item:setPositionX( width/2 - size.width/2)
		item:setPositionY(self:getContentSize(nil,idx).height - 12)
		-- item:getChildByName("msgBg"):setVisible(false)
		-- item:getChildByName("msgNum"):setVisible(false)

		item.refCocosObj:removeFromParentAndCleanup(false)
		cell.refCocosObj:addChild(item.refCocosObj)

		context:updateCellItem(idx)
	end

	local tableView = TableView:create(tableViewRender,width,height)

	tableView:ad(DisplayEvents.kTouchItem,function(evt) self:cellTouched(evt.data) end)
	-- tableView:setTouchEnabled(false)

	return tableView
end

function ActivityScene:updateCellItem( idx )
	
	if idx >= #self.activityList then
		return 
	end

	local item = self.cells[idx + 1]

	if idx < #self.activityList then
		local msgNum = self.activityList[idx + 1]:getMsgNum()
		local rewardMark = self.activityList[idx + 1]:hasRewardMark()

		item:getChildByName("msgBg"):setVisible(msgNum > 0 and not rewardMark)
		item:getChildByName("msgNum"):setVisible(msgNum > 0 and not rewardMark)
		-- 
		item:getChildByName("msgNum"):setString(
			Localization:getInstance():getText("activity.scene.message.text1",{n=msgNum})
		)

		item:getChildByName("rewardIcon"):setVisible(rewardMark)
	end

	-- 
	local status = self.activityList[idx + 1]:getStatus()
	local progressUI = item:getChildByName("progress")
	if status == ActivityStatus.kLoading then	
		if progressUI == nil then
			progressUI = self:buildProgress()
			local progressBounds = progressUI:getGroupBounds()
			local bgBoundingBox = item:getChildByName("bg"):boundingBox()
			
			progressUI:setPositionX(bgBoundingBox:getMidX() - progressBounds.size.width/2)
			progressUI:setPositionY(bgBoundingBox:getMidY() + progressBounds.size.height/2)
			
			progressUI.name = "progress"
			item:addChild(progressUI)
		end
		progressUI:setPercentage(self.activityList[idx + 1].percent)
	elseif progressUI then 
		progressUI:removeFromParentAndCleanup(true)
	end

	-- 
	local needManualDownloadUI = item:getChildByName("needManualDownload")
	if status == ActivityStatus.kNeedManualDownload then
		if needManualDownloadUI == nil then
			needManualDownloadUI = self:buildDownLoad(idx)
			local downLoadBounds = needManualDownloadUI:getGroupBounds()
			local bgBoundingBox = item:getChildByName("bg"):boundingBox()

			needManualDownloadUI:setPositionX(bgBoundingBox:getMidX() - downLoadBounds.size.width/2)
			needManualDownloadUI:setPositionY(bgBoundingBox:getMidY() + downLoadBounds.size.height/2)

			needManualDownloadUI.name = "needManualDownload"
			item:addChildAt(needManualDownloadUI,2)
		end
	elseif needManualDownloadUI then
		needManualDownloadUI:removeFromParentAndCleanup(true)
	end
end

function ActivityScene:buildDownLoad( idx )

	local downLoadUI = self.builder:buildGroup("download_panel")

	local btn = downLoadUI:getChildByName("btn")
	-- downLoadUI.button = btn
	btn:setTouchEnabled(true)
	btn:setButtonMode(true)
	btn:addEventListener(DisplayEvents.kTouchTap,function( evt ) self:downLoad(idx) end)

	btn.hitTestPoint = function (s,worldPosition, useGroupTest)
		if self.tableView:boundingBox():containsPoint(self:convertToNodeSpace(worldPosition)) then
			return CocosObject.hitTestPoint(s,worldPosition, useGroupTest)
		else
			return false
		end
	end

	-- 
	downLoadUI:getChildByName("text"):setString(
		Localization:getInstance():getText('activity.scene.message.text2',
			{n= string.format("%.2fM",self.activityList[idx + 1]:getSize() / (1024 * 1024))}
		)
	)

	return downLoadUI
end

function ActivityScene:buildProgress( ... )

	local progressUI = self.builder:buildGroup("activity_progress")
	local progressBounds = progressUI:getGroupBounds()
	
	local progressText = progressUI:getChildByName("progressText")
	progressText:setDimensions(CCSizeMake(0,0))
	progressText:setAnchorPoint(ccp(0.5,0.5))
	progressText:setPositionXY(progressBounds:getMidX(),progressBounds:getMidY())
	progressText:setString("0%")

	local progress = progressUI:getChildByName("progress")
	progress:removeFromParentAndCleanup(false)
	local ccprogress = CCProgressTimer:create(progress.refCocosObj)
	progress:dispose()

	ccprogress:setType(kCCProgressTimerTypeRadial)
	ccprogress:setPercentage(0)
	ccprogress:setAnchorPoint(ccp(0.5,0.5))
	ccprogress:setPosition(ccp(progressBounds:getMidX(),progressBounds:getMidY()))

	-- 
	progressUI:addChild(CocosObject.new(ccprogress))

	function progressUI:setPercentage( percent )
		percent = math.floor(percent or 0)
		progressText:setString(tostring(percent) .. "%")
		-- ccprogress:setPercentage(percent)
		ccprogress:stopAllActions()
		ccprogress:runAction(CCProgressFromTo:create(
			0.01,
			ccprogress:getPercentage(),
			percent
		))
	end

	return progressUI
end

function ActivityScene:buildLoadingAnimation( ... )

	local container	= Layer:create()

	local batch = SpriteBatchNode:createWithTexture(CCSprite:createWithSpriteFrameName("loading_ico_1 instance 10000"):getTexture())
	container:addChild(batch)

	local currentPosition = 0
	for i = 1, 6 do
		local animal = Sprite:createWithSpriteFrameName("loading_ico_"..i.." instance 10000")
		local contentSize = animal:getContentSize()
		animal:setPosition(ccp(currentPosition, 8))
		animal.oriX = currentPosition
		animal.oriY	= 8
		animal.move = function( self, delay )
			self:stopAllActions()
			self:setPosition(ccp(self.oriX, self.oriY))
			self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCSequence:createWithTwoActions(CCMoveTo:create(0.25, ccp(self.oriX, self.oriY + 25)), CCMoveTo:create(0.25, ccp(self.oriX, self.oriY)))))
		end
		currentPosition = currentPosition + contentSize.width + 5
		batch:addChild(animal)
		if i == 6 then currentPosition = currentPosition - contentSize.width - 5 end
	end
	local function onStartAnimation()
		for i = 0, 5 do
			local animal = batch:getChildAt(i)
			if animal then animal:move(i * 0.2) end
		end
	end
	batch:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(onStartAnimation), CCDelayTime:create(1.5))))
	batch:setPositionX(-currentPosition/2)

	--
	labelText = Localization:getInstance():getText('activity.scene.loading.text')
	local label = TextField:create(labelText, nil, 24)
	label:setPositionY(-44)
	container:addChild(label)

	return container


end

function ActivityScene:buildItem( idx )
	
	local item = self.builder:buildGroup("activity_item")
	local bg = item:getChildByName("bg")
	local bgBoundingBox = bg:boundingBox()

	local msgNum = item:getChildByName("msgNum")
	local msgBgBoundingBox = item:getChildByName("msgBg"):boundingBox()
	-- msgNum:setString("999个新消息")
	msgNum:setDimensions(CCSizeMake(0,0))
	msgNum:setAnchorPoint(ccp(0.5,0.5))
	msgNum:setPositionX(msgBgBoundingBox:getMidX() + msgBgBoundingBox.size.width * 0.1)
	msgNum:setPositionY(msgBgBoundingBox:getMidY() + msgBgBoundingBox.size.height * 0.1)

	for _,v in pairs({"msgNum","msgBg","rewardIcon"}) do
		item:getChildByName(v):setVisible(false)
	end

	item:addChildAt(CocosObject:create(),1)
	item:addChildAt(CocosObject:create(),2)
	if idx < #self.activityList then 

		local animation = self:buildLoadingAnimation()
		animation:setPositionX(bgBoundingBox:getMidX())
		animation:setPositionY(bgBoundingBox:getMidY())
		item:addChild(animation)

		local cocosObj = item.refCocosObj
		cocosObj:retain()
		self.activityList[idx + 1]:getNoticeImage(function(imgPath)
			if imgPath then
				local noticeImage = CCSprite:create(imgPath)
				noticeImage:setAnchorPoint(ccp(0.5,0.5))
				noticeImage:setPositionX(bgBoundingBox:getMidX())
				noticeImage:setPositionY(bgBoundingBox:getMidY())
				cocosObj:addChild(noticeImage,1)

				CCTextureCache:sharedTextureCache():removeTextureForKey(
					CCFileUtils:sharedFileUtils():fullPathForFilename(imgPath)
				)
			end
			if not animation.isDisposed then
				animation:removeFromParentAndCleanup(true)
			end
			cocosObj:release()
		end)
	else
		local more = self.builder:buildGroup("activity_more")
		local moreSize = more:getGroupBounds().size
		more:setPositionX(bgBoundingBox:getMidX() - moreSize.width/2)
		more:setPositionY(bgBoundingBox:getMidY() + moreSize.height/2)

		item:addChildAt(more,1)
	end

	-- if self.inAcitivtyTime then 
	-- 	-- 25,25
	-- 	for i,v in ipairs({
	-- 		ccp(25,-25),
	-- 		ccp(bgBoundingBox.size.width-25,-25),
	-- 		ccp(bgBoundingBox.size.width-25,-(bgBoundingBox.size.height - 25)),
	-- 		ccp(25,-(bgBoundingBox.size.height - 25))
	-- 	}) do
	-- 		local frame = CCSprite:createWithSpriteFrameName("imgs/activity_item_frame0000")
	-- 		frame:setPosition(ccp(46,0))
	-- 		frame:setAnchorPoint(ccp(1,0))

	-- 		local container = CocosObject:create()
	-- 		container:setContentSize(CCSizeMake(46,46))
	-- 		container:addChild(CocosObject.new(frame))

	-- 		container:setAnchorPoint(ccp(0.5,0.5))
	-- 		container:setPosition(v)
	-- 		container:setRotation((i-1)*90) 
	-- 		item:addChild(container)
	-- 	end
	-- end
	return item
end

function ActivityScene:cellTouched(idx)

	if idx >= #self.activityList then 
		return
	end

	if not self.activityList[idx + 1].isLoadError and self.activityList[idx + 1]:getStatus() ~= ActivityStatus.kCache then
		return
	end

	self.activityList[idx + 1]:start(true,true)


	-- local source = self.activityList[idx + 1].source
	-- local version = self.activityList[idx + 1].version
	-- local config = require("activity/" .. source)

	-- local function onSuccess( ... )
	-- 	require("activity/" .. config.startLua)()
	-- end
	-- local function onError()
	-- 	CommonTip:showTip(
	-- 		Localization:getInstance():getText('activity.scene.error1'),'negative'
	-- 	)
	-- 		--"您的网络出现问题，请检查后重新进入"
	-- end

	-- if ActivityUtil:isSrcLoaded(config.src,version) and ActivityUtil:isResourceLoaded(config.resource,version) then 
	-- 	onSuccess()
	-- else
	-- 	ActivityUtil:loadRes(source,version,onSuccess,onError)
	-- end
end

function ActivityScene:downLoad( idx )
	local source = self.activityList[idx + 1].source
	local version = self.activityList[idx + 1].version

	if self.activityList[idx + 1]:isLoaded() and not ActivityUtil:needUpdate(source) then 
		return
	end


	-- local config = require("activity/" .. source)
	-- if ActivityUtil:isSrcLoaded(config.src,version) and ActivityUtil:isResourceLoaded(config.resource,version) then 
	-- 	return
	-- end

	self.activityList[idx + 1].loading = true
	self.activityList[idx + 1].isLoadError = false

	local function onError()
		if not self.refCocosObj or self.isDisposed then 
			return
		end

		CommonTip:showTip(
			Localization:getInstance():getText('activity.scene.error1'),'negative'
		)
		
		self.activityList[idx + 1].percent = 0 
		self.activityList[idx + 1].loading = false

		self.activityList[idx + 1].isLoadError = true
		--self.tableView:updateCellAtIndex(idx)
		self:updateCellItem(idx)
	end

	local function onProcess( data )
		if not self.refCocosObj or self.isDisposed then 
			return
		end

		if data.curSize >= data.totalSize then 
			return 
		end

		if data.totalSize == 0 then 
			self.activityList[idx + 1].percent = 0 
		else
			self.activityList[idx + 1].percent = 100 * data.curSize / data.totalSize
		end

		--self.tableView:updateCellAtIndex(idx)
		self:updateCellItem(idx)
	end
	local function onSuccess( ... )

		if not self.refCocosObj or self.isDisposed then 
			return
		end

		self.activityList[idx + 1].percent = 100
		self.activityList[idx + 1].loading = false

		--self.tableView:updateCellAtIndex(idx)

		self:updateCellItem(idx)
	end
	ActivityUtil:loadRes(source,version,onSuccess,onError,onProcess)

	self.activityList[idx + 1].loading = true
	self.tableView:updateCellAtIndex(idx)
end


function ActivityScene:refresh( activitys )
	
	activitys = activitys or {}

	for k,v in pairs(self.cells) do
		v:dispose()
	end

	self.activityList = {}
	self.cells = {}
	for k,v in pairs(activitys) do
		table.insert(self.activityList,ActivityData.new(v))
	end

	for i,v in ipairs(self.activityList) do
		table.insert(self.cells,self:buildItem(i - 1))
	end
	table.insert(self.cells,self:buildItem(#self.activityList + 1))

	self.tableView:reloadData()

	-- for i,v in ipairs(self.activityList) do
	-- 	self:downLoad(i - 1)
	-- end

end