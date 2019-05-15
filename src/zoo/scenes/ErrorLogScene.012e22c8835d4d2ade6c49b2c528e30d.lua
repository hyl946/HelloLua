require "hecore.display.TextField"
require "hecore.display.Scene"
require "hecore.display.Director"
require "zoo.util.ClipBoardUtil"

assert(Scene)
local ErrorLogScene = class(Scene)

function ErrorLogScene:init(crashMsg)
  Scene.initScene(self)

  local vSize = Director:sharedDirector():getVisibleSize()
  local vOrigin = Director:sharedDirector():getVisibleOrigin()

  local l = LayerColor:create()
  l:setColor(ccc3(0, 0, 0))
  l:changeWidthAndHeight(vSize.width, vSize.height)
  l:setPosition(ccp(vOrigin.x, vOrigin.y))
  l:setTouchEnabled(true)
  self:addChild(l)

  local margin = 10
  local textWidth = vSize.width - margin * 2
  local textHeight = vSize.height - margin * 2
  local textInitPosX = margin
  local textInitPosY = textHeight + margin

  local textView = TextField:create("", nil, 28, CCSizeMake(textWidth, 0))
  textView:ignoreAnchorPointForPosition(false)
  textView:setAnchorPoint(ccp(0,1))
  textView:setPosition(ccp(textInitPosX, textInitPosY))
  local msg = crashMsg or debug.traceback()
  textView:setString(msg)
  l:addChild(textView)

  local tSize = textView:getContentSize()

  local minPosY = textInitPosY
  local maxPosY = textInitPosY + tSize.height - textHeight + 150
  if maxPosY < minPosY then maxPosY = minPosY end

  local prePos = nil
  local function onTouchEvent( evt )
    local pos = evt.globalPosition
    if evt.name == DisplayEvents.kTouchBegin then
      prePos = pos
    elseif evt.name == DisplayEvents.kTouchEnd then
      prePos = nil
    elseif evt.name == DisplayEvents.kTouchMove then 
      local tPos = textView:getPosition()
      local newPosY = tPos.y + (pos.y - prePos.y)
      if newPosY < minPosY then newPosY = minPosY end
      if newPosY > maxPosY then newPosY = maxPosY end

      textView:setPosition(ccp(tPos.x, newPosY))
      prePos = pos
    end
  end
  l:addEventListener(DisplayEvents.kTouchBegin, onTouchEvent)
  l:addEventListener(DisplayEvents.kTouchEnd, onTouchEvent)
  l:addEventListener(DisplayEvents.kTouchMove, onTouchEvent)

  local closeBtn = LayerColor:create()
  closeBtn:setColor(ccc3(0, 155, 255))
  closeBtn:changeWidthAndHeight(120, 80)
  local exitLabel = TextField:create("EXIT", nil, 40)
  exitLabel:setPosition(ccp(60, 40))
  closeBtn:addChild(exitLabel)

  closeBtn:setPosition(ccp(vOrigin.x + vSize.width - 180, vOrigin.y + 20))
  closeBtn:setTouchEnabled(true, -999, true)
  local function onExitBtnTapped(evt)
    if evt.name == DisplayEvents.kTouchBegin then
      closeBtn:setOpacity(255 * 0.6)
    elseif evt.name == DisplayEvents.kTouchEnd then
      closeBtn:setOpacity(255)
      local pos = evt.globalPosition
      if closeBtn:hitTestPoint(pos, true) then
        Director.sharedDirector():exitGame()
      end
    end
  end
  closeBtn:addEventListener(DisplayEvents.kTouchEnd, onExitBtnTapped)
  closeBtn:addEventListener(DisplayEvents.kTouchBegin, onExitBtnTapped)
  self:addChild(closeBtn)

  local copyBtn = LayerColor:create()
  copyBtn:setColor(ccc3(0, 155, 255))
  copyBtn:changeWidthAndHeight(120, 80)
  local copyLabel = TextField:create("COPY", nil, 40)
  copyLabel:setPosition(ccp(60, 40))
  copyBtn:addChild(copyLabel)

  copyBtn:setPosition(ccp(vOrigin.x + vSize.width - 340, vOrigin.y + 20))
  copyBtn:setTouchEnabled(true, -999, true)
  local function onCopyBtnTapped(evt)
    if evt.name == DisplayEvents.kTouchBegin then
      copyBtn:setOpacity(255 * 0.6)
    elseif evt.name == DisplayEvents.kTouchEnd then
      copyBtn:setOpacity(255)
      local pos = evt.globalPosition
      if copyBtn:hitTestPoint(pos, true) then

        ClipBoardUtil.copyText(msg.."\nTime: "..os.date("%Y/%m/%d %H:%M:%S"))
      end
    end
  end
  copyBtn:addEventListener(DisplayEvents.kTouchEnd, onCopyBtnTapped)
  copyBtn:addEventListener(DisplayEvents.kTouchBegin, onCopyBtnTapped)
  self:addChild(copyBtn)

  if GamePlayMusicPlayer then -- stop all music
    GamePlayMusicPlayer:getInstance():appPause()
  end
end

function ErrorLogScene:create(crashMsg)
  local s = ErrorLogScene.new()
  s:init(crashMsg)
  return s
end

return ErrorLogScene