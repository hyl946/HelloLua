
require "hecore.class"
require "hecore.display.TextField"
require "hecore.display.Layer"
require "hecore.ui.TableView"

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月27日 15:05:58
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


------------------------------------------------------------
--
-- Use Table View To Implement A Multi Line TTF Text Field.
-- Each Table View Cell Represet One Line
--
------------------------------------------------------------


------------------------------
--  Utility Function
--  ---------------------------

local function convertToMultiLine(columnPerLine, str)

	local lines = {}

	local nextMaxReturnPos = 1 + columnPerLine 
	local nextTrueReturnPos = string.find(str, "\n")

	local line = ""

	for index = 1, string.len(str) do

		if index == nextTrueReturnPos then

			-- A Line Is Completed At True Return Pos
			table.insert(lines, line)
			line = ""

			-- ----------------------
			-- Find Next Return Pos
			-- ----------------------

			-- Next Max Cur Line Pos
			nextMaxReturnPos = index + columnPerLine 
			-- Find The  Next True Return
			nextTrueReturnPos = string.find(str, "\n", index + 1)

		elseif index == nextMaxReturnPos then

			-- A Line Is Completed At Max Line Width
			table.insert(lines, line)
			line = string.sub(str, index, index)

			-- ----------------------
			-- Find Next Return Pos
			-- ----------------------

			-- Next Max Cur Line Pos
			nextMaxReturnPos = index + columnPerLine 
			-- Find The  Next True Return
			nextTrueReturnPos = string.find(str, "\n", index + 1)
		else
			line = line .. string.sub(str, index, index)
		end
	end

	-- The Last Line
	if line ~= "" then
		table.insert(lines, line)
	end

	return lines
end

---------------------------------------------------
-------------- MultiLineTableViewRender
---------------------------------------------------

assert(not MultiLineTableViewRender)
assert(TableViewRenderer)

MultiLineTableViewRender = class(TableViewRenderer)

function MultiLineTableViewRender:init(charPerLine, ...)
	assert(type(charPerLine) == "number")
	assert(#{...} == 0)

	-- Init Base Class
	--TableViewRenderer.ini

	self.charPerLine	= charPerLine
	self.multiLineStr	= { "no error !"}
	self.labels 		= {}
end

function MultiLineTableViewRender:dispose(  )
	for k,v in pairs(self.labels) do
		v:dispose()
	end
end


--function MultiLineTableViewRender:getContentSize()
--
--	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
--	local label		= TextField:create("100000000000000000", "Helvetica", 40, visibleSize)
--	local labelSize		= label:getGroupBounds().size
--	he_log_warning("get label group bounds has problem in width ??!")
--
--	return CCSizeMake(self.width, self.height / self.height)
--end

function MultiLineTableViewRender:buildCell(cell, index, ...)
	assert(cell)
	assert(type(index) == "number")
	assert(#{...} == 0)

	index = index + 1
	
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local label		= TextField:create("Have Fault !", "Helvetica", 40)
	label:setAnchorPoint(ccp(0, 1))

	assert(label)
	assert(label.refCocosObj)

	self.labels[index] 	= label
	cell.refCocosObj:addChild(label.refCocosObj)
	label:releaseCocosObj()
end

function MultiLineTableViewRender:setData(rawCocosObj, index, ...)
	assert(rawCocosObj)
	assert(index)
	assert(#{...} == 0)

	index = index + 1

	local label = self.labels[index]

	assert(label)
	label:setString(self.multiLineStr[index])
end

function MultiLineTableViewRender:numberOfCells(...)
	assert(#{...} == 0)
	
	return #self.multiLineStr
end

function MultiLineTableViewRender:setString(str, ...)
	assert(#{...} == 0)

	self.multiLineStr = convertToMultiLine(self.charPerLine, str)
	--if _G.isLocalDevelopMode then printx(0, "str: " .. str) end
	--for k,v in pairs(self.multiLineStr) do
	--	if _G.isLocalDevelopMode then printx(0, v) end
	--end
end

function MultiLineTableViewRender:create(charPerLine, width, height, ...)
	assert(type(charPerLine)	== "number")
	assert(type(width)	== "number")
	assert(type(height)	== "number")
	assert(#{...} == 0)

	local newMultiLineTableViewRender = MultiLineTableViewRender.new(width, height)
	newMultiLineTableViewRender:init(charPerLine)
	return newMultiLineTableViewRender
end

---------------------------------------------------
-------------- MultiLineTextField
---------------------------------------------------

assert(not MultiLineTextField)
assert(Layer)
MultiLineTextField = class(Layer)

function MultiLineTextField:init(width, height, numberOfLine, charPerLine, ...)
	assert(type(width)		== "number")
	assert(type(height)		== "number")
	assert(type(numberOfLine)	== "number")
	assert(type(charPerLine)	== "number")
	assert(#{...} == 0)

	------------------
	-- Init Base Class
	-- ----------------
	Layer.initLayer(self)

	--------------
	-- Data
	-- -----------
	self.width		= width
	self.height		= height
	self.numberOfLine	= numberOfLine
	self.charPerLine	= charPerLine

	--------------------------
	-- Create The Table View
	-- --------------------
	self.multiLineRender			= MultiLineTableViewRender:create(self.charPerLine, width, height / numberOfLine)
	self.assertFalseLogTableView		= TableView:create(self.multiLineRender, width, height)
	self.assertFalseLogTableView:reloadData()

	self:addChild(self.assertFalseLogTableView)
end

function MultiLineTextField:setString(str, ...)
	assert(type(str) == "string")
	assert(#{...} == 0)

	self.multiLineRender:setString(str)
	self.assertFalseLogTableView:reloadData()
end

function MultiLineTextField:create(width, height, numberOfLine, charPerLine, ...)
	assert(type(width)		== "number")
	assert(type(height)		== "number")
	assert(type(numberOfLine)	== "number")
	assert(type(charPerLine)	== "number")
	assert(#{...} == 0)

	local newMultiLineTextField = MultiLineTextField.new()
	newMultiLineTextField:init(width, height, numberOfLine, charPerLine)
	return newMultiLineTextField
end

function MultiLineTextField:dispose()
	self.multiLineRender:dispose()
	BasePanel.dispose(self)
end