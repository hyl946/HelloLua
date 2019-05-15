require 'zoo.dc.DcValidate'


_G._VALIDATE_DC_DATA = 1
_G._VALIDATE_DC_PLATFORM = {
  _=10000
}


local tests = {
'{"step":"120","ai_flag":"0","viral_id":"_1552016165","gameversion":"1.0","utc_diff":"0","_user_id":"12345","time":"20190308113605","platform":"he","seq_id":"0","ogid":"0","udid":"ca7edbf091cc7b0f236d804d061192bb","_ac_type":"5","time_zone":"8","_src":"ct","install_key":"","is_new":"0","_uniq_key":"animal_ioscn_prod","dcsession_id":"","interval":"0","lang":"zh_CN"}',
'{"ai_flag":"0","category":"login","gameversion":"1.0","utc_diff":"-4","sub_category":"login_click_custom","_user_id":"25103","time":"20190308151007","platform":"he","seq_id":"0","level":"0","star":"0","ogid":"0","udid":"ca7edbf091cc7b0f236d804d061192bb","_ac_type":"101","time_zone":"8","_src":"ct","_uniq_key":"animal_ioscn_prod","network_state":"kMobileNetwork","networktype":"0","dcsession_id":"","minor_version":"local_dev_version","lang":"zh_CN"}',
'{"ai_flag":"1","last_login_time":"2019-03-07 14:43:28","serial_number":"","mac":"3417EBDC3ED3","deviceMemory":"0","_user_id":"25103","idfa":"","platform":"he","seq_id":"0","carrier":"","ogid":"25103","udid":"ca7edbf091cc7b0f236d804d061192bb","install_key":"","lang":"zh_CN","clienttype":"windows","clientversion":"","gameversion":"1.0","equipment":"nocrack","insideVersion":"","location":"CN","_uniq_key":"animal_ioscn_prod","utc_diff":"-116","level":"1414","star":"4274","md5":"local_dev_version","udid_remainder":"0","time_zone":"8","time":"20190308151217","clientpixel":"1080*1920","_ac_type":"2","android_id":"ca7edbf091cc7b0f236d804d061192bb","imsi":"","google_aid":"","imei":"","networktype":"0","dcsession_id":"","_src":"ct","iccid":""}',
'{"ai_flag":"1","category":"location","gameversion":"1.0","utc_diff":"-116","sub_category":"update","value":"permission","_user_id":"25103","time":"20190308151318","platform":"he","seq_id":"0","level":"1414","star":"4274","ogid":"25103","_ac_type":"109","udid":"ca7edbf091cc7b0f236d804d061192bb","time_zone":"8","_src":"ct","dcsession_id":"","_uniq_key":"animal_ioscn_prod","lang":"zh_CN"}',
'{"_user_id":"16","_uniq_key":"animal_androidcncm_prod","hideStar":"558","star":"5656","_src":"svr","_coin":"30002","category":"props","level":"1845","prop_id":"10001","prop_num":"3","src":"5","sub_category":"getProps","_ac_type":"101","time_send":"1552445014676","_cash":"2000"}',
}
local expects =
{
{
  _ac_type = "user_load",
  _uniq_key = "animal_ioscn_prod",
  _user_id = "12345",
  ai_flag = "0",
  client_time = "20190308145305",
  dcsession_id = "",
  extractmap = "{\"_src\":\"ct\"}",
  gameversion = "1.0",
  install_key = "",
  is_new = "0",
  keyword_interval = "0",
  lang = "zh_CN",
  ogid = "0",
  platform = "he",
  seq_id = "0",
  step = "120",
  time_zone = "8",
  udid = "ca7edbf091cc7b0f236d804d061192bb",
  utc_diff = "0",
  viral_id = "_1552027985",
},
{
  _ac_type = "useraction_login",
  _uniq_key = "animal_ioscn_prod",
  _user_id = "25103",
  ai_flag = "0",
  category = "login",
  client_time = "20190308151007",
  dcsession_id = "",
  extractmap = "{\"minor_version\":\"local_dev_version\",\"_src\":\"ct\"}",
  gameversion = "1.0",
  keyword_level = "0",
  lang = "zh_CN",
  network_state = "kMobileNetwork",
  networktype = "0",
  ogid = "0",
  platform = "he",
  seq_id = "0",
  star = "0",
  sub_category = "login_click_custom",
  time_zone = "8",
  udid = "ca7edbf091cc7b0f236d804d061192bb",
  utc_diff = "-4",
},
{
  _ac_type = "user_active",
  _uniq_key = "animal_ioscn_prod",
  _user_id = "25103",
  ai_flag = "1",
  android_id = "ca7edbf091cc7b0f236d804d061192bb",
  carrier = "",
  client_time = "20190308151217",
  clientpixel = "1080*1920",
  clienttype = "windows",
  clientversion = "",
  dcsession_id = "",
  devicememory = "0",
  equipment = "nocrack",
  extractmap = "{\"insideVersion\":\"\",\"imsi\":\"\",\"md5\":\"local_dev_version\",\"serial_number\":\"\",\"_src\":\"ct\"}",
  gameversion = "1.0",
  google_aid = "",
  iccid = "",
  idfa = "",
  imei = "",
  install_key = "",
  keyword_level = "1414",
  keyword_location = "CN",
  lang = "zh_CN",
  last_login_time = "2019-03-07 14:43:28",
  mac = "3417EBDC3ED3",
  networktype = "0",
  ogid = "25103",
  platform = "he",
  seq_id = "0",
  star = "4274",
  time_zone = "8",
  udid = "ca7edbf091cc7b0f236d804d061192bb",
  udid_remainder = "0",
  utc_diff = "-116",
},
{
  _ac_type = "data_109",
  _uniq_key = "animal_ioscn_prod",
  _user_id = "25103",
  ai_flag = "1",
  category = "location",
  client_time = "20190308151318",
  dcsession_id = "",
  extractmap = "{\"time_zone\":\"8\",\"_src\":\"ct\",\"utc_diff\":\"-116\"}",
  gameversion = "1.0",
  keyword_level = "1414",
  lang = "zh_CN",
  ogid = "25103",
  platform = "he",
  seq_id = "0",
  star = "4274",
  sub_category = "update",
  udid = "ca7edbf091cc7b0f236d804d061192bb",
  value = "permission",
},
{
  _ac_type = "useraction_props",
  _uniq_key = "animal_androidcncm_prod",
  _user_id = "16",
  category = "props",
  extractmap = "{\"_cash\":\"2000\",\"_coin\":\"30002\",\"time_send\":\"1552445014676\",\"_src\":\"svr\"}",
  hidestar = "558",
  keyword_level = "1845",
  prop_id = "10001",
  prop_num = "3",
  src = "5",
  star = "5656",
  sub_category = "getProps",
},
}


