local LevelFlourButton = class(BaseUI)
function LevelFlourButton:create(actData , level)
	local btn = LevelFlourButton.new()
	btn:init(actData , level)
	return btn
end

function LevelFlourButton:init(actData , level)
	self.actData = actData
	self.level = level

	FrameLoader:loadArmature("skeleton/LevelFlourAnimation", 'LevelFlourAnimation', 'LevelFlourAnimation')
	
	local avatar = ArmatureNode:create(actData.res , true)
	avatar:setScale(0.85)
    avatar:setPosition(ccp(-3, 4))
    avatar:playByIndex(0)
    local function onParticlePlayFinished()
		avatar:playByIndex(0)
    end
    avatar:addEventListener(ArmatureEvents.COMPLETE, onParticlePlayFinished)
	self.avatar = avatar

	local ui = Layer:create()
	ui:addChild(avatar)
	BaseUI.init(self, ui)

	self.ui:setTouchEnabled(true, 0, true, nil, true)
	self.ui:ad(DisplayEvents.kTouchTap, function( ... )
		self:onClk()
	end)
end

-- 激活态
function LevelFlourButton:activeState()
	-- avatar
	local avatar = self.avatar
	local function onFinished()
		avatar:playByIndex(1)
    end
	avatar:rma()
	avatar:playByIndex(1)
    avatar:addEventListener(ArmatureEvents.COMPLETE, onFinished)
end

-- 消失态
function LevelFlourButton:dispState(icon)
	--DcUtil:UserTrack({category = "cirrusshow", sub_category = "end", t1 = 1, t4 = config.actId}, true)
	local canvas = HomeScene:sharedInstance()

	-- position
	local bounds = self.ui:getGroupBounds()
	local wPos = ccp(bounds:getMidX(), bounds:getMidY())
	local srcPos = canvas:convertToNodeSpace(wPos)

	-- icon
	icon = icon or HomeScene:sharedInstance().activityButton
	if not icon then return end

	local bounds = icon:getGroupBounds()
	local dstPos = canvas:convertToNodeSpace(ccp(bounds:getMidX() + 10, bounds:getMidY() + 10))

	local sz = self.avatar:getGroupBounds(self.ui).size

	-- fly
	local fly = ParticleSystemQuad:create("particle/fly.plist")
	fly:setVisible(false)
	fly:setPosition(ccp(srcPos.x + 5, srcPos.y - 20))
	fly:setAutoRemoveOnFinish(true)
	canvas:addChild(fly)

	local p1 = ccp(100, 0)
	local p2 = ccp(180, 0.85*(dstPos.y - srcPos.y))
	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = ccp(srcPos.x +  p1.x, srcPos.y +  p1.y)
	bezierConfig.controlPoint_2 = ccp(srcPos.x +  p2.x, srcPos.y +  p2.y)
	bezierConfig.endPosition = dstPos
	local bezierAction_1 = CCEaseInOut:create(CCBezierTo:create(1, bezierConfig), 1.5)

	local sequenceArr = CCArray:create()
	sequenceArr:addObject(CCDelayTime:create(8/24))
	local function playParticle()
		fly:setVisible(true)
	end
	sequenceArr:addObject(CCCallFunc:create(playParticle))

	sequenceArr:addObject(bezierAction_1)
	local function onFlyFinished()
		fly:removeFromParentAndCleanup()

		local iconEffect = ArmatureNode:create('ChannelUp/interface/IconEffect')
		canvas:addChild(iconEffect)
    	iconEffect:setPosition(ccp(dstPos.x - 2, dstPos.y))
    	iconEffect:playByIndex(0)
    	local function onParticlePlayFinished()
    	    iconEffect:removeFromParentAndCleanup()
    	end
    	iconEffect:addEventListener(ArmatureEvents.COMPLETE, onParticlePlayFinished)
	end
	sequenceArr:addObject(CCCallFunc:create(onFlyFinished))
	fly:runAction(CCSequence:create(sequenceArr))

	-- avatar
	local avatar = self.avatar
	local function onPlayFinished()
        avatar:removeFromParentAndCleanup()
    end
	avatar:rma()
	avatar:playByIndex(2)
    avatar:addEventListener(ArmatureEvents.COMPLETE, onPlayFinished)
end

function LevelFlourButton:onClk()

	local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0
	if self.level <= topLevelId then
		ActivityLevelFlourManager:removeFlour(self.level)
	else
		--self:dispState()
		ActivityUtil:getActivitys(function(activitys)
	        local version = nil
	        for k,v in pairs(activitys or {}) do
	            if v.source == self.actData.source then
	                version = v.version
	                break
	            end
	        end

	        if version then
	            ActivityData.new({source=self.actData.source, version=version}):start(true, -1)
	        end
	    end)
	end
	
end

function LevelFlourButton:playAnim( ... )
	-- body
end

return LevelFlourButton