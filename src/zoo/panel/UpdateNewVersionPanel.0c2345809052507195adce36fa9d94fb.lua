require 'zoo.panel.basePanel.BasePanel'
require "zoo.util.NewVersionUtil"
require "zoo.panel.UpdateSJSuccessPanel"

local UpdatePackageLogic = require 'zoo.panel.UpdatePackageLogic'

local UIUtils = require 'zoo.panel.UIHelper'
local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'

local KEY_HELP_TIP = "update.KEY_HELP_TIP"

-- 新版本更新!!!
UpdatePageagePanel = class(BasePanel)

local function getUpdateInfo()
	return UpdatePageagePanel._updateInfo
end

local updatePageagePanelInstances = {}

function UpdatePageagePanel:create(btnPosInWorldSpace,tip)
	local panel = UpdatePageagePanel.new()
	table.insert(updatePageagePanelInstances, panel)

	if not getUpdateInfo().grayscale then
		panel:loadRequiredResource('ui/update_new_version_panel_ver_47.json')
	else
		panel:loadRequiredResource('ui/update_new_version_panel_ver_47a.json')

		DcUtil:UserTrack({
			category='Update', 
			sub_category='grey_update_reach', 
			t1 = tostring(getUpdateInfo().version),
		})

	end

	panel:init(btnPosInWorldSpace,tip)
	return panel
end

function UpdatePageagePanel:popoutIfNotExist( ... )

	if not getUpdateInfo() then
		return 
	end
	
	if #updatePageagePanelInstances > 0 then
		return
	end

	local homeScene = HomeScene:sharedInstance()

	homeScene:runAction(CCCallFunc:create(function ( ... )

		local homeScene = HomeScene:sharedInstance()
		local position = ccp(0, 0)
		if homeScene.updateVersionButton and (not homeScene.updateVersionButton.isDisposed) then
			homeScene.updateVersionButton:setVisible(true)
			position = homeScene.updateVersionButton:getPositionInWorldSpace()
		end

		local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
	    AsyncSkinLoader:create(UpdatePageagePanel, {
	        position,
	    }, UpdatePageagePanel.getSkin, function ( panel )
	        if (panel) then
	        	local function onClose()
					if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
					homeScene.updateVersionButton.wrapper:setTouchEnabled(true)
				end

				if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
				homeScene.updateVersionButton.wrapper:setTouchEnabled(false)
	           	panel:addEventListener(kPanelEvents.kClose, onClose) 
	            panel:popout()
	        end
	    end)
    
	end))

	
end

function UpdatePageagePanel:dispose()
	UIUtils:unloadArmature('skeleton/update_version_47')
	UpdatePackageLogic:getInstance():setRefeshCallback(nil)
	BasePanel.dispose(self)
end

