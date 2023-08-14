using UnityEngine;
using UnityEngine.UI;
using System.Collections;

/// <summary>
/// 用作全透明的图片，如透明按钮中的热区范围。
/// 这种写法将完全不产生DrawCall
/// </summary>
namespace Game.UI {
    public class DummyImage : Image {

        protected override void OnPopulateMesh(VertexHelper toFill) {
            //Left blank
            toFill.Clear();
        }
    }
}
