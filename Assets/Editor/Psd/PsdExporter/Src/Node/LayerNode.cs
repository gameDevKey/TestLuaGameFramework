using Ntreev.Library.Psd;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayerNode
{
    public LayerNode parent;

    public Rect rect;

    public string name;
    public string objName;
    public int index;

    public float alpha;

    public PsdLayer layer;

    public LayerNode(int index, PsdLayer layer, LayerNode parent)
    {
        this.index = index;
        this.layer = layer;
        this.parent = parent;

        setLayerName();

        setAlpha();

        rect = PsdExporterUtils.GetRectFromLayer(layer, parent);
    }

    void setLayerName()
    {
        name = EditorUtil.GetValidName(layer.Name);
        if (!name.Equals(layer.Name))
        {
            Debug.LogError($"图层【{layer.Name}】名字非法，转换成:{name}");
        }
    }

    void setAlpha()
    {
        alpha = layer.Opacity;
        Channel aChannel = Array.Find(layer.Channels, i => i.Type == ChannelType.Alpha);
        if (aChannel != null)
        {
            alpha *= aChannel.Opacity;
        }
    }
}





//public virtual void OnDestroy()
//{
//    foreach (var v in defineVariables)
//    {
//        v.OnDestroy();
//    }
//}


