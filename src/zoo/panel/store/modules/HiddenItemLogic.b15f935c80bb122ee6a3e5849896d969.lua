local StoreItemData = require('zoo.panel.store.StoreItemData')

local HiddenItemLogic = {}

function HiddenItemLogic:loadData( onSuccess, onFail, flag)

	local ret = {}

	if __ANDROID then
		for _, v in pairs(MetaManager:getInstance().product_android) do
			if v.tag == 'all_third_party' then
				if table.includes(_G.StoreConfig.HiddenGoldIdsMap[flag], tonumber(v.id)) then
					local data = StoreItemData.new(_G.StoreConfig.SGType.kGold)
					data:setGoldData(v)
					table.insert(ret, data)
					DcUtil:UserTrack({category = 'new_store', sub_category = 'specific_coins_show', product_id = v.id})
				end
			end
		end
	elseif __IOS or __WIN32 then
		for _, v in pairs(MetaManager:getInstance().product) do
			if v.showCode == 2 then
				if table.includes(_G.StoreConfig.HiddenGoldIdsMap[flag] or {}, tonumber(v.id)) then
					local data = StoreItemData.new(_G.StoreConfig.SGType.kGold)
					data:setGoldData(v)
					table.insert(ret, data)
					DcUtil:UserTrack({category = 'new_store', sub_category = 'specific_coins_show', product_id = v.id})
				end
			end
		end
	end
	if onSuccess then onSuccess(ret) end
end

return HiddenItemLogic