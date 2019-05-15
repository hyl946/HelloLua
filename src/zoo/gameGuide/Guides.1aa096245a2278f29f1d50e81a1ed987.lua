require "zoo.model.MetaModel"
require "zoo.net.LevelType"
-- require "zoo.gamePlay.GameBoardLogic" --注意，Guides文件一定不能再加载GameBoardLogic，具体原因可以问reast
require "zoo.gamePlay.config.GamePlayGlobalConfigs"
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


kGuideFlags = {
	BuffBoom = 1,
	ACHIEVE = 2,

	InfiniteEnergy = 3 ,
	RankRace = 4,

    MoleWeekAdd5Step = 5,

    SheQuGuide = 6,

    Qixi2018Guide = 7,

    PreProps_MagicBird = 8,

    FruitTreePick = 9,
    --旧版视频果子引导 废弃
    FruitTreeVideo = 10,
    --新版视频果子引导
    FruitTreeVideo_1810 = 11,

    PreProps_FireCracker = 11,
    inGame_FireCracker = 12,
    PreProps_LineAndWrap = 13, 		--前置道具爆炸直线特效 10007
    PreProps_MagicBird_Free = 14,

    ThanksGivingGuide1 = 15,
    ThanksGivingGuide2 = 16,

    SpeedBtn_1 = 17,
    SpeedBtn_2 = 18,

	--播放CG
	FinishCartoon = 100 ,
	--新头像框解锁
	NewHeadFrame = 101 ,


	EnergyACT = 102,

	FindTheWay_1 = 103, 
	FindTheWay_2 = 104, 
	FindTheWay_3 = 105, 
	FindTheWay_4 = 106, 
	FindTheWay_5 = 107, 
	FindTheWay_6 = 108, 
	FindTheWay_7 = 109, 
	FindTheWay_8 = 110, 

	FiveStepNewLottery = 111,
	DailyTasks2019IsOpen = 112,
	DailyTasks2019TimeIconIsOpen = 113,
	DailyTasks2019DoPopout = 114 , --回到藤蔓界面时 任务强弹标记


	kUserReview_1 = 115 ,
	kUserReview_2 = 116 ,
	kUserReview_3 = 117 ,

}

--后端标记的引导 完成引导时送的奖励
kGuideRewardConfig = {
	[kGuideFlags.PreProps_LineAndWrap] = 20,
	[kGuideFlags.PreProps_MagicBird_Free] = 21,
}

local vs = Director:sharedDirector():getVisibleSize()
local vo = Director:sharedDirector():getVisibleOrigin()
local notGameLevelType = {GameLevelType.kTaskForRecall, GameLevelType.kTaskForUnlockArea, 
	GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017, GameLevelType.kSpring2018, 
	GameLevelType.kYuanxiao2017, GameLevelType.kSummerWeekly, GameLevelType.kFourYears,
	GameLevelType.kMoleWeekly, GameLevelType.kSummerFish, GameLevelType.kJamSperadLevel, GameLevelType.kSpring2019 }

GuideLevel = table.const{
	kSeasonWeekly = 230400,
}

Guides = table.const
{
	-- 第1关，点击关卡花
	--[[[10] = {
		appear = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 1},
		},
		action = {
			[1] = {type = "clickFlower", para = 1 , handDelay = 1},
		},
		disappear = {
			{type = "popup"},
			{type = "scene", scene = "game"}
		}
	},]]
	-- 点击第一关开始按钮
	[11] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 1},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 1},
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	-- 上下交换
	[12] = {
		appear = {
			{type = "scene", scene = "game", para = 1},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 3, countR = 4, countC = 1}}, 
				allow = {r = 3, c = 3, countR = 2, countC = 1}, 
				from = ccp(2, 3.5), to = ccp(3.2, 3.5), 
				panAlign = "matrixD", panPosY = 6, 
				handDelay = 1.2 , panDelay = 0.8,
				panelName = "guide_dialogue_12_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 3), to = ccp(3, 3)},
		}
	},
	-- 左右交换
	[13] = {
		appear = {
			{type = "scene", scene = "game", para = 1},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 1},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 1, countC = 4}}, 
				allow = {r = 3, c = 5, countR = 1, countC = 2}, 
				from = ccp(3.3, 5), to = ccp(3.3, 6.3), 
				text = "tutorial.game.text103", panType = "up", panAlign = "matrixD", panPosY = 4, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_13_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(3, 6)},
		}
	},
	-- 任务目标:再消除4只青蛙
	[14] = {
		appear = {
			{type = "scene", scene = "game", para = 1},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "topLevel", para = 1},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "popImage", opacity = 0xCC, index = 1, 
				text = "tutorial.game.text104", panAlign = "winYU", panPosY = 200, panType = "up", 
				maskDelay = 1,maskFade = 0.4, panDelay = 1.3, panFade = 0.2, touchDelay = 1.9,
				panAnimal = {
					[1] = {animal = "frog", special = "normal", scale = ccp(0.7, 0.7), x = 227, y = -60},},
				panelName = "guide_dialogue_14_1", -- 新引导对话框参考此处
				pics = {
					[1] = {align = 'relative', groupName = 'pic_0101', scale = 1, x = -52, y = -20, baseOn="levelTargetTilePos", para=1},
				},
			},
			    
			--自动动画1，提示消除青蛙
			[2] = {type = "showEliminate", r = 5, c = 7}
		},
		disappear = {
			{type = "scene", scene = ""},
			{type = "swap"}
		}
	},
	-- 第2关，点击关卡花
	[20] = {
		appear = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 2},
			{type = "onceOnly"} ,
			{type = "isNotNextLevelModel"} ,
			{type = "checkAutoPopout", para = "InfiniteEnergyGuideAction"},
			{type = "checkGuideFlag", para = kGuideFlags.InfiniteEnergy},
		},
		action = {
			[1] = {type = "infiniteEnergy", opacity = 0xCC, touchDelay = 1, panelName = 'guide_dialogue_energy'},
		},
		disappear = {
		}
	},
	-- 点击第二关开始按钮
	[21] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 2},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 2},
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	-- 合成直线特效熊
	[22] = {
		appear = {
			{type = "scene", scene = "game", para = 2},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 2},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 2, c = 2, countR = 1, countC = 4}, 
					[2] = {r = 1, c = 3, countR = 1, countC = 1},}, 
				allow = {r = 2, c = 3, countR = 2, countC = 1}, 
				from = ccp(1, 3.5), to = ccp(2.2, 3.5), 
				text = "tutorial.game.text202", panType = "up", panAlign = "matrixD", panPosY = 3 , 
				handDelay = 1.2 , panDelay = 0.8, 
				panAnimal = {
					[1] = {animal = "bear", special = "normal", scale = ccp(0.7, 0.7), x = 140, y = -60},
					[2] = {animal = "bear", special = "normal", scale = ccp(0.7, 0.7), x = 178, y = -115},
					[3] = {animal = "frog", special = "normal", scale = ccp(0.7, 0.7), x = 358, y = -60},
				},
				panelName = 'guide_dialogue_21_1'
			}
		},
		disappear = {
			{type = "swap", from = ccp(1, 3), to = ccp(2, 3)},
		}
	},
	-- 说明直线特效熊，使用直线特效
	[23] = {
		appear = {
			{type = "scene", scene = "game", para = 2},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 2},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 3, countR = 4, countC = 1}}, 
				allow = {r = 3, c = 3, countR = 2, countC = 1}, 
				from = ccp(2, 3.5), to = ccp(3.2, 3.5), 
				text = "tutorial.game.text204",panType = "down", panAlign = "matrixU", panPosY = 9,
				handDelay = 1.2 , panDelay = 0.8,
				highlightEffect = {type = 'bomb',pauseTime = 2,
					effectArea = {{r = 1, c = 3},{r = 2, c = 3},{r = 3, c = 3},{r = 4, c = 3},{r = 5, c = 3},{r = 6, c = 3},{r = 7, c = 3},{r = 8, c = 3}},
				},
				panelName = "guide_dialogue_23_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 3), to = ccp(3, 3)},
		}
	},
	-- 对直线特效的各种合成方式的说明
	--[[[24] = {
		appear = {
			{type = "scene", scene = "game", para = 2},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "topLevel", para = 2},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showInfo", opacity = 0xCC, 
			    maskDelay = 0.8, maskFade = 0.2, panDelay = 0.8, panFade = 0.1,touchDelay = 1.4,
				panelName = 'guide_dialogue_24_1'
			},
			[2] = {type = "showHint", text = "tutorial.game.text206", 
				reverse = true ,animPosY = 0, panOrigin = ccp(-550,130),panFinal = ccp(120,130), animScale = 0.7,
				animDelay = 0.8, panDelay = 1.2 ,
				panelName = "guide_dialogue_24_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "scene", scene = ""},
		}
	},]]
	-- 第3关，点击关卡花
	--[[[30] = {
		appear = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 3},
		},
		action = {
			[1] = {type = "clickFlower", para = 3},
		},
		disappear = {
			{type = "popup"},
			{type = "scene", scene = "game"}
		}
	},]]
	-- 点击第三关开始按钮
	[31] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 3},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 3},
		},
		action = {
			[1] = {type = "startPanel"},
			
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	-- 合成区域特效
	[32] = {
		appear = {
			{type = "scene", scene = "game", para = 3},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 3},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 3, countR = 4, countC = 1}, 
					[2] = {r = 3, c = 4, countR = 1, countC = 2},
				}, 
				allow = {r = 3, c = 3, countR = 2, countC = 1}, 
				from = ccp(2, 3.5), to = ccp(3.2, 3.5),
				text = "tutorial.game.text302",panType = "up", panAlign = "matrixD", panPosY = 5.5 ,
				handDelay = 1.2 , panDelay = 0.8,
				panImage = {
				    --T和L型图片已经替换
					[1] = {image = "guides_panImage_L.png", scale=ccp(0.9, 0.9) , x = 63 , y = -115 ,},
					[2] = {image = "guides_panImage_T.png", scale=ccp(0.9, 0.9) , x = 200 , y = -112 ,},
				},
				panelName = "guide_dialogue_32_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 3), to = ccp(3, 3)},
		}
	},
	-- 使用区域特效
	[33] = {
		appear = {
			{type = "scene", scene = "game", para = 3},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 3},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 3, countR = 1, countC = 4},}, 
				allow = {r = 5, c = 3, countR = 1, countC = 2}, 
				from = ccp(5.3, 3), to = ccp(5.3, 4.3), 
				text = "tutorial.game.text303",panType = "up", panAlign = "matrixD", panPosY = 6,
				handDelay = 1.2 , panDelay = 0.8,
				highlightEffect = {type = 'bomb', pauseTime = 2,
					effectArea = {{r = 3, c = 4},{r = 4, c = 3},{r = 4, c = 4},{r = 4, c = 5},{r = 5, c = 2},{r = 5, c = 3},{r = 5, c = 4},{r = 5, c = 5},{r = 5, c = 6},
					{r = 6, c = 3},{r = 6, c = 4},{r = 6, c = 5},{r = 7, c = 4},},
				},
				panelName = "guide_dialogue_33_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 3), to = ccp(5, 4)},
		}
	},
	-- 显示区域特效规则信息，继续游戏
	--[[[34] = {
		appear = {
			{type = "scene", scene = "game", para = 3},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "topLevel", para = 3},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showInfo", opacity = 0xCC, 
				maskDelay = 0.8, maskFade = 0.2, panDelay = 0.8, panFade = 0.1,touchDelay = 1.4,
 				panelName = "guide_dialogue_34_1",
			},
			--自动动画3，现在棋盘上就有炸弹
			[2] = {type = "showHint", text = "tutorial.game.text305",
				animPosY = 660, animMatrixR = 6, animScale = 0.7, panOrigin= ccp(720,810),panFinal= ccp(200,810),
				panMatrixOriginR = 8.3, panMatrixFinalR = 8.3,
				panelName = "guide_dialogue_34_2", -- 新引导对话框参考此处
			}
		},
		disappear = {
			{type = "scene", scene = ""},
		}
	},]]
	-- 第4关，点击关卡花
	--[[[40] = {
		appear = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 4},
		},
		action = {
			[1] = {type = "clickFlower", para = 4},
		},
		disappear = {
			{type = "popup"},
			{type = "scene", scene = "game"}
		}
	},]]
	-- 点击第四关开始按钮
	[41] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 4},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 4},
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	-- 合成魔力鸟
	[42] = {
		appear = {
			{type = "scene", scene = "game", para = 4},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 4},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 2, countR = 5, countC = 1}, 
					[2] = {r = 4, c = 3, countR = 1, countC = 1},
				}, 
				allow = {r = 4, c = 2, countR = 1, countC = 2}, 
				from = ccp(4.3, 3), to = ccp(4.3, 2.3), 
				text = "tutorial.game.text402",panType = "up", panAlign = "matrixD", panPosY = 6, 
				handDelay = 1.2 , panDelay = 0.8,
				panAnimal = {
					--合成魔力鸟的图片演示,差动物之间切换的动画
					[1] = {animal = "fox", special = "normal", scale = ccp(0.7, 0.7), x = 70, y = -185-15},
					[2] = {animal = "fox", special = "normal", scale = ccp(0.7, 0.7), x = 125, y = -185-15},
					[3] = {animal = "fox", special = "normal", scale = ccp(0.7, 0.7), x = 180, y = -185-15},
					[4] = {animal = "fox", special = "normal", scale = ccp(0.7, 0.7), x = 235, y = -185-15},
					[5] = {animal = "fox", special = "normal", scale = ccp(0.7, 0.7), x = 290, y = -185-15},					
					[6] = {animal = "color", special = "normal", scale = ccp(0.7, 0.7), x = 380, y = -185-15},
				},
				panImage = {
				[1] = {image = "guides_panImage_equa.png",scale = ccp(0.8,0.8) , x = 335 , y = -185-15},
				}, 
				panelName = "guide_dialogue_42_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(4, 3), to = ccp(4, 2)},
		}
	},
	-- 使用魔力鸟特效
	[43] = {
		appear = {
			{type = "scene", scene = "game", para = 4},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 4},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 2, countR = 1, countC = 2} },
				allow = {r = 6, c = 2, countR = 1, countC = 2}, 
				from = ccp(6.3, 2), to = ccp(6.3, 3.3), 
				text = "tutorial.game.text403", panType = "up", panAlign = "matrixD", panPosY = 6,
				maskDelay = 0.7 ,handDelay = 1 , panDelay = 0.9,
				panAnimal = {
					[1] = {animal = "color", special = "normal", scale = ccp(0.7, 0.7), x = 107, y = -60},
				},
				highlightEffect = {type = 'bomb',pauseTime=2,
					effectArea = {	{r = 2, c = 4},{r = 2, c = 7},
									{r = 3, c = 3},{r = 3, c = 4},{r = 3, c = 7},
									{r = 4, c = 1},{r = 4, c = 2},{r = 4, c = 9},
									{r = 5, c = 8},{r = 5, c = 9},
									{r = 6, c = 1},{r = 6, c = 2},
									{r = 7, c = 5},{r = 7, c = 9},},
				},
				panelName = "guide_dialogue_43_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(6, 2), to = ccp(6, 3)},
		}
	},
	-- 还剩18步，高亮步数面板
	[44] = {
		appear = {
			{type = "scene", scene = "game", para = 4},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "topLevel", para = 4},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "popImage", opacity = 0xCC, posAdd = ccp(-100,-90),
				width = 180, height = 160, 
				text = "tutorial.game.text404", 
				panType = "up" ,panAlign = "winYU" , panPosY = 50, panFlip ="true",
				maskDelay = 1 ,maskfade = 0.3, panDelay = 1.2, touchDelay = 1.7,
				panelName = "guide_dialogue_44_1", -- 新引导对话框参考此处
				pics = {
					[1] = {align = 'relative', groupName = 'pic_0401', scale = 1, x = -100, y = -30, baseOn="moveOrTimeCounterPos"},
				},
			},
		},
		disappear = {}
	},
	-- 第5关，点击关卡花
	--[[[50] = {
		appear = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 5},
		},
		action = {
			[1] = {type = "clickFlower", para = 5},
		},
		disappear = {
			{type = "popup"},
			{type = "scene", scene = "game"}
		}
	},]]
	-- 点击第五关开始按钮
	[51] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 5},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 5},
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	-- 两个直线特效交换
	[52] = {
		appear = {
			{type = "scene", scene = "game", para = 5},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 5},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 2, countC = 1},}, 
				allow = {r = 3, c = 5, countR = 2, countC = 1}, 
				from = ccp(2, 5.5), to = ccp(3.2, 5.5), 
				text = "tutorial.game.text502",panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8,
				highlightEffect = {type = 'bomb',pauseTime=2,
					effectArea = {	{r = 2, c = 2},{r = 2, c = 3},{r = 2, c = 4},{r = 2, c = 5},{r = 2, c = 6},{r = 2, c = 7},{r = 2, c = 8},{r = 2, c = 9},
					{r = 1, c = 5},{r = 3, c = 5},{r = 4, c = 5},{r = 5, c = 5},{r = 6, c = 5},{r = 7, c = 5},{r = 8, c = 5},{r = 9, c = 5},},
				},
				panelName = "guide_dialogue_52_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 5), to = ccp(3, 5)},
		}
	},
	-- 继续游戏
	[53] = {
		appear = {
			{type = "scene", scene = "game", para = 5},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 5},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showHint",text = "tutorial.game.text503",
				reverse = true ,animPosY = 0, panOrigin = ccp(-550,130),panFinal = ccp(120,130), animScale = 0.7,
				animDelay = 0.8, panDelay = 1.2 ,
				panelName = "guide_dialogue_53_1", -- 新引导对话框参考此处
			}
		},
		disappear = {
			{type = "scene", scene = ""},
		}
	},
	-- 第6关,点击关卡花
	--[[[60] = {
		appear = {
			{type = "noPopup"},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 6},
		},
		action = {
			[1] = {type = "clickFlower", para = 6},
		},
		disappear = {
			{type = "popup"},
			{type = "scene", scene = "game"}
		}
	},]]
	-- 点击第六关开始按钮
	[61] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 6},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 6},
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	-- 魔力鸟和直线特效交换
	[62] = {
		appear = {
			{type = "scene", scene = "game", para = 6},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 6},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 2},}, 
				allow = {r = 2, c = 5, countR = 1, countC = 2}, 
				from = ccp(2.3, 5), to = ccp(2.3, 6.3), 
				text = "tutorial.game.text602",panType = "up", panAlign = "matrixD", panPosY = 2, panFlip ="true",
				handDelay = 1.2 , panDelay = 0.8,
				highlightEffect = {type = 'bird_line',pauseTime=1.5},
				panelName = "guide_dialogue_62_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 5), to = ccp(2, 6)},
		}
	},
	-- 展示各种特效交换的组合
	--[[[63] = {
		appear = {
			{type = "scene", scene = "game", para = 6},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 6},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showInfo", opacity = 0xCC, 
				maskDelay = 1.8, maskFade = 0.3, panDelay = 1.8, panFade = 0.2, touchDelay = 2.4,
				panelName = 'guide_dialogue_63_1',
			},
			--自动动画6，注意过关目标，祝你好运
			[2] = {type = "showHint", text = "tutorial.game.text604",
				reverse = true ,animPosY = 0, panOrigin = ccp(-550,130),panFinal = ccp(80,130), animScale = 0.7,
				animDelay = 0.8, panDelay = 1.2,
				panelName = "guide_dialogue_63_2", -- 新引导对话框参考此处
			}
		},
		disappear = {
			{type = "scene", scene = ""},
		}
	},]]
	-- 第8关，消除冰块
	[80] = {
		appear = {
			{type = "scene", scene = "game", para = 8},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 8},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 4, c = 3, countR = 1, countC = 3}, 
					[2] = {r = 3, c = 3, countR = 1, countC = 1},
				}, 
				allow = {r = 4, c = 3, countR = 2, countC = 1},
				from = ccp(3, 3.5), to = ccp(4.2, 3.5), 
				text = "tutorial.game.text800",panType = "up", panAlign = "matrixD", panPosY = 5,
				handDelay = 1.2 , panDelay = 0.8,
				highlightEffect = {type = 'ice', pauseTime=2,effectArea = {{r = 4, c = 3}, {r = 4, c = 4}, {r = 4, c = 5}}},
				panelName = "guide_dialogue_80_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(3, 3), to = ccp(4, 3)},
		}
	},
	[81] = {
		appear = {
			{type = "scene",scene = "game", para = 8},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 8},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "staticBoard"}
		},
		action = {
			[1]= {	type = "showHint",text ="tutorial.game.text801",
				reverse = true ,animPosY = 0, panOrigin = ccp(-550,130),panFinal = ccp(80,130), animScale = 0.7,
				animDelay = 0.2, panDelay = 0.5 , 
				panelName = "guide_dialogue_81_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "scene", scene = ""},
		},
	},
	-- 第11关，展示前置+3步
	[110] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 11},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 11},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showPreProp", 
				opacity = 0xCC, 
				helpIcon=true, 
				preItemIndexs={1,2,3,4},	-- 配置次序时，依据次序获取位置
				panelName = "guide_dialogue_110_1", -- 新引导对话框参考此处
			},
			[2] = {
				type = "showPreProp", 
				opacity = 0xCC,
				helpIcon=false,
				preItemIndexs={10018},		-- 配置道具ID时，寻找目标道具获取位置
				panelName = "guide_dialogue_110_2",
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},
	-- 第12关，金豆荚确认，掉落一次
	[120] = {
		appear = {
			{type = "scene", scene = "game", para = 12},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 12},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text1200",panType = "up", panAlign = "matrixD", panPosY = 1.2, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_120_1", -- 新引导对话框参考此处
				--pics = {
				--	[1] = {align = 'top_center', groupName = 'pic_1201', scale = 1, x = -100, y = 0,},
				--},
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
						[1] = {r = 2, c = 5, countR = 1, countC = 1},
						[2] = {r = 7, c = 5, countR = 4, countC = 1}
						}, 
				allow = {r = 7, c = 5, countR = 2, countC = 1}, 
				from = ccp(7, 5.5), to = ccp(5.8, 5.5),
				text = "tutorial.game.text1201",panType = "down", panAlign = "matrixU", panPosY = 3,
				panDelay =0.1 , handDelay = 0.3 ,
				panelName = "guide_dialogue_120_2", -- 新引导对话框参考此处
			}
			
		},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(6, 5)},
		}
	},
	-- 消除第二次，金豆荚掉落
	[121] = {
		appear = {
			{type = "scene", scene = "game", para = 12},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 12},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 8, c = 5, countR = 1, countC = 1}, 
					[2] = {r = 9, c = 3, countR = 1, countC = 4}
				}, 
				allow = {r = 9, c = 3, countR = 1, countC = 2}, 
				from = ccp(9.3, 3), to = ccp(9.3, 4), 
				text = "tutorial.game.text1203",panType = "down", panAlign = "matrixU", panPosY = 9,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_121_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(9, 3), to = ccp(9, 4)},
		}
	},
	-- 任务目标:再收集一个金豆荚
	[123] = {
		appear = {
			{type = "scene", scene = "game", para = 12},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "topLevel", para = 12},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {
			    type = "popImage", 
				opacity = 0xCC, 
				index = 1, 
				text = "tutorial.game.text1204",panType = "up", panAlign = "winYU", panPosY = 50,
				maskDelay = 0.8,maskFade = 0.4, panDelay = 1.1,touchDelay = 1.7,
				panelName = "guide_dialogue_123_1", -- 新引导对话框参考此处
				pics = {
					[1] = {align = 'relative', groupName = 'pic_1201', scale = 1, x = -57, y = -2, baseOn='levelTargetTilePos', para = 1},
				},
			},
		},
		disappear = {}
	},

	-- 第12关，金豆价
	[124] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 12},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 12},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showIngredient",
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},
	
	-- 第13关，展示前置刷新
	-- 此前置道具已被屏蔽
	-- [130] = {
	-- 	appear = {
	-- 		{type = "popup", popup = "startGamePanel", para = 13},
	-- 		{type = "scene", scene = "worldMap"},
	-- 		{type = "topLevel", para = 13},
	-- 		{type = "onceOnly"},
	-- 		{type = "prePropImproveLogic1", func = "isNewItemLogic", expect=false},
	-- 	},
	-- 	action = {
	-- 		[1] = {
	-- 			type = "showPreProp", 
	-- 			opacity = 0xCC, 
	-- 			helpIcon=false, 
	-- 			preItemIndexs={2},
	-- 			panelName = "guide_dialogue_130_1", -- 新引导对话框参考此处
	-- 		},
	-- 	},
	-- 	disappear = {
	-- 		{type = "popdown", popdown = "startGamePanel"},
	-- 	},
	-- },

	[131] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 13},
			{type = "scene", scene = "worldMap"},
			{type = "userLevelEqual", para = 13},
			{type = "onceOnly"},
			{type = "prePropImproveLogic1", func = "isNewItemLogic", expect=false},
			{type = "checkGuideFlag", para = kGuideFlags.PreProps_LineAndWrap},
		},
		action = {
			[1] = {
				type = "showPreProp", 
				opacity = 0xCC, 
				helpIcon = false, 
				preItemIndexs = {10007},	-- 配置道具ID时，寻找目标道具获取位置
				showFree = true, 			-- 免费送 显示免费标识
				autoSelect = true,			-- 关闭时自动选中
				panelName = "guide_dialogue_131_1",
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},


	--第15关，雪块说明
	[150] = {
		appear = {
			{type = "scene", scene = "game", para = 15},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 15},
			{type = "topPassedLevel",para = 14},
			{type = "noPopup"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
			    array = {
				[1] = {r = 3, c = 3, countR = 1, countC = 3},
				[2] = {r = 4, c = 3, countR = 1, countC = 3},
			    }, 
			allow = {r = 4, c = 3, countR = 2, countC = 1}, 
			from = ccp(3, 3), to = ccp(4, 3),
			text = "tutorial.game.text1500",panType = "up", panAlign = "matrixD", panPosY = 5 ,panFlip = "true",
			panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
			panelName = "guide_dialogue_150_1", -- 新引导对话框参考此处
			},
	    },
		disappear = {{type = "swap", from = ccp(3, 3), to = ccp(4, 3)},}
	},
	--[[]]
	[151] = {
		appear = {
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 15},
			{type = "noPopup"},
			{type = "topPassedLevel", para = 15},
			{type = "checkAutoPopout", para = "AreaUnlockGuidePopoutAction"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showUnlock", opacity = 0xCC, 
			text = "tutorial.game.text1510",panType = "up", panAlign = "winY", panPosY = 300,
			panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7 , cloudId = 40002,
			panelName = "guide_dialogue_152_1", -- 新引导对话框参考此处
			},
		},
		disappear = {}
	},
	[152] = {
		appear = {
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 30},
			{type = "noPopup"},
			{type = "topPassedLevel", para = 30},
			{type = "checkAutoPopout", para = "AreaUnlockGuidePopoutAction"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showUnlock", opacity = 0xCC, 
			text = "tutorial.game.text1520",panType = "up", panAlign = "winY", panPosY = 300,
			panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7 , cloudId = 40003,
			panelName = "guide_dialogue_151_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
		}
	},
	--]]
	--[[
	[153] = {
		appear = {
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 45},
			{type = "noPopup"},
			{type = "topPassedLevel", para = 45},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showUnlock", opacity = 0xCC, 
			text = "tutorial.game.text1530",panType = "up", panAlign = "winY", panPosY = 440,
			panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7 , cloudId = 40004
			},
		},
		disappear = {
		}
	},
	]]

	-- 大于第16关，展示新前置导弹
	[160] = {
		appear = {
			{type = "popup", popup = "startGamePanel"},
			{type = "scene", scene = "worldMap"},
			{type = "userLevelGreatThan", para = 15},
			{type = "onceOnly"},
			{type = "prePropImproveLogic1", func = "isNewItemLogic", expect=false},
			{type = "checkGuideFlag", para = kGuideFlags.PreProps_FireCracker},
		},
		action = {
			[1] = {
				type = "showPreProp", 
				opacity = 0xCC, 
				helpIcon = false, 
				preItemIndexs = {10099},	-- 配置道具ID时，寻找目标道具获取位置
				panelName = "guide_dialogue_160_1",	-- Change later: 160_1
			},
			[2] = {
				type = "showPreProp", 
				opacity = 0xCC,
				helpIcon=false,
				preItemIndexs={10099},		-- 配置道具ID时，寻找目标道具获取位置
				panelName = "guide_dialogue_160_2",
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},

	--第17关，时间关目标说明
	-- [170] = {
	-- 	appear = {
	-- 		{type = "popup", popup = "startGamePanel", para = 17},
	-- 		{type = "scene", scene ="worldMap"},
	-- 		{type = "topLevel", para = 17},
	-- 		{type = "onceOnly"},
	-- 	},
	-- 	action = {
	-- 		[1] = {type = "startInfo", opacity = 0xCC, index = 1, 
	-- 			text = "tutorial.game.text1700", maskPos = ccp(536, 940),multRadius=1.1 ,
	-- 			panType = "up", panAlign = "winYU", panPosY = 320, panFlip = "true",
	-- 			maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5, touchDelay = 1,
	-- 			panelName = "guide_dialogue_170_1", -- 新引导对话框参考此处
	-- 		},
	-- 	},
	-- 	disappear = {
	-- 		{type = "popdown", popdown = "startGamePanel"},
	-- 	},
	-- },
	
	--第19关，小木锤礼盒说明
	[190] = {
		appear = {
			{type = "scene", scene = "game", para = 19},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 19},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {
				type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 1},}, 
				text = "tutorial.game.text1800",panType = "up", panAlign = "matrixD", panPosY = 1.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panHorizonAlign = "winX" , panPosX = -130,
				panelName = "guide_dialogue_19_0", -- 新引导对话框参考此处
			},
			[2] = {
				type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 4},}, 
				allow = {r = 2, c = 3, countR = 1, countC = 2}, 
				from = ccp(2, 3), to = ccp(2, 4),
				text = "tutorial.game.text1801",panType = "up", panAlign = "matrixD", panPosY = 2 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panHorizonAlign = "winX" , panPosX = -130,
				panelName = "guide_dialogue_111111", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 3), to = ccp(2, 4)},

		}
	},

	[191] = {
        appear = {
            {type = "scene", scene = "game", para = 19},
            {type = "getItem", item = "gift"},
            {type = "topLevel", para = 19},
            {type = "noPopup"},
            {type = "staticBoard"},
            {type = "onceLevel"},
        },
        action = {
            [1] = {
                type = "showInfoWithPropIconAnimation", opacity = 0x00, index = 2, 
                array = {propId = 10010}, 
                text = "tutorial.game.text1901", multRadius = 1.3,
                panType = "down", 
                panAlign = "matrixD", panPosY = 3.5, 
                panHorizonAlign = "winX" , panPosX = -130,
                maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
                panelName = "guide_dialogue_19_1"
            },
            [2] = {
                type = "showProp",
                opacity = 0xCC, index = 1, 
                text = "tutorial.game.text.prop.10001", 
                multRadius=1.1 ,
                panType = "down", panAlign = "winY", panPosY = 520, panFlip = "true",
                maskDelay = 0.2,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 10010,
                clickAndUse = true,
                panelName = "guide_dialogue_222222"
            },
            [3] = {type = "showTile", opacity = 0xCC, 
                array = {
                    [1] = {r = 5, c = 1, countR = 1, countC = 1}
                }, 
                text = "tutorial.game.text7600",panType = "down", panAlign = "matrixU", panPosY = 8.5 ,
                panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
                panelName = "guide_dialogue_333333", -- 新引导对话框参考此处
                clickAndUse = true,
                allowClickArea = {r = 5, c = 1},
            },
            [4] = {
                type = "showInfo", opacity = 0xCC, index = 2, 
                text = "tutorial.game.text1901", multRadius = 1.3,
                panType = "down", panAlign = "viewY", panPosY = 650, 
                maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
                panelName = "guide_dialogue_19_3"
            },
        },
        disappear = {}
    },
	

		--第24关，小火箭礼盒引导使用

	[240] = {
		appear = {
			{type = "scene", scene = "game", para = 24},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 24},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {
				type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 5, countR = 1, countC = 1},
					[2] = {r = 5, c = 4, countR = 3, countC = 1},
			    }, 
				allow = {r = 5, c = 4, countR = 1, countC = 2}, 
				from = ccp(5, 5), to = ccp(5, 4),
				panAlign = "matrixD", panPosY = 5.5 ,
				panHorizonAlign = "matrixD" , panPosX = 5.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panelName = "guide_dialogue_10109_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 5), to = ccp(5, 4)},

		}
	},

	[241] = {
        appear = {
            {type = "scene", scene = "game", para = 24},
            {type = "getItem", item = "gift"},
            {type = "topLevel", para = 24},
            {type = "noPopup"},
            {type = "staticBoard"},
            {type = "onceLevel"},
        },
        action = {
            [1] = {
                type = "showInfoWithPropIconAnimation", opacity = 0x00, index = 2, 
                array = {propId = 10109},
                multRadius = 1.3,
                panAlign = "matrixD", panPosY = 3.5, 
                panHorizonAlign = "winX" , panPosX = -130,
                maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
                panelName = "guide_dialogue_10109_2"
            },
			[2] = {
                type = "showInfoWithPropIconAnimation", opacity = 0x00, index = 2, 
                array = {propId = 10105},
                multRadius = 1.3,
                panAlign = "matrixD", panPosY = 3.5, 
                panHorizonAlign = "winX" , panPosX = -130,
                maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
                panelName = "guide_dialogue_10105_2"
            },
		    [3] = {
                type = "showProp",
                opacity = 0xCC, index = 1, 
                multRadius=1.1 ,
                panAlign = "winY", panPosY = 520, panFlip = "true",
				panHorizonAlign = "matrixD" , panPosX = 80,
                maskDelay = 0.2,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 10109,
                clickAndUse = true,
                panelName = "guide_dialogue_10109_3"
            },
            [4] = {type = "showTile", opacity = 0xCC, 
                array = {
                    [1] = {r = 9, c = 5, countR = 9, countC = 1}
                },   
                panAlign = "matrixD", panPosY = 5.5 ,
				panHorizonAlign = "matrixD" , panPosX = 5.5,
                panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
                panelName = "guide_dialogue_10109_4", -- 新引导对话框参考此处
                clickAndUse = true,
                allowClickGridList = { [1] = {r = 1, c = 5} , [2] = {r = 3, c = 5} , [3] = {r = 5, c = 5}, [4] = {r = 7, c = 5}, [5] = {r = 9, c = 5} } ,
            },
			
            [5] = {
                type = "showProp",
                opacity = 0xCC, index = 1, 
                multRadius=1.1 ,
                panAlign = "winY", panPosY = 520, panFlip = "true",
				panHorizonAlign = "matrixD" , panPosX = 80,
                maskDelay = 2.2,maskFade = 0.4 ,panDelay = 2, touchDelay = 2, propId = 10105,
                clickAndUse = true,
                panelName = "guide_dialogue_10105_3"
            },
            [6] = {type = "showTile", opacity = 0xCC, 
                array = {
                    [1] = {r = 1, c = 1, countR = 1, countC = 9}
                }, 
                panAlign = "matrixD", panPosY = 2.5 ,
				panHorizonAlign = "matrixD" , panPosX = 5.5,
                panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
                panelName = "guide_dialogue_10105_4", -- 新引导对话框参考此处
                clickAndUse = true,
                allowClickGridList = { [1] = {r = 1, c = 1} , [2] = {r = 1, c = 3} , [3] = {r = 1, c = 5}, [4] = {r = 1, c = 7}, [5] = {r = 1, c = 9} } ,
            },
          
		},	
		disappear = {}
       
    },
	  
	
	-- 大于第21关，展示前置魔力鸟
	[210] = {
		appear = {
			{type = "scene", scene = "game", para = 21},
			{type = "getItem", item = "gift"},
			{type = "topLevel", para = 21},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showPropIconAnimation", opacity = 0x00, index = 2, 
				array = {propId = 10001}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "matrixD", panPosY = 3.5, 
				panHorizonAlign = "winX" , panPosX = -130,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_21_1"
			},
			[2] = {type = "showInfo", opacity = 0xCC, index = 2, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_21_2"
			},
		},
		disappear = {}
	},
	
	[211] = {
		appear = {
			{type = "popup", popup = "startGamePanel"},
			{type = "scene", scene = "worldMap"},
			{type = "userLevelGreatThan", para = 21},
			{type = "onceOnly"},
			{type = "prePropImproveLogic1", func = "isNewItemLogic", expect=false},
			{type = "checkGuideFlag", para = kGuideFlags.PreProps_MagicBird},
			{type = "checkGuideFlag1", para = kGuideFlags.PreProps_MagicBird_Free},
		},
		action = {
			[1] = {
				type = "showPreProp", 
				opacity = 0xCC, 
				helpIcon = false, 
				preItemIndexs = {10087},	-- 配置道具ID时，寻找目标道具获取位置
				panelName = "guide_dialogue_211_1",
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},

	-- 等于第21关，免费送前置魔力鸟
	[212] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 21},
			{type = "scene", scene = "worldMap"},
			{type = "userLevelEqual", para = 21},
			{type = "onceOnly"},
			{type = "prePropImproveLogic1", func = "isNewItemLogic", expect=false},
			{type = "checkGuideFlag", para = kGuideFlags.PreProps_MagicBird_Free},
		},
		action = {
			[1] = {
				type = "showPreProp", 
				opacity = 0xCC, 
				helpIcon = false, 
				preItemIndexs = {10087},	-- 配置道具ID时，寻找目标道具获取位置
				showFree = true, 			-- 免费送 显示免费标识
				autoSelect = true,			-- 关闭时自动选中
				panelName = "guide_dialogue_212_1",
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},

	--23关魔法棒引导
	[230] = {
		appear = {
			{type = "scene", scene = "game", para = 23},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 23},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
			    array = {
					[1] = {r = 7, c = 3, countR = 1, countC = 1},
					[2] = {r = 8, c = 2, countR = 1, countC = 2},
					[3] = {r = 9, c = 3, countR = 1, countC = 1},
			    }, 
				allow = {r = 8, c = 2, countR = 1, countC = 2}, 
				from = ccp(8, 2), to = ccp(8, 3),
				text = "tutorial.game.text2300new",panType = "up", panAlign = "matrixD", panPosY = 4.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panHorizonAlign = "winX" , panPosX = -130,
				panelName = "guide_dialogue_230_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
			{type = "swap", from = ccp(8, 2), to = ccp(8, 3)},
			{type = "numMoves", para = 1}
		}
	},
	 --第二步，把一个动物变成横向特效
    [231] = {
		appear = {
			{type = "scene", scene = "game", para = 23},
			{type = "topLevel", para = 23},
			{type = "noPopup"},
			{type = "numMoves", para = 1},
			{type = "curLevelGuided", guide = { 230 }},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {
				type = "useMagicPropTip", opacity = 0xCC, 
				propId = 10005,
				direction="row",--横向特效
				array = {					
					[1] = {r = 7, c = 5, countR = 1, countC = 1}, 
				}, 
			    allow={r = 7,c = 5, countR = 1, countC = 1},
				from = ccp(7, 5), to = ccp(7, 5),
	            text = "",panType = "down",panFlip = "true",
				panHorizonAlign = "winX", panPosX = -130,
				panAlign = "matrixU", panPosY = 7.5 ,
			    maskDelay = 0.8, maskFade = 0.2, panDelay = 0.8, panFade = 0.1,touchDelay = 1.4,
				panelName = "guide_dialogue_231_2", -- 新引导对话框参考此处
				panelName2 = "guide_dialogue_231_1",
			},
		},
		disappear = {
			{type = "usePropComplete", propId=10027},
		}
	},
	[232] = {
		appear = {
			{type = "scene", scene = "game", para = 23},
			{type = "topLevel", para = 23},
			{type = "noPopup"},
			{type = "numMoves", para = 1},
			{type = "curLevelGuided", guide = { 230 }},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {
				type = "useMagicPropTip", opacity = 0xCC, 
				propId = 10005,
				direction="column",--横向特效
				array = {					
					[1] = {r = 8, c = 5, countR = 1, countC = 1}, 
				}, 
				allow={r = 8,c = 5, countR = 1, countC = 1},
				from = ccp(8, 5), to = ccp(8, 5),
	            text = "",panType = "down",panFlip = "true",
				panHorizonAlign = "winX", panPosX = -130,
				panAlign = "matrixU", panPosY = 7.5 ,
			    maskDelay = 0.8, maskFade = 0.2, panDelay = 0.8, panFade = 0.1,touchDelay = 1.4,
				panelName = "guide_dialogue_232_2", -- 新引导对话框参考此处
				panelName2 = "guide_dialogue_232_1",
			},
		},
		disappear = {
			{type = "usePropComplete", propId=10027},
		}
	},
    --第四步，提示玩家交换特效收集一个金豆荚
    [233] = {
		appear = {
			{type = "scene", scene = "game", para = 23},
			{type = "numMoves", para = 1},
			{type = "curLevelGuided", guide = { 230, 231, 232 }},
			{type = "topLevel", para = 23},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
			    array = {
					[1] = {r = 7, c = 5, countR = 1, countC = 1},
					[2] = {r = 8, c = 5, countR = 1, countC = 1},
			    }, 
				allow = {r = 8, c = 5, countR = 2, countC = 1}, 
				from = ccp(7, 5), to = ccp(8, 5),
				text = "tutorial.game.text2300new",panType = "up", panAlign = "matrixD", panPosY = 4.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panHorizonAlign = "winX" , panPosX = -130,
				panelName = "guide_dialogue_233_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(8, 5)},
		}
	},
    
    --26关引导玩家使用强制交换道具
	[260] = {
		appear = {
			{type = "scene", scene = "game", para = 26},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 26},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
			    array = {
					[1] = {r = 3, c = 3, countR = 1, countC = 1},
					[2] = {r = 4, c = 2, countR = 1, countC = 3},
			    },  
				allow = {r = 4, c = 3, countR = 2, countC = 1}, 
				from = ccp(3, 3), to = ccp(4, 3),
				text = "tutorial.game.text2300new",panType = "up", panAlign = "matrixD", panPosY = 0.1 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panHorizonAlign = "winX" , panPosX = -130,
				panelName = "guide_dialogue_260_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
			{type = "swap", from = ccp(3, 3), to = ccp(4, 3)},
		}
	},
    
    --第二步，使用强制交换，把两个特效交换到一起
    [261] = {
		appear = {
			{type = "scene", scene = "game", para = 26},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 26},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {type = "useGiftTip", opacity = 0xCC, 
				propId = 10003,
				array = {					
					[1] = {r = 5, c = 5, countR = 1, countC = 1}, 
					[2] = {r = 6, c = 5, countR = 1, countC = 1},
				}, 
				allow={r = 6,c = 5, countR = 2, countC = 1},
				from = ccp(5, 5), to = ccp(6, 5),
	            text = "tutorial.game.text2300new",panType = "down",panFlip = "true",
				panHorizonAlign = "winX", panPosX = -130,
				panAlign = "matrixU", panPosY = 7 ,
	            panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panelName = "guide_dialogue_261_1", -- 新引导对话框参考此处
	},
		},
		disappear = {
			{type = "usePropComplete", propId=10028},
		}
	},  
    
    --第三步，告知玩家可点问号查看道具说明
    [262] = {
		appear = { 
		    {type = "scene", scene = "game", para = 26},
			{type = "numMoves", para = 1},
			{type = "curLevelGuided", guide = { 260,261 }},
			{type = "topLevel", para = 26},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
		},
        action = {
		    [1] = {type = "showInfoNew", opacity = 0x00, index = 2, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 360, 
				panHorizonAlign = "winX" , panPosX = 30,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_26_3"
			},
		},
		disappear = {}
	},

	[290] = {
		appear = {
			{type = "scene", scene = "game", para = 29},
			{type = "getItem", item = "gift"},
			{type = "topLevel", para = 29},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showPropIconAnimation", opacity = 0x00, index = 2, 
				array = {propId = 10002}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "matrixD", panPosY = 3.5, 
				panHorizonAlign = "winX" , panPosX = -130,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_20_1"
			},
			[2] = {type = "showInfo", opacity = 0xCC, index = 2, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_20_2"
			},
		},
		disappear = {}
	},

	[1820] = {
		appear = {
			{type = "scene", scene = "game", para = 182},
			{type = "getItem", item = "gift"},
			{type = "topLevel", para = 182},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showPropIconAnimation", opacity = 0x00, index = 2, 
				array = {propId = 10052}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "matrixD", panPosY = 3.5, 
				panHorizonAlign = "winX" , panPosX = -130,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_182_1"
			},
			[2] = {type = "showInfo", opacity = 0xCC, index = 2, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_182_2"
			},
		},
		disappear = {}
	},
	

	-- 测试引导 popImage
	-- [220] = {
	-- 	appear = {
	-- 		{type = "scene", scene = "game", para = 22},
	-- 		{type = 'numMoves', para = 0},
	-- 	},
	-- 	action = {
	-- 		[1] = {type = 'popImage', 
	-- 		pics = {
	-- 			[1] = {align = 'top_center', groupName = 'guide_dialogue_test_group_2', scale = 1, x = -225, y = 0,},
	-- 		},
	-- 		opacity = 180, maskDelay = 0.3, maskFade = 0.4, touchDelay = 1.1,},
	-- 	},
	-- 	disappear = {}
	-- },
	-- [240] = {
	-- 	appear = {
	-- 		{type = "scene", scene = "game", para = 24},
	-- 		{type = 'numMoves', para = 0},
	-- 	},
	-- 	action = {
	-- 		[1] = {type = 'popImage', 
	-- 		pics = {
	-- 			[1] = {align = 'board', groupName = 'guide_dialogue_test_group_3', scale = 0.96, x = 3.42, y = 2.46,},
	-- 			[2] = {align = 'board', groupName = 'guide_dialogue_test_group_3', scale = 0.96, x = 6.42, y = 2.46,},
	-- 		},
	-- 		opacity = 180, maskDelay = 0.3, maskFade = 0.4, touchDelay = 1.1,},
	-- 	},
	-- 	disappear = {}
	-- },
	--第47关，目标是直线特效时候的引导
	[470] = {
		appear = {
			{type = "scene", scene = "game", para = 47},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 47},
			{type = "noPopup"},
			-- {type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showObj", opacity = 0xCC, index = 1, 
			text = "tutorial.game.text4700", panType = "up", panAlign = "winYU", panPosY = 50,
			maskDelay = 1,maskFade = 0.4, panDelay = 1.3, touchDelay = 1.9,
			panelName = "guide_dialogue_470_1", -- 新引导对话框参考此处
			}, 
		},
		disappear = {}
	},
	--第76关，毒液说明
	[760] = {
		appear = {
			{type = "scene", scene = "game", para = 76},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 76},
			{type = "noPopup"},	
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 5, countR = 1, countC = 1}
				}, 
				text = "tutorial.game.text7600",panType = "down", panAlign = "matrixU", panPosY = 9.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panelName = "guide_dialogue_760_1", -- 新引导对话框参考此处
			},
		},
		disappear = {}
	},
	--第91关，银币说明
	[910] = {
		appear = {
			{type = "scene", scene = "game", para = 91},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 91},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {					[1] = {r = 9, c =6, countR = 6, countC =1}, 
					[2] = {r = 4, c =7, countR = 1, countC =3},
					[3] = {r = 9, c =8, countR = 1, countC =1}, 
					[4] = {r = 8, c =7, countR = 1, countC =1},
					[5] = {r = 8, c =9, countR = 1, countC =1}, 
					[6] = {r = 7, c =8, countR = 1, countC =1}, 
					[7] = {r = 6, c =7, countR = 1, countC =1},
					[8] = {r = 6, c =9, countR = 1, countC =1},
					[9] = {r = 5, c =8, countR = 1, countC =1},
				}, 
				text = "tutorial.game.text9100",panType = "down", panAlign = "matrixU", panPosY = 4 ,panFlip = "true",
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4, touchDelay = 1.7,
				panelName = "guide_dialogue_910_1", -- 新引导对话框参考此处
			},
		},
		disappear = {}
	},
	--第106关，褐色毛球说明
	[1060] = {
		appear = {
			{type = "scene", scene = "game", para = 106},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 106},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
					[1] = {r = 0, c = 0, countR = 0, countC = 0},
				}, 
				text = "tutorial.game.text10600",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_106_1", -- 新引导对话框参考此处
			},
		},
		disappear = {}
	},
    --第121鸡窝关，指示鸡窝的位置，消除一次
	[1210] = {
		appear = {
			{type = "scene", scene = "game", para = 121},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 121},
			{type = "noPopup"},
			{type = "onceLevel"},
			--{type = "onceOnly"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
					[1] = {r = 4, c = 7, countR = 1, countC = 1}
				}, 
				text = "tutorial.game.text12100",panType = "up", panAlign = "matrixD", panPosY = 3.5, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1210_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 4, c = 5, countR = 1, countC = 1}, 
					[2] = {r = 4, c = 6, countR = 3, countC = 1},
					[3] = {r = 4, c = 7, countR = 1, countC = 1}
				}, 
				allow = {r = 4, c = 5, countR = 1, countC = 2}, 
				from = ccp(4.3, 5), to = ccp(4.3, 6), 
				text = "tutorial.game.text12101",panType = "up", panAlign = "matrixD", panPosY = 4,
				panDelay =0.1 , handDelay = 0.3 ,
				panelName = "guide_dialogue_1210_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(4, 5), to = ccp(4, 6)},
		}
	},
	-- 消除第二次，炸鸡窝第二次
	[1211] = {
		appear = {
			{type = "scene", scene = "game", para = 121},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 121},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 1210 },}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 6, countR = 3, countC = 1 }, 
					[2] = {r = 3, c = 7, countR = 1, countC = 1 },
					[3] = {r = 5, c = 7, countR = 1, countC = 1 },
					[4] = {r = 4, c = 7, countR = 1, countC = 1 }
					
				}, 
				allow = {r = 3, c = 6, countR = 1, countC = 2}, 
				from = ccp(3.3, 6), to = ccp(3.3, 7), 
				text = "tutorial.game.text12102",panType = "up", panAlign = "matrixD", panPosY = 4.5,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_1211_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(3, 6), to = ccp(3, 7)},
		}
	},
	-- 消除第三次，炸出小鸡
	[1212] = {
		appear = {
			{type = "scene", scene = "game", para = 121},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 121},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 1210, 1211 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 8, countR = 1, countC = 1 }, 
					[2] = {r = 4, c = 7, countR = 1, countC = 3 },
					[3] = {r = 5, c = 8, countR = 1, countC = 1 },
				}, 
				allow = {r = 4, c = 8, countR = 1, countC = 2}, 
				from = ccp(4.3, 8), to = ccp(4.3, 9), 
				text = "tutorial.game.text12103",panType = "up", panAlign = "matrixD", panPosY = 4.5,
				handDelay = 1.3 , panDelay = 1.1, maskDelay = 0.9,
				panelName = "guide_dialogue_1212_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(4, 8), to = ccp(4, 9)},
		}
	},
	--136彩云关，展示彩云，消除一次
	[1360] = {
		appear = {
			{type = "scene", scene = "game", para = 136},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 136},
			{type = "noPopup"},
			{type = "onceLevel"},
			--{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
					[1] = {r = 9, c = 1, countR = 3, countC = 1},
					[2] = {r = 9, c = 2, countR = 3, countC = 1},
					[3] = {r = 9, c = 3, countR = 2, countC = 1},
					[4] = {r = 9, c = 4, countR = 1, countC = 1},
					[5] = {r = 8, c = 6, countR = 3, countC = 1},
					[6] = {r = 9, c = 7, countR = 2, countC = 1},
					[7] = {r = 9, c = 8, countR = 4, countC = 1},
					[8] = {r = 9, c = 9, countR = 2, countC = 1},
				}, 
				text = "tutorial.game.text13600", panType = "down", panAlign = "matrixU", panPosY = 6.5, panFlip = "true",
				panDelay = 1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.5,
				panelName = "guide_dialogue_1360_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 7, c = 7, countR = 4, countC = 1}, 
					[2] = {r = 5, c = 6, countR = 1, countC = 1}
				}, 
				allow = {r = 5, c = 6, countR = 1, countC = 2}, 
				from = ccp(5.3, 6), to = ccp(5.3, 7), 
				text = "tutorial.game.text13601",panType = "down", panAlign = "matrixU", panPosY = 5.5, panFlip = "true" ,
				panDelay =0.1 , handDelay = 0.3,
				panelName = "guide_dialogue_1360_2", -- 新引导对话框参考此处
			}
		},
		disappear = {
			{type = "swap", from = ccp(5, 6), to = ccp(5, 7)},
		}
	},
	-- 消除红宝石云彩一次
	[1361] = {
		appear = {
			{type = "scene", scene = "game", para = 136},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 136},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 1360 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 6, countR = 1, countC = 1 }, 
					[2] = {r = 7, c = 6, countR = 1, countC = 3 },
					[3] = {r = 8, c = 8, countR = 1, countC = 1 }
				}, 
				allow = {r = 7, c = 6, countR = 2, countC = 1}, 
				from = ccp(6, 6.3), to = ccp(7, 6.3), 
				text = "tutorial.game.text13602",panType = "down", panAlign = "matrixU", panPosY = 7.5, panFlip = "true" ,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_1361_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(6, 6), to = ccp(7, 6)},
		}
	},
	-- 消除第三次，让云层上升
	[1362] = {
		appear = {
			{type = "scene", scene = "game", para = 136},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 136},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 1360, 1361 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 7, c = 3, countR = 1, countC = 1 }, 
					[2] = {r = 6, c = 1, countR = 1, countC = 5 },
				}, 
				allow = {r = 7, c = 3, countR = 2, countC = 1}, 
				from = ccp(7, 3.3), to = ccp(6, 3.3), 
				text = "tutorial.game.text13603",panType = "down", panAlign = "matrixU", panPosY = 7, 
				handDelay = 1.3 , panDelay = 1.1, maskDelay = 0.9,
				panelName = "guide_dialogue_1362_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(7, 3), to = ccp(6, 3)},
		}
	},
		--[1363] = {
		--appear = {
		--	{type = "scene", scene = "game", para = 136},
		--	{type = "numMoves", para = 3},
		--	{type = "staticBoard"},
		--	{type = "topLevel", para = 136},
		--	{type = "noPopup"},
		--	{type = "onceLevel"},
		--	{type = "curLevelGuided", guide = { 1360, 1361, 1362 },}
		--},
		--action = {
		--	[1] = {type = "showHint",text = "tutorial.game.text503",
		--		reverse = true ,animPosY = 0, panOrigin = ccp(-550,130),panFinal = ccp(120,130), animScale = 0.7,
		--		animDelay = 0.8, panDelay = 1.2 ,
		--	}
		--},
		--disappear = {
		--	{type = "scene", scene = ""},
		--}
	--},
