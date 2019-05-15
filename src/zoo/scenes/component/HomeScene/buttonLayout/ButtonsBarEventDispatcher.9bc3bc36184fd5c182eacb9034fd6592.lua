
ButtonsBarEventDispatcher = class(EventDispatcher)

ButtonsBarEvents = {
	kClose = "ButtonsBarEvents.kClose",
}

function ButtonsBarEventDispatcher:ctor()
	
end

function ButtonsBarEventDispatcher:dispatchCloseEvent()
	self:dispatchEvent(Event.new(ButtonsBarEvents.kClose, {}, self))
end

HomeSceneSettingButtonEventDispatcher = class(EventDispatcher)

HomeSceneSettingButtonEvents = {
    kClose = "HomeSceneSettingButtonEvents.kClose",
}

function HomeSceneSettingButtonEventDispatcher:ctor()
    
end

function HomeSceneSettingButtonEventDispatcher:dispatchCloseEvent()
    self:dispatchEvent(Event.new(HomeSceneSettingButtonEvents.kClose, {}, self))
end