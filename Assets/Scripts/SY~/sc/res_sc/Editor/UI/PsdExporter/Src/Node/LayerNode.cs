using Ntreev.Library.Psd;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShanShuo.PsdExporter
{
    public class LayerNode
    {
        public LayerNode parent;

        public Rect rect;

        public string name;
        public string objName;
        public int index;

        public float alpha;

        public PsdLayer layer;

        public LayerNode(int index,PsdLayer layer, LayerNode parent)
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
            name = layer.Name;
            name = name.Replace(" ","");
            name = name.Replace("¿½±´", "");

            int beginIndex = name.IndexOf("(");
            if(beginIndex == -1)
            {
                beginIndex = name.IndexOf("£¨");
            }

            int endIndex = name.IndexOf(")");
            if (endIndex == -1)
            {
                endIndex = name.IndexOf("£©");
            }

            if(beginIndex != -1 && endIndex != -1)
            {
                name = name = name.Substring(0, beginIndex);
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
    }

