GamePlayConfigScoreMemClass = memory_class_simple_allnumber()

function GamePlayConfigScoreMemClass:getEncryptKey(key)
--	return "GamePlayConfigScoreMemClass" .. "_" .. key
	return key .. "_" .. self.__class_id
end

--local encryptKeys = {}
function GamePlayConfigScoreMemClass:encryptionFunc( key, value )
--	if type(value) == "number" then
--		encryptKeys[key] = true
	assert(type(value) == "number")
		HeMemDataHolder:setInteger(self:getEncryptKey(key), value)
--		return true
--	end
--	return false
end

function GamePlayConfigScoreMemClass:decryptionFunc( key )
--	if encryptKeys[key] then
		return HeMemDataHolder:getInteger(self:getEncryptKey(key))
--	end
--	return false
end
GamePlayConfig_replayAdjustValue = 1
------------------------------------------------------------------------------------

GamePlayConfigScore = GamePlayConfigScoreMemClass.new()

GamePlayConfigScore.MatchBySnow = 100
GamePlayConfigScore.DropDownIngredient = 10000												-- 收集得分
----消除对应特效得到的额外分数 
GamePlayConfigScore.SpecialBombkLine = 200 					
GamePlayConfigScore.SpecialBombkColumn = 200
GamePlayConfigScore.SpecialBombkWrap = 250
GamePlayConfigScore.SpecialBombkBird = 300

GamePlayConfigScore.SwapLineLine = 500						----交换两个直线特效附加分数
GamePlayConfigScore.SwapLineWrap = 1000 					----交换直线特效和区域特效
GamePlayConfigScore.SwapWrapWrap = 1500 					----交换两个区域特效附加分数
GamePlayConfigScore.SwapColorAnimal = 300 					----交换鸟和普通动物
GamePlayConfigScore.SwapColorLine = 2000 					----交换鸟和直线
GamePlayConfigScore.SwapColorWrap = 2500 					----交换鸟和区域
GamePlayConfigScore.SwapColorColor = 5000 					----交换鸟鸟
GamePlayConfigScore.SwapBlocker195 = 10000 			    	----交换星星瓶和普通物品
GamePlayConfigScore.SwapSuperBlocker195 = 15000 			----交换星星瓶和鸟、星星瓶和染色宝宝

GamePlayConfigScore.MatchDeletedBase = 10 					----消除单个动物的基础奖励分数
GamePlayConfigScore.MatchDeletedCrystal = 100 				----消除单个水晶的分数

GamePlayConfigScore.MatchAtLock = 100	 					----消除牢笼的得分
GamePlayConfigScore.MatchAtIce = 1000 						----消除冰层的得分

GamePlayConfigScore.Furball = 100 							----消除灰色毛球得分
GamePlayConfigScore.Balloon = 100							----消除气球得分
GamePlayConfigScore.Rabbit = 500
GamePlayConfigScore.Rocket = 200

GamePlayConfigScore.MatchAtDigGround = 100					----消除地块得分
GamePlayConfigScore.MatchAt_DigJewel = 1500					----消除宝石块得分
GamePlayConfigScore.MatchAt_BlackCuteBall = 5 				----消除一层黑色毛球的得分
GamePlayConfigScore.Collect_Snail = 10000					----收集蜗牛
GamePlayConfigScore.SandClean = 1000 						----消除流沙
GamePlayConfigScore.QuestionMarkDestory = 1000				----消除问号障碍得分

GamePlayConfigScore.Roost = 400
GamePlayConfigScore.BigMonster = 100
GamePlayConfigScore.ChestSquare = 100
GamePlayConfigScore.MayDayBossBeHit = 100
GamePlayConfigScore.WeeklyBossBeHit = 100

GamePlayConfigScore.SeaAnimalPenguin = 10000
GamePlayConfigScore.SeaAnimalSeal = 10000
GamePlayConfigScore.SeaAnimalBear = 10000

GamePlayConfigScore.CrystalStone = 10000 -- 染色宝宝分数

