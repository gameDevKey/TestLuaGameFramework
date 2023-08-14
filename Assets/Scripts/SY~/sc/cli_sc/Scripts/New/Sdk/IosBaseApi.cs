using System.Security.Cryptography;


#if UNITY_IOS && !UNITY_EDITOR
using System;
using System.Runtime.InteropServices;

public static class IosBaseApi{
    [DllImport("__Internal")]
    private static extern IntPtr _GetNetworkType();
    [DllImport("__Internal")]
    private static extern int _GetScreenBrightness();
    [DllImport("__Internal")]
    private static extern int _SetScreenBrightness(int percent);
    [DllImport("__Internal")]
    private static extern int _OpenUrlAction(string url);
    [DllImport("__Internal")]
    private static extern IntPtr _GetGtClientId();
	[DllImport("__Internal")]
	private static extern IntPtr _GetDeviceToken();
    [DllImport("__Internal")]
    private static extern IntPtr _GetIDFA();
    [DllImport("__Internal")]
    private static extern IntPtr _CreateDirectory(string path);
    [DllImport("__Internal")]
    private static extern bool _IsMuted();
    [DllImport("__Internal")]
    private static extern bool _IsIpv6();
    [DllImport("__Internal")]
    private static extern void _InitShareSDK(string info);
    [DllImport("__Internal")]
    private static extern void _Share(string info, int type);
    [DllImport("__Internal")]
    private static extern void _CopyToClipboard(string content);
    [DllImport("__Internal")]
    private static extern void _SavePhotoAlubm(string path);

    /// <summary>
    /// 获取当前的网络类型
    /// 返回值
    /// none: 未连接网络
    /// wifi: wifi已连接
    /// 3g: 2g、3g或4g
    /// </summary>
    public static string GetNetworkType(){
        return Marshal.PtrToStringAnsi(_GetNetworkType());
    }

    /// <summary>
    /// 获取屏幕当彰亮度
    /// 返回0~100之间的值表示百分比
    /// </summary>
    public static int GetScreenBrightness(){
        return _GetScreenBrightness();
    }

    /// <summary>
    /// 设置屏幕亮度
    /// <param name="percent">传入0~100之间的值表示百分比</param>
    /// </summary>
    public static void SetScreenBrightness(int percent){
        _SetScreenBrightness(percent);
    }


    /// <summary>
    /// openurl操作
    /// </summary>
    public static void OpenUrlAction(string url){
        _OpenUrlAction(url);
    }

    /// <summary>
    /// 获取个推客户端Id
    /// </summary>
    public static string GetGtClientId() {
        return Marshal.PtrToStringAnsi(_GetGtClientId());
    }

	/// <summary>
	/// 获取设备token
	/// </summary>
	public static string GetDeviceToken() {
		return Marshal.PtrToStringAnsi(_GetDeviceToken());
	}

    /// <summary>
    /// 获取IDFA标识
    /// </summary>
    public static string GetIDFA() {
        return Marshal.PtrToStringAnsi(_GetIDFA());
    }

    /// <summary>
    /// 创建目录
    /// </summary>
    public static void CreateDirectory(string path){
        _CreateDirectory(path);
    }

    /// <summary>
    /// 是否静音
    /// </summary>
    public static bool IsMuted(){
        return _IsMuted();
    }

    /// <summary>
    /// 是否是ipv6
    /// </summary>
    public static bool IsIpv6(){
        return _IsIpv6();
    }

    /// <summary>
    /// 复制内容到粘贴板
    /// </summary>
    public static void CopyToClipboard(string content){
        _CopyToClipboard(content);
    }

    /// <summary>
    /// 初始化分享sdk
    /// </summary>
    //public static void InitShareSDK(LuaTable info){
    //    var json = LuaTableToJsonData(info);
    //    _InitShareSDK(json.ToJson());
    //}

    /// <summary>
    /// 分享操作
    /// </summary>
    //public static void Share(LuaTable info, int type){
    //    var json = LuaTableToJsonData(info);
    //    _Share(json.ToJson(), type);
    //}

    public static void SavePhotoAlubm(string path) {
        _SavePhotoAlubm(path);
    }
    
}
#endif
