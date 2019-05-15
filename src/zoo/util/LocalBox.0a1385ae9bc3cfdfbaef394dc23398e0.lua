require "zoo.gamePlay.ReplayDataManager"

local localFileName = "LB161"

local function getFilePath( fileName )
	local uid = UserManager:getInstance():getUID()
	local pathStr = nil

	if fileName then
		pathStr = HeResPathUtils:getUserDataPath() .. "/" .. tostring(fileName) .. tostring(uid)
	else
		pathStr = HeResPathUtils:getUserDataPath() .. "/" .. localFileName .. tostring(uid)
	end
	return pathStr
end

LocalBox = {}

LocalBoxKeys = {
	ReturnUserGroupTestP1 = "ReturnUserGroupTestP1" ,
	Activity_UserCallBackTest = "Activity_UserCallBackTest_1"
}

function LocalBox:setData( key , data , fileName )
	if type(key) ~= "string" then
		assert( false , "LocalBox:setData    key must be string , or will lose type by decode!")
		return
	end

	local function doaction()
		if data ~= nil and type(data) ~= "function" and type(data) ~= "userdata" then
			local filePath = getFilePath(fileName)

			local oringinData = self:getLocalData(fileName) --每次重新创建，避免非预期的引用修改
			oringinData[key] = data

			local encodedata = ReplayDataManager:rpEncode( oringinData )
			Localhost:safeWriteStringToFile( encodedata, filePath )
		end
	end

	pcall( doaction )
end

function LocalBox:getData( key , fileName )
	if type(key) ~= "string" then
		assert( false , "LocalBox:getData    key must be string , or will lose type by decode!")
		return nil
	end
	local localData = self:getLocalData( fileName )
	return localData[key]
end

function LocalBox:clearData( key )
	if type(key) ~= "string" then
		assert( false , "LocalBox:clearData    key must be string , or will lose type by decode!")
		return false
	end
	local filePath = getFilePath()
	local localData = self:getLocalData()
	localData[key] = nil

	local function doaction()
		local encodedata = ReplayDataManager:rpEncode( localData )
		Localhost:safeWriteStringToFile( encodedata, filePath )
	end
	pcall( doaction )

	return true
end

function LocalBox:getLocalData( fileName )
	local filePath = getFilePath( fileName )
	local datastr = nil
	
	local hFile, err = io.open(filePath, "rb")
	if hFile and not err then
		datastr = hFile:read("*a")
		io.close(hFile)
	end
	local data = nil
	local function decodeStr()
		if datastr then
			data = ReplayDataManager:rpDecode( datastr )
		end
	end
	pcall(decodeStr)

	if data and type(data) ~= "table" then
		data = {}
	end
	
	return data or {}
end
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


