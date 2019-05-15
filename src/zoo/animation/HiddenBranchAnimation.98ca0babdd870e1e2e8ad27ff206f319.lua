require "hecore.display.Director"

HiddenBranchAnimation = class(Sprite)

function HiddenBranchAnimation:initStatic()
	local sprite = CCSprite:create()
	self:setRefCocosObj(sprite)
	--self.refCocosObj:setTexture(texture)

	local sprite1 = self:buildStatic("hide_branch10000", ccp(-15, -6))
	local sprite2 = self:buildStatic("hide_branch20000", ccp(-5, -40))
	local sprite3 = self:buildStatic("hide_branch30000", ccp(-20, -5))

	sprite2:setPosition(ccp(0, 10))
	sprite3:setPosition(ccp(0, 59))
	self.sprite1 = sprite1
	self.sprite2 = sprite2
	self.sprite3 = sprite3
	
	self:addChild(sprite1)
	self:addChild(sprite2)
	self:addChild(sprite3)

	self:setTexture(sprite1:getTexture())
end

function HiddenBranchAnimation:createStatic()
	local v = HiddenBranchAnimation.new()
	v:initStatic()
	return v
end

function HiddenBranchAnimation:initAnim(callback)
	local sprite = CCSprite:create()
	self:setRefCocosObj(sprite)

	local callbackCounter = 0
	local function onAnimUnitCallback()
		callbackCounter = callbackCounter + 1
		if callbackCounter >= 3 then
			if callback and type(callback) == "function" then
				callback()
			end
		end
	end

	local sprite1 = self:buildAnim("hide_branch10000", "hiddenBranchMask1", ccp(-15, -6), onAnimUnitCallback)
	local sprite2 = self:buildAnim("hide_branch20000", "hiddenBranchMask2", ccp(-5, -40), onAnimUnitCallback)
	local sprite3 = self:buildAnim("hide_branch30000", "hiddenBranchMask3", ccp(-20, -5), onAnimUnitCallback)

	sprite1:setPosition(ccp(-15, -6))
	sprite2:setPosition(ccp(0, 10))
	sprite3:setPosition(ccp(0, 59))

	self:addChild(sprite1)
	self:addChild(sprite2)
	self:addChild(sprite3)
end

function HiddenBranchAnimation:createAnim(callback)
	local v = HiddenBranchAnimation.new()
	v:initAnim(callback)
	return v
end

function HiddenBranchAnimation:buildStatic(spriteName, offset)
	local sprite = Sprite:createWithSpriteFrameName(spriteName)
	sprite:setAnchorPoint(ccp(0, 0))
	sprite:setPosition(offset)

	return sprite
end

function HiddenBranchAnimation:buildAnim(spriteName, maskName, offset, animCallback)
	local sprite = Sprite:createWithSpriteFrameName(spriteName)
	sprite:setAnchorPoint(ccp(0, 0))

	local spriteSize = sprite:getContentSize()
	local spriteWidth = spriteSize.width
	local spriteHeight = spriteSize.height
	
	local frameLength = 37
	local pattern = maskName .. "%04d"

	local stencilNode = CCSprite:createWithSpriteFrameName(string.format(pattern, 0))
	stencilNode:setAnchorPoint(ccp(0, 0))
	stencilNode:setScale(2)
	stencilNode:setPosition(offset)

	local clip = ClippingNode.new(CCClippingNode:create(stencilNode))
	clip:setAlphaThreshold(0)
	clip:setAnchorPoint(ccp(0, 0))
	clip:addChild(sprite)

	local function onAnimationFinish()
		local layer = CCLayerColor:create(ccc4(255,255,255,255), spriteWidth, spriteHeight)
		layer:setAnchorPoint(ccp(0,0))
		clip:setStencil(layer)
		clip:setAlphaThreshold(1)
		if animCallback and type(animCallback) == "function" then
			animCallback()
		end
	end
	
	local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames(pattern, 0, frameLength), 1 / 30)
	local rep = CCRepeat:create(animate, 1)
	local callback = CCCallFunc:create(onAnimationFinish)

	stencilNode:runAction(CCSequence:createWithTwoActions(rep, callback))

	return clip
end 


