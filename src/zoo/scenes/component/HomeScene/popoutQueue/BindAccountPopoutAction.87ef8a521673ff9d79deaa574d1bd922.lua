BindAccountPopoutAction = class(HomeScenePopoutAction)

function BindAccountPopoutAction:ctor()
	self.name = "BindAccountPopoutAction"
	self.__canPop = true
	self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function BindAccountPopoutAction:checkCanPop()
	if not (self.__canPop and PushBindingLogic:canForcePop()) then
		return self:onCheckPopResult(false)
	end
	--有svip 不弹账号绑定
	SVIPGetPhoneManager.getInstance():canForcePop( function (canPop)
		self:onCheckPopResult(not canPop)
	end )
end

function BindAccountPopoutAction:popout(next_action)
	local function closeCallback(popFlag)
		if not popFlag then
			--TODO:unified this action???
			self.__canPop = false
		end
        next_action()
    end
	PushBindingLogic:tryPopout(closeCallback)
end