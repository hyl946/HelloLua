local SuperCls = require('zoo.ui.edit.EditInterface')
local ScrollEdit = require('zoo.ui.edit.ScrollEdit')

local DateSelectEditor = class(SuperCls)

function DateSelectEditor:ctor( ... )
end

function DateSelectEditor:onAddToStage( ... )
	if self.isDisposed then return end
	self:notifyValueChange()
end

function DateSelectEditor:notifyValueChange( ... )
	if not self.loaded then
		return
	end
	SuperCls.notifyValueChange(self, ...)
end

function DateSelectEditor:init( w, h, itemHeight, createItemFunc)
	if self.isDisposed then return end
	SuperCls.init(self)

	self.width = w
	self.height = h
	self.itemHeight = itemHeight

	local color = hex2ccc3('FFBA48')
	local color1 = hex2ccc3('FFFFFF')

	self.createItemFunc = createItemFunc

	self.yearEditor = ScrollEdit:create(self.width/3, self.height, self.itemHeight, color, color1)
	self.monthEditor = ScrollEdit:create(self.width/3, self.height, self.itemHeight, color, color1)
	self.dayEditor = ScrollEdit:create(self.width/3, self.height, self.itemHeight, color, color1)

	self.yearEditor:setSubMode(true)
	self.monthEditor:setSubMode(true)
	self.dayEditor:setSubMode(true)

	self:addChild(self.yearEditor)
	self:addChild(self.monthEditor)
	self:addChild(self.dayEditor)

	self.yearEditor:setPositionX(0)
	self.monthEditor:setPositionX(self.width/3)
	self.dayEditor:setPositionX(self.width/3*2)

	-- for year = 1900, 2031 do
	-- 	self.yearEditor:addItem(self.createItemFunc(string.format("%02d", year)))
	-- end

	-- for year = 1, 12 do
	-- 	self.monthEditor:addItem(self.createItemFunc(string.format("%02d", year)))
	-- end

	-- for year = 1, 31 do
	-- 	self.dayEditor:addItem(self.createItemFunc(string.format("%02d", year)))
	-- end

	local toyear = os.date('%Y', Localhost:timeInSec()) 
	toyear = tonumber(toyear) or 2018

	self.taskId = 1

	local onLoaded

	self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ( ... )
			if self.isDisposed then return end

			for kkk = 1, 3 do
				if self.taskId <= 12 then
					self.monthEditor:addItem(self.createItemFunc(string.format("%02d", self.taskId)))
				end

				if self.taskId <= 31 then
					self.dayEditor:addItem(self.createItemFunc(string.format("%02d", self.taskId)))
				end

				if self.taskId <= toyear - 1900 then
					self.yearEditor:addItem(self.createItemFunc(string.format("%02d", self.taskId + 1900 - 1)))
				else
					if self.scheduleScriptFuncID then
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)
						self.scheduleScriptFuncID = nil
					end
					onLoaded()
					return
				end
				
				self.taskId = self.taskId + 1
			end

	end, 0, false)

	onLoaded = function ( ... )


		if self.isDisposed then return end

		self.loaded = true

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

	    self.yearEditor:connect('value_change', self, self.onYearChange)
	    self.monthEditor:connect('value_change', self, self.onMonthChange)
	    self.dayEditor:connect('value_change', self, self.onDayChange)

	    if self.onLoadedCallback  then
	    	self.onLoadedCallback()
	    end
	end
end

function DateSelectEditor:onYearChange( ... )
	if self.isDisposed then return end
	if not self.loaded then return end

	local year = self.yearEditor:getValue()
	if self.cacheyear ~= year then
		self.cacheyear = year

		self:notifyValueChange()
		self:check()
	end
end


function DateSelectEditor:onMonthChange( ... )
	if self.isDisposed then return end
	if not self.loaded then return end

	local month = self.monthEditor:getValue()
	if self.cachemonth ~= month then
		self.cachemonth = month

		self:notifyValueChange()
		self:check()
	end
end

function DateSelectEditor:onDayChange( ... )
	if self.isDisposed then return end
	if not self.loaded then return end
	local day = self.dayEditor:getValue()
	if self.cacheday ~= day then
		self.cacheday = day

		self:notifyValueChange()
	end
end

function DateSelectEditor:check( ... )
	if self.isDisposed then return end
	if not self.loaded then return end
	local year = tonumber(self.yearEditor:getValue())
	local month = tonumber(self.monthEditor:getValue())

	local days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	local day = days[month]

	if month == 2 then
		if (year % 400 == 0) or ((year % 100 ~= 0) and (year % 4 == 0)) then
			day = 29
		end
	end

	for k = 31,  29, -1 do
		if day >= k then
		else
			self.dayEditor:removeItemByIndex(k)
		end
	end

	for k = 29, 31 do
		if day >= k then
			if not self.dayEditor:findItemByValue(tostring(k)) then
				self.dayEditor:addItem(self.createItemFunc(tostring(k)))
			end
		else
		end
	end

end

function DateSelectEditor:getValue( ... )
	if not self.loaded then return end
	if self.isDisposed then return end
	return self.yearEditor:getValue() .. self.monthEditor:getValue() .. self.dayEditor:getValue()
end

function DateSelectEditor:setValue( v )
	if not self.loaded then return end
	if self.isDisposed then return end
	local year, month, day = string.match(v, '(%d%d%d%d)(%d%d)(%d%d)')



	self.yearEditor:setValue(year)
	-- self:onYearChange()
	self.monthEditor:setValue(month)
	-- self:onMonthChange()
	self.dayEditor:setValue(day)
	-- self:onDayChange()
end

function DateSelectEditor:dispose( ... )
	SuperCls.dispose(self)

	if self.scheduleScriptFuncID then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID)
		self.scheduleScriptFuncID = nil
	end

end

function DateSelectEditor:create( w, h, itemHeight , createItemFunc)
	-- body
	local i = DateSelectEditor.new()
	i:init(w, h, itemHeight, createItemFunc)
	return i 
end


return DateSelectEditor