function UpdatePageagePanel:getHCenterInScreenX(...)
	assert(#{...} == 0)
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= self:getGroupBounds().size.width
	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2
	return halfDeltaWidth
end

function UpdatePageagePanel:getHCenterInParentX(...)
	local hCenterXInScreen	= self:getHCenterInScreenX()
	return hCenterXInScreen
end

function UpdatePageagePanel:init(btnPosInWorldSpace,tip)
	UIUtils:loadArmature('skeleton/update_version_47', 'update_version_47', 'update_version_47')
	local version = getUpdateInfo().version

	local t = tostring(getUpdateInfo().md5)
	if not getUpdateInfo().grayscale then
		self.ui = self:buildInterfaceGroup('update_version_panel_47_1518/panel')
	else
		self.ui = self:buildInterfaceGroup('gp/update_version_panel_47_1518/panel')
	end
	BasePanel.init(self, self.ui)
	self.btnPosInWorldSpace = btnPosInWorldSpace
	self.paper = self.ui:getChildByName('paper')
	self.paper:setVisible(false)
	local function __hideAnimHolder( nodeName )
		self[nodeName] = self.ui:getChildByName(nodeName)
		self[nodeName..'_index'] = self.ui:getChildIndex(self[nodeName])
		self[nodeName]:setVisible(false)
	end
	local function __processAnimHolder( nodeName, animName )
		__hideAnimHolder(nodeName)

		self[nodeName..'_anim'] = UIUtils:createArmature(animName)
		self.ui:addChildAt(self[nodeName..'_anim'], self[nodeName..'_index'])
		self[nodeName..'_anim']:setPosition(ccp(
			self[nodeName]:getPositionX(),
			self[nodeName]:getPositionY()
		))
	end

	if not getUpdateInfo().grayscale then
		__processAnimHolder('chicken_front', 'update_version_47/chicken_front')
		__processAnimHolder('chicken_end', 'update_version_47/ji')
	else
		__hideAnimHolder('chicken_front')
		__hideAnimHolder('chicken_end')
	end
	__processAnimHolder('paper_anim', 'update_version_47/zhi_animation')
	-- __processAnimHolder('banzi')

	self.paper_anim_anim:setVisible(false)

	self:buildLabels()

	self:createPaperMask()
	self:createLid()


	local titleHolder = self.ui:getChildByName('title')
	titleHolder:setString('  ')
	local titleHolderIndex = self.ui:getChildIndex(titleHolder)
	titleHolder:setAnchorPointCenterWhileStayOrigianlPosition()
	local pos = titleHolder:getPosition()

	if not getUpdateInfo().grayscale then
		self.title = BitmapText:create('', 'fnt/questionnaire.fnt')
	else
		self.title = BitmapText:create('', 'fnt/questionnaire2.fnt')
	end
	self.title:setAnchorPoint(ccp(0.5, 0.5))
	self.title:setPosition(ccp(pos.x, pos.y))
	self.ui:addChildAt(self.title, titleHolderIndex)

	self.title.__setText = self.title.setText
	self.title.setText = function ( context, text )
		context:__setText(text)
		context:setAnchorPoint(ccp(0.5, 0.5))
		context:setPosition(ccp(pos.x, pos.y))
	end

	if not getUpdateInfo().grayscale then
		self.title:setText(Localization:getInstance():getText("new.version.title")) 

		self.helpTip = self.ui:getChildByName("helpTip")
		self.helpTip.btnUI = self.helpTip:getChildByName("btn")
		self.helpTip.btn = GroupButtonBase:create(self.helpTip.btnUI)
		self.helpTip.btn:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:showHelpPanel()
			DcUtil:UserTrack({ category='update', sub_category='update_help_dialog'})
		end)
		self.helpTip.btn:setString("需要帮助")

		self.helpTip.txt = self.helpTip:getChildByName("txt")
		self.helpTip.txt:setString("更新遇到问题？")

		self.helpTip:setVisible(false)

		if self:canShowHelpTip() then
	        self:showHelpTip()
	    end

	else
		self.title:setText(Localization:getInstance():getText("获得体验资格")) 
	end



	self.tip = self.ui:getChildByName("tip")


	self.confirm = GroupButtonBase:create(self.ui:getChildByName("btn"))

	local progress = self.ui:getChildByName("progress")
	self.pgtxt = progress:getChildByName("pgtxt")
	self.pgtxt:setAlignment(kTextAlignment.kCCTextAlignmentCenter)
	self.progress = HomeSceneItemProgressBar:create(progress, 0, 100)

	self.pgtxt:removeFromParentAndCleanup(false)
	progress:addChild(self.pgtxt)
	self.pgtxt:setPositionY(self.pgtxt:getPositionY() - 6)

	--todo 进度条闪星星

	local closeBtn = self.ui:getChildByName("closeBtn")

	local bg = self.ui:getChildByName("bg")

	local rewards = getUpdateInfo().rewards
	local blocks = getUpdateInfo().blocks

	local targets = {}
	if type(rewards) == "table" and #rewards > 0 then
		for k, v in ipairs(rewards) do table.insert(targets, v) end

	-- elseif type(blocks) == "table" and #blocks > 0 then
		-- for k, v in ipairs(blocks) do table.insert(targets, v) end

	end

	-- if __WIN32 then
		-- targets = {{itemId = 10001, num = 2}}
	-- end

	self.items = {}
	if #targets == 0 then


		__processAnimHolder('banzi', 'update_version_47/banzi')
		self.ui:getChildByName('reward'):setVisible(false)


		self.banzi_anim:setVisible(false)

		local bannerCon = UIUtils:getCon(self.banzi_anim, 'banner')

		local banner = UIUtils:safeCreateSpriteByFrameName('update_version_panel_47_1518/skin/pic_10000')
		banner:setAnchorPoint(ccp(0, 0))
		bannerCon:addChild(banner.refCocosObj)
		banner:dispose()

	else

		local items = targets


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




	local function onClose()

		DcUtil:UserTrack({
			category='Update', 
			sub_category='update_now', 
			t1 = tostring(getUpdateInfo().version),
			t3 = 1
		})

		self:onCloseBtnTapped()
	end

	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap, onClose)



	local function onButton()

		if table.exist({UpdatePackageLogic.States.kUnstart, UpdatePackageLogic.States.kError}, UpdatePackageLogic:getInstance():getState()) then
			if __WIN32 or self:isDownloadSupport() then
				if __ANDROID then
					local function _download()
						if UpdatePackageLogic:getInstance():checkDownloadOutside() then
							self:downloadApk(version, t)
							return
						end

						local apkUrl = UpdatePackageLogic:getInstance():getApkOfficialUrl(version)
						local sizeUrl = apkUrl:gsub("%.apk","%.size")

						self:requestApkSize(sizeUrl, function(dataSize)
							local WifiAlert = require 'zoo.panel.WifiAlert'
							WifiAlert:create(dataSize, function()
								self:downloadApk(version, t)
								self:refresh() 
								DcUtil:UserTrack({
									category='UI', 
									sub_category="G_update_game",
									t1 = 1
								})
							end, function()
								DcUtil:UserTrack({
									category='UI', 
									sub_category="G_update_game",
									t2 = 1
								})
							end) 
						end)
					end

					local function _cancel()
					end


					if not getUpdateInfo().grayscale then
						_download()
					else
						CommonTipWithBtn:showTip(
							{
								tip = "此次更新为体验版本，如果发现存在问题，可以通过社区报告，或者去应用商店重新下载最新正式版本。",
								yes = "确定",
								no = "取消",
							},
							 2, 
							_download, 
							_cancel, 
							 nil, 
							 false)
