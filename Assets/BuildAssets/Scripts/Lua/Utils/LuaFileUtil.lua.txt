LuaFileUtil = StaticClass("LuaFileUtil")

--引用了lua的lfs库，要看看lfs.dll有没有打进项目里，没有的话用CsFileUtil
LFS = require("lfs")

function LuaFileUtil.FindAllFile(dir, pattern, output)
    for entry in LFS.dir(dir) do
        if entry ~= '.' and entry ~= '..' then
            local path = dir .. "\\" .. entry
            local attr = LFS.attributes(path)
            assert(type(attr) == "table") --如果获取不到属性表则报错
            if attr.mode == "directory" then
                LuaFileUtil.FindAllFile(path, pattern, output)
            elseif attr.mode == "file" then
                if string.find(entry, pattern) then
                    table.insert(output, path)
                end
            end
        end
    end
end

return LuaFileUtil