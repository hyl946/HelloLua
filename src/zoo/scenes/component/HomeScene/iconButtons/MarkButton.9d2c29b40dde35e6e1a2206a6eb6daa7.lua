
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月 6日 17:06:42
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- MarkButton
---------------------------------------------------

assert(not MarkButton)
assert(IconButtonBase)
MarkButton = class(IconButtonBase)

function MarkButton:ctor()
	self.idPre = "MarkButton"
    self.playTipPriority = 40
end
function MarkButton:playHasNotificationAnim(...)
    IconButtonManager:getInstance():addPlayTipNormalIcon(self)
end
function MarkButton:stopHasNotificationAnim(...)
    IconButtonManager:getInstance():removePlayTipNormalIcon(self)
end


function MarkButton:init()
	self.id = self.idPre .. self.tipState
	self["tip"..IconTipState.kNormal] = Localization:getInstance():getText("mark.panel.btn.has.sign.tip")
	
	self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_mark')
	IconButtonBase.init(self, self.ui)

	self:setTipString(self["tip"..IconTipState.kNormal])

	local function refresh(evt) 
		self:onRefresh(evt) 
	end
	MarkModel:getInstance():addEventListener(kMarkEvents.kPriseTimer, refresh)
	self.removeListeners = function(self)
		MarkModel:getInstance():removeEventListener(kMarkEvents.kPriseTimer, refresh)
	end
end

function MarkButton:onRefresh(evt)
	if self.isDisposed then return end
	local time = evt.data
	if type(time) == "number" and time > 0 then
		local endTime = Localhost:timeInSec() + time
		self:startCountdown(endTime)
	end
end

function MarkButton:dispose()
	self:removeListeners()
	IconButtonBase.dispose(self)
end

function MarkButton:playHasSignAnimation()
	self:playHasNotificationAnim()
end

function MarkButton:stopHasSignAnimation()
	self:stopHasNotificationAnim()
end

function MarkButton:create()
	local newMarkButton = MarkButton.new()
	newMarkButton:initShowHideConfig(ManagedIconBtns.MARK)
	newMarkButton:init()
	return newMarkButton
end