--第166关，金豆荚说明
	[1660] = {
		appear = {
			{type = "scene", scene = "game", para = 166},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 166},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
   			[1] = {type = "showUFO", opacity = 0xCC, 
				position = ccp(1, 4), width = 0, height = 0, oval = true, deltaY = 15,
				text = "tutorial.game.text16601",panType = "up", panAlign = "matrixD", panPosY = 0,
				panDelay = 1.1, maskDelay = 1.2 ,maskFade = 0.4,touchDelay = 1.7, panFlip = true ,
				panelName = "guide_dialogue_1660_1", -- 新引导对话框参考此处
				panImage = {
					[1] = { image = "guides_ufo.png", scale = ccp(1, 1) , x = 300 , y = 230},
				},
			}
		},
		disappear = {}
	},
--第167关，火箭说明
	[1670] = {
		appear = {
			{type = "scene", scene = "game", para = 167},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 167},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 5, countR = 1, countC = 1}, 
					[2] = {r = 4, c = 4, countR = 1, countC = 3}
				}, 
				allow = {r = 5, c = 5, countR = 2, countC = 1}, 
				from = ccp(5, 5), to = ccp(4, 5), 
				text = "tutorial.game.text16701",panType = "up", panAlign = "matrixD", panPosY =  5, panFlip = "true" ,
				panDelay =0.1 , handDelay = 0.3,
				panelName = "guide_dialogue_1670_1", -- 新引导对话框参考此处
				panImage = {
					[1] = { image = "guides_ufo.png", scale = ccp(1, 1) , x = 720 - 140 , y = 0, rotation=-12.7},
					[2] = { image = "guides_ufo_rocket.png", scale = ccp(1, 1) , x = 720 - 57 , y = -105, rotation=-39},
				},
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 5), to = ccp(4, 5)},
		},
	},
--第181关，章鱼说明
	[1810] = {
		appear = {
			{type = "scene", scene = "game", para = 181},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 181},
			{type = "noPopup"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 8, c = 3, countR = 1, countC = 1},
				    [2] = {r = 8, c = 5, countR = 1, countC = 1},
				    [3] = {r = 8, c = 7, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text18100",panType = "down", panAlign = "matrixD", panPosY = 2.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1810_1", -- 新引导对话框参考此处
			},
			--[2] = {
			--	type = "showObj", 
			--	opacity = 0xCC, 
			--	index = 2, 
			--	text = "tutorial.game.text18101", 
			--	panType = "up",
			--	panAlign = "matrixD", 
			--	panPosY = 2.5 ,
			--	panDelay = 1.1, 
			--	maskDelay = 0.8 ,
			--	maskFade = 0.4,
			--	touchDelay = 1.7,
				
			--},
		},
		disappear = {}
	},	

	--- 第182关，章鱼冰道具说明
	--[[
	[1820] = {
		appear = {
			{type = "scene", scene ="game", para = 182},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 182},
			{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "noPopup"},
		},
		action = {
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text18200", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 720, panFlip = "true",
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 10052,
			},
			[2] = {type = "giveProp", opacity = 0xCC, index = 1, 
				text = "tutorial.game.text18201", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 720, panFlip = "true",
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5, touchDelay = 1,
				propId = 10052, tempPropId = 10053, count = 1,
				panImage = {
						[1] = { image = "Prop_10052_sprite0000", scale = ccp(1, 1) , x = 450 , y = -175},
					},
			},
		},
		disappear = {},
	},
	]]

--第196关，地格说明	
	[1960] = {
		appear = {
			{type = "scene", scene = "game", para = 196},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 196},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 4, c = 4, countR = 1, countC = 1},
				    [2] = {r = 4, c = 6, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text19600",panType = "up", panAlign = "matrixD", panPosY = 2 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1960_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {}
	},
	-- 消除第一次，地块边缘变色说明，障碍地格说明
	[1961] = {
		appear = {
			{type = "scene", scene = "game", para = 196},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 196},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 1960 },},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 4, c = 4, countR = 1, countC = 1},
				    [2] = {r = 4, c = 6, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text19601",panType = "up", panAlign = "matrixD", panPosY = 2 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1961_1", -- 新引导对话框参考此处
			},
			[2]= {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 0, c = 0, countR = 0, countC = 0},
				}, 
				text = "tutorial.game.text19602",panType = "down", panAlign = "matrixD", panPosY = 1.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1961_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(7, 3), to = ccp(6, 3)},
		}
	},
	--[[
	不要打开，否则进关卡就卡死-。-
	--第211关，雪怪说明	 ,废弃
    [2110] = {
		appear = {},
		action = {},
		disappear = {}
	},
	-- 消除第一次，雪怪右上角处的冰消除，进入下一步说明,废弃
	[2111] = {
		appear = {},
		action = {},
		disappear = {}
	},
	--]]
--弹框引导
	-- [2114] = {
	-- 	appear = {
	-- 		{type = "hasGuide", guideArray = {2110, 2111}},
	-- 		{type = "scene", scene = "game", para ={212, 215, 223, 228, 229, 237, 239, 243, 249, 252, 255, 258, 264, 269, 284, 296, 302, 342, 350, 375, 395, 431, 462, 506, 536}},
	-- 		{type = "numMoves", para = 0},
	-- 		{type = "topLevel", para = 211},
	-- 		{type = "noPopup"},
	-- 		{type = "onceOnly"},
	-- 		{type = "onceLevel"}
	-- 	},
	-- 	action = {
	-- 	    [1] = {type = "showTile", opacity = 0xCC, 
	-- 			array = {
	-- 			    [1] = {r = 9, c = 1, countR = 9, countC = 9}, 
	-- 			}, 
	-- 			text = "tutorial.game.text21104",panType = "up", panAlign = "matrixD", panPosY = 7.5 ,
	-- 			panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
	-- 		},
	-- 	},
	-- 	disappear = {}
	-- },

--新引导
	[2112] = {
		appear = {
			{type = "scene", scene = "game", para = 211},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 211},
			{type = "noPopup"},
			-- {type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 4, c = 2, countR = 1, countC = 1},
				    [2] = {r = 4, c = 3, countR = 1, countC = 1},
				    [3] = {r = 5, c = 2, countR = 1, countC = 1},
				    [4] = {r = 5, c = 3, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text21100",panType = "up", panAlign = "matrixD", panPosY = 4 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2112_1", -- 新引导对话框参考此处
			},			
		    [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 3, countR = 1, countC = 4},
                         [2] = {r = 5, c = 2, countR = 2, countC = 2},
				}, 
				allow = {r = 3, c = 5, countR = 1, countC = 2}, 
				from = ccp(3.3, 6), to = ccp(3.3, 5.3), 
				text = "tutorial.game.text21101", panType = "up", panAlign = "matrixD", panPosY = 4, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2112_2", -- 新引导对话框参考此处
		    },
		},
		disappear = {
			{type = "swap", from = ccp(3, 6), to = ccp(3, 5)},
		}
	},
	-- 消除第一次，雪怪右上角处的冰消除，进入下一步说明
	[2113] = {
		appear = {
			{type = "scene", scene = "game", para = 211},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 211},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 2112 },},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 4, c = 2, countR = 1, countC = 1},
				    [2] = {r = 4, c = 3, countR = 1, countC = 1},
				    [3] = {r = 5, c = 2, countR = 1, countC = 1},
				    [4] = {r = 5, c = 3, countR = 1, countC = 1}, 
				}, 
				text = "tutorial.game.text21102",panType = "up", panAlign = "matrixD", panPosY = 4 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2113_1", -- 新引导对话框参考此处
			},
			--[2] = {type = "showTile", opacity = 0xCC, 
			--	array = {
			--	    [1] = {r = 4, c = 2, countR = 1, countC = 1},
			--	    [2] = {r = 4, c = 3, countR = 1, countC = 1},
			--	    [3] = {r = 5, c = 2, countR = 1, countC = 1},
			--	    [4] = {r = 5, c = 3, countR = 1, countC = 1}, 
			--	    [5] = {r = 4, c = 7, countR = 1, countC = 1},
			--	    [6] = {r = 4, c = 8, countR = 1, countC = 1},
			--	    [7] = {r = 5, c = 7, countR = 1, countC = 1},
			---	    [8] = {r = 5, c = 8, countR = 1, countC = 1},
			--	}, 
			--	text = "tutorial.game.text21103",panType = "up", panAlign = "matrixD", panPosY = 6.5 ,
			--	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			--},
		},
		disappear = {}
	},
--第241关，黑色毛球说明	
	[2410] = {
		appear = {
			{type = "scene", scene = "game", para = 241},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 241},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 9, c = 2, countR = 1, countC = 1},
				    [2] = {r = 9, c = 4, countR = 1, countC = 1},
				    [3] = {r = 9, c = 6, countR = 1, countC = 1},
				    [4] = {r = 9, c = 8, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text24100",panType = "down", panAlign = "matrixD", panPosY = 3.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2410_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {}
	},
--第271关，含羞草说明	
	[2710] = {
		appear = {
			{type = "scene", scene = "game", para = 271},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 271},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 0, c = 0, countR = 0, countC = 0}}, 
				text = "tutorial.game.text27100",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2710_1", -- 新引导对话框参考此处
			},			
		    [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 2, countR = 1, countC = 3},
                         [2] = {r = 2, c = 2, countR = 1, countC = 1},
                         [3] = {r = 5, c = 1, countR = 1, countC = 1}, --R=第几行 C=第几列 CR=竖着几个 CC=横着几个
				}, 
				allow = {r = 2, c = 2, countR = 2, countC = 1}, 
				from = ccp(2, 2), to = ccp(1, 2), 
				text = "tutorial.game.text27101", panType = "up", panAlign = "matrixD", panPosY = 3.5, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2710_2", -- 新引导对话框参考此处
				
		    },
		},
		disappear = {
			{type = "swap", from = ccp(2, 2), to = ccp(1, 2)},
		},
	},
-- 消除第一次，绿叶球就要向外生长了，进入下一步说明
	[2711] = {
		appear = {
			{type = "scene", scene = "game", para = 271},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 271},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 2710 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 2, countR = 1, countC = 2},
                         [2] = {r = 4, c = 2, countR = 3, countC = 1},
                         [3] = {r = 5, c = 1, countR = 1, countC = 1},--R=第几行 C=第几列 CR=竖着几个 CC=横着几个
				}, 
				allow = {r = 2, c = 2, countR = 1, countC = 2}, 
				from = ccp(2, 3), to = ccp(2, 2), 
				text = "tutorial.game.text27102", panType = "down", panAlign = "matrixD", panPosY = 5.5, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2711_1", -- 新引导对话框参考此处
				
		    },
		},
		disappear = {
			{type = "swap", from = ccp(2, 3), to = ccp(2, 2)},
		}
	},
