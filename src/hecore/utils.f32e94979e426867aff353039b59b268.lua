
--http://lua-users.org/wiki/SplitJoin
-- ",1,,2," => {"1", "2"}
function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end
-- ",1,,2," => {"","1","","2",""}
function string.split2(str, delim, maxNb)
   -- Eliminate bad cases...
   if string.find(str, delim) == nil then
      return { str }
   end
   if maxNb == nil or maxNb < 1 then
      maxNb = 0    -- No limit
   end
   local result = {}
   local pat = "(.-)" .. delim .. "()"
   local nb = 0
   local lastPos
   for part, pos in string.gfind(str, pat) do
      nb = nb + 1
      result[nb] = part
      lastPos = pos
      if nb == maxNb then
         break
      end
   end
   -- Handle the last field
   if nb ~= maxNb then
      result[nb + 1] = string.sub(str, lastPos)
   end
   return result
end

function string:escape()
    return (self:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'):gsub('%z','%%z'))
end

function string.isEmpty(str)
	return type(str) ~= "string" or not str or #str==0
end

function string:strip(pattern)
  local s = self
  pattern = pattern or "%s+"
  local _s = s:gsub("^" .. pattern, "")
  while _s ~= s do
    s = _s;
    _s = s:gsub("^" .. pattern, "")
  end
  _s = s:gsub(pattern .. "$", "")
  while _s ~= s do
    s = _s;
    _s = s:gsub(pattern .. "$", "")
  end
  return s
end
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end
local function checknumber(value, base)
    return tonumber(value, base) or 0
end
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function string.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function filterEmoji(str)
    local r = {}
    local count = utfstrlen(str)
    for i=1,count do
        local current = SubStringUTF8(str,i,i)
        local isEmoji = isEmojiCharacter(current)
        if not isEmoji then
            table.insert(r,current)
        end
    end
    local result = table.concat(r,"")
    return result
end

function isEmojiCharacter(str)
  if not str or str == "" then return false end
  local code = string.byte(str)
  local byteLen = string.len(str)

  --目前emoji基本后端返回时就返回了菱形code 237,暂时不需要额外的规则。240为zBrane的emoji code

  if code >= 237 and code <= 240 then
    return true
  end

  if byteLen > 3 then
      return true
  end

  -- if byteLen == 3 then
  --     if string.find(str, "[\226][\132-\173]") or string.find(str, "[\227][\128\138]") then
  --         return true
  --     end
  -- end
  -- local r = not ((code == 0x0) or (code == 0x9) or (code == 0xA)
  --       or (code == 0xD)
  --       or ((code >= 0x20) and (code <= 0xD7FF))
  --       or ((code >= 0xE000) and (code <= 0xFFFD))
  --       or ((code >= 0x10000) and (code <= 0x10FFFF)))
  -- if r then return true end

  -- if not ((code >= 0x0000 and code <= 0x25ff) or (code >= 0x27c0 and code <= 0xD7FF) or (code >= 0xE000 and code <= 0xFFFF)) then
  --     return true
  -- end
  return false
end

function nameDecode(nameStr)
  local ret = HeDisplayUtil:urlDecode(nameStr or "")
  ret = string.gsub(ret, '\n', '')
  return ret
end

function localize(key, params)
	return Localization:getInstance():getText(key, params)
end

function hex2ccc3( hex )
  local integer = tonumber(hex, 16)
  local ret = HeDisplayUtil:ccc3FromUInt(integer)
  return ret
end

function setTimeOut(func, time)
  local scheduleScriptFuncID
  time = time or 1
  local function onScheduleScriptFunc()
    if scheduleScriptFuncID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleScriptFuncID) end
    if func then func() end
  end
  scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleScriptFunc,time,false)
  return scheduleScriptFuncID
end

function cancelTimeOut(timeOutID)
	if timeOutID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timeOutID) end
end

function delay(timeBeforeDelay)
    local function delay(dt)
        local test = 0
        for i=1,100000 do
              for j=1,10000 do
                  test = test + 1
              end
        end
    end
    setTimeOut(delay, timeBeforeDelay)
end 

-- compare two tables
function table.compare(s, d, path)
  path = path or ''
  if not s then
    local m = '\nfailed\nkey: ' .. path .. '\ngot nil'
    assert(false, m)
  end
  for k, v in pairs(d) do
    if k then
      local v_ = s[k]
      if type(v) == "table" then
        path = path .. k .. '.'
        table.compare(v, v_, path)
      else
        if v ~= v_ then
          local m = '\nfailed\nkey: ' .. path .. tostring(k) .. '\nexpect ' .. tostring(v) .. '\ngot ' .. tostring(v_)
          assert(false, m)
        end
      end
    end
  end
  for k, v in pairs(s) do
    local v_ = s[k]
    if v ~= nil and d[k] == nil then
      local m = '\nfailed\nunexpect key: ' .. path .. tostring(k) .. '\nvalue ' .. tostring(v)
      assert(false, m)
    end
  end
