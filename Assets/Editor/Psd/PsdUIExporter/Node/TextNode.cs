using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

namespace PsdUIExporter {
    class TextNode : AbstractNode {

        public TextComponent textComp = null;

        public TextNode(OperableVO operVo, PsdLayer layer, INode parentRect) : base(operVo, layer, parentRect) {
        }

        public override void AddComponent() {
            textComp = new TextComponent(layer.Records.TextInfo);
            textComp.AddComponent(gameObject);
            SetTransform();

            base.AddComponent();
        }

        private void SetTransform() {
            Vector3 anc = gameObject.GetComponent<RectTransform>().anchoredPosition3D;
            float widthScale = 1;
            if (!IsOneline()) {
                widthScale = 1.05f;
            }
            else {
                textComp.text.horizontalOverflow = HorizontalWrapMode.Overflow;
            }
            int fontSize = this.textComp.textInfo.fontSize;
            if (textComp.fontName.ToLower().Contains(ExportContext.GetInstance().GetConfigVo().fontSpecialKey)) {
                float width = rect.width * widthScale + 1.6f;
                float height = rect.height + 2f;
                if (IsOneline()) {
                    height = (fontSize - 14) * 1.23f + 17;
                }
                gameObject.GetComponent<RectTransform>().anchoredPosition3D = new Vector3(anc.x + (width - rect.width)/2, anc.y - (height - rect.height)/2, anc.z);
        	    gameObject.GetComponent<RectTransform>().sizeDelta = new Vector2(width, height);
        	} else {
                float width = rect.width * widthScale + 2;
                float height = rect.height * 1.17f + 2;
        	    gameObject.GetComponent<RectTransform>().anchoredPosition3D = new Vector3(anc.x + (width - rect.width)/2, anc.y - (height - rect.height)/2, anc.z);
        	    gameObject.GetComponent<RectTransform>().sizeDelta = new Vector2(width, height);
        	}
        }

        public void CreatePrefab() {
            base.CreatePrefab();
        }

        private bool IsOneline() {
            string tx = this.textComp.textInfo.text;
            if (tx.Contains("\r")) {
                return false;
            } else {
                return true;
            }
        }
    }
}
