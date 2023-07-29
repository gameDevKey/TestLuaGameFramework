using Ntreev.Library.Psd;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShanShuo.PsdExporter
{
    public class PsdExporterUtils
    {
        public static GameObject CreateGameObject(string name, Rect rect, Vector2 pivot, Vector2 anchorMax, Vector2 anchorMin)
        {
            GameObject go = new GameObject();
            go.layer = UnityEngine.LayerMask.NameToLayer("UI");
            go.name = name;
            RectTransform rectTrans = go.AddComponent<RectTransform>();
            rectTrans.pivot = pivot;
            rectTrans.anchorMax = anchorMax;
            rectTrans.anchorMin = anchorMin;
            if (rect.width == 0 && rect.height == 0)
            {
                rectTrans.offsetMin = Vector2.zero;
                rectTrans.offsetMax = Vector2.zero;
            }
            else
            {
                rectTrans.sizeDelta = new Vector2(rect.width, rect.height);
            }
            rectTrans.anchoredPosition3D = new Vector3(rect.x, rect.y, 0);
            rectTrans.localScale = Vector3.one;
            return go;
        }

        public static Texture2D CreateTexture(PsdLayer layer)
        {
            Debug.Assert(layer.Width != 0 && layer.Height != 0, layer.Name + ": width = height = 0");
            if (layer.Width == 0 || layer.Height == 0) return new Texture2D(layer.Width, layer.Height);

            Texture2D texture = new Texture2D(layer.Width, layer.Height);
            Color32[] pixels = new Color32[layer.Width * layer.Height];

            Channel red = Array.Find(layer.Channels, i => i.Type == ChannelType.Red);
            Channel green = Array.Find(layer.Channels, i => i.Type == ChannelType.Green);
            Channel blue = Array.Find(layer.Channels, i => i.Type == ChannelType.Blue);
            Channel alpha = Array.Find(layer.Channels, i => i.Type == ChannelType.Alpha);

            //Channel mask = Array.Find(layer.Channels, i => i.Type == ChannelType.Mask);

            //if (layer.HasMask && alpha != null && alpha.Data != null)
            //{
            //    Debug.Log(mask.Data.Length + ":" + alpha.Data.Length);
            //}
            for (int i = 0; i < pixels.Length; i++)
            {
                var redErr = red == null || red.Data == null || red.Data.Length <= i;
                var greenErr = green == null || green.Data == null || green.Data.Length <= i;
                var blueErr = blue == null || blue.Data == null || blue.Data.Length <= i;
                var alphaErr = alpha == null || alpha.Data == null || alpha.Data.Length <= i;

                byte r = redErr ? (byte)0 : red.Data[i];
                byte g = greenErr ? (byte)0 : green.Data[i];
                byte b = blueErr ? (byte)0 : blue.Data[i];
                byte a = alphaErr ? (byte)255 : alpha.Data[i];

                int mod = i % texture.width;
                int n = ((texture.width - mod - 1) + i) - mod;
                pixels[pixels.Length - n - 1] = new Color32(r, g, b, a);
            }

            texture.SetPixels32(pixels);
            texture.Apply();
            return texture;
        }

        /// <summary>
        /// 解析Layer中的尺寸信息
        /// 以中间锚点为计算方式
        /// </summary>
        /// <param name="psdLayer"></param>
        /// <returns></returns>
        public static Rect GetRectFromLayer(IPsdLayer psdLayer, LayerNode parentNode)
        {
            //rootSize = new Vector2(rootSize.x > maxSize.x ? maxSize.x : rootSize.x, rootSize.y > maxSize.y ? maxSize.y : rootSize.y);
            var left = psdLayer.Left;// psdLayer.Left <= 0 ? 0 : psdLayer.Left;
            var bottom = psdLayer.Bottom;// psdLayer.Bottom <= 0 ? 0 : psdLayer.Bottom;
            var top = psdLayer.Top;// psdLayer.Top >= rootSize.y ? rootSize.y : psdLayer.Top;
            var rigtht = psdLayer.Right;// psdLayer.Right >= rootSize.x ? rootSize.x : psdLayer.Right;
            var width = psdLayer.Width;// psdLayer.Width > rootSize.x ? rootSize.x : psdLayer.Width;
            var height = psdLayer.Height;// psdLayer.Height > rootSize.y ? rootSize.y : psdLayer.Height;

            // var xMin = (rigtht + left - parentRect.width) * 0.5f;
            // var yMin = -(top + bottom - parentRect.height) * 0.5f;
            //Vector2 pa = GetParenRectAddition(parentNode);
            var xMin = (left + width * 0.5f) - (PsdExporterProxy.Instance.setting.width * 0.5f);
            var yMin = (PsdExporterProxy.Instance.setting.height * 0.5f) - (top + height * 0.5f);
            return new Rect(xMin, yMin, width, height);
        }

        //public static Vector2 GetParenRectAddition(LayerNode node)
        //{
        //    if(node == null)
        //    {
        //        return Vector2.zero;
        //    }
        //    else if (node.parent == null)
        //    {
        //        return new Vector2(node.rect.width  * 0.5f, node.rect.height  * 0.5f);
        //    }
        //    else
        //    {
        //        Vector2 parent = GetParenRectAddition(node.parent);
        //        return new Vector2(parent.x + node.rect.x, parent.y - node.rect.y);
        //    }
        //}

        //public static byte[] EncordToPng(this Texture2D texture)
        //{
        //    return texture.EncodeToPNG();
        //}
    }
}


