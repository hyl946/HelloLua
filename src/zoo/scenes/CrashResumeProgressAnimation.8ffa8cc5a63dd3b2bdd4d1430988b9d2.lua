CrashResumeProgressAnimation = class(Layer)

local hasLoadRes = false

CrashResumeProgressAnimationState = {
	
	kIn = 1 ,
	kNormal = 2 ,
	kOut = 3 ,

}

function CrashResumeProgressAnimation:create(animationType)
	--printx( 1 , "CrashResumeProgressAnimation:create   animationType =" , animationType)
	local anime = CrashResumeProgressAnimation.new()
	Layer.initLayer(anime)
	anime:initSelf(animationType)
	return anime
end

function CrashResumeProgressAnimation:initSelf(animationType)

    if not hasLoadRes then
    	FrameLoader:loadArmature("skeleton/CrashResume")
    	hasLoadRes = true
    end
    self.animationType = animationType
    if animationType == 2 then
    	self.body = ArmatureNode:create("CrashResume/animation/ClockAnimation2")
    	self:addChild(self.body)
    	self.body:stop()
    	setTimeOut( function () self:changeState( CrashResumeProgressAnimationState.kIn ) end , 0.1 )
    else
    	self.body = ArmatureNode:create("CrashResume/animation/ClockAnimation")
    	self:addChild(self.body)
		self:changeState( CrashResumeProgressAnimationState.kIn )
    end
end

function CrashResumeProgressAnimation:changeState( animeState , callback )

	local function onFinished()
		self.body:removeAllEventListeners()

		if self.animeState == CrashResumeProgressAnimationState.kIn and self.animationType == 1 then
			self:changeState( CrashResumeProgressAnimationState.kNormal )
		end

		if callback then callback() end
	end

	if not self.body or self.body.isDisposed then
		return
	end
	
	self.body:stop()
	self.body:removeAllEventListeners()

	self.body:addEventListener(ArmatureEvents.COMPLETE, onFinished)

	self.body:playByIndex( animeState - 1 )
	self.animeState = animeState

	if self.animeState == CrashResumeProgressAnimationState.kNormal then
		self:createDesc()
	end
end

function CrashResumeProgressAnimation:createDesc()

	local str = Localization:getInstance():getText("crash.resume.tip.inprogress" , {curr = 1 , total = 1})

	--str = "数据恢复中..."
	str = "数据恢复中...(0%)"

    self.label_desc = BitmapText:create( str , "fnt/shantui.fnt" )
    self.label_desc:setPositionXY( self.body:getPositionX() , self.body:getPositionY() - 150 )

    self:addChild( self.label_desc )

end

function CrashResumeProgressAnimation:updateProgress( curr , total )
	if self.label_desc and not self.isDisposed then

		local str = Localization:getInstance():getText("crash.resume.tip.inprogress" , {curr = curr , total = total})

		--str = "数据恢复中 ... " .. tostring(curr) .. "/" .. tostring(total)
		str = "数据恢复中...(" .. tostring( math.floor(  tonumber(curr) / tonumber(total) * 100 ) ) .. "%)"

		self.label_desc:setText( str )
	end
end

function CrashResumeProgressAnimation:removeSelf()
	if self.body then
		self.body:stop()
		self.body:removeAllEventListeners()

		if not self.body.isDisposed then
			self.body:removeFromParentAndCleanup(true)
			self.body = nil
		end
	end

	if not self.isDisposed then
		self:removeFromParentAndCleanup(true)
	end
end