function HiddenBranchAnimation:buildDataAnim( ui,animateData )
	local actions = CCArray:create()
	if animateData[1].startFrame ~= 0 then
		ui:setVisible(false)
		actions:addObject(CCDelayTime:create(animateData[1].startFrame/24))
		actions:addObject(CCShow:create())
	end

	if animateData[1].x and animateData[1].y then
		ui:setPositionX(animateData[1].x)
		ui:setPositionY(-animateData[1].y)
	end
	if animateData[1].scaleX and animateData[1].scaleY then
		ui:setScaleX(animateData[1].scaleX)
		ui:setScaleX(animateData[1].scaleY)
	end
	if animateData[1].opacity then
		ui:setOpacity(animateData[1].opacity)
	end

	for i=2,#animateData do
		local d = animateData[i - 1].duration / 24
		local t = {}
		if animateData[i].x and animateData[i].y then
			table.insert(t,CCMoveTo:create(d,ccp(animateData[i].x,-animateData[i].y)))
		end
		if animateData[i].scaleX and animateData[i].scaleY then
			table.insert(t,CCScaleTo:create(d,animateData[i].scaleX,animateData[i].scaleY))
		end
		if animateData[i].opacity then
			table.insert(t,CCFadeTo:create(d,animateData[i].opacity))
		end

		if #t == 1 then
			actions:addObject(t[1])
		else
			local spawnActions = CCArray:create()
			for k,v in pairs(t) do
				spawnActions:addObject(v)
			end
			actions:addObject(CCSpawn:create(spawnActions))
		end
	end

	return CCSequence:create(actions)
end


