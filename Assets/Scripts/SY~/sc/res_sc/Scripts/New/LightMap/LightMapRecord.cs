using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Rendering;

[DisallowMultipleComponent]
public class LightMapRecord : MonoBehaviour {

    [SerializeField]
    public LightingRendererData[] rendererData = new LightingRendererData[0];

    [SerializeField]
    public LightingMapData[] mapData = new LightingMapData[0];

    [SerializeField]
    public LightingFogData fogData = new LightingFogData();

    [SerializeField]
    public RenderSettingData renderSettingData = new RenderSettingData();

    [SerializeField]
    public LightingBakingOutputData[] LightingBakingOutputData = new LightingBakingOutputData[0];

    [SerializeField]
    public LightingCameraOutputData cameraOutputData = new LightingCameraOutputData();

    private bool init = false;

    protected void Awake() {
        if (init) {
            return;
        }
        init = true;

        LightmapSettings.lightmaps = null;

        LightingRendererData[] renders = rendererData;
        LightingMapData[] mapdatas = mapData;
        LightingFogData fogInfo = fogData;
        RenderSettingData renderSetting = renderSettingData;

        if (renders != null) {
            foreach (LightingRendererData data in renders) {
                if (data.lightmapIndex < 65535) {
                    data.renderer.lightmapIndex = data.lightmapIndex;
                    data.renderer.lightmapScaleOffset = data.lightmapScaleOffset;
                }
            }
        }

        LightmapData[] lightmapAsset;
        if (LightmapSettings.lightmaps == null) {
            lightmapAsset = new LightmapData[10];
            for (int i = 0; i < 10; i++) {
                lightmapAsset[i] = new LightmapData();
            }
            LightmapSettings.lightmaps = lightmapAsset;
        } else {
            if (LightmapSettings.lightmaps.Length < 10) {
                lightmapAsset = new LightmapData[10];
                for (int i = 0; i < 10; i++) {
                    lightmapAsset[i] = new LightmapData();
                }
                LightmapSettings.lightmaps = lightmapAsset;
            }
        }
        lightmapAsset = LightmapSettings.lightmaps;
        // LightmapData[] lightmapAsset = new LightmapData[5];
        bool isnormal = true;
        for (int i = 0; i < mapdatas.Length; i++) {
            int mindex = mapdatas[i].originIndex;
            if (mindex > 4) {
                isnormal = false;
                break;
            }
        }
        if (isnormal) {
            for (int i = 0; i < 5; i++) {
                lightmapAsset[i].lightmapColor = null;
                lightmapAsset[i].lightmapDir = null;
            }
        } else {
            for (int i = 5; i < 10; i++) {
                lightmapAsset[i].lightmapColor = null;
                lightmapAsset[i].lightmapDir = null;
            }
        }
        for (int i = 0; i < mapdatas.Length; i++) {
            int mindex = mapdatas[i].originIndex;
            lightmapAsset[mindex] = new LightmapData();
            // lightmapAsset[mindex].lightmapColor = AssetManager.GetAssemblyObject(mapdatas[i].keyFar) as Texture2D;
            lightmapAsset[mindex].lightmapColor = mapdatas[i].lightMapFar;
            lightmapAsset[mindex].shadowMask = mapdatas[i].lightMapShadowMask;
            lightmapAsset[mindex].lightmapDir = mapdatas[i].lightMapNear;
        }

        foreach (LightingBakingOutputData data in LightingBakingOutputData)
        {
            if(data.light != null)
            {
                data.light.bakingOutput = new LightBakingOutput()
                {
                    probeOcclusionLightIndex = data.probeOcclusionLightIndex,
                    occlusionMaskChannel = data.occlusionMaskChannel,
                    lightmapBakeType = data.lightmapBakeType,
                    mixedLightingMode = data.mixedLightingMode,
                    isBaked = data.isBaked
                };
            }
        }

        LightmapSettings.lightmaps = lightmapAsset;

        if (fogInfo != null) {
            RenderSettings.fog = fogInfo.isFog;
            RenderSettings.fogMode = fogInfo.fogMode;
            RenderSettings.fogColor = fogInfo.fogColor;
            RenderSettings.fogStartDistance = fogInfo.fogStartDistance;
            RenderSettings.fogEndDistance = fogInfo.fogEndDistance;
            RenderSettings.fogDensity = fogInfo.fogDensity;
        }

        if (renderSetting != null)
        {
            RenderSettings.ambientIntensity = renderSetting.ambientIntensity;
            RenderSettings.ambientMode = renderSetting.ambientMode;
            RenderSettings.ambientLight = renderSetting.ambientLight;
            RenderSettings.ambientGroundColor = renderSetting.ambientGroundColor;
            RenderSettings.ambientSkyColor = renderSetting.ambientSkyColor;
            RenderSettings.ambientEquatorColor = renderSetting.ambientEquatorColor;
        }

        LightmapSettings.lightmapsMode = LightmapsMode.NonDirectional;
    }

    void OnDestroy()
    {
        LightmapData[] lightmapAsset = LightmapSettings.lightmaps;

        for (int ii = 0; ii < mapData.Length; ii++)
        {
            if(mapData[ii].originIndex < lightmapAsset.Length)
            {
                if (lightmapAsset[mapData[ii].originIndex].lightmapColor != null) {
                    //Debug.Log(lightmapAsset[mapData[ii].originIndex].lightmapColor.name);
                    //Debug.Log(mapData[ii].keyFar);
                    if (mapData[ii].keyFar.Contains(lightmapAsset[mapData[ii].originIndex].lightmapColor.name.ToLower()))
                        lightmapAsset[mapData[ii].originIndex] = new LightmapData();
                }
            }
        }

        LightmapSettings.lightmaps = lightmapAsset;
    }
}

[Serializable]
public class LightingMapData {
    public int originIndex;
    public Texture2D lightMapFar;
    public Texture2D lightMapNear;
    public Texture2D lightMapShadowMask;
    public string keyFar;
    public string keyNear;
}


[Serializable]
public class RenderSettingData
{
    public AmbientMode ambientMode;
    public Color ambientLight;
    public Color ambientGroundColor;
    public Color ambientSkyColor;
    public Color ambientEquatorColor;
    public float ambientIntensity;
}


[Serializable]
public class LightingFogData {
    public bool forceRef = true;
    public bool isFog;
    public FogMode fogMode;
    public Color fogColor;
    public float fogStartDistance;
    public float fogEndDistance;
    public float fogDensity;
}

[Serializable]
public class LightingRendererData {
    public Renderer renderer;
    public int lightmapIndex;
    public Vector4 lightmapScaleOffset;
}


[Serializable]
public class LightingBakingOutputData
{
    public Light light;
    public int probeOcclusionLightIndex;
    public int occlusionMaskChannel;
    public LightmapBakeType lightmapBakeType;
    public MixedLightingMode mixedLightingMode;
    public bool isBaked;

    public LightingBakingOutputData(Light light)
    {
        this.light = light;
        var bakingOutput = light.bakingOutput;
        this.probeOcclusionLightIndex = bakingOutput.probeOcclusionLightIndex;
        this.occlusionMaskChannel = bakingOutput.occlusionMaskChannel;
        this.lightmapBakeType = bakingOutput.lightmapBakeType;
        this.mixedLightingMode = bakingOutput.mixedLightingMode;
        this.isBaked = bakingOutput.isBaked;
    }
}

[Serializable]
public class LightingCameraOutputData
{
    public CameraClearFlags clearFlag;
    public Color backgroundColor;
    public Vector3 rotation;
    public float distance;
    public float fieldOfView;
}