-- 消除第二次，绿叶球向外生长两格，进入下一步说明
	[2712] = {
		appear = {
			{type = "scene", scene = "game", para = 271},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 271},
			{type = "noPopup"},
			{type = "staticBoard"},
			--{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 2711 },},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 5, c = 1, countR = 1, countC = 3},
				}, 
				text = "tutorial.game.text27103",panType = "up", panAlign = "matrixD", panPosY = 4.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2712_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 3, countR = 4, countC = 1},
                         [2] = {r = 5, c = 1, countR = 1, countC = 2},--R=第几行 C=第几列 CR=竖着几个 CC=横着几个
				}, 
				allow = {r = 3, c = 3, countR = 2, countC = 1}, 
				from = ccp(2, 3), to = ccp(3, 3), 
				text = "tutorial.game.text27102", panType = "down", panAlign = "matrixD", panPosY = 0, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2712_3", -- 新引导对话框参考此处
				
		    },
			--[2] = {type = "showTile", opacity = 0xCC, 
				--array = {
				    --[1] = {r = 5, c = 3, countR = 1, countC = 3},
				--}, 
				--text = "tutorial.game.text27104",panType = "up", panAlign = "matrixD", panPosY = 6.5 ,
				--panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				--panelName = "guide_dialogue_2712_2", -- 新引导对话框参考此处
			--},
		},
		disappear ={{type = "swap", from = ccp(2, 3), to = ccp(3, 3)},}
	},		
--第331关，蜗牛说明
	[3310] = {
			appear = {
				{type = "scene", scene = "game", para = 331},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 331},
				{type = "noPopup"},
				--{type = "onceOnly"},
				{type = "onceLevel"}
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
				 	array = {{r = 1, c = 8, countR = 1, countC = 1}}, 
				 	text = "tutorial.game.text33100",panType = "up", panAlign = "matrixD", panPosY = 1.5 ,panFlip="true",
				 	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				 	panelName = "guide_dialogue_33100_1", -- 新引导对话框参考此处
				 },				
				[2] = {type = "showTile", opacity = 0xCC, 
				 	array = {{r = 4, c = 6, countR = 1, countC = 1}}, 
				 	text = "tutorial.game.text33100",panType = "up", panAlign = "matrixD", panPosY = 4.5 ,panFlip="true",
				 	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				 	panelName = "guide_dialogue_33100_3", -- 新引导对话框参考此处
				},	
				[3] = {type = "showSnail", opacity = 0xCC, index = 2, 
					panAlign = "matrixD", panPosY = 7.5, panType = "up", 
					maskDelay = 1,maskFade = 0.4, panDelay = 1.3, panFade = 0.2, touchDelay = 1.9,
					width = 3, height = 1.2,
					panelName = "guide_dialogue_33100_2", -- 新引导对话框参考此处
				},
			    [4] = {type = "gameSwap", opacity = 0xCC, 
				 	array = {[1] = {r = 4, c = 8, countR = 4, countC = 1},
	                          [2] = {r = 2, c = 7, countR = 1, countC = 1},
				 	}, 
				 	allow = {r = 2, c = 7, countR = 1, countC = 2}, 
				 	from = ccp(2.3, 8.3), to = ccp(2.3, 7.3), 
				 	text = "tutorial.game.text33101", panType = "up", panAlign = "matrixD", panPosY = 3, panFlip="true",
				 	handDelay = 1.2 , panDelay = 0.8 , 
				 	panelName = "guide_dialogue_33100_4", -- 新引导对话框参考此处
			     },
			},
			disappear = {
				{type = "swap", from = ccp(2, 7), to = ccp(2, 8)},
			},
		},
-- 消除第一次，消除与蜗牛相邻的小动物，进入下一步说明
	--[3311] = {
			--appear = {
				--{type = "scene", scene = "game", para = 331},
				--{type = "numMoves", para = 1},
				--{type = "topLevel", para = 331},
				--{type = "noPopup"},
				--{type = "staticBoard"},
				--{type = "onceOnly"},
				--{type = "onceLevel"},
				--{type = "curLevelGuided", guide = { 3310 },},
			--},
			--action = {
			--	[1] = {type = "showTile", opacity = 0xCC, 
			--		array = {
			--		    [1] = {r = 4, c = 8, countR = 4, countC = 1},
			--		    [2] = {r = 4, c = 6, countR = 1, countC = 1},
			--		}, 
			--		text = "tutorial.game.text33102",panType = "up", panAlign = "matrixD", panPosY = 5.0 ,panFlip="true",
			--		panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
			--		panelName = "guide_dialogue_33110_1", -- 新引导对话框参考此处
			--	},			
			--},
			--disappear = {}
		--},
		-- 活动关卡引导
	[130000] = {
		appear = {
				{type = "scene", scene = "game", para = {130001, 130002, 130003, 130004, 130005}},
				{type = "numMoves", para = 0},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
			},
		action = {
				[1] = {type = "showInfo", opacity = 0xCC, 
					text = "activity.mid.autumn.tutorial",panType = "up", panAlign = "matrixD", panPosY = 5.0 ,panFlip="true",
					panDelay = 5.2, maskDelay = 5.1 ,maskFade = 0.4,touchDelay = 1.7,
					panImage = {
						[1] = { image = "guides_panImage_mayday_boss.png", scale = ccp(1, 1) , x = 300 , y = -300},
					},
				},			
			},
		disappear = {}
	},
	[150000] = {
		appear = {
				{type = "scene", scene = "game", para = {150037, 150038, 150039, 150040, 150041}},
				{type = "numMoves", para = 0},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
			},
		action = {
				[1] = {type = "showInfo", opacity = 0xCC, 
					text = "activity.thanksgiving.tutorial",panType = "up", panAlign = "matrixD", panPosY = 5.0 ,panFlip="true",
					panDelay = 5.2, maskDelay = 5.1 ,maskFade = 0.4,touchDelay = 1.7,
					panImage = {
						[1] = { image = "guides_thanksgiving.png", scale = ccp(1, 1) , x = 300 , y = -300},
					},
				},			
			},
		disappear = {}
	},
--第376关，传送带说明
	[3760] = {
			appear = {
				{type = "scene", scene = "game", para = 376},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 376},
				{type = "noPopup"},
				--{type = "onceOnly"},
				{type = "onceLevel"}
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {{r = 4, c = 1, countR = 1, countC = 9}}, 
					text = "tutorial.game.text37600",panType = "up", panAlign = "matrixD", panPosY = 2.5 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_3760_1", -- 新引导对话框参考此处
				},			
			},
			disappear = {},
	},	
--第406关，海洋生物说明
	[4060] = {
		appear = {
			{type = "scene", scene = "game", para = 406},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 406},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 2, countR = 3, countC = 1},
                         [2] = {r = 1, c = 3, countR = 1, countC = 1},
				}, 
				allow = {r = 1, c = 2, countR = 1, countC = 2}, 
				from = ccp(1, 2.3), to = ccp(1, 3.3), 
				text = "tutorial.game.text40600", panType = "up", panAlign = "matrixD", panPosY = 1.5, 
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_4060_1", -- 新引导对话框参考此处
				},
			},
		disappear = {
			{type = "swap", from = ccp(1, 2), to = ccp(1, 3)},
		},
	},
	[4061] = {
		appear = {
			{type = "scene", scene = "game", para = 406},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "topLevel", para = 406},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 4060 },},
		},
		action = {
			[1] = {type = "popImage", opacity = 0xCC, index = 2, 
				text = "tutorial.game.text40601", panAlign = "winYU", panPosY = 50, panType = "up", 
				maskDelay = 1,maskFade = 0.4, panDelay = 1.3, panFade = 0.2, touchDelay = 1.9,
				width = 3, height = 1.2,
				panelName = "guide_dialogue_4061_1", -- 新引导对话框参考此处
				pics = {
					[1] = {align = 'relative', groupName = 'pic_4060', scale = 1.12, x = -78, y = 7, baseOn="levelTargetTilePos", para=1},
				},
			},
		},
		disappear = {},
	},
--第436关，增益障碍说明
[4360] = {
		appear = {
			{type = "scene", scene = "game", para = 436},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 436},
			{type = "noPopup"},
			{type = "onceLevel"},
			--{type = "onceOnly"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 5, countR = 1, countC = 1}
				}, 
				text = "tutorial.game.text43600",panType = "up", panAlign = "matrixD", panPosY = 3.5, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_4360_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 4, c = 3, countR = 1, countC = 1}, 
					[2] = {r = 5, c = 3, countR = 1, countC = 3}
				}, 
				allow = {r = 5, c = 3, countR = 2, countC = 1}, 
				from = ccp(4, 3.3), to = ccp(5, 3.3), 
				text = "tutorial.game.text43601",panType = "up", panAlign = "matrixD", panPosY = 4.5,
				panDelay =0.1 , handDelay = 0.3 ,
				panelName = "guide_dialogue_4360_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(4, 3), to = ccp(5, 3)},
		}
	},
--消除第二次
[4361] = {
		appear = {
			{type = "scene", scene = "game", para = 436},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 436},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 4360 },}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 5, countR = 1, countC = 1 }, 
					[2] = {r = 7, c = 6, countR = 3, countC = 1 }
				}, 
				allow = {r = 5, c = 5, countR = 1, countC = 2}, 
				from = ccp(5.3, 5), to = ccp(5.3, 6), 
				text = "tutorial.game.text43602",panType = "up", panAlign = "matrixD", panPosY = 6.5,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_4361_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 5), to = ccp(5, 6)},
		}
	},
--第三步说明
[4362] = {
		appear = {
			{type = "scene", scene = "game", para = 436},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 436},
			{type = "noPopup"},
			{type = 'onceLevel'},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 4361 },}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 5, c = 6, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text43603",panType = "up", panAlign = "matrixD", panPosY = 4.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_4362_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {}
	},	
--第466关，蜂蜜说明
	[4660] = {
		appear = {
			{type = "scene", scene = "game", para = 466},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 466},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 6, countR = 1, countC = 1},
                         [2] = {r = 6, c = 6, countR = 1, countC = 2},
                         [3] = {r = 7, c = 5, countR = 1, countC = 2}
				}, 
				allow = {r = 6, c = 6, countR = 1, countC = 2}, 
				from = ccp(6, 6.3), to = ccp(6, 7.3), 
				text = "tutorial.game.text46600", panType = "up", panAlign = "matrixD", panPosY = 6.5, 
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_4660_1", -- 新引导对话框参考此处
				},
			},
		disappear = {
			{type = "swap", from = ccp(6, 6), to = ccp(6, 7)},
		},
	},
--消除第二次
    [4661] = {
		appear = {
			{type = "scene", scene = "game", para = 466},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 466},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 4660 },}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 4, countR = 1, countC = 1 }, 
					[2] = {r = 7, c = 3, countR = 1, countC = 3 },
					[3] = {r = 8, c = 4, countR = 1, countC = 1 }
				}, 
				allow = {r = 7, c = 3, countR = 1, countC = 2}, 
				from = ccp(7, 3.3), to = ccp(7, 4.3), 
				text = "tutorial.game.text46601",panType = "down", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_4661_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(7, 3), to = ccp(7, 4)},
		}
	},
--消除第三次
    [4662] = {
		appear = {
			{type = "scene", scene = "game", para = 466},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 466},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 4661 },}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 9, c = 5, countR = 4, countC = 1 },
					[2] = {r = 7, c = 6, countR = 1, countC = 1 }
				}, 
				allow = {r = 7, c = 5, countR = 1, countC = 2}, 
				from = ccp(7.3, 5), to = ccp(7.3, 6), 
				text = "tutorial.game.text46602",panType = "down", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_4662_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(7, 6)},
		}
	},
--第四步说明
    [4663] = {
		appear = {
			{type = "scene", scene = "game", para = 466},
			{type = "numMoves", para = 3},
			{type = "topLevel", para = 466},
			{type = "noPopup"},
            {type = "staticBoard"},
            {type = 'onceLevel'},
			{type = "curLevelGuided", guide = { 4662 },}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				    [1] = {r = 5, c = 3, countR = 1, countC = 3 },
				    [2] = {r = 6, c = 3, countR = 1, countC = 3 },
				    [3] = {r = 7, c = 3, countR = 1, countC = 3 },				    
				}, 
				text = "tutorial.game.text46603",panType = "up", panAlign = "matrixD", panPosY = 7,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_4663_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {}
	},	

	[4664] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 3},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 3},
			{type = "customCheck", func = function ( ... )
				return ModuleNoticeButton:shouldPlayHandClickGuide()
			end}
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	[4665] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 8},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 8},
			{type = "customCheck", func = function ( ... )
				return ModuleNoticeButton:shouldPlayHandClickGuide()
			end}
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	[4666] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 9},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 9},
			{type = "customCheck", func = function ( ... )
				return ModuleNoticeButton:shouldPlayHandClickGuide()
			end}
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	[4667] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 16},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 16},
			{type = "customCheck", func = function ( ... )
				return ModuleNoticeButton:shouldPlayHandClickGuide()
			end}
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},
	[4668] = {
		appear = {
			{type = "popup", popup = "startGamePanel", para = 31},
			{type = "scene", scene = "worldMap"},
			{type = "topLevel", para = 31},
			{type = "customCheck", func = function ( ... )
				return ModuleNoticeButton:shouldPlayHandClickGuide()
			end}
		},
		action = {
			[1] = {type = "startPanel"},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
			{type = "noPopup"},
			{type = "scene", scene = "game"},
		}
	},

--圣诞关卡引导
    [180000] = {
			appear = {
				{type = "scene", scene = "game", para = {180001,180002,180003,180004,180005}},
				{type = "noPopup"},
				{type = "numMoves", para = 0},
				{type = "onceOnly"},
				{type = "onceLevel"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {}, 
					text = "tutorial.game.text1800010",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
					panDelay = 5.2, maskDelay = 5.1 ,maskFade = 0.4,touchDelay = 1.7
				}
			},
			disappear = {
				
			},
		},
	[180001] = {
			appear = {
				{type = "scene", scene = "game", para = {180001,180002,180003,180004,180005}},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
				{type = 'halloweenBoss'},
				{type = "numMoves", para = 0},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1.7, countC = 9 }}, 
					text = "tutorial.game.text1800011",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},		
				[2] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 9, c = 3, countR = 2, countC = 3 }}, 
					text = "tutorial.game.text1800012",panType = "up", panAlign = "matrixD", panPosY = 2 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},
			},
			disappear = {
				{type = "swap", from = ccp(2, 7), to = ccp(2, 8)},
			},
		},
	[210000] = {
			appear = {
				{type = "scene", scene = "game", para = {230007, 230008, 230009, 230010, 230011, 230012}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstShowFirework', value = true}
			},
			action = {	
			    [1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230001", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = -58,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				}	
			},
			disappear = {
			},
		},
	[210001] = {
			appear = {
				{type = "scene", scene = "game", para = {230007, 230008, 230009, 230010, 230011, 230012}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstQuestionMark', value = true}
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					offsetY = 4.5,
					text = "tutorial.game.text230002",panType = "up", panAlign = "matrixD", panPosY = 4.5, panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},	
			},
			disappear = {
			},
		},
	[210002] = {
			appear = {
				{type = "scene", scene = "game", para = {230007, 230008, 230009, 230010, 230011, 230012}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstFullFirework', value = true}
			},
			action = {	
			    [1] = {type = "showCustomizeArea", opacity = 0xCC, 
					offsetX = -80, offsetY = -65, width = 150, height = 150, position = ccp(349, 131), --默认值
					text = "tutorial.game.text230003",panType = "up", panAlign = "matrixD", panPosY = 5 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				}
			},
			disappear = {
			},
		},
	[210003] = {
		appear = {
			{type = "scene", scene = "game", para ={230007, 230008, 230009, 230010, 230011, 230012}},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = 'waitSignal', name = 'showFullFireworkTip', value = true}
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230004", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = -58,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
			}
		},
		disappear = {
		},
	},
	[230100] = {
			appear = {
				{type = "scene", scene = "game", para = {230101,230102,230103,230104,230105,230106,230107,230108,230109,230110,230111,230112,230113,230114,230115,230116,230117,230118,230119,230120}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstShowFirework', value = true}
			},
			action = {
			    [1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230006", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				}	
			},
			disappear = {
			},
		},
	[230101] = {
			appear = {
				{type = "scene", scene = "game", para = {230101,230102,230103,230104,230105,230106,230107,230108,230109,230110,230111,230112,230113,230114,230115,230116,230117,230118,230119,230120}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstQuestionMark', value = true}
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					offsetY = 4.5,
					text = "tutorial.game.text230007",panType = "up", panAlign = "matrixD", panPosY = 4.5, panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},	
			},
			disappear = {
			},
		},
	[230102] = {
			appear = {
				{type = "scene", scene = "game", para = {230101,230102,230103,230104,230105,230106,230107,230108,230109,230110,230111,230112,230113,230114,230115,230116,230117,230118,230119,230120}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstFullFirework', value = true}
			},
			action = {	
			    [1] = {type = "showProp",
					opacity = 0xCC, index = 1, 
					text = "tutorial.game.text230008", 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
					maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				}
			},
			disappear = {
			},
		},
	[230103] = {
		appear = {
			{type = "scene", scene = "game", para ={230101,230102,230103,230104,230105,230106,230107,230108,230109,230110,230111,230112,230113,230114,230115,230116,230117,230118,230119,230120}},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = 'waitSignal', name = 'showFullFireworkTip', value = true}
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230009", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
			}
		},
		disappear = {
		},
	},
	[230104] = {
		appear = {
			{type = "scene", scene = "game", para ={230101,230102,230103,230104,230105,230106,230107,230108,230109,230110,230111,230112,230113,230114,230115,230116,230117,230118,230119,230120}},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = 'waitSignal', name = 'forceUseFullFirework', value = true}
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230010", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 3, propId = 9999,
			}
		},
		disappear = {
		},
	},

	--春季周赛引导
	[230200] = {
			appear = {
				{type = "scene", scene = "game", para = {230203,230204,230205,230206,230207,230208,230209,230210,230211,230212,230213,230214,230215,230216,230217,230218,230219,230220,230221,230222}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstShowFirework', value = true}
			},
			action = {
			    [1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230011", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				}	
			},
			disappear = {
			},
		},
	[230201] = {
			appear = {
				{type = "scene", scene = "game", para = {230203,230204,230205,230206,230207,230208,230209,230210,230211,230212,230213,230214,230215,230216,230217,230218,230219,230220,230221,230222}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstQuestionMark', value = true}
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					offsetY = 4.5,
					text = "tutorial.game.text230012",panType = "up", panAlign = "matrixD", panPosY = 4.5, panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},	
			},
			disappear = {
			},
		},
	[230202] = {
			appear = {
				{type = "scene", scene = "game", para = {230203,230204,230205,230206,230207,230208,230209,230210,230211,230212,230213,230214,230215,230216,230217,230218,230219,230220,230221,230222}},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstFullFirework', value = true}
			},
			action = {	
			    [1] = {type = "showProp",
					opacity = 0xCC, index = 1, 
					text = "tutorial.game.text230013", 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
					maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				}
			},
			disappear = {
			},
		},
	[230203] = {
		appear = {
			{type = "scene", scene = "game", para ={230203,230204,230205,230206,230207,230208,230209,230210,230211,230212,230213,230214,230215,230216,230217,230218,230219,230220,230221,230222}},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = 'waitSignal', name = 'showFullFireworkTip', value = true}
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230014", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
			}
		},
		disappear = {
		},
	},
	[230204] = {
		appear = {
			{type = "scene", scene = "game", para ={230203,230204,230205,230206,230207,230208,230209,230210,230211,230212,230213,230214,230215,230216,230217,230218,230219,230220,230221,230222}},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = 'waitSignal', name = 'forceUseFullFirework', value = true}
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230015", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 3, propId = 9999,
			}
		},
		disappear = {
		},
	},

	--端午节关卡引导
    [220000] = {
			appear = {
				{type = "scene", scene = "game", para = {220001,220002,220003,220004,220005}},
				{type = "noPopup"},
				{type = "numMoves", para = 0},
				{type = "onceOnly"},
				{type = "onceLevel"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {}, 
					text = "tutorial.game.text2000010",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
					panDelay = 5.2, maskDelay = 5.1 ,maskFade = 0.4,touchDelay = 1.7
				}
			},
			disappear = {
			},
		},
	[220001] = {
			appear = {
				{type = "scene", scene = "game", para = {220001,220002,220003,220004,220005}},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
				{type = 'halloweenBoss'},
				{type = "numMoves", para = 0},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 2, countC = 9 }}, 
					text = "tutorial.game.text2000011",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},		
				[2] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 9, c = 3, countR = 2, countC = 3 }}, 
					text = "tutorial.game.text2000012",panType = "up", panAlign = "matrixD", panPosY = 2 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},
			},
			disappear = {
				{type = "swap", from = ccp(2, 7), to = ccp(2, 8)},
			},
		},
	[220002] = {
			appear = {
				{type = "scene", scene = "game", para = {220001,220002,220003,220004,220005}},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
				{type = "goldZongzi"},
				{type = "numMoves", para = 0},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					text = "tutorial.game.text2000013",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},
			},
			disappear = {},
		},
	--两周年活动
    [250006] = {
			appear = {
				{type = "scene", scene = "game", para = {250101}},
				{type = "noPopup"},
				{type = "numMoves", para = 0},
				{type = "onceOnly"},
				{type = "onceLevel"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 9, c = 1, countR = 3, countC = 9 }}, 
					text = "tutorial.game.text2501011",panType = "down", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
					panDelay = 5.2, maskDelay = 5.1 ,maskFade = 0.4,touchDelay = 1.7
				}
			},
			disappear = {
			},
		},
	[250007] = {
			appear = {
				{type = "scene", scene = "game", para = {250101}},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
				{type = 'halloweenBoss'},
			},
			action = {	
			 --    [1] = {type = "showTile", opacity = 0xCC, 
				-- 	array = {[1] = {r = 2, c = 1, countR = 3, countC = 9 }}, 
				-- 	text = "tutorial.game.text2500015",panType = "up", panAlign = "matrixD", panPosY = 3.5 ,panFlip="true",
				-- 	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				-- },		
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {
					[1] = {r = 1, c = 1, countR = 2, countC = 3 },  -- magicTile
					-- [2] = {r = 2, c = 1, countR = 3, countC = 9 }, -- boss
					}, 
					text = "tutorial.game.text2501012",panType = "down", panAlign = "matrixD", panPosY = 2 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},
			},
			disappear = {
			},
		},
	[250008] = {
			appear = {
				{type = "scene", scene = "game", para = {250101}},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
				{type = "goldZongzi"},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					text = "tutorial.game.text2501013",panType = "down", panAlign = "matrixD", panPosY = 2 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},
			},
			disappear = {},
		},
	[250009] = {
			appear = {
				{type = "scene", scene = "game", para = {250101}},
				{type = "noPopup"},
				{type = "onceOnly"},
				{type = "onceLevel"},
				{type = "waitSignal", name = 'halloweenBossDie', value = true},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 9, c = 1, countR = 3, countC = 9 }}, 
					text = "tutorial.game.text2501014",panType = "down", panAlign = "matrixD", panPosY = 3 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},
			},
			disappear = {},
		},
--第496关，流沙说明
	[4960] = {
			appear = {
				{type = "scene", scene = "game", para = 496},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 496},
				{type = "noPopup"},
				--{type = "onceOnly"},
				{type = "onceLevel"}
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {{r = 6, c = 4, countR = 3, countC = 3}}, 
					text = "tutorial.game.text49600",panType = "down", panAlign = "matrixD", panPosY = 5.5 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_4960_1", -- 新引导对话框参考此处
				},			
			},
			disappear = {},
		},
--第526关，锁链说明
[5260] = {
		appear = {
			{type = "scene", scene = "game", para = 526},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 526},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 7, c = 1, countR = 1.5, countC = 2.5}}, 
				text = "tutorial.game.text52600",panType = "down", panAlign = "matrixD", panPosY = 3.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_5260_1", -- 新引导对话框参考此处
			},			
		    [2] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 5.5, c = 4.5, countR = 2, countC = 2}}, 
				text = "tutorial.game.text52601",panType = "up", panAlign = "matrixD", panPosY = 1.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_5260_2", -- 新引导对话框参考此处
			},		
		},
		disappear = {
		},
	},
--第556关，魔法石说明
    [5560] = {
		appear = {
			{type = "scene", scene = "game", para = 556},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 556},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 9, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text55600",panType = "down", panAlign = "matrixD", panPosY = 5.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_5560_1", -- 新引导对话框参考此处
			},			
		    --[2] = {type = "showTile", opacity = 0xCC, 
			--	array = {
			--	    [1] = {r = 7, c = 5, countR = 1, countC = 1 },
			--	    [2] = {r = 8, c = 4, countR = 1, countC = 3 },
			--	    [3] = {r = 9, c = 3, countR = 1, countC = 5 },				    
			--	}, 
			--	text = "tutorial.game.text55601",panType = "down", panAlign = "matrixD", panPosY = 2.5 ,
			--	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			--},
			--[3] = {type = "showObj", opacity = 0xCC, index = 2, 
			--	text = "tutorial.game.text55602",panType = "up", panAlign = "matrixD", panPosY = 1 ,
			--	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			--},		
		},
		disappear = {
		},
	},
--第200004-200007关，手机解锁关卡，松鼠和橡果的说明
	[2000000] = {
		appear = {
			{type = "scene", scene = "game", para = {200004,200005,200006,200007}},
			{type = "numMoves", para = 0},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showUFO", opacity = 0xCC, 
				position = ccp(9, 5), width = 1.65, height = 1.8, oval = true, deltaY = 15,
				text = "tutorial.game.text2000000",panType = "down", panAlign = "matrixD", panPosY = 3 ,panFlip="true",
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			},
			[2] = {type = "showObj", opacity = 0xCC, index = 1, 
				text = "tutorial.game.text2000001",panType = "up", panAlign = "matrixD", panPosY = 2 ,panFlip="true",
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			},
		},
		disappear = {
		},
	},
--第586关，移动地块说明
	[5860] = {
			appear = {
				{type = "scene", scene = "game", para = 586},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 586},
				{type = "noPopup"},
				--{type = "onceOnly"},
				{type = "onceLevel"}
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {{r = 3, c = 4, countR = 1, countC = 1}}, 
					text = "tutorial.game.text58600",panType = "up", panAlign = "matrixD", panPosY = 3 ,panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_5860_1", -- 新引导对话框参考此处
				},			
			},
			disappear = {},
		},

--第631关，萌豆说明
    [6310] = {
		appear = {
			{type = "scene", scene = "game", para = 631},
			{type = "numMoves", para = 0},
			{type = "topLevel", para =631},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 4, countR = 1, countC = 2},
                         [2] = {r = 2, c = 5, countR = 1, countC = 1},
                         [3] = {r = 3, c = 5, countR = 1, countC = 1}
				}, 
				allow = {r = 1, c = 4, countR = 1, countC = 2}, 
				from = ccp(1, 4.3), to = ccp(1, 5.3), 
				text = "tutorial.game.text63100", panType = "up", panAlign = "matrixD", panPosY = 2, 
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_6310_1", -- 新引导对话框参考此处
				},
			},
		disappear = {
			{type = "swap", from = ccp(1, 4), to = ccp(1, 5)},
		},
	},
--消除第二次
    [6311] = {
		appear = {
			{type = "scene", scene = "game", para =631},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 631},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 6310 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 2, c = 6, countR = 1, countC = 1}, 
					[2] = {r = 3, c = 5, countR = 1, countC = 3},
				}, 
				allow = {r = 3, c = 6, countR = 2, countC = 1}, 
				from = ccp(2.3, 6), to = ccp(3.3, 6), 
				text = "tutorial.game.text63101",panType = "up", panAlign = "matrixD", panPosY = 2.5,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_6311_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 6), to = ccp(3, 6)},
		}
	},
--消除第三次
    [6312] = {
		appear = {
			{type = "scene", scene = "game", para = 631},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 631},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "noNewPreProp"},
			{type = "curLevelGuided", guide = { 6311 },},

		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 2, c = 6, countR = 1, countC = 1 },
                    [2] = {r = 3, c = 5, countR = 1, countC = 3 }
				}, 
				allow = {r = 3, c = 6, countR = 2, countC = 1}, 
				from = ccp(2.3, 6), to = ccp(3.3, 6), 
				text = "tutorial.game.text63102",panType = "up", panAlign = "matrixD", panPosY = 2,
				handDelay = 0.9 , panDelay = 0.6,
				panelName = "guide_dialogue_6312_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(2, 6), to = ccp(3, 6)},
		}
	},	

--第30关，灰色毛球新手引导
[300] = {
		appear = {
			{type = "scene", scene = "game", para = 30},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 30},
			{type = "topPassedLevel",para = 29},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1]={r = 0, c = 0, countR = 0, countC = 0}},
				text = "tutorial.game.text3000",panType = "up", panAlign = "matrixD", panPosY = 2,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_300_1", -- 新引导对话框参考此处
			},			
		    [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 7, countR = 1, countC = 1},
                         [2] = {r = 2, c = 7, countR = 1, countC = 2},
                         [3] = {r = 3, c = 7, countR = 1, countC = 1},
                         [4] = {r = 3, c = 1, countR = 1, countC = 2},
				}, 
				allow = {r = 2, c = 7, countR = 1, countC = 2}, 
				from = ccp(2, 8), to = ccp(2, 7), 
				text = "tutorial.game.text3001", panType = "up", panAlign = "matrixD", panPosY = 3, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_300_2", -- 新引导对话框参考此处
		    },
		},
		disappear = {
			{type = "swap", from = ccp(2, 8), to = ccp(2, 7)},
		},
	},
-- 消除第一次，毛球蹦走，进入下一步说明
	[301] = {
		appear = {
			{type = "scene", scene = "game", para = 30},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 30},
			{type = "topPassedLevel",para = 29},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 300 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 3, countR = 1, countC = 2},
                         [2] = {r = 2, c = 3, countR = 1, countC = 1},
                         [3] = {r = 3, c = 2, countR = 1, countC = 2},
				}, 
				allow = {r = 1, c = 3, countR = 1, countC = 2}, 
				from = ccp(1.3, 4), to = ccp(1.3, 3), 
				text = "tutorial.game.text3002", panType = "up", panAlign = "matrixD", panPosY = 4,
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_301_1", -- 新引导对话框参考此处
		    },
		},
		disappear = {
			{type = "swap", from = ccp(1, 4), to = ccp(1, 3)},
		}
	},
--十一关卡引导
--消除第一次，引导点亮路径，刺猬前进
    [2600010] = {
			appear = {
			{type = "scene", scene = "game", para = 260001},
			{type = "numMoves", para = 0},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"}
		     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 2, countR = 1, countC = 1},
                         [2] = {r = 7, c = 3, countR = 4, countC = 1},
				}, 
				allow = {r = 6, c = 2, countR = 1, countC = 2}, 
				from = ccp(6, 2.3), to = ccp(6, 3.3), 
				text = "tutorial.game.text26000100", panType = "up", panAlign = "matrixD", panPosY = 8, 
				maskDelay = 6, maskFade = 0.4, touchDelay = 7.5, handDelay = 6.9, panDelay = 6.5, 
				},
			},
		disappear = {
			{type = "swap", from = ccp(6, 2), to = ccp(6, 3)},
		},
	},
	--第二步：引导收集苹果攒能量及消除触发滚屏规则
    [2600011] = {
		appear = {
			{type = "scene", scene = "game", para =260001},
			{type = "numMoves", para = 1},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = {2600010},},
		},
		action = {
			[1] = {type = "showObj", opacity = 0xCC, index = 1, 
				text = "tutorial.game.text26000101",panType = "up", panAlign = "matrixD", panPosY = 0,
				maskDelay = 0.8,maskFade = 0.4, panDelay = 1.1,touchDelay = 1.7
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 6, countR = 1, countC = 2 },
				         [2] = {r = 8, c = 1, countR = 1, countC = 9 },
                         [3] = {r = 9, c = 1, countR = 1, countC = 9 },
				}, 
				allow = {r = 8, c = 7, countR = 1, countC = 2}, 
				from = ccp(8, 7.3), to = ccp(8, 8.3), 
				text = "tutorial.game.text26000102",panType = "down", panAlign = "matrixD", panPosY = 3,
				handDelay = 0.9 , panDelay = 0.6,
			},
		},
		disappear = {
			{type = "swap", from = ccp(8, 7), to = ccp(8, 8)},
		},
	},	

     --第三步：引导点击刺猬放大招
    [2600012] = {
			appear = {
				{type = "scene", scene = "game", para = 260001},
				{type = "noPopup"},
			    {type = 'waitSignal', name = "hedgehogCrazy", value = true},
			    {type = "onceOnly"},
			    {type = "onceLevel"}
			},
			action = {
				[1] = {type = "clickTile", opacity = 0xCC,
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 1}}, 
				text = "tutorial.game.text26000103",panType = "down" , panAlign = "matrixD" , panPosY = 0,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
			},

			},
			disappear = {
				{type = "click", {value = true}},
			}
		},
		--15年圣诞关卡引导
