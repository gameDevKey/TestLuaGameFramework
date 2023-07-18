CsFileUtil = StaticClass("CsFileUtil")

local fileUtils = CS.FileUtils
local io = CS.System.IO

local currentDir = nil
function CsFileUtil.GetCurrentDir()
    if not currentDir then
        currentDir = fileUtils.GetCurrentDir()
    end
    return currentDir
end

function CsFileUtil.FindAllFile(dir, pattern)
    return fileUtils.GetAllFile(dir, pattern)
end

function CsFileUtil.GetAllFilePath(dir, pattern)
    return io.Directory.GetFiles(dir, pattern, io.SearchOption.AllDirectories)
end

return CsFileUtil