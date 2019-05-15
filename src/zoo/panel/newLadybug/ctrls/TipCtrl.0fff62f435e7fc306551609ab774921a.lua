local TipCtrl = class()

TipCtrl.State = {
	kHide = 1,
	kText1 = 2,
	kText2 = 3
}

function TipCtrl:ctor( ui )


	self.ui = ui

	if (not self.ui) or self.ui.isDisposed then return end


	self.t1 = self.ui:getChildByName('t1')
	self.t2 = self.ui:getChildByName('t2')
	self.bg = self.ui:getChildByName('bg')


	


	self.state = TipCtrl.State.kHide
	self:refresh()
end

function TipCtrl:enableAutoClose( ... )
	if self.ui.isDisposed then return end

	local function onTouchCurrentLayer(eventType, x, y)
		if not self.ui.isDisposed then
	       	self.ui:unregisterScriptTouchHandler()
			self.ui.refCocosObj:setTouchEnabled(false) 

			self:setState(TipCtrl.State.kHide)
			self:playShowAnim()
	    end
	end
	self.ui:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
    self.ui.refCocosObj:setTouchEnabled(true)

    self.ui:runAction(CCSequence:createWithTwoActions(
		CCFadeIn:create(5),
		CCCallFunc:create(function ( ... )
			if self.ui.isDisposed then return end
			self:setState(TipCtrl.State.kHide)
			self:playShowAnim()
		end)
	))

end

function TipCtrl:setState( newState )
	if self.state ~= newState then
		self.state = newState
		self:refresh()
	end
end

function TipCtrl:refresh( ... )
	if (not self.ui) or self.ui.isDisposed then return end
	if self.state == TipCtrl.State.kHide then
		self.ui:setVisible(false)
	elseif self.state == TipCtrl.State.kText1 then
		self.ui:setVisible(true)
		self.t1:setVisible(true)
		self.t2:setVisible(false)
	elseif self.state == TipCtrl.State.kText2 then
		self.ui:setVisible(true)
		self.t1:setVisible(false)
		self.t2:setVisible(true)
	end
end

function TipCtrl:getState( ... )
	return self.state
end

function TipCtrl:playShowAnim( onFinish )

	if (not self.ui) or self.ui.isDisposed then return end

	local action = CCSequence:createWithTwoActions(
		CCFadeIn:create(5/24.0),
		CCCallFunc:create(function ( ... )
			if onFinish then
				onFinish()
			end
			self:enableAutoClose()
		end)
	)
	self.bg:runAction(action)
	self.t1:runAction(CCFadeIn:create(5/24.0))
	self.t2:runAction(CCFadeIn:create(5/24.0))
end

function TipCtrl:getTip_1_key( ... )
	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
    local uid = UserManager:getInstance().user.uid or '12345'
    local key = 'new.ladybug.tip_1.anim1.show.' .. uid
    return key
end

function TipCtrl:needShowTip_1( ... )
	return CCUserDefault:sharedUserDefault():getBoolForKey(self:getTip_1_key(), false) == false
end

function TipCtrl:hadShowTip_1( ... )
	CCUserDefault:sharedUserDefault():setBoolForKey(self:getTip_1_key(), true)
end

function TipCtrl:getTip_2_key( info )
	local taskId = info.id
	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
    local uid = UserManager:getInstance().user.uid or '12345'
    local key = 'new.ladybug.tip_2.anim1.show.' .. uid .. '.'.. tostring(taskId)
    return key
end

function TipCtrl:needShowTip_2( info )
	local taskId = info.id
	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
	local timeout = not LadybugDataManager:getInstance():isValidExtraReward(info)
	return timeout and CCUserDefault:sharedUserDefault():getBoolForKey(self:getTip_2_key(info), false) == false
end

function TipCtrl:hadShowTip_2( info )
	local taskId = info.id
	CCUserDefault:sharedUserDefault():setBoolForKey(self:getTip_2_key(info), true)
end

function TipCtrl:tryPlayAnim(info, show)
	if show and self:needShowTip_2(info) then
		self:hadShowTip_2(info)
		self:setState(TipCtrl.State.kText2)
		self:playShowAnim()
	elseif show and self:needShowTip_1() then
		self:hadShowTip_1()
		self:setState(TipCtrl.State.kText1)
		self:playShowAnim()
	else
		self:setState(TipCtrl.State.kHide)
		self:playShowAnim()
	end

end

return TipCtrl