--消除第一次，引导点亮路径，刺猬前进
    [2600140] = {
			appear = {
			{type = "scene", scene = "game", para = 260014},
			{type = "numMoves", para = 0},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"}
		     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, ignoreCharacter = true,
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},
                         [2] = {r = 4, c = 3, countR = 1, countC = 4},
				}, 
				allow = {r = 5, c = 5, countR = 2, countC = 1}, 
				from = ccp(5.1, 5), to = ccp(4.1, 5), 
				text = "tutorial.game.text26000100", panType = "up", panAlign = "matrixD", panPosY = 6, 
				maskDelay = 6, maskFade = 0.4, touchDelay = 7.5, handDelay = 6.9, panDelay = 6.5, 
				panImage = {
					[1] = { image = "christmas_dc_up.png", scale = ccp(1, 1) , x =556 , y = -121},
				},
				},
			},
		disappear = {
			{type = "swap", from = ccp(5, 5), to = ccp(4, 5)},
		},
	},
	--第二步：引导收集苹果攒能量及消除触发滚屏规则
    [2600141] = {
		appear = {
			{type = "scene", scene = "game", para =260014},
			{type = "numMoves", para = 1},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = {2600140},},
		},
		action = {
			[1] = {type = "showObj", opacity = 0xCC, index = 1, ignoreCharacter = true,
				text = "tutorial.game.text26000101",panType = "up", panAlign = "matrixD", panPosY = 0,
				maskDelay = 0.8,maskFade = 0.4, panDelay = 1.1,touchDelay = 1.7,
				panImage = {
					[1] = { image = "christmas_dc_up.png", scale = ccp(1, 1) , x =556 , y = -121},
				},
			},
			[2] = {type = "gameSwap", opacity = 0xCC, ignoreCharacter = true, 
				array = {[1] = {r = 5, c = 9, countR = 1, countC = 1 },
						 [2] = {r = 7, c = 8, countR = 4, countC = 1 },
				         [3] = {r = 8, c = 1, countR = 1, countC = 9 },
                         [4] = {r = 9, c = 1, countR = 1, countC = 9 },
				}, 
				allow = {r = 5, c = 8, countR = 1, countC = 2}, 
				from = ccp(5, 9), to = ccp(5, 8), 
				text = "tutorial.game.text26000102",panType = "down", panAlign = "matrixD", panPosY = 0,
				handDelay = 0.9 , panDelay = 0.6,
				panImage = {
					[1] = { image = "christmas_dc_down.png", scale = ccp(1, 1) , x =513 , y = -121},
				},
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 9), to = ccp(5, 8)},
		},
	},	

     --第三步：引导点击刺猬放大招
    [2600142] = {
			appear = {
				{type = "scene", scene = "game", para = 260014},
				{type = "noPopup"},
			    {type = 'waitSignal', name = "hedgehogCrazy", value = true},
			    {type = "onceOnly"},
			    {type = "onceLevel"}
			},
			action = {
				[1] = {type = "clickTile", opacity = 0xCC, ignoreCharacter = true,
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 1}}, 
				text = "tutorial.game.text26000103",panType = "down" , panAlign = "matrixD" , panPosY = 0,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
				panImage = {
					[1] = { image = "christmas_dc_down.png", scale = ccp(1, 1) , x =513 , y = -121},
				},
			},

		},
			disappear = {
				{type = "click", {value = true}},
			}
		},

	--2016春节新手引导消除桃子
    [2700010] = {
		appear = {
			{type = "scene", scene = "game", para = 270001},
			{type = "numMoves", para = 0},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"}
	     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 1, countC = 1},
                         [2] = {r = 7, c = 2, countR = 3, countC = 3},
				}, 
				allow = {r = 6, c = 3, countR = 2, countC = 1}, 
				from = ccp(5.1, 3), to = ccp(6.1, 3), 
				text = "tutorial.game.text27000100", panType = "up", panAlign = "matrixD", panPosY = 7.5, 
				maskDelay = 6, maskFade = 0.4, touchDelay = 6.5, handDelay = 7.9, panDelay = 6.5, 
				--panImage = {
					--[1] = { image = "christmas_dc_up.png", scale = ccp(1, 1) , x =556 , y = -121},
				--},
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 3), to = ccp(6, 3)},
		},
	},
	--2016春节新手引导消除桃子
	 [2700014] = {
		appear = {
			{type = "scene", scene = "game", para = 270001},
			{type = "numMoves", para = 1},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = {2700010},},
	     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 1, countC = 1},
                         [2] = {r = 7, c = 6, countR = 3, countC = 3},
				}, 
				allow = {r = 6, c = 7, countR = 2, countC = 1}, 
				from = ccp(5.1, 7), to = ccp(6.1, 7), 
				text = "tutorial.game.text27000103", panType = "up", panAlign = "matrixD", panPosY = 7.5, 
				maskDelay = 2, maskFade = 0.4, touchDelay = 3.5, handDelay = 3, panDelay = 2.5, 
				--panImage = {
					--[1] = { image = "christmas_dc_up.png", scale = ccp(1, 1) , x =556 , y = -121},
				--},
			},
		},
		disappear = {
			{type = "swap", from = ccp(5, 7), to = ccp(6, 7)},
		},
	},

	--2016春节点击猴子不能放大招
    [2700011] = {
		appear = {
			{type = "scene", scene = "game", para = {270001,270002,270003,270004,270005}},
			{type = "noPopup"},
		    {type = 'waitSignal', name = "wukongGuideJumpClick", value = true},
		    --{type = "onceOnly"},
		    --{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {}, --由wukongGuideJump处传入
				text = "tutorial.game.text27000102",panType = "down", panAlign = "matrixD", panPosY = 2.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			},
		},
		disappear = {
			--{type = "click", {value = true}},
		}
	},

	--2016春节点击猴子不能放大招
	[2700012] = {
		appear = {
			{type = "scene", scene = "game", para = {270001,270002,270003,270004,270005}},
			{type = "noPopup"},
		    {type = 'waitSignal', name = "wukongGuideJumpAuto", value = true},
		    --{type = "onceOnly"},
		    --{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {}, --由wukongGuideJump处传入
				text = "tutorial.game.text27000102",panType = "down", panAlign = "matrixD", panPosY = 2.5 ,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			},
		},
		disappear = {
			--{type = "click", {value = true}},
		}
	},

    --2016春节引导点击猴子放大招
    [2700013] = {
		appear = {
			{type = "scene", scene = "game", para = 270001},
			{type = "noPopup"},
		    {type = 'waitSignal', name = "wukongCrazy", value = true},
		    {type = "onceOnly"},
		    {type = "onceLevel"}
		},
		action = {
			[1] = {type = "clickTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 1}}, 
				text = "tutorial.game.text27000101",panType = "up" , panAlign = "matrixD" , panPosY = 4,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
				--panImage = {
					--[1] = { image = "christmas_dc_down.png", scale = ccp(1, 1) , x =513 , y = -121},
				--},
			},
		},
		disappear = {
			{type = "click", {value = true}},
		}
	},

	--2016春节2新手引导消除桃子
    [2700020] = {
		appear = {
			{type = "scene", scene = "game", para = 270002},
			{type = "numMoves", para = 0},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"}
	     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 1, countC = 1},
				         [2] = {r = 4, c = 3, countR = 1, countC = 3},
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3.1, 5), to = ccp(4.1, 5), 
				text = "tutorial.game.text27000200", panType = "up", panAlign = "matrixD", panPosY = 4.5, 
				maskDelay = 6, maskFade = 0.4, touchDelay = 6.5, handDelay = 7.9, panDelay = 6.5, 
				--panImage = {
					--[1] = { image = "christmas_dc_up.png", scale = ccp(1, 1) , x =556 , y = -121},
				--},
			},
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},

--第276关，含羞草2说明	
	[2760] = {
		appear = {
			{type = "scene", scene = "game", para = 276},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 276},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			--[1] = {type = "showTile", opacity = 0xCC, 
				--array = {{r = 9, c = 4, countR = 1, countC = 1},
				-- {r = 9, c = 6, countR = 1, countC = 1}}, 
				--text = "tutorial.game.text27600",panType = "down", panAlign = "matrixD", panPosY = 4 ,
				--panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			--},			
		    [1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 4, countR = 1, countC = 1},
					     [2] = {r = 2, c = 2, countR = 1, countC = 4},
					     [3] = {r = 9, c = 4, countR = 1, countC = 1},
					     [4] = {r = 9, c = 6, countR = 1, countC = 1},
				}, 
				allow = {r = 2, c = 4, countR = 2, countC = 1}, 
				from = ccp(1, 4), to = ccp(2, 4), 
				text = "tutorial.game.text27601", panType = "up", panAlign = "matrixD", panPosY = 4, panFlip="false",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2760_1", -- 新引导对话框参考此处
		    },
		},
		disappear = {
			{type = "swap", from = ccp(1, 4), to = ccp(2, 4)},
		},
	},
-- 消除第一次，绿叶球就要向外生长了，进入下一步说明
	[2761] = {
		appear = {
			{type = "scene", scene = "game", para = 276},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 276},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 2760 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				--array = {[1] = {r = 1, c = 6, countR = 1, countC = 3}},
				array = {[1] = {r = 2, c = 6, countR = 1, countC = 3},
					[2] = {r = 1, c = 7, countR = 1, countC = 1},
					[3] = {r = 9, c = 4, countR = 1, countC = 1},
					[4] = {r = 9, c = 6, countR = 1, countC = 1},
				}, 
				allow = {r = 2, c = 7, countR = 2, countC = 1}, 
				from = ccp(1, 7), to = ccp(2, 7), 
				text = "tutorial.game.text27602", panType = "up", panAlign = "matrixD", panPosY = 1.5, panFlip="true",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2761_1", -- 新引导对话框参考此处
		    },
		},
		disappear = {
			{type = "swap", from = ccp(1, 7), to = ccp(2, 7)},
		}
	},
-- 消除第二次，绿叶球向外生长两格，进入下一步说明
	[2762] = {
		appear = {
			{type = "scene", scene = "game", para = 276},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 276},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 2761 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 4, countR = 1, countC = 1},
					     [2] = {r = 3, c = 4, countR = 1, countC = 1},
					     [3] = {r = 9, c = 4, countR = 3, countC = 1},
				}, 
				allow = {r = 3, c = 4, countR = 2, countC = 1}, 
				from = ccp(2, 4), to = ccp(3, 4), 
				text = "tutorial.game.text27603", panType = "down", panAlign = "matrixD", panPosY = 0.3, panFlip="false",
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_2762_1", -- 新引导对话框参考此处
		    },
		},
		disappear = {
			{type = "swap", from = ccp(2, 4), to = ccp(3, 4)},
		}
	},	
-- 消除第三次，绿叶球再向外生长两格，进入下一步说明
    
	--[2763] = {
		--appear = {
			--{type = "scene", scene = "game", para = 276},
			--{type = "numMoves", para = 3},
			--{type = "topLevel", para = 276},
			--{type = "noPopup"},
			--{type = "onceOnly"},
			--{type = "onceLevel"},
			--{type = "staticBoard"},
			--{type = "curLevelGuided", guide = { 2762 },},
		--},
		--action = {
		--}
		--[1] = {type = "gameSwap", opacity = 0xCC, 
		--		array = {[1] = {r = 9, c = 6, countR = 1, countC = 1},
		--			 [2] = {r = 6, c = 5, countR = 1, countC = 3},
		--			 [3] = {r = 5, c = 5, countR = 1, countC = 1},
		--		}, 
		--		allow = {r = 6, c = 5, countR = 2, countC = 1}, 
		--		from = ccp(6.3, 5.3), to = ccp(5.3, 5.3), 
		--		text = "tutorial.game.text27604", panType = "down", panAlign = "matrixD", panPosY = 1.5, panFlip="true",
		--		handDelay = 1.2 , panDelay = 0.8 , 
		--		panelName = "guide_dialogue_2763_1", -- 新引导对话框参考此处
		--	},
		--},
		--disappear = {
			--{type = "swap", from = ccp(6, 5), to = ccp(5, 5)},
		--}
	--},
-- 最后一步说明
	[2763] = {
		appear = {
			{type = "scene", scene = "game", para = 276},
			{type = "numMoves", para = 3},
			{type = "topLevel", para = 276},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = { 2762 },},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
		        array = {
				   [1] = {r = 0, c = 0, countR = 0, countC = 0},
				}, 
				text = "tutorial.game.text27605",panType = "down", panAlign = "matrixD", panPosY = 8 ,panFlip="false",
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2712_2", -- 新引导对话框参考此处 介绍道具锤子，从271挪到这里的
			},
		},
		disappear ={
		}
	},
--第676关，染色宝宝新手引导
[6760] = {
		appear = {
			{type = "scene", scene = "game", para = 676},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 676},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 3, c = 5, countR = 2, countC = 1}}, 
				text = "tutorial.game.text67600",panType = "up", panAlign = "matrixD", panPosY = 3,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_6760_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 8, c = 5, countR = 1, countC = 1},
                         [2] = {r = 7, c = 4, countR = 1, countC = 3},
				}, 
				allow = {r = 8, c = 5, countR = 2, countC = 1}, 
				from = ccp(7.3, 5), to = ccp(8.3, 5), 
				text = "tutorial.game.text67601", panType = "down", panAlign = "matrixD", panPosY = 3,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_6760_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(8, 5)},
		},
	},
--蓄能过程
	[6761] = {
		appear = {
			{type = "scene", scene = "game", para = 676},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 676},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 6760 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 5, countR = 1, countC = 1},
                         [2] = {r = 8, c = 4, countR = 1, countC = 3},
				}, 
				allow = {r = 8, c = 5, countR = 2, countC = 1}, 
				from = ccp(7.3, 5), to = ccp(8.3, 5), 
				text = "tutorial.game.text67602", panType = "down", panAlign = "matrixD", panPosY = 4.5,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_6761_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(8, 5)},
		},
	},
	
--充满能量，引导交换染色宝宝
	[6762] = {
		appear = {
			{type = "scene", scene = "game", para = 676},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 676},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 6761 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 2, countC = 1},
				}, 
				allow = {r = 2, c = 5, countR = 2, countC = 1}, 
				from = ccp(2.3, 5), to = ccp(1.3, 5), 
				text = "tutorial.game.text67603", panType = "up", panAlign = "matrixD", panPosY = 1.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_6762_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(1, 5), to = ccp(2, 5)},
		}
	},
	--730关 引导特效让染色宝宝充能
	-- 730染色宝宝交换引导
	[7300] = {
		appear = {
			{type = "scene", scene = "game", para = 730},
			{type = "noPopup"},
			{type = "topLevel", para = 730},
			--{type = "onceOnly"},
			{type = "onceLevel"},
		    {type = 'waitSignal', name = "twoCrystalStones", value = true},
		},
		action = {	
		    [1] = {type = "gameSwap", opacity = 0xCC, 
				array = {}, 
				allow = {r = 1, c = 1, countR = 1, countC = 2}, 
				from = ccp(1, 1), to = ccp(1, 2), 
				text = "tutorial.game.text73000", panType = "up", panAlign = "matrixD", panPosY = 5, panFlip="true",
				handDelay = 1.2, panDelay = 0.8, 
				panelName = "guide_dialogue_7300_1", -- 新引导对话框参考此处
			},		
		},
		disappear = {
			{type = "swap", from = ccp(1, 1), to = ccp(1, 2)},
		},
	},
	[7301] = {
		appear = {
			{type = "scene", scene = "game", para = 730},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 730},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			--{type = "onceOnly"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 9, c = 2, countR = 3, countC = 2},
				}, 
				allow = {r = 7, c = 2, countR = 1, countC = 2}, 
				from = ccp(7, 3), to = ccp(7, 2), 
				text = "tutorial.game.text73001", panType = "down", panAlign = "matrixD", panPosY = 4,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_7301_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(7, 3), to = ccp(7, 2)},
		}
	},
--第736关，闪电鸟新手引导
[7360] = {
		appear = {
			{type = "scene", scene = "game", para = 736},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 736},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 2, countR = 1, countC = 1},
				         [2] = {r = 2, c = 8, countR = 1, countC = 1},
				         [3] = {r = 8, c = 2, countR = 1, countC = 1},
				         [4] = {r = 8, c = 8, countR = 1, countC = 1},}, 
				text = "tutorial.game.text73600",panType = "up", panAlign = "matrixD", panPosY = 2.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_7360_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 7, countR = 1, countC = 1},
                         [2] = {r = 2, c = 7, countR = 1, countC = 3},
				}, 
				allow = {r = 2, c = 7, countR = 2, countC = 1}, 
				from = ccp(1.3, 7), to = ccp(2.3, 7), 
				text = "tutorial.game.text73601", panType = "up", panAlign = "matrixD", panPosY = 3,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_7360_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(1, 7), to = ccp(2, 7)},
		},
	},
--第二步
	[7361] = {
		appear = {
			{type = "scene", scene = "game", para = 736},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 736},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 7360 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 2, c = 8, countR = 1, countC = 1},
					[2] = {r = 7, c = 1, countR = 1, countC = 1},
					[3] = {r = 8, c = 1, countR = 1, countC = 3},
				}, 
				allow = {r = 8, c = 1, countR = 2, countC = 1}, 
				from = ccp(7.3, 1), to = ccp(8.3, 1), 
				text = "tutorial.game.text73602", panType = "down", panAlign = "matrixD", panPosY = 4,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_7361_1", -- 新引导对话框参考此处
				highlightEffect = {type = 'superBird', pauseTime = 1.5},
		   },
		},
		disappear = {
			{type = "swap", from = ccp(7, 1), to = ccp(8, 1)},
		},
	},

	--荷塘新手引导
    [7960] = {
		appear = {
			{type = "scene", scene = "game", para = 796},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "topLevel", para = 796},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
	     },
		action = {
			[1] = {type = "showInfo", opacity = 0xCC, 
				--text = "tutorial.game.text304", 
				maskDelay = 0.8, maskFade = 0.2, panDelay = 0.8, panFade = 0.1,touchDelay = 1.4,			
				panImage = {
				[1] = {image = "guides.panImage_lotus.png",scale = ccp(1,1) , x = 310 , y = -360}
 				},
				panelName = "guide_dialogue_7960_0", -- 新引导对话框参考此处
			},
		  [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 5, countR = 1, countC = 1},
					[2] = {r = 4, c = 4, countR = 1, countC = 3},
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3.3, 5), to = ccp(4.3, 5), 
				text = "tutorial.game.text796", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_7960_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},
	--第841关，无敌毛球新手引导
[8410] = {
		appear = {
			{type = "scene", scene = "game", para = 841},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 841},
			{type = "noPopup"},
			-- {type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},}, 
				text = "tutorial.game.text84100",panType = "up", panAlign = "matrixD", panPosY = 4.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_8410_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 1},
                         [2] = {r = 3, c = 4, countR = 1, countC = 3},
				}, 
				allow = {r = 3, c = 5, countR = 2, countC = 1}, 
				from = ccp(3, 5), to = ccp(2, 5), 
				text = "tutorial.game.text84101", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_8410_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(2, 5)},
		},
	},




--六一关卡引导
--消除第一次，引导点亮路径，木马前进
    [2601010] = {
			appear = {
			{type = "scene", scene = "game", para = 260101},
			{type = "numMoves", para = 0},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "onceLevel"}
		     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 2, countR = 1, countC = 1},
                         [2] = {r = 7, c = 3, countR = 4, countC = 1},
				}, 
				allow = {r = 6, c = 2, countR = 1, countC = 2}, 
				from = ccp(6, 2.3), to = ccp(6, 3.3), 
				text = "tutorial.game.text26010100", panType = "up", panAlign = "matrixD", panPosY = 8, 
				maskDelay = 6, maskFade = 0.4, touchDelay = 7.5, handDelay = 6.9, panDelay = 6.5, 
				},
			},
		disappear = {
			{type = "swap", from = ccp(6, 2), to = ccp(6, 3)},
		},
	},
	--第二步：引导收集弹珠攒能量及消除触发滚屏规则
    [2601011] = {
		appear = {
			{type = "scene", scene = "game", para =260101},
			{type = "numMoves", para = 1},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "curLevelGuided", guide = {2601010},},
		},
		action = {
			[1] = {type = "showObj", opacity = 0xCC, index = 1, 
				text = "tutorial.game.text26010101",panType = "up", panAlign = "matrixD", panPosY = 0,
				maskDelay = 0.8,maskFade = 0.4, panDelay = 1.1,touchDelay = 1.7
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 6, countR = 1, countC = 1 },
				         [2] = {r = 8, c = 1, countR = 1, countC = 9 },
                         [3] = {r = 9, c = 1, countR = 1, countC = 9 },
				}, 
				allow = {r = 9, c = 2, countR = 2, countC = 1}, 
				from = ccp(8.3, 2), to = ccp(9.3, 2), 
				text = "tutorial.game.text26010102",panType = "down", panAlign = "matrixD", panPosY = 3,
				handDelay = 0.9 , panDelay = 0.6,
			},
		},
		disappear = {
			{type = "swap", from = ccp(8, 2), to = ccp(9, 2)},
		},
	},	

     --第三步：引导点击木马放大招
    [2601012] = {
			appear = {
				{type = "scene", scene = "game", para = 260101},
				{type = "noPopup"},
			    {type = 'waitSignal', name = "hedgehogCrazy", value = true},
			    {type = "onceOnly"},
			    {type = "onceLevel"},
			},
			action = {
				[1] = {type = "clickTile", opacity = 0xCC,
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 1}}, 
				text = "tutorial.game.text26010103",panType = "down" , panAlign = "matrixD" , panPosY = 0,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
			},

			},
			disappear = {
				{type = "click", {value = true}},
			}
		},
--夏季周赛引导（带水滴宝宝版）
	[2303411] = {
			appear = {
				{type = "scene", scene = "game", para = 230341},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstShowFirework', value = true},
			},
			action = {
			    [1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230011", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				panImage = {
						[1] = {image = "guides_cloud2.png", scale=ccp(0.7, 0.7) , x = 395 , y = -70 ,},
						[2] = {image = "guide_summer_normal.png", scale=ccp(0.65, 0.65) , x = 545 , y = -70 ,},
						[3] = {image = "guide_summer_full.png", scale=ccp(0.65, 0.65) , x = 350 , y = -180 ,},
					},
				},
				[2] = {
					type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 4, c = 4, countR = 1, countC = 3},
	                    [2] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 5, c = 5, countR = 2, countC = 1}, 
					from = ccp(4.3, 5), to = ccp(5.3, 5), 
					text = "tutorial.game.text230016", panType = "up", panAlign = "matrixD", panPosY = 6, 
					maskDelay = 0, maskFade = 0.4, touchDelay = 1.5, handDelay = 0.9, panDelay = 0.5, 
					panImage = {
						[1] = {image = "guides_cloud2.png", scale=ccp(0.7, 0.7) , x = 320 , y = -170 ,},
						[2] = {image = "guides_starfish1.png", scale=ccp(0.6, 0.6) , x = 60 , y = -115 ,},
					},
				},
			},
			disappear = {
			{type = "swap", from = ccp(4, 5), to = ccp(5, 5)},
			},
		},
	[2303412] = {
			appear = {
				{type = "scene", scene = "game", para = 230341},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstQuestionMark', value = true},
				{type = "curLevelGuided", guide = { 2303411 },},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					offsetY = 4.5,
					text = "tutorial.game.text230012",panType = "up", panAlign = "matrixD", panPosY = 4.5, panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},	
			},
			disappear = {
			},
		},
	[2303413] = {
			appear = {
				{type = "scene", scene = "game", para = 230341},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = 'waitSignal', name = 'firstFullFirework', value = true},
				{type = "curLevelGuided", guide = { 2303411 },},
			},
			action = {	
			    [1] = {type = "showProp",
					opacity = 0xCC, index = 1, 
					text = "tutorial.game.text230013", 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
					maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
				}
			},
			disappear = {
			},
		},
	[2303414] = {
		appear = {
			{type = "scene", scene = "game", para = 230341},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = 'waitSignal', name = 'showFullFireworkTip', value = true},
			{type = "curLevelGuided", guide = { 2303411 },},
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230014", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
			}
		},
		disappear = {
		},
	},
	[2303415] = {
		appear = {
			{type = "scene", scene = "game", para = 230341},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = 'waitSignal', name = 'forceUseFullFirework', value = true},
			{type = "curLevelGuided", guide = { 2303411 },},
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				text = "tutorial.game.text230015", 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 3, propId = 9999,
			}
		},
		disappear = {
		},
	},
-- 2016冬季周赛引导
	[2303510] = {
			appear = {
				{type = "scene", scene = "game", para = GuideLevel.kSeasonWeekly},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstShowFirework', value = true},
			},
			action = {
			    [1] = {type = "showProp",
					opacity = 0xCC, index = 1, 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
					maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
					panelName = "guide_dialogue_weekly_item",
				},
				[2] = {type = "showProp",
					opacity = 0xCC, 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 600, panFlip = "true", offsetX = 0,
					maskDelay = 0,maskFade = 0.4 ,panDelay = 0, touchDelay = 1, propId = 9999,
					panelName = "guide_dialogue_weekly_item2",
				},
				[3] = {
					type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 4, c = 4, countR = 1, countC = 3},
	                    [2] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 5, c = 5, countR = 2, countC = 1}, 
					from = ccp(4.3, 5), to = ccp(5.3, 5), 
					panType = "up", panAlign = "matrixD", panPosY = 3, 
					maskDelay = 0, maskFade = 0.4, touchDelay = 1.5, handDelay = 0.9, panDelay = 0.5, 
					panelName = "guide_dialogue_weekly_drip",
				},
			},
			disappear = {
				{type = "swap", from = ccp(4, 5), to = ccp(5, 5)},
			},
		},
	[2303512] = {
			appear = {
				{type = "scene", scene = "game", para = GuideLevel.kSeasonWeekly},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstQuestionMark', value = true},
				{type = "curLevelGuided", guide = { 2303510 },},
			},
			action = {	
			    [1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 1, countR = 1, countC = 1 }}, 
					offsetY = 4.5,
					panelName = "guide_dialogue_weekly_question_box",
					panType = "up", panAlign = "matrixD", panPosY = 0, panFlip="true",
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
				},	
			},
			disappear = {
			},
		},
	[2303513] = {
			appear = {
				{type = "scene", scene = "game", para = GuideLevel.kSeasonWeekly},
				{type = "onceOnly"},
				{type = "noPopup"},
				-- {type = "staticBoard"},
				{type = 'waitSignal', name = 'firstFullFirework', value = true},
				{type = "curLevelGuided", guide = { 2303510 },},
			},
			action = {	
			    [1] = {type = "showProp",
					opacity = 0xCC, index = 1, 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 400+_G.__EDGE_INSETS.bottom, panFlip = "true", offsetX = 0,
					maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
					panelName = "guide_dialogue_weekly_energy_full",
				}
			},
			disappear = {
			},
		},
	[2303515] = {
		appear = {
			{type = "scene", scene = "game", para = GuideLevel.kSeasonWeekly},
			{type = "onceLevel"},
			{type = "noPopup"},
			-- {type = "staticBoard"},
			{type = 'waitSignal', name = 'forceUseFullFirework', value = true},
			{type = "curLevelGuided", guide = { 2303510 },},
		},
		action = {	
			[1] = {type = "showProp",
				opacity = 0xCC, index = 1, 
				multRadius=1.1 ,
				panType = "down", panAlign = "winY", panPosY = 600+_G.__EDGE_INSETS.bottom, panFlip = "true", offsetX = 0,
				maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 3, propId = 9999,
				panelName = "guide_dialogue_weekly_auto_use",
			}
		},
		disappear = {
		},
	},
	[2303516] = {
		appear = {
			{type = "scene", scene = "game", para = GuideLevel.kSeasonWeekly},
			{type = "onceOnly"},
			{type = "noPopup"},
			{type = 'waitSignal', name = 'firstChestSquare', value = true},
			{type = "curLevelGuided", guide = { 2303510 },},
		},
		action = {	
		    [1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 1, countR = 2, countC = 2 }}, 
				offsetY = 4.5,
				panelName = "guide_dialogue_weekly_box",
				panType = "down", panAlign = "matrixD", panFlip="true",
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7
			},	
		},
		disappear = {
		},
	},
	[2303517] = {
			appear = {
				{type = "scene", scene = "game"},
				{type = "onceOnly"},
				{type = "noPopup"},
				{type = 'waitSignal', name = 'firstBuyFirework', value = true},
				-- {type = "curLevelGuided", guide = { 2303510 },},
			},
			action = {
			    [1] = {type = "showProp",
					opacity = 0xCC, index = 1, 
					multRadius=1.1 ,
					panType = "down", panAlign = "winY", panPosY = 350+_G.__EDGE_INSETS.bottom, panFlip = "true", offsetX = 0,
					maskDelay = 1,maskFade = 0.4 ,panDelay = 1, touchDelay = 1, propId = 9999,
					panelName = "guide_dialogue_weekly_buy",
				},
			},
			disappear = {
			},
		},






--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
----------------------------------       触发式引导        ---------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------







	-- BuffBoom
	[500030001] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "onceOnly"},
			{type = "hasItemOnBoard" , para = GameItemType.kBuffBoom},
			{type = "checkGuideFlag", para = kGuideFlags.BuffBoom},

		},
		action = {

			-- [1] = {type = "showTile", opacity = 0xCC, 
		 --        array = {
			-- 	}, 
			-- 	itemTypeId = GameItemType.kBuffBoom ,
			-- 	autoHide = 1 ,
			-- 	noPanel = true ,
			-- 	--text = "tutorial.game.text27605",panType = "down", panAlign = "matrixD", panPosY = 8 ,panFlip="false",
			-- 	--panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
			-- 	--panelName = "guide_dialogue_2712_2", -- 新引导对话框参考此处 介绍道具锤子，从271挪到这里的
			-- },

			[1] = {type = "showInfo", opacity = 0xCC, index = 2, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_buffBoom_1"
			},
		},
		disappear = {}
	},

	-- Firecracker
	[500030002] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "onceOnly"},
			{type = "hasItemOnBoard" , para = GameItemType.kFirecracker},
			{type = "checkGuideFlag", para = kGuideFlags.inGame_FireCracker},

		},
		action = {
			-- tutorial.game.text1901 是小木槌的文案，貌似没有被使用，大家都用它占位，这里也如此吧……
			[1] = {type = "showInfo", opacity = 0xCC, index = 2, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_firecracker_1"
			},
		},
		disappear = {}
	},

	-- 自动使用精力瓶 500000101
	[500000102] = {
		appear = {
			{type = "popup", popup = "startGamePanel"},
			-- {type = "scene", scene = "worldMap"},
			{type = "energyConut" , para = {op = 1, conut = 4}},
			{type = "hasAvailableEneryBottleToStartLevel"},
			{type = "checkMaintenanceEnabledInGroup" , para = { mname = "useEnergyOptimization_new" , key = "autoUseEnergyToStartLevel2"} },
			--{type = "topLevel", para = 13},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showStartLevelButton", 
				opacity = 0xCC, 
				helpIcon=false, 
				preItemIndexs={1},	--虽然用的是preItemIndexs字段，但其实是开始按钮相关索引，所以说不要自己图省事给大家造成误解啊 ="=
				panelName = "guide_dialogue_auto_use_enery_1", -- 新引导对话框参考此处
				fixPosX = 50, fixPosY = -130,
			},
		},
		disappear = {
			{type = "popdown", popdown = "startGamePanel"},
		},
	},

