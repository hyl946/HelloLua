--autogeneration donot change! see tools/AchiConfigHelper.py
AchiType = { 
	TRIGGER = 0,--触发型成就,前端触发,通知后端
	PROGRES = 1,--进度型成就,前后端自个计算
	SHARE = 2,
}
AchiCategory = {
	ONE = 1,--直上云霄
	TWO = 2,--积少成多
	THREE = 3,--全面发展
}
local Config = {
	--None
	{id = 50, priority = 1010, points = "20", ladder = "8,12,15,19,30,76,91,106,121,136,151,166,181,196,211,241,271,331,376,406,436,466,496,526,556,586,631,676,736,796,841,871,916,976,1036,1096,1156,1216,1276,1336,1396,1486,1576,1666,1756,1846,1936,2056", type = AchiType.PROGRES, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 300, priority = 1020, points = "1-4-20,40", ladder = "1,2,3,5,10,20,50,100", type = AchiType.PROGRES, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 520, priority = 1030, points = "1-4-15,25", ladder = "1,2,3,5,10,20,30,40,50", type = AchiType.PROGRES, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 90, priority = 1040, points = "20", ladder = "", type = AchiType.PROGRES, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 10, priority = 1050, points = "100", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 150, priority = 1060, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 160, priority = 1070, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 170, priority = 1080, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 180, priority = 1090, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.ONE, extra = nil},
	--None
	{id = 310, priority = 2010, points = "1-4-20,30", ladder = "50,300,800,1500,3000,5000,10000,15000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 320, priority = 2020, points = "1-6-15,25", ladder = "50,200,500,1000,2000,5000,10000,50000,75000,150000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 330, priority = 2030, points = "1-6-15,25", ladder = "50,200,500,1000,2000,5000,8000,15000,30000,60000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 340, priority = 2040, points = "1-4-20,30", ladder = "50,200,800,1500,3000,5000,15000,30000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 350, priority = 2050, points = "1-4-20,30", ladder = "50,200,800,1500,3000,5000,15000,30000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 360, priority = 2060, points = "1-4-20,30", ladder = "10,100,500,1000,2000,5000,10000,15000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = "10011,10012,10013,10014,10025,10026,10027,10028,10039,10053,10054,10057,10065,10072,10085,2,4,14,50015"},
	--None
	{id = 380, priority = 2080, points = "1-4-15,25", ladder = "10,100,500,1000,2000,5000,10000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 390, priority = 2090, points = "1-4-15,25", ladder = "10,100,500,1000,2000,5000,10000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 400, priority = 2100, points = "1-5-15,25", ladder = "1,5,10,50,100,200,500", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 410, priority = 2110, points = "1-4-25,40", ladder = "1,5,10,20,50", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 430, priority = 2130, points = "1-6-15,20", ladder = "1000000,2000000,3000000,5000000,7000000,9000000,20000000,40000000,60000000,80000000,100000000", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 200, priority = 2140, points = "10", ladder = "10,20,30,40,50", type = AchiType.PROGRES, category = AchiCategory.TWO, extra = nil},
	--None
	{id = 450, priority = 3010, points = "1-3-20,30", ladder = "10,50,100,200,500,800,1000", type = AchiType.PROGRES, category = AchiCategory.THREE, extra = nil},
	--None
	{id = 140, priority = 3020, points = "100", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.THREE, extra = nil},
	--None
	{id = 460, priority = 3030, points = "1-3-10,20", ladder = "7,14,21,28", type = AchiType.PROGRES, category = AchiCategory.THREE, extra = "7:7,7:14,7:21,10:30,20:60"},
	--None
	{id = 240, priority = 3040, points = "1-6-10,20", ladder = "10,50,100,200,300,500,700,900,1200,1500,1800", type = AchiType.PROGRES, category = AchiCategory.THREE, extra = nil},
	--None
	{id = 480, priority = 3060, points = "1-4-10,20", ladder = "3,10,20,50,100,200", type = AchiType.PROGRES, category = AchiCategory.THREE, extra = nil},
	--None
	{id = 490, priority = 3070, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.THREE, extra = nil},
	--None
	{id = 500, priority = 3080, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.THREE, extra = nil},
	--None
	{id = 510, priority = 3090, points = "50", ladder = "", type = AchiType.TRIGGER, category = AchiCategory.THREE, extra = nil},
}
local RightsConfig = {
	{points=0, id=1, },
	{markCoin=1, points=500, id=2, },
	{markCoin=1, points=1320, freegift=5, id=3, },
	{markCoin=1, freegift=5, points=2060, friendSubstitute=2, id=4, },
	{markCoin=1, fruit=1, friendSubstitute=2, freegift=5, id=5, points=2780, },
	{markCoin=1, fruit=1, freegift=5, energy=5, friendSubstitute=2, id=6, points=3600, },
}
return {Config, RightsConfig}
