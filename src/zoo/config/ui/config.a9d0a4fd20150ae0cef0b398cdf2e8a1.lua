
setConfig
{
	-- Scale The Icon Buttons And Tree In HomeScene
	homeScene_uiScale	= 0.9,
	homeScene_treeScale	= 0.8,
	-- Scale Panel In Different Resolution
	-- Used For StartGamePanel, EnergyPanel, LevelFailPanel ...
	panelScale		= (700 + CCDirector:sharedDirector():getVisibleSize().height) / 1980,
	-- Used, For Example Lady Bug Panel
	panelScalePolicy2	= CCDirector:sharedDirector():getVisibleSize().height / 1280 * 1.2,


	--panelScalePolicy2	= 1,

	scoreProgressBar_scoreTxtLabel_manualAdjustX = 0,
	scoreProgressBar_scoreTxtLabel_manualAdjustY = 0,
	scoreProgressBar_scoreLabel_manualAdjustX	= 0,
	scoreProgressBar_scoreLabel_manualAdjustY	= 0,


	----------------------------------------
	-- Create THe TextField For Buttons Config
	-- --------------------------------------
	textField_showUIAdjustRect	= false,

	
	-- Debug Labels --true
	-- showDebugLabels = false,

	-- Panel
	panelPopRemoveAnim_popOutTime	= 0.4,
	panelPopRemoveAnim_removeTime	= 0.15,
	
	-- Parallax
	worldScene_backgroundParallax		= 0.01869,
	worldScene_cosmosParallax		= 0.14,
	worldScene_backItemParallax		= 1,
	worldScene_cloudLayer1Parallax		= 0.01585,
	worldScene_cloudLayer2Parallax		= 0.09738,
	worldScene_cloudParallax		= 0.19382,
	--worldScene_
	-- Tree Layer Parallax = 1
	worldScene_foregroundParallax		= 1.5,
	worldScene_frontItemParallax		= 1,

	worldScene_cloudsYInterval		= 1800,

	-- WorldScene
	worldScene_velocity			= 3000,
	worldScene_topLevelBelowScreenCenter	= 100,

	-- WorldSceneScroller 
	worldSceneScroller_autoScrollTimerInterval	= 0.16,
	worldSceneScroller_velocitySlowdownRatio	= 0.78,
	worldSceneScroller_velocityThreshold		= 100,

	homeScene_deltaVelocityRatioChangePerTap	= 0.01,

	-- WorldSceneScroller
	worldSceneScroller_fingerVelocityRatio	= 1, -- true_velocity = measured_velocity * this_ratio


	-- android acceleration sensor
	ANDROID_ACCELERATION_THRESHOLD = 2.5,
	IOS_ACCELERATION_THRESHOLD = 1.2,
}
