local PigYearLogic = require 'zoo.localActivity.PigYear.PigYearLogic'
local PicYearMeta = require 'zoo.localActivity.PigYear.PicYearMeta'
local LuckyBagGroup = require 'zoo.localActivity.PigYear.LuckyBagGroup'
local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'
local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local IconHighlighter = require 'zoo.localActivity.PigYear.IconHighlighter'

local UIHelper = require 'zoo.panel.UIHelper'

local AnimationPlayer = require 'zoo.panel.endGameProp.anim.AnimationPlayer'
local PropertyTrack = require 'zoo.panel.endGameProp.anim.PropertyTrack'
local FuncTrack = require 'zoo.panel.endGameProp.anim.FuncTrack'
require "zoo.scenes.component.HomeScene.flyToAnimation.NewOpenBoxAnimation"

local function OpacitySetter( context, Opacity )
	if (not context) or context.isDisposed then return end
	context:setOpacity(Opacity)
end


local LuckyBagPanel = class(BasePanel)

function LuckyBagPanel:create(style)
    local panel = LuckyBagPanel.new()
    panel:init(style)
    return panel
end

function LuckyBagPanel:init(style)


    local ui = UIHelper:createUI("ui/pig-act-res.json", "pig-act-res/panel-" .. (style or 1))
    UIHelper:loadJson("ui/pig-act-res.json")
    -- ui = UIHelper:replaceLayer2LayerColor(ui)
    -- UIHelper:setCascadeOpacityEnabled(ui)

    ui = UIHelper:makeLayerSupportOpacity(ui)


	BasePanel.init(self, ui)

