local UIHelper = require 'zoo.panel.UIHelper'

local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local QuestAnimItem = class(Layer)

local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
local FuncTrack = require 'zoo.panel.endGameProp.anim.FuncTrack'

local function PositionYSetter( context, PositionY )
	if (not context) or context.isDisposed then return end
	context:setPositionY(PositionY)
end

local function OpacitySetter( context, Opacity )
	if (not context) or context.isDisposed then return end
	context:setOpacity(Opacity)
end

local function ProgerssSetter( context, p )
	if (not context) or context.isDisposed then return end
	context:setProgress(p)
end

function QuestAnimItem:setOpacity( opacity )
	if self.isDisposed then return end

	self.view:setOpacity(opacity)
	if self.finishedAnimContainer then
		self.finishedAnimContainer:setOpacity(opacity)
	end

    -- local progressNode = self.view:getChildByPath('progress')
	-- progressNode:setOpacity(opacity)
end


function QuestAnimItem:create( changeData )
	local animItem = QuestAnimItem.new()
	animItem:initLayer()
	animItem:init(changeData)
	return animItem
end

function QuestAnimItem:preDisapper( ... )
	if self.isDisposed then return end
	self.view:getChildByPath('progress'):setVisible(false)
end

function QuestAnimItem:init( changeData )
	self.changeData = changeData


	self.mmr = {}

	local quest = changeData.quest

	local view = UIHelper:createUI('flash/quest-icon.json', 'quest-anim/quest-item')

	view = UIHelper:replaceLayer2LayerColor(view)
	UIHelper:setCascadeOpacityEnabled(view, false)



	view.name = 'view'

	self.view = view

	local oldSetOpacity = self.view.setOpacity

	self.view.setOpacity = function (context, ... )
		oldSetOpacity(context, ...)

		self.view:findChildByName('fg'):setOpacity(...)
		self.view:findChildByName('fg2'):setOpacity(...)
		-- self.view:findChildByName('fg3'):setOpacity(...)
	end

	if quest:_isFinished() then
		local finishedAnimContainer = UIHelper:createArmature3('skeleton/quest-animation-misc', 
                        'quest-animation-misc', 'quest-animation-misc', 'quest-animation-misc/finish')

		self:addChild(finishedAnimContainer)
		finishedAnimContainer:getCon('container'):addChild(view.refCocosObj)
		view:setPositionY(32)
		view:getChildByPath('bg1'):removeFromParentAndCleanup(true)
		table.insert(self.mmr, view)
		self.finishedAnimContainer = finishedAnimContainer
		self.finishedAnimContainer:playByIndex(0, 1)
		self.finishedAnimContainer:stop()
		self.finishedAnimContainer:update(0.01)
		-- self.finishedAnimContainer:setVisible(false)

	else
		self:addChild(view)
	end

    local setProgressFunc = UIHelper:buildProgress(view:getChildByPath('progress'), 'fg')
    local setProgressFunc2 = UIHelper:buildProgress(view:getChildByPath('progress'), 'fg2')
    local setProgressFunc3 = UIHelper:buildProgressSP9(view:getChildByPath('progress'), 'fg3')


    view:getChildByPath('progress'):findChildByName('fg3'):setOpacity(0)


    view:setVisible(true)
    view:getChildByPath('label'):setString( quest:getDesc() )
    local iconHolder = view:getChildByPath('icon')
    iconHolder:setVisible(false)
    local bounds = iconHolder:getGroupBounds()
    local pos = ccp(bounds:getMidX(), bounds:getMidY())
    pos = view:convertToNodeSpace(pos)
    local index = view:getChildIndex(iconHolder)
    local icon = quest:createIcon()    
    view:addChildAt(icon, index)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(pos)
    layoutUtils.setNodeCenterPos(icon, pos, view)
    view.icon = icon


    local progress = view:getChildByPath('progress')
    progress[setProgressFunc](self, math.clamp(changeData.oldData.num/changeData.oldData.relTarget, 0, 1))
    progress[setProgressFunc2](self, math.clamp(changeData.newData.num/changeData.newData.relTarget, 0, 1))
    progress[setProgressFunc3](self, math.clamp(changeData.newData.num/changeData.newData.relTarget, 0, 1))

    UIHelper:setCenterText(progress:getChildByPath('txt'), string.format('%d/%d', changeData.oldData.num, changeData.oldData.relTarget), 'fnt/hud.fnt')

    UIHelper:move(progress:getChildByPath('txt'), 0, -1)

    self.animPlayer = AnimationPlayer:create()
	self.animPlayer:setTarget(self)
	self:addChild(self.animPlayer)

	self:setOpacity(0)
end

function QuestAnimItem:playAppearAnim( ... )
	-- body
	self:runAction(UIHelper:sequence{
		CCDelayTime:create(0.2),
		CCCallFunc:create(function ( ... )
			self:_play()
		end)
	})
end

