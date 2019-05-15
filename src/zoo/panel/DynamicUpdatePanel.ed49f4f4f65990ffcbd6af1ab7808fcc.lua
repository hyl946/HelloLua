require "hecore.ui.PopoutManager"

local UIUtils = require 'zoo.panel.UIHelper'
local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'


DynamicUpdatePanel = class(BasePanel)

local lastCheckUpdateTime = 0
local currentPanel = nil
local function parseDynamicNameValuePair( item, target )
	if item ~= nil and item ~= "" then
		local list = string.split(item, ":")
		if list and #list == 2 then
			target[list[1]] = list[2]
		end
	end
end
local function parseDynamicUserData( userdata )
	local result = {}
	if userdata ~= nil and userdata ~= "" then
		local list = string.split(userdata, ";")
		if list and #list > 0 then
			for i,v in ipairs(list) do
				parseDynamicNameValuePair( v, result )
			end
		else
			parseDynamicNameValuePair( userdata, result )
		end
	end
	return result
end
local function onResourcePrompt( data,notUsePopoutQueue, callback)
	local function onCancelLoad() data.resultHandler(0) end
	local function onConfirmLoad() data.resultHandler(1) end
	--local needsize = data.status.needDownloadSize
	local needsize = 0
	local userdata = nil
	if data and data.status then 
		needsize = data.status.needDownloadSize or 0 
		userdata = data.status.userdata 
	end

	if _G.isLocalDevelopMode then printx(0, "onResourcePrompt:"..tostring(needsize)) end
	local config = parseDynamicUserData(userdata)
	local force = false
	if config and (config["force"] == "1" or config["review"] == "1") then force = true end
	if _G.isLocalDevelopMode then printx(0, "require silent dynamic loading"..table.tostring(config)) end

	-- 以updateinfo.type为准 
	-- if needsize > 0 then

	AsyncSkinLoader:create(DynamicUpdatePanel, {
		onConfirmLoad, 
		onCancelLoad, 
		needsize,
		force 
	}, DynamicUpdatePanel.getSkin, function ( panel )

		if currentPanel then
			panel:dispose()
			return
		end

		if panel then 
			if notUsePopoutQueue then
				local button = HomeScene:sharedInstance().updateVersionButton
				if button and not button.isDisposed then
					button.wrapper:setTouchEnabled(false)
				end
				panel:popout(notUsePopoutQueue)
			else
				HomeScene:sharedInstance():runAction(CCCallFunc:create(function( ... )
					local button = HomeScene:sharedInstance().updateVersionButton
					if button and not button.isDisposed then
						button.wrapper:setTouchEnabled(false)
					end
					panel:popout(notUsePopoutQueue)
				end))
			end

			if callback then callback(panel) end
		end
	end, function ( ... )
		local button = HomeScene:sharedInstance().updateVersionButton
		if button and not button.isDisposed then
			button.wrapper:setTouchEnabled(true)
		end
	end)
end

