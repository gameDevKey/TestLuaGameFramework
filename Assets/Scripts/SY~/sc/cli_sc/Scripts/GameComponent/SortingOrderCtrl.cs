using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using XLua;

[LuaCallCSharp]
public class SortingOrderCtrl : MonoBehaviour {
    private Renderer[] _renderers;

    public int order = 0;

    private bool init = false;


    public void Awake() {
        if (!init) {
            InitRenderers();
            init = true;
        }
    }

    private void InitRenderers() {
        _renderers = GetComponentsInChildren<Renderer>();
        if (_renderers != null) {
            foreach (Renderer render in _renderers) {
                render.sortingOrder = order;
            }
        }
    }
}