--[[
						AlertDialogImpl:alert( 
							"注意!", 
							"此次更新为内测版本，如果发现存在问题，可以通过社区报告，或者去应用商店重新下载最新正式版本。", 
							Localization:getInstance():getText("button.ok"), 
							Localization:getInstance():getText("button.cancel"), 
							_download, 
							_cancel, 
							_cancel)
							]]
					end
				elseif __WIN32 then
					-- just test code
					-- UpdatePackageLogic:getInstance():setState(UpdatePackageLogic.States.kDownloading, {
					-- 	percentage = 0
					-- })

					self:downloadApk(version, t)

				else
					NewVersionUtil:gotoMarket()

						CCUserDefault:sharedUserDefault():setStringForKey(KEY_HELP_TIP, version)
						CCUserDefault:sharedUserDefault():flush()
				end
				DcUtil:UserTrack({ category='update', sub_category='update_panel_button'})
			else
				self:onCloseBtnTapped()
			end
			self:refresh()

			local t3 = 2

			if #targets == 0 then
				t3 = 0
			end

			DcUtil:UserTrack({
				category='Update', 
				sub_category='update_now', 
				t1 = tostring(getUpdateInfo().version),
				t3 = t3
			})

		elseif UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kDownloading then
			self:onCloseBtnTapped()
		elseif UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kFinish then
			UpdatePackageLogic:getInstance():toInstallApk()
		else
			self:onCloseBtnTapped()
		end
	end

	self.confirm:addEventListener(DisplayEvents.kTouchTap, onButton)

	UpdatePackageLogic:getInstance():setRefeshCallback(function ( ... )
		self:refresh()
	end)

	self:scaleAccordingToResolutionConfig()

	self.showHideAnim = IconPanelShowHideAnim:create(self, self.btnPosInWorldSpace)


	--这个放在updatelogic 的 init里做
	-- if self:isApkExist(version) then
	-- 	downloadProcess.status = "ready"
	-- 	downloadProcess.percentage = 0
	-- 	downloadProcess.apkPath = self:getApkPath(version)
	-- end




	self:refresh()
end

function UpdatePageagePanel:canShowHelpTip(  )
	local version = tostring(getUpdateInfo().version) or ''
	local u = CCUserDefault:sharedUserDefault():getStringForKey(KEY_HELP_TIP, "")
	return u==version
end

function UpdatePageagePanel:showHelpTip(  )
	if self.helpTip:isVisible() then
		return
	end
	local isCanSee = __IOS or UpdatePackageLogic:getInstance():checkDownloadOutside() or __WIN32
	if not isCanSee then
		return
	end

	local tx,ty = self.helpTip:getPositionX(),self.helpTip:getPositionY()
	
	self.helpTip:setScale(0.01)
	self.helpTip:setRotation(30)

	self.helpTip:setPositionX(tx-70)

	local t = 0.3
	local arr1 = CCArray:create()
	arr1:addObject(CCScaleTo:create(t,1,1))
	arr1:addObject(CCRotateTo:create(t,0))
	arr1:addObject(CCMoveTo:create(t,ccp(tx,ty)))
	-- arr1:addObject(CCCallFunc:create(function ()
	-- end))

	self.helpTip:setVisible(true)
	self.helpTip:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(1.3),
            CCSpawn:create(arr1)
            ))

	DcUtil:UserTrack({ category='update', sub_category='update_popout_help_dialog'})
end

function UpdatePageagePanel:showHelpPanel(  )
	if self.helpPanel then
		return
	end

	local function onClose()
		if self.helpPanel then
			PopoutManager:sharedInstance():remove(self.helpPanel)
		end
	    self.helpPanel = nil
	end

	local function popoutHelp(panel)
		local size = panel:getGroupBounds().size
	    local posAdd = _G.__EDGE_INSETS.top
	    local vSize = CCDirector:sharedDirector():getVisibleSize()
	    local tx,ty = (vSize.width-size.width)*0.5 ,(vSize.height-size.height )*0.5+posAdd
	    panel:setPositionXY(tx, -ty)
	    self.helpPanel = panel
	    PopoutManager:sharedInstance():add(panel, true)
	    panel.onClose = onClose
		panel.onKeyBackClicked = onClose
	end


	if __IOS  then
		local ui = UpdateCheckUtils:getInstance():showUpdateHelp()
		ui.darkLayer:removeFromParentAndCleanup(false)
		ui:removeFromParentAndCleanup(false)
		ui.onClose = onClose
	    popoutHelp(ui)
	    
    elseif __ANDROID  then
    	local ui = self:buildInterfaceGroup('update_version_panel_47_1518/helpFullPkg')
		local size = ui:getGroupBounds().size

		local CFG_TXT = {
			"txtTitle","更新失败？",
			"txtInfo","如果您在应用商店下载或安装失败，可以点击下面的按钮一键更新哦~",
		}
		for i,v in ipairs(CFG_TXT) do
			if i%2 == 1 then
				ui:getChildByName(v):setString(CFG_TXT[i+1])
			end
		end

	    local function setBtnOnClick(key,callback)
	        local item = ui:getChildByName(key)
	        item:setTouchEnabled(true,0, false)
	        item:setButtonMode(true)
	        item:addEventListener(DisplayEvents.kTouchTap, callback)
	    end

	    local net = NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi and 1 or 
		    NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kMobileNetwork and 2 or 3

	    local function onCancel()
	    	onClose()

		   	if UpdatePackageLogic:getInstance():checkDownloadOutside() then
			    local params = {}
			    params.category = "update"
			    params.sub_category = "update_help_to_cdn_panel"
			    params.t1 = 2
			    params.t2 = net
			    DcUtil:UserTrack(params)
			end
	    end

	    setBtnOnClick("btnClose",onCancel)

		self.btnOK = GroupButtonBase:create(ui:getChildByName("btnOK"))
		self.btnOK:setString("去更新领奖")
		self.btnOK:addEventListener(DisplayEvents.kTouchTap,function( ... )
			onClose()
			UpdatePackageLogic:getInstance():forceDownloadFullPackage()

		   	if UpdatePackageLogic:getInstance():checkDownloadOutside() then
			    local params = {}
			    params.category = "update"
			    params.sub_category = "update_help_to_cdn_panel"
			    params.t1 = 1
			    params.t2 = net
			    DcUtil:UserTrack(params)
			end
		end)
	    
	    popoutHelp(ui)

    else
		Alert:create("QQ群: 114278702 313502987\n联系客服: xiaoxiaole@happyelements.com", "开心消消乐沟通渠道")
	end