-- notUsePopoutQueue 活动里弹动更面板不能加到队列里
function DynamicUpdatePanel:onCheckDynamicUpdate(isAutoPopout,successCallback,failCallback,notUsePopoutQueue)

	local function __CheckDynamicUpdate( ... )
	-- local now = os.time()
	-- local kMinTime = 10 * 60 * 1000 -- each 10 minutes check new update.
		local scene = Director:sharedDirector():getRunningScene()
		-- local user = UserManager.getInstance().user
		-- if user and user:getTopLevelId() < 20 then return end
		if not NewVersionUtil:hasDynamicUpdate() or not scene then 
			if failCallback then
				failCallback()
			end
			return 
		end
		
		local function onResourceLoaderCallback( event, data )
			if _G.isLocalDevelopMode then printx(0, "event:", event, table.tostring(data)) end
			if event == ResCallbackEvent.onPrompt then
				if not currentPanel then
					onResourcePrompt(data,notUsePopoutQueue, function ( panel )
						currentPanel = panel
					end)
				end
			elseif event == ResCallbackEvent.onSuccess then 
				if currentPanel then 
					currentPanel:onSuccess() 
				end
				if successCallback then
					successCallback()
				end
			elseif event == ResCallbackEvent.onProcess then
				local progress = 0
		    	if data.totalSize > 0 then progress = data.curSize / data.totalSize end
		    	if currentPanel then currentPanel:setProgress(progress) end
		    elseif event == ResCallbackEvent.onError then 
		    	if data.errorCode == 2014 then 
		    		he_log_info("load required res cancel")

		    	elseif not isAutoPopout then 
		    		--这两种情况走不到 onPrompt,导致没弹面板
			    	if data.item == "static_settings" or data.item == "static_config" then
			    		he_log_error("load config fail, errorCode: " .. tostring(data.errorCode) .. ", item: " .. tostring(data.item))
			    		
			    		CommonTip:showTip(Localization:getInstance():getText("new.version.dynamic.settingfile.error"), "negative")		    		
			    	
						local updateVersionButton = HomeScene:sharedInstance().updateVersionButton
						if updateVersionButton and not updateVersionButton.isDisposed then 
							updateVersionButton.wrapper:setTouchEnabled(true)
						end
			    	elseif data.errorCode == 2015 then --没有文件可以下载,已经是最新版本

			    		CommonTip:showTip(Localization:getInstance():getText("new.version.dynamic.isnew.error"), "negative")	

			    		if NewVersionUtil:hasDynamicUpdate() then
							UserManager.getInstance().updateInfo = nil
						end

						local updateVersionButton = HomeScene:sharedInstance().updateVersionButton
						if updateVersionButton then 
							-- updateVersionButton:removeFromParentAndCleanup(true)
							HomeScene:sharedInstance().rightBottomRegionLayoutBar:removeItem(updateVersionButton)
							HomeScene:sharedInstance().updateVersionButton = nil
						end
					else
				    	if currentPanel then currentPanel:onSuccess(data.errorCode) end
				    	he_log_warning("load required res error, errorCode: " .. tostring(data.errorCode) .. ", item: " .. tostring(data.item))
					end
			    else
			    	if currentPanel then currentPanel:onSuccess(data.errorCode) end
			    	he_log_warning("load required res error, errorCode: " .. tostring(data.errorCode) .. ", item: " .. tostring(data.item))
			    end

			    if failCallback then
			    	failCallback()
			    end
			end
		end

		ResourceLoader.loadRequiredResWithPrompt(onResourceLoaderCallback)	

	end

	local DownloaderWithLoading = require 'zoo.panel.DownloaderWithLoading'

	local skinUrl = DynamicUpdatePanel:getSkin()
	local skinUrls = {}
	if skinUrl then
		skinUrls = { AsyncSkinLoader:getSkinUrls(skinUrl) }
	end

	-- local downloader = DownloaderWithLoading:create(skinUrls, function ( ret )
		-- AsyncSkinLoader:setResult(DynamicUpdatePanel, ret)

	__CheckDynamicUpdate()

	-- end, function ( ... )
		-- local updateVersionButton = HomeScene:sharedInstance().updateVersionButton
		-- if updateVersionButton and not updateVersionButton.isDisposed then 
			-- updateVersionButton.wrapper:setTouchEnabled(true)
		-- end
	-- end)

end

function DynamicUpdatePanel:create(onConfirmLoad, onCancelLoad, needsize,force)
	local updateInfo = UserManager:getInstance().updateInfo
	if not updateInfo then return nil end
	local item = DynamicUpdatePanel.new()
	item:loadRequiredResource('ui/update_new_version_panel_ver_47.json')
	if not item:buildUI(onConfirmLoad, onCancelLoad, needsize,force) then
		item:dispose()
		item = nil
	end
	return item
end

