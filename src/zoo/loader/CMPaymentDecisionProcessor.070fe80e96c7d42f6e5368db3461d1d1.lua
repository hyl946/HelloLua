
local Processor = class(EventDispatcher)

function Processor:start()
    if __ANDROID then
        self:initDecisionScript()
        if not PrepackageUtil:isPreNoNetWork() then  
            self:getLocationInfo()
        end
    end

    --Ip推广需要使用省份信息, 当时直接从Cookie读省份. 后来发现Bug, ios不存cookie, 所以ios取不到省份.

    if __IOS then
        self:getLocationInfoIOS()
    end
end

local function match( str, pattern )
    local p,n = string.find(str, pattern)
    if #pattern > 1 and p and n and n >= p then
        return true
    end
    return false
end

local ProvinceConfig = {
    ["m01,u11,t010"] = "北京",
    ["m02,u13,t022"] = "天津",
    ["m03,u18,t311"] = "河北",
    ["m04,u19,t351"] = "山西",
    ["m05,u10,t471"] = "内蒙古",
    ["m06,u91,t024"] = "辽宁",
    ["m07,u90,t431"] = "吉林",
    ["m08,u97,t451"] = "黑龙江",
    ["m09,u31,t021"] = "上海",
    ["m10,u34,t025"] = "江苏",
    ["m11,u36,t571"] = "浙江",
    ["m12,u30,t551"] = "安徽",
    ["m13,u38,t591"] = "福建",
    ["m14,u75,t791"] = "江西",
    ["m15,u17,t531"] = "山东",
    ["m16,u76,t371"] = "河南",
    ["m17,u71,t027"] = "湖北",
    ["m18,u74,t731"] = "湖南",
    ["m19,u51,t020"] = "广东",
    ["m20,u59,t771"] = "广西",
    ["m21,u50,t898"] = "海南",
    ["m22,u81,t028"] = "四川",
    ["m23,u85,t851"] = "贵州",
    ["m24,u86,t871"] = "云南",
    ["m25,u79,t891"] = "西藏",
    ["m26,u84,t029"] = "陕西",
    ["m27,u87,t931"] = "甘肃",
    ["m28,u70,t971"] = "青海",
    ["m29,u88,t951"] = "宁夏",
    ["m30,u89,t991"] = "新疆",
    ["m31,u83,t023"] = "重庆",
    getProvince = function ( self, flag )
        for key,province in pairs(self) do
            if match(key, flag) then
                return province
            end
        end
    end,
}

function Processor:getProvinceWithIccid()
    local forbidIccidFeature = MaintenanceManager:getInstance():isEnabled("forbidIccidFeature", false)
    if forbidIccidFeature then
        return nil
    end

    local iccid = MetaInfo:getInstance():getIccid() or ""
    local operator = AndroidPayment.getInstance():getOperator() or 0

    if (#iccid > 0 and operator <= 0) or (#iccid == 0 and operator > 0) then
        he_log_warning(string.format("iccid == %s, operator == %d", iccid, operator))
        return nil
    end

    if iccid and #iccid >= 6 then
        local prefix = string.sub(iccid, 1, 6)
        if match("898600,898602,898607", prefix) then --移动
            local provinceFlag = string.sub(iccid, 9, 10)
            return ProvinceConfig:getProvince("m"..provinceFlag)
        elseif match("898601,898609", prefix) then --联通
            local provinceFlag = string.sub(iccid, 10, 11)
            -- return ProvinceConfig:getProvince("u"..provinceFlag)
        elseif match("898603,898606", prefix) then --电信
            local provinceFlag = string.sub(iccid, 11, 13)
            -- return ProvinceConfig:getProvince("t"..provinceFlag)
        elseif operator > 0 then
            he_log_warning(string.format("iccid == %s, operator == %d", iccid, operator))
            return nil
        end
    end
end

function Processor:getLocationInfo()
    local province = self:getProvinceWithIccid()
    if province then
        Cookie.getInstance():write(CookieKey.kLocationProvince, province)
        self:dispatchEvent(Event.new(Events.kComplete, nil, self))
        if _G.isLocalDevelopMode then printx(0, "getProvinceWithIccid province init:" .. province) end
        return
    end

    local callbackHanler = function(locationDetail)
        if type(locationDetail) == "table" then
            local province = locationDetail.province
            if type(province) == "string" and string.len(province) > 0 then
                Cookie.getInstance():write(CookieKey.kLocationProvince, province)
            end
            -- self:dispatchEvent(Event.new(Events.kComplete, nil, self))
        else
            -- self:dispatchEvent(Event.new(Events.kError, nil, self))
        end
    end
    LocationManager_All.getInstance():getIPLocation(callbackHanler)

    self:dispatchEvent(Event.new(Events.kComplete, nil, self))
end

function Processor:initDecisionScript()
    AndroidPayment.getInstance():initCMPaymentDecisionScript()
end

function Processor:getLocationInfoIOS( ... )
    local callbackHanler = function(locationDetail)
        if type(locationDetail) == "table" then
            local province = locationDetail.province
            if type(province) == "string" and string.len(province) > 0 then
                Cookie.getInstance():write(CookieKey.kLocationProvince, province)
            end
        end
    end
    LocationManager_All.getInstance():getIPLocation(callbackHanler)
end

return Processor