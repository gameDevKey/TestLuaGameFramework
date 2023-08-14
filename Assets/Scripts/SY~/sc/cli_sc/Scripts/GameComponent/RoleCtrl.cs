using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
public class RoleCtrl : MonoBehaviour, IPointerClickHandler {

	public Action onStart = null;
	public Action onDestroy = null;
	public Action onVisable = null;
	public Action onInVisable = null;
	public Action<int> triggerEnter = null;
	public Action<int> triggerStay = null;
	public Action<int> triggerExit = null;
	public Action<int, Vector3> onClick = null;
	public Action<int> collisionEnter = null;
	public Action<int> collisionStay = null;
	public Action<int> collisionExit = null;

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
		Debug.Log ("role 你看我不到");
		if (onInVisable != null) {
			onInVisable ();
		}
	}

	void OnBecameVisible() {
		Debug.Log ("role 看到了");
		if (onVisable != null) {
			onVisable ();
		}
	}

	void OnTriggerEnter(Collider other) {
		if (triggerEnter != null) {
			int id = other.gameObject.GetInstanceID ();
			// Debug.Log ("role get trigger enter ===> " + id);
			triggerEnter (id);
		}
	}

	void OnTriggerStay(Collider other) {
		if (triggerStay != null) {
			int id = other.gameObject.GetInstanceID ();
			// Debug.Log ("role get trigger stay ===> " + id);
			triggerStay (id);
		}
	}

	void OnTriggerExit(Collider other) {
		if (triggerExit != null) {
			int id = other.gameObject.GetInstanceID ();
			// Debug.Log ("role get trigger exit ===> " + id);
			triggerExit (id);
		}
	}

	public void OnPointerClick(PointerEventData eventData) {
		if (onClick != null) {
			RaycastHit hitInfo;
			float validTouchDistance = 200;
			Ray ray =  Game.Logic.GameContext.GetInstance().MainCamera.ScreenPointToRay(Input.mousePosition);  //摄像机需要设置MainCamera的Tag这里才能找到
			if (Physics.Raycast(ray, out hitInfo, validTouchDistance, LayerMask.GetMask("Default"))) {
			    GameObject gameObj = hitInfo.collider.gameObject;
			}
			int id = eventData.pointerPress.GetInstanceID ();
			onClick (id, hitInfo.point);
		}
	}
}