function DynamicUpdatePanel:buildUI(onConfirmLoad, onCancelLoad, needsize,requireMustLoad)
	local ui = self:buildInterfaceGroup("update_version_panel_47_1518/panel")--ResourceManager:sharedInstance():buildGroup("DynamicUpdatePanel")
	self.ui = ui
	BasePanel.init(self, self.ui)

	self.onCancelLoad = onCancelLoad

	self.helpTip = self.ui:getChildByName("helpTip")
	self.helpTip:setVisible(false)

	UIUtils:loadArmature('skeleton/update_version_47', 'update_version_47', 'update_version_47')
	self.paper = self.ui:getChildByName('paper')
	self.paper:setVisible(false)
	local function __processAnimHolder( nodeName, animName )
		self[nodeName] = self.ui:getChildByName(nodeName)
		self[nodeName..'_index'] = self.ui:getChildIndex(self[nodeName])
		self[nodeName]:setVisible(false)

		self[nodeName..'_anim'] = UIUtils:createArmature(animName)
		self.ui:addChildAt(self[nodeName..'_anim'], self[nodeName..'_index'])
		self[nodeName..'_anim']:setPosition(ccp(
			self[nodeName]:getPositionX(),
			self[nodeName]:getPositionY()
		))
	end

	__processAnimHolder('chicken_front', 'update_version_47/chicken_front')
	__processAnimHolder('chicken_end', 'update_version_47/ji')
	__processAnimHolder('paper_anim', 'update_version_47/zhi_animation')

	self.paper_anim_anim:setVisible(false)

	self:buildLabels()

	self:createPaperMask()
	self:createLid()

	
	local titleHolder = self.ui:getChildByName('title')
	titleHolder:setString('  ')
	local titleHolderIndex = self.ui:getChildIndex(titleHolder)
	titleHolder:setAnchorPointCenterWhileStayOrigianlPosition()
	local pos = titleHolder:getPosition()

	self.title = BitmapText:create('', 'fnt/questionnaire.fnt')
	self.title:setAnchorPoint(ccp(0.5, 0.5))
	self.title:setPosition(ccp(pos.x, pos.y))
	self.ui:addChildAt(self.title, titleHolderIndex)

	self.title.__setText = self.title.setText
	self.title.setText = function ( context, text )
		context:__setText(text)
		context:setAnchorPoint(ccp(0.5, 0.5))
		context:setPosition(ccp(pos.x, pos.y))
	end



	self.title:setText(Localization:getInstance():getText("new.version.title")) 


	self.tip = self.ui:getChildByName("tip")
	------------

	self.confirm = GroupButtonBase:create(self.ui:getChildByName("btn"))

	
	local progress = self.ui:getChildByName("progress")
	self.pgtxt = progress:getChildByName("pgtxt")
	self.pgtxt:setAlignment(kTextAlignment.kCCTextAlignmentCenter)
	self.progress = HomeSceneItemProgressBar:create(progress, 0, 100)

	self.pgtxt:removeFromParentAndCleanup(false)
	progress:addChild(self.pgtxt)
	self.pgtxt:setPositionY(self.pgtxt:getPositionY() - 6)
	self.progress:setVisible(false)
	--todo 进度条闪星星


	self.closeBtn = self.ui:getChildByName('closeBtn')

	local bg = self.ui:getChildByName("bg")

	local rewards
	local updateInfo = UserManager:getInstance().updateInfo
	if type(updateInfo) ~= "table" then return false end
	rewards = updateInfo.rewards
	if type(rewards) ~= "table" then rewards = {} end


	-- if __WIN32 then
		-- rewards = {{itemId = 10001, num = 2}}
	-- end

	self.items = {}

	if #rewards == 0 then
		
		__processAnimHolder('banzi', 'update_version_47/banzi')
		self.ui:getChildByName('reward'):setVisible(false)

		self.banzi_anim:setVisible(false)

		local bannerCon = UIUtils:getCon(self.banzi_anim, 'banner')

		local banner = UIUtils:safeCreateSpriteByFrameName('update_version_panel_47_1518/skin/pic_10000')
		banner:setAnchorPoint(ccp(0, 0))
		bannerCon:addChild(banner.refCocosObj)
		banner:dispose()

	else
		local items = rewards

		__processAnimHolder('reward', 'update_version_47/guang')
		self.ui:getChildByName('banzi'):setVisible(false)
		
		self.reward_anim:setVisible(false)

		local rewardCon = UIUtils:getCon(self.reward_anim, 'reward')

		local function buildRewardItem(rewardItem)
			
			local sp = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
			local num = BitmapText:create('', 'fnt/event_default_digits.fnt')
			num:setText('x'..tostring(rewardItem.num))
			num:setAnchorPoint(ccp(0, 0))

			sp:setAnchorPoint(ccp(0.5, 0.5))
			sp:setPosition(ccp(82, 90))

			sp:addChild(num)
			num:setPositionX(70)
			sp:setScale(1.2)
			return sp
		end

		local rewardItem = buildRewardItem(items[1])
		rewardCon:addChild(rewardItem.refCocosObj)
		rewardItem:dispose()

	end


	local updSize = math.floor(needsize/1024/102.4) / 10
	if updSize < 0.1 then updSize = 0.1 end
	self.tip:setString(Localization:getInstance():getText("new.version.dynamic.tip.text",{ n = updSize }))
	
	if #rewards > 0 then
		--更新领奖励
		self.confirm:setString(Localization:getInstance():getText("new.version.button.download"))
	else
		--立即更新
		self.confirm:setString(Localization:getInstance():getText("new.version.button.download.zero"))
	end

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()


	local function onCloseTapped() 
		self:onCloseBtnTapped()
	end

	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	local function onCloseButtonTapped(evt)
		DcUtil:UserTrack({ category='Ui', sub_category='click_download', t=1})
		onCloseTapped(evt)
	end
	self.closeBtn:ad(DisplayEvents.kTouchTap, onCloseButtonTapped)

	self.succeedFlag = 0
	local function onConfirmTouch( evt )  
		if self.succeedFlag == 1 then 
			if __ANDROID then PrepackageUtil:restart()
			else Director.sharedDirector():exitGame() end
		elseif self.succeedFlag == 0 then
			self.succeedFlag = -1
			local rewards = UserManager:getInstance().updateInfo.rewards
			if type(rewards) ~= "table" then rewards = {} end
			if #rewards > 0 then
				self.tip:setString(Localization:getInstance():getText("new.version.dynamic.downloading.tip"))
			else
				self.tip:setString(Localization:getInstance():getText("new.version.dynamic.downloading.tip.zero"))
			end
			self.allowBackKeyTap = false
			self.confirm:setVisible(false)
			self.progress:setVisible(true)
			self.pgtxt:setVisible(true)
			self.closeBtn:setVisible(false)
			self.title:setText(Localization:getInstance():getText("new.version.dynamic.title.loading"))
			DcUtil:UserTrack({ category='update', sub_category='update_panel_button'})
			if onConfirmLoad ~= nil then onConfirmLoad() end
		elseif self.succeedFlag == 2 then onCloseTapped() end
	end

	local function onConfirmButtonTouch(evt)
		DcUtil:UserTrack({ category='Ui', sub_category='click_download', t=2})
		onConfirmTouch(evt)
	end
	self.confirm:ad(DisplayEvents.kTouchTap, onConfirmButtonTouch)
	-- 已经没内容下载了
	if needsize == 0 then
		onConfirmTouch()
	end

	if requireMustLoad then
		self.closeBtn:setVisible(false)
		self.closeBtn:rma()
	end


	return true
