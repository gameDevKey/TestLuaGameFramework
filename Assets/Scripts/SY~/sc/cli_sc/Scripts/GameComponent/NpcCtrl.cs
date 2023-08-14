using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
public class NpcCtrl : MonoBehaviour, IPointerClickHandler {

	public Action onStart = null;
	public Action onDestroy = null;
	public Action onVisable = null;
	public Action onInVisable = null;
	public Action<int> onClick = null;
	public Action<int> triggerEnter = null;
	public Action<int> triggerStay = null;
	public Action<int> triggerExit = null;

	void Start() {
		if (onStart != null) {
			onStart ();
		}
	}

	void OnDestory() {
		if (onDestroy != null) {
			onDestroy ();
		}
	}

	void OnBecameInvisible() {
		Debug.Log ("npc 你看我不到");
		if (onInVisable != null) {
			onInVisable ();
		}
	}

	void OnBecameVisible() {
		Debug.Log ("npc 又看见了");
		if (onVisable != null) {
			onVisable ();
		}
	}
	
	void OnTriggerEnter(Collider other) {
		if (triggerEnter != null) {
			int id = other.gameObject.GetInstanceID ();
//			Debug.Log ("npc get trigger enter ===> " + id);
			triggerEnter (id);
		}
	}

	void OnTriggerStay(Collider other) {
		if (triggerStay != null) {
			int id = other.gameObject.GetInstanceID ();
//			Debug.Log ("npc get trigger stay ===> " + id);
			triggerStay (id);
		}
	}

	void OnTriggerExit(Collider other) {
		if (triggerExit != null) {
			int id = other.gameObject.GetInstanceID ();
//			Debug.Log ("npc get trigger exit ===> " + id);
			triggerExit (id);
		}
	}

	public void OnPointerClick(PointerEventData eventData) {
//        RaycastHit hitInfo;
//        float validTouchDistance = 200;
//        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);  //摄像机需要设置MainCamera的Tag这里才能找到
//        if (Physics.Raycast(ray, out hitInfo, validTouchDistance, LayerMask.GetMask("Default"))) {
//            GameObject gameObj = hitInfo.collider.gameObject;
//            Vector3 hitPoint = hitInfo.point;
//            Click(hitPoint);
//        }
		if (onClick != null) {
			int id = eventData.pointerPress.GetInstanceID ();
			onClick (id);
		}
	}
}