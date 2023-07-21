using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class AndroidBuildTool : BuildToolBase
{
    public override void Build()
    {
        BuildUtils.HandleLua();
    }

    void OnEnable()
    {
        Init(BuildConfig.ANDROID_DATA_OBJ_NAME);
        this.name = "安卓平台";
    }

    void OnGUI()
    {
        DrawDataObjectArea();
        DrawButton("确定", Build, "构建");
    }
}