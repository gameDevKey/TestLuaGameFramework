using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class UIAudioData : UIAssetData
	{
		[SetSortId(3)]
		internal AudioClipLoadType loadType;

		[SetSortId(4)]
		internal AudioCompressionFormat compressionFormat;

		[SetSortId(5)]
		internal float quality;

		[SetSortId(6)]
		internal float audioTime;

		[SetSortId(7)]
		internal uint sampleRateOverride;

		[SetSortId(8)]
		internal float OriginalSize;


		[SetSortId(11)]
		internal AudioSampleRateSetting sampleRateSetting;

		[SetSortId(12)]
		internal bool preloadAudioData;
		
		public UIAudioData(Object asset) : base(asset)
		{
		}

		internal override void SetData(BuildTarget target)
		{
			this.platform = target == BuildTarget.NoTarget ? this.platform : target;
			AudioClip clip = asset as AudioClip;
			if (clip == null)
				return;

			preloadAudioData = clip.preloadAudioData;
			audioTime = clip.length;

			var fileInfo = new FileInfo(assetPath);
			OriginalSize = (float)fileInfo.Length / 1024;

			AudioImporter import = importer as AudioImporter;

			var setting = import.GetOverrideSampleSettings(this.platform.ToString());

			loadType = setting.loadType;
			sampleRateOverride = setting.sampleRateOverride;
			compressionFormat = setting.compressionFormat;
			quality = setting.quality * 100;
			sampleRateSetting = setting.sampleRateSetting;
		}
	}
}
