require "zoo.common.FAQ"

OpenBindingPopoutAction = class(HomeScenePopoutAction)

function OpenBindingPopoutAction:ctor()
    self.name = "OpenBindingPopoutAction"
    self.openUrlMethod = "open_binding"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenBindingPopoutAction:checkCache(cache)
    local res = cache.para
    local ret = false

    local url = res.para.url
    if url then
        url = HeDisplayUtil:urlDecode(url)
        if string.find(url,"happyelements%.com/") then
            self.url = url
            ret = true
        end
    end

    self:onCheckCacheResult(ret)
end

function OpenBindingPopoutAction:popout( ... )
    if not self.url then
        self:next()
        return
    end

    FAQ:openFAQClient(self.url, FAQTabTags.kSheQu, true)

    self:next()
end