-- 成就等级和权益
local AchiExplainPanel = class(BasePanel)

function AchiExplainPanel:create(builder)
	local render = AchiExplainPanel.new()
    render:init(builder)
    render:setData()
    return render
end

function AchiExplainPanel:init(builder)
	local ui = builder:buildGroup('achievement/achi_explain_panel')
	BasePanel.init(self, ui)

	self.close_btn = GroupButtonBase:create(ui:getChildByName("close"))
    self.close_btn:setColorMode(kGroupButtonColorMode.green)
    self.close_btn:setString("关闭")
    self.close_btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
        self:onCloseBtnTapped()
    end, 1))

    self.title = self.ui:getChildByName('title')
    self.info = self.ui:getChildByName('info')
    for i = 2, 6 do
    	self['item'..i] = self.ui:getChildByName('item'..i)
    	self['item'..i].bg1 = self['item'..i]:getChildByName('bg1')
    	self['item'..i].bg2 = self['item'..i]:getChildByName('bg2')
    	self['item'..i].info1 = self['item'..i]:getChildByName('info1')
    	self['item'..i].info2 = self['item'..i]:getChildByName('info2')
    	self['item'..i].info3 = self['item'..i]:getChildByName('info3')
    end
end

function AchiExplainPanel:setData(data)
	self.title:changeFntFile('fnt/caption.fnt')
	self.title:setText(localize('achievement.new.panel.title3'))
	self.title:setScale(1.2)
	self.info:setString(localize('achievement.right.detail1'))

	for i = 2, 6 do
		local gradeIcon = Sprite:createWithSpriteFrameName('achievement/achi_grade_' .. i .. '_mc0000')
		gradeIcon:setAnchorPoint(ccp(0.5, 0.5))
		gradeIcon:setPosition(ccp(70, -62))
		gradeIcon:setScale(0.93)
		self['item'..i]:addChild(gradeIcon)

		self['item'..i].info1:changeFntFile('fnt/register2.fnt')
		self['item'..i].info1:setText(localize('achievement.medal.title'.. i))
		self['item'..i].info1:setColor(ccc3(137, 56, 19))
		self['item'..i].info1:setScale(0.88)
		if i == 2 then 
            local str = ""
            if UserManager.getInstance().markV2Active then
                str = localize('achievement.right.text1_1')
            else
                str = localize('achievement.right.text1')
            end
			self['item'..i].info3:setString(str)
			self['item'..i].info3:setPositionY(-48)
		else
			self['item'..i].info3:setString(localize('achievement.right.detail2', {medal = localize('achievement.medal.title'..(i - 1)), text = localize('achievement.right.text'..(i - 1))}))
			self['item'..i].info3:setPositionY(-30)
		end

		local achiState = Achievement:getState()
		if achiState.level == i then
			self['item'..i].bg1:setVisible(false)
		else
			self['item'..i].bg2:setVisible(false)
		end

		local achiPoints = Achievement:getRightsConfig()
		self['item'..i].info2:setString(localize('achievement.right.detail3', {num = achiPoints[i].points}))
	end
end

function AchiExplainPanel:popout()
	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function AchiExplainPanel:onCloseBtnTapped()
    if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

return AchiExplainPanel