end

-- 将数组随机打乱
function table.randomOrder(array,mainLogic)
  local ret = {}

  for i=#array,1,-1 do
     local index = mainLogic.randFactory:rand(1, i)
     table.insert(ret,array[index])
     array[index] , array[i] = array[i],array[index]
  end
  return ret
end

function table.clone(t, nometa)
  local u = {}

  if not nometa then
    setmetatable(u, getmetatable(t))
  end

  for i, v in pairs(t) do
    if type(v) == "table" then
      u[i] = table.clone(v)
    else
      u[i] = v
    end
  end

  return u
end

function table.simpleClone( t )
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return u
end

function table.copyValues(t, ignoreTypes)
  if not t then
    return nil
  end

  local u = {}

  if type(ignoreTypes) == "string" then
    ignoreTypes = {ignoreTypes}
  end
  ignoreTypes = ignoreTypes or {"function"}

  for i, v in pairs(t) do
    if not table.exist(ignoreTypes, type(v)) then
      if type(v) == "table" then
        u[i] = table.copyValues(v, ignoreTypes)
      else
        u[i] = v
      end
    end
  end

  return u
end

function table.indexOf(t, v)
    for i, v_ in ipairs(t) do
        if v_ == v then return i end
    end
    return nil
end

function table.keyOf(t, v)
    for k, v_ in pairs(t) do
        if v_ == v then return k end
    end
    return nil
end


function table.includes(t, value)
  return table.indexOf(t, value)
end

function table.removeValue(t, value)
  local index = table.indexOf(t, value)
  if index then table.remove(t, index) end
  return t
end

function table.unique(t)
  local seen = {}
  for i, v in ipairs(t) do
    if not table.includes(seen, v) then table.insert(seen, v) end
  end

  return seen
end

function table.union(t0, t1)
    local t = {}
    for i, v in ipairs(t0) do table.insert(t, v) end
    for i, v in ipairs(t1) do table.insert(t, v) end
    return t
end

function table.merge(t0, t1)
    local t = {}
    for k, v in pairs(t0) do t[k] = v end
    for k, v in pairs(t1) do t[k] = v end
    return t
end

function table.removeAll(t)
    for i = 1, #t do t[i] = nil end
    for k, v in pairs(t) do t[k] = nil; end
end

function table.keys(t)
  local keys = {}
  for k, v in pairs(t) do table.insert(keys, k) end
  return keys
end

function table.values(t)
  local values = {}
  for k, v in pairs(t) do table.insert(values, v) end
  return values
end

