local TabIcon = class()

function TabIcon:create(ui, tab, clkCallBack)
	local icon = TabIcon.new()
	icon.clkCallBack = clkCallBack
	icon:init(ui, tab)
	return icon
end

function TabIcon:init(ui, tab)
	self.ui = ui
	self.tab = tab
	self.normal = self.ui:getChildByName("normal")
	self.selected = self.ui:getChildByName("selected")
	self.isSelect = false
	self.normal:setTouchEnabled(true, 0, true)
	self.normal:addEventListener(DisplayEvents.kTouchTap, 
      							 function()
      							 	if self.normal:isVisible() then
      							 		self.clkCallBack(self)
      							 	end
      							 end)
end

function TabIcon:setSelect(v, byDefault)
	if self.isSelect ~= v then
		self.isSelect = v
		if v then
			self.selected:setVisible(true)
			self.tab:setActive(true, byDefault)
			self.normal:setVisible(false)
		else
			self.selected:setVisible(false)
			self.tab:setActive(false)
			self.normal:setVisible(true)
		end
	end
end

function TabIcon:setLabel(str)
	if self.ui ~= nil and self.ui:getChildByName("label") ~= nil then
		self.ui:getChildByName("label"):setString(str)
	end
end


return TabIcon