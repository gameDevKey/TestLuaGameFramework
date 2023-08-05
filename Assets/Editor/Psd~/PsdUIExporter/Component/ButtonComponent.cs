using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Ntreev.Library.Psd;
using UnityEngine;
using UnityEngine.UI;

namespace PsdUIExporter {
    public class ButtonComponent : IComponent {

        public Button button = null;

        public override void AddComponent(GameObject go) {
            button = go.AddComponent<Button>();
        }
    }
}