local dotAnimateDatas={
[1] = {
    { startFrame=0,duration=6,scaleX=0.40,scaleY=0.40,x=15.65,y=-27.15,},
    { startFrame=6,duration=12,scaleX=0.64,scaleY=0.64,x=15.00,y=-13.35,},
    { startFrame=18,duration=1,scaleX=0.24,scaleY=0.24,x=16.75,y=-0.30,},
},
[2] = {
    { startFrame=0,duration=6,scaleX=0.40,scaleY=0.40,x=41.45,y=-106.40,},
    { startFrame=6,duration=12,scaleX=0.64,scaleY=0.64,x=52.25,y=-124.45,},
    { startFrame=18,duration=1,scaleX=0.24,scaleY=0.24,x=61.55,y=-130.75,},
},
[3] = {
    { startFrame=0,duration=6,scaleX=0.25,scaleY=0.25,x=-30.25,y=-84.75,},
    { startFrame=6,duration=12,scaleX=0.50,scaleY=0.50,x=-49.35,y=-88.05,},
    { startFrame=18,duration=1,scaleX=0.00,scaleY=0.00,x=-64.40,y=-88.05,},
},
[4] = {
    { startFrame=0,duration=6,scaleX=0.74,scaleY=0.74,x=-25.55,y=-47.50,},
    { startFrame=6,duration=12,scaleX=0.75,scaleY=0.75,x=-54.10,y=-39.00,},
    { startFrame=18,duration=1,scaleX=0.44,scaleY=0.44,x=-76.20,y=-34.00,},
},
[5] = {
    { startFrame=0,duration=6,scaleX=0.47,scaleY=0.47,x=-27.40,y=-110.05,},
    { startFrame=6,duration=12,scaleX=0.75,scaleY=0.75,x=-39.10,y=-123.05,},
    { startFrame=18,duration=1,scaleX=0.28,scaleY=0.28,x=-43.75,y=-128.95,},
},
[6] = {
    { startFrame=0,duration=6,scaleX=0.52,scaleY=0.52,x=54.40,y=-104.95,},
    { startFrame=6,duration=12,scaleX=0.84,scaleY=0.84,x=73.25,y=-112.70,},
    { startFrame=18,duration=1,scaleX=0.31,scaleY=0.31,x=89.35,y=-115.60,},
},
[7] = {
    { startFrame=0,duration=6,scaleX=0.30,scaleY=0.30,x=-14.80,y=-112.25,},
    { startFrame=6,duration=12,scaleX=0.48,scaleY=0.48,x=-15.70,y=-123.40,},
    { startFrame=18,duration=1,scaleX=0.18,scaleY=0.18,x=-13.90,y=-130.75,},
},
[8] = {
    { startFrame=0,duration=6,scaleX=0.40,scaleY=0.40,x=-28.80,y=-56.55,},
    { startFrame=6,duration=12,scaleX=0.51,scaleY=0.51,x=-45.15,y=-54.55,},
    { startFrame=18,duration=1,scaleX=0.24,scaleY=0.24,x=-60.60,y=-51.10,},
},
[9] = {
    { startFrame=0,duration=6,scaleX=0.40,scaleY=0.40,x=57.10,y=-62.15,},
    { startFrame=6,duration=12,scaleX=0.51,scaleY=0.51,x=65.85,y=-63.05,},
    { startFrame=18,duration=1,scaleX=0.24,scaleY=0.24,x=90.50,y=-61.60,},
},
[10] = {
    { startFrame=0,duration=6,scaleX=0.74,scaleY=0.74,x=55.45,y=-42.35,},
    { startFrame=6,duration=12,scaleX=0.94,scaleY=0.94,x=73.75,y=-36.10,},
    { startFrame=18,duration=1,scaleX=0.44,scaleY=0.44,x=86.65,y=-30.90,},
},
}
function HiddenBranchAnimation:buildReceiveAnim( reward,box )

	local actions = CCArray:create()

	local whiteBox = Sprite:createWithSpriteFrameName("hide_reward_box_white0000")
	whiteBox:setAnchorPoint(box:getAnchorPoint())
	whiteBox:setRotation(box:getRotation())
	whiteBox:setPositionY(box:getPositionY())
    whiteBox:setPositionX(box:getPositionX())
	reward:addChild(whiteBox)

	whiteBox:setVisible(true)
	whiteBox:setOpacity(0)
	local whiteBoxActions = CCArray:create()
	whiteBoxActions:addObject(CCFadeIn:create(3/24))
	whiteBoxActions:addObject(CCFadeOut:create(2/24))
	whiteBoxActions:addObject(CCCallFunc:create(function( ... )
		whiteBox:removeFromParentAndCleanup(true)
	end))
	actions:addObject(CCTargetedAction:create(
		whiteBox.refCocosObj,
		CCSequence:create(whiteBoxActions)
	))

	local boxActions = CCArray:create()
	boxActions:addObject(CCSpawn:createWithTwoActions(
		CCScaleTo:create(3/24,1.1,1.1),
		CCFadeOut:create(3/24)
	))
	boxActions:addObject(CCSpawn:createWithTwoActions(
		CCScaleTo:create(2/24,1,1),
		CCFadeIn:create(2/24)
	))
	boxActions:addObject(CCFadeOut:create(1/24))
	actions:addObject(CCTargetedAction:create(
		box.refCocosObj,
		CCSequence:create(boxActions)
	))
		
	for k,v in pairs(dotAnimateDatas) do
		local dot = Sprite:createWithSpriteFrameName("hide_reward_dot0000")
		reward:addChild(dot)

		dot:setVisible(false)

		local dotActions = CCArray:create()
		dotActions:addObject(CCDelayTime:create(4/24))
		dotActions:addObject(CCShow:create())
		dotActions:addObject(self:buildDataAnim(dot,v))
		dotActions:addObject(CCCallFunc:create(function( ... )
			dot:removeFromParentAndCleanup(true)
		end))
	
		actions:addObject(CCTargetedAction:create(
			dot.refCocosObj,
			CCSequence:create(dotActions)
		))
	end

	return CCSpawn:create(actions)
end


