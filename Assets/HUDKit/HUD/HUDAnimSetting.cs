using UnityEngine;

public enum HUDAlignType
{
    align_left,   // 左对齐
    align_center, // 右对齐
    align_right,  // 居中
};

[System.Serializable]
public struct HudAnimAttibute
{
    public AnimationCurve AlphaCurve;
    public AnimationCurve ScaleCurve;
    public AnimationCurve MoveCurve;
    public float OffsetX;
    public float OffsetY;
    public float GapTime;
    public int SpriteGap; // 图片间隔
    public HUDAlignType AlignType;
    public bool ScreenAlign; // 是不是按屏幕对齐
    public HUDAlignType ScreenAlignType; // 屏幕对齐类型
}

public class HUDAnimSetting : MonoBehaviour
{
    public HudAnimAttibute[] NumberAttibute;
}
