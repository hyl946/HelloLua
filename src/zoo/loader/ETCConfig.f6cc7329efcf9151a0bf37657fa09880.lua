
local etc_enable_whitelist = {
}


local function _isETCHardwareDisabled()
    local metaInfo = MetaInfo:getInstance()
    if(metaInfo) then
        local code = metaInfo:getUdid()
        for i = 1, #etc_enable_whitelist do
        	local _code = etc_enable_whitelist[i]
            if code == _code or _code == '__all__' then
                return true
            end
        end
    end
    return false
end



------------------------------------------------

local android_image_scale_whitelist = {
	
}


local function _isAndroidImageScaleDisabled()
    local metaInfo = MetaInfo:getInstance()
    if(metaInfo) then
        local code = metaInfo:getUdid()
        for i = 1, #android_image_scale_whitelist do
        	local _code = android_image_scale_whitelist[i]
            if code == _code or _code == '__all__' then
                return true
            end
        end
    end
    return false
end



------------------------------------------------

local hide_texture_whitelist = {
	
}


local function _isHideTextureDisabled()
    local metaInfo = MetaInfo:getInstance()
    if(metaInfo) then
        local code = metaInfo:getUdid()
        for i = 1, #hide_texture_whitelist do
        	local _code = hide_texture_whitelist[i]
            if code == _code or _code == '__all__' then
                return true
            end
        end
    end
    return false
end




------------------------------------------------

function _detectEtcStatus()
    local etc = _isETCHardwareDisabled()
    local scale = _isAndroidImageScaleDisabled()
    local hide = _isHideTextureDisabled()
    return etc, scale, hide
end