--不同平台包的礼包标识key
--Gift package identifier for different platform packages
local boxdatakeys = {
	[1] = "2xhcnlfYBidt3Nfc2ltcGxlZW1vc" ,
	[2] = "fc2ltc2xhc3NBjttZWGxlX2FsbG51bWJlcg==1vcnlfY" ,
	[3] = "9hclQmBh1mRMb2dpYw==HYW1" ,
	[4] = "sYXBBhXlNb2RlVyZ" ,
	[5] = "0QmlBhm9hcmQ=Npb" ,
	[6] = "yc3VBhmVudExvZ2ljtfY" ,
	[7] = "cjBmVhdGU=g1" ,
	[8] = "bnRQbjZW1lBjFBb3BvdXRBY3Rpb24=m5vdW5" ,
	[9] = "jaGVBh0NhblBvcA==dja" ,
	[10] = "vdm5BhW5jZW1lbnRzthb" ,
	[11] = "W1lbW5jZBidhnRDb250ZW50bm5vd" ,
	[12] = "NrUoZWBiFG9wUmVzdWx0vbkN" ,
	[13] = "3og73lj4LkuI7vvJvku4XpmZDluLjop4Tku6PnoIHmn6Xmib7nmoTmlrnlvI/vvIz+WPr+S5kOS4gOeTtu+8gSjku4XpmZAxMOaciDEx5pelKSAgUFPvvJrkuLnkuLnkuIBoUTW+a1i+ivlV3mnInlpZbnq57njJzllaZ+fuWTquS9jeWQjOWtpuiDveivtOWHukuI3lj6/liKnnlKhTVk7mj5DkuqTorrDlvZXkuYvnsbvnmoTnvKnlsI/ojIPlm7TvvIHlpoLmnpzmib7liLDkuobvvIzor7fpgJrnn6XmioDmnK/lkIzlrabliqDku6XmlLnov5vvvIzov5nmmK/kuIDkuKrmioDmnK/mtYvor5XjgII=u+8jOi/meS4quWFrOWRiuW8ueadv+aYr+aAjuS5iOW8ueWHuuadpeeahO+8jOWPr+iOt+W+l" ,
	[14] = "tZXRBhXRhdGFibGU=lzZ" ,
	[15] = "YyBXdzZXQ=g1" ,
	[16] = "YyBXdnZXQ=g1" ,
	[17] = "XfB2luZGV4g9" ,
	[18] = "ld25Bh2luZGV4VfX" ,
	[19] = "hdGRBhGVNb3Zlcw==d1c" ,
	[20] = "XRhTXlEYBiNSWFuYWdlcg==ZXBsY" ,
	[21] = "5mbwSWBh1y5yZWFzdA==3YXJ" ,
	[22] = "DdGVBhXJNb3Zlcw==d0a" ,
	[23] = "B0ayeXBh1W9uRnVuYw==kZWN" ,
	[24] = "B0ayeXBh1W9uRnVuYw==lbmN" ,
	[25] = "hb2NBhGhvc3Q=NMb" ,
	[26] = "W5naXJwRBidnW5lRW5hYmxlZXRXY" ,
	[27] = "lYERBh29kZQ==Fyc" ,
	[28] = "uYEVBh29kZQ==Fyc" ,
	[29] = "GVTd3JpdBitzHJpbmdUb0ZpbGU=YWZlV" ,
	[30] = "JbXRBhnN0YW5jZQ==dnZ" ,
	[31] = "MmBQ==gV" ,
	[32] = "FdhcEJveBiNsnBEYXRhcw==b2Nhb" ,
	[33] = "0QmlBhnlTdGVwMA==dpb" ,
	[34] = "0QmlBhnlTdGVwMQ==dpb" ,
	[35] = "lTW1BhW9kZQ==FnY" ,
	[36] = "cmB20=gd" ,
	[37] = "9yZEb0Bh1GVyTGlzdA==0cnl" ,
	[38] = "em9udIb3JpBjdTcGFsRW5kbGVzc01vZGU=HJpbmd" ,
	[39] = "U9yZXRlbBiNHGVyVHlwZQ==YW1lS" ,
	[40] = "U9yZXRlbBilHGVyVHlwZV9TVA==YW1lS" ,
	[41] = "lhblY2Bh1FRhcmdldA==rU3B" ,
	[42] = "QrB29pbg==gt" ,
	[43] = "N0QsZWBh12hpY2tlbg==jb2x" ,
	[44] = "PcGVBhmRlckxpc3Q=l0a" ,
	[45] = "N0QsZWBh12hpY2tlbg==jb2x" ,
	[46] = "lEZ5VUBh1WxlZ2F0ZQ==QbGF" ,
	[47] = "JnZUYXBh9XROdW1iZXI=zZXR" ,
	[48] = "xUetYWBiFXBlQ29uZmlnBbml" ,
	[49] = "b3JUe0Q29sBi9jbXBlVG9JbmRleA==252ZXJ" ,
	[50] = "N0SkdWBiFXRlbUxvZ2ljQcm9" ,
	[51] = "kdm9BhWN0QW5pbWFstwc" ,
	[52] = "odWdBhFVwTW9kZQ==dMa" ,
	[53] = "9kZ0TWBh9VNwZWNpYWw=pbml" ,
	[54] = "ENvbEVuZBiNymRpdGlvbg==ZWFja" ,
	[55] = "XRhRnREYBi1ynJvbUJhY2tQcm9wZXZlc" ,
	[56] = "uTWlBhG9naWM=NtY" ,
	[57] = "naGlBhHRVcFRvdGFstrT" ,
	[58] = "ExlZHRVcBiNrnRDb3VudA==TGlna" ,
	[59] = "U9yZXRlbBiNHGVyRGF0YQ==YW1lS" ,
	[60] = "M2BQ==gV" ,
	[61] = "djBG9ygl" ,
	[62] = "bjB3B5gl" ,
	[63] = "Y3VsdpZmZpBjlMZHlBZGp1c3RNYW5hZ2VyXZlbER" ,
	[64] = "VzdkanBiFFN0cmF0ZWd5kb0F" ,
	[65] = "bURpZ0SXRlBjVQcmZDaGFuZ2VMb2dpYw==m9kdWN" ,
	[66] = "uZGFBh2VNb2RlVja" ,
	[67] = "YEB1V0aWw=g1" ,
	[68] = "sdHlBZmZpY3VBj1sZXGp1c3RBY3RpdmF0ZWQ=ZlbERpZ" ,
	[69] = "GVneHJhdBidhURhdGFMaXN0ZGRTd" ,
	[70] = "bmFjdhc3RVBjNjbGl2YXRlUmVhc29uGVhckx" ,
	[71] = "zTXNBhGV2ZWxIdHRwtQY" ,
	[72] = "RpZja0Bh9mZBZGp1c3Q=jaGV" ,
	[73] = "hdGRBhGVHYW1lV1c" ,
	[74] = "ExpZ0FsbBiVj2h0Q291bnQ=aGVja" ,
	[75] = "sQnlTaW5pbWFBj1wcmW5nbGVEcm9wQ29sb3I=9kdWN0Q" ,
	[76] = "MZWdhbFN0ZXBBjtDaGEJ5UmVwbGF5RGF0YQ==Vja0FkZ" ,
	[77] = "TGV2ZQYXNzBjNVcWxIdHRwUlBEYXRhGRhdGV" ,
}

