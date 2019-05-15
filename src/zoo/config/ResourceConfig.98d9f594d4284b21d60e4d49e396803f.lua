require "zoo.config.GamePlayResourceConfig"

ResourceConfig = {
	plist={
		-- "flash/bear.plist", 	
		-- "flash/fox.plist", 		
		-- "flash/horse.plist", 	
		-- "flash/frog.plist", 	
		-- "flash/cat.plist", 		
		-- "flash/chicken.plist", 	
		-- "flash/bird.plist", 	
		-- "flash/bird_ext.plist",
		-- "flash/game_props.plist",
		-- "flash/TileEffect.plist",
		-- "flash/mapTiles.plist",
		-- "flash/explode.plist",
		-- "flash/mapBaseItem.plist",
		-- "flash/destroy_effect.plist",		

		"materials/trunk.plist",
		"materials/trunkRoot.plist",
		"materials/trunkRootBackCloud.plist",

		-- "materials/home_color.plist",
		-- "materials/fruitTree.plist",
		
		-- "flash/scenes/homeScene/lockedCloud.plist",
		"flash/scenes/flowers/home_effects.plist",
		-- "flash/scenes/flowers/title_text.plist",
		"flash/scenes/flowers/branch_mask.plist",
		"flash/scenes/flowers/branch.plist",
		"flash/scenes/flowers/flower_effects.plist",
		"flash/scenes/flowers/target_icon.plist",

		"flash/gameguide/guidespanImage.plist",
		"flash/ladybug.plist",
		"flash/bonus_effects.plist",

		"flash/tile_select.plist",
		"flash/board_effects.plist",
		"materials/game_bg.plist",
		"flash/bird_effects.plist",
	},

	asyncPlist={
		-- GamePlayScene
		"flash/bear.plist", 	
		"flash/fox.plist", 		
		"flash/horse.plist", 	
		"flash/frog.plist", 	
		"flash/cat.plist", 		
		"flash/chicken.plist", 	
		"flash/bird.plist", 	
		"flash/game_props.plist",
		"flash/TileEffect.plist",
		"flash/mapTiles.plist",
		"flash/explode.plist",
		"flash/mapBaseItem.plist",
		-- "flash/tile_select.plist",
		-- "flash/board_effects.plist",
		-- "flash/bird_effects.plist",
		
		-- "materials/game_bg.plist",
		-- "materials/game_bg_activity.plist",
		-- "materials/game_bg_weekly.plist",
		
		-- FruitScene
		-- "materials/fruitTree.plist",
		
		"flash/props_effects.plist",
		"flash/props_stars.plist",

	},
	
	json={
		"flash/scenes/homeScene/home.json",		
		"flash/gameguide/guideelem.json",
		"flash/scenes/flowers/ladybug.json",
		"flash/scenes/flowers/target_helper.json",
		"ui/common_ui.json",
		"flash/gameguide/game_guide_common_ui.json",
		"ui/panel_game_start.json",
		"ui/achi_icons.json",
		"flash/common/properties.json",
		"flash/scenes/homeScene/homeScene.json",
		"flash/scenes/homeScene/home_icon.json",
		"flash/scenes/homeScene/gameMisc.json",
		"flash/scenes/homeScene/icons/home_scene_icon_top.json",
		"flash/scenes/homeScene/icons/home_scene_icon.json",
        "flash/scenes/homeScene/CollectMisc.json",
		"flash/scenes/gamePlaySceneUI/gamePlaySceneUI.json",


		"flash/gameguide/game_guide_panels.json",
		"flash/gameguide/game_guide_panels_2.json",
		"flash/gameguide/game_guide_panels_3.json",
		"flash/gameguide/game_guide_panels_4.json",
		"flash/gameguide/game_guide_panels_act.json",
		"flash/gameguide/game_guide_prop.json",
		'flash/scenes/homeScene/constellations.json',
		-- 'flash/scenes/homeScene/specialClouds.json',
		'flash/scenes/homeScene/lockedCloud.json',
		'flash/quick_select_level.json',
		-- 'flash/common_sprite.json',

		"flash/head_frames.json",

	},
	skeleton={
		"skeleton/energy_animation",
		--"skeleton/raccoon_animation",
		"skeleton/add_five_step_animation",
		"skeleton/game_play_text_effects",
		"skeleton/commonEffAnimation",
		"skeleton/home_top_bar_s_ani",
	},
	image={

	},

	sfx_for_low_device={
		"music/sound.contnuousMatch.3.mp3",
		"music/sound.contnuousMatch.5.mp3",
		"music/sound.contnuousMatch.7.mp3",
		"music/sound.contnuousMatch.9.mp3",
		"music/sound.contnuousMatch.11.mp3",
		"music/sound.DeadlineStep.mp3",
		"music/sound.Drop.mp3",
		"music/sound.create.color.mp3",
		"music/sound.create.strip.mp3",
		"music/sound.create.wrap.mp3",
		"music/sound.eliminate.color.mp3",
		"music/sound.eliminate.strip.mp3",
		"music/sound.eliminate.wrap.mp3",
		"music/sound.EliminateTip.mp3",
		"music/sound.frosint.break.mp3",
		"music/sound.ice.break.mp3",
		"music/sound.Keyboard.mp3",
		"music/sound.PopupClose.mp3",
		"music/sound.PopupOpen.mp3",
		"music/sound.clipStar.mp3",
		"music/sound.star.light.mp3",
		"music/sound.Swap.mp3",
		"music/sound.SwapFun.mp3",
		"music/sound.bonus.time.mp3",
	},

	sfx={
	----[[
		"music/sound.DeadlineStep.mp3",
		"music/sound.Drop.mp3",
		"music/sound.create.color.mp3",
		"music/sound.create.strip.mp3",
		"music/sound.create.wrap.mp3",
		"music/sound.eliminate.color.mp3",
		"music/sound.eliminate.strip.mp3",
		"music/sound.eliminate.wrap.mp3",
		"music/sound.EliminateTip.mp3",
		"music/sound.frosint.break.mp3",
		"music/sound.ice.break.mp3",
		"music/sound.Keyboard.mp3",
		"music/sound.PopupClose.mp3",
		"music/sound.PopupOpen.mp3",
		"music/sound.clipStar.mp3",
		"music/sound.star.light.mp3",
		"music/sound.Swap.mp3",
		"music/sound.SwapFun.mp3",
		"music/sound.bonus.time.mp3",
		"music/sound.swap.colorcolor.swap.mp3",
		"music/sound.swap.colorcolor.cleanAll.mp3",
		"music/sound.swap.colorline.mp3",
		"music/sound.swap.lineline.mp3",
		"music/sound.swap.wrapline.mp3",
		"music/sound.swap.wrapwrap.mp3",

		"music/sound.contnuousMatch.3.mp3",
		"music/sound.contnuousMatch.5.mp3",
		"music/sound.contnuousMatch.7.mp3",
		"music/sound.contnuousMatch.9.mp3",
		"music/sound.contnuousMatch.11.mp3",

		"music/sound.Eliminate1.mp3",
		"music/sound.Eliminate2.mp3",
		"music/sound.Eliminate3.mp3",
		"music/sound.Eliminate4.mp3",
		"music/sound.Eliminate5.mp3",
		"music/sound.Eliminate6.mp3",
		"music/sound.Eliminate7.mp3",
		"music/sound.Eliminate8.mp3",
		"music/sound.roost0.mp3",
		"music/sound.roost1.mp3",
		"music/sound.roost2.mp3",
		"music/sound.roost3.mp3",
		"music/sound.balloon.break.mp3",
		"music/sound.balloon.runaway.mp3",
		"music/sound.tileBlocker.turn.mp3",
		"music/sound.fireworks.mp3",
		"music/sound.weekly.boss.hit.mp3",
		"music/sound.weekly.boss.cast.mp3",
		"music/sound.weekly.race.prop.mp3",
		"music/sound.weekly.boss.die.mp3",
		"music/sound.hedgehogbox.open.mp3",
		"music/sound.hedgehog.crazy.mp3",
		"music/sound.hedgehog.crazymove.mp3",

		--[[春节相关音效 用于1.30版本 之后版本可删
		"music/sound.spring_firework1.mp3",
		"music/sound.spring_firework2.mp3",
		"music/sound.spring_firework3.mp3",
		"music/sound.spring_firework4.mp3",
		"music/sound.spring_firework5.mp3",
		"music/sound.wukong.casting.mp3",
		--]]

		"music/sound.play.bear.save.mp3",
		"music/sound.play.blackcute.dizziness1.mp3",
		"music/sound.play.browncute.split.mp3",
		"music/sound.play.bottle.casting.mp3",
		"music/sound.play.bottle.match.mp3",
		"music/sound.play.cloud.clear1.mp3",
		"music/sound.play.cloud.collect1.mp3",
		"music/sound.play.coin1.mp3",
		"music/sound.play.crystal.active.mp3",
		"music/sound.play.crystal.casting.mp3",
		"music/sound.play.cute.jump1.mp3",
		"music/sound.play.graycute.dead1.mp3",
		"music/sound.play.honey.clear.mp3",
		"music/sound.play.honeybottle.casting.mp3",
		"music/sound.play.honeybottle.match.mp3",
		"music/sound.play.iceblock.break.mp3",
		"music/sound.play.jdj.collect1.mp3",
		"music/sound.play.lamp.casting.mp3",
		"music/sound.play.lamp.match.mp3",
		"music/sound.play.lock.break.mp3",
		"music/sound.play.lotus.clear1.mp3",
		"music/sound.play.lotus.clear2.mp3",
		"music/sound.play.magicstone.active.mp3",
		"music/sound.play.magicstone.casting.mp3",
		"music/sound.play.mimosa.grow.mp3",
		"music/sound.play.mimosa.onhit.mp3",
		"music/sound.play.monster.breakice.mp3",
		"music/sound.play.movetile.move.mp3",
		"music/sound.play.octopus.produce.mp3",
		"music/sound.play.penguin.save.mp3",
		"music/sound.play.poison.clear1.mp3",
		"music/sound.play.poster.save.mp3",
		-- "music/sound.play.elk.save.mp3",
		"music/sound.play.puffer.active.mp3",
		"music/sound.play.puffer.casting.mp3",
		"music/sound.play.rokect.launch.mp3",
		"music/sound.play.sand.move.mp3",
		"music/sound.play.snail.move.mp3",
		"music/sound.play.snail.out.mp3",
		"music/sound.play.snail.stop.mp3",
		"music/sound.play.totems.active.mp3",
		"music/sound.play.totems.casting.mp3",
		"music/sound.play.transmission.move.mp3",
		"music/sound.play.ufo.collect_jdj1.mp3",
		"music/sound.play.ufo.down.mp3",
		"music/sound.play.ufo.in.mp3",
		"music/sound.play.ufo.down.mp3",
		"music/sound.play.ufo.onhit.mp3",
		"music/sound.play.ufo.wakeup.mp3",
		"music/sound.play.ufo.win.mp3",
		"music/sound.play.whitecute.hide1.mp3",
		"music/sound.play.whitecute.show1.mp3",
		"music/sound.play.add5step.flyon.mp3",
		"music/sound.play.add5step.end.mp3",
		"music/sound.play.add5step.start.mp3",
		"music/sound.prop.add5step.flyon.mp3",
		"music/sound.prop.add3step.flyon.mp3",
		"music/sound.prop.back.mp3",
		"music/sound.prop.magicwand.mp3",
		"music/sound.prop.octopus.mp3",
		"music/sound.prop.swap.mp3",
		"music/sound.prop.lineEffect.mp3",

--地鼠周赛音效
		"music/sound.moleweek_bigskill1.mp3",
		"music/sound.moleweek_bossDie1.mp3",
		"music/sound.moleweek_bossEnough1.mp3",
		"music/sound.moleweek_bossIn1.mp3",
		"music/sound.moleweek_bossUseSkill1.mp3",

        "music/sound.moleweek_bigskill2.mp3",
		"music/sound.moleweek_bossDie2.mp3",
		"music/sound.moleweek_bossEnough2.mp3",
		"music/sound.moleweek_bossIn2.mp3",
		"music/sound.moleweek_bossUseSkill2.mp3",

        "music/sound.moleweek_bigskill3.mp3",
		"music/sound.moleweek_bossDie3.mp3",
		"music/sound.moleweek_bossEnough3.mp3",
		"music/sound.moleweek_bossIn3.mp3",
		"music/sound.moleweek_bossUseSkill3.mp3",

        "music/sound.moleweek_bigskill4.mp3",
		"music/sound.moleweek_bossDie4.mp3",
		"music/sound.moleweek_bossEnough4.mp3",
		"music/sound.moleweek_bossIn4.mp3",
		"music/sound.moleweek_bossUseSkill4.mp3",

		"music/sound.play.ghost.appear.mp3",
		"music/sound.play.ghost.disappear.mp3",
		"music/sound.play.ghost.move.mp3",

		"music/sound.play.sunbottle.match.mp3",
		"music/sound.play.sunbottle.clear.mp3",
		"music/sound.play.sun.clear.mp3",

		-- 1.41春节关卡音效
		--[[
		"music/sound.spring2017.appear.mp3",
		"music/sound.spring2017.cast.mp3",
		"music/sound.spring2017.hit.mp3",
		]]

		--"music/sound.swap.colorline.mp3",
		--"music/sound.test1.mp3"
		-- "music/sound.spring_firework_triple.mp3",

	},
	mp3={
		"music/sound.WorldSceneBGM.mp3",
		
		--春节相关音效 用于1.30版本 之后版本可删
		--"music/sound.spring_bg_music.mp3",
	}
}


require 'zoo.config.PixelFormatConfig'
require 'zoo.config.TextureSceneConfig' 

PanelConfigFiles = {}
PanelConfigFiles.common_ui = "ui/common_ui.json"
PanelConfigFiles.game_guide_common_ui = "flash/gameguide/game_guide_common_ui.json"
PanelConfigFiles.panel_game_setting = "ui/panel_game_setting.json"
PanelConfigFiles.panel_with_keypad = "ui/panel_with_keypad.json"
PanelConfigFiles.BeginnerPanel = "ui/BeginnerPanel.json"
PanelConfigFiles.AskForEnergyPanel = "ui/AskForEnergyPanel.json"
PanelConfigFiles.bag_panel_ui = "ui/bag_panel_ui.json"
PanelConfigFiles.friend_ranking_panel = "ui/friend_ranking_panel.json"
PanelConfigFiles.choose_payment_panel = "ui/choose_payment_panel.json"
PanelConfigFiles.star_reward_panel = "ui/star_reward_panel.json"
PanelConfigFiles.lady_bug_panel = "ui/lady_bug_panel.json"
PanelConfigFiles.unlock_cloud_panel_new = "ui/unlock_cloud_panel_new.json"
PanelConfigFiles.invite_friend_reward_panel = "ui/invite_friend_reward_panel.json"
PanelConfigFiles.request_message_panel = "ui/request_message_panel.json"
PanelConfigFiles.panel_buy_prop = "ui/panel_buy_prop.json"
PanelConfigFiles.panel_buy_gold = "ui/panel_buy_gold.json"
PanelConfigFiles.buy_gold_items = "ui/BuyGoldItem.json"
PanelConfigFiles.panel_mark = "ui/panel_mark.json"
PanelConfigFiles.panel_energy_bubble = "ui/panel_energy_bubble.json"
PanelConfigFiles.panel_add_step = "ui/panel_add_step.json"
PanelConfigFiles.wdj_invite_reward_panel = "ui/wdj_invite_reward_panel.json"
PanelConfigFiles.panel_preprop_remind = "ui/panel_preprop_remind.json"
PanelConfigFiles.market_panel = "ui/market_panel.json"
PanelConfigFiles.properties = "flash/common/properties.json"
PanelConfigFiles.unlock_hidden_area_panel = "ui/unlock_hidden_area_panel.json"
PanelConfigFiles.update_new_version_panel = "ui/update_new_version_panel.json"
PanelConfigFiles.fruitTreeScene = "flash/scenes/fruitTreeScene/FruitTreeScene.json"
PanelConfigFiles.panel_fruit_tree = "ui/panel_fruit_tree.json"
PanelConfigFiles.panel_give_back = "ui/panel_give_back.json"
PanelConfigFiles.free_fcash_panel = "ui/free_fcash_panel.json"
PanelConfigFiles.panel_mark_prise = "ui/panel_mark_prise.json"
PanelConfigFiles.panel_game_start = "ui/panel_game_start.json"
PanelConfigFiles.more_star_panel = "ui/more_star_panel.json"
PanelConfigFiles.panel_nick_name = "ui/panel_nick_name.json"
PanelConfigFiles.panel_push_activity = "ui/panel_push_activity.json"
PanelConfigFiles.panel_mark_energy_notionce = "ui/panel_mark_energy_notionce.json"
PanelConfigFiles.panel_turntable = "ui/panel_turntable.json"
PanelConfigFiles.panel_rabbit_weekly_v2 = "ui/panel_rabbit_week_match.json" -- not use anymore since 1.25
PanelConfigFiles.recall_ui = "ui/RecallUI.json"
PanelConfigFiles.panel_ad_video = "ui/AdVideoPanel.json"
PanelConfigFiles.panel_buy_confirm = "ui/panel_buy_confirm.json"
PanelConfigFiles.panel_register = "ui/phone_register_panel.json"
PanelConfigFiles.qr_code_panel = "ui/qr_code_panel.json"
PanelConfigFiles.third_pay_guide_panel = "ui/third_pay_guide_panel.json"
PanelConfigFiles.ios_pay_cartoon_panel = "ui/ios_pay_guide_help.json"
PanelConfigFiles.two_choice_panel = "ui/TwoChoicePanel.json"
PanelConfigFiles.four_star_guid = "ui/four_star_guid.json"
PanelConfigFiles.star_achevement = "ui/star_achievement.json"
PanelConfigFiles.third_pay_show_priority_panel = "ui/third_pay_show_priority_panel.json"
PanelConfigFiles.mark_energy_remind_panel = "ui/MarkEnergyRemindPanel.json"
PanelConfigFiles.coin_info_panel = "ui/coin_info_panel.json"
PanelConfigFiles.mission = "ui/mission_panel.json"
PanelConfigFiles.mission_1 = "ui/mission_panel_1.json"
PanelConfigFiles.mission_2 = "ui/mission_panel_2.json"
PanelConfigFiles.mission_manga = "ui/mission_manga.json"
PanelConfigFiles.mission_bugtips = "ui/mission_bugtips.json"
PanelConfigFiles.mission_rules = "ui/mission_rules.json"
PanelConfigFiles.panel_season_weekly_share = "ui/panel_season_weekly_share.json"
PanelConfigFiles.cd_key_exchange_panel = "ui/cd_key_exchange_panel.json"
PanelConfigFiles.jump_level_panel = "ui/jump_level_panel.json"
PanelConfigFiles.more_ingredient_panel = 'ui/more_ingredient_panel.json'
PanelConfigFiles.personal_center_panel = 'ui/personal_center_panel.json'
PanelConfigFiles.panel_apple_paycode = "ui/panel_apple_paycode.json"
PanelConfigFiles.panel_confirm_buy_full_energy = "ui/panel_confirm_buy_full_energy.json"
PanelConfigFiles.two_years_gift_enegy = "ui/TwoYearsGiftEnegy.json"
PanelConfigFiles.ios_score_guide = "ui/ios_score_guide.json"
PanelConfigFiles.cd_key_confirm_panel = "ui/cd_key_confirm_panel.json"
PanelConfigFiles.wechat_friend_panel = "ui/wechat_friend_pay.json"
PanelConfigFiles.prepackage_update_panel = "ui/prepackage_update_panel.json"
PanelConfigFiles.common_message = "ui/CommonMessage.json"
PanelConfigFiles.login_panels = "ui/login.json"
PanelConfigFiles.incite_panel = "ui/IncitePanel.json"
PanelConfigFiles.home_scene_icon_tip_panel = "ui/HomeSceneIconTipPanel.json"
PanelConfigFiles.oppo_turntable = "ui/oppoLaunch/turntable.json"
PanelConfigFiles.oppo_turntable_desc = "ui/oppoLaunch/desc.json"
PanelConfigFiles.friends_panel = "ui/FriendsPanel.json"