-------------------------------------------前置道具-----------------------------------------------------
	--[[
	[500010001] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			--{type = "minCoin", para = 36000},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "hasPropNum", para = { 
												groupType = 2 , group = {
																			[1] = {propId = 10071 , num = 1 , op = 2} ,
																			[2] = {propId = 10018 , num = 1 , op = 2} ,
																			[1] = {propId = 10069 , num = 1 , op = 2} ,
																			[2] = {propId = 10007 , num = 1 , op = 2} ,
																		} 
											}
			},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = { {propId = 10007} , {propId = 10018} }, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = { "guide_dialogue_trigger_3" , "guide_dialogue_trigger_2"}
			},
		},
		disappear = {}
	},
	]]

	[510000001] = {
		appear = {
			{type = "scene", scene = "worldMap"},
			{type = "onceOnly"},
			{type = "popup", popup = "startGamePanel", para = 200, op = '>='},
			{type="prePropImproveLogic1", func = "isNewItemLogic", expect=true},
		},
		action = {
			[1] = {
				type = "showNewPreProp", opacity = 0xCC,
				maskDelay = 0.1,maskFade = 0.1 ,panDelay = 0.1 , touchDelay = 0.1, panFade = 0.1,
				panelName = "guide_dialogue_goods_1",
				preItemIndexs = {},
			},
			[2] = {
				type = "showNewPreProp", opacity = 0xCC,
				maskDelay = 0.1,maskFade = 0.1 ,panDelay = 0.1 , touchDelay = 0.1, panFade = 0.1,
				panelName = 'guide_dialogue_goods_2',
				preItemIndexs = {2},
			},
			[3] = {
				type = "showNewPreProp", opacity = 0xCC,
				maskDelay = 0.1,maskFade = 0.1 ,panDelay = 0.1 , touchDelay = 0.1, panFade = 0.1,
				panelName = 'guide_dialogue_goods_3',
				preItemIndexs = {3},
			},
		},
		disappear = {{type = "popdown", popdown = "startGamePanel"},},
	},
	-- +3
	[510000002] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "hasPropNum", para = { 
												groupType = 2 , group = {
																			[1] = {propId = 10071 , num = 1 , op = 2} ,
																			[2] = {propId = 10018 , num = 1 , op = 2} ,
																		} 
											}
			},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=false},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = {{propId = 10018}}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = {"guide_dialogue_trigger_2"}
			},
		},
		disappear = {}
	},

	-- 爆炸直线
	[510000003] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			--{type = "minCoin", para = 36000},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "hasPropNum", para = { 
												groupType = 2 , group = {
																			[1] = {propId = 10069 , num = 1 , op = 2} ,
																			[2] = {propId = 10007 , num = 1 , op = 2} ,
																		} 
											}
			},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=false},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = { {propId = 10007} }, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = { "guide_dialogue_trigger_3" }
			},
		},
		disappear = {}
	},

	

	[510000004] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "minCoin", para = 36000},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=false},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = { {propId = 10007} , {propId = 10018} }, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = { "guide_dialogue_trigger_3" , "guide_dialogue_trigger_2"}
			},
		},
		disappear = {}
	},

	-- +3
	[510000005] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "minCoin", para = 10000},
			{type = "maxCoin", para = 35999},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=false},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = {{propId = 10018}}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = {"guide_dialogue_trigger_2"}
			},
		},
		disappear = {}
	},

	------------------------ 本道具已被取消
	-- -- 前置刷新
	-- [510000006] = {
	-- 	appear = {
	-- 		{type = "scene", scene = "game"},
	-- 		{type = "firstGuideOnLevel"},
	-- 		{type = "notGameLevelType" , para = notGameLevelType},
	-- 		{type = "numMoves", para = 0},
	-- 		{type = "minCurrLevel", para = 21},
	-- 		{type = "continuousFailed", para = 3},
	-- 		{type = "usePrePropNum", para = 0},
	-- 		{type = "hasPropNum", para = { 
	-- 											groupType = 2 , group = {
	-- 																		[1] = {propId = 10070 , num = 1 , op = 2} ,
	-- 																		[2] = {propId = 10015 , num = 1 , op = 2} ,
	-- 																	} 
	-- 										}
	-- 		},
	-- 		{type = "notTimeLevel", para = 1},
	-- 		{type = "staticBoard"},
	-- 		{type = "noPopup"},
	-- 		{type = "onceLevel"},
	-- 		{type = "hasNoOtherGuide"},
	-- 		{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
	-- 		{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=false},
	-- 	},
	-- 	action = {

	-- 		[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
	-- 			array = {{propId = 10015}}, 
	-- 			text = "tutorial.game.text1901", multRadius = 1.3,
	-- 			panType = "down", panAlign = "viewY", panPosY = 650, 
	-- 			maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
	-- 			panelNameRandomList = {"guide_dialogue_trigger_1"}
	-- 		},
	-- 	},
	-- 	disappear = {}
	-- },

	-- -- 前置刷新
	-- [510000007] = {
	-- 	appear = {
	-- 		{type = "scene", scene = "game"},
	-- 		{type = "firstGuideOnLevel"},
	-- 		{type = "notGameLevelType" , para = notGameLevelType},
	-- 		{type = "numMoves", para = 0},
	-- 		{type = "minCurrLevel", para = 21},
	-- 		{type = "minCoin", para = 7800},
	-- 		{type = "maxCoin", para = 9999},
	-- 		{type = "continuousFailed", para = 3},
	-- 		{type = "usePrePropNum", para = 0},
	-- 		{type = "notTimeLevel", para = 1},
	-- 		{type = "staticBoard"},
	-- 		{type = "noPopup"},
	-- 		{type = "onceLevel"},
	-- 		{type = "hasNoOtherGuide"},
	-- 		{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
	-- 		{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=false},
	-- 	},
	-- 	action = {

	-- 		[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
	-- 			array = {{propId = 10015}}, 
	-- 			text = "tutorial.game.text1901", multRadius = 1.3,
	-- 			panType = "down", panAlign = "viewY", panPosY = 650, 
	-- 			maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
	-- 			panelNameRandomList = {"guide_dialogue_trigger_1"}
	-- 		},
	-- 	},
	-- 	disappear = {}
	-- },


	--------------------------- 新版本的老引导 ------------------------------------

	-- +3步
	[520000001] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "hasPropNum", para = { 
												groupType = 2 , group = {
																			[1] = {propId = 10071 , num = 1 , op = 2} ,
																			[2] = {propId = 10018 , num = 1 , op = 2} ,
																		} 
											}
			},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=true},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = {{propId = 10018}}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = {"guide_dialogue_trigger_2"}
			},
		},
		disappear = {}
	},

	-- 爆炸
	[520000002] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "hasPropNum", para = { 
												groupType = 2 , group = {
																			[1] = {propId = 10083 , num = 1 , op = 2} ,
																			[2] = {propId = 10081 , num = 1 , op = 2} ,
																		} 
											}
			},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=true},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = { {propId = 10081} }, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = { "guide_dialogue_trigger_old_wrap" }
			},
		},
		disappear = {}
	},

	
	-- 直线
	[520000003] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "hasPropNum", para = { 
												groupType = 2 , group = {
																			[1] = {propId = 10082 , num = 1 , op = 2} ,
																			[2] = {propId = 10084, num = 1 , op = 2} ,
																		} 
											}
			},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=true},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = {{propId = 10082}}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = {"guide_dialogue_trigger_old_line"}
			},
		},
		disappear = {}
	},

	[520000004] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "minCoin", para = 18000},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=true},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = { {propId = 10081} , {propId = 10082} }, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = { "guide_dialogue_trigger_old_wrap" , "guide_dialogue_trigger_old_line"}
			},
		},
		disappear = {}
	},

	[520000005] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "firstGuideOnLevel"},
			{type = "notGameLevelType" , para = notGameLevelType},
			{type = "numMoves", para = 0},
			{type = "minCurrLevel", para = 21},
			{type = "minCoin", para = 10000},
			{type = "maxCoin", para = 18000},
			{type = "continuousFailed", para = 3},
			{type = "usePrePropNum", para = 0},
			{type = "notTimeLevel", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
			{type = "prePropImproveLogic1", func = "isNewGuideLogic", expect=false},
			{type = "prePropImproveLogic2", func = "isNewItemLogic", expect=true},
		},
		action = {

			[1] = {type = "buyPreProp", opacity = 0xCC, index = 2, 
				array = {{propId = 10018}}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "viewY", panPosY = 650, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelNameRandomList = {"guide_dialogue_trigger_2"}
			},
		},
		disappear = {}
	},

	-----------------end of 新版本的老引导----------------------------------------------------------



	[500010109] = {--道具云块2
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			-- {type = "onceOnly"},
			-- {type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea ,GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "gameModeType", para = {GameModeTypeId.MAYDAY_ENDLESS_ID}},
			{type = "minNumMoves", para = 1},
			{type = "scrollRowCloud", para = {1, 4}},
			-- {type = "hsaNoOtherGuide"},
			-- {type = "notSpringItemGuide"},
		},
		action = {
			[1] = {type = "guideWeeklyCloud", 
				rowDelta = nil,
				itemId = nil,
				panelName = "guide_dialogue_trigger_weekly_cloud"
			},
		},
		disappear = {}
	},
	--]]

-------------------------------------------限时道具-----------------------------------------------------
	[500010300] = {
		appear = {

			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnToday"},
			{type = "onceLevel"},
			{type = "minNumMoves", para = 1},
			{type = "firstGuideOnLevel"},
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "hasExpiringTimeProp" , para = 0 },
			{type = "hasNoOtherGuide"},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {gudieAnyTimeProp = true}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				panHorizonAlign = "winX" , panPosX = -130,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_5"
			},
		},
		disappear = {}
	},
------------------------------------------------------------------------------------------------

	-- 使用小木槌引导
	[500010401] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "usePropId", para = { 10010,10026 } },
		},
		action = {
			[1] = { type="usePropTip",opacity=255 * 0.7,panelName="guide_dialogue_500010401_1" }
		},
		disappear = {
			{type = "notUsePropId", para = { 10010,10026 } }
		}
	},

	-- 使用魔法棒引导
	[500010402] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "usePropId", para = { 10005,10027 } },
		},
		action = {
			[1] = { type="usePropTip",opacity=255 * 0.7,panelName="guide_dialogue_500010402_1" }
		},
		disappear = {
			{type = "notUsePropId", para = { 10005,10027 } }
		}
	},

	--使用强制交换把引导
	[500010403] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "usePropId", para = { 10003,10028 } },
		},
		action = {
			[1] = { type="usePropTip",opacity=255 * 0.7,panelName="guide_dialogue_500010403_1" }
		},
		disappear = {
			{type = "notUsePropId", para = { 10003,10028 } }
		}
	},

	--使用魔力扫把引导
	[500010404] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "usePropId", para = { 10056 } },
		},
		action = {
			[1] = { type="usePropTip",opacity=255 * 0.7,panelName="guide_dialogue_500010404_1" }
		},
		disappear = {
			{type = "notUsePropId", para = { 10056 } }
		}
	},
	
	--使用横特效
	[500010405] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "usePropId", para = { 10105,10108 } },
		},
		action = {
			[1] = { type="usePropTip",opacity=255 * 0.7,panelName="guide_dialogue_500010405_1" }
		},
		disappear = {
			{type = "notUsePropId", para = { 10105,10108 } }
		}
	},
	
	--使用竖特效
	[500010406] = {
		appear = {
			{type = "scene", scene = "game" },
			{type = "notTimeLevel", para = 1},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "usePropId", para = { 10109,10112 } },
		},
		action = {
			[1] = { type="usePropTip",opacity=255 * 0.7,panelName="guide_dialogue_500010406_1" }
		},
		disappear = {
			{type = "notUsePropId", para = { 10109,10112 } }
		}
	},

--2016奥运关卡引导
-- 第一步 :引导小故事&引导消除冰
   [2800000] = {
			appear = {
			{type = "scene", scene = "game", para = 280000},
			{type = "noPopup"},
			{type = "numMoves", para = 0},
			{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "staticBoard"},
		     },
		action = {

			[1] = {type = "showTile", opacity = 0xCC, index = 1,
				array = {[1] = {r = 1, c = -1, countR = 3, countC = 13 },},
				text = "tutorial.game.text28000000", panType = "up", panAlign = "matrixD", panPosY = 0, 
				maskDelay = 0.4, maskFade = 0.4, panDelay = 0.5, 
				panelName = "guide_dialogue_2800000_1", -- 新引导对话框参考此处
				},
			[2] = {type = "popImage", opacity = 0xCC, posAdd = ccp(-100,-90),
				width = 180, height = 160, 
				panType = "up" ,panAlign = "winY" , panPosY = 900, panFlip ="true",
				maskDelay = 0 ,maskfade = 0.3, panDelay = 0.2, touchDelay = 0.5,
				panelName = "guide_dialogue_2800000_2", -- 新引导对话框参考此处
				pics = {
					[1] = {align = 'board', groupName = 'pic_2800000_1', scale = 1, x = 4.7, y = 1,},
					[2] = {align = 'board', groupName = 'pic_2800000_3', scale = 1, x = 4.4, y = 0.3,},
					[3] = {align = 'board', groupName = 'pic_2800000_4', scale = 1, x = 4.5, y = 2.5,},
				},
			},
			[3] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 4, countR = 1, countC = 3 },
                         [2] = {r = 2, c = 5, countR = 1, countC = 1 },
				}, 
				allow = {r = 3, c = 5, countR = 2, countC = 1}, 
				from = ccp(2.3, 5), to = ccp(3.3, 5), 
				text = "tutorial.game.text28000001",panType = "down", panAlign = "matrixD", panPosY = 2,
				handDelay = 1.4 , panDelay = 0.6, touchDelay = 1.4, maskDelay = 0.4, maskFade = 0.4,
				panelName = "guide_dialogue_2800000_3", -- 新引导对话框参考此处
			},
		},
		disappear = {
		        {type = "swap", from = ccp(2, 5), to = ccp(3, 5)},
		},
	},

     --第二步：引导破碎雪块
    [2800001] = {
			appear = {
				{type = "scene", scene = "game", para = 280000},
				{type = "numMoves", para = 1},
				{type = "noPopup"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2800000},},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
				array = {[1] = {r = 5, c = 4, countR = 1, countC = 1 },
				         [2] = {r = 7, c = 5, countR = 4, countC = 1 },
				         [3] = {r = 5, c = 6, countR = 1, countC = 1 },
				         }, 
				allow = {r = 5, c = 4, countR = 1, countC = 2}, 
				from = ccp(5, 4.3), to = ccp(5, 5.3), 
				text = "tutorial.game.text28000002",panType = "down" , panAlign = "matrixD" , panPosY = 0,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4, handDelay = 1.4,
				panelName = "guide_dialogue_2800001_1", -- 新引导对话框参考此处
			},

			},
			disappear = {
				{type = "swap", from = ccp(5, 4), to = ccp(5, 5)},
			}
		},
		--第三步：引导触发香蕉
    [2800002] = {
			appear = {
				{type = "scene", scene = "game", para = 280000},
				{type = "numMoves", para = 2},
				{type = "noPopup"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2800001},},
			},
			action = {
				[1] = {type = "popImage", opacity = 0xCC, posAdd = ccp(-100,-90),
				width = 180, height = 160, 
				panType = "up" ,panAlign = "winY" , panPosY = 1100, panFlip ="true",
				maskDelay = 1 ,maskfade = 0.3, panDelay = 1.2, touchDelay = 1.7,
				panelName = "guide_dialogue_2800002_1", -- 新引导对话框参考此处
				pics = {
					[1] = {align = 'board', groupName = 'pic_2800000_2', scale = 2, x = 0.3, y = 0.7,},
				},
			},
				[2] = {type = "gameSwap", opacity = 0xCC,
					array = {[1] = {r = 6, c = 9, countR = 4, countC = 1 },
					         [2] = {r = 5, c = 8, countR = 1, countC = 1 },
					},
					allow = {r = 5, c = 8, countR = 1, countC = 2}, 
					from = ccp(5, 8.3), to = ccp(5, 9.3), 
					text = "tutorial.game.text28000003",panType = "down" , panAlign = "matrixD" , panPosY = 2,
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4, handDelay = 1.4,
					panelName = "guide_dialogue_2800002_2", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(5, 8), to = ccp(5, 9)},
			}
		},
--第871关，气鼓鱼新手引导
[8710] = {
		appear = {
			{type = "scene", scene = "game", para = 871},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 871},
			{type = "noPopup"},
			{type = "staticBoard"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},}, 
				text = "tutorial.game.text87100",panType = "up", panAlign = "matrixD", panPosY = 3.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_8710_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},
                         [2] = {r = 3, c = 5, countR = 1, countC = 1},
                         [3] = {r = 5, c = 6, countR = 3, countC = 1},
				}, 
				allow = {r = 3, c = 5, countR = 1, countC = 2}, 
				from = ccp(3, 5.3), to = ccp(3, 6.3), 
				text = "tutorial.game.text87101", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_8710_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(3, 6)},
		},
	},
--第二步
[8711] = {
		appear = {
			{type = "scene", scene = "game", para = 871},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 871},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 8710 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 4, c = 2, countR = 1, countC = 4},
					[2] = {r = 5, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 4, c = 2, countR = 1, countC = 2}, 
				from = ccp(4, 2.3), to = ccp(4, 3.3), 
				text = "tutorial.game.text87102", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_8711_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(4, 2), to = ccp(4, 3)},
		},
	},
--第916关，双面翻版新手引导
[9160] = {
		appear = {
			{type = "scene", scene = "game", para = 916},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 916},
			{type = "noPopup"},
			{type = "staticBoard"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 3, countR = 1, countC = 1},
                        [2] = {r = 3, c = 5, countR = 1, countC = 1},
                        [3] = {r = 3, c = 7, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text91600",panType = "up", panAlign = "matrixD", panPosY = 2,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_9160_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {
		},
	},
[9161] = {
		appear = {
			{type = "scene", scene = "game", para = 916},
			{type = "numMoves", para = 3},
			{type = "topLevel", para = 916},
			{type = "staticBoard"},
			{type = "noPopup"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 3, countR = 1, countC = 1},
                    [2] = {r = 3, c = 5, countR = 1, countC = 1},
                    [3] = {r = 3, c = 7, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text91601",panType = "up", panAlign = "matrixD", panPosY = 2,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_9161_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {
		},
	},
--第976关，冰封导弹新手引导
[9760] = {
		appear = {
			{type = "scene", scene = "game", para = 976},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 976},
			{type = "noPopup"},
			{type = "staticBoard"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 1},}, 
				text = "tutorial.game.text97600",panType = "up", panAlign = "matrixD", panPosY = 3.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_9760_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 4, countR = 1, countC = 1},
                         [2] = {r = 3, c = 5, countR = 2, countC = 1},
                         [3] = {r = 2, c = 6, countR = 1, countC = 1},
				}, 
				allow = {r = 3, c = 5, countR = 2, countC = 2}, 
				from = ccp(2, 5), to = ccp(3, 5), 
				text = "tutorial.game.text97601", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_9760_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(2, 5), to = ccp(3, 5)},
		},
	},
--第二步
[9761] = {
		appear = {
			{type = "scene", scene = "game", para = 976},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 976},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 9760 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 2, countR = 2, countC = 1},
					[2] = {r = 3, c = 3, countR = 1, countC = 3},
				}, 
				allow = {r = 3, c = 2, countR = 2, countC = 1}, 
				from = ccp(2, 2), to = ccp(3, 2), 
				text = "tutorial.game.text97602", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_9761_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(2, 2), to = ccp(3, 2)},
		},
	},
	--第三步
[9762] = {
		appear = {
			{type = "scene", scene = "game", para = 976},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 976},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 9761 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 5, countR = 1, countC = 3},
					[2] = {r = 3, c = 8, countR = 2, countC = 1},
				}, 
				allow = {r = 3, c = 8, countR = 2, countC = 1}, 
				from = ccp(3, 8), to = ccp(2, 8), 
				text = "tutorial.game.text97603", panType = "up", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_9762_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 8), to = ccp(2, 8)},
		},
	},

--第46关，牢笼新手引导
[460] = {
		appear = {
			{type = "scene", scene = "game", para = 46},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 46},
			{type = "noPopup"},
			{type = "staticBoard"},
			--{type = "onceOnly"},
			{type = "onceLevel"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {
				      [1] = {r = 7, c = 4, countR = 1, countC = 1},
				      [2] = {r = 7, c = 6, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text4600",panType = "down", panAlign = "matrixD", panPosY = 3.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_460_0", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 9, c = 4, countR = 3, countC = 1},
                         [2] = {r = 8, c = 3, countR = 1, countC = 1},
				}, 
				allow = {r = 8, c = 3, countR = 1, countC = 2}, 
				from = ccp(8, 3.3), to = ccp(8, 4.3), 
				text = "tutorial.game.text4601", panType = "down", panAlign = "matrixD", panPosY = 3.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_460_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(8, 3), to = ccp(8, 4)},
		},
	},

-- 圣诞活动1-3
	[2900020] = {
		appear = {
			{type = "scene", scene = "game", para = 290002},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "userLevelLessThan", para = 406},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 2, countR = 1, countC = 1},
                         [2] = {r = 8, c = 1, countR = 1, countC = 3},
				}, 
				allow = {r = 8, c = 2, countR = 2, countC = 1}, 
				from = ccp(7.3, 2), to = ccp(8.3, 2),
				text = "tutorial.game.text2900020",
				panAlign = "matrixD", panPosY = 3.5, panType = "down",
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_290002_1", -- 新引导对话框参考此处
				},
			},
		disappear = {
			{type = "swap", from = ccp(7, 2), to = ccp(8, 2)},
		},
	},
	[2900021] = {
		appear = {
			{type = "scene", scene = "game", para = 290002},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 406},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = { 2900020 },},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 1, countR = 1, countC = 3},
                         [2] = {r = 8, c = 1, countR = 1, countC = 1},
				}, 
				allow = {r = 8, c = 1, countR = 2, countC = 1}, 
				from = ccp(7.3, 1), to = ccp(8.3, 1), 
				text = "tutorial.game.text2900021", panType = "down", panAlign = "matrixD", panPosY = 3.5, 
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_290002_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
			{type = "swap", from = ccp(7, 1), to = ccp(8, 1)},
		},
	},

	[2900022] = {
		appear = {
			{type = "scene", scene = "game", para = 290002},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 406},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = { 2900020, 2900021 },},
		},
		action = {
			[1] = {
				type = "showInfo", opacity = 0xCC, 
				text = "tutorial.game.text2900022",
				panType = "up", panAlign = "matrixD", panPosY = 5.5, panFlip = true, 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290002_3", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},


--圣诞活动2-1
	[2900030] = {
		appear = {
			{type = "scene", scene = "game", para = 290003},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 436},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 2, countR = 1, countC = 1}
				},
				text = "tutorial.game.text2900030",panType = "up", panAlign = "matrixD", panPosY = 2.5, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1, panPosX = 180, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290003_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--圣诞活动3-1
	[2900060] = {
		appear = {
			{type = "scene", scene = "game", para = 290006},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 466},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 5, countR = 1, countC = 1}},
				text = "tutorial.game.text2900060",panType = "up", panAlign = "matrixD", panPosY = 1.5, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290006_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--圣诞活动4-1
	[2900090] = {
		appear = {
			{type = "scene", scene = "game", para = 290009},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 556},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 4, countR = 1, countC = 1}},
				text = "tutorial.game.text2900090",panType = "up", panAlign = "matrixD", panPosY = 0.5, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290009_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},


-- 元宵活动1-1
	[2901010] = {
		appear = {
			{type = "scene", scene = "game", para = 290101},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 4, countR = 1, countC = 3},
                         [2] = {r = 5, c = 5, countR = 1, countC = 1},
                         [3] = {r = 7, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 7, c = 5, countR = 2, countC = 1}, 
				from = ccp(6, 5), to = ccp(7, 5),
				panAlign = "matrixD", panPosY = 2, 
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_290101_1", -- 新引导对话框参考此处
				},
			},
		disappear = {
			{type = "swap", from = ccp(6, 5), to = ccp(7, 5)},
		},
	},
	[2901011] = {
		appear = {
			{type = "scene", scene = "game", para = 290101},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = { 2901010 },},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 5, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 3.5, 
				panDelay = 0.2, 
				panelName = "guide_dialogue_290101_2", -- 新引导对话框参考此处
			},
			[2] = {
				type = "showTile", opacity = 0, 
				array = {[1] = {r = 6, c = 5, countR = 1, countC = 1},
				},
				panAlign = "matrixD", panPosY = -2,  
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4,
				panelName = "guide_dialogue_290101_3", -- 新引导对话框参考此处
				completeImmediatelyOnTouchBegin = true ,
			},
		},
		disappear = {
		},
	},

--元宵活动1-3
	[2901030] = {
		appear = {
			{type = "scene", scene = "game", para = 290103},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 406},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 2, c = 3, countR = 2, countC = 1}
				},
				panAlign = "matrixD", panPosY = -1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1, panPosX = 230, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290103_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--元宵活动2-1
	[2901040] = {
		appear = {
			{type = "scene", scene = "game", para = 290104},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 466},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 1, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 3.5, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = 70, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290104_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--元宵活动3-1
	[2901070] = {
		appear = {
			{type = "scene", scene = "game", para = 290107},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 556},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 4, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290107_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--元宵活动4-1
	[2901100] = {
		appear = {
			{type = "scene", scene = "game", para = 290110},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 631},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = 80, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290110_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--元宵活动5-1
	[2901130] = {
		appear = {
			{type = "scene", scene = "game", para = 290113},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 3, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 0.8, 
				panDelay = 0.2, panPosX = 240, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290113_1", -- 新引导对话框参考此处
			},
			[2] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 2, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 2.3, 
				panDelay = 0.2, panPosX = 170, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290113_2", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

-- 端午活动1-1
	[2902010] = {
		appear = {
			{type = "scene", scene = "game", para = 290201},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 5, countR = 1, countC = 1},
                         [2] = {r = 7, c = 4, countR = 1, countC = 3},
				}, 
				allow = {r = 7, c = 5, countR = 2, countC = 1}, 
				from = ccp(7, 5), to = ccp(6, 5),
				panAlign = "matrixD", panPosY = 3, 
				handDelay = 1.2 , panDelay = 0.8, 
				panelName = "guide_dialogue_290201_1", -- 新引导对话框参考此处
				},
			},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(6, 5)},
		},
	},
	[2902011] = {
		appear = {
			{type = "scene", scene = "game", para = 290201},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = { 2902010 },},
		},
		action = {
			[1] = {type = "showObj", opacity = 0xCC, index = 1, 
			text = "tutorial.game.text4700", panType = "up", panAlign = "winYU", panPosY = 50,
			maskDelay = 1,maskFade = 0.4, panDelay = 1.3, touchDelay = 1.9,
			panelName = "guide_dialogue_290201_2", -- 新引导对话框参考此处
			}, 
		},
		disappear = {}
	},

--端午活动1-3
	[2902030] = {
		appear = {
			{type = "scene", scene = "game", para = 290203},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 406},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 2, countR = 3, countC = 1}
				},
				panAlign = "matrixD", panPosY = 1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1, panPosX = 230, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290203_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--端午活动2-1
	[2902040] = {
		appear = {
			{type = "scene", scene = "game", para = 290204},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 556},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 2, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = -0.5, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = 70, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290204_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--端午活动3-1
	[2902070] = {
		appear = {
			{type = "scene", scene = "game", para = 290207},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 631},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 7, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290207_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--端午活动4-1
	[2902100] = {
		appear = {
			{type = "scene", scene = "game", para = 290210},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 2, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = -1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = 80, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290210_1", -- 新引导对话框参考此处
			},
			[2] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 3, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = -0.7, 
				panDelay = 0.2, panPosX = 170, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290210_2", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--端午活动5-1
	[2902130] = {
		appear = {
			{type = "scene", scene = "game", para = 290213},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 976},
			{type = "noPopup"},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 2.8, 
				panDelay = 0.2, panPosX = 240, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290213_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

-- 暑期活动1-1
	[2903010] = {
		appear = {
			{type = "scene", scene = "game", para = 290301},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 436},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 4, countR = 1, countC = 1}
				},
				panAlign = "matrixD", panPosY = 2, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1, panPosX = 55, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290301_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--暑期活动1-3
	[2903030] = {
		appear = {
			{type = "scene", scene = "game", para = 290303},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 406},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 6, c = 2, countR = 2, countC = 1}
				},
				panAlign = "matrixD", panPosY = 2.4, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1, panPosX = 225, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290303_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--暑期活动2-1
	[2903040] = {
		appear = {
			{type = "scene", scene = "game", para = 290304},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 211},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 3, countR = 2, countC = 2}},
				panAlign = "matrixD", panPosY = 1.5, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = -70, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290304_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--暑期活动3-1
	[2903070] = {
		appear = {
			{type = "scene", scene = "game", para = 290307},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 556},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 4, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = 230, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290307_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--暑期活动4-1
	[2903100] = {
		appear = {
			{type = "scene", scene = "game", para = 290310},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 631},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 2, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panPosX = -200, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290310_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--暑期活动5-1
	[2903130] = {
		appear = {
			{type = "scene", scene = "game", para = 290313},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 2, countR = 1, countC = 1},
                         [2] = {r = 6, c = 3, countR = 3, countC = 1},
                         [3] = {r = 5, c = 4, countR = 1, countC = 1},
				}, 
				allow = {r = 6, c = 3, countR = 2, countC = 1}, 
				from = ccp(6, 3), to = ccp(5, 3),
				panAlign = "matrixD", panPosY = 0.8, 
				panDelay = 0.2, panPosX = 170, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290313_1", -- 新引导对话框参考此处
			},
		},
		disappear = {{type = "swap", from = ccp(6, 3), to = ccp(5, 3)}},
	},

--暑期活动6-1
	[2903160] = {
		appear = {
			{type = "scene", scene = "game", para = 290316},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 976},
			{type = "noPopup"},
			{type = "onceOnly"}
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 8, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 1.8, 
				panDelay = 0.2, panPosX = 70, panHorizonAlign = "winX",
				panelName = "guide_dialogue_290316_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},


--2017春节关卡引导
--第一步 :介绍福袋鸡&引导收集福袋
   [2801010] = {
		appear = {
			{type = "scene", scene = "game", para = 280101},
			{type = "noPopup"},
			{type = "numMoves", para = 0},
			{type = "onceOnly"},
			{type = "onceLevel"},
			{type = "staticBoard"},
		     },
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 1 },
				         [2] = {r = 3, c = 4, countR = 1, countC = 3 },
                         [3] = {r = 4, c = 5, countR = 1, countC = 1 },
				        }, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3.3, 5), to = ccp(4.3, 5), 
				text = "tutorial.game.text28010100",panType = "down", panAlign = "matrixD", panPosY = 5,
				handDelay = 1.4 , panDelay = 0.6, touchDelay = 1.8, maskDelay = 0.4, maskFade = 0.4,
				panelName = "guide_dialogue_2801010_1", -- 新引导对话框参考此处(看，福袋鸡，在它旁边进行三消，即可收集它哟！)
			},
		},
		disappear = {
		        {type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},

--第二步：继续介绍福袋鸡
    [2801011] = {
			appear = {
				{type = "scene", scene = "game", para = 280101},
				{type = "numMoves", para = 1},
				{type = "noPopup"},
				{type = "onceOnly"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2801010},},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
				array = {[1] = {r = 2, c = 8, countR = 1, countC = 1 },
				         [2] = {r = 4, c = 8, countR = 1, countC = 1 },
				         [3] = {r = 5, c = 7, countR = 1, countC = 3 },
				         }, 
				allow = {r = 5, c = 8, countR = 2, countC = 1}, 
				from = ccp(4.3, 8), to = ccp(5.3, 8), 
				text = "tutorial.game.text28010101",panType = "down" , panAlign = "matrixD" , panPosY = 7.5,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.8, handDelay = 1.4,
				panelName = "guide_dialogue_2801011_1", -- 新引导对话框参考此处（用特效也能收集福袋级哟！）
			},

		},
			disappear = {
				{type = "swap", from = ccp(4, 8), to = ccp(5, 8)},
			},
		},
--第三步：介绍鸡窝
    [2801012] = {
			appear = {
				{type = "scene", scene = "game", para = 280101},
				{type = "numMoves", para = 2},
				{type = "noPopup"},
				{type = "onceOnly"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2801011},},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
					array = {[1] = {r = 5, c = 6, countR = 1, countC = 2 },
					         [2] = {r = 6, c = 8, countR = 3, countC = 1 },
					},
					allow = {r = 5, c = 8, countR = 2, countC = 1}, 
					from = ccp(4.3, 8), to = ccp(5.3, 8), 
					text = "tutorial.game.text28010102",panType = "down" , panAlign = "matrixD" , panPosY = 5,
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.8, handDelay = 1.4,
					panelName = "guide_dialogue_2801012_1", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(4, 8), to = ccp(5, 8)},
			},
		},
--第四步：介绍大招
    [2801013] = {
			appear = {
				{type = "scene", scene = "game", para = 280101},
				{type = "numMoves", para = 3},
				{type = "noPopup"},
				{type = "onceOnly"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2801012},},
			},
			action = {
			    [1] = {type = "showCustomizeArea", opacity = 0xCC, 
					offsetX = 0, offsetY = 0, width = 150, height = 150, position = ccp(349, 131), --默认值
					text = "tutorial.game.text28010103",panType = "up", panAlign = "matrixD", panPosY = 3,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_2801013_1", -- 新引导对话框参考此处
				},
			-- [1] = {type = "showTile", opacity = 0xCC, 
			-- 	array = {
			-- 		[1] = {r = 1, c = 7, countR = 2, countC = 1.3},
			-- 	}, 
			-- 	text = "tutorial.game.text28010103",panType = "up", panAlign = "matrixD", panPosY = 2,
			-- 	panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
			-- 	panelName = "guide_dialogue_2801013_1", -- 新引导对话框参考此处
			-- },			
			},
			disappear = {
			},
	},
--第五步：介绍步数
    [2801014] = {
			appear = {
				{type = "scene", scene = "game", para = 280101},
				{type = "numMoves", para = 4},
				{type = "noPopup"},
				{type = "onceOnly"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2801013},},
			},
			action = {
				[1] = {
					type = "popImage", opacity = 0xCC, posAdd = ccp(-100,-90),
					width = 180, height = 160, 
					panType = "up" ,panAlign = "winY" , panPosY = 1100, panFlip ="true",
					maskDelay = 0.3 ,maskfade = 0.3, panDelay = 0.6, touchDelay = 1.8,
					panelName = "guide_dialogue_2801014_1", -- 新引导对话框参考此处
					pics = {
						[1] = {align = 'board', groupName = 'pic_2801014_2', scale = 1, x = 0.8, y = 2,},
					},
				},
			},	
			disappear = {
				
			},
		},
		--2017三周年关卡引导