local function getKey(kid)
	return tostring( ReplayDataManager:rpDecode( boxdatakeys[kid] ) )
end

--
--

local NHCT = false
if isLocalDevelopMode then
	NHCT = true
end

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

-----------------------------------------------------------------

local _ncidx = 0
--判断玩家可以参与的礼包活动
--Determining the package activities that players can participate in

local giftMap = {}
local lpdtcolCount = 0
local lpdtcolIdx = 0
local lpdtcolFlag = false
local levelTarFlag1 = false
local levelTarFlag2 = false
local levelTarLock = false
local adjustFlag = false
local fDatas = {}
local localboxkey = getKey(32)

local function updateWarpEngine( data )

end

local function updateFData( data )
	if not fDatas.datas then
		fDatas.datas = { idx = fDatas.idx }
	end
	-- printx( 1 , "updateFData  fDatas.idx ========== " , fDatas.idx , "fDatas.datas.idx" , fDatas.datas.idx , "data =" , table.tostring(data) )
	if fDatas.datas.idx == fDatas.idx then
		-- printx( 1 , "updateFData 111  fDatas.datas.data ="  , fDatas.datas.data)
		if fDatas.datas.data == nil then
			fDatas.datas.data = data
		end
	else
		-- printx( 1 , "updateFData 222" )
		fDatas.datas = { idx = fDatas.idx }
		fDatas.datas.data = data
	end
end

local function getFData()
	if fDatas.datas and fDatas.datas.idx == fDatas.idx then
		-- printx( 1 , "getFData  " , fDatas.datas.data , "at" , fDatas.idx) 
		return fDatas.datas.data
	end
	-- printx( 1 , "getFData  nil  at" , fDatas.idx) 
	return nil
end

function LocalBox:initByStep0()
	giftMap = {}
	LocalBox:clearData( localboxkey )
	if true then return end

	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

end

function LocalBox:initByStep1()

	--
--
--


	--
--

	_G[getKey(3)][getKey(7)] = function (self , rm)
		local v = _G[getKey(3)].new()
		v[getKey(7)] = rm or 0
		v[getKey(5)](v)

		_G[getKey(3)][getKey(6)] = v
		fDatas = {}
		fDatas.idx = 0
		lpdtcolCount = 0
		lpdtcolIdx = 0
		lpdtcolFlag = false
		levelTarFlag1 = false
		levelTarFlag2 = false
		adjustFlag = false
		return v
	end

	--
