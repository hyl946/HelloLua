--[[
 * AutoPopNoticePanel
 * @date    2018-08-10 10:27:36
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local AutoPopNoticePanel = class(BasePanel)

function AutoPopNoticePanel:ctor( ... )
	-- body
end

function AutoPopNoticePanel:create(txt_key, close_cb)
	local panel = AutoPopNoticePanel.new()
	panel:init(txt_key, close_cb)
	return panel
end

function AutoPopNoticePanel:init(txt_key, close_cb)
	self.builder = InterfaceBuilder:create("flash/scenes/homeScene/homeScene.json")
	self.ui = self.builder:buildGroup('AutoPopoutNotice/Panel')
	BasePanel.init(self, self.ui)
	self.close_cb = close_cb

	local desc = self.ui:getChildByName("desc")

	local w,h = 512,237
	desc:setDimensions(CCSizeMake(w, 0))
	desc:setString(localize(txt_key))

	local size = desc:getContentSize()
	local height = h - size.height

	local bg1 = self.ui:getChildByName("bg2")
	local bg1size = bg1:getGroupBounds().size
	bg1:setPreferredSize(CCSizeMake(bg1size.width, bg1size.height - height))

	local bg = self.ui:getChildByName("bg")
	local bgsize = bg:getGroupBounds().size
	bg:setPreferredSize(CCSizeMake(bgsize.width, bgsize.height - height))

	local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))

	btn:setPositionY(btn:getPositionY() + height)

	btn:setString("知道了")
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:onCloseBtnTapped()
    end)
end

function AutoPopNoticePanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	if self.close_cb then self.close_cb() end
	PopoutManager:sharedInstance():remove(self, true)
end

function AutoPopNoticePanel:popout()
	self.allowBackKeyTap = true
	PopoutQueue:sharedInstance():push(self, true, false)
	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
end

return AutoPopNoticePanel