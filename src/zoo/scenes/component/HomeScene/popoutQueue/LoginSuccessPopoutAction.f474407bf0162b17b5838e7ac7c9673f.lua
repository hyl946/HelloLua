
LoginSuccessPopoutAction = class(HomeScenePopoutAction)

function LoginSuccessPopoutAction:ctor()
	self.name = "LoginSuccessPopoutAction"
	self.recallUserNotPop = true
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function LoginSuccessPopoutAction:checkCache(cache)
	if self.debug then
		cache = {para = {title = "x", message = "y"}}
	end
    local para = cache.para
    self.para = para
    self:onCheckCacheResult(para and para.title and para.message)
end

function LoginSuccessPopoutAction:popout( next_action )
	if self.para then
		require "zoo.panel.QQLoginSuccessPanel"
		local qqLoginPanel = QQLoginSuccessPanel:create(self.para.title,self.para.message)
		qqLoginPanel:popout()
		qqLoginPanel:addEventListener(PopoutEvents.kRemoveOnce, next_action)
	else
		next_action()
	end
end