local unlockCloudAnimateDatas={
[1] = {
    { startFrame=0,duration=3,scaleX=0.72,scaleY=0.72,x=-19.05,y=-12.70,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.32,scaleY=1.32,x=-31.55,y=-70.60,opacity=255,},
    { startFrame=5,duration=5,scaleX=1.04,scaleY=1.04,x=-24.65,y=-68.45,opacity=255,},
    { startFrame=10,duration=9,scaleX=0.79,scaleY=0.79,x=-16.95,y=-69.40,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=0.79,scaleY=0.79,x=-16.40,y=-69.75,opacity=25.5,},
},
[2] = {
    { startFrame=0,duration=3,scaleX=0.89,scaleY=0.89,x=-9.75,y=-28.45,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.49,scaleY=1.49,x=5.85,y=-67.50,opacity=255,},
    { startFrame=5,duration=5,scaleX=1.19,scaleY=1.19,x=16.30,y=-63.60,opacity=255,},
    { startFrame=10,duration=9,scaleX=0.99,scaleY=0.99,x=26.80,y=-59.80,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=1.00,scaleY=1.00,x=27.85,y=-58.05,opacity=25.5,},
},
[3] = {
    { startFrame=0,duration=3,scaleX=0.55,scaleY=0.55,x=-22.70,y=-15.05,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.00,scaleY=1.00,x=-66.75,y=-16.25,opacity=255,},
    { startFrame=5,duration=5,scaleX=0.80,scaleY=0.80,x=-66.80,y=-13.30,opacity=255,},
    { startFrame=10,duration=9,scaleX=0.67,scaleY=0.67,x=-70.30,y=-8.10,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=0.67,scaleY=0.67,x=-71.90,y=-5.70,opacity=25.5,},
},
[4] = {
    { startFrame=0,duration=3,scaleX=0.76,scaleY=0.76,x=-2.60,y=-15.95,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.12,scaleY=1.12,x=15.55,y=9.35,opacity=255,},
    { startFrame=5,duration=5,scaleX=0.90,scaleY=0.90,x=26.00,y=16.55,opacity=255,},
    { startFrame=10,duration=9,scaleX=0.75,scaleY=0.75,x=33.00,y=25.70,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=0.75,scaleY=0.75,x=35.25,y=30.30,opacity=25.5,},
},
[5] = {
    { startFrame=0,duration=3,scaleX=0.94,scaleY=0.94,x=-27.45,y=-10.35,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.21,scaleY=1.21,x=-67.20,y=8.10,opacity=255,},
    { startFrame=5,duration=5,scaleX=0.97,scaleY=0.97,x=-66.15,y=16.40,opacity=255,},
    { startFrame=10,duration=9,scaleX=0.81,scaleY=0.81,x=-64.25,y=21.25,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=0.81,scaleY=0.81,x=-66.20,y=22.80,opacity=25.5,},
},
[6] = {
    { startFrame=0,duration=3,scaleX=1.00,scaleY=1.00,x=-14.20,y=-10.60,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.50,scaleY=1.50,x=-35.35,y=13.40,opacity=255,},
    { startFrame=5,duration=5,scaleX=1.20,scaleY=1.20,x=-27.35,y=24.70,opacity=255,},
    { startFrame=10,duration=9,scaleX=1.00,scaleY=1.00,x=-23.00,y=33.10,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=1.00,scaleY=1.00,x=-24.00,y=34.95,opacity=25.5,},
},
[7] = {
    { startFrame=0,duration=3,scaleX=0.89,scaleY=0.89,x=-9.75,y=-28.45,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.34,scaleY=1.34,x=17.60,y=-28.80,opacity=255,},
    { startFrame=5,duration=5,scaleX=1.07,scaleY=1.07,x=30.80,y=-23.40,opacity=255,},
    { startFrame=10,duration=9,scaleX=0.89,scaleY=0.89,x=42.40,y=-16.45,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=0.89,scaleY=0.89,x=43.75,y=-14.00,opacity=25.5,},
},
[8] = {
    { startFrame=0,duration=3,scaleX=1.00,scaleY=1.00,x=-26.45,y=-34.60,opacity=255,},
    { startFrame=3,duration=2,scaleX=1.50,scaleY=1.50,x=-73.05,y=-57.95,opacity=255,},
    { startFrame=5,duration=5,scaleX=1.20,scaleY=1.20,x=-68.90,y=-56.15,opacity=255,},
    { startFrame=10,duration=9,scaleX=1.00,scaleY=1.00,x=-68.50,y=-52.85,opacity=124.95,},
    { startFrame=19,duration=1,scaleX=1.00,scaleY=1.00,x=-72.50,y=-49.05,opacity=25.5,},
},
}

