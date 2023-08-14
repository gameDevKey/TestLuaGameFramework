using System.Collections.Generic;
using UnityEditor;
using System;
using UnityEngine;


namespace Tools
{
	internal class AssetProfilerTabTexture : AssetProfilerTab<UITextureData>
	{
        public AssetProfilerTabTexture(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
		{	
        }

		protected override string tabName()
		{
			return "贴图";
		}

		protected override bool platformTag()
		{
			return true;
		}
	}
}
