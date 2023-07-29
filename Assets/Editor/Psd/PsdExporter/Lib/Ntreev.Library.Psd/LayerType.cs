using System.Collections;

namespace Ntreev.Library.Psd
{
    public enum LayerType
    {
        Normal,//智能对象
        Color,//纯色块
        Text,//文字
        Group,//文件夹
        Overflow,//超过6层
        Complex//复杂类型
    }

    /// <summary>
    /// 图片对称切割
    /// </summary>
    public enum SymmetryType
    {
        None,       // 默认
        Bisection,  // 二分法
        Quartation, // 四分法
    }
}