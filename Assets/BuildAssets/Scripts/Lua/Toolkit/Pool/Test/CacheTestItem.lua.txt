CacheTestItem = Class("CacheTestItem",CacheItemBase)

CacheTestItem._cache_defaults = {
    TestField1 = "TestField1",
    TestField2 = "TestField2",
}

CacheTestItem._cache_nils = {
    TestField3 = true,
}

function CacheTestItem:OnInit()
    PrintLog("创建CacheTestItem",self)
    self.TestField1 = "a"
    self.TestField2 = "b"
    self.TestField3 = "c"
end

function CacheTestItem:OnDelete()
    PrintLog("删除CacheTestItem",self)
end

function CacheTestItem:OnUse()
    PrintLog("使用CacheTestItem",self)
end

function CacheTestItem:OnRecycle()
    PrintLog("回收CacheTestItem",self)
end

return CacheTestItem