end

function DynamicUpdatePanel:onCloseBtnTapped( ... )
	if self.onCancelLoad ~= nil then self.onCancelLoad() end
	self:remove() 

	local updateVersionButton = HomeScene:sharedInstance().updateVersionButton
	if updateVersionButton and not NewVersionUtil:hasDynamicUpdate() then 
		-- updateVersionButton:removeFromParentAndCleanup(true)
		HomeScene:sharedInstance().rightBottomRegionLayoutBar:removeItem(updateVersionButton)
		HomeScene:sharedInstance().updateVersionButton = nil
	end
end

function DynamicUpdatePanel:dispose()

	self:dispatchEvent(Event.new(AsyncSkinLoader.Events.kPanelClose, nil, self))

	UIUtils:unloadArmature('skeleton/update_version_47')
	BasePanel.dispose(self)

end


function DynamicUpdatePanel:setProgress( porgress )
	local bg = self.bg
	if self.isDisposed then return end
	if porgress < 0 then porgress = 0 end
	if porgress > 1 then porgress = 1 end
	local percent = math.floor(porgress * 100)
	self.progress:setCurNumber(percent)
	self.pgtxt:setText(tostring(percent)..'%')
end

function DynamicUpdatePanel:onSuccess(err)
	if self.isDisposed then return end
	self.progress:setVisible(false)
	self.pgtxt:setVisible(false)
	if err then 
		self.succeedFlag = 2
		-- self.label:setString(Localization:getInstance():getText("new.version.package.failure.label"))
		self.confirm:setString(Localization:getInstance():getText("button.ok"))
		self.confirm:setVisible(true)

		-- 发现新版本！
		-- self:setPanelTitleByIndex(1)
		self.title:setText(Localization:getInstance():getText("new.version.dynamic.title"))

	else
		self.succeedFlag = 1

		-- 下载成功！
		self.title:setText(Localization:getInstance():getText("new.version.dynamic.title.finish"))

		-- 成功去掉updateinfo 信息
		local rewards = UserManager:getInstance().updateInfo.rewards
		if type(rewards) ~= "table" then rewards = {} end
		if __ANDROID then
			if #rewards > 0 then
				-- self.label:setString(Localization:getInstance():getText("new.version.dynamic.complete.unattended.label"))
				self.tip:setString(Localization:getInstance():getText("new.version.dynamic.complete.unattended.tip"))
			else
				-- self.label:setString(Localization:getInstance():getText("new.version.dynamic.complete.unattended.label.zero"))
				self.tip:setString(Localization:getInstance():getText("new.version.dynamic.complete.unattended.tip.zero"))
			end
			self.confirm:setString(Localization:getInstance():getText("new.version.button.download.android"))
		else
			if #rewards > 0 then
				-- self.label:setString(Localization:getInstance():getText("new.version.dynamic.complete.label"))
				self.tip:setString(Localization:getInstance():getText("new.version.dynamic.complete.tip"))
			else
				-- self.label:setString(Localization:getInstance():getText("new.version.dynamic.complete.label.zero"))
				self.tip:setString(Localization:getInstance():getText("new.version.dynamic.complete.tip.zero"))
			end
			self.confirm:setString(Localization:getInstance():getText("new.version.button.download.ios"))
		end

		if NewVersionUtil:hasDynamicUpdate() then
			UserManager.getInstance().updateInfo = nil
		end

		self.confirm:setVisible(true)

	end
