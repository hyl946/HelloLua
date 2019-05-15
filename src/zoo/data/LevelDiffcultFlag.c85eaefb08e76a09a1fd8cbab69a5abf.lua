_G.LevelDiffcultFlag = {
	kNormal 				= 0,	--正常
	kDiffcult 				= 1,	--难关
	kExceedinglyDifficult 	= 2,	--超难关
}


_G.LvlFlagColor = {
}

---------------------------紫色
--self.bg = self.ui:getChildByName("bg"):getChildByName("bg")
--function LevelSuccessTopPanel:setMainBGColorWithData_Purple(  )
--里面的底板背景 有点发白
_G.LvlFlagColor[1] = { 1 , 0 , -0.125196 ,0.1828137  }
--line:adjustColor( 0.8788 , -0.3532 , -0.067917 , -0.067817) 
-- 3 - 12 一圈藤蔓的颜色
_G.LvlFlagColor[2] = { 0.8788 , -0.3532 , -0.067917 , -0.067817  }
--	line:adjustColor( 0.9 , -0.3532 , -0.067917 , -0.067817)
-- 13 14 上半部分 下面的小叶子
_G.LvlFlagColor[3] = { 0.9 , -0.3532 , -0.067917 , -0.067817 }

--叉子附近 的大叶片颜色
--	self.diffcultadd = self.ui:getChildByName("bg"):getChildByName("diffcultadd")
_G.LvlFlagColor[4] = { 0.8334 , -0.05711 , -0.1478 , -0.08  }

--self._itemScale9Bg:adjustColor( -0.96 , 0 , -0.15 , 0.12769 )
--奖励界面 奖励item下面的小底板的颜色
_G.LvlFlagColor[5] = { -0.96 , 0 , -0.15 , 0.12769  }

--self.jump_level_bg:adjustColor(0.833418 , -0.29595 , -0.20517 , 0.06825 )

_G.LvlFlagColor[6] = {0.833418 , -0.29595 , -0.20517 , 0.06825  }

--self.jump_level_icon:adjustColor(0.8680 , -0.2732 , 0 , 0 )
_G.LvlFlagColor[7] = { 0.8680 , -0.2732 , 0 , 0 }

--	self.friendRankBtn.notTappedBg:adjustColor(0.936 , 0.0228 , -0.0117 ,0.0121 )
--	self.serverRankBtn.notTappedBg:adjustColor(0.936 , 0.0228 , -0.0117 ,0.0121 )
_G.LvlFlagColor[8] = { 0.936 , 0.0228 , -0.0117 ,0.0121  }

--	self.serverRankBtn.tappedBg:adjustColor( 1 , 0 , -0.125196 ,0.1828137 )
--	self.friendRankBtn.tappedBg:adjustColor( 1 , 0 , -0.125196 ,0.1828137 )
_G.LvlFlagColor[9] = { 1 , 0 , -0.125196 ,0.1828137 }

--	self.leaf:adjustColor( 0.9 , -0.29595 , -0.1 , 0.06825 )
_G.LvlFlagColor[10] = { 0.9 , -0.29595 , -0.1 , 0.06825 }

-------------------------------绿色
--	line:adjustColor( 0.4 , 0.2055 , -0.1025 , -0.2624)
--	-- 3 - 12 一圈藤蔓的颜色
_G.LvlFlagColor[52] = { 0.4 , 0.2055 , -0.1025 , -0.2624 }

--	line:adjustColor( 0.45 , 0.2055 , -0.1025 , -0.2624)
-- 13 14 上半部分 下面的小叶子
_G.LvlFlagColor[53] = { 0.45 , 0.2055 , -0.1025 , -0.2624 }


--	self.diffcultadd:adjustColor(0.320 , 0.217 , -0.114 , -0.2732 )
_G.LvlFlagColor[54] = {  0.320 , 0.217 , -0.114 , -0.2732  }

--	self.jump_level_bg:adjustColor( 0.4 , 0.2055 , -0.1025 , -0.2624)
_G.LvlFlagColor[56] = {  0.4 , 0.2055 , -0.1025 , -0.2624  }

_G.LvlFlagColor[57] = {  0.4681 , 0.1253 , 0.0683 , 0 }


_G.LvlFlagColor[60] = {  0.4454 , 0.2509 , -0.1479 , -0.2624   }



--这个色值是限时道具背景图用的
_G.LvlFlagColor[100] = {  -0.2518 , -0.0518 , 0.227 , -0.093 }	--粉
_G.LvlFlagColor[101] = {  0 , 0 , 0 , 0 }	--正常红色



