
local nativeImplement = {}

nativeImplement.enabled = false and (__ANDROID or __WIN32)

return nativeImplement
