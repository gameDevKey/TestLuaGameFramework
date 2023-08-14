using UnityEditor;
using UnityEngine;
using System.IO;
using UnityEditor.IMGUI.Controls;
using System.Collections.Generic;

namespace Tools
{
    internal sealed class AssetDataProfiler : EditorWindow
    {
		public static AssetDataProfiler Open()
        {
            var proWin = EditorWindow.GetWindow<AssetDataProfiler>("Asset Profiler");
            proWin.Show();
            return proWin;
        }
		private readonly string root = "AssetProfiler";

		GUIContent NotificationSucces = new GUIContent("导出成功,请到工程目录中的AssetProfiler观察");

		AssetProfilerData data = new AssetProfilerData();

		UIAssetHeadView headView;

		int previousTabIndex;

		int currentTabIndex;

        Rect contentHorRect = Rect.zero;

		AssetProfilerTabBase contentTab;

        Dictionary<System.Type, AssetProfilerTabBase> tabs = 
			new Dictionary<System.Type, AssetProfilerTabBase>()
        {
            {typeof(AssetProfilerTabOverview),null},
            {typeof(AssetProfilerTabTexture),null},
            {typeof(AssetProfilerTabMesh),null},
			{typeof(AssetProfilerTabAudio),null},
			{typeof(AssetProfilerTabAnimationClip),null},
			{typeof(AssetProfilerTabModel),null},
		};

		private void OnEnable()
		{
			AssetProcessor.reimportCallBack += ImportCallBack;
			AssetProcessor.deleteCallBack += DeleteCallBack;

			previousTabIndex = 0;
			currentTabIndex = 0;

			setupAsset(AssetProfilerConfig.getPreData());

			TreeViewState state = new TreeViewState();
			this.headView = new UIAssetHeadView(state);
		}

		private void OnDisable()
		{
			AssetProcessor.reimportCallBack -= ImportCallBack;
			AssetProcessor.deleteCallBack -= DeleteCallBack;

			AssetProfilerConfig.Reset();
		}

		private void OnGUI()
		{
			GUILayout.Space(5);

			contentHorRect = new Rect(0, 0, position.width, position.height);
			//tab buttons
			var tabBtnWidth = this.contentHorRect.width * 0.15f;
			EditorGUILayout.BeginVertical(GUILayout.Width(tabBtnWidth));
			int curTabI = 0;
			var typeKeys = new List<System.Type>(this.tabs.Keys);
			foreach (var t in typeKeys)
			{
				var tab = getTab(t);
				var isSelectedTab = curTabI == this.currentTabIndex;
				if (tab.drawTabButton(isSelectedTab, GUILayout.Height(60)))
				{
					this.currentTabIndex = curTabI;
					isSelectedTab = true;
				}
				if (isSelectedTab)
				{
					contentTab = tab;
				}
				++curTabI;
			}
			if (previousTabIndex != currentTabIndex)
			{
				previousTabIndex = currentTabIndex;
				var configs = AssetProfilerConfig.getUnLoadData(contentTab.GetType());
				setupAsset(configs);
				contentTab.Refresh();
			}
			EditorGUILayout.EndVertical();

			//tab content;	
			var contentWidth = this.contentHorRect.width - tabBtnWidth;
			var contentHeight = this.position.height - this.contentHorRect.y - EditorGUIUtility.singleLineHeight * 2;	
			var cacuRect = new Rect(this.contentHorRect.x + tabBtnWidth + 4, this.contentHorRect.y, contentWidth, contentHeight);
			contentTab.drawContent(cacuRect);

			var hintStyle = new GUIStyle(EditorStyles.label);
			hintStyle.alignment = TextAnchor.MiddleRight;
			hintStyle.fontStyle = FontStyle.Normal;
			hintStyle.fontSize = 21;
			var hintHeight = EditorGUIUtility.singleLineHeight * 2;
			var bRect = new Rect(tabBtnWidth, this.position.height - hintHeight + 7, 300, hintHeight - 10);
			if (contentTab.drawExportButton(bRect))
			{
				if (!Directory.Exists(root))
				{
					Directory.CreateDirectory(root);
				}
				foreach(var kvps in tabs)
				{
					kvps.Value.exportData(root);
				}
				ShowNotification(NotificationSucces);
			}

			EditorGUI.LabelField(new Rect(0, this.position.height - hintHeight, this.position.width, hintHeight), contentTab.hintStr(), hintStyle);
		}

