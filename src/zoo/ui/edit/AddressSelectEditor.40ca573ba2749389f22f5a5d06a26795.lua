local SuperCls = require('zoo.ui.edit.EditInterface')
local ScrollEdit = require('zoo.ui.edit.ScrollEdit')
local db = require 'zoo.ui.edit.db'

local AddressSelectEditor = class(SuperCls)

function AddressSelectEditor:ctor( ... )
end

function AddressSelectEditor:init( w, h, itemHeight, createItemFunc, locationBtn)
	if self.isDisposed then return end
	SuperCls.init(self)

	self.width = w
	self.height = h
	self.itemHeight = itemHeight

	local color = hex2ccc3('FFBA48')
	local color1 = hex2ccc3('FFFFFF')

	self.createItemFunc = createItemFunc


	self.provinceEditor = ScrollEdit:create(self.width/3, self.height, self.itemHeight, color, color1)
	self.cityEditor = ScrollEdit:create(self.width/3, self.height, self.itemHeight, color, color1)
	self.countyEditor = ScrollEdit:create(self.width/3, self.height, self.itemHeight, color, color1)

	self.provinceEditor.name = 'provinceEditor'
	self.cityEditor.name = 'cityEditor'
	self.countyEditor.name = 'countyEditor'

	self.provinceEditor:setSubMode(true)
	self.cityEditor:setSubMode(true)
	self.countyEditor:setSubMode(true)

	local btnHeight = locationBtn:getGroupBounds().size.height

	local btnMask = LayerColor:createWithColor(color, w, btnHeight)
	btnMask:ignoreAnchorPointForPosition(false)
	btnMask:setAnchorPoint(ccp(0, 1))
	btnMask:setPositionY(h)
	self:addChild(btnMask)

	self:addChild(locationBtn)

	locationBtn:setPositionY(h)
	locationBtn:setTouchEnabled(true)

	local function onLocatedFail()
		CommonTip:showTip(localize('my.card.edit.area.loading.tip2'))
	end

	local function onLocatedSuccess()
		if self.isDisposed then return end

		LocationManager_All.getInstance():initLocationManager()
		LocationManager_All.getInstance():startUpdatingLocation(true)
		
		local scene = Director:sharedDirector():getRunningScene()
	    self.animation = CountDownAnimation:createNetworkAnimation(scene, nil, localize('my.card.edit.area.loading.tip1'), true)

	    self.animation.onKeyBackClicked = function() end

	    setTimeOut(function ( ... )
	    	if self.isDisposed then return end

	    	if self.animation then
	    		self.animation:removeFromParentAndCleanup(true)
	    		self.animation = nil
	    	end

	    	local data = LocationManager_All.getInstance():getLocationData()

	    	if __WIN32 then
	    		data = {
	    			province = '内蒙古',
	    			city = '赤峰',
	    			district = '喀喇沁',
	    		}
	    	end

			if data and data.province and data.city and data.district then
				local province = data.province				
				local city = data.city
				local district = data.district				

				local adcode = data.adcode --百度sdk 没有adcode ，高德才有

				if adcode then
					self:setValueByAdCode(adcode)
				else
					adcode = db:findSimilarAdCodeByStr(province, city, district)
					self:setValueByAdCode(adcode)
				end

				CommonTip:showTip(localize('my.card.edit.area.loading.tip3'), 'positive')

				self:hide()
			else
				onLocatedFail()
			end
	    end, 3)
	end

	locationBtn:ad(DisplayEvents.kTouchTap, function ()
		PermissionManager.getInstance():requestEach(PermissionsConfig.ACCESS_FINE_LOCATION, onLocatedSuccess, onLocatedFail)
	end)


	self:addChild(self.provinceEditor)
	self:addChild(self.cityEditor)
	self:addChild(self.countyEditor)




	self.provinceEditor:setPositionX(0)
	self.cityEditor:setPositionX(self.width/3)
	self.countyEditor:setPositionX(self.width/3*2)

	


	self.provinceEditor:setPositionY(-btnHeight)
	self.cityEditor:setPositionY(-btnHeight)
	self.countyEditor:setPositionY(-btnHeight)


	self.cityName2Id = {}


	local taskList = db:getProvinces()


	self.taskId = 1

	local onLoaded

	self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ( ... )
			if self.isDisposed then return end
			
			for kkk = 1, 3 do

				if self.taskId <= #taskList then
					self.provinceEditor:addItem(self.createItemFunc(string.format("%s", taskList[self.taskId][1])))
				else
					if self.scheduleScriptFuncID then
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)
						self.scheduleScriptFuncID = nil
					end
					onLoaded()
					break
				end
				self.taskId = self.taskId + 1

			end

	end, 0, false)




	onLoaded = function ( ... )
		if self.isDisposed then return end

		self:setTouchEnabled(true, nil, true, function ( ... )
	    	return true
	    end)

	    local function pointInRect( pos, rect )
	    	return pos.x >= rect.left and pos.y >= rect.bottom and pos.x <= rect.right and pos.y <= rect.top
	    end

	    self:ad(DisplayEvents.kTouchBegin, function ( evt )
	    	if self.isDisposed then return end
	    	local pos = evt.globalPosition
	    	pos = self:convertToNodeSpace(pos)
	    	if not pointInRect(pos, {left = 0, bottom = 0, right = self.width, top = self.height}) then
	    		self:hide()
	    	end
	    end)

	    self.provinceEditor:connect('value_change', self, self.onprovinceChange)
	    self.cityEditor:connect('value_change', self, self.oncityChange)
	    self.countyEditor:connect('value_change', self, self.oncountyChange)

	    if self.onLoadedCallback  then
	    	self.onLoadedCallback()
	    end

	end