GamePlayConfigScore.NormalTotems = 10
GamePlayConfigScore.SuperTotems = 10000

GamePlayConfigScore.BonusTimeScore = 2500

GamePlayConfigScore.LotusLevel1 = 10
GamePlayConfigScore.LotusLevel2 = 120
GamePlayConfigScore.LotusLevel3 = 50

GamePlayConfigScore.MatchAt_YellowDiamond = 1500					----消除黄宝石块得分
GamePlayConfigScore.MatchAt_WanSheng = 100					----消除万生得分


----生成对应特效得到的额外分数
GamePlayConfigScore.SpecialCombineLine = 20 				
GamePlayConfigScore.SpecialCombineCloumn = 20
GamePlayConfigScore.SpecialCombineWrap = 30
GamePlayConfigScore.SpecialCombineBird = 60

GamePlayConfigScore.MatchAt_Missile = 100				----消除一层冰封导弹的得分
GamePlayConfigScore.BlockerCoverMaterial = 10   --消除小木桩和小叶堆每层的得分

GamePlayConfigScore.BiscuitCollected = 100
---------------------------GamePlayConfigScore END-----------------------------------

-- 棋盘定位、棋盘属性相关
GamePlayConfig_Tile_Width = 70				-- 每个Tile的宽度！资源的实际大小，不能随便修改！
GamePlayConfig_Tile_Height = 70				-- 每个Tile的高度！资源的实际大小，不能随便修改！
GamePlayConfig_Tile_PosAddX = 5 			-- 棋盘与屏幕两边的距离
GamePlayConfig_Design_Width = 720			-- 标准屏幕宽
GamePlayConfig_Design_Height = 1280			-- 标准屏幕高
GamePlayConfig_Top_Height = 211				-- 棋盘上方留白的距离！根据资源和产品要求调整，不能随便修改！
GamePlayConfig_Bottom_Height = 160 			-- 期盼下方留白的距离！根据资源和产品要求调整，不能随便修改！
GamePlayConfig_Strengh_Scale = 1			-- 棋盘适应屏幕过程中棋盘拉伸的比率
GamePlayConfig_Tile_ScaleX = 1 				-- 棋盘X缩放！会在游戏初始化时修改以适应屏幕，此处修改无效！
GamePlayConfig_Tile_ScaleY = 1				-- 棋盘Y缩放！会在游戏初始化时修改以适应屏幕，此处修改无效！
GamePlayConfig_Tile_BorderWidth = 4			-- 边框的宽度！资源的实际大小，不能随便修改！
GamePlayConfig_Tile_Ingr_CollectorY = 4		-- 豆荚收集口标志Y偏移量！资源的实际大小，不能随便修改！
GamePlayConfig_Tile_Ingr_Height = 27		-- 豆荚收集口高！资源的实际大小，不能随便修改！
GamePlayConfig_Max_Item_Y = 10 				-- 棋盘轴向最大容纳数+1！不要随便修改！

-- 音乐开启关闭
GamePlayConfig_Music_Effect_Open = true
GamePlayConfig_Background_Music_Open = true

-- 游戏帧数
GamePlayConfig_Action_FPS = 60											-- 设计帧率，不足时会以跳帧进行补充（一次渲染进行多次计算）！不要改变此处！
GamePlayConfig_Action_FPS_Time_Scale = GamePlayConfig_Action_FPS / 60		-- 动画时间配置标准！不要改变此处！
GamePlayConfig_Action_FPS_Time_Scale_F = 60 / GamePlayConfig_Action_FPS 	-- 动画时间配置倒数！不要改变此处！

