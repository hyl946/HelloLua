local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

local ballonMaxWidth = 186.25
local ballonMaxHeight = 188.8
local offsetX = 35
local offsetY = 35

Mark2019SelectPanel = class(BasePanel)
function Mark2019SelectPanel:create( closeCall, bReMark, Day, needBuy )
    local panel = Mark2019SelectPanel.new()
    panel:init(closeCall, bReMark, Day, needBuy)
    return panel
end

function Mark2019SelectPanel:init(closeCall, bReMark, Day, needBuy)

    UIHelper:loadArmature('skeleton/markAnim2019')
    UIHelper:loadArmature('skeleton/markAnim2019_2')
    UIHelper:loadArmature('skeleton/markAnim2019_3')

    self.closeCall = closeCall
    self.bReMark = bReMark
    self.Day = Day

    if needBuy == nil then
        self.needBuy = true
    else
        self.needBuy = needBuy
    end

    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/selectPanel")
    BasePanel.init(self, ui)

    self.ballonPosList = {}
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local gCenterPos = IntCoord:create(vOrigin.x + vSize.width / 2, vOrigin.y + vSize.height / 2)
    local FirstPos = IntCoord:create( gCenterPos.x - ballonMaxWidth/2 - offsetX -  ballonMaxWidth/2, gCenterPos.y + ballonMaxHeight/2 +  offsetY + ballonMaxHeight/2 )

    for i=1, 9 do
        local xpos = i%3
        if xpos == 0 then
            xpos = 3
        end
        local ypos = math.ceil(i/3)

        local posX = FirstPos.x + (ballonMaxWidth+offsetX) * (xpos-1)
        local posY = FirstPos.y - (ballonMaxHeight+offsetY)* (ypos-1)

        table.insert( self.ballonPosList, IntCoord:create(posX,posY) )
    end
    self.gCenterPos = gCenterPos

    local title1 = self.ui:getChildByName('title1')
    title1:setVisible(false)
    self.title1 = title1

    local title2 = self.ui:getChildByName('title2')
    title2:setVisible(false)
    self.title2 = title2

    local tip = self.ui:getChildByName('tip')
    tip:setVisible(false)
    self.tip = tip
    
    local okbtn = self.ui:getChildByName('okbtn')
    self.ok_btn = GroupButtonBase:create(okbtn)
    self.ok_btn:setString("确定")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )

        self:ShowGetItemToBag()
        self:onCloseBtnTapped()
    end) 
    self.ok_btn:setVisible(false)
end

function Mark2019SelectPanel:_close()

    Mark2019Manager.getInstance():removeObserver(self)

    UIHelper:unloadArmature('skeleton/markAnim2019', true)
    UIHelper:unloadArmature('skeleton/markAnim2019_2', true)
    UIHelper:unloadArmature('skeleton/markAnim2019_3', true)

    if self.closeCall then self.closeCall() end
--    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function Mark2019SelectPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 220)

    self:popoutShowTransition()

--    self.allowBackKeyTap = true
end

function Mark2019SelectPanel:popoutShowTransition()

    self.bCanClickBtn = false

    Mark2019Manager.getInstance():addObserver(self)

    local asyncRunner = Misc.AsyncFuncRunner:create()

    asyncRunner:add(function ( done )
        if self.isDisposed then return end
        self:ballonShowOut(done)
    end)

    asyncRunner:run()
end

-- 将数组随机打乱
function Mark2019SelectPanel:randomOrder(array)
  local ret = {}
  for i=#array,1,-1 do
     local index = math.random(1, i)
     table.insert(ret,array[index])
     array[index] , array[i] = array[i], array[index]
  end
  return ret
end