function QuestAnimItem:_play( ... )
	if self.isDisposed then return end

	local deltaY = 150.9 - 128.9
	local py = self:getPositionY()
	self:setPositionY(py - deltaY)
	self:setOpacity(0)


	local viewOpacity = PropertyTrack.new()
	viewOpacity:setName('viewOpacity')
	viewOpacity:setPropertyAccessor(nil, OpacitySetter)
	viewOpacity:setTargetPath('.')
	viewOpacity:setFrameDataConfig({
		{index = 0, data = 0},
		{index = 7, data = 255},
	})
	self.animPlayer:addTrack(viewOpacity)

	local viewPosY = PropertyTrack.new()
	viewPosY:setName('viewPosY')
	viewPosY:setPropertyAccessor(nil, PositionYSetter)
	viewPosY:setTargetPath('.')
	viewPosY:setFrameDataConfig({
		{index = 0, data = py - deltaY},
		{index = 7, data = py},
	})
	self.animPlayer:addTrack(viewPosY)

	self.animPlayer:start()

	


end

function QuestAnimItem:playInfoAnim( ... )
	if self.isDisposed then return end
	self:playProgressAnim()
	
end

function QuestAnimItem:playProgressAnim( ... )
	if self.isDisposed then return end


	self.view:getChildByPath('progress'):findChildByName('fg3'):runAction(UIHelper:sequence{
		CCDelayTime:create(0.3),
		CCFadeIn:create(0.3),
		CCDelayTime:create(0.3),
		CCFadeOut:create(0.3),
		
		CCCallFunc:create(function ( ... )
			if self.isDisposed then return end

			self.animPlayer2 = AnimationPlayer:create()
			self.animPlayer2:setTarget(self)
			self:addChild(self.animPlayer2)

			local frames = self.changeData.newData.num - self.changeData.oldData.num
			frames = math.clamp(frames, 5, 10)
			
			local txt = self.view:getChildByPath('progress/txt')

			txt:setNumWithAnim(self.changeData.newData.num, frames / 30, function ( k )
				if self.isDisposed then return end
				txt:setText(k .. '/' .. self.changeData.newData.relTarget)
			end)


			local progress = self.view:getChildByPath('progress')

			local progressAnimPlayer = AnimationPlayer:create()
			progressAnimPlayer:setTarget(progress)
			progress:addChild(progressAnimPlayer)

			local progessTrack = PropertyTrack.new()
			progessTrack:setName('progessTrack')
			progessTrack:setPropertyAccessor(nil, ProgerssSetter)
			progessTrack:setTargetPath('.')
			progessTrack:setFrameDataConfig({
				{index = 0, data = self.changeData.oldData.num / self.changeData.oldData.relTarget},
				{index = frames, data = self.changeData.newData.num / self.changeData.newData.relTarget},
			})

			progressAnimPlayer:addTrack(progessTrack)

			local funcTrack = FuncTrack.new()
			funcTrack:setName('funcTrack')
			funcTrack:setTargetPath('.')
			funcTrack:setFrameDataConfig({
				{index = frames + 1, data = function ( ... )
					if self.isDisposed then return end
					if self.progressStarAnim then
						self.progressStarAnim:removeFromParentAndCleanup(true)
						self:unscheduleUpdate()


						local flyStar = UIHelper:createArmature3('skeleton/quest-animation-misc', 
		                        'quest-animation-misc', 'quest-animation-misc', 'quest-animation-misc/fly-star')

						self.view:getChildByPath('progress'):addChild(flyStar)
						local fg = self.view:findChildByName('fg')
						flyStar:setPositionX(
							fg:getPositionX() + fg:getContentSize().width
						)
						flyStar:playByIndex(0, 1)


					end
				end},
			})
			self.animPlayer2:addTrack(funcTrack)


			progressAnimPlayer:start()



			local anim = UIHelper:createArmature3('skeleton/quest-animation-misc', 
		                        'quest-animation-misc', 'quest-animation-misc', 'quest-animation-misc/progress-star')
			anim:playByIndex(0, 0)
			progress:addChild(anim)

			self.progressStarAnim = anim

			self:scheduleUpdateWithPriority(function ( dt )
				self:onUpdate(dt)
			end, 0)

			self.animPlayer2:start()



			if self.finishedAnimContainer then
				self.finishedAnimContainer:setVisible(true)
				self.finishedAnimContainer:playByIndex(0, 1)
			end

		end)

	})


	
end

function QuestAnimItem:dispose( ... )
	for _, v in ipairs(self.mmr or {}) do
		v:dispose()
	end
	self.mmr = nil
	self:unscheduleUpdate()
	Layer.dispose(self, ...)	
end

function QuestAnimItem:onUpdate( ... )
	if self.isDisposed then return end

	if self.progressStarAnim then
		local fg = self.view:findChildByName('fg')
		self.progressStarAnim:setPositionX(
			fg:getPositionX() + fg:getContentSize().width
		)
	end

end

return QuestAnimItem