		AssetProfilerTabBase getTab(System.Type t)
        {
            if(this.data == null)
            {
                return null;
            }
			AssetProfilerTabBase re = null;
            if(this.tabs.TryGetValue(t, out re))
            {
                if(re == null)
                {
                    re = System.Activator.CreateInstance(t, this.data, this.headView) as AssetProfilerTabBase;
					this.tabs[t] = re;
                }
            }
            return re;
        }

		void setupAsset(AssetProfilerConfig[] configs)
		{
			HashSet<string> assetPaths = new HashSet<string>();
			bool needLoading = false;
			for (int index = 0; index != configs.Length; index++)
			{
				var config = configs[index];
				needLoading = true;
				string[] searchInFolders = config.searchInFolders;
				if (searchInFolders == null)
				{
					searchInFolders = new string[] {
						AssetProfilerWizard.GetConfig(AssetProfilerWizard.s_AssetKeys) };
				}
				var guids = AssetDatabase.FindAssets(
					config.searchPattern, searchInFolders);

				foreach (var guid in guids)
				{
					string assetPath = AssetDatabase.GUIDToAssetPath(guid);
					if (!assetPaths.Contains(assetPath))
					{
						assetPaths.Add(assetPath);
					}
				}
				config.status = AssetProfilerConfig.LoadStatus.LoadComplete;				
			}

			if(needLoading)
			{
				using (ProgressIndicator progress = new ProgressIndicator("Loading"))
				{
					progress.SetTotal(assetPaths.Count * configs.Length);

					List<UIAssetData> allObjs = new List<UIAssetData>();
					if (!progress.Show("....."))
					{
						foreach (var config in configs)
						{
							foreach (var assetPath in assetPaths)
							{
								var objs = AssetDatabase.LoadAllAssetsAtPath(assetPath);
								foreach (var obj in objs)
								{
									if (config.checkFunc(obj))
									{
										UIAssetData assetData = System.Activator.CreateInstance(config.dataType, (object)obj) as UIAssetData;
										allObjs.Add(assetData);
										break;
									}									
								}
								progress.AddProgress();
								progress.Show("Loading...");
							}
						}

						data.FillData<UITextureData>(allObjs.ToArray());
						data.FillData<UIMeshData>(allObjs.ToArray());
						data.FillData<UIAudioData>(allObjs.ToArray());
						data.FillData<UIAnimationClipData>(allObjs.ToArray());
						data.FillData<UIParticleSystemData>(allObjs.ToArray());
						data.FillData<UIModelData>(allObjs.ToArray());
					}
				}
			}
		}

		void ImportCallBack(string path)
		{
			if (!path.Contains(".scene"))
			{
				var objs = AssetDatabase.LoadAllAssetsAtPath(path);

				var configs = AssetProfilerConfig.getDatas(null, true);
				foreach (var config in configs)
				{
					foreach (var obj in objs)
					{
						if (config.checkFunc(obj))
						{
							data.CreateData<UITextureData>(obj, config.dataType);
							data.CreateData<UIMeshData>(obj, config.dataType);
							data.CreateData<UIAudioData>(obj, config.dataType);
							data.CreateData<UIAnimationClipData>(obj, config.dataType);
							data.CreateData<UIModelData>(obj, config.dataType);
						}
					}
				}
			}

			if (contentTab != null)
			{
				contentTab.Refresh();
			}
		}

		void DeleteCallBack(string path)
		{
			data.DeleteData<UITextureData>(path);
			data.DeleteData<UIMeshData>(path);
			data.DeleteData<UIAudioData>(path);
			data.DeleteData<UIAnimationClipData>(path);
			data.DeleteData<UIParticleSystemData>(path);

			if (contentTab != null)
			{
				contentTab.Refresh();
			}
		}
	}
}