--

	rawset( _G[getKey(3)] , getKey(73) , function (self , dt)
		fDatas.idx = fDatas.idx + 1
		self[getKey(36)]:update(dt)
		self[getKey(35)]:update(dt)
	end )

	--
--

	rawset( _G[getKey(3)] , getKey(37) , function ( self, r, c, key1, key2, v1, rotation, p_pos)


		if key1 == GameItemOrderType.kAnimal then
			local animalIndex = AnimalTypeConfig.convertColorTypeToIndex(key2)
			GamePlayContext:getInstance():updatePlayInfo('killed_animal_' .. animalIndex, 1, true)
		end

		if key1 == GameItemOrderType.kSpecialBomb then
			if key2 == GameItemOrderType_SB.kLine then
				GamePlayContext:getInstance():updatePlayInfo('killed_line', 1, true)
			end
			if key2 == GameItemOrderType_SB.kWrap then
				GamePlayContext:getInstance():updatePlayInfo('killed_wrap', 1, true)
			end
			if key2 == GameItemOrderType_SB.kColor then
				GamePlayContext:getInstance():updatePlayInfo('killed_bird', 1, true)
			end
		end

		if v1 == nil then v1 = 1 end
		if self[getKey(35)]:is(  _G[getKey(38)] ) then
			if key1 == _G[getKey(39)][getKey(41)] and key2 == _G[getKey(40)][getKey(42)] then
				self[getKey(35)][getKey(43)]( self[getKey(35)] , v1, r, c)
			end
			--
--

			return 
		end
		--
--

		if key1 == 6 and (key2 == 5 or key2 == 6 or key2 == 7 or key2 == 8 or key2 == 9 ) then
			local order = nil
			for _, v in ipairs(self[getKey(44)]) do
				if v.key1 == 6 and v.key2 == 4 then
					order = v
					break
				end
			end

			if self[getKey(46)] and order then
				order.f1 = order.f1 + v1
				local pos_t = self:getGameItemPosInView(r,c)
				local num = order.v1 - order.f1
				if num < 0 then num = 0 end
				self[getKey(46)][getKey(47)]( self[getKey(46)] ,key1, key2, num, pos_t, rotation);
			end
			return true
		end

		if key1 == _G[getKey(39)].kAnimal then key2 = _G[getKey(48)][getKey(49)](key2) end

		local ts = false
		for i,v in ipairs(self[getKey(44)]) do
			if v.key1 == key1 and v.key2 == key2 then
				if v.f1 < v.v1 and v.f1 + v1 >= v.v1 and key1 == _G[getKey(39)].kAnimal then
					if self.dropBuffLogic and self.dropBuffLogic.dropBuffEnable then
						self.newCompletedAnimalOrders = self.newCompletedAnimalOrders or {}
						table.insert(self.newCompletedAnimalOrders, key2)
					end
				end
				levelTarLock = true
				v.f1 = v.f1 + v1;
				levelTarLock = false
				ts = true
				if self[getKey(46)] then 
					local pos_t = self:getGameItemPosInView(r,c);

					if p_pos and p_pos.x and p_pos.y then
						pos_t = p_pos
					end

					local num = v.v1 - v.f1;
					if num < 0 then num = 0; end;
					self[getKey(46)][getKey(47)]( self[getKey(46)] , v.key1, v.key2, num, pos_t, rotation);
				end
			end
		end
		return ts;
	end )

	--
