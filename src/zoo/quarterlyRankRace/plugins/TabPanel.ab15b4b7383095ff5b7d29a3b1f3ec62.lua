
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local TabPanel = class(BasePlugin)

function TabPanel:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
		
	local num = 0

	for i = 1, 999 do
		local page = self:getChildByPath('./page' .. i)
		if page then
			num = num + 1
		else
			break
		end
	end

	self.pages = {}

	self.normalTabs = {}
	self.selectTabs = {}


	for i = 1, num do
		local page = self:getChildByPath('./page' .. i)
		table.insert(self.pages, page)

		local st = self:getChildByPath('./tab_' .. i .. '_select')
		local nt = self:getChildByPath('./tab_' .. i .. '_normal')

		table.insert(self.normalTabs, nt)
		table.insert(self.selectTabs, st)

	end

	self:turnTo(1)
	
	return true
end

function TabPanel:turnTo( pageIndex )
	if pageIndex ~= self.curPageIndex then
		for index, v in ipairs(self.pages) do
			v:setVisible(pageIndex == index)
		end

		for index, v in ipairs(self.normalTabs) do
			v:setVisible(pageIndex ~= index)
		end

		for index, v in ipairs(self.selectTabs) do
			v:setVisible(pageIndex == index)
		end

		self:callAncestors("afterTurnTo", pageIndex)
	end

	self.curPageIndex = pageIndex
end

function TabPanel:onButtonTap( nodeName )
	local pageIndex = string.match(nodeName, 'tab_(%d+)_normal')
	if pageIndex then
		self:turnTo(tonumber(pageIndex))
		return true
	end
	return true
end

return TabPanel