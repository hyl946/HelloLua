local StoreItemData = require('zoo.panel.store.StoreItemData')

local StarBankLogic = {}

function StarBankLogic:loadData( onSuccess, onFail)
	local ret = {}
	if StarBank:isShowCoinItem() then
		local data = StoreItemData.new(_G.StoreConfig.SGType.kStarBank)
		table.insert(ret, data)
	end

	if onSuccess then onSuccess(ret) end
end

return StarBankLogic