TileJamSperad = class(Sprite)

function TileJamSperad:create(texture, bAnim )
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileJamSperad.new(sprite)
	node.parentTexture = texture

    node:createJamSperad( bAnim )
	return node
end

function TileJamSperad:createJamSperad( bAnim )

    if bAnim == nil then
        bAnim = false
    end

    if bAnim then
        local JamSperad = Sprite:createWithSpriteFrameName("JamSperad_JamSperad_0000.png")
        JamSperad:setPosition( ccp(0,0) )
        JamSperad:setScale(1)

        local frames = SpriteUtil:buildFrames("JamSperad_JamSperad_".."%04d.png", 0, 8)
        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
        JamSperad:play( animate, 0, 1 )

        self:addChild( JamSperad )
    else
        local JamSperad = Sprite:createWithSpriteFrameName("JamSperad_JamSperad_0007.png")
        JamSperad:setPosition( ccp(0,0) )
        JamSperad:setScale(1)

        self:addChild( JamSperad )
    end

--    local mainLogic = GameBoardLogic:getCurrentLogic()
--	if mainLogic and mainLogic.PlayUIDelegate then
--        mainLogic.PlayUIDelegate:setTargetNumber( 0,0,0, ccp(0,0) )
--    end
end
