using UnityEditor;
using UnityEngine;

namespace SYpackage.Character
{
    [CustomEditor(typeof(CharacterLight))]
    public class CharacterLightEditor : Editor
    {
        #region Static
        static GUIStyle titleLabelSunStyle, titleLabelEnvStyle, titleLabelOtherStyle;
        static Color titleColorSun;
        static Color titleColorEnv;
        static Color titleColorOther;
        static Color uiColorOther;
        #endregion

        #region SerializedProperty

        //自定义主光
        private SerializedProperty lightSourceType;
        private SerializedProperty eulerValue;
        private SerializedProperty isShowDirGUI;
        
        private SerializedProperty isCustomColor;
        private SerializedProperty mainLightColor;
        private SerializedProperty mainLightIntensity;
        private SerializedProperty shadowStrength;
        private SerializedProperty specularColor;
        private SerializedProperty rimColor;

        //private SerializedProperty isAddLight;
        //private SerializedProperty addLightColor;
        private SerializedProperty ambientColor;
        private SerializedProperty bakeAmbientIntensity;
        private SerializedProperty envColor;

        // Other
        private SerializedProperty isDebug;
        

        #endregion
    
        private void OnEnable()
        {
            titleColorSun = EditorGUIUtility.isProSkin ? new Color(0.964f, 1f, 0) : new Color(0.89f, 0.4f, 0.4f);
            titleColorEnv = EditorGUIUtility.isProSkin ? new Color(0.0f, 0.66f, 1f) : new Color(0, 0.49f, 1f);
            titleColorOther = EditorGUIUtility.isProSkin ? new Color(0.134f, 0.75f, 0.1f) : new Color(0.134f, 0.56f, 0);
            uiColorOther = EditorGUIUtility.isProSkin ? new Color(0.8f, 0.2f, 0.8f) : new Color(0.4f, 0.2f, 0.8f);
            
            //自定义主光
            lightSourceType = serializedObject.FindProperty("lightSourceType");
            eulerValue = serializedObject.FindProperty("eulerValue");
            isShowDirGUI = serializedObject.FindProperty("isShowDirGUI");
            
            isCustomColor = serializedObject.FindProperty("isCustomColor");
            mainLightColor = serializedObject.FindProperty("mainLightColor");
            mainLightIntensity = serializedObject.FindProperty("mainLightIntensity");
            shadowStrength = serializedObject.FindProperty("shadowStrength");
            specularColor = serializedObject.FindProperty("specularColor");
            rimColor = serializedObject.FindProperty("rimColor");
            
            //环境光设置
            //isAddLight = serializedObject.FindProperty("isAddLight");
            //addLightColor = serializedObject.FindProperty("addLightColor");
            ambientColor = serializedObject.FindProperty("ambientColor");
            bakeAmbientIntensity = serializedObject.FindProperty("bakeAmbientIntensity");
            envColor = serializedObject.FindProperty("envColor");

            // Other
            isDebug = serializedObject.FindProperty("isDebug");
            
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
        
            if (titleLabelSunStyle == null) {
                titleLabelSunStyle = new GUIStyle(EditorStyles.label);
            }
            titleLabelSunStyle.normal.textColor = titleColorSun;
            titleLabelSunStyle.fontStyle = FontStyle.Bold;
            titleLabelSunStyle.fontSize = 15;

            EditorGUILayout.Separator();
                EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("光照设置", titleLabelSunStyle);
                EditorGUILayout.EndHorizontal();
            EditorGUILayout.Separator();
            EditorGUILayout.PropertyField(lightSourceType, new GUIContent("光源类型", "选择方向光来源类型"));
            if (lightSourceType.intValue == (int)LightSourceType.CustomLightDir)
            {
                //交互提示
                if (isShowDirGUI.boolValue)
                {
                    GUI.backgroundColor = new Color(0f, 1.0f, 0.8f, 1);
                    Tools.current = Tool.None;//让Scene窗口不显示任何Transform操作图标
                }
                else
                {
                    GUI.backgroundColor = Color.white;
                }
                
                EditorGUILayout.PropertyField(eulerValue, new GUIContent("光照方向", "自定义光照方向"));
                EditorGUILayout.BeginHorizontal();
                    if (GUILayout.Button("设置方向",GUILayout.Width(75), GUILayout.Height(25)))
                    {
                        isShowDirGUI.boolValue = !isShowDirGUI.boolValue;
                    }
                    if (GUILayout.Button("重置方向",GUILayout.Width(75), GUILayout.Height(25)))
                    {
                        eulerValue.vector3Value = new Vector3(0, 0, 0);
                    }
                EditorGUILayout.EndHorizontal();
                GUI.backgroundColor = Color.white;
                EditorGUILayout.Space(15);
            }
            EditorGUILayout.PropertyField(mainLightIntensity, new GUIContent("光照强度", "自定义光照强度"));
            EditorGUILayout.PropertyField(shadowStrength, new GUIContent("自投影强度", "自定义自投影强度"));
            EditorGUILayout.PropertyField(specularColor, new GUIContent("高光颜色", "高光颜色"));
            EditorGUILayout.PropertyField(rimColor, new GUIContent("边缘光颜色", "边缘光颜色"));

            if (RenderSettings.sun != null)
            {
                EditorGUILayout.PropertyField(isCustomColor, new GUIContent("使用自定义主光颜色", "是否使用自定义主光颜色"));
                if (isCustomColor.boolValue)
                {
                    EditorGUILayout.PropertyField(mainLightColor, new GUIContent("主光颜色", "自定义灯光颜色"));
                }
            }

            EditorGUILayout.Space(15);
            EditorGUILayout.Separator();
                EditorGUILayout.BeginHorizontal();
                    titleLabelSunStyle.normal.textColor = new Color(1, 0.5f, 0, 1);
                    EditorGUILayout.LabelField("环境光设置", titleLabelSunStyle);
                EditorGUILayout.EndHorizontal();
            EditorGUILayout.Separator();
            EditorGUILayout.PropertyField(ambientColor, new GUIContent("环境漫反射颜色", "暗部补光颜色"));
            EditorGUILayout.PropertyField(bakeAmbientIntensity, new GUIContent("环境漫反射颜色亮度", "暗部补光颜色亮度"));
            EditorGUILayout.PropertyField(envColor, new GUIContent("环境反射高光颜色", "环境反射高光颜色"));

            /*
            //2022.12.20注释，暂时用不到
            EditorGUILayout.Space(15);
            EditorGUILayout.Separator();
                EditorGUILayout.BeginHorizontal();
                    titleLabelSunStyle.normal.textColor = new Color(1, 0.5f, 0, 1);
                    EditorGUILayout.LabelField("额外直射光设置", titleLabelSunStyle);
                EditorGUILayout.EndHorizontal();
            EditorGUILayout.Separator();
            EditorGUILayout.PropertyField(isAddLight, new GUIContent("使用额外直射光", "是否添加额外直射光"));
            if (isAddLight.boolValue)
            {
                EditorGUILayout.PropertyField(isDebug, new GUIContent("显示额外光方向(Debug)", "显示方向"));
                EditorGUILayout.PropertyField(addLightColor, new GUIContent("额外直射光颜色", "额外直射光补光颜色"));
            }*/
            
            // Env
            // if (titleLabelEnvStyle == null) {
            //     titleLabelEnvStyle = new GUIStyle(EditorStyles.label);
            // }
            // titleLabelEnvStyle.normal.textColor = titleColorEnv;
            // titleLabelEnvStyle.fontStyle = FontStyle.Bold;
            // titleLabelEnvStyle.fontSize = 15;
            // EditorGUILayout.Separator();
            // EditorGUILayout.BeginHorizontal();
            // EditorGUILayout.LabelField("环境光设置", titleLabelEnvStyle);
            // EditorGUILayout.EndHorizontal();
            // EditorGUILayout.Separator();
            //EditorGUILayout.PropertyField(bakeAmbientIntensity, new GUIContent("环境光整体强度", "环境光整体强度"));
            
            serializedObject.ApplyModifiedProperties();
        }
    }
}













