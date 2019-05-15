GlobalCoreActionLogic = class()

function GlobalCoreActionLogic:update(mainLogic)
	local count = GlobalCoreActionLogic:doUpdate(mainLogic)
	-- 检测blocker状态变化
	mainLogic:updateFallingAndBlockStatus()
	return count > 0
end

function GlobalCoreActionLogic:doUpdate(mainLogic)
	local count = 0

	local maxIndex = table.maxn(mainLogic.globalCoreActionList)
	for i = 1 , maxIndex do
		local atc = mainLogic.globalCoreActionList[i]
		if atc then
			count = count + 1
			GlobalCoreActionLogic:runViewAction( mainLogic.boardView , atc )
			GlobalCoreActionLogic:runLogicAction( mainLogic , atc , i )
		end
	end
	return count
end

function GlobalCoreActionLogic:runViewAction(boardView, theAction)
	if theAction.actionType == GameItemActionType.kAddBuffItemToBoard then
		GlobalCoreActionLogic:runView_AddBuffItemToBoard( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kBuffBoom_Dec then
		GlobalCoreActionLogic:runView_DecBuffItem( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kBuffBoom_Explode then
		GlobalCoreActionLogic:runView_ExplodeBuffItem( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kAct_Collection_Turn then
		GlobalCoreActionLogic:runView_ActCollectionTurn( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kAddBuffRefresh then
		GlobalCoreActionLogic:runView_AddBuffRefresh( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kAddBuffAdd3Step then
		GlobalCoreActionLogic:runView_AddBuffAdd3Step( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kAddBuffSpecialAnimal then
		GlobalCoreActionLogic:runView_AddBuffSpecialAnimal( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kItemGiveBack then
		GlobalCoreActionLogic:runView_ItemGiveBack( boardView , theAction )
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Create then
		GlobalCoreActionLogic:runView_MoleWeeklyBossCreate(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Skill then
		GlobalCoreActionLogic:runView_MoleWeeklyBossSkill(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Die then
		GlobalCoreActionLogic:runView_MoleWeeklyBossDie(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kSummerFish_33_FlyObject then
		GlobalCoreActionLogic:runView_SummerFishFlyLogic(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ghost_generate then
		GlobalCoreActionLogic:runView_GhostGenerate(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ScoreBuffBottle_Add then
		GlobalCoreActionLogic:runView_AddScoreBuffBottle(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ScoreBuffBottle_Blast then
		GlobalCoreActionLogic:runView_BlastScoreBuffBottle(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Firecracker_Blast then
		GlobalCoreActionLogic:runView_BlastFirecracker(boardView, theAction) 
	elseif theAction.actionTarget == GameActionTargetType.kTopPartAction and theAction.actionType == GameBoardTopPartActionType.kBranchProgress then
		GlobalCoreActionLogic:runView_kCSYEBranchProgress(boardView, theAction) 
	end
end

function GlobalCoreActionLogic:runLogicAction(mainLogic, theAction, actid)
	if theAction.actionType == GameItemActionType.kAddBuffItemToBoard then
		GlobalCoreActionLogic:runLogic_AddBuffItemToBoard( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kBuffBoom_Dec then
		GlobalCoreActionLogic:runLogic_DecBuffItem( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kBuffBoom_Explode then
		GlobalCoreActionLogic:runLogic_ExplodeBuffItem( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kAct_Collection_Turn then
		GlobalCoreActionLogic:runLogic_ActCollectionTurn( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kAddBuffRefresh then
		GlobalCoreActionLogic:runLogic_AddBuffRefresh( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kAddBuffAdd3Step then
		GlobalCoreActionLogic:runLogic_AddBuffAdd3Step( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kAddBuffSpecialAnimal then
		GlobalCoreActionLogic:runLogic_AddBuffSpecialAnimal( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kItemGiveBack then
		GlobalCoreActionLogic:runLogic_ItemGiveBack( mainLogic , theAction , actid )
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Create then
		GlobalCoreActionLogic:runLogic_MoleWeeklyBossCreate(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Skill then
		GlobalCoreActionLogic:runLogic_MoleWeeklyBossSkill(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Die then
		GlobalCoreActionLogic:runLogic_MoleWeeklyBossDie(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kSummerFish_33_FlyObject then
		GlobalCoreActionLogic:runLogic_SummerFishFlyView(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ghost_generate then
		GlobalCoreActionLogic:runLogic_GhostGenerate(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ScoreBuffBottle_Add then
		GlobalCoreActionLogic:runLogic_AddScoreBuffBottle(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ScoreBuffBottle_Blast then
		GlobalCoreActionLogic:runLogic_BlastScoreBuffBottle(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Firecracker_Blast then
		GlobalCoreActionLogic:runLogic_BlastFirecracker(mainLogic, theAction, actid, actByView)
	elseif theAction.actionTarget == GameActionTargetType.kTopPartAction and theAction.actionType == GameBoardTopPartActionType.kBranchProgress then
		GlobalCoreActionLogic:runLogic_kCSYEBranchProgress(mainLogic, theAction, actid, actByView)
	end
end
-------------------------------------------------------------------------------
function GlobalCoreActionLogic:runView_ActCollectionTurn(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.addInfo = "start"
	else
		if theAction.addInfo == "startPlayAni" then 
			theAction.addInfo = "playingAni" 
			local turnTargets = theAction.turnTargets
			local targetNum = #turnTargets
			for i,v in ipairs(turnTargets) do
				local itemView = boardView.baseMap[v.r][v.c]
				local cb 
				if i == targetNum then 
					cb = function ()
						theAction.addInfo = 'over'
					end
				end
				itemView:playActCollectionShow(cb)
			end
		end
	end 
end

function GlobalCoreActionLogic:runLogic_ActCollectionTurn(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "start" then
		local turnTargets = theAction.turnTargets
		for i,v in ipairs(turnTargets) do
			local itemData = mainLogic.gameItemMap[v.r][v.c]
			itemData:setHasActCollection(true)
		end
		theAction.addInfo = "startPlayAni"
	elseif theAction.addInfo == 'over' then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_ExplodeBuffItem(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local booms = theAction.booms
		
		if booms then

			for k,v in ipairs(booms) do
				local r = v.r
				local c = v.c

				local itemView = boardView.baseMap[r][c]
				itemView:explodeBuffBoom()
			end

		else
			theAction.addInfo = "over"
			return
		end

		theAction.jsq = 0
		theAction.addInfo = "startBoom"

	elseif theAction.addInfo == "fly" then

		local booms = theAction.booms

		for k,v in ipairs(booms) do
			local r = v.r
			local c = v.c

			local itemView = boardView.baseMap[r][c]
			local fromPos = itemView:getBasePosition( itemView.x , itemView.y )
			
			local targetList = v.targetList

			for k1 , v1 in ipairs(targetList) do
				local targetView = boardView.baseMap[v1.r][v1.c]
				--local toPos = targetView:getBasePosition( targetView.x , targetView.y )
				targetView:playBoomByBuffBoomFromPos( k1 , fromPos )
			end

			itemView:hideBuffBoom()
		end

		theAction.jsq = 0
		theAction.addInfo = "watingForFly"
	end

end

function GlobalCoreActionLogic:runLogic_ExplodeBuffItem(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "startBoom" then
		theAction.jsq = theAction.jsq + 1
		--printx( 1 , "GlobalCoreActionLogic:runLogic_DecBuffItem  ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~ " , theAction.jsq)
		if theAction.jsq == 38 then
			theAction.addInfo = "fly"
		end
	elseif theAction.addInfo == "watingForFly" then
		theAction.jsq = theAction.jsq + 1
		--printx( 1 , "GlobalCoreActionLogic:runLogic_DecBuffItem  ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~ " , theAction.jsq)
		if theAction.jsq == 35 then
			theAction.addInfo = "explode"
		end
	elseif theAction.addInfo == "explode" then

		local function explodeItem(r,c ,specialAtSnail)

			local bitem = nil
			if mainLogic.gameItemMap[r] then
				bitem = mainLogic.gameItemMap[r][c]
			end

			if bitem then
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)
				BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, 1, actId)

				SpecialCoverLogic:specialCoverChainsAroundPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft})
				if specialAtSnail or true then
					SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
				end
				GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
			end

			--mainLogic:setNeedCheckFalling()
		end


		local booms = theAction.booms

		for k,v in ipairs(booms) do
			local r = v.r
			local c = v.c

			local item = mainLogic.gameItemMap[r][c]
			item:cleanAnimalLikeData()
			item.isNeedUpdate = true
			mainLogic:checkItemBlock(r, c)
			explodeItem( r , c )
			
			local targetList = v.targetList

			for k1 , v1 in ipairs(targetList) do
				local targetItem = mainLogic.gameItemMap[v1.r][v1.c]
				explodeItem( v1.r , v1.c )
			end
		end

		mainLogic:setNeedCheckFalling()
		FallingItemLogic:preUpdateHelpMap(mainLogic)

		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic:setNeedCheckFalling()

		mainLogic.globalCoreActionList[actid] = nil
		
	end
end

function GlobalCoreActionLogic:runView_DecBuffItem(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		--printx( 1 , "GlobalCoreActionLogic:runView_DecBuffItem  ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~ ")
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y

		local itemView = boardView.baseMap[r][c]
		itemView:decBuffBoomToLevel( theAction.tarLevel )

		theAction.jsq = 0
		theAction.addInfo = "watingForAnimation"
	end
end

function GlobalCoreActionLogic:runLogic_DecBuffItem(mainLogic, theAction, actid, actByView)

	--printx( 1 , "GlobalCoreActionLogic:runLogic_DecBuffItem  ~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~ " ,theAction.addInfo, theAction.jsq)

	if theAction.addInfo == "watingForAnimation" then
		theAction.jsq = theAction.jsq + 1
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		
		local item = mainLogic.gameItemMap[r][c]

		if theAction.jsq == 1 then
			-- item.flag = true
			-- mainLogic:checkItemBlock(r,c)
		elseif theAction.jsq == 50 then
			item.flag = false
			mainLogic:checkItemBlock(r,c)
			theAction.addInfo = "decBuff"
		end
	elseif theAction.addInfo == "decBuff" then

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = nil

		if mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] then
			item = mainLogic.gameItemMap[r][c]
		end

		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then

		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_AddBuffItemToBoard(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function callback()
			theAction.addInfo = "over"
		end

		--[[
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playWeeklyBossHit(boardView, theAction.addInt)
		callback()
		]]

		local animeType = theAction.animeType
		local animeDelay = 180

		local scene = Director:sharedDirector():getRunningSceneLua()

		local function playBoomEff(targetPos)
			local boomEff = ArmatureNode:create("BuffInitFlyInAnimation/boomEff")
			boomEff:playByIndex(0)
			boomEff:update(0.001) -- 此处的参数含义为时间

			boomEff:setPosition( ccp( targetPos.x , targetPos.y ) )

			if scene then
				scene:addChild(boomEff)
			end

			boomEff:addEventListener(ArmatureEvents.COMPLETE, function () 
					if scene and not scene.isDisposed then
						scene:removeChild(boomEff)
					end
				end)
		end

        local function playDragonBoomEff(targetPos)
			local boomEff = ArmatureNode:create("dragonbuff/boomEff")
			boomEff:playByIndex(0)
			boomEff:update(0.001) -- 此处的参数含义为时间

			boomEff:setPosition( ccp( targetPos.x , targetPos.y ) )

			if scene then
				scene:addChild(boomEff)
			end

			boomEff:addEventListener(ArmatureEvents.COMPLETE, function () 
					if scene and not scene.isDisposed then
						scene:removeChild(boomEff)
					end
				end)
		end

		--FrameLoader:loadArmature(PreBuffLogic:getInitFlyAnimSkeletonSourceName())

		if animeType == AddGameInitBuffAnimeType.kPreBuffActivity2017 then

			local skeletonId = tonumber(theAction.animeTypeParameter) or 1
			if skeletonId < 1 or skeletonId > 5 then skeletonId = 1 end
			
			local skeletonAnimeName = "BuffInitFlyInAnimation/AddBuff_" .. tostring(skeletonId)
			local skeletonAnime = ArmatureNode:create( skeletonAnimeName )
			skeletonAnime:playByIndex(0)
			skeletonAnime:update(0.001) -- 此处的参数含义为时间
			--skeletonAnime:playByIndex(0)

			local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
			local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
			--local ori_getVisibleSize =  CCDirector:sharedDirector():ori_getVisibleSize()

			local tx = visibleOrigin.x + (visibleSize.width / 2)
			local ty = visibleOrigin.y + (visibleSize.height * 2 / 3)


			skeletonAnime:setPosition( ccp( tx - 0 , ty - 0 ) )

			local trueMask = LayerColor:create()
			trueMask:changeWidthAndHeight( visibleSize.width , visibleSize.height + 9999)
			trueMask:setTouchEnabled(true, 0, true)
			trueMask:setOpacity(255*0.7)

			
			if scene then
				scene:addChild( trueMask )
				scene:addChild( skeletonAnime )
			end

			skeletonAnime:addEventListener(ArmatureEvents.COMPLETE, function () 
				if scene and not scene.isDisposed then
					scene:removeChild(skeletonAnime)
					scene:removeChild(trueMask)
				end
			end)

			local function onBubbleBreak()
				
				if boardView.isDisposed or not boardView.baseMap then
					return
				end	

				local initBuffResult = theAction.initBuffResult

				for k,v in pairs( initBuffResult ) do
					local tarR = v.r
					local tarC = v.c
					local tarItem = v.item
					local tarItemSpecialType = v.tarItemSpecialType
					local buffType = v.buffType

					local itemView = nil

					if boardView.baseMap[tarR] and boardView.baseMap[tarR][tarC] then
						itemView = boardView.baseMap[tarR][tarC]
					end

					if itemView --[[ and buffType == 4 ]] then

						local tarItemPos = itemView:getBasePosition( tarC , tarR )
						local globalTagPos = boardView:convertToWorldSpace( tarItemPos )

						local function getAngle( tarPos , fromPos )

							local len_y = tarPos.y - fromPos.y
							local len_x = tarPos.x - fromPos.x

							local tan_yx = math.abs( len_y / len_x )

							local angle = 0

							if len_y >= 0 and len_x <= 0 then
							   angle = math.atan( tan_yx ) * 180/math.pi - 90
							elseif len_y >= 0 and len_x >= 0 then
							   angle = 90 - math.atan( tan_yx ) * 180/math.pi
							elseif len_y <= 0 and len_x <= 0 then
							   angle = -math.atan( tan_yx ) * 180/math.pi - 90
							elseif len_y <= 0 and len_x >= 0 then
							   angle = math.atan( tan_yx ) * 180/math.pi + 90
							end
							return angle
						end

						local flyEff = ArmatureNode:create("BuffInitFlyInAnimation/FlyEff")
						flyEff:playByIndex(0)
						flyEff:update(0.001) -- 此处的参数含义为时间

						flyEff:setPosition( ccp( tx , ty ) )
						local angle = getAngle( globalTagPos , ccp( tx , ty ) ) - 0
						--printx( 1 , "angle ===================================================== " , angle)
						flyEff:setRotation( angle - 90 ) -- 素材默认方向朝右

						local actArr = CCArray:create()
					    actArr:addObject( CCEaseSineOut:create( CCMoveTo:create( 0.5 , globalTagPos ) ) )
					    actArr:addObject(CCCallFunc:create(function ()
					        if scene and not scene.isDisposed then
					        	scene:removeChild( flyEff )
					        end

					        playBoomEff(globalTagPos)
					        theAction.addInfo = "doAddBuff"
					    end))
					   	
					   	flyEff:runAction( CCSequence:create(actArr) )

						if scene then
							scene:addChild(flyEff)
						end

					end
				end

			end
			

			setTimeOut( onBubbleBreak , 2.8 )


			animeDelay = 102 + 1 --已废弃
		elseif animeType == AddGameInitBuffAnimeType.kPreBuffActivity2018 then

			local iconSpriteFrame = 'prebuff_icon_res/sp/' .. tostring(theAction.animeTypeParameter) .. '0000'
			local UIHelper = require 'zoo.panel.UIHelper'
            local icon = UIHelper:createSpriteFrame('ui/prebuff_icons.json', iconSpriteFrame)
			

			local skeletonAnimeName = "BuffInitFlyInAnimation/AddBuff_Holder"
			local skeletonAnime = ArmatureNode:create( skeletonAnimeName )

			if icon then
				local cons = skeletonAnime:getCon('icon')
				cons:addChild(icon.refCocosObj)
				icon:setPosition(ccp(105, 105))
			end

			skeletonAnime:playByIndex(0)
			skeletonAnime:update(0.001) -- 此处的参数含义为时间
			--skeletonAnime:playByIndex(0)

			local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
			local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
			--local ori_getVisibleSize =  CCDirector:sharedDirector():ori_getVisibleSize()

			local tx = visibleOrigin.x + (visibleSize.width / 2)
			local ty = visibleOrigin.y + (visibleSize.height * 2 / 3)


			skeletonAnime:setPosition( ccp( tx - 0 , ty - 0 ) )

			local trueMask = LayerColor:create()
			trueMask:changeWidthAndHeight( visibleSize.width , visibleSize.height + 9999)
			trueMask:setTouchEnabled(true, 0, true)
			trueMask:setOpacity(255*0.7)

			
			if scene then
				scene:addChild( trueMask )
				scene:addChild( skeletonAnime )
			end

			skeletonAnime:addEventListener(ArmatureEvents.COMPLETE, function () 
				if scene and not scene.isDisposed then
					scene:removeChild(skeletonAnime)
					scene:removeChild(trueMask)
					if icon and (not icon.isDisposed) then
						icon:dispose()
					end
				end
			end)

			local function onBubbleBreak()
				
				if boardView.isDisposed or not boardView.baseMap then
					return
				end	

				local initBuffResult = theAction.initBuffResult

				for k,v in pairs( initBuffResult ) do
					local tarR = v.r
					local tarC = v.c
					local tarItem = v.item
					local tarItemSpecialType = v.tarItemSpecialType
					local buffType = v.buffType

					local itemView = nil

					if boardView.baseMap[tarR] and boardView.baseMap[tarR][tarC] then
						itemView = boardView.baseMap[tarR][tarC]
					end

					if itemView --[[ and buffType == 4 ]] then

						local tarItemPos = itemView:getBasePosition( tarC , tarR )
						local globalTagPos = boardView:convertToWorldSpace( tarItemPos )

						local function getAngle( tarPos , fromPos )

							local len_y = tarPos.y - fromPos.y
							local len_x = tarPos.x - fromPos.x

							local tan_yx = math.abs( len_y / len_x )

							local angle = 0

							if len_y >= 0 and len_x <= 0 then
							   angle = math.atan( tan_yx ) * 180/math.pi - 90
							elseif len_y >= 0 and len_x >= 0 then
							   angle = 90 - math.atan( tan_yx ) * 180/math.pi
							elseif len_y <= 0 and len_x <= 0 then
							   angle = -math.atan( tan_yx ) * 180/math.pi - 90
							elseif len_y <= 0 and len_x >= 0 then
							   angle = math.atan( tan_yx ) * 180/math.pi + 90
							end
							return angle
						end

						local flyEff = ArmatureNode:create("BuffInitFlyInAnimation/FlyEff")
						flyEff:playByIndex(0)
						flyEff:update(0.001) -- 此处的参数含义为时间

						flyEff:setPosition( ccp( tx , ty ) )
						local angle = getAngle( globalTagPos , ccp( tx , ty ) ) - 0
						--printx( 1 , "angle ===================================================== " , angle)
						flyEff:setRotation( angle - 90 ) -- 素材默认方向朝右

						local actArr = CCArray:create()
					    actArr:addObject( CCEaseSineOut:create( CCMoveTo:create( 0.5 , globalTagPos ) ) )
					    actArr:addObject(CCCallFunc:create(function ()
					        if scene and not scene.isDisposed then
					        	scene:removeChild( flyEff )
					        end

					        playBoomEff(globalTagPos)
					        theAction.addInfo = "doAddBuff"
					    end))
					   	
					   	flyEff:runAction( CCSequence:create(actArr) )

						if scene then
							scene:addChild(flyEff)
						end

					end
				end

			end
			

			setTimeOut( onBubbleBreak , 2.8 )


			animeDelay = 102 + 1 --已废弃
        elseif animeType == AddGameInitBuffAnimeType.kDragonBuff2018 then
            local skeletonId = tonumber(theAction.animeTypeParameter) or 1
			if skeletonId < 1 or skeletonId > 5 then skeletonId = 1 end
			
            FrameLoader:loadArmature('skeleton/dragonbuff')
			local skeletonAnimeName = "dragonbuff/AddBuff_" .. tostring(skeletonId)
			local skeletonAnime = ArmatureNode:create( skeletonAnimeName )
			skeletonAnime:playByIndex(0)
			skeletonAnime:update(0.001) -- 此处的参数含义为时间
			--skeletonAnime:playByIndex(0)

			local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
			local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
			--local ori_getVisibleSize =  CCDirector:sharedDirector():ori_getVisibleSize()

			local tx = visibleOrigin.x + (visibleSize.width / 2)
			local ty = visibleOrigin.y + (visibleSize.height / 2 )

            local offset = -29
			skeletonAnime:setPosition( ccp( tx + offset , ty - 0 ) )

			local trueMask = LayerColor:create()
			trueMask:changeWidthAndHeight( visibleSize.width , visibleSize.height + 9999)
			trueMask:setTouchEnabled(true, 0, true)
			trueMask:setOpacity(255*0.7)

			
			if scene then
				scene:addChild( trueMask )
				scene:addChild( skeletonAnime )
			end

			skeletonAnime:addEventListener(ArmatureEvents.COMPLETE, function () 
				if scene and not scene.isDisposed then
					scene:removeChild(skeletonAnime)
					scene:removeChild(trueMask)
				end
			end)

			local function onBubbleBreak()
				
				if boardView.isDisposed or not boardView.baseMap then
					return
				end	

				local initBuffResult = theAction.initBuffResult

				for k,v in pairs( initBuffResult ) do
					local tarR = v.r
					local tarC = v.c
					local tarItem = v.item
					local tarItemSpecialType = v.tarItemSpecialType
					local buffType = v.buffType

					local itemView = nil

					if boardView.baseMap[tarR] and boardView.baseMap[tarR][tarC] then
						itemView = boardView.baseMap[tarR][tarC]
					end

					if itemView --[[ and buffType == 4 ]] then

						local tarItemPos = itemView:getBasePosition( tarC , tarR )
						local globalTagPos = boardView:convertToWorldSpace( tarItemPos )

						local function getAngle( tarPos , fromPos )

							local len_y = tarPos.y - fromPos.y
							local len_x = tarPos.x - fromPos.x

							local tan_yx = math.abs( len_y / len_x )

							local angle = 0

							if len_y >= 0 and len_x <= 0 then
							   angle = math.atan( tan_yx ) * 180/math.pi - 90
							elseif len_y >= 0 and len_x >= 0 then
							   angle = 90 - math.atan( tan_yx ) * 180/math.pi
							elseif len_y <= 0 and len_x <= 0 then
							   angle = -math.atan( tan_yx ) * 180/math.pi - 90
							elseif len_y <= 0 and len_x >= 0 then
							   angle = math.atan( tan_yx ) * 180/math.pi + 90
							end
							return angle
						end

						local flyEff = ArmatureNode:create("dragonbuff/FlyEff")
						flyEff:playByIndex(0)
						flyEff:update(0.001) -- 此处的参数含义为时间

						flyEff:setPosition( ccp( tx , ty ) )
						local angle = getAngle( globalTagPos , ccp( tx , ty ) ) - 0
						--printx( 1 , "angle ===================================================== " , angle)
						flyEff:setRotation( angle - 90 ) -- 素材默认方向朝右

						local actArr = CCArray:create()
					    actArr:addObject( CCEaseSineOut:create( CCMoveTo:create( 0.5 , globalTagPos ) ) )
					    actArr:addObject(CCCallFunc:create(function ()
					        if scene and not scene.isDisposed then
					        	scene:removeChild( flyEff )
					        end

					        playDragonBoomEff(globalTagPos)
					        theAction.addInfo = "doAddBuff"
					    end))
					   	
					   	flyEff:runAction( CCSequence:create(actArr) )

						if scene then
							scene:addChild(flyEff)
						end

					end
				end

			end
			

			setTimeOut( onBubbleBreak , 2.2 )


			animeDelay = 102 + 1 --已废弃
		else
			--CommonTip:showTip("恭喜你获得开局特效！", "negative", nil, 3)

			local initBuffResult = theAction.initBuffResult

			for k,v in pairs( initBuffResult ) do
				local tarR = v.r
				local tarC = v.c
				local tarItem = v.item
				local tarItemSpecialType = v.tarItemSpecialType
				local buffType = v.buffType

				local itemView = nil

				if boardView.baseMap[tarR] and boardView.baseMap[tarR][tarC] then
					itemView = boardView.baseMap[tarR][tarC]
				end

				if itemView then
					local tarItemPos = itemView:getBasePosition( tarC , tarR )
					local globalTagPos = boardView:convertToWorldSpace( tarItemPos )
					playBoomEff(globalTagPos)
				end
			end
			animeDelay = 40 + 1


			setTimeOut( function () theAction.addInfo = "doAddBuff"  end , 0.66 )
		end

		
		theAction.animeDelay = animeDelay
		theAction.jsq = 0
		theAction.addInfo = "watingForAnimation"
	end
end

function GlobalCoreActionLogic:runLogic_AddBuffItemToBoard(mainLogic, theAction, actid, actByView)

	--printx( 1 , "GlobalCoreActionLogic:runLogic_AddBuffItemToBoard     theAction.addInfo" , theAction.addInfo , theAction.jsq)

	if theAction.addInfo == "watingForAnimation" then
		theAction.jsq = theAction.jsq + 1
		--printx( 1 , "GlobalCoreActionLogic:runLogic_AddBuffItemToBoard  test" , theAction.jsq)

		--[[
		if theAction.jsq == theAction.animeDelay then
			theAction.addInfo = "doAddBuff"
		end
		]]
	elseif theAction.addInfo == "doAddBuff" then

		local initBuffResult = theAction.initBuffResult

		for k,v in pairs( initBuffResult ) do
			local tarR = v.r
			local tarC = v.c
			local tarItem = v.item
			local tarItemSpecialType = v.tarItemSpecialType
			local buffType = v.buffType

			local item = nil

			if mainLogic.gameItemMap[tarR] and mainLogic.gameItemMap[tarR][tarC] then
				item = mainLogic.gameItemMap[tarR][tarC]
			end

			if item then
				if buffType == InitBuffType.BUFF_BOOM then
					--item:changeToBuffBoom()
					item.ItemType = GameItemType.kBuffBoom
					item.level = 3
					item.flag = false
					item:AddItemStatus( GameItemStatusType.kNone , true )
					item._encrypt.ItemColorType = 0
					item.ItemSpecialType = 0
					item.isNeedUpdate = true
				elseif buffType == InitBuffType.FIRECRACKER then
					item.ItemType = GameItemType.kFirecracker
					mainLogic.generateFirecrackerTimesForPreBuff = mainLogic.generateFirecrackerTimesForPreBuff + 1
					item.isNeedUpdate = true
                elseif buffType == InitBuffType.RANDOM_BIRD then
					--item:changeToBuffBoom()
					item.ItemType = GameItemType.kAnimal
					item:changeItemType(0, tarItemSpecialType )
					item.isNeedUpdate = true
				else
					item.ItemType = GameItemType.kAnimal
					item:changeItemType(tarItem._encrypt.ItemColorType, tarItemSpecialType )
					item.isNeedUpdate = true
				end
			end

			mainLogic:checkItemBlock(tarR,tarC)
		end

		--[[
		if mainLogic.boardView then
			mainLogic.boardView:updateItemViewByLogic()			----界面展示刷新
			mainLogic.boardView:updateItemViewSelf()				----界面自我刷新
		end
		]]

		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then

		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic:setNeedCheckFalling()

		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_AddBuffAdd3Step(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function allPrePropFinishCallback()
			theAction.addInfo = "over"
		end
		boardView.PlayUIDelegate:playPreGamePropAddStepAnim(theAction.data, allPrePropFinishCallback)
		setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPropAdd3stepFlyon ) end , 1 )
	end
end

function GlobalCoreActionLogic:runLogic_AddBuffAdd3Step(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback( theAction.fromGuide )
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_AddBuffRefresh(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function allPrePropFinishCallback()
			theAction.addInfo = "over"
		end
		boardView.PlayUIDelegate:playPreGamePropAddToBarAnim(theAction.data, allPrePropFinishCallback, theAction.fromGuide)
		setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPropSwap ) end , 1 )
	end
end

function GlobalCoreActionLogic:runLogic_AddBuffRefresh(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback( theAction.fromGuide )
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_AddBuffSpecialAnimal(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function allPrePropFinishCallback()
			theAction.addInfo = "over"
		end
		local function animFinishCallback()
			theAction.addInfo = "add"
		end
		local function buildData(specialType, r, c)
			return {type = specialType, r = r, c = c, pos = boardView.gameBoardLogic:getGameItemPosInView_ForPreProp(r, c)}
		end
		
		local validData = true
		local data = theAction.data
		local pos = theAction.pos
		local lineData = nil
		local wrapData = nil
		if theAction.buffType == InitBuffType.LINE_WRAP then
			lineData = buildData(theAction.tarItemSpecialType, pos.r, pos.c)
			local pos2 = theAction.pos2
			wrapData = buildData(theAction.tarItemSpecialType2, pos2.r, pos2.c)
		elseif theAction.buffType == InitBuffType.LINE then
			lineData = buildData(theAction.tarItemSpecialType, pos.r, pos.c)
		elseif theAction.buffType == InitBuffType.WRAP 
			or theAction.buffType == InitBuffType.RANDOM_BIRD
			or theAction.buffType == InitBuffType.BUFF_BOOM
			or theAction.buffType == InitBuffType.FIRECRACKER
			then
			wrapData = buildData(theAction.tarItemSpecialType, pos.r, pos.c)
		else
			validData = false
		end

		if validData then
			boardView.PlayUIDelegate:playCommonAddPrePropEffect(
				theAction.buffType, data, lineData, wrapData, animFinishCallback, allPrePropFinishCallback)
		else
			allPrePropFinishCallback()
		end

		setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPropAdd3stepFlyon ) end , 1 )
	end
end

function GlobalCoreActionLogic:runLogic_AddBuffSpecialAnimal(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "add" then
		local pos = theAction.pos
		local tarR, tarC = pos.r, pos.c
		local item = mainLogic.gameItemMap[tarR][tarC]
		-- printx(11, "= = GlobalCoreActionLogic:runLogic_AddBuffSpecialAnimal")
		-- printx(11, "buffType:"..theAction.buffType..", tarItemSpecialType:"..theAction.tarItemSpecialType)
		-- printx(11, "tarItemType:", theAction.tarItemType)
		if theAction.buffType == InitBuffType.BUFF_BOOM then
			item.ItemType = GameItemType.kBuffBoom
			item.level = 3
			item.flag = false
			item:AddItemStatus( GameItemStatusType.kNone , true )
			item._encrypt.ItemColorType = 0
			item.ItemSpecialType = 0
		else
			local tarColor = theAction.tarItemColorType
			if theAction.tarItemType then
				item.ItemType = theAction.tarItemType
				mainLogic.generateFirecrackerTimes = mainLogic.generateFirecrackerTimes + 1
			else
				local tarItemSpecialType = theAction.tarItemSpecialType
				item.ItemType = GameItemType.kAnimal
				item:changeItemType(tarColor, tarItemSpecialType )
			end
		end
		item.isNeedUpdate = true

		if theAction.pos2 then
			local pos = theAction.pos2
			local tarColor = theAction.tarItemColorType2
			local tarItemSpecialType = theAction.tarItemSpecialType2
			local tarR, tarC = pos.r, pos.c
			local item = mainLogic.gameItemMap[tarR][tarC]
			item.ItemType = GameItemType.kAnimal
			item:changeItemType(tarColor, tarItemSpecialType )
			item.isNeedUpdate = true
		end
		theAction.addInfo = "waitOver"
	elseif theAction.addInfo == "over" then

		mainLogic:setNeedCheckFalling()
		
		if theAction.completeCallback then
			theAction.completeCallback( theAction.fromGuide )
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_ItemGiveBack(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function allPrePropFinishCallback()
			theAction.addInfo = "over"
		end
		local data = theAction.data
		boardView.PlayUIDelegate:playGiveBackPreProp(data, allPrePropFinishCallback)
	end
end

function GlobalCoreActionLogic:runLogic_ItemGiveBack( mainLogic , theAction , actid )
	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback( theAction.fromGuide )
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

-----------------------------------------------------------------------------------------------------
--										MOLE WEEKLY RACE
-----------------------------------------------------------------------------------------------------
function GlobalCoreActionLogic:runView_MoleWeeklyBossCreate(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

        theAction.addInfo = "initBossData"
	end

	local bossData

    if theAction.addInfo == "initBossView" then
        local function finish()
			theAction.addInfo = "InitEnd"
		end

		bossData = boardView.gameBoardLogic:getMoleWeeklyBossData()
        if boardView.PlayUIDelegate and bossData then
        	local currBossSkillList = MoleWeeklyRaceConfig:getCurrSkillTypeArr(bossData.bossGroupID)
			boardView.PlayUIDelegate:initBossBee(currBossSkillList)
            boardView.PlayUIDelegate:playBossFlyUp(finish)
        else
            finish()
		end

        theAction.addInfo = ""
    end

    if theAction.addInfo == "InitEnd" then
        if boardView.PlayUIDelegate then
            local bossData = boardView.gameBoardLogic:getMoleWeeklyBossData()
		    boardView.PlayUIDelegate:initBossBeeHP( bossData.totalBlood )

            theAction.addInfo = "over"
        else
            theAction.addInfo = "over"
        end
    end
end

function GlobalCoreActionLogic:runLogic_MoleWeeklyBossCreate(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "initBossData" then
		-- if _G.isLocalDevelopMode then printx(0, '***************** Mole Weekly Boss Create') end
		mainLogic:initMoleWeeklyBoss(MoleWeeklyRaceConfig.genNewBoss(mainLogic))
        theAction.addInfo = "initBossView"
	end

	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_MoleWeeklyBossSkill(boardView, theAction)
	local bossAnimationDelay = 20
	local skillFlyAnimationDelay = 25
	local thickHoneyCoverAnimationDelay = 35
	local bossSeedDemolishAnimationDelay = 25
	local bossSeedCountDownAnimationDelay = 30

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
		theAction.addInfo = "actionStartPeriod"
	end

	if theAction.actionStatus == GameActionStatus.kRunning then

		if theAction.addInfo == "actionStartPeriod" then
			if theAction.skillType == MoleWeeklyBossSkillType.SUB_SEED_COUNT_DOWN 
	        	or theAction.skillType == MoleWeeklyBossSkillType.SUB_ADD_SPECIAL then
	        	theAction.addInfo = "executeSkill"
	        else
		        if boardView.PlayUIDelegate and boardView.PlayUIDelegate.bossBeeController and boardView.PlayUIDelegate.BossSkillController then
					boardView.PlayUIDelegate.bossBeeController:playCast()
	                boardView.PlayUIDelegate.BossSkillController:PlayAttack(theAction.skillType)
	                theAction.addInfo = "bossAnimation"
		        else
		            theAction.addInfo = "executeSkill"
				end
			end

		elseif theAction.addInfo == "bossAnimation" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == bossAnimationDelay then
				theAction.addInfo = "executeSkill"
			end

		elseif theAction.addInfo == "executeSkill" then
			theAction.jsq = 0

		    local itemView
		    local bossWorldPos = ccp(0,0)
		    if boardView.PlayUIDelegate and  boardView.PlayUIDelegate.BossSkillController then
			    bossWorldPos = boardView.PlayUIDelegate.BossSkillController:getSkillCirclePos( theAction.skillType )
		    end

		    if theAction.targetList and #theAction.targetList > 0 then
			    for k, v in pairs(theAction.targetList) do 
				    local x, y = v.x, v.y
					local targetCoord = {r = x, c = y}
				    -- printx(11, "= = = RUN view. Target:("..x..","..y..")")

				    if theAction.skillType == MoleWeeklyBossSkillType.THICK_HONEY or
				    	theAction.skillType == MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL or 
					    theAction.skillType == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE or 
					    theAction.skillType == MoleWeeklyBossSkillType.SEED or 
					    theAction.skillType == MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK or
					    theAction.skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_1 or 
					    theAction.skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_2 
					    then

					    if theAction.skillType == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then
						    local item = boardView.baseMap[x][y]
						    if item then
							    item:addMoleMagicTileCoverAnimation()
							    item.isNeedUpdate = true
						    end
					    elseif theAction.skillType == MoleWeeklyBossSkillType.SEED then
						    itemView = boardView.baseMap[x][y]
						    itemView:replaceWithMoleBossSeed()
					    end

                        local toPos = boardView.PlayUIDelegate:_getPositionFromGridCoord(targetCoord)
				        boardView.PlayUIDelegate:playLightFlyingEffect(bossWorldPos, toPos)
						theAction.addInfo = "skillFlyAnimation"
				    elseif theAction.skillType == MoleWeeklyBossSkillType.SUB_ADD_SPECIAL then
					    itemView = boardView.baseMap[y][x]
					    itemView:playMoleBossSeedDemolish()
					    theAction.addInfo = "bossSeedDemolishAnimation"
				    elseif theAction.skillType == MoleWeeklyBossSkillType.SUB_SEED_COUNT_DOWN then
					    itemView = boardView.baseMap[y][x]
					    itemView:playMoleBossSeedCountDown()
					    theAction.addInfo = "bossSeedCountDownAnimation"
				    end
			    end
		    else
			    theAction.addInfo = "actionFinished"
		    end

		elseif theAction.addInfo == "skillFlyAnimation" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == skillFlyAnimationDelay then
				theAction.addInfo = "actionFinished"
			end

		elseif theAction.addInfo == "bossSeedDemolishAnimation" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == bossSeedDemolishAnimationDelay then
				theAction.addInfo = "actionFinished"
			end

		elseif theAction.addInfo == "bossSeedCountDownAnimation" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == bossSeedCountDownAnimationDelay then
				theAction.addInfo = "actionFinished"
			end
			
		elseif theAction.addInfo == "actionFinished" then
			theAction.addInfo = "over"
		end
	end
end

function GlobalCoreActionLogic:runLogic_MoleWeeklyBossSkill(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then

		local tItem
		if theAction.targetList and #theAction.targetList > 0 then
			for k, v in pairs(theAction.targetList) do 
				if theAction.skillType == MoleWeeklyBossSkillType.THICK_HONEY then
					tItem = mainLogic.gameItemMap[v.x][v.y]
					tItem.honeyLevel = 2
					mainLogic:checkItemBlock(v.x, v.y)
					tItem.isNeedUpdate = true
				elseif theAction.skillType == MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL then
					tItem = mainLogic.gameItemMap[v.x][v.y]
					tItem.ItemType = GameItemType.kBlackCuteBall
					tItem.isBlock = false
					tItem._encrypt.ItemColorType = 0
					tItem.ItemSpecialType = 0
					tItem.isEmpty = false
					tItem.blackCuteStrength = 1
					tItem.blackCuteMaxStrength = tItem.blackCuteStrength
					tItem.isNeedUpdate = true
				elseif theAction.skillType == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then
					local boardItem = mainLogic.boardmap[v.x][v.y]
					boardItem.magicTileDisabledRound = theAction.param2
				elseif theAction.skillType == MoleWeeklyBossSkillType.SEED then
					tItem = mainLogic.gameItemMap[v.x][v.y]
					tItem.ItemType = GameItemType.kMoleBossSeed
					tItem.moleBossSeedHP = 1
					tItem.moleBossSeedCountDown = 2
					tItem.isBlock = false
					tItem._encrypt.ItemColorType = 0
					tItem.ItemSpecialType = 0
					tItem.isEmpty = false
					tItem.isNeedUpdate = true
				elseif theAction.skillType == MoleWeeklyBossSkillType.SUB_ADD_SPECIAL then
					tItem = mainLogic.gameItemMap[v.y][v.x]
					tItem.ItemType = GameItemType.kAnimal
					tItem._encrypt.ItemColorType = mainLogic:randomColor()
					local list = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn, AnimalTypeConfig.kWrap}
					tItem.ItemSpecialType = list[mainLogic.randFactory:rand(1, #list)]
					tItem.isNeedUpdate = true
					mainLogic:addNeedCheckMatchPoint(v.y, v.x)
				elseif theAction.skillType == MoleWeeklyBossSkillType.SUB_SEED_COUNT_DOWN then
					tItem = mainLogic.gameItemMap[v.y][v.x]
					if theAction.changeToGrass then
						tItem.ItemType = GameItemType.kDigGround
						tItem.digGroundLevel = 1
						tItem.isBlock = true
						tItem._encrypt.ItemColorType = 0
						tItem.ItemSpecialType = 0
						tItem.isEmpty = false
						tItem.isNeedUpdate = true
						mainLogic:checkItemBlock(v.y, v.x)
					else
						tItem.moleBossSeedCountDown = tItem.moleBossSeedCountDown - 1
					end
				elseif theAction.skillType == MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK then
					MoleWeeklyRaceLogic:initMoleBossCloudBlock(mainLogic, v.x, v.y)
				elseif theAction.skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_1 
					or theAction.skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_2 then
					local cloudLevel = 1
					if theAction.skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_2 then cloudLevel = 2 end
					tItem = mainLogic.gameItemMap[v.x][v.y]
					tItem.ItemType = GameItemType.kDigJewel
					tItem.digJewelLevel = cloudLevel
					tItem.isBlock = true
					tItem._encrypt.ItemColorType = 0
					tItem.ItemSpecialType = 0
					tItem.isEmpty = false
					tItem.isNeedUpdate = true
					mainLogic:checkItemBlock(v.x, v.y)
				end
			end
			FallingItemLogic:preUpdateHelpMap( mainLogic )
		end

		MoleWeeklyRaceLogic:setSkillFlagForGuide(mainLogic, theAction.skillType)
		theAction.addInfo = "end"
		
	elseif theAction.addInfo == "end" then
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_MoleWeeklyBossDie(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		if boardView.PlayUIDelegate then
            theAction.diePosition = boardView.PlayUIDelegate.bossBeeController.BossNode:getPosition()
			boardView.PlayUIDelegate:bossBeeDie(finish)
			theAction.jsq = 0
			theAction.addInfo = "playAnimation"
		else
			-- theAction.addInfo = "addTarget"
			theAction.addInfo = "over"
		end
	end

	if theAction.addInfo == "playAnimation" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 5 then
			-- theAction.addInfo = "addTarget"
			theAction.addInfo = "over"
		end
	end	
end

function GlobalCoreActionLogic:runLogic_MoleWeeklyBossDie(mainLogic, theAction, actid, actByView)
	-- if theAction.addInfo == "addTarget" then
	-- 	local pos = {}
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(8.5, -0.5))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(7.8, 0.7))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(8.7, 2.2))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(8.0, 3.1))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(9.1, 4.1))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(7.7, 4.7))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(7.6, 5.6))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(8.6, 8.0))
	-- 	table.insert(pos, mainLogic:getGameItemPosInView(7.7, 8.9))

	-- 	local currDigJewelCount = mainLogic.digJewelCount:getValue()
	-- 	for k, v in pairs(pos) do
	-- 		if mainLogic.PlayUIDelegate then
	-- 			mainLogic.PlayUIDelegate:setTargetNumber(0, 1, currDigJewelCount , v)
	-- 		end
	-- 	end

	-- 	theAction.addInfo = "over"
	-- end

	if theAction.addInfo == "over" then
		mainLogic:onMoleWeeklyBossDie(theAction.diePosition)
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end


function GlobalCoreActionLogic:runView_SummerFishFlyLogic(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

        local vo = Director:sharedDirector():getVisibleOrigin()
	    local vs = Director:sharedDirector():getVisibleSize()

        local node = theAction.node
        local globalPosition = theAction.globalPosition
        local nodeWidth = theAction.nodeWidth
        local offsetX = theAction.offsetX
        local aPartDelay = theAction.aPartDelay
        local FlyDelayTime = theAction.FlyDelayTime
        local icon = theAction.icon
        local SunmerFish3x3GetNum = theAction.SunmerFish3x3GetNum
        local csize = theAction.csize
        local scale = 1

        --3*3的鱼飞行动画不一样
        local UIHelper = require 'zoo.panel.UIHelper'

        --读取掉出来的鱼
        local FishItemList = {}
        local FishShadowList = {}
        for i=1, 5 do
            FishItemList[i] = UIHelper:getCon(node,"fish"..i)
            FishShadowList[i] = UIHelper:getCon(node,"shadow"..i)
        end

        --滚动数字
        local numbg = UIHelper:getCon(node,"number-stop")
        numbg:setOpacity(0)

        local label1Pos = ccp(41+22/0.7-51,39+13/0.7-33)
        local label2Pos = ccp(80+24/0.7-54,39+13/0.7-33)

        local label1 = Sprite:createWithSpriteFrameName("sea_animal_wenhao")
        label1:setPosition( label1Pos )
        label1:setAnchorPoint(ccp(0.5, 0.5))
        numbg:addChild( label1.refCocosObj )
        label1:dispose()

        local label2 = Sprite:createWithSpriteFrameName("sea_animal_wenhao")
        label2:setPosition( label2Pos )
        label2:setAnchorPoint(ccp(0.5, 0.5))
        numbg:addChild( label2.refCocosObj )
        label2:dispose()

        -- 防止动画飞出屏幕
	    local moveOffsetX = 0
	    local moveOffsetY = 0
	    if globalPosition.x > ( vo.x + vs.width - nodeWidth) then
		    moveOffsetX = offsetX
	    end

        local a = CCArray:create()
	    a:addObject(CCDelayTime:create(FlyDelayTime))
	    a:addObject(CCSpawn:createWithTwoActions(CCRotateBy:create(0.2, rotation), CCMoveBy:create(0.2, ccp(moveOffsetX, moveOffsetY))))
	    a:addObject(CCDelayTime:create(aPartDelay))	--2
	    a:addObject(CCCallFunc:create(
		    function ()
			    local centerPos = ccp(node:getGroupBounds():getMidX(), node:getGroupBounds():getMidY())
			    centerPos = node:convertToNodeSpace(centerPos)
			    local realAnchorPoint = ccp(centerPos.x/csize.width, centerPos.y/csize.height)
			    node:setAnchorPointWhileStayOriginalPosition(realAnchorPoint)
		    end
	    ))

	    -- local destPos = panel.icon:getPosition()
        local destPos = icon:getParent():convertToWorldSpace(icon:getPosition())

        local MoveEndNum = 0
        local ShowNum = 0
        local bNumberAniEnd = false

        function getDropNum( num )
            if num > 99 then
                num = 99
            end
            local num1 = 0
            local num2 = 0
            if num < 10 then
                num1 = 0
                num2 = num
            else
                num2 = num%10
                num1 = (num - num2)/10
            end

            return num1, num2
        end

        local function MoveEnd( NoAdd )
            if NoAdd then
                bAdd = false
            else
                bAdd = true
            end

            if bAdd then
                MoveEndNum = MoveEndNum + 1

                if MoveEndNum > 5 then
                    MoveEndNum = 5
                end

                for i=1, MoveEndNum do
                    FishItemList[i]:setVisible(false)
                end
            end

            if MoveEndNum == 5 and bNumberAniEnd then
                theAction.addInfo = "waitEnd"
            end
        end

        local function onNumberChange()

            if bNumberAniEnd then
                MoveEnd( 1 ) --数字播完 鱼飞完都会调用结束函数。看是否都满足条件了
                numbg:stopAllActions()
            end

            numbg:removeAllChildrenWithCleanup(true)

            ShowNum = ShowNum + 1
            if ShowNum > SunmerFish3x3GetNum  then
                ShowNum = SunmerFish3x3GetNum
            end
            local num1,num2 = getDropNum( ShowNum  )

            local label1 = Sprite:createWithSpriteFrameName("sea_animal_num"..num1)
            label1:setPosition( label1Pos )
            label1:setAnchorPoint(ccp(0.5, 0.5))
            numbg:addChild( label1.refCocosObj )
            label1:dispose()

            local label2 = Sprite:createWithSpriteFrameName("sea_animal_num"..num2)
            label2:setPosition( label2Pos )
            label2:setAnchorPoint(ccp(0.5, 0.5))
            numbg:addChild( label2.refCocosObj )
            label2:dispose()

            if SunmerFish3x3GetNum == ShowNum then
                bNumberAniEnd = true
            end
        end

        local function onFishMoveOut()

            --数字滚动
            local d = CCArray:create()
            d:addObject(CCDelayTime:create(0.05))
            d:addObject(CCCallFunc:create(onNumberChange))

            numbg:runAction(CCRepeatForever:create( CCSequence:create(d) ))

            --飞小鱼
            for i=1, 5 do
                local c = CCArray:create()

	            local b = CCArray:create()

                local FishDstPos = node:convertToNodeSpace(destPos)

	            b:addObject(CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(FishDstPos.x, FishDstPos.y))))
	            b:addObject(CCFadeTo:create(0.5, 30))
	            b:addObject(CCScaleTo:create(0.3, 0.3))

                c:addObject(CCDelayTime:create(0.5+i*0.2))	--2
                c:addObject(CCSpawn:create(b))	--2
                c:addObject(CCCallFunc:create(MoveEnd))

                FishItemList[i]:runAction(CCSequence:create(c))

                if FishShadowList[i] then 
                    local dd = CCArray:create()
                    dd:addObject(CCFadeOut:create(0.2+i*0.2))
                    FishShadowList[i]:runAction(CCSequence:create(dd))
                end
            end
        end

        a:addObject(CCCallFunc:create(onFishMoveOut))
	    node:runAction(CCSequence:create(a))

		theAction.addInfo = "playAnimation"
	end

	if theAction.addInfo == "waitEnd" then
		theAction.addInfo = "over"
	end
end

function GlobalCoreActionLogic:runLogic_SummerFishFlyView(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

-------------------------------------------------------------------------------
function GlobalCoreActionLogic:runView_GhostGenerate(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			for _, targetItem in ipairs(theAction.pickedTargets) do
				local gridView = boardView.baseMap[targetItem.y][targetItem.x]
				gridView:playGhostAppear(onGenerateJumpEnd)
			end
		end

		theAction.jsq = theAction.jsq + 1

		if theAction.jsq == 35 then
			theAction.addInfo = "over"
		end
	end
end

function GlobalCoreActionLogic:runLogic_GhostGenerate(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "over" then
		local generateNumByBoardMin = theAction.generateNumByBoardMin
		local generateNumByStep = theAction.generateNumByStep

		for _, targetItem in ipairs(theAction.pickedTargets) do
			GhostLogic:updateNewGhost(mainLogic, targetItem)
			if generateNumByBoardMin > 0 then
				mainLogic.ghostGeneratedByBoardMin = mainLogic.ghostGeneratedByBoardMin + 1
				generateNumByBoardMin = generateNumByBoardMin - 1
				-- printx(11, "add ghostGeneratedByBoardMin to: ", mainLogic.ghostGeneratedByBoardMin)
			else
				mainLogic.ghostGeneratedByStep = mainLogic.ghostGeneratedByStep + 1
				generateNumByStep = generateNumByStep - 1
				-- printx(11, "add ghostGeneratedByStep to: ", mainLogic.ghostGeneratedByStep)
			end

			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Ghost, ObstacleFootprintAction.k_Appear, 1)
		end

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end

end

------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
function GlobalCoreActionLogic:runView_AddScoreBuffBottle(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		setTimeOut(function () theAction.addInfo = "addData" end , theAction.preAnimationDelay + 0.15)
		
		theAction.jsq = 0
		theAction.addInfo = "waitingForAnimation"
	end
end

function GlobalCoreActionLogic:runLogic_AddScoreBuffBottle(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "waitingForAnimation" then
		theAction.jsq = theAction.jsq + 1

	elseif theAction.addInfo == "addData" then
		local targetItems = theAction.targetItems
		for _, item in pairs(targetItems) do
			item.ItemType = GameItemType.kScoreBuffBottle
			item.isNeedUpdate = true

			mainLogic.generatedScoreBuffBottle = mainLogic.generatedScoreBuffBottle + 1
		end
		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic:setNeedCheckFalling()
		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_BlastScoreBuffBottle(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			for _, targetItem in ipairs(theAction.targetItems) do
				local targetColour = targetItem._encrypt.ItemColorType
				local colourIndex = AnimalTypeConfig.convertColorTypeToIndex(targetColour)

				local gridView = boardView.baseMap[targetItem.y][targetItem.x]
				gridView:playScoreBuffBottleBlast(colourIndex)
			end
		end

		theAction.jsq = theAction.jsq + 1

		if theAction.jsq == 20 then
			theAction.addInfo = "updateData"
		end

		-- if theAction.jsq == 60 then
		-- 	theAction.addInfo = "over"
		-- end
	end
end

function GlobalCoreActionLogic:runLogic_BlastScoreBuffBottle(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "updateData" then
		for _, targetItem in ipairs(theAction.targetItems) do
			ScoreBuffBottleLogic:onDestroyScoreBuffBottle(mainLogic, targetItem)
		end

		theAction.addInfo = "over"
	end

	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.globalCoreActionList[actid] = nil
	end
end

------------------------------------------------------------------------------------------------------------------------------------
function GlobalCoreActionLogic:runView_BlastFirecracker(boardView, theAction)
	local targetFirecracker = theAction.targetFirecracker
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		if targetFirecracker then
			local r = targetFirecracker.y
			local c = targetFirecracker.x

			local itemView = boardView.baseMap[r][c]
			itemView:explodeFirecracker()
		else
			theAction.addInfo = "over"
			return
		end

		theAction.jsq = 0
		theAction.addInfo = "startBoom"

	elseif theAction.addInfo == "fly" then
		local r = targetFirecracker.y
		local c = targetFirecracker.x

		local itemView = boardView.baseMap[r][c]
		local fromPos = itemView:getBasePosition( itemView.x , itemView.y )

		local targetList = theAction.targetPositions
		if targetList and #targetList > 0 then
			-- for i, v in pairs(targetList) do
			for i = 1, 3 do
				local v = targetList[i]
				if v then
					-- printx(11 ,"============== fly!!", v.y, v.x)
					local targetView = boardView.baseMap[v.y][v.x]
					local firecrackerColour = targetFirecracker._encrypt.ItemColorType
					local colourIndex = AnimalTypeConfig.convertColorTypeToIndex(firecrackerColour)
					local directionGap = v.x - c
					targetView:playBoomByFirecrackerFromPos(colourIndex, directionGap, i, fromPos)
				end
			end

			theAction.jsq = 0
			theAction.addInfo = "watingForFly"
		else
			theAction.addInfo = "explodeFirecracker"
		end

		itemView:cleanFirecrackerView()
	end
end

function GlobalCoreActionLogic:runLogic_BlastFirecracker(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "startBoom" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 24 then
			theAction.addInfo = "fly"
		end
	elseif theAction.addInfo == "watingForFly" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 45 then
			theAction.addInfo = "explodeTarget"
		end
	elseif theAction.addInfo == "explodeTarget" then
		for _, v in pairs(theAction.targetPositions) do
			local targetPoint = IntCoord:create(v.x, v.y)
			local rectangleAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_rectangle,
										targetPoint,
										targetPoint,
										GamePlayConfig_MaxAction_time)
			rectangleAction.addInt2 = 1
			rectangleAction.eliminateChainIncludeHem = true
			mainLogic:addDestructionPlanAction(rectangleAction)
		end
		mainLogic:setNeedCheckFalling()

		theAction.jsq = 0
		theAction.addInfo = "waitToExplodeFirecracker"

	elseif theAction.addInfo == "waitToExplodeFirecracker" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 1 then
			theAction.addInfo = "explodeFirecracker"
		end
		
	elseif theAction.addInfo == "explodeFirecracker" then
		FirecrackerLogic:onDestroyFirecracker(mainLogic, theAction.targetFirecracker)

		FallingItemLogic:preUpdateHelpMap(mainLogic)
		mainLogic:setNeedCheckFalling()

		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		-- mainLogic:setNeedCheckFalling()

		mainLogic.globalCoreActionList[actid] = nil
	end
end

function GlobalCoreActionLogic:runView_kCSYEBranchProgress(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			CollectStarsYEMgr.getInstance():doPlayBuffAnim(boardView.PlayUIDelegate, theAction.startPos, theAction.scoreToShow, function ()
				theAction.addInfo = "over"
			end)
		end
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 200 then
			theAction.addInfo = "over"
		end
	end
end

function GlobalCoreActionLogic:runLogic_kCSYEBranchProgress(mainLogic, theAction, actid, actByView)
	local function overCheck()
		if theAction.addInfo == "over" then
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.globalCoreActionList[actid] = nil
		end
	end
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		if mainLogic.PlayUIDelegate and 
			mainLogic.PlayUIDelegate.scoreProgressBar and 
			mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation and 
			mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation.isResetMoveOver then
			if mainLogic.PlayUIDelegate.scoreProgressBar.ladyBugAnimation:isResetMoveOver() then
				theAction.actionStatus = GameActionStatus.kRunning
				theAction.jsq = 0
			end
		else
			theAction.addInfo = "over" 
			overCheck()
		end
	end

	overCheck()
end