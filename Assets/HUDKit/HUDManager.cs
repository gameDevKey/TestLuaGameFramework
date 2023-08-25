using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;
using XLua;

[LuaCallCSharp]
public class HUDManager : MonoSingleton<HUDManager>
{
    [BlackList] public Camera MainCamera;
    public bool IsInitComplete;
    [HideInInspector, BlackList] public HUDSetting HUDSetting;
    [HideInInspector, BlackList] public HUDAnimSetting AnimSetting;
    [HideInInspector, BlackList] public HUDSpriteSetting SpriteSetting;

    private BiDictionary<Sprite, int> sprite2Index;
    private BiDictionary<SpriteAtlas, int> atlas2Index;
    private HUDNumberRender render;

    protected override void Awake()
    {
        base.Awake();
        IsInitComplete = false;
        sprite2Index = new BiDictionary<Sprite, int>();
        MainCamera = Camera.main;
        render = new HUDNumberRender();
        GameAssetLoader.Instance.GetGameObjectAsync("HUDSetting", (obj, path) =>
        {
            HUDSetting = obj.GetComponent<HUDSetting>();
            AnimSetting = obj.GetComponent<HUDAnimSetting>();
            SpriteSetting = new HUDSpriteSetting();
            InitFontSprite();
            OnInitComplete();
        });
    }

    private void InitFontSprite()
    {
        var len = 2;
        SpriteSetting.SpriteAttibutes = new HUDSpriteAttibute[len];
        //SpriteSetting.SpriteAttibutes[(int)HUDNumberRenderType.HUD_SHOW_ABSORB].InitNumber("??", "??");
        SpriteSetting.SpriteAttibutes[(int)HUDNumberRenderType.HUD_SHOW_HP_HURT].InitNumber("", "red");
    }

    private void OnInitComplete()
    {
        IsInitComplete = true;
        Debug.Log("HUDManager 初始化完成");
    }

    [BlackList]
    public int SpriteNameToID(string name)
    {
        if (string.IsNullOrEmpty(name)) return 0;
        var sprite = GameAssetLoader.Instance.GetAsset<Sprite>(name);
        if (sprite == null)
        {
            Debug.LogError("找不到Sprite:" + name);
            return -1;
        }
        var index = name.GetHashCode();
        sprite2Index.TryAdd(sprite as Sprite, index);
        var atlas = GameAssetLoader.Instance.GetAtlasBySpriteKey(name);
        atlas2Index.TryAdd(atlas, atlas.name.GetHashCode());
        return index;
    }

    [BlackList]
    public Sprite GetSpriteByID(int spriteId)
    {
        sprite2Index.TryGetBySecond(spriteId, out var sprite);
        return sprite;
    }

    //public SpriteAtlas

    public void ShowNumber(int number, Transform t)
    {
        render.AddHudNumber(t ?? transform, HUDNumberRenderType.HUD_SHOW_HP_HURT, number, false, true, false);
    }
}

class HUDSpriteInfo
{
    public SpriteAtlas Atlas;
    public int AtlasID;
    public Sprite Sprite;
    public int SpriteID;
}
