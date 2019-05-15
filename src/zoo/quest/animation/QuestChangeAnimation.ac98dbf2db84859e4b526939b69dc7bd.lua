local UIHelper = require 'zoo.panel.UIHelper'
local QuestFactory = require 'zoo.quest.QuestFactory'

local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
local FuncTrack = require 'zoo.panel.endGameProp.anim.FuncTrack'
if __WIN32 then
	package.loaded['zoo.quest.animation.QuestAnimItem'] = nil
end
local QuestAnimItem = require 'zoo.quest.animation.QuestAnimItem'

local function PositionXSetter( context, PositionX )
	if (not context) or context.isDisposed then return end
	context:setPositionX(PositionX)
end

local function PositionYSetter( context, PositionY )
	if (not context) or context.isDisposed then return end
	context:setPositionY(PositionY)
end

local function OpacitySetter( context, Opacity )
	if (not context) or context.isDisposed then return end
	context:setOpacity(Opacity)
end

local function ScaleSetter( context, Scale )
	if (not context) or context.isDisposed then return end
	context:setScale(Scale)
end

local function ScaleXSetter( context, ScaleX )
	if (not context) or context.isDisposed then return end
	context:setScaleX(ScaleX)
end

local function ScaleYSetter( context, ScaleY )
	if (not context) or context.isDisposed then return end
	context:setScaleY(ScaleY)
end

local function S9HeightSetter( context, h )
	if (not context) or context.isDisposed then return end
	local size = context:getPreferredSize()
	context:setPreferredSize(CCSizeMake(size.width, h))
end


local QuestChangeAnimation = class(Layer)

local BG_HEIGHT_DELTA = 400 - 241

function QuestChangeAnimation:create( changeDataList )

	-- printx(61, 'QuestChangeAnimation:create', debug.traceback())
	-- body
	local changeDataList = changeDataList or {
		-- 	{
		-- 		oldData = {relTarget = 100, num = 10},
		-- 		newData = {relTarget = 100, num = 100},
		-- 		quest = QuestFactory:createQuestByRawData({
		-- 			id = 1,
		-- 			relTarget = 100,
		-- 			num = 100,
		-- 			_type = 9,
		-- 			data = {},
		-- 		}, 1)
		-- },

		-- {
		-- 		oldData = {relTarget = 100, num = 10},
		-- 		newData = {relTarget = 100, num = 70},
		-- 		quest = QuestFactory:createQuestByRawData({
		-- 			id = 1,
		-- 			relTarget = 100,
		-- 			num = 70,
		-- 			_type = 9,
		-- 			data = {},
		-- 		}, 1)
		-- },
		-- {
		-- 		oldData = {relTarget = 100, num = 10},
		-- 		newData = {relTarget = 100, num = 50},
		-- 		quest = QuestFactory:createQuestByRawData({
		-- 			id = 1,
		-- 			relTarget = 100,
		-- 			num = 50,
		-- 			_type = 9,
		-- 			data = {},
		-- 		}, 1)
		-- },

		{
				oldData = {relTarget = 100, num = 10},
				newData = {relTarget = 100, num = 70},
				quest = QuestFactory:createQuestByRawData({
					id = 1,
					relTarget = 100,
					num = 70,
					_type = 9,
					data = {},
				}, 1)
		}
	}

	if #changeDataList <= 0 then
		return 
	end

	local anim = QuestChangeAnimation.new()
	anim:init(changeDataList)
	return anim
end