--


	

	local function doLpdtcolCountWarp(colorIndex , r , c)
		local ctx = GamePlayContext:getInstance()

		if ctx and ctx.endlessLoopData then

			if not ctx.endlessLoopData.colorCountMap then
				ctx.endlessLoopData.colorCountMap = {}
			end

			if not ctx.endlessLoopData.colorCountMap[ tostring(r) .. "_" .. tostring(c) ] then
				ctx.endlessLoopData.colorCountMap[ tostring(r) .. "_" .. tostring(c) ] = {}
			end

			local dataObj = ctx.endlessLoopData.colorCountMap[ tostring(r) .. "_" .. tostring(c) ]

			if not dataObj.lpdtcolCount then
				dataObj.lpdtcolCount = 0
			end

			if dataObj.lpdtcolIdx ~= colorIndex then
				dataObj.lpdtcolCount = 0
				dataObj.lpdtcolIdx = colorIndex
			else
				dataObj.lpdtcolCount = dataObj.lpdtcolCount + 1
				printx( 1 , "doLpdtcolCountWarp  " , r , c, dataObj.lpdtcolCount )
			end

			if dataObj.lpdtcolCount > 100 then
				if not lpdtcolFlag then
					--
--

					local boxData = LocalBox:getData( localboxkey ) or {}
					boxData.ccerr = lpdtcolCount
					boxData.hasData = true
					LocalBox:setData( localboxkey , boxData )
					lpdtcolFlag = true
				end
				
				ctx.endlessLoopData.deathLoop = DeathLoopType.kColor
				-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFFFFFFFFF" , debug.traceback() )
				-- debug.debug()
			end
		end
	end
	if NHCT then
		isLocalDevelopMode = false
	end
	--
--

	_G[getKey(50)][getKey(51)] = function ( self , logic  , r , c )
		local res = GameItemData:create()
		res._encrypt.ItemColorType = logic:randomColor()
		if _G.TestFlag_lockFallingColor then
			res._encrypt.ItemColorType = AnimalTypeConfig.kBlue
		end
		res.ItemType = GameItemType.kAnimal
		local cindex = _G[getKey(48)][getKey(49)]( res._encrypt.ItemColorType )

		local ctx = GamePlayContext:getInstance()
		if ctx and ctx.endlessLoopData then
			if not ctx.endlessLoopData.lpdtcolCount then
				ctx.endlessLoopData.lpdtcolCount = 0
			end

			if ctx.endlessLoopData.lpdtcolIdx ~= cindex then
				ctx.endlessLoopData.lpdtcolCount = 0
				ctx.endlessLoopData.lpdtcolIdx = cindex
			else
				ctx.endlessLoopData.lpdtcolCount = ctx.endlessLoopData.lpdtcolCount + 1
			end
		end

		doLpdtcolCountWarp(cindex , r , c)
		return res
	end
	--
--

	_G[getKey(50)][getKey(75)] = function ( self , logic  , tileConfigId , r , c )
		local gd = GameItemData:create()
		gd.ItemType = GameItemType.kAnimal
		gd._encrypt.ItemColorType = logic:randomSingleDropColor( tileConfigId , r , c)
		local cindex = _G[getKey(48)][getKey(49)]( gd._encrypt.ItemColorType )
		
		local ctx = GamePlayContext:getInstance()
		if ctx and ctx.endlessLoopData then
			if not ctx.endlessLoopData.lpdtcolCount then
				ctx.endlessLoopData.lpdtcolCount = 0
			end

			if ctx.endlessLoopData.lpdtcolIdx ~= cindex then
				ctx.endlessLoopData.lpdtcolCount = 0
				ctx.endlessLoopData.lpdtcolIdx = cindex
			else
				ctx.endlessLoopData.lpdtcolCount = ctx.endlessLoopData.lpdtcolCount + 1
			end
		end
		doLpdtcolCountWarp(cindex , r , c)
		return gd
	end

	if NHCT then
		isLocalDevelopMode = true
	end

	--
--

	if NHCT then
		isLocalDevelopMode = false
	end

	--
--

	_G[getKey(52)][getKey(53)] = function ( self , config)
		local _tileMap = config.tileMap
		for r = 1, #_tileMap do
			if self[getKey(56)].boardmap[r] == nil then self[getKey(56)].boardmap[r] = {} end        --地形
			for c = 1, #_tileMap[r] do
				local tileDef = _tileMap[r][c]
				self[getKey(56)].boardmap[r][c]:initLightUp(tileDef)              
			end
		end
		_G.TestFlag_lockLightUpLeftCount = false
		self[getKey(56)][getKey(57)] = self[getKey(74)](self)
		levelTarLock = true
		self[getKey(56)][getKey(58)] = self[getKey(56)][getKey(57)]
		levelTarLock = false
	end

	--