end

function UpdatePageagePanel:onKeyBackClicked( ... )
	BasePanel.onKeyBackClicked(self, ...)

	DcUtil:UserTrack({
		category='Update', 
		sub_category='update_now', 
		t1 = tostring(getUpdateInfo().version),
		t3 = 1
	})

end

function UpdatePageagePanel:getSkin( ... )
	if not getUpdateInfo() then
		return nil
	end

	CCUserDefault:sharedUserDefault():setStringForKey(
		'update.panel.updateRes', 
		getUpdateInfo().updateRes or ''
	)

	return getUpdateInfo().updateRes
end

function UpdatePageagePanel:createPaperMask( ... )
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

function UpdatePageagePanel:createLid(  )
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

function UpdatePageagePanel:delayCallback(time, callback )
    if self.isDisposed then return end

    self.ui:runAction(
        CCSequence:createWithTwoActions(
            CCDelayTime:create(time), 
            CCCallFunc:create(callback)
        )
    )
end

function UpdatePageagePanel:buildLabels( ... )

	local paper = self.paper

	local tips = getUpdateInfo().newTips or '功能有一些小更新哦~'


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

function UpdatePageagePanel:buildLabelItem( text )
	local itemUI = nil
	if not getUpdateInfo().grayscale then
		itemUI = self:buildInterfaceGroup('update_version_panel_47_1518/item')
	else
		itemUI = self:buildInterfaceGroup('gp/update_version_panel_47_1518/item')
	end

	local label = itemUI:getChildByName('label')
	local size = label:getDimensions()
	label:setDimensions(CCSizeMake(size.width, 0))
	label:setString(text)

	local up = itemUI:getChildByName('up')
	local down = itemUI:getChildByName('down')

	down:setPositionY(label:getPositionY() - label:getContentSize().height - 10)

	return itemUI
end

function UpdatePageagePanel:playAnim( ... )
	if not getUpdateInfo().grayscale then
		self.chicken_front_anim:playByIndex(0)
		self.chicken_end_anim:playByIndex(0)
	else
	end

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

function UpdatePageagePanel:refresh()
	if self.isDisposed then return end

	local actualHeight = 0

	if UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kDownloading then
		self.title:setText(Localization:getInstance():getText("new.version.dynamic.title.loading"))
	elseif UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kFinish then
		self.title:setText(Localization:getInstance():getText("new.version.dynamic.title.finish"))		
	else
		if not getUpdateInfo().grayscale then
			self.title:setText(Localization:getInstance():getText("new.version.title")) 
		else
			self.title:setText(Localization:getInstance():getText("获得体验资格")) 
		end
	end

	if UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kDownloading then

		local percentage = UpdatePackageLogic:getInstance():getData().percentage
		self.progress:setCurNumber(percentage or 0)
		self.pgtxt:setText(tostring(percentage)..'%')
	end

	if table.exist({UpdatePackageLogic.States.kUnstart, UpdatePackageLogic.States.kError}, UpdatePackageLogic:getInstance():getState()) then
		if self:isDownloadSupport() then 
			local rewards
			if getUpdateInfo() then
				rewards = getUpdateInfo().rewards
			end
			if type(rewards) == "table" and #rewards > 0 then
				--更新领奖励
				self.confirm:setString(Localization:getInstance():getText("new.version.button.download"))
			else
				--立即更新
				self.confirm:setString(Localization:getInstance():getText("new.version.button.download.zero"))
			end

		else 
			self.confirm:setString(Localization:getInstance():getText("new.version.done.cancel")) 
		end
		self.confirm:setVisible(true)
		self.progress:setVisible(false)
		self.pgtxt:setVisible(false)
		self.tip:setString(Localization:getInstance():getText("new.version.package.tip.text"))
	elseif UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kDownloading then
		self.confirm:setString(Localization:getInstance():getText("update.done.doing"))
		self.confirm:setVisible(false)
		self.progress:setVisible(true)
		self.pgtxt:setVisible(true)
		local rewards
		if getUpdateInfo() then
			rewards = getUpdateInfo().rewards
		end
		if type(rewards) == "table" and #rewards > 0 then
			self.tip:setString(Localization:getInstance():getText("new.version.dynamic.downloading.tip"))
		else
			self.tip:setString(Localization:getInstance():getText("new.version.dynamic.downloading.tip.zero"))
		end
	elseif UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kFinish then
		self.confirm:setString(Localization:getInstance():getText("new.version.package.complete.confirm"))
		self.confirm:setVisible(true)
		self.progress:setVisible(false)
		self.pgtxt:setVisible(false)
		self.tip:setString(Localization:getInstance():getText("wifi.update.success.panel.desc2"))
		--[[local rewards = getUpdateInfo().rewards
		if type(rewards) == "table" and #rewards > 0 then
			self.tip:setString(Localization:getInstance():getText("new.version.package.complete.tip"))
		else
			self.tip:setString(Localization:getInstance():getText("new.version.package.complete.tip.zero"))
		end]]
	end