-- 第一步 :引导小故事&引导消除冰
    [2802010] = {
			appear = {
			{type = "scene", scene = "game", para = 280201},
			{type = "noPopup"},
			{type = "numMoves", para = 0},
			{type = "onceLevel"},
			{type = "staticBoard"},
			{type = "notPassedLevel" , para = 280201},
		     },
		action = {

			[1] = {type = "showTile", opacity = 0xCC, index = 1,
				array = {[1] = {r = 1, c = -1, countR = 3, countC = 13 },},
				text = "tutorial.game.text28000000", panType = "up", panAlign = "matrixD", panPosY = 2, 
				maskDelay = 0.4, maskFade = 0.4, panDelay = 0.5, 
				panelName = "guide_dialogue_2802010_1", -- 新引导对话框参考此处
				},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 4, countR = 3, countC = 1 },
                         [2] = {r = 6, c = 3, countR = 1, countC = 1 },
				}, 
				allow = {r = 6, c = 3, countR = 1, countC = 2}, 
				from = ccp(6.3, 3), to = ccp(6.3, 4), 
				text = "tutorial.game.text28000001",panType = "down", panAlign = "matrixD", panPosY = 2,
				handDelay = 1.4 , panDelay = 0.6, touchDelay = 1.4, maskDelay = 0.4, maskFade = 0.4,
				panelName = "guide_dialogue_2802010_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		        {type = "swap", from = ccp(6, 3), to = ccp(6, 4)},
		},
	},

     --第二步：引导破碎雪块
    [2802011] = {
			appear = {
				{type = "scene", scene = "game", para = 280201},
				{type = "numMoves", para = 1},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2802010}},
			    {type = "notPassedLevel" , para = 280201},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
				array = {[1] = {r = 6, c = 4, countR = 1, countC = 1 },
				         [2] = {r = 7, c = 5, countR = 4, countC = 1 },
				         [3] = {r = 7, c = 6, countR = 4, countC = 1 },
				         }, 
				allow = {r = 6, c = 4, countR = 1, countC = 2}, 
				from = ccp(6, 4.3), to = ccp(6, 5.3), 
				text = "tutorial.game.text28000002",panType = "down" , panAlign = "matrixD" , panPosY = 1,
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4, handDelay = 1.4,
				panelName = "guide_dialogue_2802011_1", -- 新引导对话框参考此处
			},

			},
			disappear = {
				{type = "swap", from = ccp(6, 4), to = ccp(6, 5)},
			}
		},
		--第三步：引导走步数
	[2802012] = {
			appear = {
				{type = "scene", scene = "game", para = 280201},
				{type = "numMoves", para = 2},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2802011}},
			    {type = "notPassedLevel" , para = 280201},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1.5, c = 1, countR = 1, countC = 1},}, 
					panType = "up", panAlign = "matrixD", panPosY = -0.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_2802012_1", -- 新引导对话框参考此处
				},	
			},	
			disappear = {
				
			},	
		},
		--第四步：引导消除炸药
    [2802013] = {
			appear = {
				{type = "scene", scene = "game", para = 280201},
				{type = "numMoves", para = 3},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2802012}},
			    {type = "notPassedLevel" , para = 280201},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
					array = {[1] = {r = 7, c = 9, countR = 5, countC = 1 },
					},
					allow = {r = 4, c = 9, countR = 2, countC = 1}, 
					from = ccp(3, 9.3), to = ccp(4, 9.3), 
					text = "tutorial.game.text28000003",panType = "down" , panAlign = "matrixD" , panPosY = 3,
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4, handDelay = 1.4,
					panelName = "guide_dialogue_2802013_1", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(3, 9), to = ccp(4, 9)},
			}
		},
	--第1036关，小叶堆新手引导
	--第1步，小树桩出现，小树桩消除1
	[10360] = {
			appear = {
				{type = "scene", scene = "game", para = 1036},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1036},
				{type = "noPopup"},
				{type = "staticBoard"},
				--{type = "onceOnly"},
				{type = "onceLevel"},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 3, c = 4, countR = 2, countC = 3},}, 
					text = "tutorial.game.text1036001",panType = "up", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_10360_1", -- 新引导对话框参考此处
				},			
			   [2] = {type = "gameSwap", opacity = 0xCC, 
					array = {[1] = {r = 1, c = 5, countR = 1, countC = 1},
	                         [2] = {r = 2, c = 4, countR = 1, countC = 3},
					}, 
					allow = {r = 2, c = 5, countR = 2, countC = 1}, 
					from = ccp(1, 5), to = ccp(2, 5), 
					text = "tutorial.game.text1036002", panType = "up", panAlign = "matrixD", panPosY = 1,
					handDelay = 1.2 , panDelay = 0.8 , 
					panelName = "guide_dialogue_10360_2", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(1, 5), to = ccp(2, 5)},
			},
		},
	--第2步，小树桩消除2
	[10361] = {
			appear = {
				{type = "scene", scene = "game", para = 1036},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1036},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 10360 },},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 2, c = 5, countR = 1, countC = 3},
						[2] = {r = 3, c = 5, countR = 1, countC = 3},
					}, 
					allow = {r = 3, c = 7, countR = 2, countC = 1}, 
					from = ccp(2, 7), to = ccp(3, 7), 
					text = "tutorial.game.text1036003", panType = "up", panAlign = "matrixD", panPosY = 2,
					handDelay = 1.2 , panDelay = 0.8 ,
					panelName = "guide_dialogue_10361_1", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(2, 7), to = ccp(3, 7)},
			},
		},
	--第3步，小叶堆生成，小叶堆消除
	[10362] = {
			appear = {
				{type = "scene", scene = "game", para = 1036},
				{type = "numMoves", para = 2},
				{type = "topLevel", para = 1036},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 10361 },},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
						array = {[1] = {r = 8, c = 1, countR = 6, countC = 2},
						}, 
						text = "tutorial.game.text1036004",panType = "up", panAlign = "matrixD", panPosY = 3,
						panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
						panelName = "guide_dialogue_10362_1", -- 新引导对话框参考此处
				},			
			    [2] = {type = "gameSwap", opacity = 0xCC, 
						array = {[1] = {r = 8, c = 1, countR = 4, countC = 2},
						}, 
						allow = {r = 6, c = 1, countR = 2, countC = 1}, 
						from = ccp(5, 1), to = ccp(6, 1), 
						text = "tutorial.game.text1036005", panType = "down", panAlign = "matrixD", panPosY = 5,
						handDelay = 1.2 , panDelay = 0.8 , 
					    panelName = "guide_dialogue_10362_2", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(5, 1), to = ccp(6, 1)},
			},
		},
	--1096关，星星瓶引导 
	--第1阶段星星瓶出现引导，第一次充能消除
	[10960] = {
			appear = {
				{type = "scene", scene = "game", para = 1096},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1096},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 6, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1096001",panType = "down", panAlign = "matrixD", panPosY = 1.0,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_10960_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 3, c = 4, countR = 1, countC = 3},
						[2] = {r = 2, c = 5, countR = 1, countC = 1},
						[3] = {r = 6, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 3, c = 5, countR = 2, countC = 1}, 
					from = ccp(2, 5), to = ccp(3, 5),
					text = "tutorial.game.text1096002",panType = "up", panAlign = "matrixD", panPosY = 7.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_10960_2", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(2,5), to = ccp(3, 5)},
			},
		},
	
	--第2步星星瓶充能操作
	[10961] = {
			appear = {
				{type = "scene", scene = "game", para = 1096},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1096},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 10960 },},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 3, c = 6, countR = 1, countC = 1},
						[2] = {r = 4, c = 5, countR = 1, countC = 3},
						[3] = {r = 6, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 4, c = 6, countR = 2, countC = 1}, 
					from = ccp(3, 6), to = ccp(4, 6),
					text = "tutorial.game.text1096003",panType = "up", panAlign = "matrixD", panPosY = 7.2,
					panDelay = 0.001, maskDelay = 0.001 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_10961_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(3,6), to = ccp(4, 6)},
			},
		},	
	[10962] = {
			appear = {
				{type = "scene", scene = "game", para = 1096},
				{type = "numMoves", para = 2},
				{type = "topLevel", para = 1096},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 10961 },},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 3, c = 4, countR = 1, countC = 1},
						[2] = {r = 4, c = 3, countR = 1, countC = 3},
						[3] = {r = 6, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 4, c = 4, countR = 2, countC = 1}, 
					from = ccp(3, 4), to = ccp(4, 4),
					text = "tutorial.game.text1096004",panType = "up", panAlign = "matrixD", panPosY = 5.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_10962_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(3,4), to = ccp(4, 4)},
			},
		},	
		--星星瓶使用引导
	[10963] = {
			appear = {
				{type = "scene", scene = "game", para = 1096},
				{type = "numMoves", para = 3},
				{type = "topLevel", para = 1096},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 10962 },},
				{type = "noNewPreProp"},
			},
			action = {
				
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 7, c = 4, countR = 2, countC = 3},
						
					}, 
					allow = {r = 7, c = 5, countR = 2, countC = 1}, 
					from = ccp(6, 5), to = ccp(7, 5),
					text = "tutorial.game.text1096005",panType = "down", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_10963_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(6,5), to = ccp(7, 5)},
			},
		},	
	--1156关，水母宝宝引导 
	--第1阶段水母宝宝出现引导，解锁一层水母宝宝
	[11560] = {
			appear = {
				{type = "scene", scene = "game", para = 1156},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1156},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1156001",panType = "down", panAlign = "matrixD", panPosY = 0.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_11560_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 4, c = 4, countR = 1, countC = 3},
						[2] = {r = 3, c = 5, countR = 1, countC = 1},
						[3] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 4, c = 5, countR = 2, countC = 1}, 
					from = ccp(3, 5), to = ccp(4, 5),
					text = "tutorial.game.text1156002",panType = "up", panAlign = "matrixD", panPosY = 6.0,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2, 
					panelName = "guide_dialogue_11560_2", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(3,5), to = ccp(4, 5)},
			},
		},	
	--第2步水母宝宝解锁操作
	[11561] = {
			appear = {
				{type = "scene", scene = "game", para = 1156},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1156},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 11560 },},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 7, c = 4, countR = 3, countC = 1},
						[2] = {r = 7, c = 5, countR = 1, countC = 1},
						[3] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 7, c = 4, countR = 1, countC = 2}, 
					from = ccp(7, 4), to = ccp(7, 5),
					text = "tutorial.game.text1156003",panType = "up", panAlign = "matrixD", panPosY = 7.0,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2,
					panelName = "guide_dialogue_11561_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(7,4), to = ccp(7, 5)},	
				},
		},	
	[11562] = {
			appear = {
				{type = "scene", scene = "game", para = 1156},
				{type = "numMoves", para = 2},
				{type = "topLevel", para = 1156},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 11561 },},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 7, c = 4, countR = 3, countC = 1},
						[2] = {r = 7, c = 5, countR = 1, countC = 1},
						[3] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 7, c = 4, countR = 1, countC = 2}, 
					from = ccp(7, 4), to = ccp(7, 5),
					text = "tutorial.game.text1156004",panType = "up", panAlign = "matrixD", panPosY = 7.0,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2,
					panelName = "guide_dialogue_11562_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(7,4), to = ccp(7, 5)},
			},
		},		
		--水母宝宝使用引导
	[11563] = {
			appear = {
				{type = "scene", scene = "game", para = 1156},
				{type = "numMoves", para = 3},
				{type = "topLevel", para = 1156},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 11562 },},
			},
			action = {
				
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 5, c = 4, countR = 3, countC = 1},
						[2] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 5, c = 4, countR = 1, countC = 2}, 
					from = ccp(5, 4), to = ccp(5, 5),
					text = "tutorial.game.text1156005",panType = "down", panAlign = "matrixD", panPosY = 0.0,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2,
					panelName = "guide_dialogue_11563_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(5,4), to = ccp(5, 5)},
			},
		},
	--1216关，色彩顾虑器引导 
	--第1阶段色彩过滤器出现引导
	[12160] = {
			appear = {
				{type = "scene", scene = "game", para = 1216},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1216},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 5, c = 6, countR = 1, countC = 3},}, 
					text = "tutorial.game.text1156001",panType = "down", panAlign = "matrixD", panPosY = 0.0,panPosX = 120,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_12160_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 4, c = 6, countR = 1, countC = 3},
						[2] = {r = 3, c = 7, countR = 1, countC = 1},
						[3] = {r = 5, c = 6, countR = 1, countC = 3},
					}, 
					allow = {r = 4, c = 7, countR = 2, countC = 1}, 
					from = ccp(3, 7), to = ccp(4, 7),
					text = "tutorial.game.text1156002",panType = "up", panAlign = "matrixD", panPosY = 4.5,panPosX = 120,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2, 
					panelName = "guide_dialogue_12160_2", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(3,7), to = ccp(4, 7)},
			},
		},	
	--第2步封印石板解锁操作
	[12161] = {
			appear = {
				{type = "scene", scene = "game", para = 1216},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1216},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 12160 },},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 4, c = 6, countR = 1, countC = 3},
						[2] = {r = 3, c = 7, countR = 1, countC = 1},
						[3] = {r = 5, c = 6, countR = 1, countC = 3},
					}, 
					allow = {r = 4, c = 7, countR = 2, countC = 1}, 
					from = ccp(3, 7), to = ccp(4, 7),
					text = "tutorial.game.text1156003",panType = "up", panAlign = "matrixD", panPosY = 4.5,panPosX = 120,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2,
					panelName = "guide_dialogue_12161_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(3,7), to = ccp(4, 7)},	
				},
		},	
	[12162] = {
			appear = {
				{type = "scene", scene = "game", para = 1216},
				{type = "numMoves", para = 2},
				{type = "topLevel", para = 1216},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 12161 },},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 4, c = 6, countR = 1, countC = 3},
						[2] = {r = 3, c = 7, countR = 1, countC = 1},
						[3] = {r = 5, c = 6, countR = 1, countC = 3},
					}, 
					allow = {r = 4, c =7, countR = 2, countC = 1}, 
					from = ccp(3, 7), to = ccp(4, 7),
					text = "tutorial.game.text1156004",panType = "up", panAlign = "matrixD", panPosY = 4.5,panPosX = 120,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2,
					panelName = "guide_dialogue_12162_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(3,7), to = ccp(4, 7)},
			},
		},		
		--色彩过滤器说明引导
	[12163] = {
			appear = {
				{type = "scene", scene = "game", para = 1216},
				{type = "numMoves", para = 3},
				{type = "topLevel", para = 1216},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 12162 },},
			},
			action = {
				
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 5, c = 6, countR = 1, countC = 3},}, 
					text = "tutorial.game.text1156001",panType = "down", panAlign = "matrixD", panPosY = 0.0,panPosX = 120,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_12163_1", -- 新引导对话框参考此处
				},	
			},				
			disappear = {
				
			},
		},

	--1276关，染色蛋引导 
	--第1阶段染色蛋出现引导
	[12760] = {
			appear = {
				{type = "scene", scene = "game", para = 1276},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1276},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 3, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1276001",panType = "down", panAlign = "matrixD", panPosY = 3.5,panPosX = 120,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_12760_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 2, c = 4, countR = 1, countC = 3},
						[2] = {r = 1, c = 5, countR = 1, countC = 1},
						[3] = {r = 3, c = 5, countR = 1, countC = 1},
					}, 
					allow = {r = 2, c = 5, countR = 2, countC = 1}, 
					from = ccp(1, 5), to = ccp(2, 5),
					text = "tutorial.game.text1276002",panType = "up", panAlign = "matrixD", panPosY = 1.5,panPosX = 120,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2, 
					panelName = "guide_dialogue_12760_2", -- 新引导对话框参考此处
				},
			},
			disappear = {
				{type = "swap", from = ccp(1,5), to = ccp(2, 5)},
			},
		},	
	--第2步染色蛋连消操作
	[12761] = {
			appear = {
				{type = "scene", scene = "game", para = 1276},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1276},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 12760 },},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 3, c = 4, countR = 1, countC = 3},
						[2] = {r = 2, c = 5, countR = 1, countC = 1},
						[3] = {r = 4, c = 4, countR = 1, countC = 3},
					}, 
					allow = {r = 3, c = 5, countR = 2, countC = 1}, 
					from = ccp(2, 5), to = ccp(3, 5),
					text = "tutorial.game.text1276003",panType = "up", panAlign = "matrixD", panPosY = 4.5,panPosX = 120,
					panDelay = 0.8, maskDelay = 0.4 ,maskFade = 0.4,touchDelay = 1.7,handDelay = 1.2,
					panelName = "guide_dialogue_12761_1", -- 新引导对话框参考此处
				},
			},				
			disappear = {
				{type = "swap", from = ccp(2,5), to = ccp(3, 5)},	
				},
		},	

--第1336关，宝箱新手引导
	--第1步，介绍钥匙、宝箱，并引导消一次钥匙
	[13360] = {
			appear = {
				{type = "scene", scene = "game", para = 1336},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1336},
				{type = "noPopup"},
				{type = "staticBoard"},
				--{type = "onceOnly"},
				{type = "onceLevel"},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 7, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1336001",panType = "up", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_13360_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 6, c = 3, countR = 1, countC = 5},
					         [2] = {r = 9, c = 3, countR = 1, countC = 5},
					         [3] = {r = 9, c = 3, countR = 4, countC = 1},
					         [4] = {r = 9, c = 7, countR = 4, countC = 1},
					}, 
					text = "tutorial.game.text1336002",panType = "up", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_13360_2", -- 新引导对话框参考此处
				},			
			    [3] = {type = "gameSwap", opacity = 0xCC, 
					array = {[1] = {r = 7, c = 4, countR = 1, countC = 3},
	                         [2] = {r = 8, c = 4, countR = 1, countC = 3},
					}, 
					allow = {r = 8, c = 5, countR = 2, countC = 1}, 
					from = ccp(8, 5), to = ccp(7, 5), 
					text = "tutorial.game.text1336003", panType = "up", panAlign = "matrixD", panPosY = 1,
					handDelay = 1.2 , panDelay = 0.8 , 
					panelName = "guide_dialogue_13360_3", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(8, 5), to = ccp(7, 5)},
			},
		},
	--第2步，介绍锁上数字，并引导第二次消除钥匙
	[13361] = {
			appear = {
				{type = "scene", scene = "game", para = 1336},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1336},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 13360 },},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 9, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1336101",panType = "up", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_13361_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "gameSwap", opacity = 0xCC, 
					array = {
						[1] = {r = 7, c = 4, countR = 1, countC = 3},
						[2] = {r = 8, c = 4, countR = 1, countC = 1},
						[3] = {r = 8, c = 6, countR = 1, countC = 1},
					}, 
					allow = {r = 8, c = 6, countR = 2, countC = 1}, 
					from = ccp(8, 6), to = ccp(7, 6), 
					text = "tutorial.game.text1336102", panType = "up", panAlign = "matrixD", panPosY = 2,
					handDelay = 1.2 , panDelay = 0.8 ,
					panelName = "guide_dialogue_13361_2", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(8, 6), to = ccp(7, 6)},
			},
		},


--第1396关，蓄电精灵新手引导
	--第1步，介绍蓄电精灵、精灵球，并引导移动一次蓄电精灵
	[13960] = {
			appear = {
				{type = "scene", scene = "game", para = 1396},
				{type = "numMoves", para = 0},
				{type = "topLevel", para = 1396},
				{type = "noPopup"},
				{type = "staticBoard"},
				--{type = "onceOnly"},
				{type = "onceLevel"},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 3, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1396001",panType = "up", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_13960_1", -- 新引导对话框参考此处
				},	
				[2] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},
					}, 
					text = "tutorial.game.text1396002",panType = "up", panAlign = "matrixD", panPosY = 1.5,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_13960_2", -- 新引导对话框参考此处
				},			
			    [3] = {type = "gameSwap", opacity = 0xCC, 
					array = {[1] = {r = 2, c = 4, countR = 1, countC = 4},
					         [2] = {r = 3, c = 5, countR = 3, countC = 1}, 
					}, 
					allow = {r = 2, c = 4, countR = 1, countC = 2}, 
					from = ccp(2, 4), to = ccp(2, 5), 
					text = "tutorial.game.text1396003", panType = "up", panAlign = "matrixD", panPosY = 1,
					handDelay = 1.2 , panDelay = 0.8 , 
					panelName = "guide_dialogue_13960_3", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(2, 4), to = ccp(2, 5)},
			},
		},
	--第2步，介绍蓄电精灵吃特效的效果
	[13961] = {
			appear = {
				{type = "scene", scene = "game", para = 1396},
				{type = "numMoves", para = 1},
				{type = "topLevel", para = 1396},
				{type = "noPopup"},
				{type = "staticBoard"},
				{type = "onceLevel"},
				{type = "curLevelGuided", guide = { 13960 },},
				{type = "noNewPreProp"},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 2, c = 5, countR = 1, countC = 1},}, 
					text = "tutorial.game.text1396101",panType = "up", panAlign = "matrixD", panPosY = 2,
					panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
					panelName = "guide_dialogue_13961_1", -- 新引导对话框参考此处
				},
				[2] = {type = "gameSwap", opacity = 0xCC, 
					array = {[1] = {r = 3, c = 4, countR = 3, countC = 1},
							 [2] = {r = 3, c = 5, countR = 1, countC = 1}, 
					 
					}, 
					allow = {r = 3, c = 4, countR = 1, countC = 2}, 
					from = ccp(3, 4), to = ccp(3, 5), 
					text = "tutorial.game.text1396102", panType = "up", panAlign = "matrixD", panPosY = 2,
					handDelay = 1.2 , panDelay = 0.8 ,
					panelName = "guide_dialogue_13961_2", -- 新引导对话框参考此处
			   },
			},
			disappear = {
				{type = "swap", from = ccp(3, 4), to = ccp(3, 5)},
			},
		},

		--第1486关，寄居蟹新手引导
[14860] = {
		appear = {
			{type = "scene", scene = "game", para = 1486},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1486},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 2, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text148600",panType = "up", panAlign = "matrixD", panPosY = 3,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_14860_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 8, c = 5, countR = 1, countC = 1},
                         [2] = {r = 7, c = 4, countR = 1, countC = 3},
                         [3] = {r = 2, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 8, c = 5, countR = 2, countC = 1}, 
				from = ccp(7.3, 5), to = ccp(8.3, 5), 
				text = "tutorial.game.text148601", panType = "down", panAlign = "matrixD", panPosY = 3,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_14860_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(7, 5), to = ccp(8, 5)},
		},
	},
--蓄能过程
	[14861] = {
		appear = {
			{type = "scene", scene = "game", para = 1486},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 1486},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 14860 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 4, countR = 1, countC = 3},
                         [2] = {r = 8, c = 6, countR = 1, countC = 1},
                         [3] = {r = 2, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 8, c = 6, countR = 2, countC = 1}, 
				from = ccp(7.3, 6), to = ccp(8.3, 6), 
				text = "tutorial.game.text148602", panType = "down", panAlign = "matrixD", panPosY = 4.5,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_14861_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(7, 6), to = ccp(8, 6)},
		},
	},
			--第1576关，魔法炮新手引导
[15760] = {
		appear = {
			{type = "scene", scene = "game", para = 1576},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1576},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 3, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text148600",panType = "up", panAlign = "matrixD", panPosY = 2.5,
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_15760_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 5, countR = 1, countC = 1},
                         [2] = {r = 2, c = 4, countR = 1, countC = 3},
                         [3] = {r = 3, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 2, c = 5, countR = 2, countC = 1}, 
				from = ccp(1, 5), to = ccp(2, 5), 
				text = "tutorial.game.text148601", panType = "down", panAlign = "matrixD", panPosY = 1.5,
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_15760_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(1, 5), to = ccp(2, 5)},
		},
	},
--发炮过程
	[15761] = {
		appear = {
			{type = "scene", scene = "game", para = 1576},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 1576},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 15760 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 4, countR = 1, countC = 1},
                         [2] = {r = 2, c = 4, countR = 1, countC = 3},
                         [3] = {r = 3, c = 5, countR = 1, countC = 1},
						 [4] = {r = 8, c = 4, countR = 3, countC = 3},
				}, 
				allow = {r = 2, c = 4, countR = 2, countC = 1}, 
				from = ccp(1, 4), to = ccp(2, 4), 
				text = "tutorial.game.text148602", panType = "down", panAlign = "matrixD", panPosY = 1,
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_15761_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(1, 4), to = ccp(2, 4)},
		},
	},

				--第1666关，小幽灵新手引导
[16660] = {
		appear = {
			{type = "scene", scene = "game", para = 1666},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1666},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 6, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text166600",panType = "up", panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 6, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_16660_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 4, countR = 1, countC = 3},
                         [2] = {r = 8, c = 4, countR = 1, countC = 2},
                         [3] = {r = 9, c = 5, countR = 1, countC = 1},
						 [4] = {r = 6, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 8, c = 4, countR = 1, countC = 2}, 
				from = ccp(8, 4), to = ccp(8, 5), 
				text = "tutorial.game.text166601", panType = "down", panHorizonAlign = "matrixD" , panPosX = 3.5,
				panAlign = "matrixD", panPosY = 3.5, 
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_16660_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(8, 4), to = ccp(8, 5)},
		},
	},
--特效加速
	[16661] = {
		appear = {
			{type = "scene", scene = "game", para = 1666},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 1666},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 16660 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 9, countR = 1, countC = 1},
                         [2] = {r = 5, c = 9, countR = 1, countC = 1},
                         [3] = {r = 5, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 5, c = 9, countR = 2, countC = 1}, 
				from = ccp(4, 9), to = ccp(5, 9), 
				text = "tutorial.game.text166602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 1, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_16661_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(4, 9), to = ccp(5, 9)},
		},
	},
	--收集口引导
	[16662] = {
		appear = {
			{type = "scene", scene = "game", para = 1666},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 1666},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 16661 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 1, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text166600",panType = "up", panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 1, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_16662_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--第1756关，太阳花新手引导
--一次消除
[17560] = {
		appear = {
			{type = "scene", scene = "game", para = 1756},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1756},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 4, countR = 1, countC = 1},
                         [2] = {r = 4, c = 4, countR = 3, countC = 1},
                         [3] = {r = 3, c = 5, countR = 1, countC = 1},
						 }, 		
				allow = {r = 3, c = 4, countR = 1, countC = 2}, 
				from = ccp(3, 4), to = ccp(3, 5),
				text = "tutorial.game.text175600",panType = "up", panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 5.5, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_17560_1", -- 新引导对话框参考此处
			},			
		},
		disappear = {
			{type = "swap", from = ccp(3, 4), to = ccp(3, 5)},
		},
	},
--二次消除
	[17561] = {
		appear = {
			{type = "scene", scene = "game", para = 1756},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 1756},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 17560 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 4, countR = 3, countC = 1},
                         [2] = {r = 4, c = 5, countR = 1, countC = 1},
                         [3] = {r = 5, c = 6, countR = 2, countC = 1},
				}, 
				allow = {r = 4, c = 4, countR = 2, countC = 1}, 
				from = ccp(3, 4), to = ccp(4, 4),  
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 5.5, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_17561_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 4), to = ccp(4, 4)},
		},
	},
	--阳光瓶爆炸
	[17562] = {
		appear = {
			{type = "scene", scene = "game", para = 1756},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 1756},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 17561 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 4, countR = 4, countC = 1},
                         [2] = {r = 4, c = 5, countR = 1, countC = 1},
				}, 
				allow = {r = 4, c = 4, countR = 1, countC = 2}, 
				from = ccp(4, 4), to = ccp(4, 5),  
				text = "tutorial.game.text175603", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 5.5, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_17562_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(4, 4), to = ccp(4, 5)},
		},
	},
	--太阳花引导
	[17563] = {
		appear = {
			{type = "scene", scene = "game", para = 1756},
			{type = "numMoves", para = 3},
			{type = "topLevel", para = 1756},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 17562 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 6, c = 5, countR = 1, countC = 1}}, 
				text = "tutorial.game.text175604",panType = "up", panHorizonAlign = "matrixD" , panPosX = 3,
				panAlign = "matrixD", panPosY = 6.5, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_17563_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--第1846关，墨鱼宝宝新手引导
	--认识和充能
[18460] = {
		appear = {
			{type = "scene", scene = "game", para = 1846},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1846},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 9, c = 5, countR = 2, countC = 1}}, 
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4.1,
				panAlign = "matrixD", panPosY = 6.6, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_18460_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 3, countR = 3, countC = 1},
                         [2] = {r = 7, c = 4, countR = 4, countC = 1},
				}, 
				allow = {r = 5, c = 4, countR = 2, countC = 1}, 
				from = ccp(4, 4), to = ccp(5, 4), 
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 7.2,
				panAlign = "matrixD", panPosY = 1.5, 
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_18460_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(4, 4), to = ccp(5, 4)},
		},
	},
--继续充能
	[18461] = {
		appear = {
			{type = "scene", scene = "game", para = 1846},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 1846},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 18460 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 7, countR = 3, countC = 1},
                         [2] = {r = 7, c = 6, countR = 4, countC = 1},
				}, 
				allow = {r = 5, c = 6, countR = 2, countC = 1}, 
				from = ccp(4, 6), to = ccp(5, 6),  
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 5.5,
				panAlign = "matrixD", panPosY = 1.5, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_18461_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(4, 6), to = ccp(5, 6)},
		},
	},
	--引导消除剩余的墨鱼
	[18462] = {
		appear = {
			{type = "scene", scene = "game", para = 1846},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 1846},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 18461 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 1, countR = 2, countC = 1},
                         [2] = {r = 2, c = 9, countR = 2, countC = 1},}, 
				text = "tutorial.game.text175604",panType = "up", panHorizonAlign = "matrixD" , panPosX = 4.8,
				panAlign = "matrixD", panPosY = 1.5, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_18462_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--第1936关，荷花苞新手引导
	--认识和消除
[19360] = {
		appear = {
			{type = "scene", scene = "game", para = 1936},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 1936},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},
						 [2] = {r = 3, c = 2, countR = 1, countC = 1},
						 [3] = {r = 4, c = 1, countR = 1, countC = 1},
						 [4] = {r = 3, c = 8, countR = 1, countC = 1},
						 [5] = {r = 4, c = 9, countR = 1, countC = 1},
				}, 
				text = "tutorial.game.text193600", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4.1,
				panAlign = "matrixD", panPosY = 6.6, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_19360_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 1, countC = 3},
                         [2] = {r = 5, c = 5, countR = 3, countC = 1},
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3, 5), to = ccp(4, 5), 
				text = "tutorial.game.text193602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 3.1,
				panAlign = "matrixD", panPosY = 6.6, 
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_19360_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},
	--继续充能
	[19361] = {
		appear = {
			{type = "scene", scene = "game", para = 1936},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 1936},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 19360 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 1, countC = 3},
                         [2] = {r = 5, c = 5, countR = 3, countC = 1},
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3, 5), to = ccp(4, 5),  
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 3.1,
				panAlign = "matrixD", panPosY = 6.6, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_19361_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},
	--继续充能
	[19362] = {
		appear = {
			{type = "scene", scene = "game", para = 1936},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 1936},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 19361 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 1, countC = 3},
                         [2] = {r = 5, c = 5, countR = 3, countC = 1},
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3, 5), to = ccp(4, 5),  
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 3.1,
				panAlign = "matrixD", panPosY = 6.6, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_19362_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},

	--第2056关，夹心饼干新手引导
	--认识和涂第一层奶油
