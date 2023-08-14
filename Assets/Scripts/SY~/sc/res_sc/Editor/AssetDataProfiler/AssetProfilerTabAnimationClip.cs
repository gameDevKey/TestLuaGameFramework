using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class AssetProfilerTabAnimationClip : AssetProfilerTab<UIAnimationClipData>
	{
		public AssetProfilerTabAnimationClip(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
		{
		}

		protected override string tabName()
		{
			return "动画";
		}
	}
}
