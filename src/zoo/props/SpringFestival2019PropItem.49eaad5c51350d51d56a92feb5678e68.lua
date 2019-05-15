require 'zoo.props.PropListItem'
require "zoo.animation.SpringFestivalAnimation"
local WeeklyDazhaoBuyPanel = require "zoo.modules.weekly2017s1.WeeklyDazhaoBuyPanel"
local SpringFestival2019SkillPanel = require 'zoo.localActivity.SpringFestival2019.SpringFestival2019SkillPanel'
local UIHelper = require 'zoo.panel.UIHelper'

SpringFestival2019PropItem = class(BaseUI)

function SpringFestival2019PropItem:create(propListAnimation)
    local instance = SpringFestival2019PropItem.new()
    instance:init(propListAnimation)
    return instance
end

function SpringFestival2019PropItem:init(propListAnimation)
    self.usedTimes = 0

    self.animHummerIsRun = false

    self.propListAnimation = propListAnimation
    self.controller = propListAnimation.controller
    self.icon = self:buildItemIcon()
    BaseUI.init(self, self.icon)
end

function SpringFestival2019PropItem:buildItemIcon()
    local icon = SpringFestivalAnimation:buildItemIcon()
    return icon
end

function SpringFestival2019PropItem:ShowChildLayer()
    --展开技能树
    local SpringFestival2019SkillPanel = SpringFestival2019SkillPanel:create()
    if SpringFestival2019SkillPanel then
    	SpringFestival2019SkillPanel:setExitCallback(function( ... )
            self.SpringFestival2019SkillPanel = nil
    	end)
    	SpringFestival2019SkillPanel:popout() 
        self.SpringFestival2019SkillPanel = SpringFestival2019SkillPanel

        SpringFestival2019Manager.getInstance():DC( "stage","5years_click_skill")

        self.icon:skillTipHide()

        self:HideRedPoint()
    end
end

function SpringFestival2019PropItem:use()
    self:ShowChildLayer()
end

function SpringFestival2019PropItem:isItemRequireConfirm()
    return false
end

function SpringFestival2019PropItem:getItemCenterPosition()
  local position = self.icon:convertToWorldSpace(self.icon.bubble:getPosition())
  return position
end

function SpringFestival2019PropItem:PlayFullAnim( )
    self.icon:skillTipShow()
end

function SpringFestival2019PropItem:ShowRedPointAndUpdate( Num )
    if Num > 0 then
        local ShowStr = ""..Num
        if Num > 99 then ShowStr = "99+" end
        self.icon.redPoint_sprite:setVisible(true)
        self.icon.poingNumLabel:setText(ShowStr)
    else
        self:HideRedPoint()
    end
end

function SpringFestival2019PropItem:HideRedPoint( )
    self.icon.redPoint_sprite:setVisible(false)
end

function SpringFestival2019PropItem:playFlyNut(callback)
    if self.isDisposed then return end
    if not self.icon then return end
    if not self.icon.SkillIcon then return end
    if self.flyAnim then return end

    FrameLoader:loadImageWithPlist("flash/Spring2019Guide.plist")
    
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local scene = Director:sharedDirector():getRunningScene()
    if not scene then return end
    local container = Layer:create()

    local nut
    local goldNut
    nut = Sprite:createWithSpriteFrameName('spring2019_normal_item_0000.png')
    goldNut = Sprite:createWithSpriteFrameName('spring2019_gold_item_0000.png')

    local resName = 'SpringFestival2019_anim/ani_2'
	local comet = UIHelper:createArmature2('skeleton/springFestival2019Anim', resName)
    local cricle = Sprite:createWithSpriteFrameName('spring2019_item_circle_0000.png')
    local bg = Sprite:createWithSpriteFrameName('spring2019_item_bg_0000.png')
    local bg_star = Sprite:createWithSpriteFrameName('spring2019_item_bg_star_0000.png')

    container:addChild(bg)
    bg:setPosition(ccp(-5, -2))
    container:addChild(bg_star)
    container:addChild(cricle)
    container:addChild(comet)
    container:addChild(nut)
    container:addChild(goldNut)
    goldNut:setOpacity(0)
--    comet:setAnchorPoint(ccp(0.5, 0.5))
--    comet:setPosition(ccp(-50, 50))
    local startPos = self.icon.SkillIcon:getParent():convertToWorldSpace(self.icon.SkillIcon:getPosition())
    scene:addChild(container)
    container:setPosition(scene:convertToNodeSpace(startPos))

    comet:addEventListener(ArmatureEvents.COMPLETE, function()
            comet:removeAllEventListeners()
    	    comet:play("b")
        end)
    comet:play("a",1 )
   
    local destPos = ccp(vo.x+vs.width/2, vo.y+vs.height/2)

     --旋转
    local rotation = 0
	if destPos.y - startPos.y > 0 then
		rotation = math.deg(math.atan((destPos.x - startPos.x)/(destPos.y - startPos.y)))
	elseif destPos.y -startPos.y < 0 then
		rotation = 180 + math.deg(math.atan((destPos.x - startPos.x) / (destPos.y - startPos.y)))
	else
		if destPos.x - startPos.x > 0 then rotation = 90
		else
			rotation = -90
		end
	end
    comet:setRotation( rotation )

    local function remove()
        if container then 
            container:removeFromParentAndCleanup(true)
            container = nil
            self.flyAnim = nil
        end
        if callback then callback() end

        FrameLoader:unloadImageWithPlists("flash/Spring2019Guide.plist")
    end

    local function onArrive()
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("spring2019_item_circle_%04d.png", 0, 16), 1/30)
        cricle:play(animate, 0, 1, remove)            
    end

      
    local function onWait()
        comet:addEventListener(ArmatureEvents.COMPLETE, function()
            comet:removeAllEventListeners()
            comet:setVisible(false)
        end)
        comet:play("c",1 )

        goldNut:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5*0.75, 255), CCFadeTo:create(0.5*0.75, 0)), 2))
        local arr_bg = CCArray:create()
        arr_bg:addObject(CCScaleTo:create(0.1*0.75, 1))  
        arr_bg:addObject(CCDelayTime:create(1.85*0.75))
        arr_bg:addObject(CCScaleTo:create(0.05*0.75, 0))
        bg:runAction(CCSequence:create(arr_bg))
        bg:runAction(CCRotateBy:create(3, 180))
        bg_star:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.4*0.75, 1), CCHide:create()))
    end

    bg:setScale(0)
    bg_star:setScale(0)

    local scaleFactor = 1.2
    local arr = CCArray:create()
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(13/24, 1.5 ), CCEaseSineOut:create(CCMoveTo:create(13/24, destPos))))
    arr:addObject(CCCallFunc:create(onWait))
    arr:addObject(CCDelayTime:create(2*0.75))
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(13/24, 1 ), CCEaseSineIn:create(CCMoveTo:create(13/24, startPos))))
    arr:addObject(CCCallFunc:create(onArrive))
    container:runAction(CCSequence:create(arr))
    self.flyAnim = container

end 