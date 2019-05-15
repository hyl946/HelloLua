
local PiecesGuide = class(BasePanel)
function PiecesGuide:create(onReady, onClose)
	local panel = PiecesGuide.new()
	panel:init(onReady, onClose)
	return panel
end

function PiecesGuide:onAddToStage( ... )
	-- body
	if self.isDisposed then return end
	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'


	local wSize = Director:sharedDirector():getWinSize()
	local pos1 = self:convertToNodeSpace(ccp(0, 0))
	local pos2 = self:convertToNodeSpace(ccp(wSize.width, wSize.height))
	self.ui:changeWidthAndHeight(pos2.x - pos1.x, pos2.y - pos1.y)
	self.ui:setPosition(ccp(pos1.x, pos2.y))

	-- CommonTip:showTip(tostring(pos2.x - pos1.x) .. ' ' .. tostring(pos2.y - pos1.y))
	-- CommonTip:showTip(tostring( pos1.x) .. ' ' .. tostring( pos1.y))

	-- local vo = Director:sharedDirector():getVisibleOrigin()
	-- layoutUtils.setNodeRelativePos(self.ui, layoutUtils.MarginType.kBOTTOM, -vo.y)
end

function PiecesGuide:init(onReady, onClose)
	self.onClose = onClose
	self.onReady = onReady
	local touchDelay = 0.5

	local wSize = Director:sharedDirector():getWinSize()
	-- local wSize = CCSizeMake(960, 2000)

	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:ignoreAnchorPointForPosition(false)
	mask:setAnchorPoint(ccp(0, 1))
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(180)
	mask:setTouchEnabled(true, 0, true)

	local arr = CCArray:create()
	mask.layerSprite = layerSprite
	
	self.ui = mask

	self.ui.onAddToStage = function ( 	 )
		self:onAddToStage()
	end

	BasePanel.init(self, self.ui)

	self:runAnimation()
end

function PiecesGuide:runAnimation()
    local anim = ArmatureNode:create("2017SummerWeekly/interface/guideExtraNum2", true)
    self.anim = anim
    anim:playByIndex(0, 1)
    self.ui:addChild(anim)

	local contest = self
	local function onAnimFinished()
		local function onTouch(evt)
			contest:close()
		end
		self.ui:ad(DisplayEvents.kTouchTap, onTouch)

		if self.onReady then
			self.onReady()
		end
	end
	anim:addEventListener(ArmatureEvents.COMPLETE, onAnimFinished)
end

function PiecesGuide:close()
	if not self.isDisposed then
		self:removeFromParentAndCleanup(true)
		if self.onClose then
			self.onClose()
		end
	end
end

function PiecesGuide:setAnimWorldPos( pos )
	local p = self.ui:convertToNodeSpace(pos)
	self.anim:setPosition(p)
end


return PiecesGuide