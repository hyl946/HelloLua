local CacheIO = class()

function CacheIO:ctor( szDomain )
    self.kvCacheData = {}
    self.szDomain = szDomain
end

function CacheIO:_writeCache( ... )
    local szDataJson = table.serialize(self.kvCacheData or {})
    local szUid = '12345'
    if UserManager and UserManager:getInstance().user then
        szUid = UserManager:getInstance().user.uid or '12345'
    end
    local szKey = "com.happyelements.cacheio." .. self.szDomain .. '.'.. szUid
    CCUserDefault:sharedUserDefault():setStringForKey(szKey, szDataJson)
    CCUserDefault:sharedUserDefault():flush()
end

function CacheIO:_readCache( ... )
    local szUid = '12345'
    if UserManager and UserManager:getInstance().user then
        szUid = UserManager:getInstance().user.uid or '12345'
    end
    local szKey = "com.happyelements.cacheio." .. self.szDomain .. '.'.. szUid
    local szDataJson = CCUserDefault:sharedUserDefault():getStringForKey(szKey)
    if szDataJson and szDataJson ~= "" then 
        local kvData = { }
        kvData = table.deserialize(szDataJson) or {}
        self.kvCacheData = kvData
    end
end

function CacheIO:get(szKey)
    self:_readCache()
    local kvCacheData = self.kvCacheData or {}
    return kvCacheData[szKey], szKey
end

function CacheIO:set( szKey, value, noIo )
    self.kvCacheData = self.kvCacheData or {}
    self.kvCacheData[szKey] = value

    if not noIo then
        self:_writeCache()
    end
end


return CacheIO