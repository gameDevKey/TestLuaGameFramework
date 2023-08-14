using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AndroidNotchAgent
{
	public delegate void UpdateNotchCallBack(bool isSupport,bool hideNotch,int notchWidth,int notchHeight);
	private event UpdateNotchCallBack notchlayoutChange;

	private AndroidJavaObject activity;
	private NotchAgentEventListener javaListener;

	private static AndroidNotchAgent instance;

	private static AndroidNotchAgent Instance
	{
		get
		{
			if(instance == null)
			{
				instance = new AndroidNotchAgent();
#if !UNITY_EDITOR && UNITY_ANDROID
				
				AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.notchadaptation.AdapterManager");
				instance.activity = jc.CallStatic<AndroidJavaObject>("getAdapter");
				instance.javaListener = new NotchAgentEventListener();

				jc.CallStatic("SetEventListener", instance.javaListener);
				jc.CallStatic("initDisplayCutoutMode");
#endif
			}
			return instance;
		}
	}

	public static event UpdateNotchCallBack NotchLayerChange
	{
		add
		{
			Instance.notchlayoutChange += value;		
		}
		remove
		{
			Instance.notchlayoutChange -= value;
		}
	}

	public static bool supportNotch
	{
		get
		{
			var java_activity = Instance.activity;
			if (java_activity != null)
			{
				return java_activity.Call<bool>("isSupportNotch");
			}
			return false;
		}
	}

	public static bool isHideNotch
	{
		get
		{
			var java_activity = Instance.activity;
			if (java_activity != null)
			{
				return java_activity.Call<bool>("isHideNotch");
			}
			return false;
		}
	}
	public static int notchWidth
	{
		get
		{
			var java_activity = Instance.activity;
			if (java_activity != null)
			{
				return java_activity.Call<int>("getNotchWidth");
			}
			return 0;
		}
	}
	public static int notchHeight
	{
		get
		{
			var java_activity = Instance.activity;
			if (java_activity != null)
			{
				return java_activity.Call<int>("getNotchHeigth");
			}
			return 0;
		}
	}

	private class NotchAgentEventListener : AndroidJavaProxy
	{
		public NotchAgentEventListener() :base("com.unity3d.notchadaptation.IEventListener")
		{
		}

		public void OnLayoutChange()
		{
			if (Instance.notchlayoutChange != null)
			{
				Instance.notchlayoutChange.Invoke(supportNotch, isHideNotch, notchWidth, notchHeight);
			}
		}
	}
}