end

function UpdatePageagePanel:getLpsChannel( ... )
	-- body
	return UpdatePackageLogic:getInstance():getLpsChannel()
end

function UpdatePageagePanel:getApkPath( version )
	return UpdatePackageLogic:getInstance():getApkPath(version)
end

function UpdatePageagePanel:isApkExist( version )
	return UpdatePackageLogic:getInstance():isApkExist(version)
end

function UpdatePageagePanel:downloadApk(version)
	local homeScene = HomeScene:sharedInstance()

	if _G.isLocalDevelopMode then printx(0, apkName) end

	if homeScene.updateVersionButton then 
		if not UpdatePackageLogic:getInstance():needShowProgress() then
			homeScene.updateVersionButton:setText(nil, 0)
		else
			homeScene.updateVersionButton:setText("ing", 0)
		end
		homeScene.updateVersionButton:setVisible(true)
	end
	local md5 = ""

	if homeScene.updateVersionButton then 
		homeScene.updateVersionButton:setVisible(true)
	end

	local function startDownload()
		local isStart = UpdatePackageLogic:getInstance():manualStartDownload(version)
		
		local net = NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi and 1 or 
		    NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kMobileNetwork and 2 or 3

	    local params = {}
	    params.category = "update"
	    params.sub_category = "update_popout_panel"
	    params.t2 = 1
	    params.t3 = net
	    DcUtil:UserTrack(params)

	end

	local isCanSeeTip = __IOS or UpdatePackageLogic:getInstance():checkDownloadOutside() or __WIN32
	if isCanSeeTip then
		startDownload()
		-- self:showHelpPanel()

		CCUserDefault:sharedUserDefault():setStringForKey(KEY_HELP_TIP, version)
		CCUserDefault:sharedUserDefault():flush()
		return
	end

	-- 可以去商店更新时也无需检查MD5
	if not UpdatePackageLogic:getInstance():needCheckMd5() or UpdatePackageLogic:getInstance():checkDownloadOutside() then 
		startDownload()
	else
		self:requestApkMd5(version,function( m )
			md5 = m
			if md5 == "" then 
				UpdatePageagePanel:onDownloadError(0)
				return
			end
			startDownload()
		end)
	end
	self:onCloseBtnTapped(true)
end

function UpdatePageagePanel:requestApkMd5(version, callback)
	UpdatePackageLogic:getInstance():requestMd5(version, callback)
end

function UpdatePageagePanel:onDownloadSuccess(md5, apkPath)

	if not getUpdateInfo() then
		return 
	end

	local homeScene = HomeScene:sharedInstance()
	if (not UpdatePackageLogic:getInstance():needCheckMd5()) or md5 == HeMathUtils:md5File(apkPath) then 
		DcUtil:UserTrack({
			category='Update', 
			sub_category='update_now', 
			t1 = tostring(getUpdateInfo().version),
			t4 = 0
		})
		UpdatePackageLogic:getInstance():setState(
			UpdatePackageLogic.States.kFinish,
			{apkPath = apkPath}
		)

		if not UpdatePackageLogic:getInstance():refreshUI() then
			homeScene:runAction(CCCallFunc:create(function()
				if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
				local position = homeScene.updateVersionButton:getPositionInWorldSpace()
				local function doPopout(panel)
					local function onClose()
						if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
						homeScene.updateVersionButton.wrapper:setTouchEnabled(true)
					end
					panel:addEventListener(kPanelEvents.kClose, onClose)
					homeScene.updateVersionButton.wrapper:setTouchEnabled(false)
					panel:popout()
				end
				local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
				AsyncSkinLoader:create(UpdatePageagePanel, {
					position
				}, UpdatePageagePanel.getSkin, function ( panel )
					if (panel) then
						doPopout(panel)
					end
				end, function ( ... )
					if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
					homeScene.updateVersionButton.wrapper:setTouchEnabled(true)
				end)
			end))
		end
		if homeScene.updateVersionButton then 
			homeScene.updateVersionButton:setText("ready")
			homeScene.updateVersionButton:setVisible(true)
		end
	else
		HeFileUtils:removeFile(apkPath)
		DcUtil:UserTrack({
			category='Update', 
			sub_category='update_now', 
			t1 = tostring(getUpdateInfo().version),
			t4 = 1
		})

		if not UpdatePackageLogic:getInstance():isAutoState() then
			CommonTip:showTip(Localization:getInstance():getText("new.version.download.error"), "negative")
		end

		UpdatePackageLogic:getInstance():setState(UpdatePackageLogic.States.kError)
		UpdatePackageLogic:getInstance():refreshUI()
		if homeScene.updateVersionButton then 
			homeScene.updateVersionButton:setText()
			homeScene.updateVersionButton:setVisible(true)
		end
	end
end

