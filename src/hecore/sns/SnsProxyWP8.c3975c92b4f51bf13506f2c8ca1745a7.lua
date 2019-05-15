require "hecore.sns.SnsCallbackEvent"

SnsProxy = {profile = {}}

function SnsProxy:isLogin()
	return false
end

function SnsProxy:setAuthorizeType(authorType)
	
end

function SnsProxy:getAuthorizeType()
	return PlatformAuthEnum.kPhone
end