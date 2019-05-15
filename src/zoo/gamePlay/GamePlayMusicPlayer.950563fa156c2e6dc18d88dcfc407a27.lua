require "zoo.loader.AudioFrameLoader"


GamePlayMusicPlayer = class{}

GameMusicType = table.const
{
	kNewStarLevel = "",											-- 分数达到一颗新的星星
	kContinueMatch = "music/sound.contnuousMatch.%d.mp3",		-- 连击
	kDeadlineStep = "music/sound.DeadlineStep.mp3",				-- 仅剩5步时
	kSlide = "music/sound.Drop.mp3",							-- 斜向滑落
	kDrop = "music/sound.Drop.mp3",								-- 落到底部
	kCreateColor = "music/sound.create.color.mp3",				-- 生成魔力鸟
	kCreateLine = "music/sound.create.strip.mp3",				-- 生成直线特效
	kCreateWrap = "music/sound.create.wrap.mp3",				-- 生成区域特效
	kEliminateColor = "music/sound.eliminate.color.mp3",		-- 消除魔力鸟
	kEliminateLine = "music/sound.eliminate.strip.mp3",			-- 消除直线特效
	kEliminateWrap = "music/sound.eliminate.wrap.mp3",			-- 消除区域特效
	kEliminate = "music/sound.Eliminate%d.mp3",					-- 消除Animal
	kEliminateTip = "music/sound.EliminateTip.mp3",				-- 长时间不动的消除提示
	kSnowBreak = "music/sound.frosint.break.mp3",				-- 雪破裂
	kIceBreak = "music/sound.ice.break.mp3",					-- 冰破裂
	kKeyboard = "music/sound.Keyboard.mp3",						-- 动物被选中
	kPopupClose = "music/sound.PopupClose.mp3",					-- 关闭面板
	kPopupOpen = "music/sound.PopupOpen.mp3",					-- 打开面板
	kBtnClick = "sound.clipStar.mp3",							-- 点击开始等硬质按钮
	kBubbleBreak = "sound.clipStar.mp3",						-- 道具泡泡破裂的声音
	kStarOnPanel = "music/sound.star.light.mp3",					-- 星星落在面板上
	kGetNewStar = "sound.clipStar.mp3",							-- 本关获得的这颗星星是新的
	kSwap = "music/sound.Swap.mp3",								-- 交换
	kSwapFun = "music/sound.SwapFun.mp3",						-- 搞笑交换（被绳子挡住）
	kPropWrong = "sound.clipStar.mp3",							-- 道具使用错误（使用位置错误）
	kLineBrush = "sound.clipStar.mp3",							-- 道具直线特效刷子（魔棒）
	kBonusTime = "music/sound.bonus.time.mp3",					-- BonusTime字样
	kXXLBonusTime = "music/sound.kaixinxiaoxiaole.mp3",
	kBonusTimeSteps = "sound.clipStar.mp3",						-- BonusTime光飞到面板上
	kWorldSceneBGM = "music/sound.WorldSceneBGM.mp3",			-- 世界地图背景音乐
	kGameSceneBGM = "music/sound.GameSceneBGM.mp3",				-- 关卡背景音乐
	kSwapColorColorSwap = "music/sound.swap.colorcolor.swap.mp3",
	kSwapColorColorCleanAll = "music/sound.swap.colorcolor.cleanAll.mp3",
	kSwapColorLine = "music/sound.swap.colorline.mp3",
	kSwapLineLine = "music/sound.swap.lineline.mp3",
	kSwapWrapLine = "music/sound.swap.wrapline.mp3",
	kSwapWrapWrap = "music/sound.swap.wrapwrap.mp3",
	kRoostUpgrade = "music/sound.roost%d.mp3",
	kBalloonBreak = "music/sound.balloon.break.mp3",
	kBalloonRunaway = "music/sound.balloon.runaway.mp3",
	kTileBlockerTurn = "music/sound.tileBlocker.turn.mp3",
	kMonsterJumpOut = "music/sound.monster.jumpout.mp3",
	kGetRewardProp = "music/sound.reward.prop.mp3",
	kUseEnergy = "music/sound.use.energy.mp3",
	kGetRewardCoin = "music/sound.reward.coin.mp3",
	kClickBubble = "music/sound.click.bubble.mp3",
	kClickCommonButton = "music/sound.click.common.button.mp3",
	kBonusStepToLine = "music/sound.step.to.line.mp3",
	kAddEnergy = "music/sound.add.energy.mp3",
	kPanelVerticalPopout = "music/sound.panel.vertical.popout.mp3",
	kCoinTick = "music/sound.coin.tick.mp3",
	kFirework = "music/sound.fireworks.mp3",
	kWeeklyBossHit = "music/sound.eliminate.wrap.mp3",
	kWeeklyRaceProp = "music/sound.weekly.race.prop.mp3",
	kWeeklyBossDie = "music/sound.weekly.boss.die.mp3",
	kWeeklyBossCast = "music/sound.weekly.boss.cast.mp3",
	kQiXiBoss = "music/sound.qixiboss.kiss.mp3",
	kHedgehogCrazy = "music/sound.hedgehog.crazy.mp3",
	kHedgehogBoxOpen = "music/sound.hedgehogbox.open.mp3",
	kHedgehogCrazyMove = "music/sound.hedgehog.crazymove.mp3",

	-- kSpringFirework1 = "music/sound.spring_firework1.mp3",
	-- kSpringFirework2 = "music/sound.spring_firework2.mp3",
	-- kSpringFirework3 = "music/sound.spring_firework3.mp3",
	-- kSpringFirework4 = "music/sound.spring_firework4.mp3",
	-- kSpringFirework5 = "music/sound.spring_firework5.mp3",
	kWukongCasting = "music/sound.wukong.casting.mp3",
	kSpringFireworkTriple = "music/sound.spring_firework_triple.mp3",
	-- kSpringBgMusic = "music/sound.spring_bg_music.mp3",


	kHalloweenBeeHit = "music/sound.halloween.boss.hit.mp3",
	kHalloweenBeeDie1 = "music/sound.halloween.boss.cast1.mp3",
	kHalloweenBeeDie2 = "music/sound.halloween.boss.cast2.mp3",

	kPlayBearSave = "music/sound.play.bear.save.mp3",
	kPlayBlackcuteDizziness = "music/sound.play.blackcute.dizziness1.mp3",
	kPlayBlackcuteJump = "music/sound.play.blackcute.jump.mp3",
	kPlayBrowncuteSplit = "music/sound.play.browncute.split.mp3",
	kPlayBottleCasting = "music/sound.play.bottle.casting.mp3",
	kPlayBottleMatch = "music/sound.play.bottle.match.mp3",
	kPlayCloudClear = "music/sound.play.cloud.clear1.mp3",
	kPlayCloudCollect = "music/sound.play.cloud.collect1.mp3",
	kPlayCoinCollect = "music/sound.play.coin1.mp3",
	kPlayCrystalActive = "music/sound.play.crystal.active.mp3",
	kPlayCrystalCasting = "music/sound.play.crystal.casting.mp3",
	kPlayCuteJump = "music/sound.play.cute.jump1.mp3",
	kPlayGraycuteDead = "music/sound.play.graycute.dead1.mp3",
	kPlayHoneyClear = "music/sound.play.honey.clear.mp3",
	kPlayHoneybottleCasting = "music/sound.play.honeybottle.casting.mp3",
	kPlayHoneybottleMatch = "music/sound.play.honeybottle.match.mp3",
	kPlayIceblockBreak = "music/sound.play.iceblock.break.mp3",
	kPlayJdjCollect = "music/sound.play.jdj.collect1.mp3",
	kPlayLampCasting = "music/sound.play.lamp.casting.mp3",
	kPlayLampMatch = "music/sound.play.lamp.match.mp3",
	kPlayLockBreak = "music/sound.play.lock.break.mp3",
	kPlayLotusClear1 = "music/sound.play.lotus.clear1.mp3",
	kPlayLotusClear2 = "music/sound.play.lotus.clear2.mp3",
	kPlayMagicstoneActive= "music/sound.play.magicstone.active.mp3",
	kPlayMagicstoneCasting = "music/sound.play.magicstone.casting.mp3",
	kPlayMimosaGrow = "music/sound.play.mimosa.grow.mp3",
	kPlayMimosaOnhit = "music/sound.play.mimosa.onhit.mp3",
	kPlayMonsterBreakice = "music/sound.play.monster.breakice.mp3",
	kPlayMovetileMove = "music/sound.play.movetile.move.mp3",
	kPlayOctopusProduce = "music/sound.play.octopus.produce.mp3",
	kPlayPenguinSave = "music/sound.play.penguin.save.mp3",
	kPlayPoisonClear = "music/sound.play.poison.clear1.mp3",
	kPlayPosterSave = "music/sound.play.poster.save.mp3",
	-- kPlayElkSave = "music/sound.play.elk.save.mp3",
	kPlayPufferActive = "music/sound.play.puffer.active.mp3",
	kPlayPufferCasting = "music/sound.play.puffer.casting.mp3",
	kPlayPokectLaunch = "music/sound.play.rokect.launch.mp3",
	kPlaySandMove = "music/sound.play.sand.move.mp3",
	kPlaySnailMove = "music/sound.play.snail.move.mp3",
	kPlaySnailOut = "music/sound.play.snail.out.mp3",
	kPlaySnailStop = "music/sound.play.snail.stop.mp3",
	kPlayTotemsActive = "music/sound.play.totems.active.mp3",
	kPlayTotemsCasting = "music/sound.play.totems.casting.mp3",
	kPlayTransmissionMove = "music/sound.play.transmission.move.mp3",
	kPlayUfoCollect_jdj = "music/sound.play.ufo.collect_jdj1.mp3",
	kPlayUfoDown = "music/sound.play.ufo.down.mp3",
	kPlayUfoIn = "music/sound.play.ufo.in.mp3",
	kPlayUfoDown = "music/sound.play.ufo.down.mp3",
	kPlayUfoOnhit = "music/sound.play.ufo.onhit.mp3",
	kPlayUfoWakeup = "music/sound.play.ufo.wakeup.mp3",
	kPlayUfoWin = "music/sound.play.ufo.win.mp3",
	kPlayWhitecuteHide = "music/sound.play.whitecute.hide1.mp3",
	kPlayWhitecuteShow = "music/sound.play.whitecute.show1.mp3",
	kPlayAdd5stepFlyon = "music/sound.play.add5step.flyon.mp3",
	kPlayAdd5stepEnd = "music/sound.play.add5step.end.mp3",
	kPlayAdd5stepStart = "music/sound.play.add5step.start.mp3",
	kPropAdd5stepFlyon = "music/sound.prop.add5step.flyon.mp3",
	kPropAdd3stepFlyon = "music/sound.prop.add3step.flyon.mp3",
	kPropBack = "music/sound.prop.back.mp3",
	kPropMagicwand = "music/sound.prop.magicwand.mp3",
	kPropOctopus = "music/sound.prop.octopus.mp3",
	kPropSwap = "music/sound.prop.swap.mp3",
	kPropLineEffect = "music/sound.prop.lineEffect.mp3",

	kMoleweek_bigskill1 = "music/sound.moleweek_bigskill1.mp3",
	kMoleweek_bossDie1 = "music/sound.moleweek_bossDie1.mp3",
	kMoleweek_bossEnough1 = "music/sound.moleweek_bossEnough1.mp3",
	kMoleweek_bossIn1 = "music/sound.moleweek_bossIn1.mp3",
	kMoleweek_bossUseSkill1 = "music/sound.moleweek_bossUseSkill1.mp3",

    kMoleweek_bigskill2 = "music/sound.moleweek_bigskill2.mp3",
	kMoleweek_bossDie2 = "music/sound.moleweek_bossDie2.mp3",
	kMoleweek_bossEnough2 = "music/sound.moleweek_bossEnough2.mp3",
	kMoleweek_bossIn2 = "music/sound.moleweek_bossIn2.mp3",
	kMoleweek_bossUseSkill2 = "music/sound.moleweek_bossUseSkill2.mp3",

    kMoleweek_bigskill3 = "music/sound.moleweek_bigskill3.mp3",
	kMoleweek_bossDie3 = "music/sound.moleweek_bossDie3.mp3",
	kMoleweek_bossEnough3 = "music/sound.moleweek_bossEnough3.mp3",
	kMoleweek_bossIn3 = "music/sound.moleweek_bossIn3.mp3",
	kMoleweek_bossUseSkill3 = "music/sound.moleweek_bossUseSkill3.mp3",

    kMoleweek_bigskill4 = "music/sound.moleweek_bigskill4.mp3",
	kMoleweek_bossDie4 = "music/sound.moleweek_bossDie4.mp3",
	kMoleweek_bossEnough4 = "music/sound.moleweek_bossEnough4.mp3",
	kMoleweek_bossIn4 = "music/sound.moleweek_bossIn4.mp3",
	kMoleweek_bossUseSkill4 = "music/sound.moleweek_bossUseSkill4.mp3",

	kGhostAppear = "music/sound.play.ghost.appear.mp3",
	kGhostDisappear = "music/sound.play.ghost.disappear.mp3",
	kGhostMove = "music/sound.play.ghost.move.mp3",

	kSunFlaskMatch = "music/sound.play.sunbottle.match.mp3",
	kSunFlaskBreak = "music/sound.play.sunbottle.clear.mp3",
	kSunflowerBlast = "music/sound.play.sun.clear.mp3",

	kGoldFly = "music/sound.gold.fly.mp3",
}

