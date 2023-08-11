using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Ntreev.Library.Psd;
using UnityEngine;
using UnityEngine.UI;

namespace PsdUIExporter {
    class TextComponent : IComponent {

        public TextInfo textInfo = null;
        public Color color;
        public int fontSize = 16;
        public String fontName = null;

        public Text text = null;

        public TextComponent(TextInfo textInfo) {
            this.textInfo = textInfo;
            color = new Color(textInfo.color[0], textInfo.color[1], textInfo.color[2], textInfo.color[3]);
            fontSize = textInfo.fontSize;
            fontName = textInfo.fontName;
        }

        public override void AddComponent(GameObject go) {
            text = go.AddComponent<Text>();
            if (fontName != null && fontName.ToLower().Contains(ExportContext.GetInstance().GetConfigVo().fontSpecialKey)) {
                text.fontSize = fontSize;
                text.font = ExportContext.GetInstance().GetFont(ExportContext.GetInstance().GetConfigVo().fontSpecialKey);
            } else {
                text.fontSize = fontSize;
                text.font = ExportContext.GetInstance().GetFont(ExportContext.GetInstance().GetConfigVo().fontNormalKey);
            }
            text.color = this.color;
            text.text = this.textInfo.text.Replace("\r", "\n");
            text.raycastTarget = false;
        }
    }
}