--	if self.ui:getChildByPath('descLabel') then
--    	self.ui:getChildByPath('descLabel'):setString('宝石可帮助闯关，高倍福袋开出的宝石更多哦~')
--    end

	self.tickTaskMgr = TickTaskMgr.new()
    self.tickTaskMgr:setTickTask(10001, function()
        if self.isDisposed then return end
        self:onSlotCountDown()
    end)


    UIUtils:setTouchHandler(self.ui:getChildByPath('closeBtn'), function()
        self:onCloseBtnTapped()
    end)

    self.luckyBagGroup = LuckyBagGroup:create(
    	self.ui:getChildByPath('bags'),
    	PigYearLogic, function ( ... )
    		-- body
    		return UIHelper:createUI('ui/pig-act-res.json', 'pig-act-res/speed-tip')
    	end
    )
    self.luckyBagGroup.canUnlockSlot = style == 1

    if style ~= 1 then
    	self.luckyBagGroup:setCanBuySlot(false)
    end

    if style == 1 then
    	self.luckyBagGroup:setScene(2)
    else
    	self.luckyBagGroup:setScene(3)
    end

    self:refreshView()
    self.tickTaskMgr:start()

    self.luckyBagGroup.evtDp:ad(LuckyBagGroup.EventType.kSpeedUp, function ( ... )
    	if self.isDisposed then return end
    	self:refreshView()
    end)

    self.luckyBagGroup.evtDp:ad(LuckyBagGroup.EventType.kUnlockSlot, function ( evt )
    	if self.isDisposed then return end
    	self:refreshView()

    	local slotIndex = evt.data.slotIndex

    	self:setupJumpAnimation(slotIndex)
    	self:runJumpAnimation(slotIndex)
    end)

    self.luckyBagGroup.evtDp:ad(LuckyBagGroup.EventType.kAfterCheckData, function ( ... )
    	if self.isDisposed then return end
    	self:refreshView()
    end)

	self.luckyBagGroup.evtDp:ad(LuckyBagGroup.EventType.kOpenLuckyBag, function ( evt )
    	if self.isDisposed then return end

    	self.paused_bagnum = true
    	self:refreshView()

    	local data = evt.data or {}
    	local rewards = data.rewards or {}
    	local slotIndex = data.slotIndex
    	local multiple = data.multiple or 1

    	local luckyBagLevel = PigYearLogic:getLuckyBagLevel()

	    local boxRes = Sprite:createWithSpriteFrameName(string.format('pig-act-res/p%s0000', luckyBagLevel))

	    local targetPos = self:getGemTargetPos()

	    local floatMode = (style == 1 and self:createFloatIconIfNotExist())

	    if floatMode then
	    	self.floatIcon:setSceneMode(true)

	    	self.floatIcon:show()
	    	targetPos = self.floatIconPos
	    end



	    self:setupJumpAnimation(slotIndex)


	    if multiple > 1 then
	        local mSP = Sprite:createWithSpriteFrameName('pig-act-res/m' .. multiple .. '0000')
	        mSP:setCascadeOpacityEnabled(true)
	        boxRes:setCascadeOpacityEnabled(true)
	        boxRes:addChild(mSP)
	        mSP:setScale(1.5)
	        mSP:setPosition(ccp(50, boxRes:getContentSize().height - 65))
	        boxRes:setAnchorPoint(ccp(0.5, 0.5))
	    end



	    local openAnim = NewOpenBoxAnimation:create(rewards, boxRes.refCocosObj, {
	        [PicYearMeta.ItemIDs.GEM_1] = {
	             frameName = 'pig-act-res/piggyi_10000', targetPos = targetPos
	        },
	        [PicYearMeta.ItemIDs.GEM_2] = {
	             frameName = 'pig-act-res/piggyi_20000', targetPos = targetPos
	        },
	        [PicYearMeta.ItemIDs.GEM_3] = {
	             frameName = 'pig-act-res/piggyi_30000', targetPos = targetPos
	        },
	        [PicYearMeta.ItemIDs.GEM_4] = {
	             frameName = 'pig-act-res/piggyi_40000', targetPos = targetPos
	        },
	    }, true)

	    boxRes:dispose()

	    openAnim:setFinishCallback(function ( ... )
	    	if self.isDisposed then return end

	    	if self.floatIcon then
	    		self.floatIcon:remove()
	    		self.floatIcon = nil
	    	end

--            self:setupJumpAnimation(slotIndex)
	    	if self:runJumpAnimation(slotIndex) then
	    	else
	    		self:refreshView()
	    	end
	    	
	    	self.paused_bagnum = false
    		-- self:refreshView()

	    end)
	    openAnim:play()

    end)


	local oldSetOpacity = self.ui.setOpacity
    function self.ui:setOpacity( o )
    	if self.isDisposed then return end
    	oldSetOpacity(self, o)
    	self:getChildByPath('bg1'):setOpacity(o)
    	self:getChildByPath('bg'):setOpacity(o)
    	self:getChildByPath('closeBtn/图层 1'):setOpacity(o)
		for i = 1, 8 do
--    		self:getChildByPath('bags/' .. i .. '/bg1'):setOpacity(o)
--    		self:getChildByPath('bags/' .. i .. '/bg2'):setOpacity(o)
    		self:getChildByPath('bags/' .. i .. '/time'):setOpacity(o)
    		self:getChildByPath('bags/' .. i .. '/speedUpBtn/图层 1'):setOpacity(o)
    		self:getChildByPath('bags/' .. i .. '/btn/图层 1'):setOpacity(o)
    		self:getChildByPath('bags/' .. i .. '/progress'):findChildByName('fg'):setOpacity(o)
    		self:getChildByPath('bags/' .. i .. '/progress'):findChildByName('bg'):setOpacity(o)

            local slotView = self:getChildByPath('bags/' .. i)
            if slotView.buyBtn and slotView.buyBtn.gold then
                slotView.buyBtn.gold:setOpacity(o)
            end

            if slotView.buyBtn and slotView.buyBtn.txtGold then
                slotView.buyBtn.txtGold:setOpacity(o)
            end
		end
    end

    self.animPlayer = AnimationPlayer:create()
	self.animPlayer:setTarget(self.ui)
	self:addChild(self.animPlayer)

end

