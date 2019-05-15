-- 测试通用击打逻辑中优先级排序是否稳定：
-- 		击打逻辑内部，可能会添加更多新的优先级层级
--		但是对于原有对象类型，相对优先级排列顺序是不应该改变的

require "zoo.gamePlay.BoardLogic.CertainPlayLogic.CommonMultipleHittingPriorityLogic"
require "zoo.gamePlay.GameItemData"
require "zoo.gamePlay.GameBoardData"

caseCommonMultipleHitting = class(UnittestTask)

function caseCommonMultipleHitting:ctor()
	UnittestTask.ctor(self)
end

function caseCommonMultipleHitting:run(callback_success_message)

	local dummyMainLogic = {}
	dummyMainLogic.gameItemMap = {}
	dummyMainLogic.boardmap = {}
	dummyMainLogic.gameItemMap[1] = {}
	dummyMainLogic.boardmap[1] = {}
	-- 李鬼终究不是李逵，为了不露怯，屏蔽一些情况
	dummyMainLogic.gameMode = {}
	dummyMainLogic.gameMode.allSeaAnimals = nil
	dummyMainLogic.theGamePlayType = 1 -- CLASSIC_MOVES_ID = 1

	-- 选取几个分布于不同优先级层级中的，有代表性的类型
	-- 检测他们的相对优先级顺序是否稳定
	----- 任意选择的测试目标：（括号中为优先级层级，越小优先级越高）
	----- 毒液(1)  蜂蜜罐(2)  银币(3)  大眼仔(4)  冰封导弹(5)  礼盒(6)
	local dummyItemDataSet = {}
	local dummyItemData1 = GameItemData:create()
	dummyItemData1.venomLevel = 1
	dummyItemDataSet[1] = dummyItemData1
	local dummyItemData2 = GameItemData:create()
	dummyItemData2.ItemType = GameItemType.kHoneyBottle
	dummyItemDataSet[2] = dummyItemData2
	local dummyItemData3 = GameItemData:create()
	dummyItemData3.ItemType = GameItemType.kCoin
	dummyItemDataSet[3] = dummyItemData3
	local dummyItemData4 = GameItemData:create()
	dummyItemData4.ItemType = GameItemType.kMagicLamp
	dummyItemDataSet[4] = dummyItemData4
	local dummyItemData5 = GameItemData:create()
	dummyItemData5.ItemType = GameItemType.kMissile
	dummyItemData5.missileLevel  = 1
	dummyItemDataSet[5] = dummyItemData5
	local dummyItemData6 = GameItemData:create()
	dummyItemData6.ItemType = GameItemType.kNewGift
	dummyItemDataSet[6] = dummyItemData6
	---
	local dummyBoardData = GameBoardData:create()
	dummyMainLogic.boardmap[1][1] = dummyBoardData	--没测试需要boardData的类型，所以统一赋值

	-- testPriorityResult中保存运算出的优先级数值。
	-- 因为优先级层级数可能改变，所以此数值会动态调整，但不同层级间相对大小关系不会改变。
	-- 数值越大，表示优先级越高
	local testPriorityResult = {}	
	local testDataSet = {}
	for i = 1, #dummyItemDataSet do
		local itemData = dummyItemDataSet[i]
		dummyMainLogic.gameItemMap[1][1] = itemData
		local resultPriorityValue = CommonMultipleHittingPriorityLogic:getTargetGridPrior(dummyMainLogic, 1, 1)
		testPriorityResult[i] = resultPriorityValue
	end

	-- 最终测试：因为检测对象优先级由大到小排列，结果数值越大表示优先级越高，所以结果数值也应是降序配列。
	for index = 1, (#testPriorityResult - 1) do
		local val1 = testPriorityResult[index]
		local val2 = testPriorityResult[index + 1]
		 -- 前一个数比后一个小，一定有哪里不对……
		assert(val1 > val2, "caseCommonMultipleHitting, Ooooops! priority in disorder! Index:"..index)
	end

	callback_success_message(true, "caseCommonMultipleHitting, Finished! ヽ(*´▽`)ノ")
end

