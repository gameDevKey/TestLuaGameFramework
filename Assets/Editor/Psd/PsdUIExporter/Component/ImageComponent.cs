using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Ntreev.Library.Psd;
using UnityEngine;
using UnityEngine.UI;

namespace PsdUIExporter {
    public class ImageComponent : IComponent {

        public Image image = null;

        public ImageComponent() {
        }

        public override void AddComponent(GameObject go) {
            image = go.AddComponent<Image>();
            image.raycastTarget = false;
        }
    }
}
