using System;
using System.Collections.Generic;
using UnityEditor;

namespace Tools
{
	internal class AssetProfilerTabMesh : AssetProfilerTab<UIMeshData>
    {
		public AssetProfilerTabMesh(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
		{
		}

		protected override string tabName()
        {
            return "网格";
        }
    }
}
