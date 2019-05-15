local function isWifi()
	local isForceMobile = MaintenanceManager:getInstance():isEnabledInGroup('isForceMobileTest', 'test', UserManager:getInstance().uid)
	if isForceMobile then
		do return false end
	end

	if __ANDROID then
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		local netType = metaInfo:getNetworkInfo()
		return netType ~= -1 and netType ~= 0
	else
		return true
	end
end

local function isSms()
	if __ANDROID then
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		local netType = metaInfo:getNetworkInfo()
		return netType == 0
	else
		return false
	end
end

local function isNetworkOff()
	if __ANDROID then
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		local netType = metaInfo:getNetworkInfo()
		return netType == -1
	else
		return false
	end
end

local function checkValue(value, typeName, defaultValue)
	if type(value) == typeName then
		return value
	else
		return defaultValue
	end
end


local WifiAlert = class(BasePanel)

function WifiAlert:isWifi()
	return isWifi()
end

function WifiAlert:isNetworkOff()
	return isNetworkOff()
end

function WifiAlert:create(dataSize, confirmCallback, cancelCallback)
	if not isWifi() then
		local instance = WifiAlert.new()
		instance:loadRequiredResource('ui/wifiAlert.json')
		instance:init(dataSize, confirmCallback, cancelCallback)
		instance:popout()
		return instance
	else
		if confirmCallback then
			confirmCallback()
		end
	end
end

function WifiAlert:init(dataSize, confirmCallback, cancelCallback)
	local ui = self:buildInterfaceGroup('wifiAlert/wifiAlert_panel')
	BasePanel.init(self, ui)

	self.dataSize = checkValue(dataSize, 'number', 0)
	self.confirmCallback = checkValue(confirmCallback, 'function', nil)
	self.cancelCallback = checkValue(cancelCallback, 'function', nil)

	self.confirmBtn	= GroupButtonBase:create(ui:getChildByName('confirm_btn'))
	self.confirmBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onConfirm()
	end)
	self.confirmBtn:setString('土豪请继续')

	self.closeBtn = self.ui:getChildByName('close_btn')
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, function () 
		self:onClose() 
	end)

	self.textGroup = self.ui:getChildByName('textGroup')

	local function getTextUI(uiName)
		local textUI = self.textGroup:getChildByName(uiName)
		textUI:setDimensions(CCSizeMake(0, 0))
		return textUI
	end

	self.text_1 = getTextUI('text1')
	self.text_2 = getTextUI('text2')
	self.text_3 = getTextUI('text3')
	self.text_4 = getTextUI('text4')
	self.text_5 = getTextUI('text5')

	local dataSizeValue = 0
	local dataSizeUnit = 'M'
	if self.dataSize < 1024 then
		dataSizeValue = self.dataSize
		dataSizeUnit = 'B'
	elseif self.dataSize < 1024*1024 then
		dataSizeValue = math.floor(self.dataSize / 1024)
		dataSizeUnit = 'K'
	elseif self.dataSize < 1024*1024*1024 then
		dataSizeValue = math.floor(self.dataSize / 1024 / 1024)
		dataSizeUnit = 'M'
	elseif self.dataSize < 1024*1024*1024*1024 then
		dataSizeValue = math.floor(self.dataSize / 1024 / 1024 / 1024)
		dataSizeUnit = 'G'
	end

	--这一段文字混用了不同的字体 所以分成5段
	self.text_1:setString('现在')
	self.text_2:setString('非wifi')
	self.text_3:setString('模式，需要消耗')
	self.text_4:setString(string.format('%d%s', dataSizeValue, dataSizeUnit))
	self.text_5:setString('流量')

	--0 是个异常值 此时应该是 取size失败了
	if dataSizeValue == 0 then
		self.text_4:setString('大量')
	end


	--ui对齐、居中
	local items = {}
	table.insert(items, {node = self.text_1})
	table.insert(items, {node = self.text_2})
	table.insert(items, {node = self.text_3})
	table.insert(items, {node = self.text_4})
	table.insert(items, {node = self.text_5})

	local nodes = {self.text_1, self.text_2, self.text_3, self.text_4, self.text_5}

    local utils = require 'zoo.panel.happyCoinShop.utils'
    --水平排列items
    utils.horizontalLayoutItems(items)
    --设置一组nodes的左上角坐标
    utils.setNodesLeftTopPos(nodes, ccp(0, 0), self.textGroup)
    --居中
    utils.verticalCenterAlignNodes({self.textGroup}, self.ui:getChildByName('bg2'))
end

function WifiAlert:popout()
	if self.isDisposed then return end
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)
    local utils = require 'zoo.panel.happyCoinShop.utils'
    utils.centerNode(self)
    local size = self:getGroupBounds().size
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    self:setPositionY((size.height - visibleSize.height)/2)
end

function WifiAlert:onClose()
	if self.isDisposed then return end
	if self.cancelCallback then
		self.cancelCallback()
	end
	self:close()
end

function WifiAlert:close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

function WifiAlert:onConfirm()
	if self.isDisposed then return end
	if self.confirmCallback then
		self.confirmCallback()
	end
	self:close()
end

function WifiAlert:onCloseBtnTapped()
	self:onClose()
end

return WifiAlert