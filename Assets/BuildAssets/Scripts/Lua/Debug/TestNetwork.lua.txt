Network.Instance:Recv(ProtoDefine.Test,{data = {"anydata1"}})

PrintLog("Test协议:更新data")
Network.Instance:Recv(ProtoDefine.Test,{data = {"anydata2","anydata5"}})--更新data

PrintLog("Test协议:新增data1")
Network.Instance:Recv(ProtoDefine.Test,{data = {"anydata2"},data1 = {"33"}})--新增data1

PrintLog("Test协议:删除data")
Network.Instance:Recv(ProtoDefine.Test,{data1 = {"33"}})--删除data

PrintLog("Test协议:插入新字段a/b")
Network.Instance:Recv(ProtoDefine.Test,{data1 = {"33"},a={c=1},b=2})

PrintLog("Test协议:更新Test.a.c")
Network.Instance:Recv(ProtoDefine.Test,{data1 = {"33"},a={c=2},b=2})