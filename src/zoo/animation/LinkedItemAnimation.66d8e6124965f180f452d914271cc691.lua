require "hecore.display.Director"

local kCharacterAnimationTime = 1/24

LinkedItemAnimation = class()

function LinkedItemAnimation:buildPortalEnter(colorId , gravity)
    local sprite = Sprite:createWithSpriteFrameName("portal_"..colorId.."_0060")
	  local frames = SpriteUtil:buildFrames("portal_"..colorId.."_%04d", 0, 61, true)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    sprite:play(animate)
    
  	
    local sprite2 = Sprite:createWithSpriteFrameName("portal_star_0040")
    local frames2 = SpriteUtil:buildFrames("portal_star_%04d", 0, 41, true)
    local animate2 = SpriteUtil:buildAnimate(frames2, kCharacterAnimationTime)
    sprite2:play(animate2)
    
    if gravity == BoardGravityDirection.kDown then
        sprite:setRotation(180)
    elseif gravity == BoardGravityDirection.kUp then
        sprite:setRotation(0)
    elseif gravity == BoardGravityDirection.kLeft then
        sprite:setRotation(-90)
    else
        sprite:setRotation(90)
    end
    sprite2:setPositionXY(37, 6)
    sprite:addChild(sprite2)

  	return sprite
end

function LinkedItemAnimation:buildPortalExit(colorId , gravity)
	  local sprite = Sprite:createWithSpriteFrameName("portal_"..colorId.."_0000") 
	  local frames = SpriteUtil:buildFrames("portal_"..colorId.."_%04d", 0, 61)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    sprite:play(animate)

    local sprite2 = Sprite:createWithSpriteFrameName("portal_star_0000")
    local frames2 = SpriteUtil:buildFrames("portal_star_%04d", 0, 41)
    local animate2 = SpriteUtil:buildAnimate(frames2, kCharacterAnimationTime)
    sprite2:play(animate2)
    
    if gravity == BoardGravityDirection.kDown then
        sprite:setRotation(0)
    elseif gravity == BoardGravityDirection.kUp then
        sprite:setRotation(180)
    elseif gravity == BoardGravityDirection.kLeft then
        sprite:setRotation(90)
    else
        sprite:setRotation(-90)
    end
    sprite2:setPositionXY(37, 6)
    sprite:addChild(sprite2)

  	return sprite
end

function LinkedItemAnimation:buildPortalBoth(enterColorId, exitColorId , gravity)
	  local sprite2 = self:buildPortalEnter(enterColorId , BoardGravityDirection.kDown) -- sprite2被addChild到sprite1里面了，所以一律方向为下，真正的旋转是sprite1基于gravity实现的
	  local sprite1 = self:buildPortalExit(exitColorId , gravity)
	  sprite2:setPositionXY(37, -40)
	  sprite1:addChild(sprite2)
	  return sprite1;
end