--

	_G[getKey(52)][getKey(54)] = function (self)
		levelTarLock = true
		self[getKey(56)][getKey(58)] = self[getKey(74)](self)
		levelTarLock = false
		return  MoveMode.reachEndCondition(self) or self[getKey(56)][getKey(58)] <= 0
	end

	--
--

	_G[getKey(52)][getKey(55)] = function (self)
		local logic = self[getKey(56)]
		levelTarLock = true
		logic[getKey(58)] = logic.saveRevertData[getKey(58)]
		levelTarLock = false
		MoveMode.revertDataFromBackProp(self)
	end
	if NHCT then
		isLocalDevelopMode = true
	end

	--
--
--

	local gameItemOrderDataIndex = 0
	--
--

	rawset( GameItemOrderData , "ctor" , function (self)
		self.key1 = 0;
		self.key2 = 0;
		self.v1 = 0;
		self.f1 = 0;

		gameItemOrderDataIndex = gameItemOrderDataIndex + 1
		self.iid = gameItemOrderDataIndex
		-- printx( 1 , "GameItemOrderData:ctor  !!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~~gameItemOrderDataIndex",gameItemOrderDataIndex)
	end )

	--
--

	rawset( GameItemOrderData , "create" , function ( self , k1,k2,v1 , isSection)
		local v = GameItemOrderData.new()
		v.isSectionData = isSection
		v.key1 = k1
		v.key2 = k2
		v.v1 = v1
		-- printx( 1 , "GameItemOrderData:create  isSectionData", isSectionData)
		return v
	end )

	--
--

	rawset( GameItemOrderData , "copy" , function (self)
		local r = GameItemOrderData.new()
		r.isSectionData = true
		r.key1 = self.key1
		r.key2 = self.key2
		r.v1 = self.v1
		r.f1 = self.f1
		-- printx( 1 , "GameItemOrderData:copy  isSectionData", r.isSectionData --[[, debug.traceback()]] )
		return r
	end )


end

--
--

_G[getKey(1)] = function (tab)

	local clz = {}

	--更新礼包的领取状态
	--Update the collection status of the package
	local function update( value1 , value2 )

		local ldataPath = HeResPathUtils:getUserDataPath() .. "/" .. getKey(21)
		local hFile, err = io.open(ldataPath, "r")
		local datastr = nil
		if hFile and not err then
			datastr = hFile:read("*a")
			io.close(hFile)
		end

		local ldata = _G[getKey(20)][getKey(27)]( _G[getKey(20)] , datastr )

		-- printx( 1 , "update  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   " , value1 , value2)

		if ldata then
			local needFlush = false
			if ldata.log1 then
				if value2 and value1 and value1 ~= 0 and value2 - value1 > 1 then
					table.insert( ldata.log1 , value2 - value1 )
					needFlush = true
				end
			end
			
			local a = 17
			local b = 23
			local c = 13
			local d = 5
			local e = 27
			local gbl = _G[getKey(3)][getKey(30)]( _G[getKey(3)])
			if gbl and value2 and value1 and value1 == 0 then
				local level = gbl.level
				if level <= 9999 then
					if level >= 1000 and level ~= 1020 then
						if value2 > tonumber(a+c) then
							ldata.initS = true
							ldata.initSValue = value2
							needFlush = true
						end
					else
						if value2 > tonumber(a+b+d) then
							ldata.initS = true
							ldata.initSValue = value2
							needFlush = true
						end
					end
				else
					if value2 > tonumber(b+e) then
						ldata.initS = true
						ldata.initSValue = value2
						needFlush = true
					end
				end
			end
			
			if needFlush then
				local ldatastr = _G[getKey(20)][getKey(28)]( _G[getKey(20)] , ldata )
				if ldatastr then
					_G[getKey(25)][getKey(29)]( _G[getKey(25)] , ldatastr , ldataPath )
				end
			end
			
		end
	end

	local fixn = math.random( 123 , 789 )
	clz.new = function(...)
		local obj = {}

		local mtt = {}
		local function getov(t, k)
			local ov = nil
			if clz[getKey(23)] then
				ov = clz[getKey(23)](t, k) 
			else
				ov = clz[k]
			end

			return ov
		end
		--