function UpdatePageagePanel:onDownloadProgress( progress, total )
	local homeScene = HomeScene:sharedInstance()
	if homeScene.updateVersionButton then 
		homeScene.updateVersionButton:setText("ing", math.floor(progress * 100 / total))
		-- homeScene.updateVersionButton:setVisible(true)
	end
	
	UpdatePackageLogic:getInstance():refreshUI()
end

function UpdatePageagePanel:onDownloadError( code )
	local homeScene = HomeScene:sharedInstance()
	local version = getUpdateInfo().version
	if code ~= 1000 then
		DcUtil:UserTrack({
			category='Update', 
			sub_category='update_now', 
			t1 = tostring(version),
			t4 = 1
		})

		if not UpdatePackageLogic:getInstance():isAutoState() then
			CommonTip:showTip(Localization:getInstance():getText("new.version.download.error"), "negative")
		end
	else
		DcUtil:UserTrack({
			category='Update', 
			sub_category='update_now', 
			t1 = tostring(version),
			t4 = 1
		})
		if not UpdatePackageLogic:getInstance():isAutoState() then
			CommonTip:showTip("当前更新链接出错，请通过应用商店下载最新版本游戏哦~", "negative")
		end
		he_log_error("download apk error:"..StartupConfig:getInstance():getPlatformName())
	end

	if homeScene.updateVersionButton then 
		homeScene.updateVersionButton:setText()
		homeScene.updateVersionButton:setVisible(true)
	end
	UpdatePackageLogic:getInstance():refreshUI()
end

function UpdatePageagePanel:requestApkSize(sizeUrl, callback)
	if self.isBusyForRequestSize then
		return
	end
	self.isBusyForRequestSize = true
    local function onCallback(response)
    	self.isBusyForRequestSize = false
		if response.httpCode ~= 200 then 
			callback(nil)
		else
			callback(tonumber(response.body))
		end
    end
	local request = HttpRequest:createGet(sizeUrl)
  	local connection_timeout = 2
  	if __WP8 then 
    	connection_timeout = 5
  	end
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
    HttpClient:getInstance():sendRequest(onCallback, request)
end

function UpdatePageagePanel:getOrbuildLoading( ... )
	local homeScene = HomeScene:sharedInstance()

	local loading = homeScene.packageLoading
	if loading then 
		return loading
	end
	if self.isDisposed then 
		return nil
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	loading = self:buildInterfaceGroup("updage_package_loading")
	loading:setPositionX(visibleSize.x)
	loading:setPositionY(visibleSize.height + visibleOrigin.y)
	homeScene:addChild(loading, SceneLayerShowKey.POP_OUT_LAYER)

	homeScene.packageLoading = loading

	function loading:setPercent( current,total )
		self:getChildByName("text"):setString(Localization:getInstance():getText(
			"new.version.download.progress",
			{
				rate = string.format("%.2fM/%.2fM",current/(1024*1024),total/(1024*1024))
			}
		))	
		local bar = self:getChildByName("bar")
		if total > 0 then 
			bar:setPreferredSize(CCSizeMake(visibleSize.width * current / total,bar:getPreferredSize().height))
		else
			bar:setPreferredSize(CCSizeMake(1,bar:getPreferredSize().height))
		end
		if _G.isLocalDevelopMode then printx(0, "current:" .. current .. " total:" .. total) end
		if _G.isLocalDevelopMode then printx(0, "percent:" .. bar:getContentSize().width) end
	end
	loading:setPercent(0,0)

	return loading
end

function UpdatePageagePanel:hasLoading( ... )
	local homeScene = HomeScene:sharedInstance()
	local loading = homeScene.packageLoading

	return loading 
end
function UpdatePageagePanel:removeLoading( ... )
	local homeScene = HomeScene:sharedInstance()
		
	local loading =	homeScene.packageLoading
	if loading then 
		loading:removeFromParentAndCleanup(true)
		homeScene.packageLoading = nil
	end
end

function UpdatePageagePanel:isDownloadSupport(checkPlatformName)
	return UpdatePackageLogic:getInstance():isDownloadSupport(checkPlatformName)
end

function UpdatePageagePanel:popout(forcePopout)

	local homeScene = HomeScene:sharedInstance()
	if homeScene.updateVersionButton and (not homeScene.updateVersionButton.isDisposed) then 
		homeScene.updateVersionButton:setVisible(true)
	end

	self.popoutShowTransition = function( ... )
		local function onFinish()

			self:refresh()

			UpdatePackageLogic:getInstance():setRefeshCallback(function ( ... )
				self:refresh()
			end)


			self.allowBackKeyTap = true


			if self.isDisposed then return end
			self:playAnim()

			

		end
		UpdatePackageLogic:getInstance():setRefeshCallback(nil)
		self.showHideAnim:playShowAnim(onFinish)
	end
	PopoutQueue:sharedInstance():push(self,true,false,function( ... )end)

	local tForce 
	if forcePopout then
		tForce = 1
	else
		tForce = 2
	end

    local net = NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi and 1 or 
	    NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kMobileNetwork and 2 or 3

	DcUtil:UserTrack({ category='update', sub_category='update_popout_panel', t1 = tForce,t3 = net})
end

function UpdatePageagePanel:autoPopout( ... )
	if self:hasLoading() then 
		self:dispose()
	else	
		-- PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
		self:setVisible(false)
		self.popoutShowTransition = function( ... )
			self:setVisible(true)
			local function onFinish()

				if self.isDisposed then return end
				self:playAnim()

				self.allowBackKeyTap = true 
			end
			self.showHideAnim:playShowAnim(onFinish)
		end
		PopoutQueue:sharedInstance():push(self,true,false,function( ... )end)
	end
