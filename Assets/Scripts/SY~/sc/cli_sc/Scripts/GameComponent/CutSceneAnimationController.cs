using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class CutSceneAnimationController : MonoBehaviour {

	public class AnimationPlayEvent : UnityEvent<string> {}
	[SerializeField]
	public int unitid = 0;
	[SerializeField]
	public int sex = 0;
	[SerializeField]
	public int classes = 0;

	private AnimationPlayEvent m_OnPlay = new AnimationPlayEvent();

	public AnimationPlayEvent onPlay
	{
		get { return m_OnPlay; }
		set { m_OnPlay = value; }
	}

	void Start () {
		m_OnPlay.AddListener ((string arg0) =>{
			Debug.Log(arg0+"成功了");
		});
	}

	public void Play(string name){
		m_OnPlay.Invoke (name);
	}

	public void Clear(){
		m_OnPlay.RemoveAllListeners();
	}
}