function LuckyBagPanel:setupJumpAnimation( slotIndex )

	if self.isDisposed then return end
	if self.animedBag then return end
	local animedBag
    local slotData = PigYearLogic:getSlotData(slotIndex)
    if slotData.unlocked and (not slotData.isSlotEmpty) then
        animedBag = self.ui:getChildByPath(string.format('bags/%d/cake', slotIndex))
        local slotView = self.ui:getChildByPath(string.format('bags/%d', slotIndex))
        slotView:removeFromParentAndCleanup(false)
        self.ui:getChildByPath('bags'):addChild(slotView)
    end

    if animedBag then
        animedBag:setVisible(false)
        self.luckyBagGroup:hideAllExceptBag(slotIndex)
        self.pausedSlotIndex = slotIndex
        self.luckyBagGroup:setBusyMode(true)

        if slotData.multiple > 1 then
	    	local animedBagMM = self.ui:getChildByPath(string.format('bags/%d/multiIcon/%d', slotIndex, slotData.multiple))
	    	self.animedBagMM = animedBagMM
	    	self.animedBagMM:setVisible(false)
	    	animedBagMM:setAnchorPointCenterWhileStayOrigianlPosition()
	    end
    end

    self.animedBag = animedBag
end


function LuckyBagPanel:runJumpAnimation( slotIndex )

	if self.isDisposed then return end
	if self.animedBag then 
    	local slotData = PigYearLogic:getSlotData(slotIndex)
    	local startPos = ccp(0, 0)
        local bagIcon = self.ui:getChildByPath('bar/g' .. slotData.multiple .. '/icon')
        local bagIconBonds = bagIcon:getGroupBounds()
        startPos = ccp(bagIconBonds:getMidX(), bagIconBonds:getMidY())

        local targetPos = self.animedBag:getPosition()
        targetPos = ccp(targetPos.x, targetPos.y)

        layoutUtils.setNodeCenterPos(self.animedBag, startPos)
        self.animedBag:setVisible(true)

        self.animedBag:runAction(UIHelper:sequence{
            CCJumpTo:create(0.5, targetPos, 200, 1),
            CCScaleTo:create(0.1, 1/1.3, 1/1.3),
            CCScaleTo:create(0.1, 1.3, 1.3),
            CCScaleTo:create(0.1, 1, 1),
            CCCallFunc:create(function ( ... )
                if self.isDisposed then return end
                self.pausedSlotIndex = nil
        		self.luckyBagGroup:setBusyMode(false)

                -- self.luckyBagGroup:refresh()

                self:refreshView()
                self.animedBag = nil
            end)
        })

        if self.animedBagMM then
	        local targetPosMM = self.animedBagMM:getPosition()
	        targetPosMM = ccp(targetPosMM.x, targetPosMM.y)

	        layoutUtils.setNodeCenterPos(self.animedBagMM, startPos)
	        self.animedBagMM:setVisible(true)

	        self.animedBagMM:runAction(UIHelper:sequence{
	            CCJumpTo:create(0.5, targetPosMM, 200, 1),
	            CCScaleTo:create(0.1, 1/1.3, 1/1.3),
	            CCScaleTo:create(0.1, 1.3, 1.3),
	            CCScaleTo:create(0.1, 1, 1),
	            CCCallFunc:create(function ( ... )
	                if self.isDisposed then return end
	            end)
	        })
	        self.animedBagMM = nil
	    end

        return true
	end

	
end

function LuckyBagPanel:createFloatIconIfNotExist( ... )
	-- body
	if self.isDisposed then return end

	if not self.floatIcon then

		local icon = PigYearLogic:getActivityIcon()
		if icon and (not icon.isDisposed) then
			self.floatIcon = IconHighlighter:create(icon, self.ui)

			local bounds = icon:getGroupBounds()
			self.floatIconPos = ccp(bounds:getMidX(), bounds:getMidY())
		end

		
	end

	return self.floatIcon ~= nil
end

function LuckyBagPanel:removeFloatIcon( ... )
	if self.isDisposed then return end
	if self.floatIcon then
		self.floatIcon:remove()
		self.floatIcon = nil
	end
end

function LuckyBagPanel:getGemTargetPos( ... )
	return self.gemPos or ccp(0, 0)
end

function LuckyBagPanel:setGemTargetPos( pos )
	self.gemPos = pos
end

