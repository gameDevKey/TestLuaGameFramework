using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Tools
{
    internal class AssetProfilerTabOverview : AssetProfilerTabBase
    {
		public AssetProfilerTabOverview(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
        {

        }

        protected override string tabName()
        {
            return "总览";
        }

        protected override void initGUI()
        {			
		}

        protected override void onGUI(Rect rect)
        {
			var st = new GUIStyle(EditorStyles.label);
            var sizeHold = st.fontSize;
            var heHold = st.fixedHeight;
			st.fontSize = 30;
            st.fixedHeight = st.fontSize * 2;
			st.fontStyle = FontStyle.Normal;
			st.alignment = TextAnchor.MiddleLeft;

			rect.height = EditorGUIUtility.singleLineHeight * 3;

			int count = data.getDataList<UITextureData>() != null ? data.getDataList<UITextureData>().Length : 0;
			EditorGUI.LabelField(rect, "贴图总数:" + count, st);
			rect.y = rect.yMax;

			count = data.getDataList<UIMeshData>() != null ? data.getDataList<UIMeshData>().Length : 0;
			EditorGUI.LabelField(rect, "网格总数:" + count, st);
			rect.y = rect.yMax;

			count = data.getDataList<UIAudioData>() != null ? data.getDataList<UIAudioData>().Length : 0;
			EditorGUI.LabelField(rect, "音效总数:" + count, st);
			rect.y = rect.yMax;

			count = data.getDataList<UIAnimationClipData>() != null ? data.getDataList<UIAnimationClipData>().Length : 0;
			EditorGUI.LabelField(rect, "动画总数:" + count, st);
			rect.y = rect.yMax;

			count = data.getDataList<UIModelData>() != null ? data.getDataList<UIModelData>().Length : 0;
			EditorGUI.LabelField(rect, "模型总数:" + count, st);

			st.fontSize = sizeHold;
            st.fixedHeight = heHold;
        }
    }
}