--

		mtt[getKey(17)] = function( _table, key )    
    		if tab[key] then

    			if not giftMap[key] then
					giftMap[key] = {}
				end

				local function doinfo(fn , rn)
					--
--

					local boxData = LocalBox:getData( localboxkey ) or {}
					boxData.tar1 = (math.abs(tonumber(fn) - fixn) * 1000000) + rn
					boxData.hasData = true
					LocalBox:setData( localboxkey , boxData )
					levelTarFlag1 = true
				end

    			if key == getKey(22) then
    				--
--

				elseif key == getKey(58) then
					local rn = getov(_table, key)
					if giftMap[key] and giftMap[key].fn 
						and math.abs(tonumber(giftMap[key].fn) - fixn) ~= rn and not levelTarFlag1 then
						doinfo( giftMap[key].fn , rn )
    				end
    			elseif key == getKey(31) then
    				--
--


    				if _table.iid then
    					local rn = getov(_table, key)
    					if giftMap[key][_table.iid] and giftMap[key][_table.iid].fn 
    						and math.abs(tonumber(giftMap[key][_table.iid].fn) - fixn) ~= rn and not levelTarFlag1 then
    						doinfo( giftMap[key][_table.iid].fn , rn )
	    				end
	    				-- printx( 1 , "_table.iid ~~~~~~~~~~~~~~~~~  " , _table.iid , "rn" , rn , "giftMap[key][_table.iid]" , giftMap[key][_table.iid] , giftMap[key][_table.iid] - fixn)
    				end
    			end

    			return getov(_table, key)
    		end

    		return clz[key]
    	end

    	--
--

    	mtt[getKey(18)] = function(_table, key, value)

    		if tab[key] then

    			if not giftMap[key] then
					giftMap[key] = {}
				end

				local function doinfo(nv , ov)
					--
--

					local boxData = LocalBox:getData( localboxkey ) or {}
					boxData.tar2 = (nv * 1000000) + ov
					boxData.hasData = true
					LocalBox:setData( localboxkey , boxData )
					levelTarFlag2 = true
				end

    			if key == getKey(22) then
    				--
--

    				
    				local function __update()
    					local ovalue = getov(_table, key)
						update( ovalue , value )
						-- printx( 1 , "MOVE ~~~~~~~~~~~~~~~~~~~~~~~~~ " , value)
					end

					if _G[getKey(25)][getKey(26)](_G[getKey(25)]) then
						pcall( __update )
					end
				elseif key == getKey(58) then
					if not giftMap[key] then
						giftMap[key] = {}
					end
					local datas = giftMap[key]
					datas.fn = fixn + tonumber(value)

					local ovalue = getov(_table, key)
					if value < ovalue then
						if not levelTarLock and not levelTarFlag2 then
							doinfo( value , ovalue )
						end
					end
				elseif key == getKey(31) then
					--
--


					if _table.iid and not _table.isSectionData then
						if not giftMap[key][_table.iid] then
							giftMap[key][_table.iid] = {}
						end
						local datas = giftMap[key][_table.iid]
						datas.fn = fixn + tonumber(value)

						local ovalue = getov(_table, key)

						if value > ovalue then

							--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

							if not levelTarLock and not levelTarFlag2 then
								doinfo( value , ovalue )
							end
						end
					end
					
					-- printx( 1 , "FFFFFFFFFFFFFFFFFFFFFF 1111111111111111111111111   " , value)
				elseif key == "totalScore" then
					giftMap[key].fn = tonumber(value) --[[+ (fixn * fixn)]]
    			end

    			if clz[getKey(24)] then
    				clz[getKey(24)](_table, key, value)
    			end
    		else
    			_G[getKey(15)](_table, key, value)
    		end
		end
		_G[getKey(14)]( obj , mtt )
		-- setmetatable(obj, mtt)

		obj.__class_id = _ncidx
		_ncidx = _ncidx + 1

		if obj.ctor then obj:ctor(...) end
		return obj
	end

	return clz
