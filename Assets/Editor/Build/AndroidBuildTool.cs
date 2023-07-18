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
}