function LuckyBagPanel:onSlotCountDown( ... )
	if self.isDisposed then return end
	self.luckyBagGroup:onSlotCountDown()
end

function LuckyBagPanel:refreshView( newRewardsMode )

	if self.isDisposed then return end

	local luckBagLevel = PigYearLogic:getLuckyBagLevel()

	for i = 1, 4 do
		local numLabel = self.ui:getChildByPath('bar/g' .. i .. '/num')
  		numLabel:setColor(hex2ccc3('CC6600'))

  		if not self.paused_bagnum then
			UIHelper:setCenterText(numLabel, PigYearLogic:getLuckyBagNum(i))
		end

		if newRewardsMode then

			local sum = 0
			for _, v in ipairs(self.newRewards or {}) do
				if v.itemId == PicYearMeta.ItemIDs['LUCKY_BAG_M_' .. i] then
					sum = sum + v.num
				end
			end

			UIHelper:setCenterText(numLabel, PigYearLogic:getLuckyBagNum(i) - sum)
		end

--		local icon = self.ui:getChildByPath('bar/g' .. i .. '/icon')
--		for i = 1, 4 do
--			icon:getChildByPath(tostring(i)):setVisible(i == luckBagLevel)
--		end
	end



	if not self._init_bag_icon_pos then
		self._init_bag_icon_pos = true

		self._pos_cache = {}


		local function cachePos( path )
			local node = self.ui:getChildByPath(path)
			if node then
				local pos = node:getPosition()
				return ccp(pos.x, pos.y)
			end
			return ccp(0, 0)
		end

		self._pos_cache.my = cachePos('bar/my')
		for i = 1, 4 do
			self._pos_cache[i] = {}
			self._pos_cache[i].icon = cachePos('bar/g' .. i )
			self._pos_cache[i].multiple = cachePos('bar/' .. i .. 'm')
		end
	end

	local function setBagIconVisible( i, b )
		if self.isDisposed then return end

		if b == false and self._layout_bag_icons then
			return
		end

		self.ui:getChildByPath('bar/' .. i .. 'm'):setVisible(b)
		self.ui:getChildByPath('bar/g' .. i ):setVisible(b)
	end

	local function moveBagIcon( i, newIndex )
		self.ui:getChildByPath('bar/g' .. i):setPosition(self._pos_cache[newIndex].icon)
		self.ui:getChildByPath('bar/' .. i .. 'm'):setPosition(self._pos_cache[newIndex].multiple)
	end

	local function moveMyIcon( newIndex )
		self.ui:getChildByPath('bar/my'):setPositionX(
			self.ui:getChildByPath('bar/g' .. newIndex ):getPositionX() - 60

		)
	end


	-- if not self._layout_bag_icons then
		local deltaIndex = 0

		if PigYearLogic:getLuckyBagNum(2) <= 0 then
			setBagIconVisible(2, false)
			deltaIndex = deltaIndex - 1
		else
			setBagIconVisible(2, true)
		end

		moveBagIcon(3, 3 + deltaIndex)


		if PigYearLogic:getLuckyBagNum(3) <= 0 then
			setBagIconVisible(3, false)
			deltaIndex = deltaIndex - 1
		else
			setBagIconVisible(3, true)
		end

		moveBagIcon(4, 4 + deltaIndex)

		if PigYearLogic:getLuckyBagNum(4) <= 0 then
			setBagIconVisible(4, false)
			deltaIndex = deltaIndex - 1
		else
			setBagIconVisible(4, true)
		end

	-- end

	for i = 4, 1, -1 do
		if self.ui:getChildByPath('bar/g' .. i):isVisible() then
			moveMyIcon(i)
			break
		end
	end

	self._layout_bag_icons = true

	self.luckyBagGroup:refresh()
end

function LuckyBagPanel:_close()
	if self.tickTaskMgr then
        self.tickTaskMgr:stop()
        self.tickTaskMgr = nil
    end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function LuckyBagPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setScale(self:getScaleX() * 0.85)
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self.allowBackKeyTap = true

	self:popoutShowTransition()
end

