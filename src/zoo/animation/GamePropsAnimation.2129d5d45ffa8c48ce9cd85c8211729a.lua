require "hecore.display.Director"

--原谅我英语不好，加个注释--------这是游戏道具，例如 锤子

local kPropsAnimationTime = 1/26
local kHammerAnimationTime = 14
local kLineBrush = 25

GamePropsAnimation = class()

function GamePropsAnimation:buildMagicWind()
  local node = CocosObject:create()
  node.name = ""

  local sprite = Sprite:createWithSpriteFrameName("magic_wind0000")
  local frames = SpriteUtil:buildFrames("magic_wind%04d", 0, 25)
  local animate = SpriteUtil:buildAnimate(frames, kPropsAnimationTime)

  local function onRepeatFinishCallback()
    sprite:dp(Event.new(Events.kComplete, nil, sprite))
  end
  --sprite:play(animate)
  sprite:play(animate, 0, 1, onRepeatFinishCallback)
  return sprite
end

function GamePropsAnimation:buildHammer()
  local node = CocosObject:create()
  node.name = "prop_hammer"
  node.touchEnabled = false
  node.touchChildren = false

	local sprite = Sprite:createWithSpriteFrameName("hammer0000")
  node:addChild(sprite)

	local frames = SpriteUtil:buildFrames("hammer%04d", 0, 14)
	local animate = SpriteUtil:buildAnimate(frames, kPropsAnimationTime)

	local function onRepeatFinishCallback()
		sprite:dp(Event.new(Events.kComplete, nil, sprite))
	end
	--sprite:play(animate) 
	sprite:play(animate, 0, 1, onRepeatFinishCallback)
	return sprite
end