local unlockStarAnimateDatas={
[1] = {
    { startFrame=0,duration=10,scaleX=0.71,scaleY=0.71,x=146.95,y=8.95,opacity=0.00,},
    { startFrame=10,duration=3,scaleX=0.71,scaleY=0.71,x=146.95,y=8.95,opacity=0.00,},
    { startFrame=13,duration=7,scaleX=0.71,scaleY=0.71,x=146.95,y=1.95,opacity=127.50,},
    { startFrame=20,duration=1,scaleX=0.71,scaleY=0.71,x=146.95,y=1.95,opacity=0.00,},
},
[2] = {
    { startFrame=0,duration=9,scaleX=0.71,scaleY=0.71,x=176.45,y=28.55,opacity=0.00,},
    { startFrame=9,duration=3,scaleX=0.71,scaleY=0.71,x=176.45,y=28.55,opacity=0.00,},
    { startFrame=12,duration=7,scaleX=0.71,scaleY=0.71,x=176.45,y=21.55,opacity=127.50,},
    { startFrame=19,duration=1,scaleX=0.71,scaleY=0.71,x=176.45,y=21.55,opacity=0.00,},
},
[3] = {
    { startFrame=0,duration=8,scaleX=0.71,scaleY=0.71,x=110.20,y=-11.55,opacity=0.00,},
    { startFrame=8,duration=3,scaleX=0.71,scaleY=0.71,x=110.20,y=-11.55,opacity=0.00,},
    { startFrame=11,duration=7,scaleX=0.71,scaleY=0.71,x=110.20,y=-18.55,opacity=127.50,},
    { startFrame=18,duration=1,scaleX=0.71,scaleY=0.71,x=110.20,y=-18.55,opacity=0.00,},
},
[4] = {
    { startFrame=0,duration=7,scaleX=0.71,scaleY=0.71,x=146.95,y=8.95,opacity=0.00,},
    { startFrame=7,duration=3,scaleX=0.71,scaleY=0.71,x=146.95,y=8.95,opacity=0.00,},
    { startFrame=10,duration=7,scaleX=0.71,scaleY=0.71,x=146.95,y=1.95,opacity=127.50,},
    { startFrame=17,duration=1,scaleX=0.71,scaleY=0.71,x=146.95,y=1.95,opacity=0.00,},
},
[5] = {
    { startFrame=0,duration=6,scaleX=0.71,scaleY=0.71,x=146.95,y=8.95,opacity=0.00,},
    { startFrame=6,duration=3,scaleX=0.71,scaleY=0.71,x=146.95,y=8.95,opacity=0.00,},
    { startFrame=9,duration=7,scaleX=0.71,scaleY=0.71,x=146.95,y=1.95,opacity=127.50,},
    { startFrame=16,duration=1,scaleX=0.71,scaleY=0.71,x=146.95,y=1.95,opacity=0.00,},
},
[6] = {
    { startFrame=0,duration=5,scaleX=0.89,scaleY=0.89,x=120.95,y=14.90,opacity=0.00,},
    { startFrame=5,duration=3,scaleX=0.89,scaleY=0.89,x=120.95,y=14.90,opacity=0.00,},
    { startFrame=8,duration=7,scaleX=0.89,scaleY=0.89,x=120.95,y=6.00,opacity=193.80,},
    { startFrame=15,duration=1,scaleX=0.89,scaleY=0.89,x=120.95,y=6.00,opacity=0.00,},
},
[7] = {
    { startFrame=0,duration=4,scaleX=0.89,scaleY=0.89,x=90.95,y=7.90,opacity=0.00,},
    { startFrame=4,duration=3,scaleX=0.89,scaleY=0.89,x=90.95,y=7.90,opacity=0.00,},
    { startFrame=7,duration=7,scaleX=0.89,scaleY=0.89,x=90.95,y=-1.00,opacity=255.00,},
    { startFrame=14,duration=1,scaleX=0.89,scaleY=0.89,x=90.95,y=-1.00,opacity=0.00,},
},
[8] = {
    { startFrame=3,duration=3,scaleX=0.77,scaleY=0.77,x=72.25,y=18.25,opacity=0.00,},
    { startFrame=6,duration=7,scaleX=0.77,scaleY=0.77,x=72.25,y=10.60,opacity=198.90,},
    { startFrame=13,duration=8,scaleX=0.77,scaleY=0.77,x=72.25,y=10.60,opacity=0.00,},
},
[9] = {
    { startFrame=2,duration=3,scaleX=0.77,scaleY=0.77,x=38.60,y=1.15,opacity=0.00,},
    { startFrame=5,duration=7,scaleX=0.77,scaleY=0.77,x=38.60,y=-6.50,opacity=255.00,},
    { startFrame=12,duration=9,scaleX=0.77,scaleY=0.77,x=38.60,y=-6.50,opacity=0.00,},
},
[10] = {
    { startFrame=1,duration=3,scaleX=0.89,scaleY=0.89,x=105.50,y=35.00,opacity=0.00,},
    { startFrame=4,duration=7,scaleX=0.89,scaleY=0.89,x=105.50,y=26.10,opacity=201.45,},
    { startFrame=11,duration=10,scaleX=0.89,scaleY=0.89,x=105.50,y=26.10,opacity=0.00,},
},
[11] = {
    { startFrame=0,duration=3,scaleX=0.89,scaleY=0.89,x=7.95,y=18.15,opacity=0.00,},
    { startFrame=3,duration=7,scaleX=0.89,scaleY=0.89,x=7.95,y=9.25,opacity=255.00,},
    { startFrame=10,duration=11,scaleX=0.89,scaleY=0.89,x=7.95,y=9.25,opacity=0.00,},
},
}


