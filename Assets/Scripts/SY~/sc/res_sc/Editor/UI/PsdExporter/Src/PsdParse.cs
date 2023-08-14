using Ntreev.Library.Psd;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace ShanShuo.PsdExporter
{
    public class PsdParse
    {
        public string filePath;
        public string fileName;
        public List<LayerNode> nodes = new List<LayerNode>();

        public List<string> errors = new List<string>();

        int index;

        public void Parse(string file)
        {
            filePath = file;

            PsdDocument document = PsdDocument.Create(file);

            fileName = IOUtils.GetFileName(file);

            //foreach (PsdLayer layer in document.Childs)
            //{
            //    ParseLayer(layer, null);
            //}

            try
            {
                foreach (PsdLayer layer in document.Childs)
                {
                    ParseLayer(layer, null);
                }
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                document.Dispose();
            }
        }

        private void ParseLayer(PsdLayer layer, LayerNode parent)
        {
            if (!layer.IsVisible)
            {
                return;
            }

            checkLinkLayer(layer);
            checkMask(layer);

            LayerNode node;

            switch (layer.LayerType)
            {
                case LayerType.Text:
                    node = new TextNode(++index,layer, parent) ;
                    break;
                case LayerType.Group:
                    node = new GroupNode(0,layer, parent);
                    break;
                case LayerType.Complex:
                case LayerType.Color:
                case LayerType.Normal:
                    node = new ImageNode(++index,layer, parent);
                    break;
                default:
                    throw new Exception("解析Psd图层异常，无法识别的图层类型:" + layer.LayerType);
            }

            if(node.alpha <= 0.1f)
            {
                return;
            }

            if(layer.LayerType != LayerType.Group)
            {
                nodes.Add(node);
            }

            if (node != null && layer.Childs.Length > 0)
            {
                foreach (PsdLayer child in layer.Childs)
                {
                    ParseLayer(child,node);
                }
            }
        }

        void checkLinkLayer(PsdLayer psdLayer)
        {
            if(psdLayer.LinkedLayer != null)
            {
                string error = string.Format("禁止链接图层[{0}]",psdLayer.Name);
                errors.Add(error);
            }
        }

        void checkMask(PsdLayer psdLayer)
        {
            if (psdLayer.HasMask)
            {
                string error = string.Format("禁止遮罩图层[{0}]", psdLayer.Name);
                errors.Add(error);
            }
        }

        public void HasError()
        {
            if (errors.Count <= 0)
            {
                return;
            }

            StringBuilder err = new StringBuilder();
            err.AppendLine(string.Format("Psd文件解析异常[{0}]:", filePath));
            foreach (var error in errors)
            {
                err.AppendLine(error.ToString());
            }
            throw new Exception(err.ToString());
        }
    }
}

