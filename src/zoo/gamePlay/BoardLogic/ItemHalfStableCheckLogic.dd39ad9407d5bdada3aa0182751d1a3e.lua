require "zoo.gamePlay.BoardLogic.MatchItemLogic"
---------物品进入半稳定状态判断-------
ItemHalfStableCheckLogic = class{}

----检测整个地图进入半稳定状态的Item
function ItemHalfStableCheckLogic:checkAllMap(mainLogic)
	-----全地图落点判断------
	local needMix = false
	for r=1,#mainLogic.gameItemMap do
		for c=1,#mainLogic.gameItemMap[r] do
			if mainLogic.gameItemMap[r][c].ItemStatus == GameItemStatusType.kItemHalfStable			----不稳定状态
				then
				----检测半稳定模块
				local item = mainLogic.gameItemMap[r][c]
				local color = item._encrypt.ItemColorType
				mainLogic:addNeedCheckMatchPoint(r, c)
				----状态检测后，变成普通状态----
				mainLogic.gameItemMap[r][c]:AddItemStatus( GameItemStatusType.kNone , true ) 		----变成普通
			end
		end
	end

	return needMix
end

function ItemHalfStableCheckLogic:checkElasticAnimation(mainLogic)
	for r=1,#mainLogic.gameItemMap do
		for c=1,#mainLogic.gameItemMap[r] do
			if mainLogic.gameItemMap[r][c].ItemStatus == GameItemStatusType.kItemHalfStable	then
				if mainLogic.boardView then
					local itemView = mainLogic.boardView.baseMap[r][c]
					local board = mainLogic.boardmap[r][c]
					if board.transType > 0 then
						mainLogic.waitForElasticAnimation = true
					end
					itemView:playElasticEffect()
				end
				GamePlayMusicPlayer:playEffect(GameMusicType.kDrop)
			end
		end
	end
end

----检测整个地图，即使不是半稳定状态或者移动中的Item
----当产生消除，则返回true，否则返回false
function ItemHalfStableCheckLogic:checkAllMapWithNoMove(mainLogic)
	MatchItemLogic:cleanSwapHelpMap(mainLogic)
	-----全地图落点判断------
	local needMix = false
	for r=1,#mainLogic.gameItemMap do
		for c=1,#mainLogic.gameItemMap[r] do
			if mainLogic.gameItemMap[r][c].isUsed == true 				----不稳定状态
				then
				----检测半稳定模块
				local item = mainLogic.gameItemMap[r][c]
				local color = item._encrypt.ItemColorType
				if MatchItemLogic:checkMatchStep1(mainLogic, r, c, color, true) then
					needMix = true
				end
			end
		end
	end

	-----全地图match------
	if needMix then 
		MatchItemLogic:_MatchSuccessAndMix(mainLogic)
	end
	MatchItemLogic:cleanSwapHelpMap(mainLogic)
	return needMix
end