[20560] = {
		appear = {
			{type = "scene", scene = "game", para = 2056},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 2056},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 2, countC = 3},
				}, 
				text = "tutorial.game.text205600", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4.1,
				panAlign = "matrixD", panPosY = 6.6, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_20560_1", -- 新引导对话框参考此处
			},			
		   [2] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 2, countC = 3},
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3, 5), to = ccp(4, 5), 
				text = "tutorial.game.text205602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4.1,
				panAlign = "matrixD", panPosY = 6.6, 
				handDelay = 1.2 , panDelay = 0.8 , 
				panelName = "guide_dialogue_20560_2", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},
	--涂第二层奶油
	[20561] = {
		appear = {
			{type = "scene", scene = "game", para = 2056},
			{type = "numMoves", para = 1},
			{type = "topLevel", para = 2056},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 20560 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 2, countC = 3},  
				}, 
				allow = {r = 4, c = 5, countR = 2, countC = 1}, 
				from = ccp(3, 5), to = ccp(4, 5),  
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = -0.8,
				panAlign = "matrixD", panPosY = 2.6, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_20561_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(3, 5), to = ccp(4, 5)},
		},
	},
	--涂第三层奶油
	[20562] = {
		appear = {
			{type = "scene", scene = "game", para = 2056},
			{type = "numMoves", para = 2},
			{type = "topLevel", para = 2056},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "onceLevel"},
			{type = "curLevelGuided", guide = { 20561 },},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 2, countC = 3},
                         [2] = {r = 6, c = 5, countR = 2, countC = 1},
				}, 
				allow = {r = 6, c = 5, countR = 2, countC = 1}, 
				from = ccp(5, 5), to = ccp(6, 5),  
				text = "tutorial.game.text175602", panType = "down", panHorizonAlign = "matrixD" , panPosX = 4.1,
				panAlign = "matrixD", panPosY = 7.0, 
				handDelay = 1.2 , panDelay = 0.8 ,
				panelName = "guide_dialogue_20562_1", -- 新引导对话框参考此处
		   },
		},
		disappear = {
			{type = "swap", from = ccp(5, 5), to = ccp(6, 5)},
		},
	},
	--13关前置特效说明
	-- [130] = {
		-- appear = {
			-- {type = "scene", scene = "game", para = 13},
			-- {type = "numMoves", para = 0},
			-- {type = "topLevel", para = 13},
			-- {type = "noPopup"},
			-- {type = "onceLevel"},
			-- {type = "noNewPreProp"},
		-- },
		-- action = {
			-- [1] = {type = "showTile", opacity = 0xCC, 
				-- array = {[1] = {r = 8, c = 5, countR = 3, countC = 1 },
                         -- [2] = {r = 7, c = 6, countR = 1, countC = 1 },
						 -- }, 
				-- text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 1.1,
				-- panAlign = "matrixD", panPosY = 2, 
				-- panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				-- panelName = "guide_dialogue_130_2", -- 新引导对话框参考此处
			-- },	
		-- },
		-- disappear = {
		-- },
	-- },
	
	--134关提示使用魔法棒
	[1340] = {
		appear = {
			{type = "scene", scene = "game", para = 134},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 134},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 9, c = 1, countR = 1, countC = 9}}, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 0.6,
				panAlign = "matrixD", panPosY = 4, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1340_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--161关提示使用小木槌
	[1610] = {
		appear = {
			{type = "scene", scene = "game", para = 161},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 161},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 2, countR = 1, countC = 1 },
                         [2] = {r = 1, c = 8, countR = 1, countC = 1 },}, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 0.6,
				panAlign = "matrixD", panPosY = 0.8, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_1610_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--235关提示使用小木槌
	[2350] = {
		appear = {
			{type = "scene", scene = "game", para = 235},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 235},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 4, countR = 1, countC = 1 },
                         [2] = {r = 4, c = 9, countR = 1, countC = 1 },
						 [3] = {r = 9, c = 6, countR = 1, countC = 1 },
                         [4] = {r = 6, c = 1, countR = 1, countC = 1 },}, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 0.6,
				panAlign = "matrixD", panPosY = 0.1, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2350_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--273关提示使用魔法棒
	[2730] = {
		appear = {
			{type = "scene", scene = "game", para = 273},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 273},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 9, c = 1, countR = 1, countC = 4 },
                         [2] = {r = 9, c = 6, countR = 1, countC = 4 },
						 }, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 0.4,
				panAlign = "matrixD", panPosY = 4, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_2730_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--393关提示使用魔法棒
	[3930] = {
		appear = {
			{type = "scene", scene = "game", para = 393},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 393},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 9, c = 3, countR = 9, countC = 1}}, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 0.2,
				panAlign = "matrixD", panPosY = 3, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_3930_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--532关提示使用小木槌
	[5320] = {
		appear = {
			{type = "scene", scene = "game", para = 532},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 532},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 9, c = 1, countR = 1, countC = 1 },
                         [2] = {r = 9, c = 9, countR = 1, countC = 1 },
						 }, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 1.2,
				panAlign = "matrixD", panPosY = 4, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_5320_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
	--571关提示使用魔法棒
	[5710] = {
		appear = {
			{type = "scene", scene = "game", para = 571},
			{type = "numMoves", para = 0},
			{type = "topLevel", para = 571},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "noNewPreProp"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {{r = 9, c = 1, countR = 1, countC = 9}}, 
				text = "tutorial.game.text13400",panType = "up", panHorizonAlign = "matrixD" , panPosX = 0.6,
				panAlign = "matrixD", panPosY = 4, 
				panDelay = 1.1, maskDelay = 0.8 ,maskFade = 0.4,touchDelay = 1.7,
				panelName = "guide_dialogue_5710_1", -- 新引导对话框参考此处
			},	
		},
		disappear = {
		},
	},
	
--2017十一活动关卡引导
-- 第一步 :引导消除星星宝石
    [2803010] = {
			appear = {
			{type = "scene", scene = "game", para = 280301},
			{type = "noPopup"},
			{type = "numMoves", para = 0},
			{type = "onceLevel"},
			{type = "staticBoard"},
			{type = "notPassedLevel" , para = 280301},
		     },
		action = {

			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 3, countR = 1, countC = 1 },
                         [2] = {r = 6, c = 4, countR = 3, countC = 1 },
				}, 
				allow = {r = 4, c = 3, countR = 1, countC = 2}, 
				from = ccp(4.3, 3), to = ccp(4.3, 4), 
				text = "tutorial.game.text28000001",panType = "down", panAlign = "matrixD", panPosY = 0,
				panPosX = 280, panHorizonAlign = "winX",
				handDelay = 1.4 , panDelay = 0.6, touchDelay = 1.4, maskDelay = 0.4, maskFade = 0.4,
				panelName = "guide_dialogue_280301_1", -- 新引导对话框参考此处
				cannotSkip = true,
			},
		},
		disappear = {
		        {type = "swap", from = ccp(4, 3), to = ccp(4, 4)},
		},
	},

     --第二步：引导消除星星飞碟
    [2803011] = {
			appear = {
				{type = "scene", scene = "game", para = 280301},
				{type = "numMoves", para = 1},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2803010}},
			    {type = "notPassedLevel" , para = 280301},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
				array = {[1] = {r = 1, c = 7, countR = 1, countC = 1 },
				         [2] = {r = 2, c = 6, countR = 1, countC = 3 },
				         [3] = {r = 3, c = 7, countR = 1, countC = 1 },
				         }, 
				allow = {r = 3, c = 7, countR = 2, countC = 1}, 
				from = ccp(3.3, 7), to = ccp(2.3, 7), 
				text = "tutorial.game.text28000002",panType = "down" , panAlign = "matrixD" , panPosY = -2.5,
				panPosX = 50, panHorizonAlign = "winX",
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4, handDelay = 1.4,
				panelName = "guide_dialogue_280301_2", -- 新引导对话框参考此处
				cannotSkip = true,
			},

			},
			disappear = {
				{type = "swap", from = ccp(3, 7), to = ccp(2, 7)},
			}
		},
		--第三步：引导走步数
	[2803012] = {
			appear = {
				{type = "scene", scene = "game", para = 280301},
				{type = "numMoves", para = 2},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2803011}},
			    {type = "notPassedLevel" , para = 280301},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1.5, c = 1, countR = 1, countC = 1.5},}, 
					panType = "up", panAlign = "matrixD", panPosY = -1.5,
					panPosX = 70, panHorizonAlign = "winX",
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
					panelName = "guide_dialogue_280301_3", -- 新引导对话框参考此处
					cannotSkip = true,
				},		
			},	
			disappear = {
			
			},	
		},
		--第四步：引导走步数&引导使用大招
	[2803013] = {
			appear = {
				{type = "scene", scene = "game", para = 280301},
				{type = "numMoves", para = 3},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2803012}},
			    {type = "notPassedLevel" , para = 280301},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 1, c = -1, countR = 8, countC = 13},}, 
					panType = "up", panAlign = "matrixD", panPosY = -1,
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
					panelName = "guide_dialogue_280301_5", -- 新引导对话框参考此处
					cannotSkip = true,
				},	
			},	
			disappear = {
			
			},	
		},

--2018中秋活动关卡引导
-- 第一步 :引导消除花灯
    [2804010] = {
			appear = {
			{type = "scene", scene = "game", para = 280401},
			{type = "noPopup"},
			{type = "numMoves", para = 0},
			{type = "onceLevel"},
			{type = "staticBoard"},
			{type = "notPassedLevel" , para = 280401},
		     },
		action = {

			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 8, c = 6, countR = 1, countC = 1 },
                         [2] = {r = 9, c = 5, countR = 3, countC = 1 },
				}, 
				allow = {r = 8, c = 5, countR = 1, countC = 2}, 
				from = ccp(8.3, 5), to = ccp(8.3, 6), 
				text = "tutorial.game.text28000001",panType = "down", 
				panAlign = "matrixD", panPosY = 8, 
				panPosX = 4.5, panHorizonAlign = "matrixD",
				handDelay = 1.4 , panDelay = 0.6, touchDelay = 1.4, maskDelay = 0.4, maskFade = 0.4,
				panelName = "guide_dialogue_280401_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
		        {type = "swap", from = ccp(8, 5), to = ccp(8, 6)},
		},
	},

     --第二步：引导消除月饼
    [2804011] = {
			appear = {
				{type = "scene", scene = "game", para = 280401},
				{type = "numMoves", para = 1},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2804010}},
			    {type = "notPassedLevel" , para = 280401},
			},
			action = {
				[1] = {type = "gameSwap", opacity = 0xCC,
				array = {[1] = {r = 3, c = 8, countR = 1, countC = 1 },
				         [2] = {r = 4, c = 7, countR = 1, countC = 3 },
				         [3] = {r = 5, c = 8, countR = 1, countC = 1 },
				         }, 
				allow = {r = 4, c = 8, countR = 2, countC = 1}, 
				from = ccp(3.3, 8), to = ccp(4.3, 8), 
				text = "tutorial.game.text28000002",panType = "down" , panAlign = "matrixD" , panPosY = 5,
				panPosX = 7.5, panHorizonAlign = "matrixD",
				panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4, handDelay = 1.4,
				panelName = "guide_dialogue_280401_2", -- 新引导对话框参考此处
			},

			},
			disappear = {
				{type = "swap", from = ccp(4, 8), to = ccp(3, 8)},
			}
		},
		--第三步：引导走步数和碎片目标
	[2804012] = {
			appear = {
				{type = "scene", scene = "game", para = 280401},
				{type = "numMoves", para = 2},
				{type = "noPopup"},
				{type = "onceLevel"},
			    {type = "staticBoard"},
			    {type = "curLevelGuided", guide = {2804011}},
			    {type = "notPassedLevel" , para = 280401},
			},
			action = {
				[1] = {type = "showTile", opacity = 0xCC, 
					array = {[1] = {r = 2, c = 1, countR = 1, countC = 1},}, 
					panType = "up", panAlign = "matrixD", panPosY = 2.5,
					panPosX = 2, panHorizonAlign = "matrixD",
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
					panelName = "guide_dialogue_280401_3", -- 新引导对话框参考此处
					cannotSkip = true,
				},	
				[2] = {	
					type = "showCustomizeArea", opacity = 0xCC, 
					offsetX = 0, offsetY = 0, 
					width = 300, height = 150, 
					baseOn = "baseOnZQTargetLanterns",
					position = ccp(vo.x + vs.width - 300, vo.y + vs.height - 150), 
					panPosX = vo.x + vs.width - 400, panPosY = 200,--默认值
					panType = "up", panAlign = "winYU", panHorizonAlign = "winX",
					panDelay = 0.8, maskDelay = 0.3 ,maskFade = 0.4,touchDelay = 1.4,
					panelName = "guide_dialogue_280401_4", 
					cannotSkip = true,
				},
			},	
			disappear = {
			
			},	
		},


-- 2018春节活动1-1
	[2904000] = {
		appear = {
			{type = "scene", scene = "game", para = 290400},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
		},

		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 7, c = 5, countR = 1, countC = 1}
				},
				text = "tutorial.game.text7600",panType = "down",
				panHorizonAlign = "matrixD" , panPosX = 5,
				panAlign = "matrixD", panPosY = 7,  
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290400_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		
		},
	},

--2018春节活动2-1
	[2904030] = {
		appear = {
			{type = "scene", scene = "game", para = 290403},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 556},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 3, c = 4, countR = 1, countC = 1}
				},
				panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290403_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018春节活动3-1
	[2904060] = {
		appear = {
			{type = "scene", scene = "game", para = 290406},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 676},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				panHorizonAlign = "matrixD" , panPosX = 4,
				array = {[1] = {r = 1, c = 4, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290406_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 8, c = 2, countR = 1, countC = 1} ,
				        	[2] = {r = 9, c = 1, countR = 1, countC = 3}
				        },
				allow = {r =9, c =2,countR =2, countC =1},
				from = ccp (8,2),to = ccp(9,2),
				panAlign = "matrixD", panPosY = 9, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290406_2", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 2,

			},
		},
		disappear = {
		{type = "swap", from = ccp(8,2),to = ccp(9,2)},
		},
	},
	[2904061] = {
		appear = {
			{type = "scene", scene = "game", para = 290406},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = {2904060},},
		},
		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 4, countR = 2, countC = 1}},
				allow = {r = 7, c = 4, countR = 2, countC = 1},
				from = ccp(7, 4), to = ccp(6, 4),
				panAlign = "matrixD", panPosY = 7, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panHorizonAlign = "matrixD" , panPosX = 4,

				panelName = "guide_dialogue_290406_3", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap",from = ccp(7, 4), to = ccp(6, 4)},
		},
	},

--2018春节活动3-3
	[2904080] = {
		appear = {
			{type = "scene", scene = "game", para = 290408},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 730},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 2, countC = 1}},
				panAlign = "matrixD", panPosY = 3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290408_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 5,
			},
		},
		disappear = {},
	},

--2018春节活动7-1
	[2904180] = {
		appear = {
			{type = "scene", scene = "game", para = 290418},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 436},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 7, countR = 1, countC = 2}},
				panAlign = "matrixD", panPosY = 7, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290418_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 7,
			},
		},
		disappear = {},
	},

--2018春节活动8-1
	[2904210] = {
		appear = {
			{type = "scene", scene = "game", para = 290421},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 976},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 4, countR = 1, countC = 1},}, 
				panAlign = "matrixD", panPosY = 2, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290421_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 4,
			},
		},
		disappear = {},
	},

--2018春节活动9-1
	[2904240] = {
		appear = {
			{type = "scene", scene = "game", para = 290424},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 736},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 9, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 5, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290424_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 9,
			},
		},
		disappear = {},
	},

--2018春节活动13-1
	[2904360] = {
		appear = {
			{type = "scene", scene = "game", para = 290436},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 211},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 8, c = 6, countR = 2, countC = 2},
				}, 
				panAlign = "matrixD", panPosY = 8, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290436_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 6,
			},
		},
		disappear = {},
	},

--2018春节活动14-1
	[2904390] = {
		appear = {
			{type = "scene", scene = "game", para = 290439},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 4, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 4, 
				panDelay = 0.2, 
				panelName = "guide_dialogue_290439_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 4,
			},
		},
		disappear = {},
	},

--2018春节活动15-1
	[2904420] = {
		appear = {
			{type = "scene", scene = "game", para = 290442},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1156},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 2, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 2, 
				panDelay = 0.2, 
				panelName = "guide_dialogue_290442_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 2,
			},
		},
		disappear = {},
	},



-- 2018四周年活动1-1
	[2905010] = {
		appear = {
			{type = "scene", scene = "game", para = 290501},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
		},

		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 2, c = 4, countR = 2, countC = 2}
				},
				text = "tutorial.game.text7600",panType = "down",
				panHorizonAlign = "matrixD" , panPosX = 4,
				panAlign = "matrixD", panPosY = 2.3,  
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290501_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 1, c = 4, countR = 1, countC = 1} ,
				        	[2] = {r = 2, c = 3, countR = 1, countC = 3}
				        },
				allow = {r =2, c =4,countR =2, countC =1},
				from = ccp (2,4),to = ccp(1,4),
				panAlign = "matrixD", panPosY = 2, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290501_2", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = -2,
			},
		},
		disappear = {
		{type = "swap", from = ccp(2,4),to = ccp(1,4)},
		},
	},

	[2905011] = {
		appear = {
			{type = "scene", scene = "game", para = 290501},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = {2905010},},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 8, c = 1, countR = 8, countC = 8}},
				panAlign = "matrixD", panPosY = 1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panHorizonAlign = "matrixD" , panPosX = 4,
				panelName = "guide_dialogue_290501_3", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018四周年活动2-1
	[2905040] = {
		appear = {
			{type = "scene", scene = "game", para = 290504},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 221},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 8, c = 5, countR = 2, countC = 2}
				},
				panHorizonAlign = "matrixD" , panPosX = 5,
				panAlign = "matrixD", panPosY = 7, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290504_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018四周年活动3-1
	[2905070] = {
		appear = {
			{type = "scene", scene = "game", para = 290507},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 436},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				panHorizonAlign = "matrixD" , panPosX = 3.8,
				array = {[1] = {r = 4, c = 4, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 4, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290507_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},


--2018四周年活动4-1
	[2905100] = {
		appear = {
			{type = "scene", scene = "game", para = 290510},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 556},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 2, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 2, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290510_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 2,
			},
		},
		disappear = {},
	},

--2018四周年活动5-1
	[2905130] = {
		appear = {
			{type = "scene", scene = "game", para = 290513},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 631},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 8, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 4, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290513_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 8,
			},
		},
		disappear = {},
	},

--2018四周年活动6-1
	[2905160] = {
		appear = {
			{type = "scene", scene = "game", para = 290516},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 3, countR = 1, countC = 1},}, 
				panAlign = "matrixD", panPosY = -1, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290516_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 1.5,
			},
		},
		disappear = {},
	},

--2018四周年活动7-1
	[2905190] = {
		appear = {
			{type = "scene", scene = "game", para = 290519},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 976},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 5, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 4, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290519_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 5,
			},
		},
		disappear = {},
	},

--2018四周年活动8-1
	[2905220] = {
		appear = {
			{type = "scene", scene = "game", para = 290522},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1156},
			{type = "noPopup"},
			{type = "onceOnly"},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 1, c = 1, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 1.2, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290522_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 1,
			},
		},
		disappear = {},
	},

-- 2018暑期活动1-1
	[2906010] = {
		appear = {
			{type = "scene", scene = "game", para = 290601},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
		},

		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 4, countR = 2, countC = 2}
				},
				text = "tutorial.game.text7600",panType = "down",
				panHorizonAlign = "matrixD" , panPosX = 3.8,
				panAlign = "matrixD", panPosY = 4.3,  
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290601_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 5, c = 5, countR = 2, countC = 1} ,
				        	[2] = {r = 6, c = 4, countR = 1, countC = 2}
				        },
				allow = {r =6, c =4,countR =1, countC =2},
				from = ccp (6,4),to = ccp(6,5),
				panHorizonAlign = "matrixD" , panPosX = 3.8,
				panAlign = "matrixD", panPosY = 6.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290601_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(6,4),to = ccp(6,5)},
		},
	},

	[2906011] = {
		appear = {
			{type = "scene", scene = "game", para = 290601},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = {2906010},},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 9, c = 2, countR = 9, countC = 7}},
				panAlign = "matrixD", panPosY = 1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panHorizonAlign = "matrixD" , panPosX = 4,
				panelName = "guide_dialogue_290601_3", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018暑期活动2-1
	[2906040] = {
		appear = {
			{type = "scene", scene = "game", para = 290604},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 221},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 5, c = 4, countR = 2, countC = 2}
				},
				panHorizonAlign = "matrixD" , panPosX = 3.8,
				panAlign = "matrixD", panPosY = 4.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290604_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018暑期活动3-1
	[2906070] = {
		appear = {
			{type = "scene", scene = "game", para = 290607},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 121},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				panHorizonAlign = "matrixD" , panPosX = 4.8,
				array = {[1] = {r = 3, c = 5, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 4.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290607_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},


--2018暑期活动4-1
	[2906100] = {
		appear = {
			{type = "scene", scene = "game", para = 290610},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 436},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 5, countR = 1, countC = 1}},
				panHorizonAlign = "matrixD" , panPosX = 4.8,
				panAlign = "matrixD", panPosY = 3.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290610_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018暑期活动5-1
	[2906130] = {
		appear = {
			{type = "scene", scene = "game", para = 290613},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 631},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 7, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 4.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290613_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 6.8,
			},
		},
		disappear = {},
	},

--2018暑期活动6-1
	[2906160] = {
		appear = {
			{type = "scene", scene = "game", para = 290616},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 2, countR = 1, countC = 1},}, 
				panAlign = "matrixD", panPosY = 7.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290616_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 2.3,
			},
		},
		disappear = {},
	},

--2018暑期活动7-1
	[2906190] = {
		appear = {
			{type = "scene", scene = "game", para = 290619},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 976},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 8, c = 5, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 8.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290619_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 5.3,
			},
		},
		disappear = {},
	},

--2018暑期活动8-1
	[2906220] = {
		appear = {
			{type = "scene", scene = "game", para = 290622},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1156},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 5, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 4.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290622_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 5.3,
			},
		},
		disappear = {},
	},


--2018暑期活动9-1
	[2906250] = {
		appear = {
			{type = "scene", scene = "game", para = 290625},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1486},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 9, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 4.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290625_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 8.8,
			},
		},
		disappear = {},
	},

-- 2018暑期活动10-1
	[2906280] = {
		appear = {
			{type = "scene", scene = "game", para = 290628},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 676},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},

		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 7, c = 8, countR = 1, countC = 2}
				},
				text = "tutorial.game.text7600",panType = "down",
				panHorizonAlign = "matrixD" , panPosX = 7.8,
				panAlign = "matrixD", panPosY = 7.3,  
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290628_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 8, c = 8, countR = 1, countC = 2}
				        },
				allow = {r =8, c =8,countR =1, countC =2},
				from = ccp (8,8),to = ccp(8,9),
				panHorizonAlign = "matrixD" , panPosX = 7.8,
				panAlign = "matrixD", panPosY = 8.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290628_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(8,8),to = ccp(8,9)},
		},
	},

	[2906281] = {
		appear = {
			{type = "scene", scene = "game", para = 290628},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 676},
			{type = "noPopup"},
			{type = "curLevelGuided", guide = {2906280},},
			{type = "onceOnly"},
		},

		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 8, c = 8, countR = 1, countC = 2}
				        },
				allow = {r =8, c =8,countR =1, countC =2},
				from = ccp (8,8),to = ccp(8,9),
				panHorizonAlign = "matrixD" , panPosX = 7.8,
				panAlign = "matrixD", panPosY = 8.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290628_3", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(8,8),to = ccp(8,9)},
		},
	},


--2018暑期活动11-1
	[2906310] = {
		appear = {
			{type = "scene", scene = "game", para = 290631},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1096},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 6, c = 4, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 5.8, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290631_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 4.3,
			},
		},
		disappear = {},
	},

-- 2018十一活动1-1
	[2907010] = {
		appear = {
			{type = "scene", scene = "game", para = 290701},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
		},

		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 7, c = 4, countR = 2, countC = 2}
				},
				text = "tutorial.game.text7600",panType = "down",
				panHorizonAlign = "matrixD" , panPosX = 3.8,
				panAlign = "matrixD", panPosY = 6.3,  
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290701_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 6, c = 4, countR = 1, countC = 1} ,
				        	[2] = {r = 7, c = 5, countR = 3, countC = 1}
				        },
				allow = {r =6, c =4,countR =1, countC =2},
				from = ccp (6,4),to = ccp(6,5),
				panHorizonAlign = "matrixD" , panPosX = 3.3,
				panAlign = "matrixD", panPosY = 6.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290701_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(6,4),to = ccp(6,5)},
		},
	},

	[2907011] = {
		appear = {
			{type = "scene", scene = "game", para = 290701},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = {2907010},},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 0, c = -3, countR = 9, countC = 15}},
				panAlign = "matrixD", panPosY = -1, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panHorizonAlign = "matrixD" , panPosX = 3,
				panelName = "guide_dialogue_290701_3", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018十一活动2-1
	[2907040] = {
		appear = {
			{type = "scene", scene = "game", para = 290704},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 211},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {
				type = "showTile", 
				opacity = 0xCC, 
				array = {
					[1] = {r = 9, c = 4, countR = 2, countC = 2}
				},
				panHorizonAlign = "matrixD" , panPosX = 5.3,
				panAlign = "matrixD", panPosY = 8.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290704_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018十一活动3-1
	[2907070] = {
		appear = {
			{type = "scene", scene = "game", para = 290707},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 436},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				panHorizonAlign = "matrixD" , panPosX = 4.3,
				array = {[1] = {r = 6, c = 5, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 6.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290707_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},


--2018十一活动4-1
	[2907100] = {
		appear = {
			{type = "scene", scene = "game", para = 290710},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 631},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 3, c = 6, countR = 1, countC = 1}},
				panHorizonAlign = "matrixD" , panPosX = 5.3,
				panAlign = "matrixD", panPosY = 3.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290710_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018十一活动5-1
	[2907130] = {
		appear = {
			{type = "scene", scene = "game", para = 290713},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 871},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 5, countR = 1, countC = 1}},
				panHorizonAlign = "matrixD" , panPosX = 4.3,
				panAlign = "matrixD", panPosY = 7.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_290713_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018十一活动6-1
	[2907160] = {
		appear = {
			{type = "scene", scene = "game", para = 290716},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 8976},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 1, countR = 1, countC = 1},}, 
				panHorizonAlign = "matrixD" , panPosX = 1.3,
				panAlign = "matrixD", panPosY = 5.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290716_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018十一活动7-1
	[2907190] = {
		appear = {
			{type = "scene", scene = "game", para = 290719},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1156},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 1, countR = 1, countC = 1},
				}, 
				panHorizonAlign = "matrixD" , panPosX = 1.3,
				panAlign = "matrixD", panPosY = 4.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290719_1", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

--2018十一活动8-1
	[2907220] = {
		appear = {
			{type = "scene", scene = "game", para = 290722},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1486},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 2, c = 5, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 2.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290722_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 4.5,
			},
		},
		disappear = {},
	},


--2018十一活动9-1
	[2907250] = {
		appear = {
			{type = "scene", scene = "game", para = 290725},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 676},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 7, c = 8, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 7.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290725_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 7.3,
			},
		},
		disappear = {},
	},

--2018十一活动10-1
	[2907280] = {
		appear = {
			{type = "scene", scene = "game", para = 290728},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "userLevelLessThan", para = 1096},
			{type = "noPopup"},
			{type = "onceOnly"},
			
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 5, c = 5, countR = 1, countC = 1},
				}, 
				panAlign = "matrixD", panPosY = 5.3, 
				panDelay = 0.2,
				panelName = "guide_dialogue_290728_1", -- 新引导对话框参考此处
				panHorizonAlign = "matrixD" , panPosX = 5.3,
			},
		},
		disappear = {},
	},

-- 2018圣诞活动
	[3200060] = {
		appear = {
			{type = "scene", scene = "game", para = 320006},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
		},

		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 3, c = 4, countR = 1, countC = 3} ,
				        	[2] = {r = 2, c = 5, countR = 1, countC = 1}
				        },
				allow = {r =3, c =5,countR =2, countC =1},
				from = ccp (3,5),to = ccp(2,5),
				panHorizonAlign = "matrixD" , panPosX = 5.3,
				panAlign = "matrixD", panPosY = 3.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_320006_1", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(3,5),to = ccp(2,5)},
		},
	},

	[3200061] = {
		appear = {
			{type = "scene", scene = "game", para = 320006},
			{type = "numMoves", para = 1},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = {3200060},},
		},

		action = {
			[1] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 3, c = 4, countR = 1, countC = 3} ,
				        	[2] = {r = 2, c = 5, countR = 1, countC = 1}
				        },
				allow = {r =3, c =5,countR =2, countC =1},
				from = ccp (3,5),to = ccp(2,5),
				panHorizonAlign = "matrixD" , panPosX = 5.3,
				panAlign = "matrixD", panPosY = 3.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_320006_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(3,5),to = ccp(2,5)},
		},
	},

	[3200062] = {
		appear = {
			{type = "scene", scene = "game", para = 320006},
			{type = "numMoves", para = 2},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
			{type = "curLevelGuided", guide = {3200061},},
		},
		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 4, c = 5, countR = 1, countC = 1}},
				panAlign = "matrixD", panPosY = 4, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panHorizonAlign = "matrixD" , panPosX = 5.5,
				panelName = "guide_dialogue_320006_3", -- 新引导对话框参考此处
			},
		},
		disappear = {},
	},

-- 2019春节活动
	[3300010] = {
		appear = {
			{type = "scene", scene = "game", para = 330001},
			{type = "numMoves", para = 0},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceOnly"},
		},

		action = {
			[1] = {type = "showTile", opacity = 0xCC, 
				array = {[1] = {r = 9, c = 1, countR = 4, countC = 9}},
				panAlign = "matrixD", panPosY = 6, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panHorizonAlign = "matrixD" , panPosX = 4,
				panelName = "guide_dialogue_330001_1", -- 新引导对话框参考此处
			},
			[2] = {type = "gameSwap", opacity = 0xCC, 
				array = {
							[1] = {r = 9, c = 5, countR = 1, countC = 1} ,
				        	[2] = {r = 8, c = 4, countR = 1, countC = 3}
				        },
				allow = {r =9, c =5,countR =2, countC =1},
				from = ccp (9,5),to = ccp(8,5),
				panHorizonAlign = "matrixD" , panPosX = 6.3,
				panAlign = "matrixD", panPosY = 8.3, panFlip = true , 
				panDelay = 0.8, maskDelay = 0.5 ,maskFade = 0.4, touchDelay = 1.1,
				panelName = "guide_dialogue_330001_2", -- 新引导对话框参考此处
			},
		},
		disappear = {
		{type = "swap", from = ccp(9,5),to = ccp(8,5)},
		},
	},



-------------------------------------------某些面板上的引导-------------------------------------------
	--这个id 在LevelStrategyManager也有引用
	[3000000] = {
			appear = {
				{type = "onceOnly"},
				{type = "hasNoOtherGuide"},
				{type = 'waitSignal', name = 'forceLevelStrategyGuide', value = true}
			},
			action = {
			    [1] = {type = "showCustomizeArea", opacity = 0xDD, 
					offsetX = 0, offsetY = 0, 
					-- width = 150, height = 150, position = ccp(349, 131), panPosY = 300, --默认值
					panType = "up", panAlign = "viewY",
					panDelay = 0.5, maskDelay = 0 ,maskFade = 0.5,touchDelay = 2,
					panelName = "guide_dialogue_level_stragety_1", 
				},	
		    	[2] = {type = "showCustomizeArea", opacity = 0xDD, 
					offsetX = 0, offsetY = 0, 
					-- width = 150, height = 150, position = ccp(349, 131), panPosY = 300, --默认值
					panType = "up", panAlign = "viewY",
					panDelay = 0.5, maskDelay = 0 ,maskFade = 0.5,touchDelay = 2,
					panelName = "guide_dialogue_level_stragety_2", 
				},	
			},	
			disappear = {
			},	
		},

	-- [3000015] = {
	-- 		appear = {
	-- 			{type = "onceOnly"},
	-- 			-- {type = 'popdown', popdown='startGamePanel'},
	-- 			{type = "scene", scene = "worldMap"},
	-- 			{type = "noPopup"},
	-- 			{type = 'customCheck', func = function ( ... )
	-- 				if HomeSceneButtonsManager:getInstance().hasGuideOnScreen then
	-- 					return false
	-- 				end
	-- 				return require('zoo.PersonalCenter.PersonalInfoReward'):canTrigger()
	-- 			end},
	-- 		},
	-- 		action = {
	-- 			[1] = {type = 'customAction', func = function ( cb )
	-- 				local PersonalInfoGuide = require "zoo.PersonalCenter.PersonalInfoGuide"
	-- 				PersonalInfoGuide:popGuide(cb)
	-- 			end}
	-- 		},
	-- 		disappear = {
	-- 		}
	-- },
-------------------------------------------游戏内道具-----------------------------------------------------
--[[
	[500010099] = {--测试用
		appear = {
			{type = "scene", scene = "game"},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "notTimeLevel", para = 1},
			{type = "minNumMoves", para = 1},
			{type = "notUseProp" , para = {10001} },
			{type = "hasPropInBar" , para = 10001 },
			{type = "staticBoard"},
			{type = "noPopup"},
			--{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
		},
		action = {

			[1] = {type = "guidePropBar", opacity = 0x00, index = 2, 
				array = {propId = 10005}, 
				--array = {propId = 10002}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10019"
			},
		},
		disappear = {}
	},
	[500010098] = {--测试用
		appear = {
			{type = "scene", scene = "game"},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea}},
			{type = "notTimeLevel", para = 1},
			{type = "minNumMoves", para = 1},
			{type = "notUseProp" , para = {10001} },
			{type = "hasPropInBar" , para = 10001 },
			{type = "staticBoard"},
			{type = "noPopup"},
			--{type = "onceLevel"},
			{type = "hasNoOtherGuide"},
		},
		action = {

			[1] = {type = "guidePropBar", opacity = 0x00, index = 2, 
				array = {propId = 10010}, 
				--array = {propId = 10002}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10010"
			},
		},
		disappear = {}
	},
	
