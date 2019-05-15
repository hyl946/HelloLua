require "zoo.panel.share.sharePanelVerB.shareLevelSuccess.ShareLevelSuccessPanel"

local ShareLevelSuccessButtonUtil = {}

local ShareLevelSuccessButtonTiltKey = "share_level_success_button_tilt_key"

function ShareLevelSuccessButtonUtil:canShow()
    
    local isTest = true
    if isTest then return true end

    if PublishActUtil:isGroundPublish() then
        return false
    end
    if LevelType.isShareEnable(self.levelType) and not PlatformConfig:isPlayDemo() then
        return true
    else
        return false
    end
end

function ShareLevelSuccessButtonUtil:init(buttonUi, levelId, stars, score)
    self.iconBtn = buttonUi:getChildByName("icon")
    local function onIconBtnTapped(event)
        local panel = ShareLevelSuccessPanel:create(levelId, stars, score)
        if panel then 
            DcUtil:UserTrack({
                category = "show", 
                sub_category = "show_off_button", 
                t1 = levelId,
                t2 = stars,
                t3 = panel.levelTypeId
            })
            panel:popout()
            self.iconBtn:getChildByName('iconShape'):stopAllActions()
            CCUserDefault:sharedUserDefault():setBoolForKey(ShareLevelSuccessButtonTiltKey, true)
            CCUserDefault:sharedUserDefault():flush()
        else
            -- 非正常数据
        end
    end
    self.iconBtn:setTouchEnabled(true, 0 ,true)
    self.iconBtn:setButtonMode(true)
    self.iconBtn:addEventListener(DisplayEvents.kTouchTap, onIconBtnTapped)

    if not CCUserDefault:sharedUserDefault():getBoolForKey(ShareLevelSuccessButtonTiltKey, false)
    then
        local iconImg = self.iconBtn:getChildByName('iconShape')
        local iconImgSize = iconImg:getGroupBounds().size
        iconImg:setAnchorPoint(ccp(0.5,0.5))
        iconImg:setPosition(ccp(iconImgSize.width/2, - iconImgSize.height/2))
        self:setStartTilt(iconImg, 0.5)
    end
end

function ShareLevelSuccessButtonUtil:setStartTilt(ui, durationTime) --晃动图标
    if not ui then return end
    ui:stopAllActions()

	local action_rotation_1 = CCRotateTo:create(0.1, -8.7)
	local action_rotation_2 = CCRotateTo:create(0.1, 9.2 )
	local action_rotation_3 = CCRotateTo:create(0.1, -10.7)
	local action_rotation_4 = CCRotateTo:create(0.05, 8)
	local action_rotation_5 = CCRotateTo:create(0.01, 0)

	durationTime = durationTime or 3
	local action_delay = CCDelayTime:create(durationTime)
	local array = CCArray:create()
	array:addObject(action_delay)
	array:addObject(action_rotation_1)
	array:addObject(action_rotation_2)
	array:addObject(action_rotation_3)
	array:addObject(action_rotation_4)
	array:addObject(action_rotation_5)
	
	local action_sequence = CCSequence:create(array)
	local action = CCRepeatForever:create(action_sequence)
	ui:runAction(action)
end

return ShareLevelSuccessButtonUtil