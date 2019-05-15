local StoreItemData = require('zoo.panel.store.StoreItemData')

local GoldLogic = {}

function GoldLogic:loadData( onSuccess, onFail)

	local ret = {}

	if __ANDROID then
		for _, v in pairs(MetaManager:getInstance().product_android) do
			if v.tag == 'all_third_party' then
				if not table.includes(_G.StoreConfig.HiddenGoldIds, tonumber(v.id)) then
					local data = StoreItemData.new(_G.StoreConfig.SGType.kGold)
					data:setGoldData(v)
					table.insert(ret, data)
				end
			end
		end
	elseif __IOS or __WIN32 then
		for _, v in pairs(MetaManager:getInstance().product) do
			if v.showCode == 2 then
				if not table.includes(_G.StoreConfig.HiddenGoldIds, tonumber(v.id)) then
					local data = StoreItemData.new(_G.StoreConfig.SGType.kGold)
					data:setGoldData(v)
					table.insert(ret, data)
				end
			end
		end
	end

	if onSuccess then onSuccess(ret) end
end

return GoldLogic