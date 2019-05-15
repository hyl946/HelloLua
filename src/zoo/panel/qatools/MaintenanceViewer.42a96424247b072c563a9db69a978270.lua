MACRO_DEV_START()

require 'hecore.display.ShapeNode'
local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'

local MaintenanceViewer = class(Layer)

function MaintenanceViewer:popout( ... )
	-- body
	local panel = MaintenanceViewer.new()
	panel:initLayer()
	panel:init()

	local scene = Scene:create()
	scene:addChild(panel)
	Director:sharedDirector():pushScene(scene)

	scene.onKeyBackClicked = function ( ... )
		Director:sharedDirector():popScene()
	end
end

function MaintenanceViewer:buildBtn( btnText, fntSize, callback, solid, frameColor )
	local label = TextField:create(btnText, nil, fntSize or 48)
	local size = label:getContentSize()

	local margin = 16

	local btn = Layer:create()
	btn:setAnchorPoint(ccp(0.5, 0.5))
	btn:ignoreAnchorPointForPosition(false)
	btn:changeWidthAndHeight(size.width + margin, size.height + margin)

	label:setAnchorPoint(ccp(0.5, 0.5))

	label:setPositionXY(size.width/2 + margin/2, size.height/2 + margin/2)

	local frame = RectShape:create(CCSizeMake(size.width + margin*0.75, size.height + margin*0.75), 225, 255, 255, 255)
    btn:addChild(frame)
	btn:addChild(label)

	local labelColor
    if frameColor then
    	frame:setColor(frameColor)
    	labelColor = ccc3(255-frameColor.r*255, 255-frameColor.g*255, 255-frameColor.b*255)
    end

    if labelColor then
    	label:setColor(labelColor)
    end

    if solid then
    	frame:setFill(true)
    end


    if callback then
	    btn:setTouchEnabled(true)
	    btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
	    	if callback then callback() end
	    end))
	end

    return btn
end



function MaintenanceViewer:init( ... )

	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(ccp(0, 0))

	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

    self:changeWidthAndHeight(vs.width, vs.height)
    self:setPosition(vo)

    local bgLayer = LayerColor:createWithColor(hex2ccc3('9B30FF'), vs.width, vs.height)
    bgLayer:ignoreAnchorPointForPosition(false)
    bgLayer:setAnchorPoint(ccp(0, 0))

    self:addChild(bgLayer)

    local closeBtn = self:buildBtn('close', nil, function ( ... )
    	Director:sharedDirector():popScene()
    end)
    self:addChild(closeBtn)

    layoutUtils.setNodeRelativePos(closeBtn, layoutUtils.MarginType.kTOP, 0)
    layoutUtils.setNodeRelativePos(closeBtn, layoutUtils.MarginType.kRIGHT, 0)

    
    local descBtn = self:buildBtn('说明', nil, function ( ... )

    	self:popTip([[
    		1、搜索框可以输入开关id 或者 开关名字。

    		2、如果要输入名字，允许忽略大小写，也可以漏写一些字母。但尽量别写错字母，搜索匹配算法有点智障。

    		3、结果中展示的enable/disable/分组情况 仅仅是根据开关通用配置来计算的，假如某个功能模块自定义了一些规则，比如通过value或者extra的一些字段来控制放量，那么即使本页面显示enable，对应功能也未必开启。
    	]])

    end)
    self:addChild(descBtn)

    layoutUtils.setNodeRelativePos(descBtn, layoutUtils.MarginType.kTOP, 0)
    layoutUtils.setNodeRelativePos(descBtn, layoutUtils.MarginType.kLEFT, 0)


    local listView = VerticalScrollable:create(vs.width, vs.height - 200, true, true)
	self:addChild(listView)

	listView:setPositionXY(0, vs.height - 200)
	self.listView = listView



	local featureNameLabel = self:buildBtn('搜索', 24, nil, true, ccc4f(1, 1, 1, 1))
	self:addChild(featureNameLabel)
	featureNameLabel:setPositionX(featureNameLabel:getContentSize().width/2)
	featureNameLabel:setPositionY(vs.height - 100)

	local featureNameInputSize = CCSizeMake(vs.width*0.6, 48)
	local featureNameInput = self:createEditLabel(CCSizeMake(featureNameInputSize.width, featureNameInputSize.height), nil, function ( text )
		self.searchKeyWords = text
		self:refresh()
	end)
    self:addChild(featureNameInput)
    featureNameInput:setPositionX(featureNameInputSize.width/2 + featureNameLabel:getContentSize().width)
    featureNameInput:setPositionY(vs.height - 100)


    local uidLabel = self:buildBtn('UID', 24, nil, true, ccc4f(1, 1, 1, 1))
	self:addChild(uidLabel)
	uidLabel:setPositionX(uidLabel:getContentSize().width/2)
	uidLabel:setPositionY(vs.height - 165)

	local uidInputSize = CCSizeMake(vs.width*0.6, 48)
	local uidInput = self:createEditLabel(CCSizeMake(uidInputSize.width, uidInputSize.height), nil, function ( text )
		self.uid = text
		self:refresh()
	end)
    self:addChild(uidInput)
    uidInput:setPositionX(uidInputSize.width/2 + uidLabel:getContentSize().width)
    uidInput:setPositionY(vs.height - 165)
    uidInput:setText(tostring(UserManager:getInstance():getUID()))
    self.uid = uidInput:getText()
    self:loadOnline()

    self.ready = true

    self:refresh()
