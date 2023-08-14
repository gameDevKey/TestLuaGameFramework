using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEditor;
using Ntreev.Library.Psd;

namespace PsdUIExporter {
    public class PsdUITExporter {

        public string path = "E:/data/psd.dev/psd/pet_changename.psd";
        // private Rect rootSize = new Rect();


        // [MenuItem("PsdTools/PsdUIExporter")]
        public static void Exporter() {
            PsdUITExporter exporter = new PsdUITExporter();
            exporter.ParsePsd();
        }

        //==============================================================================
        public PsdUITExporter() {
        }

        private RootNode rootNode = null;
        public void ParsePsd() {
            using (PsdDocument document = PsdDocument.Create(path)) {
                rootNode = new RootNode("TestName");
        	    foreach (PsdLayer layer in document.Childs) {
                    ParseLayer(layer, rootNode);
        	    }
        	}
        }

        private void ParseLayer(PsdLayer layer, INode parentNode) {
            INode node = null;
            if (ExportUtility.IsNoexportLayer(layer)) {
                return;
            }
            OperableVO operVo = new OperableVO();
            switch (layer.LayerType) {
                case LayerType.Text:
                    node = new TextNode(operVo, layer, parentNode);
                    parentNode.AddChild(node);
                    break;
                case LayerType.Group:
                    node = new GroupNode(operVo, layer, parentNode);
                    parentNode.AddChild(node);
                    break;
                case LayerType.Complex:
                case LayerType.Color:
                case LayerType.Normal:
                    node = new ImageNode(operVo, layer, parentNode);
                    parentNode.AddChild(node);
                    break;
                default:
                    throw new Exception("psd图层类型异常，无法识别:" + layer.LayerType);
            }
            if (node != null && layer.Childs.Length > 0) {
        	    foreach (PsdLayer child in layer.Childs) {
            	    ParseLayer(child, node);
        		}
            }
        }
    }
}