-- 基本掉落相关
GamePlayConfig_FallingSpeed_Delay = 30 * GamePlayConfig_Action_FPS_Time_Scale 		-- 掉落延迟时间
GamePlayConfig_FallingSpeed_Start = 2 * GamePlayConfig_Action_FPS_Time_Scale_F	-- 掉落起始速度
GamePlayConfig_FallingSpeed_Add	= 1.6 * GamePlayConfig_Action_FPS_Time_Scale_F		-- 掉落加速度
GamePlayConfig_FallingSpeed_Max = 34 * GamePlayConfig_Action_FPS_Time_Scale_F		-- 掉落最大速度
GamePlayConfig_FallingSpeed_Pass_Start = 8 * GamePlayConfig_Action_FPS_Time_Scale_F		-- 穿过传送门后的起始速度

-- 棋盘震动
GamePlayConfig_Viberate_InitY = 0.01 	-- 震动幅度，与屏幕高度的比例	
GamePlayConfig_Viberate_Count = 4 		-- 震动次数，一上一下算两次
GamePlayConfig_Viberate_Delay = 2 		-- 每次震动之间的间隔

function setDefaultGamePLayGlobalParameter()

	GamePlayConfig_replayAdjustValue = 1

		-- 强制交换
	GamePlayConfig_ForceSwapAction_Move_CD = 10 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_ForceSwapAction_Effect_CD = 40 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_ForceSwapAction_CD = GamePlayConfig_ForceSwapAction_Move_CD

	GamePlayConfig_SwapAction_CD = 8 * GamePlayConfig_Action_FPS_Time_Scale					--开始交换的动画播放时间
	GamePlayConfig_SwapAction_Failed_CD = 10 * GamePlayConfig_Action_FPS_Time_Scale			--交换失败回弹时间
	GamePlayConfig_SwapAction_Success_CD = 2 * GamePlayConfig_Action_FPS_Time_Scale			--交换成功回弹时间
	GamePlayConfig_SwapAction_Fun_CD = 6 * GamePlayConfig_Action_FPS_Time_Scale				--被绳子挡住的搞笑交换的持续时间
	GamePlayConfig_SwapAction_Fun_Failed_CD = 6 * GamePlayConfig_Action_FPS_Time_Scale		--被绳子挡住之后的回弹效果
	GamePlayConfig_GameItemAnimalDeleteAction_CD = 12 * GamePlayConfig_Action_FPS_Time_Scale		--删除GameItem的Animal数据动画时间
	GamePlayConfig_GameItemAnimalDeleteAction_CD_View = 12 * GamePlayConfig_Action_FPS_Time_Scale	--删除GameItem的Animal残影动画时间
	GamePlayConfig_GameItemLockDeleteAction_CD = 18	* GamePlayConfig_Action_FPS_Time_Scale			--删除GameItem的牢笼动画时间
	GamePlayConfig_GameItemCrystalDeleteAction_CD = 18 * GamePlayConfig_Action_FPS_Time_Scale		--删除水晶的时间
	GamePlayConfig_GameItemGiftDeleteAction_CD = 18 * GamePlayConfig_Action_FPS_Time_Scale			--删除礼物的时间
	GamePlayConfig_GameItemBlockerDeleteAction_CD = 16 * GamePlayConfig_Action_FPS_Time_Scale		-- 删除障碍的时间
	GamePlayConfig_GameItemGreyFurballDeleteAction_CD = 35 * GamePlayConfig_Action_FPS_Time_Scale		-- 删除障碍的时间
	GamePlayConfig_GameItemDigGroundDeleteAction_CD = 18 * GamePlayConfig_Action_FPS_Time_Scale  --删除地块的时间
	GamePlayConfig_GameItemDigJewelDeleteAction_CD = 18 * GamePlayConfig_Action_FPS_Time_Scale --删除宝石块的时间
    GamePlayConfig_GameItemYellowDiamondDeleteAction_CD = 18 * GamePlayConfig_Action_FPS_Time_Scale --删除宝石块的时间

	-- 直线特效、区域特效
	GamePlayConfig_SpecialBomb_Line_Anim_CD = 30 * GamePlayConfig_Action_FPS_Time_Scale		-- 横向直线特效逻辑等待动画播放时间
	GamePlayConfig_SpecialBomb_Line_Add_CD = 1 * GamePlayConfig_Action_FPS_Time_Scale		-- 横向直线特效爆炸逻辑爆破间隔，1为最小
	GamePlayConfig_SpecialBomb_Column_Anim_CD = 30 * GamePlayConfig_Action_FPS_Time_Scale	-- 纵向直线特效逻辑等待动画播放时间
	GamePlayConfig_SpecialBomb_Wrap = 30 * GamePlayConfig_Action_FPS_Time_Scale				-- 区域特效播放时间
	GamePlayConfig_SpecialBomb_WrapWrap = 20 * GamePlayConfig_Action_FPS_Time_Scale 		-- 区域+区域延迟时间

	GamePlayConfig_SpecialBomb_BirdAnimal_Time1 = 100 * GamePlayConfig_Action_FPS_Time_Scale 			--鸟和动物交换特效时间
	GamePlayConfig_SpecialBomb_BirdAnimal_Time2 = 50 * GamePlayConfig_Action_FPS_Time_Scale 			--鸟和动物交换特效时间(动物飞行时间)
	GamePlayConfig_SpecialBomb_BirdAnimal_Time3 = 75 * GamePlayConfig_Action_FPS_Time_Scale 			--鸟和动物交换特效时间(动物摇头晃脑时间)
	GamePlayConfig_SpecialBomb_BirdAnimal_Shake_Time = 45 * GamePlayConfig_Action_FPS_Time_Scale 			--动物摇头晃脑时间
	GamePlayConfig_SpecialBomb_BirdLine_Time1 = 3000 * GamePlayConfig_Action_FPS_Time_Scale				--鸟和直线特效交换时间----极限值
	GamePlayConfig_SpecialBomb_BirdLine_Time2 = 50 * GamePlayConfig_Action_FPS_Time_Scale				--鸟开始四处飞，引起变化
	GamePlayConfig_SpecialBomb_BirdLine_Time3 = 30 * GamePlayConfig_Action_FPS_Time_Scale				--鸟四处飞的时间----之后剩余的时间，动物变形
	GamePlayConfig_SpecialBomb_BirdLine_Time4 = 95 * GamePlayConfig_Action_FPS_Time_Scale				--交换之后多少时间变形的动物开始特效爆炸
	GamePlayConfig_SpecialBomb_BirdLine_Time5 = 10 * GamePlayConfig_Action_FPS_Time_Scale				--特效爆炸的检测间隔

	GamePlayConfig_SpecialBomb_BirdBird_Time1 = 10000 * GamePlayConfig_Action_FPS_Time_Scale			--鸟鸟交换特效最大持续时间
	GamePlayConfig_SpecialBomb_BirdBird_Time2 = 30 * GamePlayConfig_Action_FPS_Time_Scale				--鸟鸟交换的鸟消失时间
	GamePlayConfig_SpecialBomb_BirdBird_Time3 = 20 * GamePlayConfig_Action_FPS_Time_Scale				--鸟鸟交换特效----第一次静默等待时间
	GamePlayConfig_SpecialBomb_BirdBird_Time4 = 30 * GamePlayConfig_Action_FPS_Time_Scale				--鸟鸟交换特效----第二次静默等待时间
	GamePlayConfig_SpecialBomb_BirdBird_Time5 = 50 * GamePlayConfig_Action_FPS_Time_Scale				--鸟鸟交换特效----第三次静默等待时间

	GamePlayConfig_Falling_MaxTime = 3000* GamePlayConfig_Action_FPS_Time_Scale		----!!!最大下落时间

	GamePlayConfig_Falling_LeftRight_Time = 8 * GamePlayConfig_Action_FPS_Time_Scale 									----侧滑时间
	GamePlayConfig_Falling_LeftRight_Speed_X = GamePlayConfig_Tile_Width / GamePlayConfig_Falling_LeftRight_Time		----!!!自动计算侧滑速度
	GamePlayConfig_Falling_LeftRight_Speed_Y = GamePlayConfig_Tile_Height / GamePlayConfig_Falling_LeftRight_Time		----!!!自动计算侧滑速度

	GamePlayConfig_IceDeleted_Pos_Add_X = {-2, -2, -2}				----!!!冰层动画的偏移量，因为冰层动画范围比一个格子要大
	GamePlayConfig_IceDeleted_Pos_Add_Y = {-9, -10, -5}					

	GamePlayConfig_LockDeleted_Pos_Add_X = 2
	GamePlayConfig_LockDeleted_Pos_Add_Y = -33						----!!!牢笼动画的偏移量，因为牢笼动画范围比一个格子要大

	--黑色毛球消失
	GamePlayConfig_BlackCuteBall_Destroy = 30
	--雪怪被打
	GamePlayConfig_MonsterFrosting_Dec = 16 * GamePlayConfig_Action_FPS / 30 
	-- 大宝箱被打
	GamePlayConfig_ChestSquarePart_Dec = 16 * GamePlayConfig_Action_FPS / 30 

	--蜂蜜消失
	GamePlayConfig_Honey_Disappear = 19 * GamePlayConfig_Action_FPS / 30 

	GamePlayConfig_Add_Move_Base = 5


	-- 雪块
	GamePlayConfig_GameItemSnowDeleteAction_CD = GamePlayConfig_GameItemBlockerDeleteAction_CD		-- 删除雪块的时间（此时间有问题，暂时仅测试用，提交时注释）
	GamePlayConfig_SnowDeleted_Pos_Add_X = {2,2,2,2,2} 												-- 雪花动画X轴向偏移量！资源的实际大小，不能随便修改！
	GamePlayConfig_SnowDeleted_Pos_Add_Y = {-33,-33,-33,-33,-33}									-- 雪花动画Y轴向偏移量！资源的实际大小，不能随便修改！
	GamePlayConfig_SnowDeleted_Action_Count = {12, 27, 18, 22, 22}									-- 雪花消除特效的资源帧数！资源的实际大小，不能随便修改！

	GamePlayConfig_GameItemChristmasBellDeleteAction_CD = 40 * GamePlayConfig_Action_FPS_Time_Scale

	-- 金豆荚
	GamePlayConfig_DropDown_Ingredient_DroppingCD = 18 * GamePlayConfig_Action_FPS_Time_Scale 	-- 豆荚收集时长
	-- GamePlayConfig_DropDown_Ingredient_DroppingCD = GamePlayConfig_FallingSpeed_Delay		-- 豆荚收集时长（此时间有问题，暂时仅测试用，提交时注释）
	GamePlayConfig_DropDown_Ingredient_ScaleTime = 10 * GamePlayConfig_Action_FPS_Time_Scale 	-- 豆荚原地缩小时长
	GamePlayConfig_DropDown_Ingredient_CollectTime = 10 * GamePlayConfig_Action_FPS_Time_Scale 	-- 豆荚收集动画时长
	GamePlayConfig_DropDown_Ingredient_CollectScale = 1 										-- 豆荚收集动画终结时豆荚的大小
	GamePlayConfig_DropDown_Ingredient_CollectPos = 1											-- 豆荚收集动画下降位置（N倍单元格高度）
	GamePlayConfig_DropDown_Acorn_CollectPos = 1.2											    -- 橡果收集动画下降位置（N倍单元格高度）
	GamePlayConfig_DropDown_Ingredient_Time2 = 50 * GamePlayConfig_Action_FPS_Time_Scale		-- 豆荚收集--飞行时长

	--银币
	GamePlayConfig_GameItemCoinDeleteAction_CD = GamePlayConfig_GameItemAnimalDeleteAction_CD

	GamePlayConfig_Hammer_Animation_CD = 20 * GamePlayConfig_Action_FPS_Time_Scale 			-- 锤子的动画播放时间

	GamePlayConfig_Hammer_Pos = ccp(64, -2)								 					-- 锤子的位置增量
	GamePlayConfig_Hammer_InitAngle = -45
	GamePlayConfig_Hammer_UpAngle = -15
	GamePlayConfig_Hammer_HitAngle = -75
	GamePlayConfig_Hammer_FinalAngle = -45
	GamePlayConfig_Hammer_1stUpTime = 12 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_Hammer_DownTime = 6 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_Hammer_2ndUpTime = 6 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_Impact_Pos = ccp(20, 10)
	GamePlayConfig_Impact_InitScale = 0.2
	GamePlayConfig_Impact_2ndScale = 1
	GamePlayConfig_Impact_FinalScale = 1.5
	GamePlayConfig_Impact_InitOpacity = 0.4
	GamePlayConfig_Impact_2ndOpacity = 255
	GamePlayConfig_Impact_FinalOpacity = 0
	GamePlayConfig_Impact2ndTime = 6 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_ImpackFinalTime = 6 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_Hammer_Viberate_Time = 18 * GamePlayConfig_Action_FPS_Time_Scale

	--
	GamePlayConfig_LineBrush_Animation_CD = 40 * GamePlayConfig_Action_FPS_Time_Scale		    -- 条纹刷子的等待动画播放时间（此时间过后目标的类型即被转换）
	--使用道具后播放星星动画的数据
	GamePlayConfig_LineBrush_EFFECT_CD = 40 * GamePlayConfig_Action_FPS_Time_Scale

	GamePlayConfig_LineBrush_AnchorPoint = ccp(0.3, 0.6)										-- 条纹刷子的AnchorPoint
	GamePlayConfig_LineBrush_Comet_ShowDelay = 0.05
	GamePlayConfig_LineBrush_Comet_ScaleWait = 0.15
	GamePlayConfig_LineBrush_Comet_ScaleDuration = 0.05
	GamePlayConfig_LineBrush_Comet_FinalScaleY = 1.3
	GamePlayConfig_LineBrush_Comet_MovingTime = 18 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_LineBrush_Star1_Scale = 1
	GamePlayConfig_LineBrush_Star2_Scale = 2
	GamePlayConfig_LineBrush_Star3_Scale = 1.5
	GamePlayConfig_LineBrush_Star1_InitX = 6
	GamePlayConfig_LineBrush_Star2_InitX = -5
	GamePlayConfig_LineBrush_Star3_InitX = 1
	GamePlayConfig_LineBrush_Star1_FinalX = 10
	GamePlayConfig_LineBrush_Star2_FinalX = -6
	GamePlayConfig_LineBrush_Star3_FinalX = 4
	GamePlayConfig_LineBrush_Star1_InitY = 30
	GamePlayConfig_LineBrush_Star2_InitY = 14
	GamePlayConfig_LineBrush_Star3_InitY = 45
	GamePlayConfig_LineBrush_Star1_FinalY = 50
	GamePlayConfig_LineBrush_Star2_FinalY = 18
	GamePlayConfig_LineBrush_Star3_FinalY = 72
	GamePlayConfig_LineBrush_Star1_MovingTime = 24 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_LineBrush_Star2_MovingTime = 21 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_LineBrush_Star3_MovingTime = 30 * GamePlayConfig_Action_FPS_Time_Scale		-- 因为在这个时间后回收所有图形资源，所以务必保持这个时间是最长的

	-- ??
	GamePlayConfig_Back_AnimTime = 0.2

	GamePlayConfig_Back_Animation_CD = 120 * GamePlayConfig_Action_FPS_Time_Scale

	GamePlayConfig_Product_As_Clipping = true 		----!!!生产口是否用Clipping做

	GamePlayConfig_Score_Rocket_Bomb_Scale = 1.5

	GamePlayConfig_Score_MatchDeleted_UP_Time = 20* GamePlayConfig_Action_FPS_Time_Scale				----分数弹起的时间
	GamePlayConfig_Score_MatchDeleted_Stop_Time = 25* GamePlayConfig_Action_FPS_Time_Scale			----分数在空中停留的时间
	GamePlayConfig_Score_MatchDeleted_Fly_Time = 20 * GamePlayConfig_Action_FPS_Time_Scale			----分数在空中飞向消失地点的时间/渐隐效果时间
	GamePlayConfig_Score_MatchDeleted_Scale = 0.6 													----分数字大小
	GamePlayConfig_Score_MatchDeleted_Scale_BIG = 1 													----分数字大小
	GamePlayConfig_Score_MatchDeleted_Scale_NORMAL = 0.85 												----分数字大小
	GamePlayConfig_Score_MatchDeleted_Scale_SMALL = 0.7													----分数字大小
	GamePlayConfig_Score_MatchDeleted_Scale_SCORE_BUFF_BOTTLE = 1.25									----分数字大小：刷星瓶子

	GamePlayConfig_UFO_SleepCD_On_Hit = 3						-- ufo被击中后失效回合数
	GamePlayConfig_GamePlayType_Can_SwapSwapSwap = false 				----是否可以在消除的过程中，再移动其他动物，引起同步消除


	GamePlayConfig_Refresh_BaseSwap_Count = 30 					----刷新时基础交换统计次数
	GamePlayConfig_Refresh_Item_Flying_Time = 55 * GamePlayConfig_Action_FPS_Time_Scale 			----飞行帧数


	GamePlayConfig_BonusTime_Total = 100000 * GamePlayConfig_Action_FPS_Time_Scale					----BonusTime总时间----不要改动
	GamePlayConfig_BonusTime_RandomBomb_CD = 10 * GamePlayConfig_Action_FPS_Time_Scale				----随机引爆的间隔
	GamePlayConfig_BonusTime_ItemFlying_CD = 8 * GamePlayConfig_Action_FPS_Time_Scale				----两个飞行特效之间的间隔
	GamePlayConfig_BonusTime_ItemFlying = 60 * GamePlayConfig_Action_FPS_Time_Scale  				----特效飞行时间
	GamePlayConfig_BonusTime_ItemBomb_CD = 30 * GamePlayConfig_Action_FPS_Time_Scale				----特效爆炸间隔

	GamePlayConfig_MaxAction_time = 100000* GamePlayConfig_Action_FPS_Time_Scale                    ----最大action时间，由动画控制的行为
	GamePlayConfig_CrystalChange_time = 36 * GamePlayConfig_Action_FPS_Time_Scale 					----水晶变色
	GamePlayConfig_VenomSpread_time = 10000 * GamePlayConfig_Action_FPS_Time_Scale 					----毒液蔓延
	GamePlayConfig_Furball_Transfer = 10000 * GamePlayConfig_Action_FPS_Time_Scale 					----毛球转移跳动
	GamePlayConfig_Furball_Split = 10000 * GamePlayConfig_Action_FPS_Time_Scale 						----褐色毛球分裂
	GamePlayConfig_Roost_Replace = 1000 * GamePlayConfig_Action_FPS_Time_Scale 						----鸡窝替换小鸡
	GamePlayConfig_Roost_Upgrade_Level1 = 55														----鸡窝升级动画1级
	GamePlayConfig_Roost_Upgrade_Level2 = 25 														----鸡窝升级动画2级
	GamePlayConfig_Roost_Upgrade_Level3 = 35														----鸡窝升级动画3级


	GamePlayConfig_Balloon_Runaway_time = 12 * GamePlayConfig_Action_FPS_Time_Scale                  ---气球飞走动画
	GamePlayConfig_Balloon_Update_time = 4 * GamePlayConfig_Action_FPS_Time_Scale                     ---气球更新


	GamePlayConfig_PM25_ChangeItem_Max_Count = 3                                                          ----每次更新，pm2.5把普通动物改成地块的最大数量
	GamePlayConfig_Mimosa_Grow_Step  = 2                                                             --几步操作会导致含羞草开始生长
	GamePlayConfig_Mimosa_Grow_Grid_Num = 2                                                          --每次生长，增加的格子数
	GamePlayConfig_Mimosa_Back_Num = 1                                                               --收回次数计数

	-- if __WP8 then
	--   GamePlayConfig_FallingSpeed_Start = GamePlayConfig_FallingSpeed_Start * 2	-- 掉落起始速度
	--   GamePlayConfig_FallingSpeed_Add	= GamePlayConfig_FallingSpeed_Add * 2		-- 掉落加速度
	--   GamePlayConfig_FallingSpeed_Max = GamePlayConfig_FallingSpeed_Max * 2		-- 掉落最大速度
	--   GamePlayConfig_FallingSpeed_Pass_Start = GamePlayConfig_FallingSpeed_Pass_Start * 2		-- 穿过传送门后的起始速度
	-- end


	GamePlayConfig_Transmission_Time = 24 / 30 --传送带传送一个item的时间

	-------------------刺猬相关配置---------------------------
	GamePlayConfig_HedgehogAwardJewel = 10
	GamePlayConfig_HedgehogAwardAddMove = 1
	GamePlayConfig_HedgehogAwardLine = 2
	GamePlayConfig_HedgehogAwardWrap = 2
	GamePlayConfig_HedgehogBuffStep = 7

	-----------------染色宝宝-------------------
	GamePlayConfig_CrystalStone_Energy = 20 -- 染色宝宝能量值
	GamePlayConfig_CrystalEnergy_Normal = 1 -- 普通动物充能值
	GamePlayConfig_CrystalEnergy_Special = 3 -- 特效充能值（&Hammer）
	GamePlayConfig_CrystalStone2_Handle_One_Time = 4 -- 两个染色宝宝交换,变色分步进行,每步4个
	GamePlayConfig_CrystalStone2_Handle_Interval = 3 * GamePlayConfig_Action_FPS_Time_Scale -- 两个染色宝宝交换,变色分步间隔帧数
	GamePlayConfig_SpecialBomb_CrystalStone_Destory_Time1 = 50 * GamePlayConfig_Action_FPS_Time_Scale -- 染色宝宝消失Action总时间
	GamePlayConfig_SpecialBomb_CrystalStone_Destory_Time2 = 13 * GamePlayConfig_Action_FPS_Time_Scale -- special(染色宝宝+魔力鸟)消失结束时间
	GamePlayConfig_SpecialBomb_CrystalStone_Animal_Time1 = 2000 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_SpecialBomb_CrystalStone_Animal_Time2 = 30 * GamePlayConfig_Action_FPS_Time_Scale -- 染色宝宝爆炸时间点
	GamePlayConfig_SpecialBomb_CrystalStone2_Time1 = 2000 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_SpecialBomb_CrystalStone2_Time2 = 80 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time1 = 2000 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time2 = 20 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time3 = 20 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_CrystalStone_Fly_Time1 = 50 * GamePlayConfig_Action_FPS_Time_Scale -- 总时间
	GamePlayConfig_CrystalStone_Fly_Time2 = 30 * GamePlayConfig_Action_FPS_Time_Scale -- 飞行特效结束时间点
	GamePlayConfig_CrystalStone_Fly_Time3 = 45 * GamePlayConfig_Action_FPS_Time_Scale -- 特效自爆时间点

	GamePlayConfig_Score_SuperTotems_Scale = 2

	GamePlayConfig_SuperCute_InactiveRound_UseProp = 1
	GamePlayConfig_SuperCute_InactiveRound_UseMove = 2
	GamePlayConfig_SuperCute_InactiveTick = 55

	GamePlayConfig_TangChicken_Destroy1_Time = 60 * 30/30 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_TangChicken_Destroy2_Time = 60 * 3/30 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_TangChicken_Destroy3_Time = 60 * 6/60 * GamePlayConfig_Action_FPS_Time_Scale
	GamePlayConfig_Blcoker195_Destroy_Time = 77
end



setDefaultGamePLayGlobalParameter()