function HiddenBranchAnimation:buildUnlockAnim( cloud,branch )

	local actions = CCArray:create()

	local cloudContainer = Sprite:createEmpty()
	cloudContainer:setTexture(cloud:getTexture())
	cloudContainer:setPositionX(cloud:getContentSize().width/2)
	cloudContainer:setPositionY(cloud:getContentSize().height/2)
	cloudContainer:setScaleX(2.25)
	cloudContainer:setScaleY(2.20)
	cloud:addChild(cloudContainer)

	for k,v in pairs(unlockCloudAnimateDatas) do
		local miniCloud = Sprite:createWithSpriteFrameName("hide_cloud_20000")
		miniCloud:setAnchorPoint(ccp(0,1))
		miniCloud:setVisible(false)

		cloudContainer:addChild(miniCloud)

		local cloudActions = CCArray:create()
		cloudActions:addObject(CCDelayTime:create(2/24))
		cloudActions:addObject(CCShow:create())
		cloudActions:addObject(self:buildDataAnim(miniCloud,v))
		cloudActions:addObject(CCCallFunc:create(function( ... )
			miniCloud:removeFromParentAndCleanup(true)
		end))

		actions:addObject(CCTargetedAction:create(
			miniCloud.refCocosObj,
			CCSequence:create(cloudActions)
		))
	end

	local starContainers = {}

	local offsets = { ccp(30,130),ccp(230,200) }
	for i=1,2 do
		starContainers[i] = Sprite:createEmpty()
		starContainers[i]:setTexture(branch.refCocosObj:getTexture())
		starContainers[i]:setScaleX(1.35)
		starContainers[i]:setScaleY(1.35)
		starContainers[i]:setPosition(offsets[i])
		branch:addChild(starContainers[i])
	end

	local starDelayTimes = {20,29}
	for i=1,2 do
		for k,v in pairs(unlockStarAnimateDatas) do
			local star = Sprite:createWithSpriteFrameName("hide_cloud_star0000")
			star:setAnchorPoint(ccp(0,1))
			star:setVisible(false)

			starContainers[i]:addChild(star)

			local starActions = CCArray:create()
			starActions:addObject(CCDelayTime:create(starDelayTimes[i]/24))
			starActions:addObject(CCShow:create())
			starActions:addObject(self:buildDataAnim(star,v))
			starActions:addObject(CCCallFunc:create(function( ... )
				star:removeFromParentAndCleanup(true)
			end))

			actions:addObject(CCTargetedAction:create(
				star.refCocosObj,
				CCSequence:create(starActions)
			))
		end
	end

	return CCSequence:createWithTwoActions(
		CCSpawn:create(actions),
		CCCallFunc:create(function( ... )
			cloudContainer:removeFromParentAndCleanup(true)
			starContainers[1]:removeFromParentAndCleanup(true)
			starContainers[2]:removeFromParentAndCleanup(true)
		end)
	)
end