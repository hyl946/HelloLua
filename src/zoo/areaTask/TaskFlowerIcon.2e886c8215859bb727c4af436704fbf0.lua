local UIHelper = require 'zoo.panel.UIHelper'


local TaskFlowerIcon = class(LayerColor)

local __scale = 0.75


function TaskFlowerIcon:shake( ... )
	if self.isDisposed then return end
	self.ui_container:playByIndex(1, 1)
	self.shake_counter = 1
end

function TaskFlowerIcon:init( ... )
	self:initLayer()
	self.data = nil
	self.ui = nil

	UIUtils:setTouchHandler(self, function ( ... )
		if self.isDisposed then return end
		if self.data then
			Notify:dispatch("QuitNextLevelModeEvent")

			local areaId = math.floor((self.data.levelId - 1) / 15) + 40001
			local AreaTaskInfoPanel = require 'zoo.areaTask.AreaTaskInfoPanel'
			AreaTaskInfoPanel:create(areaId):popoutPush()
		end
	end)

	self.ui_container = UIHelper:createArmature2('skeleton/area_task_flower', 'area.task.flower/FlowerAnim')
	self:addChild(self.ui_container)

	self.ui_container:playByIndex(0, 1)

	self.ui_container:ad(ArmatureEvents.COMPLETE, function ( ... )
		if self.isDisposed then return end
		setTimeOut(function ( ... )
			if self.isDisposed then return end
			if self.ui_container.isDisposed then return end

			if self.shake_counter > 0 then
				self.shake_counter = self.shake_counter - 1
				self.ui_container:playByIndex(1, 1)
			else
				self.ui_container:playByIndex(0, 1)
			end
		end, 0.3)
	end)

	self:setScale(__scale)
end

function TaskFlowerIcon:create( ... )
	local tfi = TaskFlowerIcon.new()
	tfi:init()
	return tfi
end

function TaskFlowerIcon:dispose( ... )
	LayerColor.dispose(self, ...)
	if self.ui then
		self.ui:dispose()
	end
end

function TaskFlowerIcon:refreshUI( ... )

	if self.isDisposed then return end
	if not self.data then return end

	local state = nil

	local model = _G.AreaTaskMgr:getInstance():getModel()

	if not self.ui then
	-- if state ~= self.state then
		-- self.state = state

		self.ui = ResourceManager:sharedInstance():buildGroup('area.task.ui/tip1')
		self.ui:getChildByPath('gift'):removeFromParentAndCleanup(true)
		self.ui:getChildByPath('bg'):removeFromParentAndCleanup(true)

		self.ui = UIHelper:replaceLayer2LayerColor(self.ui)
		-- self.ui_container:addChild(self.ui)

		local slot = self.ui_container:getCon('图层 2')
		slot:addChild(self.ui.refCocosObj)

		self.ui:setScale(1.1)
		self.ui:setPosition(ccp(58.7 + 7, -10))


		local label = BitmapText:create("","fnt/timelimit_gift.fnt")
		local labelHolder = self.ui:getChildByPath('label')

		local leftUpPos = labelHolder:getPosition()
		local centerPos = ccp(
				leftUpPos.x + labelHolder.preferredWidth/2,
				leftUpPos.y - labelHolder.preferredHeight/2 + 2
			)
		label:setAnchorPoint(ccp(0.5, 0.5))
		label:setPosition(centerPos)
		label:setColor(hex2ccc3('990000'))
		label:setScale(0.7)

		self.ui:addChild(label)

		self.ui.label = label

		UIHelper:setCascadeOpacityEnabled(self)
		
	end

	if self.ui then

		-- if self.state == STATE.kFinished then
			--never traped
		-- else
			--todo 
			local endTime = self.data.endTime or 0
			local now = Localhost:time()
			local timeout = (endTime - now) / 1000
			local timeoutText = '' 
			local secPerDay = 24 * 3600
			if timeout > secPerDay then
				timeoutText = localize('area.goal.desc2', {num = math.floor(timeout / secPerDay)})
			else
				timeoutText = convertSecondToHHMMSSFormat(timeout)
			end
			self.ui.label:setText(timeoutText)
		-- end
	end
end

function TaskFlowerIcon:setData( taskInfo )
	self.data = taskInfo
end

function TaskFlowerIcon:getData( ... )
	return self.data or {}
end






function TaskFlowerIcon:getPosition( pos )
	return self.pos or Layer.getPosition(self)
end

return TaskFlowerIcon