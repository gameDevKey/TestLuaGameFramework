using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Reflection;

namespace Tools
{
	internal sealed class AssetProfilerWizard : ScriptableWizard {
		 
		//public static readonly string s_EffectKeys = "c_AssetProfilerEffect";
		public static readonly string s_AssetKeys = "c_AssetProfilerAsset";

		private AssetProfilerConfig[] configs;
		private DefaultAsset assetConfig;
		//private DefaultAsset effectConfig;
		private bool isOpenOtherWindow = false;

		[MenuItem("Tool/AssetProfiler")]
		static void Open()
		{
			DisplayWizard<AssetProfilerWizard>("AssetProfilerWizard", "打开");
		}

		private void OnEnable()
		{
			configs = AssetProfilerConfig.getDatas(null, true);
			//effectConfig = CheckConfig(s_EffectKeys);
			assetConfig = CheckConfig(s_AssetKeys);
			if(assetConfig == null)
			{
				SetConfig(s_AssetKeys, "Assets");
				assetConfig = CheckConfig(s_AssetKeys);
			}
		}

		private void OnDisable()
		{
			if (!isOpenOtherWindow)
			{
				AssetProfilerConfig.Reset();
			}
		}

		void OnWizardCreate()
		{
			isOpenOtherWindow = true;
			AssetDataProfiler.Open();
			EditorWindow.DestroyImmediate(this);	
		}

		void OnWizardUpdate()
		{
			//if (effectConfig != null)
			//{
			//	SetConfig(s_EffectKeys, AssetDatabase.GetAssetPath(effectConfig));
			//}

			if (assetConfig != null)
			{
				SetConfig(s_AssetKeys, AssetDatabase.GetAssetPath(assetConfig));
			}
		}

		DefaultAsset CheckConfig(string key)
		{
			string value = EditorPrefs.GetString(key);
		    if (!string.IsNullOrEmpty(value))
			{
				var checkAsset = AssetDatabase.LoadAssetAtPath<DefaultAsset>(value);
				if(checkAsset != null)
				{
					return checkAsset;
				}				
			}
			return null;
		}

		public static string GetConfig(string key)
		{
			return EditorPrefs.GetString(key);
		}

		void SetConfig(string key, string value)
		{
			EditorPrefs.SetString(key, value);
		}

		protected override bool DrawWizardGUI()
		{
			EditorGUILayout.BeginVertical(GUI.skin.box);

			GUILayout.Label("预加载的资源条: ");
			foreach(var config in configs)
			{
				GUILayout.BeginHorizontal();
				GUILayout.Label(config.labelName + " :");
				bool isPre = config.status == AssetProfilerConfig.LoadStatus.Preload;
				bool curisPre = GUILayout.Toggle(isPre, new GUIContent());
				if(curisPre != isPre)
				{
					config.status = curisPre ? AssetProfilerConfig.LoadStatus.Preload : AssetProfilerConfig.LoadStatus.NoLoad;
				}		
				GUILayout.EndHorizontal();
			}
			EditorGUILayout.EndVertical();

			assetConfig = EditorGUILayout.ObjectField("资源目录", assetConfig, typeof(DefaultAsset), true) as DefaultAsset;
			//effectConfig = EditorGUILayout.ObjectField("特效目录", effectConfig, typeof(DefaultAsset), true) as DefaultAsset;

			return true;
		}
	}
}
	