function Mark2019SelectPanel:ballonShowOut( showEndCall )

    local nodeCenterPos = self.ui:convertToNodeSpace( ccp(self.gCenterPos.x,self.gCenterPos.y) )
    local ShowEndNum = 0
    local function ballonShowEnd()
        if self.isDisposed then return end

        ShowEndNum = ShowEndNum + 1
        if ShowEndNum == 9 then
            if showEndCall then showEndCall() end
            self.bCanClickBtn = true

            ----按钮
            for i,v in ipairs(self.BaseLayerList) do
                UIUtils:setTouchHandler(v, function ( ... )
                    if self.isDisposed then return end
                    if not self.bCanClickBtn then return end

                    local function selectBubble()
                        self.bCanClickBtn = false 

                        if v.BallonData and v.BallonData.index then
                            local selectIndex = v.BallonData.index

                            local function sucessCall( allRewards )
                                self.otherRewards = table.clone(allRewards)
                                self.otherRewards.rewards = self:randomOrder(self.otherRewards.rewards)

                                self:showEnd(selectIndex)
                                self.bCanClickBtn = false
                                self.title1:setVisible(false)
                                self.title2:setVisible(true)
                                self.tip:setVisible(true)
                            end

                            local function onFail( )
                                self:_close()
                            end

                            if self.bReMark then
                                if self.needBuy then
                                    self:BuyBuQianItemLogic( sucessCall,onFail,onFail )
                                else
                                    Mark2019Manager.getInstance():Mark(true,self.Day,sucessCall,onFail,onFail)
                                end
                            else
                                Mark2019Manager.getInstance():Mark(false,nil,sucessCall,onFail,onFail)
                            end
                        end
                    end

                    selectBubble()
                end)
            end
            ----

        end
    end

    self.title1:setVisible(true)

    self.BaseLayerList = {}
    for i=1, 9 do
        local baseLayer = LayerColor:createWithColor(ccc3(255, 0, 0), ballonMaxWidth, ballonMaxHeight)
        baseLayer:setPosition( ccp(nodeCenterPos.x-88,nodeCenterPos.y) )
        self.ui:addChildAt( baseLayer,1 )
        baseLayer:setOpacity(0)
        table.insert( self.BaseLayerList, baseLayer )
        baseLayer.BallonData = {}
        baseLayer.BallonData.index = i

        local balloon_anim = ArmatureNode:create('MarkAnim/balloon0')
        balloon_anim:playByIndex(0)
        balloon_anim:update(0.001)
        balloon_anim:stop()
        balloon_anim:setPosition( ccp(0,ballonMaxHeight) )
        baseLayer:addChildAt( balloon_anim,1 )
        balloon_anim:setOpacity(0)
        baseLayer.balloon_anim = balloon_anim
       
        local function moveEndCall()
            if self.isDisposed then return end

            balloon_anim:play("A", 1)
            balloon_anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	        balloon_anim:removeAllEventListeners()
                ballonShowEnd()
            end)

            local randomNum = math.random(3)
            self:ItemMoveAction(balloon_anim, randomNum/10)
        end

        local function balloonFadeIn()
            if self.isDisposed then return end

            local array = CCArray:create()
            array:addObject( CCFadeIn:create(0.2)  )
            balloon_anim:runAction( CCSequence:create(array) )
        end

        local nodeEndPos = self.ui:convertToNodeSpace( ccp(self.ballonPosList[i].x,self.ballonPosList[i].y) )

        local array1 = CCArray:create()
        array1:addObject(CCCallFunc:create(balloonFadeIn))
        array1:addObject( CCMoveTo:create(0.2, ccp(nodeEndPos.x-92,nodeEndPos.y) ) )

        local array = CCArray:create()
        array:addObject( CCDelayTime:create(0.1*i)  )
        array:addObject( CCSpawn:create(array1)  )
        array:addObject(CCCallFunc:create(moveEndCall))

        baseLayer:runAction( CCSequence:create(array) )
    end
end

function Mark2019SelectPanel:BuyBuQianItemLogic( sucessCall,onFail,onFail )
    --补签购买道具
    local BuQianCost = Mark2019Manager.getInstance():getReMarkCost()

    local function onSuccess(data)
        Mark2019Manager.getInstance():Mark(true,self.Day,sucessCall,onFail,onFail)
    end

    local function onFail(errorCode)
--        Mark2019Manager.getInstance():showErrorTip(errorCode)
        CommonTip:showTip(localize("网络连接失败！"))
        self:_close()
    end

    local function onProc()
		if self.isDisposed then return end
		local function startBuyLogic()
            local curData = os.date("*t")
            curData.day = self.Day
            curData.year = Mark2019Manager.getInstance().year
            curData.month = Mark2019Manager.getInstance().month
            local timeSec = os.time2( curData )
            local day = Mark2019Manager.getInstance():time2day(timeSec)

            local goodsId = 589

            local logic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kSignIn, DcSourceType.kSignSupply,day)
			logic:getPrice()
			logic:start(1, onSuccess, onFail, nil, BuQianCost, true )
		end

        local function failt()
            self:_close()
        end
		RequireNetworkAlert:callFuncWithLogged(startBuyLogic,failt)
	end

    onProc()