function LuckyBagPanel:setNewRewards( rewards )
	if self.isDisposed then return end
	self.newRewards = rewards
end

function LuckyBagPanel:popoutShowTransition( ... )
	if self.isDisposed then return end

	if self.newRewards then


		self:refreshView(true)

		self.rewardNodeGrp = {}

		self.ui:setOpacity(0)

		local animNode = UIHelper:createArmature3('skeleton/pig-act-anim', 
                    'pig-act-pkg-anim', 'pig-act-pkg-anim', 'pig-act-pkg-anim/anim1')
		self:addChild(animNode)

		animNode:playByIndex(0, 1)

		animNode:setPositionX(self.ui:getGroupBounds(self).size.width/2)
		animNode:setPositionY(250)

		animNode:runAction(UIHelper:sequence{
			CCDelayTime:create(8/30),
			CCCallFunc:create(function ( ... )
				if self.isDisposed then return end


				local layer = Layer:create()
				local nodes = {}

				for _, v in ipairs(self.newRewards) do

					local sp = self:buildItemSprite(v.itemId)
					if sp then

						sp:setAnchorPoint(ccp(0.5, 0.5))
                        sp:setScale(1.5)
						sp:setPosition(ccp(104/2, 100/2))

						if v.itemId == PicYearMeta.ItemIDs.SILVER then
							sp:setPosition(ccp(104/2, 108/2))
						end

						if v.itemId == PicYearMeta.ItemIDs.SILVER then
							sp:setPosition(ccp(104/2, 108/2))
						end
						if v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_1 or 
							v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_2 or 
							v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_3 or 
							v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then

							local multiple = v.itemId - PicYearMeta.ItemIDs.LUCKY_BAG_M_1 + 1
							if multiple > 1 then
								local mSP = Sprite:createWithSpriteFrameName('pig-act-res/m' .. multiple .. '0000')
						        mSP:setCascadeOpacityEnabled(true)
						        sp:setCascadeOpacityEnabled(true)
						        sp:addChild(mSP)
						        mSP:setScale(1.5)
						        mSP:setPosition(ccp(50, sp:getContentSize().height - 65))
						    end

						end

						local rewardNode = UIHelper:createArmature3('skeleton/pig-act-anim', 
	                    	'pig-act-pkg-anim', 'pig-act-pkg-anim', 'pig-act-pkg-anim/anim2')


						local holder = rewardNode:getCon('holder')
						holder:addChild(sp.refCocosObj)

						layer:addChild(rewardNode)
						table.insert(nodes, {
							node = rewardNode,
						})

						rewardNode:playByIndex(0, 1)

						table.insert(self.rewardNodeGrp, {rewardNode, sp, v})

						rewardNode:update(0.001)
						-- rewardNode:stop()
					end


				end

				layoutUtils.horizontalLayoutItems(nodes)


				self:addChild(layer)
				self.rewardAnimContainer = layer

				local vo = Director:sharedDirector():getVisibleOrigin()
				local vs = Director:sharedDirector():getVisibleSize()

				layer:setPositionY(100)
				layer:setPositionX( (vs.width - 250 * (#nodes))/2)

				if #nodes == 2 then
					layer:setPositionX( (vs.width - 270 * (#nodes))/2)
				end

				if #nodes == 3 then
					layer:setPositionX( (vs.width - 245 * (#nodes))/2)
				end

				if #nodes == 1 then
					layer:setPositionX( (vs.width - 330 * (#nodes))/2)
				end



			end)
		})

		animNode:runAction(UIHelper:sequence{
			CCDelayTime:create(35/30),
			CCCallFunc:create(function ( ... )
				if self.isDisposed then return end

				local viewOpacity = PropertyTrack.new()
				viewOpacity:setName('viewOpacity')
				viewOpacity:setPropertyAccessor(nil, OpacitySetter)
				viewOpacity:setTargetPath('.')
				viewOpacity:setFrameDataConfig({
					{index = 0, data = 0},
					{index = 7, data = 255},
				})
				self.animPlayer:addTrack(viewOpacity)

				local funcTrack = FuncTrack.new()
				funcTrack:setName('funcTrack')
				funcTrack:setTargetPath('.')
				funcTrack:setFrameDataConfig({
					{index = 8, data = function ( ... )
						if self.isDisposed then return end

						local entrySlotIndex = PigYearLogic:tryEnterSlot()
                        Notify:dispatch("FifthAnniversaryPassLevel_getFuDai")

						for _, vv in ipairs(self.rewardNodeGrp) do

							vv[1]:getCon('ffdd'):setVisible(false)

							if animNode and (not animNode.isDisposed) then
								animNode:setVisible(false)
							end

							local context = vv
							if context[3].itemId >= PicYearMeta.ItemIDs.LUCKY_BAG_M_1 and context[3].itemId <= PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then

								-- entrySlotIndex = 1
								if entrySlotIndex then
									PigYearLogic:getSlotData(entrySlotIndex)								


									local multiple = context[3].itemId - PicYearMeta.ItemIDs.LUCKY_BAG_M_1 + 1

									local luckyIcon = self.ui:getChildByPath('bags/' .. entrySlotIndex .. '/bagDone')
									local bounds = luckyIcon:getGroupBounds()
									local luckyPos = ccp(bounds:getMidX(), bounds:getMidY())

									context[2]:setAnchorPointCenterWhileStayOrigianlPosition()
									context[2]:runAction(UIHelper:sequence{
										UIHelper:spawn{
											CCJumpTo:create(0.5, context[2].refCocosObj:getParent():convertToNodeSpace(luckyPos), 200, 1),
											CCScaleBy:create(0.5, 0.8, 0.8),
										},
										CCCallFunc:create(function ( ... )
											if self.isDisposed then return end
											-- body
											
											context[2]:runAction(UIHelper:sequence{
												CCScaleBy:create(4/30, 100/54, 100/54),
												UIHelper:spawn{
													CCScaleBy:create(4/30, 43/100, 43/100),
													CCFadeOut:create(4/30)
												},
											})

											self:refreshView()

											if self.floatIcon then
	    										self.floatIcon:remove()
	    										self.floatIcon = nil
	    									end


										end)
									})

								else

									local multiple = context[3].itemId - PicYearMeta.ItemIDs.LUCKY_BAG_M_1 + 1

									local luckyIcon = self.ui:getChildByPath('bar/g' .. multiple .. '/icon')
									local bounds = luckyIcon:getGroupBounds()
									local luckyPos = ccp(bounds:getMidX(), bounds:getMidY())

									context[2]:setAnchorPointCenterWhileStayOrigianlPosition()
									context[2]:runAction(UIHelper:sequence{
										UIHelper:spawn{
											CCJumpTo:create(0.5, context[2].refCocosObj:getParent():convertToNodeSpace(luckyPos), 200, 1),
											CCScaleBy:create(0.5, 0.5, 0.5),
										},
										CCCallFunc:create(function ( ... )
											if self.isDisposed then return end
											-- body
											
											context[2]:runAction(UIHelper:sequence{
												CCScaleBy:create(4/30, 100/54, 100/54),
												UIHelper:spawn{
													CCScaleBy:create(4/30, 43/100, 43/100),
													CCFadeOut:create(4/30)
												},
											})

											self:refreshView()

											if self.floatIcon then
	    										self.floatIcon:remove()
	    										self.floatIcon = nil
	    									end
										end)
									})

								end
							else

								context[2]:setAnchorPointCenterWhileStayOrigianlPosition()
								context[2]:runAction(UIHelper:sequence{
									UIHelper:spawn{
										CCJumpTo:create(0.5, context[2].refCocosObj:getParent():convertToNodeSpace(self.floatIconPos), 50, 1),
										CCScaleTo:create(0.5, 0.6),
									},
									CCCallFunc:create(function ( ... )
										if self.isDisposed then return end
										-- body
										-- context[2]:setVisible(false)
										context[2]:runAction(UIHelper:sequence{
											CCScaleBy:create(4/30, 135/54, 135/54),
											UIHelper:spawn{
												CCScaleBy:create(4/30, 43/135, 43/135),
												CCFadeOut:create(4/30)
											},
										})
									end)
								})
							end
						end

						self.luckyBagGroup:setCustomFadeEnabled(true)
					end},
				})
				self.animPlayer:addTrack(funcTrack)
				self.animPlayer:start()


				local onlyLuckyBag = true

				for _, v in ipairs(self.newRewards or {}) do
					if v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_1 or
						v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_2 or
						v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_3 or
						v.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
					else
						onlyLuckyBag = false
					end
				end

				if not onlyLuckyBag then
					self:createFloatIconIfNotExist()
				end

				if self.floatIcon then
					self.floatIcon:show()
				end


			end)
		})

		self.titleAnim = animNode
		self.luckyBagGroup:setCustomFadeEnabled(false)


	else
		for i = 1, PicYearMeta.SLOT_NUM do
			if not PigYearLogic:tryEnterSlot() then 
				self:refreshView()
				break 
			end
		end
	end

end

function LuckyBagPanel:HideCloseBtn()
    self.ui:getChildByPath('closeBtn'):setVisible(false)
end

function LuckyBagPanel:ShowCloseBtn()
    self.ui:getChildByPath('closeBtn'):setVisible(true)
end

function LuckyBagPanel:ShowFlyAnim( itemList, bDouble, endCallBack )

    local function getSequenceAction( luckyIcon, MoveNode, endPos )
        if self.isDisposed then return end

        local function callend()
            if self.isDisposed then return end

            local array1 = CCArray:create()
            array1:addObject( CCScaleTo:create(0.1, 1.1)  )
            array1:addObject( CCScaleTo:create(0.1, 1)  )
            luckyIcon:runAction( CCSequence:create(array1) )

            if MoveNode then
	    	    MoveNode:setVisible(false)
	        end

            if self.floatIcon then
                self.floatIcon:remove()
                self.floatIcon = nil
            end

            if endCallBack then endCallBack() endCallBack = nil self:refreshView() end
        end

        local array1 = CCArray:create()
        array1:addObject( CCJumpTo:create(0.5, MoveNode:getParent():convertToNodeSpace(endPos), 200, 1)  )
        array1:addObject( CCScaleBy:create(0.5, 0.5, 0.5)  )

        local array = CCArray:create()
        array:addObject( CCDelayTime:create(0.5) )
        array:addObject( CCSpawn:create(array1)  )
        array:addObject(CCCallFunc:create(callend))

        return CCSequence:create(array)
    end

    local function getSequenceAction2( MoveNode )
        if self.isDisposed then return end

        local function callend()
            if self.isDisposed then return end

            if MoveNode then
	    	    MoveNode:setVisible(false)
	        end

            if self.floatIcon then
                self.floatIcon:remove()
                self.floatIcon = nil
            end

            if endCallBack then endCallBack() endCallBack = nil end
        end

        if self.floatIcon then
            self.floatIcon:show()
        end

        local EndPos = ccp(0,0)
        if self.floatIconPos then
            EndPos = ccp( self.floatIconPos.x-14/0.7, self.floatIconPos.y+10/0.7 )
        end

        local array1 = CCArray:create()
        array1:addObject( CCJumpTo:create(0.5, MoveNode:getParent():convertToNodeSpace(EndPos), 50, 1)  )
        array1:addObject( CCScaleBy:create(0.5, 0.3, 0.3)  )

        local array = CCArray:create()
        array:addObject( CCDelayTime:create(0.5) )
        array:addObject( CCSpawn:create(array1)  )
        array:addObject(CCCallFunc:create(callend))

        return CCSequence:create(array)
    end

    self:createFloatIconIfNotExist()

    ------------
    local bHaveTicket = false
    local BagDouble = 1
    for i,v in ipairs(self.newRewards) do
        if v.itemId == PicYearMeta.ItemIDs.GOLD and v.num > 0 then
            bHaveTicket = true
        elseif v.itemId >= PicYearMeta.ItemIDs.LUCKY_BAG_M_1 and v.itemId <= PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
            BagDouble = v.itemId - PicYearMeta.ItemIDs.LUCKY_BAG_M_1 + 1
        end
    end

	local luckyIcon = self.ui:getChildByPath('bar/g' .. BagDouble .. '/icon')

    local function getLuckyPos()
        local luckyPos = ccp(0,0)
        --判断能不能跳到格子里
        local entrySlotIndex = PigYearLogic:tryEnterSlotOne()
        if entrySlotIndex then
			local luckyIcon = self.ui:getChildByPath('bags/' .. entrySlotIndex .. '/bagDone')
			local bounds = luckyIcon:getGroupBounds()
			luckyPos = ccp(bounds:getMidX(), bounds:getMidY())
        else
            luckyPos = luckyIcon:getParent():convertToWorldSpace(luckyIcon:getPosition())
        end

        return luckyPos
    end

    if bDouble then
        if #itemList == 3 then
            --object
            for i=1,2 do
                local luckyPos = getLuckyPos()
                local sequenAction = getSequenceAction( luckyIcon,itemList[i], luckyPos )
                itemList[i]:runAction( sequenAction )
            end

            --ticket
            local ticketIcon =  itemList[3]
            local sequenAction = getSequenceAction2( ticketIcon )
            ticketIcon:runAction( sequenAction )
        else
            for i=1,2 do
                local luckyPos = getLuckyPos()
                local sequenAction = getSequenceAction( luckyIcon,itemList[i], luckyPos )
                itemList[i]:runAction( sequenAction )
            end
        end
    else
        if #itemList == 2 then
            --object
            local luckyPos = getLuckyPos()
            local sequenAction = getSequenceAction( luckyIcon,itemList[1], luckyPos )
            itemList[1]:runAction( sequenAction )

            --ticket
            local ticketIcon =  itemList[2]
            local sequenAction = getSequenceAction2( ticketIcon )
            ticketIcon:runAction( sequenAction )
        else
            local luckyPos = getLuckyPos()
            local sequenAction = getSequenceAction( luckyIcon,itemList[1], luckyPos )
            itemList[1]:runAction( sequenAction )
        end
    end

    Notify:dispatch("FifthAnniversaryPassLevel_getFuDai")
end

function LuckyBagPanel:onCloseBtnTapped( ... )
    local _ = self.closeCallback and self.closeCallback()
    self:_close()
end

function LuckyBagPanel:dispose( ... )
	-- body
	self:removeFloatIcon()


	BasePanel.dispose(self, ...)


	if self.rewardNodeGrp then
		for _, v in ipairs(self.rewardNodeGrp) do
			v[2]:dispose()
		end
    end

    UIHelper:unloadJson("ui/pig-act-res.json")


end


function LuckyBagPanel:buildItemSprite( itemId )
	if self.isDisposed then return end

	local luckyBagLevel = PigYearLogic:getLuckyBagLevel()


	if itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_1 then
		return Sprite:createWithSpriteFrameName('pig-act-res/p' .. luckyBagLevel .. '0000')
	elseif itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_2 then
		return Sprite:createWithSpriteFrameName('pig-act-res/p' .. luckyBagLevel .. '0000')
	elseif itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_3 then
		return Sprite:createWithSpriteFrameName('pig-act-res/p' .. luckyBagLevel .. '0000')
	elseif itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
		return Sprite:createWithSpriteFrameName('pig-act-res/p' .. luckyBagLevel .. '0000')
	elseif itemId == PicYearMeta.ItemIDs.GOLD then
		return Sprite:createWithSpriteFrameName('pig-act-res/prop_500450000')
	elseif itemId == PicYearMeta.ItemIDs.SILVER then
		return Sprite:createWithSpriteFrameName('pig-act-res/prop_500460000')
	elseif itemId == PicYearMeta.ItemIDs.SPEEDUP_CARD then
		return Sprite:createWithSpriteFrameName('pig-act-res/prop_500400000')
	end
end




-- if __WIN32 then
-- 	setTimeOut(function ( ... )
-- 		-- PigYearLogic:addRewards({{itemId = -30001+1, num = 1}})
-- 		local panel = LuckyBagPanel:create(1)
-- 		panel:popout()
-- 	end)


-- end


return LuckyBagPanel
