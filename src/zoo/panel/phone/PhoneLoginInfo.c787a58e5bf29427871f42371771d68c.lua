

PhoneLoginMode = table.const {
	kDirectLogin = 1,	 --直接登录
	kChangeLogin = 2, --切换账号登录
	kBindingOldLogin = 3,--绑定登录老账号
	kBindingNewLogin = 4,--绑定登录新账号
	kAddBindingLogin = 5,--添加
}

PhoneLoginInfo = class()

function PhoneLoginInfo:ctor( mode )
	if mode then
		self:setMode(mode)
	end
end

function PhoneLoginInfo:setMode( mode )
	self.mode = mode
end

-- 更改绑定之前的手机号
function PhoneLoginInfo:setOldPhone( phone )
	self.oldPhone = phone
end
function PhoneLoginInfo:getOldPhone( ... )
	return self.oldPhone
end

-- 是否是游客增加绑定
function PhoneLoginInfo:setGuestAddBinding( isGuestAddBinding )
	self._isGuestAddBinding = isGuestAddBinding
end
function PhoneLoginInfo:isGuestAddBinding( ... )
	return self._isGuestAddBinding
end

-- 在游戏内
function PhoneLoginInfo:isInGame( ... )
	return self.mode == PhoneLoginMode.kBindingOldLogin or
		self.mode == PhoneLoginMode.kBindingNewLogin or
		self.mode == PhoneLoginMode.kAddBindingLogin
end

-- loading 
function PhoneLoginInfo:isInLoading( ... )
	return self.mode == PhoneLoginMode.kDirectLogin or
		self.mode == PhoneLoginMode.kChangeLogin
end

-- place 
-- 1=游戏loading界面 
-- 2=游戏内补充登录
function PhoneLoginInfo:getDcPlace( ... )
	if self:isInLoading() then
		return 1
	elseif self:isInGame() then
		return 2
	end
end

-- where 
-- 1=点手机号登录弹出 
-- 2=点切换手机号登录时弹出 
function PhoneLoginInfo:getDcWhere( ... )
	if self.mode == PhoneLoginMode.kDirectLogin then
		return 1
	elseif self.mode == PhoneLoginMode.kChangeLogin then
		return 2
	end
end


-- custom 
-- 1=新用户 
-- 2=老用户
function PhoneLoginInfo:setDcCustom( custom )
	self.dcCustom = custom
end
function PhoneLoginInfo:getDcCustom( ... )
	if self:isInLoading() then
		return self.dcCustom
	elseif self.mode == PhoneLoginMode.kBindingOldLogin then
		return 2
	elseif self.mode == PhoneLoginMode.kBindingNewLogin then
		return 1
	elseif self.mode == PhoneLoginMode.kAddBindingLogin then
		if self:isGuestAddBinding() then
			return self.dcCustom 
		else
			return 1
		end
	end
end