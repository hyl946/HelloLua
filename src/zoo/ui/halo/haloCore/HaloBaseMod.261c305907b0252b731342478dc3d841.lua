MACRO_DEV_START()
-- 所有Mod的基类
MACRO_DEV_END()


HaloBaseMod = class()

function HaloBaseMod:ctor()
	
	self._className = "src.zoo.ui.halo.haloCore.HaloBaseMod"
	self._targetHolder = nil
	self._oldTargetHolder = nil
	self._enabled = false

end


MACRO_DEV_START()
-- 创建并返回一个HaloBaseMod实例
-- 允许传入HaloBaseModCreateData作为创建参数
-- 这个方法可以被不同子类继承
-- 		子类的create方法可以设计自己特有的参数来方便创建实例
-- 		无论子类的create方法参数如何设计，方法内部都会将参数转化为HaloBaseModCreateData，并调用self:build方法来构建自己
MACRO_DEV_END()
function HaloBaseMod:create( createData )
	local HaloBaseMod = HaloBaseMod.new()
	HaloBaseMod:init( createData )
	return HaloBaseMod
end

MACRO_DEV_START()
-- 仅在创建实例时执行一次的方法
-- 默认情况下，init仅仅只是调用self:build
MACRO_DEV_END()
function HaloBaseMod:init( createData )

	if not self.evtDp then
		self.evtDp = EventDispatcher.new()
	end

	self:build( createData )
end

MACRO_DEV_START()
-- 使用一个HaloBaseModCreateData作为参数数据构建自己
-- 每个Halo的类，都必然有一个build方法来构建自己，且该方法必然只支持一个CreateData的参数
-- 几乎每个Halo类，都支持使用build方法来重复构建自己，即build方法都是支持重复调用的（init方法则是仅调用一次）
MACRO_DEV_END()
function HaloBaseMod:build( createData )
	
end

MACRO_DEV_START()
-- 设置targetHolder，targetHolder是mod的持有者，也是mod特性的应用对象
MACRO_DEV_END()
function HaloBaseMod:setTargetHolder( targetHolder )
	self._targetHolder = targetHolder
end

MACRO_DEV_START()
-- 返回targetHolder，targetHolder是mod的持有者，也是mod特性的应用对象
MACRO_DEV_END()
function HaloBaseMod:getTargetHolder()
	return self._targetHolder
end

MACRO_DEV_START()
-- 当targetHolder发生变更时调用，处理相关逻辑
MACRO_DEV_END()
function HaloBaseMod:__onTargetHolderChanged( oldTargetHolder , targetHolder )

end

MACRO_DEV_START()
-- 设置Mod是否启用
MACRO_DEV_END()
function HaloBaseMod:setEnable( value )
	self._enabled = value
end

MACRO_DEV_START()
-- 返回Mod是否启用
MACRO_DEV_END()
function HaloBaseMod:getEnable()
	return self._enabled
end

MACRO_DEV_START()
-- 返回实例的类名
MACRO_DEV_END()
function HaloBaseMod:getClassName()
	return self._className
end

-- 发送事件 可能是发给外部 
-- 也可能是发给targetHolder
-- 实现暂时采用基类EventDispatcher

function HaloBaseMod:notify( eventType )
	self.evtDp:dp(Event.new(eventType, nil, self))
end

function HaloBaseMod:watch( eventType, listener)
	self.evtDp:ad(eventType, listener)
end

function HaloBaseMod:unwatch( eventType, listener )
	self.evtDp:removeEventListener(eventType, listener)
end

return HaloBaseMod