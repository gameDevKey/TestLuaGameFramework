using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine.Events;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

namespace SYpackage.Character
{
    [Serializable]
    public enum LightSourceType
    {
        SceneLightDir,
        CustomLightDir
    }
     
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public partial class CharacterLight : MonoBehaviour
    {
        // TODO：如果没有使用某些功能就不要传入
        #region ReadOnly
            //光照设置
            private readonly int characterLightDir = Shader.PropertyToID("_CharacterLightDir"); // xyz:自定义光照方向, a:开关
            private readonly int characterLightData0 = Shader.PropertyToID("_CharacterLightData0"); // x:toggle yz:none w:灯光强度
            private readonly int characterMainLightColor = Shader.PropertyToID("_CharacterLightColor"); // xyz: color a: none
            private readonly int characterLightData1 = Shader.PropertyToID("_CharacterLightData1"); // x 阴影强度， y 环境光强度 zw：ENV HDR
            private readonly int characterSpecularColor = Shader.PropertyToID("_CharacterSpecularColor"); // xyz:color, a:intensity
            private readonly int characterRimColor = Shader.PropertyToID("_CharacterRimColor"); // xyz:color, a:intensity
            
            //环境光设置
            private readonly int characterAmbientColor = Shader.PropertyToID("_CharacterAmbientColor");
            private readonly int characterEnvColor = Shader.PropertyToID("_CharacterEnvColor"); // xyz：color, a:intensity
            #endregion

        #region Public Filed
            //光照设置
            public LightSourceType lightSourceType = LightSourceType.SceneLightDir;
            public Vector3 eulerValue = Vector3.zero;//Inspector面板显示的旋转角度
            #if UNITY_EDITOR
                public bool isShowDirGUI = false;
            #endif
        
            public bool isCustomColor = false;
            [ColorUsage(false)] public Color mainLightColor = Color.white;
            [Range(0, 10)] public float mainLightIntensity = 1;
            [Range(0, 1)] public float shadowStrength = 1;
            [ColorUsage(false)]public Color specularColor = new Color(1, 1, 1, 0.1f);
            [ColorUsage(false)]public Color rimColor = new Color(1, 1, 1, 0.1f);
            
            //环境光设置
            [ColorUsage(false)] public Color ambientColor = Color.white;
            [Range(0, 1)] public float bakeAmbientIntensity = 0.0f;
            [ColorUsage(false)]public Color envColor = Color.white; // 环境球颜色
            #endregion


        #region Private Filed
            [SerializeField]
            private Vector4 lightData0 = Vector4.zero;
            [SerializeField]
            private Vector4 lightData1 = Vector4.zero;
            [SerializeField]
            private Vector4 lightDir = Vector4.zero;
            
            [SerializeField]
            private float useCustomLightDir = 0;
            [SerializeField]
            private Quaternion Cache_rotationValue = Quaternion.identity;
        #endregion
        
        private static CharacterLight instance;
        public static CharacterLight Instance
        {
            get => instance;
        }

        private void OnEnable()
        {
            instance = this;
            
            SetupLightData();
            SetupBuffer();
            RenderPipelineManager.beginCameraRendering += SetupCharacterLightBuffer; 
            #if UNITY_EDITOR
                SceneView.duringSceneGui += this.OnScene;
            #endif
        }

        private void OnDisable()
        {
            ClearBuffer();
            #if UNITY_EDITOR
                SceneView.duringSceneGui -= this.OnScene;
            #endif
        }

        private void OnDestroy()
        {
            ClearBuffer();
            #if UNITY_EDITOR
                SceneView.duringSceneGui -= this.OnScene;
            #endif
        }
#if UNITY_EDITOR
        private void OnValidate() {
            SetupLightSource();
            SetupLightData();
        }
#endif
        private void Update()
        {
            //SetupLightSource();
            //SetupBuffer();
        }

        /// <summary>
        /// 设置光源方向类型。
        /// </summary>
        private void SetupLightSource()
        {
            switch (lightSourceType)
            {
                case LightSourceType.SceneLightDir:
                    if (RenderSettings.sun != null)
                    {
                        useCustomLightDir = 0;
                    }
                    else
                    {
                        useCustomLightDir = 1;
                        lightSourceType = LightSourceType.CustomLightDir;
                        #if UNITY_EDITOR
                        Debug.LogError("角色灯光脚本: 场景没有主灯光，不能选择SceneLightDir模式");
                        #endif
                    }
                    break;
                
                case LightSourceType.CustomLightDir:
                    useCustomLightDir = 1;
                    break;
            }
        }
        
        private void SetupLightData()
        {
            lightData0.x = 1;
            lightData0.w = mainLightIntensity;
            
            if (!isCustomColor && RenderSettings.sun != null)
                mainLightColor = RenderSettings.sun.color;

            lightData1.x = shadowStrength;
            lightData1.y = 1;//暂时不用bakeAmbientIntensity
            
            specularColor.a = 0.1f;//specularIntensity
            rimColor.a = 0.1f;//rimIntensity
            
            lightDir = (Cache_rotationValue * Vector3.forward).normalized;
            lightDir.w = useCustomLightDir;
        }
        
        private void SetupBuffer()
        {
            Shader.SetGlobalVector(characterLightDir, lightDir);

            lightData0.x = 1;
            Shader.SetGlobalVector(characterLightData0, lightData0);
            Shader.SetGlobalColor(characterMainLightColor, mainLightColor);
            Shader.SetGlobalVector(characterLightData1, lightData1);
            Shader.SetGlobalColor(characterSpecularColor, specularColor);
            Shader.SetGlobalColor(characterRimColor, rimColor);

            ambientColor.a = bakeAmbientIntensity;
            Shader.SetGlobalColor(characterAmbientColor, ambientColor);
            Shader.SetGlobalColor(characterEnvColor, envColor);
        }
        

        private void ClearBuffer()
        {
            lightData0.x = 0;
            Shader.SetGlobalVector(characterLightData0, lightData0);

            RenderPipelineManager.beginCameraRendering -= SetupCharacterLightBuffer;
        }

        /// <summary>
        /// 不同的相机设置不同的buffer
        /// </summary>
        /// <param name="context"></param>
        /// <param name="camera"></param>
        private void SetupCharacterLightBuffer(ScriptableRenderContext context, Camera camera)
        {
            SetupBuffer();
        }
        
        #region DEBUG
                        
        #if UNITY_EDITOR
        void OnScene(SceneView scene)
        {
            if (isShowDirGUI)
            {
                //绘制旋转手柄
                //旋转手柄位置
                Vector3 GUIPosition = transform.position;
                //欧拉角转四元数，旋转手柄旋向
                Quaternion rotationValue = Quaternion.Euler(eulerValue);

                rotationValue = Handles.RotationHandle(rotationValue, GUIPosition);
                
                if (Cache_rotationValue != rotationValue)
                {
                    //存储旋转四元数
                    Cache_rotationValue = rotationValue;

                    if (PrefabUtility.GetPrefabInstanceHandle(this))
                    {
                        //保存预制体
                        EditorUtility.SetDirty(this);
                        AssetDatabase.SaveAssets();
                        AssetDatabase.Refresh();
                    }
                }

                //四元数转欧拉角
                eulerValue = rotationValue.eulerAngles;
                eulerValue.x=(float)Math.Round(eulerValue.x,3);  
                eulerValue.y=(float)Math.Round(eulerValue.y,3);  
                eulerValue.z=(float)Math.Round(eulerValue.z,3);

                //光线方向预览
                var rrr = rotationValue;
                rrr.SetLookRotation(rotationValue * -Vector3.forward);
            
                Handles.color = new Color(1, 1, 0, 1);
                Handles.ArrowHandleCap(0, GUIPosition, rrr, HandleUtility.GetHandleSize(GUIPosition), EventType.Repaint);
            }
            
            SetupLightSource();
            SetupLightData();
        }
        void OnDrawGizmos()
        {
            
        }
        #endif
        
        #endregion
    }
}