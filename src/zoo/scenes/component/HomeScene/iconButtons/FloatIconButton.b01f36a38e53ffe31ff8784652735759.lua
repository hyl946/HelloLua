FloatIconType = table.const {
	kNone = 0,
	kLeft = 1,
	kRight = 2,
}

FloatIconPositionType = table.const {
	kFixed = 0,
	kTopLevel = 1,
}

FloatIconButton = class(CocosObject)

function FloatIconButton:ctor()
	self.floatType = FloatIconType.kNone
	self.posType = FloatIconPositionType.kFixed
end

function FloatIconButton:init(floatType, posType)
	self.floatType = floatType or FloatIconType.kNone
	self.posType = posType or FloatIconPositionType.kFixed
end

function FloatIconButton:getFloatType()
	return self.floatType
end

function FloatIconButton:getPosType()
	return self.posType
end

function FloatIconButton:hitTestPoint(worldPosition, useGroupTest)
	return CocosObject.hitTestPoint(self, worldPosition, useGroupTest)
end

function FloatIconButton:checkVisible(checks)
	return true
end
