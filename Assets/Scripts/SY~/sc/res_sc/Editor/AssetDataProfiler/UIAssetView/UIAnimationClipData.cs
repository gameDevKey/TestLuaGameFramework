using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class UIAnimationClipData : UIAssetData
	{
		[SetSortId(6)]
		internal int curve;
		[SetSortId(7)]
		internal WrapMode WrapMode;
		[SetSortId(8)]
		internal float frameRate;
		[SetSortId(9)]
		internal float animationTime;

		public UIAnimationClipData(Object asset) : base(asset)
		{
		}

		internal override void SetData(BuildTarget target)
		{
			AnimationClip clip = asset as AnimationClip;

			var curves = AnimationUtility.GetCurveBindings(clip);
			curve = curves.Length;

			WrapMode = clip.wrapMode;
			frameRate = clip.frameRate;
			animationTime = clip.length;
		}
	}
}
