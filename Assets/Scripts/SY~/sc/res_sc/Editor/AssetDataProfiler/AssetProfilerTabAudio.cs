using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class AssetProfilerTabAudio : AssetProfilerTab<UIAudioData>
	{
		public AssetProfilerTabAudio(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
		{			
		}

		protected override string tabName()
		{
			return "音效";
		}

		protected override bool platformTag()
		{
			return true;
		}
	}
}