end

function MaintenanceViewer:refresh( ... )
	if self.ready then
		self.listView:removeContent()
		local content = self:createListItems(self.listView)
		self.listView:setContent(content)
		self.listView:scrollToTop(0.1)
	end
end




local function splitChars( text,maxCount,filterFunc )
    local charTab = {}
    local count = 0
    for uchar in string.gfind(text, "[%z\1-\127\194-\244][\128-\191]*") do
        if count >= maxCount then
            return charTab,count,true
        end
        if uchar ~= '\n' and uchar ~= '\r' then
            if not filterFunc or filterFunc(uchar) then 
                table.insert(charTab, uchar)
                count = count + 1
            end
        else
            table.insert(charTab, uchar)
        end
    end
    return charTab,count,false
end
local function dot( v1, v2 )
    local ret = 0
    for i = 1, math.max(#v1, #v2) do
        ret = ret + (v1[i] or 0) * (v2[i] or 0)
    end
    return ret
end
local function mag( v )
    return math.sqrt(dot(v, v))
end
local function getSimilarValue( str1, str2 )
    local t1 = splitChars(str1 or '', 128)
    local t2 = splitChars(str2 or '', 128)

    local common = {}

    for _, v in ipairs(t1) do
        common[v] = true
    end

    for _, v in ipairs(t2) do
        common[v] = true
    end

    local v1 = {}
    local v2 = {}

    for v, _ in pairs(common) do
        if table.indexOf(t1, v) then
            table.insert(v1, 1)
        else
            table.insert(v1, 0)
        end

        if table.indexOf(t2, v) then
            table.insert(v2, 1)
        else
            table.insert(v2, 0)
        end
    end
    return dot(v1, v2) / (mag(v1) * mag(v2) )
end


function MaintenanceViewer:createListItems( parentView )
	local vs = Director:sharedDirector():getVisibleSize()

	local dataList = {}
	local featureName2IdMap = {}

	for name, feature in pairs(MaintenanceManager:getInstance().data) do
		table.insert(dataList, name)
		featureName2IdMap[name] = feature.id
	end

	if self.onlineConfList then
		for _, feature in ipairs(self.onlineConfList) do
			local name = feature.name
			if not featureName2IdMap[name] then
				featureName2IdMap[name] = feature.id
			end
		end
	end


	if self.onlineConfList then
		if not self.allFeatureNames then
			local config = self.onlineConfList
			self.allFeatureNames = {}
			for _, v in ipairs(config) do
				self.allFeatureNames[v.name] = true
			end
			self.allFeatureNames = table.keys(self.allFeatureNames)
		end
	end


	local disabledFeatureNames = {}
	for _, v in pairs(self.allFeatureNames or {}) do
		if not table.indexOf(dataList, v) then
			table.insert(disabledFeatureNames, v)
		end
	end


	dataList = table.union(dataList, disabledFeatureNames)


	if self.searchKeyWords and (tonumber(self.searchKeyWords) or 0) > 0 then
		self.searchKeyWords = self:convertFeatureId2Name(self.searchKeyWords)
	end

	if self.searchKeyWords and self.searchKeyWords ~= '' then

		local priority = {}
		for index, v in ipairs(dataList) do
			priority[v] = math.max(getSimilarValue(v, self.searchKeyWords), getSimilarValue(string.lower(v), string.lower(self.searchKeyWords)))

			if string.match(v, self.searchKeyWords) then
				priority[v] = priority[v] + 1
			end
		end

		table.sort(dataList, function ( a, b )
			return priority[a] > priority[b]
		end)

		dataList = table.headn(dataList, 10)

		for _, v in ipairs(dataList) do
			--printx(61, v, priority[v])
		end
	else
		table.sort(dataList, function ( a, b )
			local ida = featureName2IdMap[a]
			local idb = featureName2IdMap[b]
			if ida and idb then
				return tonumber(ida) < tonumber(idb)
			else
				return a < b
			end
		end)
	end

	local context = self

	local LayoutRender = class(DynamicLoadLayoutRender)
	function LayoutRender:getColumnNum()
		return 1
	end
	function LayoutRender:getItemSize()
		return {width = parentView.width, height = 64}
	end

	function LayoutRender:getVisibleHeight()
        return parentView.height
    end

	function LayoutRender:buildItemView(itemData, index)
		local data = itemData.data
		local itemView 

		local featureId = featureName2IdMap[data] or -1
		featureId = tonumber(featureId) or - 1

		itemView = context:buildBtn('[' .. string.format("%3d", featureId) .. '] ' .. data, 24, function ( ... )
			if itemView.onTap then
				itemView.onTap()
			end
		end)

		local function addFlag( container, flag, lastX )
			container:addChild(flag)
			flag:setPositionY(flag:getContentSize().height/2)
			flag:setPositionX(flag:getContentSize().width/2 + lastX)
			return lastX + flag:getContentSize().width
		end

		if table.indexOf(disabledFeatureNames, data) then
			local flag = context:buildBtn('Disable', 24, nil, true, ccc4f(1, 0, 0, 1))
			addFlag(itemView, flag, itemView:getContentSize().width)
		else
			local lastX = itemView:getContentSize().width

			local groupMode = false

			local feature = MaintenanceManager:getInstance():getMaintenanceFeature(data)
			if feature.modeValue == MaintenanceModeType.kGroup then
				local flag = context:buildBtn('分组', 24, nil, true, ccc4f(1, 0.5, 1.0, 1))
				lastX = addFlag(itemView, flag, lastX)
				groupMode = true
			elseif feature.modeValue == MaintenanceModeType.kOrthogonalGroup then
				local flag = context:buildBtn('正交分组', 24, nil, true, ccc4f(1, 0.5, 1.0, 1))
				lastX = addFlag(itemView, flag, lastX)
				groupMode = true
			elseif MaintenanceManager:getInstance():isEnabled(data) then
				local flag = context:buildBtn('Enable', 24, nil, true, ccc4f(0, 1, 0, 1))
				lastX = addFlag(itemView, flag, lastX)
			else
				local flag = context:buildBtn('Disable', 24, nil, true, ccc4f(1, 0, 0, 1))
				lastX = addFlag(itemView, flag, lastX)
			end


			if groupMode then
				local uid = context.uid 
				if not string.match(uid, '^%d+$') then
					context.uid = UserManager:getInstance():getUID()
					CommonTip:showTip('输入的uid不合法 已使用当前帐户实际uid计算')
				end

				local moduleKeys = context:getModuleKeys(data)
				local enabledModuleKeys = {}
				for _, moduleKey in ipairs(moduleKeys) do
					if MaintenanceManager:getInstance():isEnabledInGroup(data, moduleKey, uid) then
						local moduleKeyView = context:buildBtn(moduleKey, 24, nil, true, ccc4f(1, 1, 1, 1))
						itemView:addChild(moduleKeyView)
						moduleKeyView:setPositionY(moduleKeyView:getContentSize().height/2)
						moduleKeyView:setPositionX(lastX + moduleKeyView:getContentSize().width/2)
						lastX = lastX + moduleKeyView:getContentSize().width
						table.insert(enabledModuleKeys, moduleKey)
					end
				end

				itemView.onTap = function ( ... )
					local message = ''
					for _, v in ipairs(enabledModuleKeys) do
						message = message .. v .. '\n'
					end

					context:popTip(message)
				end

			end
		end


		itemView:setPositionX(itemView:getContentSize().width/2)
		itemView:setPositionY(-itemView:getContentSize().height/2)

		local layoutItem = ItemInClippingNode:create()
		layoutItem:setContent(itemView)
		layoutItem:setParentView(parentView)
		return layoutItem
	end

  	local container = DynamicLoadLayout:create(LayoutRender.new())
  	container:setPosition(ccp(0, 0))
  	container:initWithDatas(dataList)
	return container
end

function MaintenanceViewer:onTapItem( data )

end

function MaintenanceViewer:getModuleKeys( featureName )
	local moduleKeys = {}
	local range = MaintenanceManager:getInstance():getGroupChildRangeMap(featureName)
	if range then
		for _, v in ipairs(range) do
			for _, moduleKey in ipairs(v.modules) do
				moduleKeys[moduleKey] = true
			end
		end
	end


	return table.keys(moduleKeys)
end

function MaintenanceViewer:createEditLabel( size, fontColor, afterValueChanged )

	if not fontColor then 
		fontColor = ccc3(0, 0, 0) 
	end

	local textInput = TextInput:create(size,  CCScale9Sprite:create(),  CCScale9Sprite:create(),  CCScale9Sprite:create())
	textInput:setFontColor(fontColor)
	textInput:setText("")
	textInput:setAnchorPoint(ccp(0, 0))


	local touchLayer = LayerColor:createWithColor(ccc3(255, 255, 255), size.width, size.height)
	touchLayer:setOpacity(128)
	touchLayer:setTouchEnabled(true)
	touchLayer:ignoreAnchorPointForPosition(false)
	touchLayer:setAnchorPoint(ccp(0, 0))

	local function onBoxTapped()
		textInput:openKeyBoard()
		textInput:setText('')
	end

	touchLayer:addEventListener(DisplayEvents.kTouchTap, onBoxTapped)
	textInput.touchLayer = touchLayer
	textInput:addChild(touchLayer)
	touchLayer.refCocosObj:setZOrder(-1)


	local function onTextChanged( ... )
		local text = textInput:getText()
	end
	local function onTextEnd( ... )
		if afterValueChanged then
			afterValueChanged(textInput:getText())
		end

	end
	local function onTextReturn( ... )
	end


	textInput:ad(kTextInputEvents.kEnded, onTextEnd)
	textInput:ad(kTextInputEvents.kChanged, onTextChanged)
	textInput:ad(kTextInputEvents.kReturn, onTextReturn)
	textInput:setText("")

	return textInput
end

function MaintenanceViewer:convertFeatureId2Name( id )
	-- body
	for _, feature in pairs(self.onlineConfList or MaintenanceManager:getInstance().data) do
		if tostring(feature.id) == tostring(id) then
			return feature.name
		end
	end
end

function MaintenanceViewer:loadOnline( ... )
	local url = NetworkConfig.maintenanceURL
	local uid = "12345"
	local params = string.format("?name=maintenance&uid=%s&_v=%s", uid, _G.bundleVersion)
	url = url .. params
  	if _G.isLocalDevelopMode then printx(0, "MaintenanceManager:", url) end
	local request = HttpRequest:createGet(url)
  	local connection_timeout = 2
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
    local function onRegisterFinished( response )
    	if response.httpCode ~= 200 then 
    	else
    		local message = response.body
    		local metaXML = xml.eval(message)
    		local confList = xml.find(metaXML, "maintenance")
    		if confList then
    			self.onlineConfList = confList
    			self:refresh()
	    	end
    	end
    	if onFinish then onFinish() end
    end
    HttpClient:getInstance():sendRequest(onRegisterFinished, request)
end

function MaintenanceViewer:popTip( message, fntSize )


	local tipPanel = LayerColor:create()
	self:addChild(tipPanel)
	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

    local width, height = vs.width * 0.75, vs.width * 0.75 * 0.628
    tipPanel:changeWidthAndHeight(width, height)
    tipPanel:ignoreAnchorPointForPosition(false)

    tipPanel:setAnchorPoint(ccp(0.5, 0.5))
    tipPanel:setPositionXY(vo.x + vs.width/2, vo.y + vs.height/2)
    tipPanel:setColor(hex2ccc3('D15FEE'))


    local innerBG = LayerColor:create()
	tipPanel:addChild(innerBG)
    innerBG:changeWidthAndHeight(width - 16, height - 16)
    innerBG:ignoreAnchorPointForPosition(false)
    innerBG:setAnchorPoint(ccp(0.5, 0.5))
    innerBG:setPositionXY(width/2, height/2)
    innerBG:setColor(hex2ccc3('C1FFC1'))


	local text = TextField:create(message, nil, fntSize or 24 , CCSizeMake( width - 32, height - 32), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	text:setAnchorPoint(ccp(0.5, 0.5))
	tipPanel:addChild(text)
    text:setPositionXY(width/2, height/2)
    text:setColor(ccc3(255, 0, 0))

    tipPanel:setTouchEnabled(true, nil, true, function ( ... )
    	return true
    end, nil, true)

    tipPanel:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
    	tipPanel:removeFromParentAndCleanup(true)
    end))
end

-- setTimeOut(function ( ... )
-- 	MaintenanceViewer:popout()
-- end, 1)
MACRO_DEV_END()

return MaintenanceViewer