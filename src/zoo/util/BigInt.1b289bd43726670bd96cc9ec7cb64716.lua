BigInt = class()

local bpe = 0 --bits stored per array element
local mask = 0 --AND this with an array element to chop it down to bpe bits
local radix = 1 --equals 2^bpe.  A single 1 bit to the left of the last bit of mask.
local digitsStr = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_=!@#$%^&*()[]{}|;:,.<>/?`~ \\\'\"+-"
local isInit = false
local one = 0;
local t = {}
local s6 = t

while bit.lshift(1, bpe + 1) > bit.lshift(1, bpe) do
  bpe = bpe + 1
end
bpe = bit.rshift(bpe, 1)
mask = bit.lshift(1, bpe) - 1
radix = mask + 1

local function copyIntToArray(x, n)
  local c = n
  for i = 1, #x do
    x[i] = bit.band (c, mask)
    c = bit.rshift(c, bpe)
  end
end

--do x=y on bigInts x and y.  x must be an array at least as big as y (not counting the leading zeros in y).
local function copyArray(x, y)
  local k = #y
  for i = 1, k do
    x[i] = y[i]
  end
  for i = k + 1, #x do
    x[i] = 0
  end
end

--returns a duplicate of bigInt x
local function dupArray(x)
  local buff = {}
  copyArray(buff,x);
  return buff;
end

--is the bigInt x equal to zero
local function isZeroArray(x)
  for i = 1, #x do
    if x[i] ~= 0 then
      return false;
    end
  end
  return true;
end

--do x=floor(x/n) for bigInt x and integer n, and return the remainder
local function divIntArray(x, n)
  local r = 0
  local s
  for i = #x, 1, -1 do
    s = r * radix + x[i]
    x[i] = math.floor(s / n)
    r = s % n
  end
  return r
end

--[[
do x=x+n where x is a bigInt and n is an integer.
x must be large enough to hold the result.
--]]
local function addIntArray(x, n)
  local k
  local b
  local c
  x[1] = x[1] + n
  k = #x
  c = 0
  for i = 1, k do
    c = c + x[i];
    b = 0;
    if c < 0 then
      b = -bit.rshift(c, bpe)
      c = c + b * radix;
    end
    x[i] = bit.band(c, mask)
    c = bit.rshift(c, bpe) - b;
    if c == 0  then 
      return; --stop carrying as soon as the carry is zero
    end
  end
end

--[[
do x=x*n where x is a bigInt and n is an integer.
x must be large enough to hold the result.
--]]
local function multIntArray(x, n)
  local k
  local b
  local c
  if (n == 0) then
    return
  end
  k = #x
  c = 0
  for i = 1, k do
    c = c + x[i] * n
    b = 0
    if c < 0 then
      b = -bit.rshift(c, bpe)
      c = c + b * radix;
    end
    x[i] = bit.band(c, mask)
    c = bit.rshift(c, bpe) - b;
  end
end

function BigInt:ctor(a)
  if a then
    self.val = a
  else
    self.val = {}
  end
end

function BigInt.int2bigInt(t, bits, minSize)
  local k = math.ceil(bits/bpe) + 1;
  k = (minSize > k) and minSize or k
  local buff = BigInt:new();
  buff.val = {};
  for i = 1, k do
    buff.val[i] = 0
  end
  copyIntToArray(buff.val,t);
  return buff;
end

--[[
convert a bigInt into a string in a given base, from base 2 up to base 95.
Base -1 prints the contents of the array representing the number.
--]]


--local bigInt2StrUsedClock = 0

function BigInt.bigInt2str(x, base)
	--local startClock = os.clock()
  local s = ""
  
  if #s6 ~= #(x.val) then
    s6 = dupArray(x.val)
  else
    copyArray(s6, x.val)
  end
  
  if base == -1 then
    for i = #(x.val), 2, -1 do
      s = s .. x.val[i] .. ","
    end
    s = s .. x.val[1]
  else
    while not isZeroArray(s6) do
      local t = divIntArray(s6, base) --t=s6 % base; s6=floor(s6/base)
      s = string.sub(digitsStr, t + 1, t + 1) .. s
    end
  end
  
  if #s == 0 then
    s = "0";
  end
  --local endClock = os.clock()
  --local deltaClock = endClock - startClock

  --bigInt2StrUsedClock = bigInt2StrUsedClock + deltaClock
  --if _G.isLocalDevelopMode then printx(0, "bigInt2StrUsedClock: " .. bigInt2StrUsedClock) end
  return s
end

--[[
return the bigInt given a string representation in a given base.  
Pad the array with leading zeros so that it has at least minSize elements.
If base=-1, then it reads in a space-separated list of array elements in decimal.
The array will always have at least one leading zero, unless base=-1.
--]]
function BigInt.str2bigInt(s, base, minSize)
  local k = string.len(s)
  local kk
  local x
  local y
  local d
  if base == -1 then --comma-separated list of array elements in decimal
    x = {}
    while true do
      y = {};
      for i = 1, #x do
        y[i + 1] = x[i]
      end
      y[0] = tonumber(s, 10);
      x=y;
      d=string.find(s, ',');
      if not d then 
        break
      end
      s = string.sub(s, d+1)
      if string.len(s) == 0 then
        break;
      end
    end
    if #x < minSize then
      y = {};
      for i = 1, minSize do
        y[i] = 0
      end
      copyArray(y,x);
      return BigInt.new(y);
    end
    return BigInt.new(x);
  end
  
  local xtemp = BigInt.int2bigInt(0, base*k, 0);
  x = xtemp.val;
  for i = 1, k do
    d = string.find(digitsStr, string.sub(s, i, i)) - 1
    if (base <= 36 and d >= 36) then  --convert lowercase to uppercase if base<=36
      d = d - 26
    end
    if (d >= base or d < 0) then   --stop at first illegal character
      break;
    end
    multIntArray(x, base)
    addIntArray(x, d)
  end
  
  k = #x
  while x[k] == 0 do --strip off leading zeros
    k = k - 1
  end
  
  k = (minSize > k) and minSize or k
  y = {}
  kk = (k < #x) and k or #x
  for i = 1, kk do
    y[i] = x[i]
  end
  for i = kk + 1, k do
    y[i] = 0
  end
  
  return BigInt.new(y)
end




