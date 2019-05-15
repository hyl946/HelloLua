-- 当使用新风车币商店的时候，返回这些空代理取代旧的IosPayGuide AndroidSalesManager
-- 所有旧促销功能的入口类 都应该有一个对应的空代理

-- 空代理实现一些外部类可能会调用的空方法
-- 这些空方法可能有多余的，即一些从来都不会调过来的方法
local NullIosPayGuide = class()

function NullIosPayGuide:ctor()
end

function NullIosPayGuide:init()
end

function NullIosPayGuide:isInAppleVerification()
	return false
end

function NullIosPayGuide:isInFCashPromotion()
	return false
end

function NullIosPayGuide:oneYuanFCashEnd()
end

function NullIosPayGuide:removeOneYuanFCashFlag()
end

function NullIosPayGuide:getOneYuanFCashConfig()
	return {}
end

function NullIosPayGuide:shouldShowMarketOneYuanFCash()
	return false
end

function NullIosPayGuide:oneYuanFCashStart()
end

function NullIosPayGuide:getOneYuanShopLeftSeconds()
end

function NullIosPayGuide:onSuccessiveLevelFailure()
end

function NullIosPayGuide:isInOneYuanShopPromotion()
	return false
end

-- 凡事总有意外
-- 原来的促销逻辑里 有一个和促销没什么关系的面板
-- 这个东西在新版促销里边还得留着
function NullIosPayGuide:tryPopFailGuidePanel(cartoonCloseCallback)
    if not IosAliGuideUtils:isIOSAliGuideEnable() then
        return false
    end
	local guideModel = require("zoo.gameGuide.IosPayGuideModel"):create()
    if guideModel:getFailGuidePopped() then
        return false
    end
    if UserManager:getInstance().userExtend.payUser then
        return false
    end

    if _G.StoreManager and _G.StoreManager:safeIsEnabled() then
        return false
    end


    IosPayFailGuidePanel:create(cartoonCloseCallback):popout()
    guideModel:setFailGuidePopped()
    return true
end

local NullAndroidSalesManager = class()
local androidSalesMgrInstance

function NullAndroidSalesManager:ctor()
end

function NullAndroidSalesManager.getInstance()
	if androidSalesMgrInstance == nil then
		androidSalesMgrInstance = NullAndroidSalesManager.new()
	end
	return androidSalesMgrInstance
end

function NullAndroidSalesManager:isInGoldSalesPromotion()
	return false
end

function NullAndroidSalesManager:removeGoldButtonFlag()
	return false
end

function NullAndroidSalesManager:showGoldButtonFlag()
	return false
end

function NullAndroidSalesManager:shouldTriggerAndroidSales()
	return false
end

function NullAndroidSalesManager:showAndroidSalesPromotion()
	return false
end

function NullAndroidSalesManager:triggerSalesPromotion()
end

function NullAndroidSalesManager:goldSalesEnd()
end

function NullAndroidSalesManager:getGoldSalesLeftSeconds()
	return 0
end

function NullAndroidSalesManager:getShowOneYuanItemAni()
	return false
end

function NullAndroidSalesManager:setShowOneYuanItemAni()
end

local nullProxy = {
	iosPayGuide = NullIosPayGuide,
	androidSalesManager = NullAndroidSalesManager
}

return nullProxy