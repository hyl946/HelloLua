
return [[
本质上 Quest只是计算逻辑，可以计算来自需求A的任务，也可以计算来自需求B的任务
对应需求的[Manager]负责根据自己需求的数据创建对应的Quest

比如QuestACT活动（第一个任务需求）的管理类是QuestManager，他根据UserManger中的数据创建Quest对象
Quest的字段moduleId 用来表示需求
QuestACT活动 的moduleId 是 0

具体某个需求相关的代码 应该放在module目录下
QuestAct是第一个需求，当时是乱写的，所以这个需求的专属代码放在了外边 ，包括[ QuestManager QuestActLogic QuestHttp QuestChangeContext:popTip]

]]