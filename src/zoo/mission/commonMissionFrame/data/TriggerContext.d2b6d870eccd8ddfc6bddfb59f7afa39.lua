TriggerContext = class()

TriggerContextPlace = {
	
	ANY_WHERE = 0,
	ONLINE_SETTER = 1,
	ONLINE_GETTER = 2,
	OFFLINE = 3,
	START_LEVEL_AND_CREATE_GAME_PLAY_SCENE = 4,
	LOGIN_GAME = 5,
	UNLOACK_AREA = 6,
}

function TriggerContext:create(place)
	local context = TriggerContext.new()
	context.place = place
	context.datas = {}
	--context:init(id , targetValue , currentValue , parameters)
	return context
end

function TriggerContext:getPlace()
	return self.place
end

function TriggerContext:addValue(key , value)
	self.datas[key] = value
end

function TriggerContext:getValue(key)
	return self.datas[key]
end