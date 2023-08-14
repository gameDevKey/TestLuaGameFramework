using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// 用于UI面片特效根据屏幕分辨率进行缩放
/// </summary>
public class UIEffectScale : MonoBehaviour {
	
	public float screenx = 1280;
	public float screeny = 720;
	// Use this for initialization
	void Start () {
		float scalefactor = (float)Screen.width / (float)Screen.height;
		transform.localScale = new Vector3 (scalefactor/(screenx/screeny) * transform.localScale.x , transform.localScale.y, 1);
	}
}
