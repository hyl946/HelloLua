_G._clientIp = nil
_G._clientCityCode = nil
_G._clientCityName = nil
local function testIpAddress()
    local function _createRequest(host)
      local request = HttpRequest:createPost(host)
      request:setConnectionTimeoutMs(3 * 1000)
      request:setTimeoutMs(30 * 1000)
      request:addHeader("Content-Type: application/json")
      return request
    end

    local function _sendRequest(request, body, callback)
      local stream = table.serialize(body)
      request:setPostData(stream, string.len(stream))
      HttpClient:getInstance():sendRequest2(callback, request)
    end

    local function onDownloadCodesFinished(response)
      print('get ip address, body = ' .. tostring(response.body)) 

      if response.httpCode ~= 200 then 
        return 
      end

      local s = string.find(response.body, '{')
      local j = string.sub(response.body, s - #response.body - 1, -2)
      print(j)
      local c = table.deserialize(j)
      _G._clientIp = c.cip
      _G._clientCityCode = c.cid
      _G._clientCityName = c.cname
      print(_G._clientIp)
      print(_G._clientCityCode)
      print(_G._clientCityName)
    end

    local request = _createRequest('http://pv.sohu.com/cityjson')
    local body = {}
    _sendRequest(request, body, onDownloadCodesFinished)
end
pcall(testIpAddress)

function _isClientIpValid()
    if _G._clientIp == nil or _G._clientCityCode == nil or _G._clientCityName == nil then
        return false
    end
    return true
end

