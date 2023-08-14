using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrialClear : MonoBehaviour {

	private TrailRenderer tr;
	// Use this for initialization
	void OnEnable () {
		if (tr == null)
			tr = GetComponent<TrailRenderer>();
		if (tr != null)
			tr.Clear();
	}

}
