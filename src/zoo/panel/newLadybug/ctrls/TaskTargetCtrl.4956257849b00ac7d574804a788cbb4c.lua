local TaskTargetCtrl = class()

function TaskTargetCtrl:ctor( ui )
	self.ui = ui

	if (not self.ui) or self.ui.isDisposed then return end

	self.icon = self.ui:getChildByName('icon')
	self.scroll = self.ui:getChildByName('scroll')
	self.content = self.ui:getChildByName('content')
	self.bg = self.content:getChildByName('bg')
	self.text = self.content:getChildByName('text')

	self.text_1 = self.text:getChildByName('t1')
	self.text_2 = self.text:getChildByName('t2')
	self.text_2:setScale(30.0/32)
	self.text_3 = self.text:getChildByName('t3')
	self.text_3:setScale(26.0/32)


	self.text:setScale(1.1)


	self.text_1:setColor(hex2ccc3('3F8A00'))
	self.text_2:setColor(hex2ccc3('3F8A00'))
	self.text_3:setColor(hex2ccc3('FF8500'))

	self.text_1:changeFntFile('fnt/register2.fnt')
	self.text_2:changeFntFile('fnt/register2.fnt')
	self.text_3:changeFntFile('fnt/register2.fnt')

	local childIndex = self.ui:getChildIndex(self.content)

	local size = self.bg:getContentSize()
	size = CCSizeMake(size.width - 14, size.height)

	local pos = self.content:getPosition()
	pos = ccp(pos.x, pos.y)

	local stencilNode = LayerColor:createWithColor(ccc3(0,0,255), size.width, size.height)
	stencilNode:ignoreAnchorPointForPosition(false)
	stencilNode:setAnchorPoint(ccp(0, 1))
	self.stencilNode = stencilNode

	local clipNode = ClippingNode.new(CCClippingNode:create(stencilNode.refCocosObj))

	-- local clipNode = Layer:create()
	-- clipNode:addChild(stencilNode)


	self.content:removeFromParentAndCleanup(false)
	self.content:setPosition(ccp(0, 0))
	clipNode:addChild(self.content)
	clipNode:setPosition(pos)

	self.ui:addChildAt(clipNode, childIndex)


	self.content:setVisible(false)
	self.scroll:setVisible(false)


end

function TaskTargetCtrl:playIconAnim1( onFinish )

	if (not self.ui) or self.ui.isDisposed then return end

	local frameRate = 24

	local array = CCArray:create()
	array:addObject(CCRotateTo:create(
		2/frameRate,
		15
	))
	array:addObject(CCRotateTo:create(
		2/frameRate,
		-15
	))
	array:addObject(CCRotateTo:create(
		2/frameRate,
		8.7
	))
	array:addObject(CCRotateTo:create(
		2/frameRate,
		-5
	))
	array:addObject(CCRotateTo:create(
		1/frameRate,
		0
	))
	array:addObject(CCCallFunc:create(function ( ... )
		if onFinish then
			onFinish()
		end
	end))

	local action = CCSequence:create(array)

	self.icon:runAction(action)
end

function TaskTargetCtrl:playIconAnim2( onFinish )

	if (not self.ui) or self.ui.isDisposed then return end

	local frameRate = 24

	local array = CCArray:create()
	array:addObject(CCScaleTo:create(
		4/frameRate,
		1.3, 1.3
	))
	array:addObject(CCScaleTo:create(
		4/frameRate,
		1.1, 1.1
	))
	array:addObject(CCScaleTo:create(
		4/frameRate,
		1.25, 1.25
	))
	array:addObject(CCScaleTo:create(
		3/frameRate,
		1.25, 1.25
	))
	array:addObject(CCScaleTo:create(
		4/frameRate,
		1, 1
	))
	array:addObject(CCCallFunc:create(function ( ... )
		if onFinish then
			onFinish()
		end
	end))

	local action = CCSequence:create(array)
	
	self.icon:runAction(action)
end

function TaskTargetCtrl:playScrollAnim( onFinish )
	if (not self.ui) or self.ui.isDisposed then return end

	self.content:setVisible(true)
	self.scroll:setVisible(true)


	local time = 1
	local dist = 650

	local ox1 = self.stencilNode:getPositionX()
	local ox2 = self.scroll:getPositionX()

	self.stencilNode:setPositionX(ox1-dist)
	self.stencilNode:runAction(CCMoveTo:create(time, ccp(ox1, self.stencilNode:getPositionY())))

	self.scroll:setPositionX(ox2-dist)
	self.scroll:runAction(
		CCSequence:createWithTwoActions(CCMoveTo:create(time, ccp(ox2, self.scroll:getPositionY())), CCCallFunc:create(function ( 	 )
			if onFinish then
				onFinish()
			end
		end))
	)
end

function TaskTargetCtrl:dispose( ... )

	if (not self.stencilNode) or self.stencilNode.isDisposed then
		return
	end

	self.stencilNode:dispose()
end

function TaskTargetCtrl:setText(id, taskType, targetNum, curNum, targetStar, curStar, todayTask, finished)

	if curNum > targetNum then
		curNum = targetNum
	end

    local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'

	self.text_1:setText(string.format('任务：'))
	if taskType == LadybugDataManager.TaskTargetType.kMainLevel then
		self.text_2:setText(string.format('到达第%s关',targetNum+1))

		if targetStar > 1 then
			self.text_2:setText(string.format('%s星通过第%s关', targetStar, targetNum))
		end

	else
		self.text_2:setText(string.format('成功闯%s次周赛关',targetNum))
	end

	if todayTask then
		if finished then
			self.text_3:setRichText('（已完成）')
		else

			if taskType == LadybugDataManager.TaskTargetType.kMainLevel and id ~= 7 then 
				self.text_3:setRichText(
					string.format('（[#FF8500]%s[/#]/%s）', curNum, targetNum+1),
					'3F8A00'
				)
			else
				self.text_3:setRichText(
					string.format('（[#FF8500]%s[/#]/%s）', curNum, targetNum),
					'3F8A00'
				)
			end

			if taskType == LadybugDataManager.TaskTargetType.kMainLevel then
				if targetStar > 1 and curNum >= targetNum then
					self.text_3:setRichText(
						string.format('（[#FF8500]%s[/#]/%s）', curStar, targetStar),
						'3F8A00'
					)
				end 
			end
		end
	else
		if finished then
			self.text_3:setRichText('（明日领奖）')
		else
			self.text_3:setRichText(
				string.format('（[#FF8500]%s[/#]/%s明日任务）', curNum, targetNum+1),
				'3F8A00'
			)

			if taskType == LadybugDataManager.TaskTargetType.kMainLevel then
				if targetStar > 1 and curNum >= targetNum then
					self.text_3:setRichText(
						string.format('（[#FF8500]%s[/#]/%s明日任务）', curStar, targetStar),
						'3F8A00'
					)
				end 
			end
		end
	end


	local spacingX = 0
	self.text_2:setPositionX(self.text_1:getPositionX() + self.text_1:getContentSize().width + spacingX)
	self.text_3:setPositionX(self.text_2:getPositionX() + self.text_2:getContentSize().width + spacingX - 12)
end

function TaskTargetCtrl:playAnim(  )
	self.content:setVisible(false)
	self.scroll:setVisible(false)

	self:playIconAnim1(function ( ... )
		self:playScrollAnim(function ( 	 )
			self:playIconAnim2()
		end)
	end)
end

function TaskTargetCtrl:show( ... )
	self.content:setVisible(true)
	self.scroll:setVisible(true)
end

return TaskTargetCtrl