function QuestChangeAnimation:init( changeDataList )


	UIHelper:loadJson('flash/quest-icon.json')

	self:initLayer()
	self.changeDataList = changeDataList

	local BG_WIDTH = 622

	self.bg = Scale9Sprite:createWithSpriteFrameName('quest-anim/scaleBG0000')
	self.bg:setAnchorPoint(ccp(0.5, 1))

	self:addChild(self.bg)

	self.bg:setPreferredSize(CCSizeMake(BG_WIDTH, 60))
	self.bg.name = 'bg'

	self.animPlayer = AnimationPlayer:create()
	self.animPlayer:setTarget(self)
	self:addChild(self.animPlayer)

	self.itemContainer = self

	self.animQuestItemList = {}
	for i = 1, #changeDataList do
		local item = QuestAnimItem:create(changeDataList[i])
		self.itemContainer:addChild(item)
		item:setVisible(false)
		item:setPositionX(-280)
		item:setPositionY(-50)
		self.animQuestItemList[i] = item

	end

	self:createFirstQuestAnim(changeDataList[1])

	for i = 2, #changeDataList do
		self:createNextQuestAnim(changeDataList[i], i)
	end


	local play2Func = FuncTrack.new()
	play2Func:setName('play2Func')
	play2Func:setTargetPath('.')
	play2Func:setFrameDataConfig({
		{index = self.lastFrameIndex, data = function ( ... )
			if self.isDisposed then return end
			for _, v in ipairs(self.animQuestItemList) do
				v:playInfoAnim()
			end
		end},
	})
	self.animPlayer:addTrack(play2Func)

	self.lastFrameIndex = self.lastFrameIndex + 60

	local disposeDelay = 30

	local disapperTrack = PropertyTrack.new()
	disapperTrack:setName('disapper')
	disapperTrack:setPropertyAccessor(nil, OpacitySetter)
	disapperTrack:setTargetPath('.')
	disapperTrack:setFrameDataConfig({
		{index = self.lastFrameIndex + disposeDelay, data = 255},
		{index = self.lastFrameIndex + disposeDelay + 10, data = 0},
	})
	self.animPlayer:addTrack(disapperTrack)

	local disposeTrack = FuncTrack.new()
	disposeTrack:setName('dispose')
	disposeTrack:setTargetPath('.')
	disposeTrack:setFrameDataConfig({
		{index = self.lastFrameIndex + disposeDelay, data = function ( ... )
			if self.isDisposed then return end
			if self.darkLayer then
				self.darkLayer:removeFromParentAndCleanup(true)
				self.darkLayer = nil
			end

			for _, v in ipairs(self.animQuestItemList) do
				v:preDisapper()
			end

		end},
		{index = self.lastFrameIndex + disposeDelay + 1 + 45, data = function ( ... )
			if self.isDisposed then return end
			self:close()
		end},
	})
	self.animPlayer:addTrack(disposeTrack)

	self.animPlayer:preStart(0.001)

end


function QuestChangeAnimation:createFirstQuestAnim( changeData )
	if self.isDisposed then return end

	local bgScaleY = PropertyTrack.new()
	bgScaleY:setName('bgScaleY')
	bgScaleY:setPropertyAccessor(nil, ScaleYSetter)
	bgScaleY:setTargetPath('bg')
	bgScaleY:setFrameDataConfig({
		{index = 0, data = 0.2},
		{index = 3, data = 1.0},
	})
	self.animPlayer:addTrack(bgScaleY)

	local bgOpacity = PropertyTrack.new()
	bgOpacity:setName('bgOpacity')
	bgOpacity:setPropertyAccessor(nil, OpacitySetter)
	bgOpacity:setTargetPath('bg')
	bgOpacity:setFrameDataConfig({
		{index = 0, data = 0},
		{index = 9, data = 255},
	})
	self.animPlayer:addTrack(bgOpacity)

	local bgHeight = PropertyTrack.new()
	bgHeight:setName('bgHeight')
	bgHeight:setPropertyAccessor(nil, S9HeightSetter)
	bgHeight:setTargetPath('bg')
	bgHeight:setFrameDataConfig({
		{index = 3, data = 60},
		{index = 9, data = 241},
	})
	self.animPlayer:addTrack(bgHeight)

	local funcTrack = FuncTrack.new()
	funcTrack:setName('funcTrack')
	funcTrack:setTargetPath('.')
	funcTrack:setFrameDataConfig({
		{index = 3, data = function ( ... )
			if self.isDisposed then return end
			self.animQuestItemList[1]:setVisible(true)
			self.animQuestItemList[1]:playAppearAnim()
		end},
	})
	self.animPlayer:addTrack(funcTrack)


	self.lastFrameIndex = 10
	self.lastBGHeight = 241