end

function UpdatePageagePanel:onCloseBtnTapped(isStartDownload)
	if self.isClose then 
		return
	end
	self.isClose = true

	local function hidePanelCompleted()
		self:dispatchEvent(Event.new(AsyncSkinLoader.Events.kPanelClose, nil, self))
		self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
		PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
		table.removeValue(updatePageagePanelInstances, self)

		local WifiAutoDownloadManager = require 'zoo.data.WifiAutoDownloadManager'

		if WifiAutoDownloadManager:getInstance():canTrigger() then
			local WifiAutoDownloadAlertPanel = require 'zoo.panel.WifiAutoDownloadAlertPanel'
			WifiAutoDownloadAlertPanel:create():popout(function ( ... )
				WifiAutoDownloadManager:getInstance():trigger()
			end)
		end

	end
	self.allowBackKeyTap = false
	self.showHideAnim:playHideAnim(hidePanelCompleted)

	local net = NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi and 1 or 
	    NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kMobileNetwork and 2 or 3

    local params = {}
    params.category = "update"
    params.sub_category = "update_popout_panel"
    params.t2 = 2
    params.t3 = net
    DcUtil:UserTrack(params)
end

-- 更新成功
UpdateSuccessPanel = class(BasePanel)
local hasPopout = false
function UpdateSuccessPanel:canPopout( ... )
	if hasPopout then 
		return false
	end

	if NewVersionUtil:hasUpdateReward() then
		return true
	end

	return false
end

function UpdateSuccessPanel:getSkin( ... )
	
	local ret = CCUserDefault:sharedUserDefault():getStringForKey('update.panel.updateRes')
	if ret == '' then
		ret = nil
	end

	return ret
end

function UpdateSuccessPanel.popoutIfNecessary(closeCallback)
	-- 有更新奖励，弹领取面板
	if hasPopout then 
		if closeCallback then
			closeCallback()
		end
		return
	end
	

	if NewVersionUtil:hasUpdateReward() then -- NewVersionUtil:hasUpdateReward() then
		local rewards = UserManager.getInstance().updateRewards
		if (not UserManager.getInstance().preRewardsFlag and UserManager.getInstance().preRewards) then
			rewards = UserManager.getInstance().preRewards
		end

		local sjRewards = UserManager.getInstance().sjRewards
		local panel



		local function doPopout( ... )
			panel:popout()
			panel:addEventListener(PopoutEvents.kRemoveOnce,function( ... )
				if closeCallback then
					closeCallback()
				end
			end)
			hasPopout = true
		end

		if sjRewards and #sjRewards > 0 then
			panel = UpdateSJSuccessPanel:create(rewards, sjRewards)
			doPopout()
		else
			AsyncSkinLoader:create(UpdateSuccessPanel, {rewards}, UpdateSuccessPanel.getSkin, function ( __panel )
				panel = __panel
				doPopout()
			end, closeCallback)
		end
		
	else
		if closeCallback then
			closeCallback()
		end
	end
end

function UpdateSuccessPanel:create(rewards)
	local panel = UpdateSuccessPanel.new()
	panel:loadRequiredResource('ui/update_new_version_panel_ver_47.json')
	panel:init(rewards)

	return panel
end