local instance = nil

function GamePlayMusicPlayer:ctor()
	self.IsMusicOpen = not CCUserDefault:sharedUserDefault():getBoolForKey("game.disable.sound.effect")
	self.IsBackgroundMusicOPen = not CCUserDefault:sharedUserDefault():getBoolForKey("game.disable.background.music")
	self.normalBgMusicVolume = SimpleAudioEngine:sharedEngine():getBackgroundMusicVolume()
	self.curBgMusicFile = false
	self.bgMusicDelay = -1
	self.iosVideoPlay = false
	self.isAppPaused = false
end

function GamePlayMusicPlayer:enterBackground()
	if self.IsBackgroundMusicOPen then
		SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
		self:disposeBgMusicDelay()
		--SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
	end

	if self.IsMusicOpen then
		SimpleAudioEngine:sharedEngine():pauseAllEffects()
	end

	self:disposeBgMusicDelay()
end

function GamePlayMusicPlayer:enterForeground()
	if self.isAppPaused then return end

	if self.IsBackgroundMusicOPen then
		if self.curBgMusicFile then
			SimpleAudioEngine:sharedEngine():playBackgroundMusic(self.curBgMusicFile, true)
		end
	end

	if self.IsMusicOpen then
		SimpleAudioEngine:sharedEngine():resumeAllEffects()
	end

	if self.isVideoPlay then
		self:appPause()
	end
