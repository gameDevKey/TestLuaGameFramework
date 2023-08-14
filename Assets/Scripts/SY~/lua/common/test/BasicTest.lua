BasicTest = StaticClass("BasicTest")

function BasicTest.Test()
    print("lua测试")
    BasicTest.Test1()
    BasicTest.Test2()
    BasicTest.Test3()
    BasicTest.Test4()
    BasicTest.Test5()
    BasicTest.Test6()
    BasicTest.Test7()
    BasicTest.Test8()
end

function BasicTest.Test1()
    local obj = GameObject()
    local transform = obj.transform

    local one = Vector3.one
    local t = os.clock()
      
    for i = 1,200000 do
        transform.position = transform.position
    end
      
    t = os.clock() - t
    print("Transform.position lua cost time: ", t)
end

function BasicTest.Test2()
    local obj = GameObject()
    local transform = obj.transform

    local up = Vector3.up
    local t = os.clock()
    for i = 1,200000 do
        transform:Rotate(up, 1)
    end
      
    t = os.clock() - t
    print("Transform.Rotate lua cost time: ", t)   
end

function BasicTest.Test3()
    local obj = GameObject()
    local transform = obj.transform

    local Vector3 = Vector3
    
    local t = os.clock()
    --local New = Vector3.New
      
    for i = 1, 200000 do
        transform.position = Vector3(i, i , i)   
    end
          
    t = os.clock() - t
    print("Vector3.New lua cost time: ", t)
end

function BasicTest.Test4()   
    local GameObject = CS.UnityEngine.GameObject
    local t = os.clock()   
    local go = GameObject()
    local node = go.transform
    for i = 1,100000 do
        go = node.gameObject
    end
      
    t = os.clock() - t
    print("GameObject.New lua cost time: ", t)
end



function BasicTest.Test5()   
    local array = {}
    for i = 1, 1024 do
        array[i] = i
    end
    local total = 0
    local t = os.clock()
          
    for j = 1, 100000 do
        for i = 1, 1024 do
            total = total + array[i]
        end        
    end
          
    print("Array cost time: ", os.clock() - t)
end

function BasicTest.Test6()       
    local Vector3 = Vector3
    local t = os.clock()
          
    for i = 1, 200000 do
        local v = Vector3(i,i,i)
        Vector3.Normalize(v)
    end
          
    print("Vector3 New Normalize cost time: ", os.clock() - t)
end


function BasicTest.Test7()       
    local Quaternion = Quaternion
    local t = os.clock()
      
    for i=1,200000 do
        local q1 = Quaternion.Euler(i, i, i)       
        local q2 = Quaternion.Euler(i * 2, i * 2, i * 2)
        Quaternion.Slerp(Quaternion.identity, q1, 0.5)     
    end
          
    print("Quaternion Euler Slerp const: ", os.clock() - t)    
end

function BasicTest.Test8()
    local obj = GameObject()

    local total = 0
    local t = os.clock()
    for i = 0, 10000000 do
        total = total + i - (i/2) * (i + 3) / (i + 5)
    end
    print("math cal cost: ", os.clock() - t)       
end