end
function DynamicUpdatePanel:remove()
	currentPanel = nil
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
	local button = HomeScene:sharedInstance().updateVersionButton
	if button and not button.isDisposed then
		button.wrapper:setTouchEnabled(true)
	end
end

function DynamicUpdatePanel:getSkin( ... )
	if not UserManager.getInstance().updateInfo then
		return nil
	end

	CCUserDefault:sharedUserDefault():setStringForKey(
		'update.panel.updateRes', 
		UserManager.getInstance().updateInfo.updateRes or ''
	)

	return UserManager.getInstance().updateInfo.updateRes
end

function DynamicUpdatePanel:popout(notUsePopoutQueue)

	if notUsePopoutQueue then
		PopoutManager:sharedInstance():add(self, true, false)
		self:popoutShowTransition()
	else
		PopoutQueue:sharedInstance():push(self,true, false)
	end
	self.allowBackKeyTap = true
end

function DynamicUpdatePanel:popoutShowTransition( ... )
	if self.isDisposed then return end
	self:playAnim()
end

function DynamicUpdatePanel:createLid(  )
	self.lid = self.ui:getChildByName('gaizi')

	local frameNum = 6

	local function showFrame( index)
		for i = 1, frameNum do
			self.lid:getChildByName(tostring(i)):setVisible(false)
		end
		self.lid:getChildByName(tostring(index)):setVisible(true)
	end

	showFrame(1)

	local function playLidAnim( ... )
		
		local array = CCArray:create()
		for i = 2, frameNum do
			array:addObject(CCCallFunc:create(function ( ... )
				if self.lid.isDisposed then return end
				showFrame(i)
			end))
			array:addObject(CCDelayTime:create(1/18))
		end
		self.lid:runAction(CCSequence:create(array))
	end

	self.lid.play = playLidAnim