end

function GamePlayMusicPlayer:appPause()
	if self.IsBackgroundMusicOPen then
		SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
	end

	if self.IsMusicOpen then
		SimpleAudioEngine:sharedEngine():pauseAllEffects()
	end

	if _G.needCheckMusicCanPlay then
		self.isAppPaused = true
	end
end

function GamePlayMusicPlayer:appResume()
	if self.isVideoPlay then
		return
	end

	self.isAppPaused = false

	if self.IsBackgroundMusicOPen then
		if self.curBgMusicFile then
			local function cb()
				if not self.isAppPaused and self.IsBackgroundMusicOPen and not SimpleAudioEngine:sharedEngine():isBackgroundMusicPlaying() then
					SimpleAudioEngine:sharedEngine():playBackgroundMusic(self.curBgMusicFile, true)
				end
				self:disposeBgMusicDelay()
			end
			if self.iosVideoPlay then 
				self:disposeBgMusicDelay()
			elseif self.bgMusicDelay < 0 then
				self.bgMusicDelay = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(cb, 1, false)
			end
		end
	end

	if self.IsMusicOpen then
		SimpleAudioEngine:sharedEngine():resumeAllEffects()
	end
end

function GamePlayMusicPlayer:disposeBgMusicDelay()
	if self.bgMusicDelay >= 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.bgMusicDelay) 
		self.bgMusicDelay = -1
	end
