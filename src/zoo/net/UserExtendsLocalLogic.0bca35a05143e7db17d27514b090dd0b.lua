require "zoo.data.DataRef"

UserExtendsLocalLogic = class()

function UserExtendsLocalLogic:extraEenrgy(uid, meta)
	UserLocalLogic:refreshEnergy()
	local now = Localhost:time()
	local userExtend = UserService.getInstance().userExtend
	local energyPlusEffectTime = userExtend:getEnergyPlusEffectTime()
	local energyPlusPermanentId = userExtend.energyPlusPermanentId
	if energyPlusEffectTime <= now then		
		if energyPlusPermanentId == 0 then UserExtendsLocalLogic:setExtraEnergy(userExtend, meta, now)
		else
			local confidence = meta.confidence or 0
			local metaPermanent = MetaManager.getInstance():getPropMeta(energyPlusPermanentId)
			local confPermanent = metaPermanent.confidence or 0
			if confidence < confPermanent then
				return false, ZooErrorCode.USE_ENERY_PLUS_PROP_ERROR_ENERGY_PLUS_ERROR
			end
			UserExtendsLocalLogic:setExtraEnergy(userExtend, meta, now)
		end
	else
		local energyPlusId = userExtend.energyPlusId or 0
		if energyPlusId > 0 then
			if energyPlusPermanentId > 0 then return false, ZooErrorCode.USE_ENERY_PLUS_PROP_ERROR end
			UserExtendsLocalLogic:setExtraEnergy(userExtend, meta, now)
		end
	end
	return true
end

function UserExtendsLocalLogic:setExtraEnergy( userExtend, meta, now )
	local value = meta.value or 0
	if value == -1 then
		userExtend:setEnergyPlusEffectTime(0)
		userExtend.energyPlusPermanentId = meta.id
	else
		local milliseconds_day = 24*60*60*1000
		userExtend.energyPlusId = 0
		local effectTime = now + value * milliseconds_day
		userExtend:setEnergyPlusEffectTime(effectTime)
	end
end

function UserExtendsLocalLogic:notConsumeEnergyBuff( uid, minute )
	local userExtend = UserService.getInstance().userExtend
	local now = Localhost:time()
	local milliseconds_munute = 60 * 1000
	local notConsumeEnergyBuff = userExtend:getNotConsumeEnergyBuff()
	if notConsumeEnergyBuff <= now then
		userExtend:setNotConsumeEnergyBuff(now + minute * milliseconds_munute)
	else
		userExtend:setNotConsumeEnergyBuff(notConsumeEnergyBuff + minute * milliseconds_munute)
	end
end

function UserExtendsLocalLogic:isNotConsumeEnergyBuff(uid)
	local userExtend = UserService.getInstance().userExtend
	local now = Localhost:time()
	local milliseconds_munute = 60 * 1000
	return userExtend:getNotConsumeEnergyBuff() + milliseconds_munute >= now
end