local UIHelper = require 'zoo.panel.UIHelper'

local Thumb = class(BaseUI)

function Thumb:ctor()
end

function Thumb:init(json, symbol, fntFile, strColor, strScale, posAdjust)
	json = json or "ui/thumb.json"
	symbol = symbol or  "component_ui_thumb/c_thumb"
	fntFile = fntFile or "fnt/tutorial_white.fnt"
	self.strScale = strScale or 1
	self.ui = UIHelper:createUI(json, symbol)
	BaseUI.init(self, self.ui)

	self.iconUI = self.ui:getChildByName("icon")
	local iconPos = self.iconUI:getPosition()
	local iconSize = self.iconUI:getContentSize()
	self.wrap = iconPos.x * 2 + iconSize.width + (posAdjust and posAdjust.x or 0)
	self.bg = self.ui:getChildByName("bg")
	self.bgHeight = self.bg:getContentSize().height
	self.label = UIHelper:addBitmapTextByIcon(self.iconUI, "", fntFile, strColor, strScale, posAdjust)
end

--call after self.ui is addChilded and positioned
--default alignment is right
function Thumb:setText(str, isAlignmentLeft)
	if not self.oriPos then
		local pos = self:getPosition() 
		self.oriPos = {x = pos.x, y = pos.y}
	end
	self.label:setText(str)
	local strSize = self.label:getContentSize()
	local bgSize = self.wrap + strSize.width * self.strScale
	self.bg:setContentSize(CCSizeMake(bgSize, self.bgHeight))
	if not isAlignmentLeft then
		self:setPosition(ccp(self.oriPos.x - bgSize, self.oriPos.y))
	end
end

function Thumb:getThumbIconPos(nodeToConvert)
	local iconPos = self.iconUI:getPosition()
	local iconWorldPos = self.ui:convertToWorldSpace(ccp(iconPos.x, iconPos.y))
	local iconNewPos = nodeToConvert:convertToNodeSpace(ccp(iconWorldPos.x, iconWorldPos.y))
	return {x = iconNewPos.x, y = iconNewPos.y}
end

function Thumb:create(json, symbol, fntFile, strColor, strScale, posAdjust)
	local thumb = Thumb.new()
	thumb:init(json, symbol, fntFile, strColor, strScale, posAdjust)
	return thumb
end

------------------------------------------------------------------------------
function Thumb:playFlyAni(flyParent, startPos, endPos, endCallback)
	
end

return Thumb