end

----------------------------------
--播放其他文件为背景音乐
--mp3Path  文件地址
----------------------------------
function GamePlayMusicPlayer:playOtherBgMusic(mp3Path)
    if self.isAppPaused then return end

    if self.curBgMusicFile ~= mp3Path then
        self.curBgMusicFile = mp3Path

        if self.IsBackgroundMusicOPen then
            SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
            SimpleAudioEngine:sharedEngine():playBackgroundMusic(mp3Path, true)
        else
            -- Do Nothing
        end
    end
end

----------------------
-- 临时暂停背景音乐
----------------------
function GamePlayMusicPlayer:tempPauseMusic()
	if self.IsBackgroundMusicOPen then --如果当前在播放背景音乐
        self:pauseBackgroundMusic()
        self.inTempPauseMusic = true
    end
end

---------------------------
--恢复临时停止的背景音乐
---------------------------
function GamePlayMusicPlayer:resumeTempPauseMusic()
	if self.inTempPauseMusic then--如果当前在临时暂停状态
		self.inTempPauseMusic = false
		self:resumeBackgroundMusic()
	end
end

function GamePlayMusicPlayer:pauseBackgroundMusic(...)
	assert(#{...} == 0)

	self.IsBackgroundMusicOPen	= false
	--SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
	SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
	local config = CCUserDefault:sharedUserDefault()
	config:setBoolForKey("game.disable.background.music", true)
	config:flush()

	self:disposeBgMusicDelay()
end

function GamePlayMusicPlayer:resumeBackgroundMusic(...)
	assert(#{...} == 0)
	self.IsBackgroundMusicOPen	= true
	if self.curBgMusicFile then
		--SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(self.normalBgMusicVolume)
		SimpleAudioEngine:sharedEngine():playBackgroundMusic(self.curBgMusicFile, true)
	end
	local config = CCUserDefault:sharedUserDefault()
	config:setBoolForKey("game.disable.background.music", false)
	config:flush()
end

function GamePlayMusicPlayer:startVideoPlay()
	self.isVideoPlay = true
end

function GamePlayMusicPlayer:endVideoPlay()
	self.isVideoPlay = false
end

function GamePlayMusicPlayer:pauseSoundEffects(...)
	assert(#{...} == 0)
	self.IsMusicOpen = false
	local config = CCUserDefault:sharedUserDefault()
	config:setBoolForKey("game.disable.sound.effect", true)
	config:flush()
end

function GamePlayMusicPlayer:resumeSoundEffects(...)
	assert(#{...} == 0)
	self.IsMusicOpen = true
	local config = CCUserDefault:sharedUserDefault()
	config:setBoolForKey("game.disable.sound.effect", false)
	config:flush()

	AudioFrameLoader:startLoadEffect()
end

function GamePlayMusicPlayer:getInstance()
	if instance == nil then
		instance = GamePlayMusicPlayer.new();
	end
	return instance;
end

function GamePlayMusicPlayer:playWorldSceneBgMusic(Volume, ...)
	assert(#{...} == 0)
	if self.isAppPaused then return end

	if self.curBgMusicFile ~= GameMusicType.kWorldSceneBGM then
		self.curBgMusicFile = GameMusicType.kWorldSceneBGM

		if self.IsBackgroundMusicOPen then
			-- Stop Previous Background Music
			SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
			SimpleAudioEngine:sharedEngine():playBackgroundMusic(GameMusicType.kWorldSceneBGM, true)
		else
			-- Do Nothing
		end
	end
end

function GamePlayMusicPlayer:playSpringBgMusic()
	if self.isAppPaused then return end

	if self.curBgMusicFile ~= GameMusicType.kSpringBgMusic then
		self.curBgMusicFile = GameMusicType.kSpringBgMusic

		if self.IsBackgroundMusicOPen then
			-- Stop Previous Background Music
			SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
			SimpleAudioEngine:sharedEngine():playBackgroundMusic(GameMusicType.kSpringBgMusic, true)
		else
			-- Do Nothing
		end
	end
end

function GamePlayMusicPlayer:playGameSceneBgMusic(...)
	assert(#{...} == 0)
	if self.isAppPaused then return end

	self.curBgMusicFile = GameMusicType.kGameSceneBGM

	if self.IsBackgroundMusicOPen then
		-- Stop Previous Background Music
		SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
		SimpleAudioEngine:sharedEngine():playBackgroundMusic(GameMusicType.kGameSceneBGM, true)
	else
		-- Do Nothing
	end
end

function GamePlayMusicPlayer:playEffect(filename, vol)
	--printx( 1 , "    GamePlayMusicPlayer:playEffect  -------------------------  " , filename)
	--printx( 1 , "   " , debug.traceback())
	if filename == "" then 
		return
	end

	local context = self
	local function setEffectLifeDead()
		context.effectLifeCycle[filename] = false
	end
	--printx( 1 , "   GamePlayMusicPlayer:playEffect  111")
	if GamePlayMusicPlayer:getInstance().IsMusicOpen then
		if self.effectLifeCycle == nil then
			self.effectLifeCycle = {}
		end
		
		if self.effectLifeCycle[filename] then
			return
		else
			self.effectLifeCycle[filename] = true
			-- setTimeOut(setEffectLifeDead, GameMusicDuration[filename])
			setTimeOut(setEffectLifeDead, 0.1)
			--printx( 1 , "   GamePlayMusicPlayer:playEffect  222")

			local insideSfxFullList = table.indexOf(ResourceConfig.sfx, filename)
			if(insideSfxFullList) then
				if(SimpleAudioEngine:sharedEngine():isEffectPreloaded(filename)) then
					SimpleAudioEngine:sharedEngine():playEffect(filename)
				end
			else
				SimpleAudioEngine:sharedEngine():playEffect(filename)
			end

		end
	end
end