end

function AddressSelectEditor:dispose()
	SuperCls.dispose(self)

	if self.scheduleScriptFuncID then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)
		self.scheduleScriptFuncID = nil
	end

end

function AddressSelectEditor:onprovinceChange( ... )

	if self.isDisposed then return end

	local province = self.provinceEditor:getValue()

	if self.cacheProvince ~= province then

		self.cacheProvince = province

		local citys = db:getCitys(province)

		if #citys > self.cityEditor:getItemNum() then
			local delta = #citys - self.cityEditor:getItemNum()
			for i = 1, delta do
				self.cityEditor:addItem(self.createItemFunc('xx'))
			end
		elseif #citys < self.cityEditor:getItemNum() then
			local delta = - #citys + self.cityEditor:getItemNum()
			for i = 1, delta do
				self.cityEditor:removeItemByIndex(1)
			end
		end


		for index, v in ipairs(citys) do
			self.cityEditor:setItemValue(index, (v[1]))
			self.cityName2Id[v[1]] = v[2]
		end

		if #citys > 0 then
			self.cityEditor:setValue(citys[1][1])
		end

		self:oncityChange()

	end
end


function AddressSelectEditor:oncityChange( ... )
	if self.isDisposed then return end

	local city = self.cityEditor:getValue()

	if self.cacheCity ~= city then

		self.cacheCity = city



		local countys = db:getCountysByCityId(self.cityName2Id[city])

		if #countys > self.countyEditor:getItemNum() then
			local delta = #countys - self.countyEditor:getItemNum()
			for i = 1, delta do
				self.countyEditor:addItem(self.createItemFunc('xx'))
			end
		elseif #countys < self.countyEditor:getItemNum() then
			local delta = - #countys + self.countyEditor:getItemNum()
			for i = 1, delta do
				self.countyEditor:removeItemByIndex(1)
			end
		end

		for index, v in ipairs(countys) do
			self.countyEditor:setItemValue(index, (v[1]))
		end

		if #countys > 0 then

			self.countyEditor:setValue(countys[1][1])
		end

		self:oncountyChange()

	end
end

function AddressSelectEditor:oncountyChange( ... )
	if self.isDisposed then return end

	local county = self.countyEditor:getValue()

	if self.cacheCounty ~= county then
		self.cacheCounty = county
	end

	self:notifyValueChange()
end


function AddressSelectEditor:getValue( ... )
	if self.isDisposed then return end
	return (self.provinceEditor:getValue() or '') .. '#' .. (self.cityEditor:getValue() or '') .. '#' .. (self.countyEditor:getValue() or '')
end

function AddressSelectEditor:setValue( v )
	if self.isDisposed then return end
	local province, city, county = string.match(v, '(.*)#(.*)#(.*)')
	self.provinceEditor:setValue(province)
	-- self:onprovinceChange()
	self.cityEditor:setValue(city)
	-- self:oncityChange()
	self.countyEditor:setValue(county)
	-- self:oncountyChange()

end

function AddressSelectEditor:setValueByAdCode( adcode )
	if self.isDisposed then return end
	local address = db:getAddressByAdCode(adcode)
	self:setValue(address)
end

function AddressSelectEditor:create( w, h, itemHeight , createItemFunc, locationBtn)
	-- body
	local i = AddressSelectEditor.new()
	i:init(w, h, itemHeight, createItemFunc, locationBtn)
	return i
end


return AddressSelectEditor