end

function Mark2019SelectPanel:showEnd( index )
    if self.isDisposed then return end

    local markReward = table.clone(Mark2019Manager.getInstance().markReward)
    Mark2019Manager.getInstance().markReward = {}

    self.BaseLayerList[index].balloon_anim:removeFromParentAndCleanup(true)
    self.BaseLayerList[index].balloon_anim = nil

    local balloon_anim = ArmatureNode:create('MarkAnim/balloon2')
    balloon_anim:playByIndex(0)
    balloon_anim:update(0.001)
    balloon_anim:stop()
    balloon_anim:setPosition( ccp(0,ballonMaxHeight) )
    self.BaseLayerList[index]:addChildAt( balloon_anim,1 )
    self.BaseLayerList[index].balloon_anim = balloon_anim

    local object = UIHelper:getCon(balloon_anim,"object")
    local icon = Mark2019Manager.getInstance():createIcon(markReward)
    icon:setScale(1.2)
    object:addChild( icon.refCocosObj )
    self:ItemMoveAction(icon)
    icon:dispose()

    --记录位置
    local bollonPos = balloon_anim:getPosition()
    local worldPos = balloon_anim:getParent():convertToWorldSpace( ccp(bollonPos.x+97,bollonPos.y-102) )
    self.saveOpenPos = IntCoord:create(worldPos.x,worldPos.y)
    self.saveMarkReward = table.clone(markReward)

    local function ShowOtherBalloon()
        self.ok_btn:setVisible(true)

        local OtherRewardInfo = self.otherRewards.rewards
        local showIndex = 1
        for i=1, 9 do
            if i ~= index then 
                self.BaseLayerList[i].balloon_anim:removeFromParentAndCleanup(true)
                self.BaseLayerList[i].balloon_anim = nil

                local other_balloon_anim = ArmatureNode:create('MarkAnim/balloon1')
                other_balloon_anim:playByIndex(0)
                other_balloon_anim:update(0.001)
                other_balloon_anim:stop()
                other_balloon_anim:setPosition( ccp(0,ballonMaxHeight) )
                self.BaseLayerList[i]:addChildAt( other_balloon_anim,1 )
                self.BaseLayerList[i].balloon_anim = other_balloon_anim

                local object = UIHelper:getCon(other_balloon_anim,"object")
                local icon = Mark2019Manager.getInstance():createIcon(OtherRewardInfo[showIndex])
                icon:setScale(1.2)
                icon:setPositionY(icon:getPositionY()+5)
                object:addChild( icon.refCocosObj )
                icon:dispose()

                other_balloon_anim:play("B", 1)


                local randomNum = math.random(3)
                self:ItemMoveAction(other_balloon_anim, randomNum/10)

                showIndex = showIndex + 1
            end
        end
    end

    balloon_anim:play("B", 1)
    balloon_anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	balloon_anim:removeAllEventListeners()
--        ShowOtherBalloon()
--        self.ok_btn:setVisible(true)
    end)

    local randomNum = math.random(3)
    self:ItemMoveAction(balloon_anim, randomNum/10)

    setTimeOut( ShowOtherBalloon, 0.3 )
end

function Mark2019SelectPanel:ItemMoveAction( node, delay )
    if self.isDisposed then return end

    if delay == nil then delay = 0 end

    local array = CCArray:create()
    array:addObject( CCDelayTime:create(delay)  )
    array:addObject( CCMoveBy:create(1, ccp(0,5))  )
    array:addObject( CCMoveBy:create(1, ccp(0,-5))  )

    node:runAction( CCRepeatForever:create( CCSequence:create( array ) ) )
end

function Mark2019SelectPanel:ShowGetItemToBag()
    if not self.saveOpenPos then return end 

    local anim = FlyItemsAnimation:create({self.saveMarkReward })
	anim:setScale(1.8)
	anim:setWorldPosition(ccp(self.saveOpenPos.x, self.saveOpenPos.y))
	anim:setFinishCallback(function()
--        if self.isDisposed then return end
--		self.ok_btn:setVisible(true)
	end)
	anim:play()
end

function Mark2019SelectPanel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function Mark2019SelectPanel:onCloseBtnTapped( ... )
    self:_close()
end


function Mark2019SelectPanel:onPassDay()
    self:_close()
end

return Mark2019SelectPanel