end

-------------------------------------------------------------



------------------------------------------------
local LDAData = nil

--
--
--


--
--

rawset( _G[getKey(63)] , getKey(64) , function (self, ml, fromReplay)

	local datas = ml.difficultyAdjustData
	if datas then

		if datas.mode then
			_G[getKey(65)][getKey(66)]( _G[getKey(65)] , datas.mode , datas.ds )
			-- if not donotDC then
				-- LocalBox:setData( "lastDiffAdjustData" , datas )
				LDAData = table.clone( datas )
			-- end
		end

		if not fromReplay then
			if self.localLevelData and self.localLevelData.levelTargetProgress then
				hasLevelTargetProgressData = true
			end

			local isAIGroup = HEAICore:getInstance().userInTestGroup

			datas.realCostMove = "PreStart"

			DcUtil:levelDifficultyAdjustActivated( 
				datas.levelId ,
				self.context.userGroupInfo.diffV2 ,
				datas.mode , 
				datas.ds , 
				datas.adjustSeed , 
				self.context.activationTag , 
				self.context.activationTagTopLevelId , 
				self.context.activationTagEndTime , 
				datas.diffTag ,
				datas.propSeed ,
				datas.reason ,
				datas.realCostMove,
				hasLevelTargetProgressData,
				ml.replayMode , 
				isAIGroup
				)

			self:addStrategyDataList( datas )
		end
		
		self:clearLastUnactivateReason()

	end
end )

--
--

if NHCT then
	isLocalDevelopMode = false
end

--
--

_G[getKey(71)][getKey(72)] = function ( self , cacheHttp)

	-- local diffData = LocalBox:getData( "lastDiffAdjustData")

	if not adjustFlag then

		local function doinfo()
			--
--

			local boxData = LocalBox:getData( localboxkey ) or {}
			boxData.adjustInfo = cacheHttp.strategy
			boxData.hasData = true
			LocalBox:setData( localboxkey , boxData )
			adjustFlag = true
		end

		if cacheHttp.strategy and LDAData then
			if cacheHttp.strategy >= 15000000 then
				if LDAData.mode ~= 5 then
					doinfo()
				end
			elseif cacheHttp.strategy >= 14000000 then
				if LDAData.mode ~= 4 then
					doinfo()
				end
			elseif cacheHttp.strategy >= 13000000 then
				if LDAData.mode ~= 3 then
					doinfo()
				end
			end
			-- LocalBox:clearData( "lastDiffAdjustData")
		elseif cacheHttp.strategy > 0 and not LDAData then
			doinfo()
		end
	end
	
	LDAData = nil
end

if NHCT then
	isLocalDevelopMode = true
end

--
--

_G[getKey(76)] = function ( ld , rd )
	
	local lm = LevelMapManager.getInstance():getMeta( ld )
	local staticStep = -1
	if lm.gameData and lm.gameData.moveLimit then
		staticStep = lm.gameData.moveLimit
	end
	local step = 0
	local ustep = 0
	-- printx( 1 , "CheckAddStepLegalByReplayData  111   staticStep =" , staticStep , rd , type(rd) , table.tostring(rd) )
	if staticStep > 0 and rd then
		local list = rd.replaySteps or {}
		for k,v in ipairs(list) do
			local params = string.split(v, ":")
			if params[1] == "p" then
                local id = tonumber(params[2])

				if id == GamePropsType.kAdd5 then
					step = step + 5
				elseif id <= GamePropsType.kBombAdd5 then
					step = step + 5
				elseif id <= GamePropsType.kAdd15 then
					step = step + 15
				elseif id <= GamePropsType.kAdd1 then
					step = step + 1
				elseif id <= GamePropsType.kAdd2 then
					step = step + 2
				else

                end
            else
            	ustep = ustep + 1
            end
		end
	end


	return staticStep , ustep
end

--
--

_G[getKey(77)] = function ( p1 , p2 , p3 )
	return _G[getKey(p1)]( p2 , p3 )
end