end



function QuestChangeAnimation:createNextQuestAnim( changeData, dataIndex)
	if self.isDisposed then return end


	local bgHeight = PropertyTrack.new()
	bgHeight:setName('bgHeight-' .. dataIndex)
	bgHeight:setPropertyAccessor(nil, S9HeightSetter)
	bgHeight:setTargetPath('bg')
	bgHeight:setFrameDataConfig({
		{index = self.lastFrameIndex + 3, data = self.lastBGHeight},
		{index = self.lastFrameIndex + 10, data = self.lastBGHeight + BG_HEIGHT_DELTA},
	})
	self.animPlayer:addTrack(bgHeight)


	local funcTrack = FuncTrack.new()
	funcTrack:setName('funcTrack-' .. dataIndex)
	funcTrack:setTargetPath('.')
	funcTrack:setFrameDataConfig({
		{index = self.lastFrameIndex + 5, data = function ( ... )
			if self.isDisposed then return end
			local item = self.animQuestItemList[dataIndex]
			item:setVisible(true)
			item:playAppearAnim()
			item:setPositionY(item:getPositionY() - (dataIndex - 1) * 165)
		end},
	})
	self.animPlayer:addTrack(funcTrack)


	self.lastFrameIndex = self.lastFrameIndex + 11
	self.lastBGHeight = self.lastBGHeight + BG_HEIGHT_DELTA
end

function QuestChangeAnimation:setOpacity( opacity )
	if self.isDisposed then return end
	self:getChildByPath('bg'):setOpacity(opacity)
	for _, v in ipairs(self.animQuestItemList) do
		v:setOpacity(opacity)
	end

	if self.darkLayer then
		self.darkLayer:setOpacity(opacity)
	end
end

function QuestChangeAnimation:dispose( ... )
	UIHelper:unloadJson('flash/quest-icon.json')
	Layer.dispose(self, ...)
end

function QuestChangeAnimation:popout( parent, pos )
	if self.isDisposed then return end
	-- parent = parent or Director:sharedDirector():run()
	-- parent:addChild(self, 'topLayer')
	self._pop_pos = pos
	PopoutQueue.sharedInstance():push(self, false)

end

function QuestChangeAnimation:popoutShowTransition( ... )
	local pos = self._pop_pos or self:getPos()

	local pos = self:getParent():convertToNodeSpace(pos)

	self:setPosition(ccp(pos.x, pos.y))
	self.animPlayer:start()
	-- ____BBBB = function ( ... )
		-- self:close()
	-- end
	-- ____CCCC = function ( ... )
	-- 	self.animQuestItemList[1]:setOpacity(0)
	-- end
	local vs = Director:sharedDirector():ori_getVisibleSize()
    local vo = Director:sharedDirector():ori_getVisibleOrigin()
	local darkLayer = LayerColor:createWithColor(ccc3(0, 0, 0), vs.width, vs.height)
	self.darkLayer = darkLayer
	darkLayer:setOpacity(0)
	self:addChildAt(darkLayer, 0)
	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeOriginPos(darkLayer, ccp(0, 0))
	darkLayer:runAction(CCFadeTo:create(0.8, 150))
end

function QuestChangeAnimation:getPos( ... )
	if self.isDisposed then return end
	local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

    local pos = ccp(vo.x + vs.width/2, vo.y + vs.height/2 + self.lastBGHeight/2)
    return pos
end

function QuestChangeAnimation:close( ... )
	if self.isDisposed then return end
	-- self:removeFromParentAndCleanup(true)
	PopoutManager:sharedInstance():remove(self)
	
end

function QuestChangeAnimation:onKeyBackClicked( ... )
end

-- if __WIN32 then
-- 	setTimeOut(function ( ... )
-- 		QuestChangeAnimation:create():popout()	
-- 	end, 1)
-- end

return QuestChangeAnimation