function table.last(t)
  return t[#t]
end

function table.append(t, moreValues)
  for i, v in ipairs(moreValues) do
    table.insert(t, v)
  end

  return t
end

function table.max( t )
  local _, r = next(t)
  for _, v in pairs(t) do
    r = math.max(v, r)
  end
  return r
end

function table.min( t )
  local _, r = next(t)
  for _, v in pairs(t) do
    r = math.min(v, r)
  end
  return r
end

function table.each(t, func)
  for k, v in pairs(t) do
    func(v, k)
  end
end

function table.find(t, func)
  for k, v in pairs(t) do
    if func(v) then return v, k end
  end

  return nil
end

function table.findStr(t, str)
  return table.find(
    t,
    function(v)
      return v==str
    end)
end

function table.findItem(t, str)
  return table.find(
    t,
    function(v)
      return v==str
    end)
end

function table.filter(t, func)
  local matches = {}
  for k, v in pairs(t) do
    if func(v) then table.insert(matches, v) end
  end

  return matches
end

function table.headn( t, n )
  if #t <= n then return t end
  local ret = {}
  for k, v in ipairs(t) do
    table.insert(ret, v)
    if #ret >= n then
      break
    end
  end
  return ret
end

function table._and( t )
  local ret = #t > 0 

  for _, v in ipairs(t) do
    ret = ret and (not not v)
  end

  return ret
end

function table._or( t )
  local ret = false

  for _, v in ipairs(t) do
    ret = ret or (not not v)
  end

  return ret
end

function table.map(func, ...)
  local paras = {...}
  local tables = paras
  local ret = {}
  for k, v in pairs(tables[1]) do
    local values = {}
    for _, t in ipairs(tables) do
     table.insert(values, t[k])
    end
    ret[k] = func(unpack(values))
  end
  return ret
end

function table.reduce(t, func)
  local ret =  t[1]
  for i = 2, #t do
    ret = func(ret, t[i])
  end
  return ret
end

function table.sum(t)
  local s = 0
  for _, v in pairs(t) do
    s = s + v
  end
  return s
end

function table.groupBy(t, func)
  local grouped = {}
  for k, v in pairs(t) do
    local groupKey = func(v)
    if not grouped[groupKey] then grouped[groupKey] = {} end
    table.insert(grouped[groupKey], v)
  end

  return grouped
end

function table.simpleString(tbl, depth, jstack)
  depth   = depth  or 7
  jstack  = jstack or {name="top"}

  if depth < 1 then return tostring(tbl)..",\n" end

  local output = {}
  if type(tbl) == "table" then
    -- very important to avoid disgracing ourselves with circular referencs...
    for i,t in pairs(jstack) do
      if tbl == t then
        return "<" .. i .. ">,\n"
      end
    end
    jstack[jstack.name] = tbl

    table.insert(output, "{\n")

    local name = jstack.name
    for key, value in pairs(tbl) do
      local innerIndent = (indent or " ") .. (indent or " ")
      table.insert(output, innerIndent .. tostring(key) .. " = ")
      jstack.name = name .. "." .. tostring(key)
      table.insert(output,
        value == tbl and "<parent>," or table.simpleString(value, depth-1, jstack)
      )
    end
    table.insert(output, indent and (indent or "") .. "},\n" or "}")
  else
    if type(tbl) == "string" then tbl = string.format("%q", tbl) end -- quote strings
    table.insert(output, tostring(tbl) .. ",\n")
  end
  return table.concat(output)
end

function table.sorted_pairs( t )
  local keys = table.keys(t)
  table.sort(keys, function ( a, b )
    if type(a) == type(b) then
      if type(b) == type(0) then
        return a < b
      else
        return tostring(a) < tostring(b)
      end
    end
    return type(a) < type(b)
  end)
  local index = 0
  return function ( ... )
    -- body
    index = index + 1
    if index <= #keys then
      return keys[index], t[keys[index]] 
    end
  end
end

function table.tostring(tbl, indent, limit, depth, jstack)
  limit   = limit  or 1000
  depth   = depth  or 7
  jstack  = jstack or {name="top"}
  local i = 0

  local output = {}
  if type(tbl) == "table" then
    -- very important to avoid disgracing ourselves with circular referencs...
    for i,t in pairs(jstack) do
      if tbl == t then
        return "<" .. i .. ">,\n"
      end
    end
    jstack[jstack.name] = tbl

    table.insert(output, "{\n")

    local name = jstack.name
    for key, value in pairs(tbl) do
      local innerIndent = (indent or " ") .. (indent or " ")
      table.insert(output, innerIndent .. tostring(key) .. " = ")
      jstack.name = name .. "." .. tostring(key)
      table.insert(output,
        value == tbl and "<parent>," or table.tostring(value, innerIndent, limit, depth, jstack)
      )

      i = i + 1
      if i > limit then
        table.insert(output, (innerIndent or "") .. "...\n")
        break
      end
    end

    table.insert(output, indent and (indent or "") .. "},\n" or "}")
  else
    if type(tbl) == "string" then tbl = string.format("%q", tbl) end -- quote strings
    table.insert(output, tostring(tbl) .. ",\n")
  end

  return table.concat(output)
end

--- 与table.tostring的区别：打印条目按Key字符排序
function table.tostringByKeyOrder(tbl, indent, limit, depth, jstack)
  limit   = limit  or 1000
  depth   = depth  or 7
  jstack  = jstack or {name="top"}
  local i = 0

  local output = {}
  if type(tbl) == "table" then
    -- very important to avoid disgracing ourselves with circular referencs...
    for i,t in pairs(jstack) do
      if tbl == t then
        return "<" .. i .. ">,\n"
      end
    end
    jstack[jstack.name] = tbl

    table.insert(output, "{\n")

    local name = jstack.name

    ------------ sort by key ------------
    local keyTable = {}
    for i in pairs(tbl) do
      table.insert(keyTable, i)
    end
    table.sort(keyTable)
    ------------ sort by key ------------

    for _, key in pairs(keyTable) do
      local value = tbl[key]
      local innerIndent = (indent or " ") .. (indent or " ")
      table.insert(output, innerIndent .. tostring(key) .. " = ")
      jstack.name = name .. "." .. tostring(key)
      table.insert(output,
        value == tbl and "<parent>," or table.tostring(value, innerIndent, limit, depth, jstack)
      )

      i = i + 1
      if i > limit then
        table.insert(output, (innerIndent or "") .. "...\n")
        break
      end
    end

    table.insert(output, indent and (indent or "") .. "},\n" or "}")
  else
    if type(tbl) == "string" then tbl = string.format("%q", tbl) end -- quote strings
    table.insert(output, tostring(tbl) .. ",\n")
  end

  return table.concat(output)
end

function table.insertIfNotExist(t, v)
    if t then
        if not table.indexOf(t, v) then table.insert(t, v) end
    else
        t = {v}
    end
    return t
end
function table.removeIfExist(t, v)
    if t then
        local i = table.indexOf(t, v)
        if i then return table.remove(t, i) end
        for k, v_ in pairs(t) do
            if v_ == v then t[k] = nil; return v_; end
        end
    end
    return nil
end

function table.size(t)
    local s = 0;
    for k,v in pairs(t) do
        if v ~= nil then s = s+1; end
    end
    return s;
end

-- added in ver 1.27
function table.isEmpty(t)
  return not t or not next(t)
end

function table.getNotKV(t,i)
    local index = 0;
    local key,value = nil,nil;
    for k,v in pairs(t) do
        if v ~= nil then
            index = index + 1; 
            if index == i then
                value = v;
                key = k;
                break; 
            end 
        end
    end
    return key, value;
end

function table.exist(t,v)
    for k,v_ in pairs(t) do
        if v_ == v then
            return true;
        end
    end
    return false;
end

function table.getMapValue(t, k)
    for _k, v in pairs(t) do
        if _k == k then
            return v;
        end
    end
    return nil;
end


function table.getIndexByValue(t, v)
  for _k, _v in pairs(t) do
      if _v == v then
          return _k;
      end
  end
  return nil;
end


function table.walk( tbl, func)
    for k, v in ipairs(tbl) do
        if func(v, k) then
            return
        end
    end
end

function reverse_ipair( tbl )
    local i = #tbl + 1
    return function ( ... )
        i = i - 1
        if i <= 0 then
            return nil, nil
        end
        return i, tbl[i]
    end
end

function table.reverse_walk( tbl, func)
    for k, v in reverse_ipair(tbl) do
        if func(v, k) then
            return
        end
    end
end

--
-- Just For Test Phase ---------------------------------------------------------------------------------
--

local function printConstTable(t)
    if _G.isLocalDevelopMode then printx(0, "---------------- Constants Table Error -----------------") end
    for k, v in pairs(t) do if _G.isLocalDevelopMode then printx(0, k, v) end end
end

function table.bean(c, b)
    if __RESTRICT_BEAN then
        local proxy = {}
        local metadata = {
            __o = b,
            __c = c,
            __index = function(t, k)
                if not c[k] then
                    printConstTable(t)
                    error("fail to retrieve undefined key '" .. k .. "' from a bean table.", 2)
                end
                return rawget(b, k)
            end,
            __newindex = function(t, k, v)
                local t_f = c[k]
                if t_f then
                    if nil == v and ("number" ~= t_f) or type(v) == t_f then      -- 鍖归厤鍘熷鏁版嵁绫诲瀷锛屼粎number鍙互璁剧疆涓簄il
                        rawset(b, k, v)
                    else
                        local mt = getmetatable(v)
                        if mt and mt.__c == t_f then                              -- 鍖归厤鑷畾涔夋暟鎹被鍨?
                            rawset(b, k, v)
                        else
                            local c_metadata = getmetatable(c)
                            if c_metadata and type(c_metadata.__o) == "table" then printConstTable(c_metadata.__o) end
                            error("fail to modify a bean table for key '" .. k .. "' with a value of '" .. type(v) .. "'", 2)
                        end
                    end
                else
                    printConstTable(t)
                    error("fail to modify a bean table with key of '" .. k .. "'", 2)
                end
            end
        }
        setmetatable(proxy, metadata)
        return proxy
    else
        return b
    end
end

function table.serialize(t)
  local _json = require("cjson")
  return _json.encode(t)
end


function table.deserialize(str)
  local _json = require("cjson")
  local result = nil
  local function deserialize_cjson() result = _json.decode(str) end
  pcall(deserialize_cjson)
  return result
end

function table.const(t)
    if __RESTRICT_BEAN then
        local const = {}
        local metadata = {
            __o = t,
            __index = function(a, k)
                local v = t[k]
                if nil == v then
                    printConstTable(t)
                    error("fail to retrieve undefined key '" .. k .. "' from a constants table.", 2)
                end
                return v
            end,
            __newindex = function(a, k, b)
                printConstTable(t)
                error("fail to modify a constants table with key of '" .. k .. "'", 2)
            end
        }
        setmetatable(const, metadata)
        return const
    else
        return t
    end
end

table.class = table.const

function table.debug(t, tab)
    if __DEBUG_OUTPUT then
        local prev = ""
        if type(tab) == "number" then 
            for i = 1, tab do prev = prev .. "\t" end
        end
            
        if #t > 0 then
            for i, v in ipairs(t) do 
                if _G.isLocalDevelopMode then printx(0, prev, i, v) end 
                if type(v) == "table" then
                    table.debug(v, type(tab) == "number" and (tab + 1) or 1)
                end
            end
        else
            local object = false
            for k, v in pairs(t) do
                object = true
                if _G.isLocalDevelopMode then printx(0, prev, k, v) end 
                if type(v) == "table" then
                    table.debug(v, type(tab) == "number" and (tab + 1) or 1)
                end
            end
            if not object then if _G.isLocalDevelopMode then printx(0, prev, "... empty ...") end end
        end
    end
end

Type = table.const {
    kNumber = "number",
    kString = "string",
    kBoolean = "boolean",
    kArray = "table",
    kTable = "table"
}


-- To Format 0:0:0
function convertSecondToHMSFormat(second, ...)
	assert(type(second) == "number")
	assert(#{...} == 0)

	local minute 		= math.floor(second / 60)
	local lastSecond	= second - minute*60

	local hour		= math.floor(minute / 60)
	local lastMinute	= minute - hour*60


	local string = hour .. ":" .. lastMinute .. ":" .. lastSecond
	return string
end

function convertSecondToHHMMSSFormat(second, ...)
  assert(type(second) == "number")
  assert(#{...} == 0)

  local minute    = math.floor(second / 60)
  local lastSecond  = second - minute*60

  local hour    = math.floor(minute / 60)
  local lastMinute  = minute - hour*60

  local str = string.format("%02d:%02d:%02d", hour, lastMinute, lastSecond)
  return str
end

function convertSecondToHHMMFormat(second, ...)
  assert(type(second) == "number")
  assert(#{...} == 0)

  local minute    = math.floor(second / 60)
  local lastSecond  = second - minute*60

  local hour    = math.floor(minute / 60)
  local lastMinute  = minute - hour*60

  local str = string.format("%02d:%02d", hour, lastMinute)
  return str
end

function convertSecondToMMSSFormat(second, ...)
  assert(type(second) == "number")
  assert(#{...} == 0)

  local minute    = math.floor(second / 60)
  local lastSecond  = second - minute*60

  local hour    = math.floor(minute / 60)
  local lastMinute  = minute - hour*60

  local str = string.format("%02d:%02d",lastMinute, lastSecond)
  return str
end

function convertDateTableToString(date, ...)
	assert(type(date) == "table")
	assert(#{...} == 0)

	local dateString = 
		tostring(date.year) .. "-" ..
		tostring(date.month) .. "-" ..
		tostring(date.day) .. "\t" ..
		tostring(date.hour) .. ":" ..
		tostring(date.min) .. ":" ..
		tostring(date.sec)
	return dateString
end

function parseDateStringToTimestamp(string)
    local p = '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'
    local year, month, day, hour, min, sec = string:match(p)
    local t = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})
    return t
end

function parseDate2Time( str,default )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str,pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

--
-- Tests ---------------------------------------------------------------------------------------------
--
-- _G.__magicarr1={0x6e,0x66,0x68,0x72,0x78,0x2f,0x68,0x6c,0x66,0x6d,0x77,0x2e,0x48,0x64,0x7a,0x6b,0x37,0x2e,0x6e,0x6b,0x36,}
-- _G.__magicarr2={0x6e,0x66,0x68,0x72,0x78,0x2f,0x68,0x6c,0x66,0x6d,0x77,0x2e,0x68,0x67,0x7a,0x69,0x2e,0x6f,0x72,0x74,0x73,0x67,0x37,0x2e,0x6e,0x6b,0x36,}

--[[
local T_STRING = "string"
local Class = table.class{ 
            prop1 = T_STRING, prop2 = T_STRING, prop3 = T_STRING, 
            dynamic1 = T_STRING, dynamic2 = T_STRING, dynamic3 = T_STRING 
        }
local bean = table.bean(Class, {
            prop1 = "Prop1",
            prop2 = "Prop2",
            prop3 = "Prop3",
        })

if _G.isLocalDevelopMode then printx(0, bean.prop1, bean.prop2, bean.prop3, bean.dynamic1, bean.dynamic2, bean.dynamic3) end
bean.prop1 = nil
bean.dynamic1 = "Dynamic1"
if _G.isLocalDevelopMode then printx(0, bean.prop1, bean.prop2, bean.prop3, bean.dynamic1, bean.dynamic2, bean.dynamic3) end
bean.dynamic2 = true                -- raise error here
bean.notexsit = true                -- raise error here
if _G.isLocalDevelopMode then printx(0, bean.notexsit) end                -- raise error here
--]]

function calcDateDiff(date1, date2)
    assert(date1.year)
    assert(date1.month)
    assert(date1.day)
    assert(date2.year)
    assert(date2.month)
    assert(date2.day)

    local date1Copy = 
    {
      sec = 0,
      min = 0,
      hour = 0,
      day = date1.day,
      isdst = false,
      wday = date1.wday,
      yday = date1.yday,
      year = date1.year,
      month = date1.month,
  }

  local date2Copy = 
    {
      sec = 0,
      min = 0,
      hour = 0,
      day = date2.day,
      isdst = false,
      wday = date2.wday,
      yday = date2.yday,
      year = date2.year,
      month = date2.month,
  }

  local time1 = os.time(date1Copy) or 0
  local time2 = os.time(date2Copy) or 0
  return (time1 - time2) / 86400
end

function compareDate(date1, date2)
    local dateDiff = calcDateDiff(date1, date2)
    if dateDiff < 0 then
      return -1
    elseif dateDiff == 0 then
      return 0
    elseif dateDiff > 0 then 
      return 1
    end
end

-------------------------
-- since v1.29
-- 璁＄畻鍚戦噺AB(point1->point2)涓巟杞寸殑澶硅
-------------------------
function angleFromPoint(point1, point2)
  if point1.x == point2.x then
    if point2.y > point1.y then return -90 else return 90 end
  elseif point1.y == point2.y then
    if point2.x > point1.x then return 0 else return -180 end
  else
    local ret = math.atan((point2.y-point1.y)/(point2.x-point1.x))*180/math.pi
    if point2.x > point1.x then return (0-ret)
    else return (180 - ret) end
  end
end

function utfstrlen(str)
  local len = #str;
  local left = len;
  local cnt = 0;
  local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
  while left ~= 0 do
    local tmp=string.byte(str,-left);
    local i=#arr;
    while arr[i] do
      if tmp>=arr[i] then left=left-i;break;end
      i=i-1;
    end
    cnt=cnt+1;
  end
  return cnt;
end

--截取中英混合的UTF8字符串，endIndex可缺省
function SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

-- 璁剧疆鐐瑰嚮浜嬩欢鐨勫亸绉诲€?
function setClickOffSets(newWidth,newHeight)
  -- if not _G.__HAS_SAFE_AREA then
    local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local newVisibleHeight = visibleSize.width * newHeight / newWidth

    _G.clickOffsetY = newVisibleHeight - visibleSize.height
    GlobalEventDispatcher:getInstance():dp(Event.new(kGlobalEvents.kScreenOffsetChanged, {offsetY = _G.clickOffsetY}))
  -- end
  -- he_log_error("_G.clickOffsetY==" .. _G.clickOffsetY)
end

function getTimeFormatString(timeInSec , viewType)
  local tdata = getTimeFormatData(timeInSec)
  if not viewType then viewType = 1 end
  if viewType == 1 then

    local h = tdata.h
    local m = tdata.m
    local s = tdata.s

    if tonumber(h) < 10 then h = "0" .. tostring(h) end
    if tonumber(m) < 10 then m = "0" .. tostring(m) end
    if tonumber(s) < 10 then s = "0" .. tostring(s) end

    return h .. ":" .. m .. ":" .. s
  else
    return tdata.h .. ":" .. tdata.m .. ":" .. tdata.s
  end
  
end

function getTimeFormatData(timeInSec)
  local h = 0
  local m = 0
  local s = 0
  if timeInSec > 0 then 
    local cdMin = timeInSec / 60

    h = math.floor( timeInSec / 3600)
    m = math.floor( (timeInSec - (3600 * h)) / 60)
    s = math.floor( timeInSec - (3600 * h) - (60 * m) )
    return {h = h, m = m, s = s} 
  end
  return {h = h, m = m, s = s} 
end

function getTimeFormatDataDHMS(timeInSec)
  local timeInSec0 = timeInSec
  local d = 0
  local h = 0
  local m = 0
  local s = 0
  if timeInSec0 > 0 then 
    d = math.floor( timeInSec0 / 86400 )
    timeInSec0 = timeInSec0 % 86400
    h = math.floor( timeInSec0 / 3600)
    timeInSec0 = timeInSec0 % 3600
    m = math.floor( timeInSec0 / 60)
    s = timeInSec0 % 60
    return {d = d, h = h, m = m, s = s}
  end
  return {d = d, h = h, m = m, s = s}
end

------------------------------
-- 鐪熸鐨勫垎鍓插瓧绗︿覆
------------------------------
function splite(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

VIDEO_TYPE = {
  MINITV = "MiniTV",                --(杨幂)小电视，播放器本身不带退出功能
  INCOMMINGCALL = "InCommingCall",  --(蒋劲夫)全屏播放，带退出功能
  COMMON_H = "CommonH",             --(普通/竖屏)全屏播放，带退出功能
  COMMON_V = "CommonV"              --(普通/横屏)全屏播放，带退出功能
}

---------------------------------------------------------
-- 播放内嵌视频，这个视频可以是包内的，也可以是活动里的
-- url  视频地址 如"cg/jiangjinfuincommingcall.mp4"(包内视频)   "activity/Wildaid/res/testVideo.mp4" (活动里视频)
-- type  类型，需要平台有对应支持  取值 VIDEO_TYPE
-- callBacks  回调函数对象， 格式{onSucess = testFunc1, onError = testFunc2, onFail = testFunc3}
-- res.result：视频的URL res.status "0":正常播放完成退出 "1":用户选择跳过
-- pauseBgMusic  播放视频期间是否暂停背景音乐  默认值为true
----------------------------------------------------------
function playEmbedVideo( url, type, callBacks, pauseBgMusic)
    local videoPath = CCFileUtils:sharedFileUtils():fullPathForFilename(url)
    if pauseBgMusic == nil then pauseBgMusic = true end
    
    if pauseBgMusic then
         GamePlayMusicPlayer.getInstance():tempPauseMusic()
    end

    if __ANDROID then
        local videoCallback = luajava.createProxy("com.happyelements.android.InvokeCallback", 
                                                  {
                                                       onSuccess = function (result)
                                                           GamePlayMusicPlayer.getInstance():resumeTempPauseMusic()
                                                           if callBacks.onSuccess ~= nil then callBacks.onSuccess() end
                                                       end,
                                                       onError = function (code, errMsg)
                                                           GamePlayMusicPlayer.getInstance():resumeTempPauseMusic()
                                                           if callBacks.onError ~= nil then callBacks.onError() end
                                                       end,
                                                       onCancel = function ()
                                                           GamePlayMusicPlayer.getInstance():resumeTempPauseMusic()
                                                           if callBacks.onCancel ~= nil then callBacks.onCancel() end
                                                       end
                                                   })
        local builder = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
        builder:playVideo(videoPath, type, videoCallback)
    elseif __IOS then
        waxClass{"SimpleCallbackDelegate", "NSObject", protocols = {"SimpleCallbackDelegate"}}
        SimpleCallbackDelegate.onSuccess = function(self, tab) 
                                              GamePlayMusicPlayer.getInstance():resumeTempPauseMusic()
                                              if callBacks.onSuccess ~= nil then callBacks.onSuccess() end
                                            end
        SimpleCallbackDelegate.onFailed = function() 
                                              GamePlayMusicPlayer.getInstance():resumeTempPauseMusic()
                                              if callBacks.onError ~= nil then callBacks.onError() end
                                          end
        SimpleCallbackDelegate.onCancel = function()
                                              GamePlayMusicPlayer.getInstance():resumeTempPauseMusic()
                                              if callBacks.onCancel ~= nil then callBacks.onCancel() end
                                          end
        LHVideoPlayer:playMP4_layoutName_callback(videoPath, type, SimpleCallbackDelegate:init())
    end
end

function shouldOverwriteHeadUrl(old, new)
    local isDefault, isSns, isCustomized = 1,2,3
    local function getType(url)
        if not url then url = '' end
        if url == '' or tonumber(url) ~= nil then
            return isDefault
        elseif string.starts(url, 'http://animal-10001882.image.myqcloud.com/') then
            return isCustomized
        else
            return isSns
        end
    end
    local oldType = getType(old)
    local newType = getType(new)
    if newType > oldType then
        return true
    else
        return false
    end
end

function getDeviceNameUserInput()
  local base = 'game.devicename.userinput'
  local uid = '12345'
  if UserManager and UserManager:getInstance().user then
    uid = UserManager:getInstance().user.uid or '12345'
  end
  return base .. '.' .. uid
end

function print_e()
for i=1,50 do
  if _G.isLocalDevelopMode then printx(0, "") end
end
end

function getScale9RoundRectMask(width, height)
    local roundMask = Scale9SpriteColorAdjust:createWithSpriteFrameName("ui_scale9/ui_yellow_green_scale90000")
    if roundMask ~= nil then
        roundMask:setPreferredSize(CCSizeMake(width, height))
    end

    return roundMask
end

function preventContinuousClick( func, busyTime)
  local busy = false
  return function ( ... )
    if busy then
      return
    end

    busy = true

    setTimeOut(function ( ... )
      busy = false
    end, busyTime)

    if func then
      func(...)
    end
  end
end

function getShareImagePathPrefix()
    if __ANDROID then
      local function getExternalStorage()
        return luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
      end
      local result, prefix = pcall(getExternalStorage)
      if result then
        return prefix
      end
    end
    return HeResPathUtils:getResCachePath()
end

function wrapUiForRePosition(ui)

  local wrapper = Layer:create()
  local posX, posY = ui:getPositionX(), ui:getPositionY()
  local parent = ui:getParent()
  local zorder = ui:getZOrder()
  if parent then
    ui:removeFromParentAndCleanup(false)
  end
  wrapper:addChild(ui)
  if parent then
    parent:addChildAt(wrapper, zorder)
  end
  ui:setPosition(ccp(0, 0))
  wrapper:setPosition(ccp(posX, posY))
  wrapper:setTouchEnabled(true, 0, true)
  wrapper:ad(DisplayEvents.kTouchBegin, 
    function(evt)
      print('wrapUiForRePosition')
      wrapper.__lastX, wrapper.__lastY = evt.globalPosition.x, evt.globalPosition.y

    end)
  wrapper:ad(DisplayEvents.kTouchMove, 
    function (evt)
      local y = evt.globalPosition.y
      local x = evt.globalPosition.x
      local dx = x - wrapper.__lastX
      local dy = y - wrapper.__lastY
      wrapper:setPositionX(wrapper:getPositionX() + dx)
      wrapper:setPositionY(wrapper:getPositionY() + dy)
      wrapper.__lastX = x
      wrapper.__lastY = y
    end)
  wrapper:ad(DisplayEvents.kTouchEnd, 
    function ()
      print('========== Position ==========')
      print(wrapper:getPositionX(), wrapper:getPositionY())
    end)

  wrapper.hitTestPoint = function(...)
    return true
  end

  return ui

end

function Image_resize(src, dst, scale)
  local canvas = Layer:create()

  local tex = CCTextureCache:sharedTextureCache():addImage(src)
  local bg = Sprite:createWithTexture(tex)
  bg:setAnchorPoint(ccp(0,0))
  canvas:addChild(bg)

  bg:setScale(scale)
  local sz = bg:getContentSize()

  local rt = CCRenderTexture:create(sz.width * scale, sz.height * scale)
  rt:beginWithClear(0, 0, 0, 0)
  canvas:visit()
  rt:endToLua()

  rt:saveToFile(dst)
  CCTextureCache:sharedTextureCache():removeTextureForKey(src)
  CCTextureCache:sharedTextureCache():removeTextureForKey(dst)
end

--clamp value in [a, b]
function math.clamp( value, a, b )
  return math.max(a, math.min(value, b))
end

function math.ceil2( n )
   return math.ceil(tonumber(string.format("%.06f",n)))
end

function localize2( key )
  local platformName = StartupConfig:getInstance():getPlatformName()
  local key2 = key .. '.' .. platformName

  if localize(key2) ~= key2 then
    return localize(key2)
  end
  return localize(key)

end

function getSafeUid()
    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
      uid = UserManager:getInstance().user.uid or '12345'
    end
    uid = tostring(uid)
    return uid
end

local timeOffset = (os.time() - os.time(os.date('!*t', os.time())))
function os.time2( dateTbl )
  if dateTbl == nil then
    return os.time()
  end

  dateTbl.isdst = false
  return os.time(dateTbl) + timeOffset - 8 * 3600
end

--传入 123456789 返回123,456,789 
function number_format(num,deperator)
    local str1 =""
    local str = tostring(num)
    local strLen = string.len(str)
    if deperator == nil then
        deperator = ","
    end
    deperator = tostring(deperator)
        
    for i=1,strLen do
        str1 = string.char(string.byte(str,strLen+1 - i)) .. str1
        if math.mod(i,3) == 0 then
            --下一个数 还有
            if strLen - i ~= 0 then
                str1 = ","..str1
            end
        end
    end
    return str1
end

function number_formatForm(num)
    if not num then
        return 0
    end
    if num >=100000000 then
        return math.floor(num*0.00000001).."亿"
    elseif num >= 10000 then
        return math.floor(num*0.0001).."万"
    -- elseif num >= 1000 then
    --     return math.floor(num*0.001).."千"
    end
    return num
end

function getOSVersionNumber()
    local osVersion = MetaInfo:getInstance():getOsVersion() or ""
    local vs = osVersion:split(".")
    return tonumber(tostring(vs[1]).."."..tostring(vs[2] or 0))
end

function time2day(ts)
  ts = ts or Localhost:timeInSec()
  local utc8TimeOffset = 57600 -- (24 - 8) * 3600
  local oneDaySeconds = 86400 -- 24 * 3600
  local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
  return (dayStart + 8*3600)/24/3600
end

function lua_switch( n )
  return function ( t )
    local function _do( action )
      if type(action) == 'function' then
        return action()
      else
        return action
      end
    end

    if t[n] ~= nil then
      return _do(t[n])
    end

    for k, f in pairs(t) do
      if type(k) == 'function' then
        if k(n) then
          return _do(f)
        end
      end
    end

    if t.default then
      return _do(t.default)
    end
  end
end

function pairsByKeys(t)
    local a = {}

    for n in pairs(t) do
        a[#a + 1] = n
    end

    table.sort(a)

    local i = 0
        
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end