function UpdateSuccessPanel:init(rewards)
	self.ui = self:buildInterfaceGroup('update_version_panel_47_1518/update_success_panel')
	BasePanel.init(self, self.ui)
	local wSize = CCDirector:sharedDirector():getWinSize()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local label = self.ui:getChildByName("label")
	local confirm = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
	local label1 = self.ui:getChildByName("label1")
	local item1 = self.ui:getChildByName("item1")
	local bg = self.ui:getChildByName("bg")
	local bg1 = self.ui:getChildByName("bg1")

	local itemY = item1:getPositionY()

	self.label = label
	self.confirm = confirm
	self.items = {}


	if type(rewards) ~= "table" then rewards = {} end

	local successLabelKey = "new.version.success.msg.text"
	if __IOS and  WorldSceneShowManager:isRightGameVersion() then
		successLabelKey = "new.version.success.msg.text.apple"
	end
	
	local dimension = label:getDimensions()
	label:setDimensions(CCSizeMake(dimension.width, 0))
	label:setString(Localization:getInstance():getText(successLabelKey))
	local iSize = item1:getGroupBounds().size

	local items = {}
	for k, v in ipairs(rewards) do
		local item = self:buildItem(v)
		item.itemId = v.itemId
		item.num = v.num
		table.insert(items, item)
		table.insert(self.items, item)
	end

	local bgSize = bg:getGroupBounds().size
	local bgSize1 = bg1:getGroupBounds().size
	local boxWidth = bgSize1.width / (#rewards + 1)
	local extraX = 80 * (4-#rewards)
	local spacing = (bgSize1.width - iSize.width*#rewards - extraX) / (#rewards + 1)

	for k, v in ipairs(items) do

		v:setPositionXY(12 + extraX/2 + (bgSize.width-bgSize1.width)/2 + (spacing + iSize.width) * k - iSize.width, itemY)
		self.ui:addChildAt(v, self.ui:getChildIndex(item1))

	end
	item1:removeFromParentAndCleanup(true)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local function onConfirmButtonTouch(evt)
		self:onOkTapped()
	end
	confirm:ad(DisplayEvents.kTouchTap, onConfirmButtonTouch)

	confirm:setString(Localization:getInstance():getText("new.version.button.download.finish"))-- 领取奖励

end

function UpdateSuccessPanel:popout()
	-- PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	PopoutQueue:sharedInstance():push(self)
	self.allowBackKeyTap = true




end

function UpdateSuccessPanel:onCloseBtnTapped()


	local WifiAutoDownloadManager = require 'zoo.data.WifiAutoDownloadManager'

	if WifiAutoDownloadManager:getInstance():canTrigger() then
		WifiAutoDownloadManager:getInstance():trigger()
		local WifiAutoDownloadAlertPanel = require 'zoo.panel.WifiAutoDownloadAlertPanel'
		WifiAutoDownloadAlertPanel:create():popout()
	end




	self:dispatchEvent(Event.new(AsyncSkinLoader.Events.kPanelClose, nil, self))
	PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
	self.allowBackKeyTap = false
end

function UpdateSuccessPanel:onOkTapped()

	self.confirm:setEnabled(false)

	local function onSuccess( evt )
		
        DcUtil:UserTrack({ category='update', sub_category='get_update_reward' })
        DcUtil:UserTrack({ category='Update', sub_category='update_over', t1 = 0})



	    UserManager.getInstance().updateRewards = nil
	    UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end

	    UserManager:getInstance():addRewards(self.items, "update_reward")
	    UserService:getInstance():addRewards(self.items)
	    GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kTrunk, self.items, DcSourceType.kUpdate)

	    for k,v in ipairs(self.items) do
	    	local anim = FlyItemsAnimation:create({v})
			local bounds = v:getGroupBounds()
		    anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
		    anim:play()
	    end

		self:onCloseBtnTapped()
	end

	local function onFail( evt ) 

        DcUtil:UserTrack({ category='Update', sub_category='update_over', t1 = 1})

		
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
	   	UserManager.getInstance().updateRewards = nil
	   	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end

		self:onCloseBtnTapped()
	end

	local function onCancel(evt)
	  	UserManager.getInstance().updateRewards = nil
	  	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end
	    
		self.confirm:setEnabled(true)
	end

	local http = GetUpdateRewardHttp.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onCancel)
	http:load()
end

function UpdateSuccessPanel:buildItem( rewardItem )
	local itemUI = self:buildInterfaceGroup('update_version_panel_47_1518/update_new_version_panel_item')
	local sp = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
	local itemHolder = itemUI:getChildByName('item')
	local itemHolderIndex = itemUI:getChildIndex(itemHolder)
	sp:setAnchorPoint(ccp(0.5, 0.5))
	itemHolder:setAnchorPointCenterWhileStayOrigianlPosition()
	local pos = itemHolder:getPosition()
	sp:setPosition(ccp(pos.x - 6, pos.y))
	itemUI:addChildAt(sp, itemHolderIndex)
	itemHolder:removeFromParentAndCleanup(true)
	sp:setScale(1.2)


	local function fixNum(num)
		if not num then
			return 0
		end
		if num >100000000 then
			return math.floor(num*0.00000001).."亿"
		elseif num > 10000 then
			return math.floor(num*0.0001).."万"
		elseif num > 1000 then
			return math.floor(num*0.001).."千"
		end
		return num
	end

	local newLabel = BitmapText:create('', 'fnt/target_amount.fnt')
	newLabel:setAnchorPoint(ccp(0, 1))
	newLabel:setText('x'..fixNum(rewardItem.num))
	newLabel:setScale(1.4)
	local numPos = itemUI:getChildByName('num'):getPosition()

	itemUI:addChild(newLabel)
	newLabel:setPosition(ccp(numPos.x, numPos.y))
	return itemUI
end


-- 
NewVersionTipPanel = class(BasePanel)
function NewVersionTipPanel:create( tip,callback )
	local panel = NewVersionTipPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.update_new_version_panel)
	panel:init(tip,callback)
	return panel
end

function NewVersionTipPanel:init( tip,callback )
	self.ui = self:buildInterfaceGroup('NewVersionTipPanel')
	BasePanel.init(self, self.ui)
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local text = self.ui:getChildByName("text")
	text:setString(tip)

	local button = GroupButtonBase:create(self.ui:getChildByName("button"))

	if NewVersionUtil:hasDynamicUpdate() then
		button:setString("去更新")
		button:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:remove()
			DynamicUpdatePanel:onCheckDynamicUpdate(false,callback,callback)
		end)
	elseif NewVersionUtil:hasPackageUpdate() and (PrePackageUpdatePanel:isDownloadSupport() or __WIN32) then
		button:setString("去更新")
		button:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:remove()
			local panel = PrePackageUpdatePanel:create(ccp(0,0))
			panel:addEventListener(kPanelEvents.kClose, callback)
			panel:autoPopout()
		end)
	else
		button:setString("知道了")
		button:addEventListener(DisplayEvents.kTouchTap,function( ... )
			self:remove()
			if callback then callback() end
		end)		
	end
end

function NewVersionTipPanel:remove( ... )
	PopoutManager:sharedInstance():remove(self)
end

function NewVersionTipPanel:popout( ... )
	PopoutQueue:sharedInstance():push(self)
end
