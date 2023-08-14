using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Tools
{
	internal sealed class AssetProfilerConfig 
	{
		internal enum LoadStatus
		{
			Preload,
			NoLoad,
			LoadComplete
		}

		internal LoadStatus status;
		internal string labelName;
		internal string searchPattern;
		internal string searchFolder;

		internal System.Type tagType;
		internal System.Type dataType;

		internal System.Func<Object, bool> checkFunc;

		internal string [] searchInFolders
		{
			get
			{
				if (!string.IsNullOrEmpty(searchFolder))
				{
					return new string[]
					{
						AssetProfilerWizard.GetConfig(searchFolder)
					};
				}
				return null;
			}
		}


		static AssetProfilerConfig[] configs = new AssetProfilerConfig[] {
			new AssetProfilerConfig() {
				status = LoadStatus.Preload, labelName = "贴图", searchPattern = "t:Texture",
				tagType = typeof(AssetProfilerTabTexture),  dataType = typeof(UITextureData),
				checkFunc = (obj) =>{   return obj.GetType() == typeof(Texture) || obj.GetType() == typeof(Texture2D); }
			},

			new AssetProfilerConfig() {
				status = LoadStatus.Preload,labelName = "网格", searchPattern = "t:Mesh",
				tagType = typeof(AssetProfilerTabMesh), dataType = typeof(UIMeshData),
				checkFunc = (obj) =>  { return obj.GetType() == typeof(Mesh); } },

			new AssetProfilerConfig() {
				status = LoadStatus.Preload,labelName = "音频", searchPattern = "t:AudioClip",
				tagType = typeof(AssetProfilerTabAudio),  dataType = typeof(UIAudioData),
				checkFunc = (obj) =>  { return obj.GetType() == typeof(AudioClip); } },

			new AssetProfilerConfig() {
				status = LoadStatus.Preload,labelName = "动画",searchPattern = "t:AnimationClip",
				tagType = typeof(AssetProfilerTabAnimationClip),  dataType = typeof(UIAnimationClipData),
				checkFunc = (obj) =>  { return obj.GetType() == typeof(AnimationClip) && obj.name != "__preview__Take 001"; } },

			new AssetProfilerConfig() {
				status = LoadStatus.Preload,labelName = "模型",searchPattern = "t:Model",
				tagType = typeof(AssetProfilerTabModel), dataType = typeof(UIModelData),
				checkFunc = (obj) =>  {
					string path = AssetDatabase.GetAssetPath(obj);
					var importer = AssetImporter.GetAtPath(path);
					if(importer is ModelImporter && AssetDatabase.IsMainAsset(obj))
						return true;
					return false;
			} }
		};

		internal static AssetProfilerConfig[] getDatas(int[] indexs, bool allowAllConfig = false)
		{
			List<AssetProfilerConfig> dataList = new List<AssetProfilerConfig>();
			if (!allowAllConfig)
			{
				foreach (var index in indexs)
				{
					if (index < configs.Length)
					{
						dataList.Add(configs[index]);
					}
				}
			}else{
				dataList.AddRange(configs);
			}
			return dataList.ToArray();
		}

		internal static AssetProfilerConfig[] getPreData()
		{
			List<AssetProfilerConfig> dataList = new List<AssetProfilerConfig>();
			foreach (var config in configs)
			{
				if(config.status == LoadStatus.Preload)
				{
					dataList.Add(config);
				}
			}
			return dataList.ToArray();
		}

		internal static AssetProfilerConfig[] getUnLoadData(System.Type type)
		{
			List<AssetProfilerConfig> dataList = new List<AssetProfilerConfig>();
			foreach (var config in configs)
			{
				if (config.tagType == type && config.status == LoadStatus.NoLoad)
				{
					dataList.Add(config);
				}
			}
			return dataList.ToArray();
		}

		internal static void Reset()
		{
			List<AssetProfilerConfig> dataList = new List<AssetProfilerConfig>();
			foreach (var config in configs)
			{
				config.status = LoadStatus.Preload;
			}
		}
	}
}