end

function DynamicUpdatePanel:delayCallback(time, callback )
    if self.isDisposed then return end

    self.ui:runAction(
        CCSequence:createWithTwoActions(
            CCDelayTime:create(time), 
            CCCallFunc:create(callback)
        )
    )
end

function DynamicUpdatePanel:buildLabels( ... )

	local paper = self.paper

	local tips = UserManager.getInstance().updateInfo.newTips or '功能有一些小更新哦~'
	tips = string.gsub(tips, '\r', '')
	tips = string.gsub(tips, '\n', '')
	tips = string.split(tips, '\\n')


	local contentHolder = paper:getChildByName('paperContent')
	contentHolder:setVisible(false)
	local contentPos = contentHolder:getPosition()
	local contentSize = contentHolder:getContentSize()
	local scaleX, scaleY = contentHolder:getScaleX(), contentHolder:getScaleY()

	local scroll = VerticalScrollable:create(contentSize.width*scaleX, contentSize.height*scaleY, true)
    scroll:setIgnoreHorizontalMove(false)
    local scrollLayout = VerticalTileLayout:create(contentSize.width)
    scroll:setContent(scrollLayout)


    for index = 1, #tips do
        local text = ''

        text = tips[index]

        local item = self:buildLabelItem(text)
        local itemInLayout = ItemInLayout:create()
        itemInLayout:setContent(item)
        itemInLayout:setHeight(itemInLayout:getHeight() - 10)
        scrollLayout:addItem(itemInLayout)

    end
    scroll:updateScrollableHeight()

    paper:addChild(scroll)
    scroll:setPosition(ccp(contentPos.x, contentPos.y))


end

function DynamicUpdatePanel:buildLabelItem( text )
	local itemUI = self:buildInterfaceGroup('update_version_panel_47_1518/item')
	local label = itemUI:getChildByName('label')
	local size = label:getDimensions()
	label:setDimensions(CCSizeMake(size.width, 0))
	label:setString(text)

	local up = itemUI:getChildByName('up')
	local down = itemUI:getChildByName('down')

	down:setPositionY(label:getPositionY() - label:getContentSize().height - 10)

	return itemUI
end

function DynamicUpdatePanel:playAnim( ... )
	self.chicken_front_anim:playByIndex(0)
	self.chicken_end_anim:playByIndex(0)

	self.paper:setVisible(true)
	local posY = self.paper:getPositionY()
	self.paper:setPositionY(posY + 400)
	self.paper:runAction(CCMoveBy:create(17/24, ccp(0, -400)))


	self:delayCallback(0.8, function ( ... )
		if self.isDisposed then return end
		self.paper_anim_anim:setVisible(true)
		self.paper_anim_anim:playByIndex(0)
		self.lid:play()
	end)

	self:delayCallback(0.8, function ( ... )
		if self.isDisposed then return end

		if self.banzi_anim then
			self.banzi_anim:setVisible(true)
			self.banzi_anim:playByIndex(0)
		end

		if self.reward_anim then
			self.reward_anim:setVisible(true)
			self.reward_anim:playByIndex(0)
		end
	end)
	
	

end


function DynamicUpdatePanel:createPaperMask( ... )
	local paper = self.paper
	local paperIndex = self.ui:getChildIndex(paper)
	paper:removeFromParentAndCleanup(false)

	local size = paper:getGroupBounds().size

	local pos = paper:getPosition()

	local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(525, 368))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0, 1))
    clipping:ignoreAnchorPointForPosition(false)
    clipping:setPosition(ccp(pos.x, pos.y))
    clipping:addChild(paper)

    self.ui:addChildAt(clipping, paperIndex)
    paper:setPosition(ccp(0, size.height))
    

end
