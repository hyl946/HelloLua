_G.StoreConfig = {
	
}

-- 商店里的物品类型
-- 最贴切的名字本应该是GoodsType，但GoodsType这个名字早就另有含义了，啊啊啊啊啊
_G.StoreConfig.SGType = {
	kGift = 1,     
	kGold = 2,   
	kStarBank = 3,
	kPromotion = 4,
	kServerConfig = 5,	
}


_G.StoreConfig.GiftGoodsIds = {
	635,
	636,
	637,
	638,
	639,
	-- 640,
}


if __ANDROID then
	_G.StoreConfig.HiddenGoldIdsMap = {
		[_G.StoreManager.EnterFlag.kEndGamePanelDiscount5Step] = {190},
		[_G.StoreManager.EnterFlag.kEndGamePanel2Step] = {189},
	}
else
	_G.StoreConfig.HiddenGoldIdsMap = {
		[_G.StoreManager.EnterFlag.kEndGamePanel2Step] = {133},
	}
end


_G.StoreConfig.HiddenGoldIds = {}

for _, v in pairs(_G.StoreConfig.HiddenGoldIdsMap) do
	_G.StoreConfig.HiddenGoldIds = table.union(_G.StoreConfig.HiddenGoldIds, v)
end