--]]



	[500010100] = {--刷新 弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly, GameLevelType.kMoleWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "minNumMoves", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kRefresh , GamePropsType.kRefresh_b , GamePropsType.kRefresh_l} },
			{type = "hasPropInBar" , para = 10001 },
			{type = "hasNoOperation" , para = 8 },
			{type = "hasNoSpecialAnimal" , para = 0 },
			{type = "firstGuideOnLevel"},
			{type = "hasNoOtherGuide"},
			{type = "canSwapArea"},
			{type = "IngamePropGuideManager", para = {propId=10001, type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10001, type='weak'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10001"
			},
		},
		disappear = {}
	},
	[5000101001] = {--刷新 强引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "minNumMoves", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kRefresh , GamePropsType.kRefresh_b , GamePropsType.kRefresh_l} },
			{type = "hasPropInBar" , para = 10001 },
			{type = "hasNoOperation" , para = 5 },
			{type = "hasNoSpecialAnimal" , para = 0 },
			{type = "firstGuideOnLevel"},
			{type = "hasNoOtherGuide"},
			{type = "canSwapArea"},
			{type = "IngamePropGuideManager", para = {propId=10001,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongRefresh", opacity = 0x00, index = 2, 
				array = {propId = 10001}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName1 = "guide_dialogue_10001_step1",
				panelName2 = "guide_dialogue_10001_step2",
			},
		},
		disappear = {}
	},
	[5000101002] = {--刷新 弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "onceLevel"},
			{type = "noPopup"},
			{type = "staticBoard"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "minNumMoves", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kRefresh , GamePropsType.kRefresh_b , GamePropsType.kRefresh_l} },
			{type = "hasPropInBar" , para = 10001 },
			{type = "hasNoOperation" , para = 8 },
			{type = "hasNoSpecialAnimal" , para = 0 },
			{type = "firstGuideOnLevel"},
			{type = "hasNoOtherGuide"},
			{type = "canSwapArea"},
			{type = "IngamePropGuideManager", para = {propId=10001, type='extra'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10001, type='extra'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10001"
			},
		},
		disappear = {}
	},

	--------------------------------------------------------------------------------------------
	-- -- 小木槌引导有优化 挪到TimelyHammerGuideMgr里做分组测试了
	-- [500010101] = {--小木槌 强引导
	-- 	appear = {
	-- 			{type = "scene", scene = "game"},
	-- 			{type = "onceLevel"},
	-- 			{type = "staticBoard"},
	-- 			{type = "noPopup"},
	-- 			{type = "firstGuideOnLevel"},
	-- 			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
	-- 			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
	-- 			{type = "minCurrLevel", para = 31},
	-- 			{type = "notTimeLevel", para = 1},
	-- 			{type = "notUseProp" , para = {GamePropsType.kHammer , GamePropsType.kHammer_b , GamePropsType.kHammer_l} },
	-- 			{type = "hasPropInBar" , para = 10010 },
	-- 			{type = "tagetLeft" , para = 2 },
	-- 			{type = "numMoveLeft", para = {4,1}},
	-- 			{type = "gameModeType", para = { 
	-- 											GameModeTypeId.LIGHT_UP_ID , 
	-- 											GameModeTypeId.ORDER_ID , 
	-- 											GameModeTypeId.DIG_MOVE_ID ,
	-- 											GameModeTypeId.DROP_DOWN_ID ,
	-- 											GameModeTypeId.SEA_ORDER_ID
	-- 										}},
	-- 			{type = "hasNoOtherGuide"},
	-- 			{type = "triggerHammer"},
	-- 			{type = "IngamePropGuideManager", para = {propId=10010,type='strong'}},
	-- 		},
	-- 	action = {

	-- 		[1] = {type = "guidePropStrongHammer", opacity = 0x00, index = 2, 
	-- 			array = {propId = 10010}, 
	-- 			text = "tutorial.game.text1901", multRadius = 1.3,
	-- 			panType = "down", panAlign = "winY", panPosY = 400, 
	-- 			maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
	-- 			panelName1 = "guide_dialogue_10010_step1",
	-- 			panelName2 = "guide_dialogue_10010_step2",
	-- 			panelName3 = "guide_dialogue_10010_step3",
	-- 		},
	-- 	},
	-- 	disappear = {}
	-- },
	-- [5000101011] = {--小木槌 弱引导
	-- 	appear = { 
	-- 		{type = "scene", scene = "game"},
	-- 		{type = "onceLevel"},
	-- 		{type = "staticBoard"},
	-- 		{type = "noPopup"},
	-- 		{type = "firstGuideOnLevel"},
	-- 		{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
	-- 		{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
	-- 		{type = "minCurrLevel", para = 31},
	-- 		{type = "notTimeLevel", para = 1},
	-- 		{type = "notUseProp" , para = {GamePropsType.kHammer , GamePropsType.kHammer_b , GamePropsType.kHammer_l} },
	-- 		{type = "hasPropInBar" , para = 10010 },
	-- 		{type = "tagetLeft" , para = 2 },
	-- 		{type = "numMoveLeft", para = {4,1}},
	-- 		{type = "gameModeType", para = { 
	-- 										GameModeTypeId.LIGHT_UP_ID , 
	-- 										GameModeTypeId.ORDER_ID , 
	-- 										GameModeTypeId.DIG_MOVE_ID ,
	-- 										GameModeTypeId.DROP_DOWN_ID ,
	-- 										GameModeTypeId.SEA_ORDER_ID
	-- 									}},
	-- 		{type = "hasNoOtherGuide"},
	-- 		{type = "IngamePropGuideManager", para = {propId=10010, type='weak'}},
	-- 	},
	-- 	action = {

	-- 		[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
	-- 			array = {propId = 10010, type='weak'}, 
	-- 			text = "tutorial.game.text1901", multRadius = 1.3,
	-- 			panType = "down", panAlign = "winY", panPosY = 400, 
	-- 			maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
	-- 			panelName = "guide_dialogue_trigger_10010"
	-- 		},
	-- 	},
	-- 	disappear = {}
	-- },
	-- [5000101012] = {--小木槌 弱引导
	-- 	appear = { 
	-- 		{type = "scene", scene = "game"},
	-- 		{type = "onceLevel"},
	-- 		{type = "staticBoard"},
	-- 		{type = "noPopup"},
	-- 		{type = "firstGuideOnLevel"},
	-- 		{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
	-- 		{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
	-- 		{type = "minCurrLevel", para = 31},
	-- 		{type = "notTimeLevel", para = 1},
	-- 		{type = "notUseProp" , para = {GamePropsType.kHammer , GamePropsType.kHammer_b , GamePropsType.kHammer_l} },
	-- 		{type = "hasPropInBar" , para = 10010 },
	-- 		{type = "tagetLeft" , para = 2 },
	-- 		{type = "numMoveLeft", para = {4,1}},
	-- 		{type = "gameModeType", para = { 
	-- 										GameModeTypeId.LIGHT_UP_ID , 
	-- 										GameModeTypeId.ORDER_ID , 
	-- 										GameModeTypeId.DIG_MOVE_ID ,
	-- 										GameModeTypeId.DROP_DOWN_ID ,
	-- 										GameModeTypeId.SEA_ORDER_ID
	-- 									}},
	-- 		{type = "hasNoOtherGuide"},
	-- 		{type = "IngamePropGuideManager", para = {propId=10010, type='extra'}},
	-- 	},
	-- 	action = {

	-- 		[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
	-- 			array = {propId = 10010, type='extra'}, 
	-- 			text = "tutorial.game.text1901", multRadius = 1.3,
	-- 			panType = "down", panAlign = "winY", panPosY = 400, 
	-- 			maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
	-- 			panelName = "guide_dialogue_trigger_10010"
	-- 		},
	-- 	},
	-- 	disappear = {}
	-- },

	-----------------------------------------------------------------------------------------------------------

	[500010102] = {--强制交换 强引导 特效
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017 }},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kSwap , GamePropsType.kSwap_b , GamePropsType.kSwap_l} },
			{type = "hasNoOtherGuide"},
			{type = "notTimeLevel", para = 1},
			{type = "hasPropInBar" , para = 10003 },
			{type = "minNumMoves", para = 1},
			{type = "triggerForceSwapSpecial"},
			{type = "IngamePropGuideManager", para = {propId=10003,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongForceSwapSpecial", 
				array = {propId = 10003}, 
				panelName1 = "guide_dialogue_10003_step1_new",
				panelName2 = "guide_dialogue_10003_step2_new",
				panelName3 = "guide_dialogue_10003_step3_new",
				panelName4 = "guide_dialogue_10003_step4_new",
			},
		},
		disappear = {}
	},
	[5000101021] = {--强制交换 强引导 豆荚
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall ,  GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017 }},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kSwap , GamePropsType.kSwap_b , GamePropsType.kSwap_l} },
			{type = "hasPropInBar" , para = 10003 },
			{type = "notTimeLevel", para = 1},
			{type = "tagetLeft" , para = 2 },
			{type = "numMoveLeft", para = {4,1}},
			{type = "gameModeType", para = {GameModeTypeId.DROP_DOWN_ID}},
			{type = "hasNoOtherGuide"},
			{type = "triggerForceSwapIngredient"},
			{type = "IngamePropGuideManager", para = {propId=10003,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongForceSwapIngredient", 
				array = {propId = 10003}, 
				panelName1 = "guide_dialogue_10003_step1_old",
				panelName2 = "guide_dialogue_10003_step2_old",
				panelName3 = "guide_dialogue_10003_step3_old",
			},
		},
		disappear = {}
	},
	[5000101022] = {--强制交换 --弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall ,  GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017 }},
			{type = "minCurrLevel", para = 31},
			{type = "notTimeLevel", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kSwap , GamePropsType.kSwap_b , GamePropsType.kSwap_l} },
			{type = "hasPropInBar" , para = 10003 },
			{type = "tagetLeft" , para = 2 },
			{type = "numMoveLeft", para = {4,1}},
			{type = "gameModeType", para = {GameModeTypeId.DROP_DOWN_ID}},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10003, type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10003, type='weak'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10003"
			},
		},
		disappear = {}
	},

	[5000101023] = {--强制交换 --弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea , GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017 }},
			{type = "minCurrLevel", para = 31},
			{type = "notTimeLevel", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kSwap , GamePropsType.kSwap_b , GamePropsType.kSwap_l} },
			{type = "hasPropInBar" , para = 10003 },
			{type = "tagetLeft" , para = 2 },
			{type = "numMoveLeft", para = {4,1}},
			{type = "gameModeType", para = {GameModeTypeId.DROP_DOWN_ID}},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10003, type='extra'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10003, type='extra'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10003"
			},
		},
		disappear = {}
	},

	-------------------------------------------------------------------------------------------------------------

	[500010103] = {--魔法棒 强引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kLineBrush , GamePropsType.kLineBrush_b , GamePropsType.kLineBrush_l} },
			{type = "hasPropInBar" , para = 10005 },
			-- {type = "numMoveLeft", para = {9,1}},
			{type = "hasNoOtherGuide"},
			-- {type = "hasBrid", para =  {1,2,1,1}},
			{type = "minNumMoves", para = 5},
			{type = "triggerBrush"},
			{type = "IngamePropGuideManager", para = {propId=10005,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongBrush",
				array = {propId = 10005}, 
				panelName1 = "guide_dialogue_10005_step1",
				panelName2 = "guide_dialogue_10005_step2",
				panelName3 = "guide_dialogue_10005_step3",
				panelName4 = "guide_dialogue_10005_step4",
			},
		},
		disappear = {}
	},
	[5000101031] = {--魔法棒  弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly,  GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kLineBrush , GamePropsType.kLineBrush_b , GamePropsType.kLineBrush_l} },
			{type = "hasPropInBar" , para = 10005 },
			{type = "numMoveLeft", para = {9,1}},
			{type = "hasNoOtherGuide"},
			{type = "hasBrid", para =  {1,2,1,1}},
			{type = "IngamePropGuideManager", para = {propId=10005, type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10005, type='weak'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10019"
			},
		},
		disappear = {}
	},

	[5000101032] = {--魔法棒  弱引导 附加
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall ,  GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kLineBrush , GamePropsType.kLineBrush_b , GamePropsType.kLineBrush_l} },
			{type = "hasPropInBar" , para = 10005 },
			{type = "numMoveLeft", para = {9,1}},
			{type = "hasNoOtherGuide"},
			{type = "hasBrid", para =  {1,2,1,1}},
			{type = "IngamePropGuideManager", para = {propId=10005, type='extra'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10005, type='extra'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10019"
			},
		},
		disappear = {}
	},
	-----------------------------------------------------------------------------------------------------------------------

	[500010104] = {--章鱼冰  强引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly,  GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kOctopusForbid , GamePropsType.kOctopusForbid_l } },
			{type = "hasPropInBar" , para = 10052 },
			{type = "notLevelOrder" , para = {[0] = {key1=4,key2=3}}},
			{type = "numMoveLeft", para = {9,1}},
			{type = "hasVenom", para = 11},
			{type = "hasNoOtherGuide"},
			{type = "minNumMoves", para = 1},
			{type = "IngamePropGuideManager", para = {propId=10052,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongTwoSteps", opacity = 0x00, index = 2, 
				array = {propId = 10052}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName1 = "guide_dialogue_10052_step1",
				panelName2 = "guide_dialogue_10052_step2",
			},
		},
		disappear = {}
	},

	[5000101041] = {--章鱼冰 弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly,  GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kOctopusForbid , GamePropsType.kOctopusForbid_l } },
			{type = "hasPropInBar" , para = 10052 },
			{type = "notLevelOrder" , para = {[0] = {key1=4,key2=3}} },--to do
			{type = "numMoveLeft", para = {9,1}},
			{type = "hasVenom", para = 11},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10052, type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10052, type='weak'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10052"
			},
		},
		disappear = {}
	},

	[5000101042] = {--章鱼冰 弱引导 附加
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall ,  GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kOctopusForbid , GamePropsType.kOctopusForbid_l } },
			{type = "hasPropInBar" , para = 10052 },
			{type = "notLevelOrder" , para = {[0] = {key1=4,key2=3}} },--to do
			{type = "numMoveLeft", para = {9,1}},
			{type = "hasVenom", para = 11},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10052, type='extra'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10052, type='extra'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10052"
			},
		},
		disappear = {}
	},

	--------------------------------------------------------------------------------------------------------------------------------

	[500010105] = { -- 后退一步 强引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "onceOnly"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minNumMoves", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "hasPropInBar" , para = 10002 },
			{type = "numMoveLeft", para = {6,2}},
			{type = "levelOrder" , para = {[0] = {key1=4,key2=3}} },
			{type = "venomTooLess" , para = 0},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10002,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongBack", opacity = 0x00, index = 2, 
				array = {propId = 10002}, 
				highlightTarget = {"order4" , 3},
				needBlockTouch = false ,
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winYU", panPosY = 60, 
				panHorizonAlign = "winX" , panPosX = -90,
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName1 = "guide_dialogue_10002_step1",
				panelName2 = "guide_dialogue_10002_step2",
				-- panelName = "guide_dialogue_trigger_4",
			},
		},
		disappear = {}
	},

	[500010106] = {--后退一步 弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minNumMoves", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kBack , GamePropsType.kBack_b ,GamePropsType.kBack_l } },
			{type = "hasPropInBar" , para = 10002 },
			{type = "numMoveLeft", para = {4,1}},
			{type = "levelOrder" , para = {[0] = {key1=4,key2=3}} },
			{type = "venomTooLess" , para = 0},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10002, type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10002, type='weak'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10002"
			},
		},
		disappear = {}
	},

	[5000101061] = {--后退一步 弱引导 附加
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kMoleWeekly, GameLevelType.kTaskForUnlockArea, GameLevelType.kSummerWeekly , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "notTimeLevel", para = 1},
			{type = "minNumMoves", para = 1},
			{type = "minCurrLevel", para = 31},
			{type = "notUseProp" , para = {GamePropsType.kBack , GamePropsType.kBack_b ,GamePropsType.kBack_l } },
			{type = "hasPropInBar" , para = 10002 },
			{type = "numMoveLeft", para = {4,1}},
			{type = "levelOrder" , para = {[0] = {key1=4,key2=3}} },
			{type = "venomTooLess" , para = 0},
			{type = "hasNoOtherGuide"},
			{type = "IngamePropGuideManager", para = {propId=10002, type='extra'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10002, type='extra'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10002"
			},
		},
		disappear = {}
	},

-------------------------------------------周赛道具-----------------------------------------------------
	--[[
	[500010107] = {--魔力鸟 强引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "gameModeType", para = {GameModeTypeId.MAYDAY_ENDLESS_ID}},
			{type = "minNumMoves", para = 1},
			{type = "notTimeLevel", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kRandomBird} },
			{type = "hasPropInBar" , para = 10055 },
			{type = "hasNoSpecialAnimal", para =  0},
			{type = "hasNoOtherGuide"},
			{type = "notSpringItemGuide"},
			{type = "IngamePropGuideManager", para = {propId=10055,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongTwoSteps", opacity = 0x00, index = 2, 
				array = {propId = 10055}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName1 = "guide_dialogue_10055_step1",
				panelName2 = "guide_dialogue_10055_step2",
			},
		},
		disappear = {}
	},

	[5000101071] = {--魔力鸟 弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea , GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "gameModeType", para = {GameModeTypeId.MAYDAY_ENDLESS_ID}},
			{type = "minNumMoves", para = 1},
			{type = "notTimeLevel", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kRandomBird} },
			{type = "hasPropInBar" , para = 10055 },
			{type = "hasNoSpecialAnimal", para =  0},
			{type = "hasNoOtherGuide"},
			{type = "notSpringItemGuide"},
			{type = "IngamePropGuideManager", para = {propId=10055,type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10055}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10055"
			},
		},
		disappear = {}
	},]]

	--------------------------------------------------------------------------------------------------------------------------------

	[500010108] = {--扫把 强引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea ,GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "gameModeType", para = {GameModeTypeId.MAYDAY_ENDLESS_ID}},
			{type = "minNumMoves", para = 1},
			{type = "notTimeLevel", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kBroom ,GamePropsType.kBroom_l } },
			{type = "hasPropInBar" , para = 10056 },
			{type = "numMoveLeft", para = {5,1}},
			{type = "bossBlood", para = {6 , 10}},
			{type = "hasNoOtherGuide"},
			{type = "notSpringItemGuide"},
			{type = "IngamePropGuideManager", para = {propId=10056,type='strong'}},
		},
		action = {

			[1] = {type = "guidePropStrongBroom", opacity = 0x00, index = 2, 
				array = {propId = 10056}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName1 = "guide_dialogue_10056_step1",
				panelName2 = "guide_dialogue_10056_step2",
				panelName3 = "guide_dialogue_10056_step3",
			},
		},
		disappear = {}
	},
	[5000101081] = {--扫把 弱引导
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "onceLevel"},
			{type = "firstGuideOnLevel"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "notGameLevelType" , para = {GameLevelType.kTaskForRecall , GameLevelType.kTaskForUnlockArea ,GameLevelType.kOlympicEndless, GameLevelType.kMidAutumn2018, GameLevelType.kSpring2017}},
			{type = "gameModeType", para = {GameModeTypeId.MAYDAY_ENDLESS_ID}},
			{type = "minNumMoves", para = 1},
			{type = "notTimeLevel", para = 1},
			{type = "notUseProp" , para = {GamePropsType.kBroom ,GamePropsType.kBroom_l } },
			{type = "hasPropInBar" , para = 10056 },
			{type = "numMoveLeft", para = {5,1}},
			{type = "bossBlood", para = {6 , 10}},
			{type = "hasNoOtherGuide"},
			{type = "notSpringItemGuide"},
			{type = "IngamePropGuideManager", para = {propId=10056, type='weak'}},
		},
		action = {

			[1] = {type = "guidePropBarWeak", opacity = 0x00, index = 2, 
				array = {propId = 10056, type='weak'}, 
				text = "tutorial.game.text1901", multRadius = 1.3,
				panType = "down", 
				panAlign = "winY", panPosY = 400, 
				maskDelay = 0.3,maskFade = 0.4 ,panDelay = 1 , touchDelay = 1.1,
				panelName = "guide_dialogue_trigger_10056",
			},
		},
		disappear = {}
	},

--	--成就引导
--	[5100000001] = {
--		appear = {
--			{type = "scene", scene = "worldMap"},
--			{type = "userLevelGreatThan", para = 59},
--			{type = "noPopup"},
--			{type = "checkAutoPopout", para = "AchieveGuideAction"},
--			{type = "checkGuideFlag", para = kGuideFlags.ACHIEVE},
--		},
--		action = { 
--			[1] = {type = "showAchieve", opacity = 0xCC, touchDelay = 1, panelName = 'guide_dialogue_achievement_1', panDelay = 0},
--		},
--		disappear = {
--			{type = 'popup'}
--		}
--	},


    ------------------地鼠周赛 水塘出现
    --BOSS出现
	[310000001] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
			{type = "hasNoOtherGuide"},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_BossShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_6",
			},
            [2] = {type = "GuidePropBarMoleWeek_WaterBoxShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_2",
			},
		},
		disappear = {}
	},

--    --水塘出现
--	[310000002] = {
--		appear = {
--			{type = "scene", scene = "game"},
--			{type = "staticBoard"},
--			{type = "noPopup"},
--            {type = "onceOnly"},
--			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
--			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
--			{type = "hasNoOtherGuide"},
--            {type = "CheckIsNotTestScene"},
--            {type = "CheckSceneIsHaveBoardView"},
--            {type = "CheckIsHaveMoleWeekWaterBox"},
--		},
--		action = { 
--            [1] = {type = "GuidePropBarMoleWeek_WaterBoxShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
--                panDelay = 1,
--				panelName = "guide_mole_weekly_race_2",
--			},
--		},
--		disappear = {}
--	},

    --boss死亡后没复活
	[310000003] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsBossNotAlive"},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_BossNotAliveShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_5",
			},
		},
		disappear = {}
	},

    --寻找新水塘
	[310000004] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsNotHaveMoleWeekWaterBox"},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_FindNewWaterBoxShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_1",
			},
		},
		disappear = {}
	},
	
    --小地鼠引导
	[310000005] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsBossLifeReinit"},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_BossReLifeShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_4",
			},
		},
		disappear = {}
	},

    --大招充能
	[310000006] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckSceneIsHaveBoss"},
            {type = "CheckIsBigSkillFull"},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_BigSkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_3",
			},
		},
		disappear = {}
	},

    --毛球出现
	[310000007] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSkillShow", para = MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL },
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_SkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_11",
                itemWidth = 1, itemHeight = 1, SkillType = MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL,
                guideWidth = 290,
			},
		},
		disappear = {}
	},

    --大草地出现
	[310000008] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSkillShow", para = MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_SkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_9",
                itemWidth = 2, itemHeight = 2, SkillType = MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK,
                guideWidth = 300,
			},
		},
		disappear = {}
	},

    --蜂蜜出现
	[310000009] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSkillShow", para = MoleWeeklyBossSkillType.THICK_HONEY },
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_SkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_10",
                itemWidth = 1, itemHeight = 1, SkillType = MoleWeeklyBossSkillType.THICK_HONEY,
                guideWidth = 300,
			},
		},
		disappear = {}
	},

    --石块出现
	[310000010] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSkillShow", para = MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE },
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_SkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_7",
                itemWidth = 1, itemHeight = 1, SkillType = MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE,
                guideWidth = 294,
			},
		},
		disappear = {}
	},

    --草袋出现
	[310000011] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSkillShow", para = MoleWeeklyBossSkillType.SEED },
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_SkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_8",
                itemWidth = 1, itemHeight = 1, SkillType = MoleWeeklyBossSkillType.SEED,
                guideWidth = 298,
			},
		},
		disappear = {}
	},

    --首次+5步引导
	[310000012] = {
		appear = {
			{type = "scene", scene = "game"},
            {type = "onceOnly"},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckSceneIsHaveBoss"},
            {type = "CheckSceneIsInMoleWeekAddFilePanel"},
            {type = "checkGuideFlag", para = kGuideFlags.MoleWeekAdd5Step},
		},
		action = { 
            [1] = {type = "GuideMoleWeek_addStep", opacity = 0x00, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_12",
			},
		},
		disappear = {}
	},

    --使用大招得气球
	[310000013] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSkillShow", para =  GamePropsType.kMoleWeeklyRaceSPProp },
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_SkillShow", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
                panDelay = 1,
				panelName = "guide_mole_weekly_race_13",
                itemWidth = 1, itemHeight = 1, SkillType = GamePropsType.kMoleWeeklyRaceSPProp,
                guideWidth = 294,
			},
		},
		disappear = {}
	},

    --大招购买
	[310000014] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
--            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
			{type = "gameModeType", para = {GameModeTypeId.MOLE_WEEKLY_RACE_ID}},
			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = 'waitSignal', name = 'firstBuyMoleWeekFirework', value = true},
		},
		action = { 
            [1] = {type = "GuidePropBarMoleWeek_BigSkillBuyShow",text = "tutorial.game.text503",
				reverse = true ,animPosY = 0, panOrigin = ccp(-550,1301),panFinal = ccp(120,1301), animScale = 0.7,
				animDelay = 0.8, panDelay = 1.2 ,
				panelName = "guide_dialogue_rank_race_buy",
			}
		},
		disappear = {}
	},

    --春节大招引导
	[2019010601] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "popup", popup = "SpringFestival2019SkillPanel"},
            {type = "onceOnly"},
			{type = "notGamePlayStatus" , para = {GamePlayStatus.kEnd , GamePlayStatus.kBonus , GamePlayStatus.kAferBonus}},
--			{type = "hasNoOtherGuide"},
            {type = "CheckIsNotTestScene"},
            {type = "CheckSceneIsHaveBoardView"},
            {type = "CheckIsSpringFestival2019OpenAndSkillShow"},
		},
		action = { 
            [1] = {type = "GuideSpringFestival2019UseSkill",text = "tutorial.game.text503",
				reverse = true ,animPosY = 0, panOrigin = ccp(-630,1301),panFinal = ccp(120,1301), animScale = 0.7,
				animDelay = 0.8, panDelay = 0.1 ,
				panelName = "guide_springFestival2019_skill",
			},
            [2] = {type = "GuideSpringFestival2019UseSkill",text = "tutorial.game.text503",
				reverse = true ,animPosY = 0, panOrigin = ccp(-630,1301),panFinal = ccp(120,1301), animScale = 0.7,
				animDelay = 0.8, panDelay = 0.1 ,
				panelName = "guide_springFestival2019_skill2",
			}
		},
		disappear = {}
	},

	-- -----------------------------------------------------------------------------------------------------------------------------
	--]]

--     --社区引导
--	[20180612] = {
--		appear = {
--			{type = "scene", scene = "worldMap"},
--            {type = "onceOnly"},
--			{type = "hasNoOtherGuide"},
--			{type = "userLevelGreatThan", para = 100},
--            {type = "CheckCanShowFAQ"},
--            {type = "CheckSettingBtnIsCreate"},
--            {type = "CheckIsNotYYB"},
--            {type = "checkAutoPopout", para = "SheQuGuidePopoutAction"},
--            {type = "checkGuideFlag", para = kGuideFlags.SheQuGuide},

--		},
--		action = { 
--            [1] = {type = "GuideSheQu", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
--                panDelay = 1,
--				panelName = "guide_shequ",
--			},
--		},
--		disappear = {}
--	},

--     --社区引导2 yyb
--	[20180613] = {
--		appear = {
--			{type = "scene", scene = "worldMap"},
--            {type = "onceOnly"},
--			{type = "hasNoOtherGuide"},
--			{type = "userLevelGreatThan", para = 100},
--            {type = "CheckCanShowFAQ"},
--            {type = "CheckSettingBtnIsCreate"},
--            {type = "CheckIsYYB"},
--            {type = "checkAutoPopout", para = "SheQuGuidePopoutAction"},
--            {type = "checkGuideFlag", para = kGuideFlags.SheQuGuide},

--		},
--		action = { 
--            [1] = {type = "GuideSheQu", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 1.1,
--                panDelay = 1,
--				panelName = "guide_shequ2",
--			},
--		},
--		disappear = {}
--	},

	 --社区留言引导 好友面板的个人中心 
	[20181109] = {
		appear = {
			{type = "popup", popup = "friendsPanel"},
			{type = "scene", scene = "friendsCenterScene"},
            {type = "onceOnly"},
			{type = "hasNoOtherGuide"},
            -- {type = "CheckCanShowFAQ"},
            -- {type = "CheckSettingBtnIsCreate"},
            -- {type = "CheckIsNotYYB"},
		},
		action = { 
            [1] = {type = "GuideFriendSheQuCenter", opacity = 0xCC, maskDelay = 0.3,maskFade = 0.4 , touchDelay = 0.5,
                panDelay = 0,
				panelName = "guide_dialogue_friend_faq",
			},
		},
		disappear = {}
	},


	-- [20181022] = {
	-- 	appear = {
	-- 		{type = "popup", popup = "AskForEnergyPanel", strictMode = true},
	-- 		{type = "scene", scene = "worldMap"},
			
	-- 		{type = "checkGuideFlag", para = kGuideFlags.EnergyACT},
	-- 		{type = "customCheck", func = function ( ... )
	-- 			require "zoo.panel.AskForEnergyPanel"
	-- 			return AskForEnergyPanel.isEnergyACTEnabled()
	-- 		end},
	-- 	},
	-- 	action = {
	-- 		[1] = {
	-- 			type = "gudieAnim", 
	-- 			anchorNodePath = 'ui/energyACT',
	-- 			offset = ccp(0, 50),
	-- 			skeletonRes = 'skeleton/energy_act_guide',
	-- 			armatureName = 'energy_act_guide/anim',
	-- 			radius = 2,
	-- 			handler = function ( ... )
	-- 				require "zoo.panel.AskForEnergyPanel"
	-- 				AskForEnergyPanel.openEnergyACT()
	-- 			end,
	-- 		},
	-- 	},
	-- 	disappear = {
	-- 		{type = "popdown", popdown = "AskForEnergyPanel"},
	-- 		{type = "popup"},
	-- 		{type = "noPopup"},
	-- 	}
	-- },

	[201901301132] = {
		appear = {
			{type = "scene", scene = "game"},
			{type = "staticBoard"},
			{type = "noPopup"},
			{type = "checkSpeedBtn", guide1 = kGuideFlags.SpeedBtn_1, guide2 = kGuideFlags.SpeedBtn_2},
		},
		action = {
            [1] = {
            	type = "clickPause",text = "tutorial.game.text503",
            	opacity = 0xCC, maskDelay = 0.3,
				panAlign = "matrixU", panPosY = 3, 
				handDelay = 1.2 , panDelay = 0.8,
				panelName = "guide_dialogue_190130_1",
			}
		},
		disappear = {}
	},
	[201901301442] = {
		appear = {
			{type = "popup", popup = "QuitPanel"},
			{type = "scene", scene = "game"},
			{type = "checkSpeedBtn"},
		},
		action = {
            [1] = {
            	type = "showSpeedBtn",text = "tutorial.game.text503",
            	opacity = 0xCC, maskDelay = 0.3,
				handDelay = 1.2 , panDelay = 0.8,
				multRadius = 1.4,
				panelName = "guide_dialogue_190130_2",
			}
		},
		disappear = {}
	},
}




-- local tmpMap = {}
-- for _, v in pairs(Guides) do
-- 	for _, v2 in pairs(v.appear) do
-- 		if v2.type == "scene" and v2.scene=="game" then
-- 			if type(v2.para) == "table" then
-- 				for _, id in pairs(v2.para) do
-- 					tmpMap[tostring(id)] = true
-- 				end
-- 			else
-- 				tmpMap[tostring(v2.para)] = true
-- 			end
-- 		end
-- 	end
-- end

-- local levelIds = {}
-- for levelId, _ in  pairs(tmpMap) do
-- 	table.insert(levelIds, tonumber(levelId))
-- end
-- table.sort(levelIds)
-- mylog(table.concat(levelIds, ","))

GuideSeeds = table.const
{
	[1] = 1389943462,
	[2] = 1394088236,
	[3] = 1395992355,
	[4] = 1394096931,
	[5] = 1395993581,
	[6] = 1396066208,
	[8] = 1388138716,
	[12] = 1394099839,
	[13] = 1394099838,
	[21] = 1394099837,
	[23] = 1469519181,
	[121]=1440413286,
	[136] = 1395387867,
	[211] = 1441522423,
	[271] = 1441520945,
	[276] = 1467639344,
	[331] = 1440928205,
	[436] = 1517826378,
	[466] = 1440933409,
	[467] = 1440679879,
	[631] = 1440677804,
	[30] = 1440761545,
	[260001] = 1442306154,
	[167] = 1444733242,
	[260014] = 1448520404,
	[676] = 1451023816,
	[270001] = 1454309081,
	[260101] = 1462779018,
	[280000] = 1470302280,
	[871] = 1472104216,
	[976] =1479206647,
	[290002] = 1479206648,
	[280101] = 1484221773,
	[280401] = 1484221773,
	[290101] = 1484221999,
	[1036] = 1517830381,
	[280201] = 1484211191,
	[1096] = 1484211932,
	[1156] = 520315,
	[1216] = 2341511,
	[1276] = 4358759,
	[1486] = 3962759,

	[1336] = 1512552127,	
	[1396] = 490684,
	[280301] = 1484321591,
	[290501] = 1459284381,
	[1576] = 156544656,
	[1666] = 156544556,
	[1756] = 1112225219,
	[1846] = 1162326239,
	[1936] = 1162326239,
	[2056] = 1162326239,
}

if _G.isPlayDemo then
	Guides = {}
	GuideSeeds = {}
end