UserManager = {}
UserManager.uid = 0
UserManager.getInstance = function()
  return UserManager
end 
UserManager.hadInited = function()
  return false
end

function printx(c, m)
  print(m)
end

---------------------------------------------------------------

dcTest = class(UnittestTask)

function dcTest:ctor()
	UnittestTask.ctor(self)

end

function dcTest:run(callback_success_message)
  for i = 1, #tests do
    print('\n\n****\t\t#' .. tostring(i) .. '\t\t****\n')

    local str = tests[i]
    local expect = expects[i]

    print('expect body')
    print(table.tostringByKeyOrder(expect))

    local data = table.deserialize(str)
    local newData = refactor_dc_body(data)

    -- mock
    local toBeIgnoreField = {'_schema_cver', 'viral_id', 'client_time'}
    local toBeIgnoreExtractField = {'time_send'}
    for i = 1, #toBeIgnoreField do
      local field = toBeIgnoreField[i]
      newData[field] = expect[field]
    end

    local extraNewData = table.deserialize(newData.extractmap or '{}')
    local extraExpect = table.deserialize(expect.extractmap or '{}')
    newData.extractmap = nil
    expect.extractmap = nil
    for i = 1, #toBeIgnoreExtractField do
      local field = toBeIgnoreExtractField[i]
      extraNewData[field] = extraExpect[field]
    end

    table.compare(newData, expect)
    table.compare(extraNewData, extraExpect)
    -- local newStr = table.serialize(newData)
    -- if newStr ~= expect then
    --   print('')
    --   print('expect json')
    --   print(expect)
    --   print('')
    --   print('source table:')
    --   print(table.tostring(data))
    --   print('target table')
    --   print(table.tostring(newData))
    --   assert(false, '#' .. tostring(i) .. ' failed')
    -- end
  end

	callback_success_message(true, "")
end

