using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class NineSlice
{
    [MenuItem("Assets/九宫格图片处理/最优解版(宽高尽量被4整除且尽量不小于32) %e")]
    public static void AutoDoNineSlice()
    {
        Object[] objs = Selection.GetFiltered(typeof(Texture2D), SelectionMode.Unfiltered);
        int success = 0;
        for(int i = 0; i < objs.Length; i++) if(DealWithTexture(objs[i] as Texture2D, true)) success++;
        if(objs.Length > 0)
            EditorUtility.DisplayDialog("结果", "当前选中: " + objs.Length + " 张图片\n成功替换: " + success + " 张图片\n具体可查看Debug日志", "确认");
        else
            EditorUtility.DisplayDialog("温馨提示", "请先选中任意一张图片!!", "确认");
        AssetDatabase.Refresh(); //刷新
    }

    [MenuItem("Assets/九宫格图片处理/最优解版阉割版（屏蔽横向处理）")]
    public static void AutoDoNineSlice3()
    {
        Object[] objs = Selection.GetFiltered(typeof(Texture2D), SelectionMode.Unfiltered);
        int success = 0;
        for (int i = 0; i < objs.Length; i++) if (DealWithTexture(objs[i] as Texture2D, true, true)) success++;
        if (objs.Length > 0)
            EditorUtility.DisplayDialog("结果", "当前选中: " + objs.Length + " 张图片\n成功替换: " + success + " 张图片\n具体可查看Debug日志", "确认");
        else
            EditorUtility.DisplayDialog("温馨提示", "请先选中任意一张图片!!", "确认");
        AssetDatabase.Refresh(); //刷新
    }

    [MenuItem("Assets/九宫格图片处理/最优解版阉割版（屏蔽纵向处理）")]
    public static void AutoDoNineSlice4()
    {
        Object[] objs = Selection.GetFiltered(typeof(Texture2D), SelectionMode.Unfiltered);
        int success = 0;
        for (int i = 0; i < objs.Length; i++) if (DealWithTexture(objs[i] as Texture2D, true, false, true)) success++;
        if (objs.Length > 0)
            EditorUtility.DisplayDialog("结果", "当前选中: " + objs.Length + " 张图片\n成功替换: " + success + " 张图片\n具体可查看Debug日志", "确认");
        else
            EditorUtility.DisplayDialog("温馨提示", "请先选中任意一张图片!!", "确认");
        AssetDatabase.Refresh(); //刷新
    }

    [MenuItem("Assets/九宫格图片处理/次优解版(宽高尽量被4整除且尽量小) %w")]
    public static void AutoDoNineSlice5()
    {
        Object[] objs = Selection.GetFiltered(typeof(Texture2D), SelectionMode.Unfiltered);
        int success = 0;
        for (int i = 0; i < objs.Length; i++) if (DealWithTexture(objs[i] as Texture2D, true,false,false,-1)) success++;
        if (objs.Length > 0)
            EditorUtility.DisplayDialog("结果", "当前选中: " + objs.Length + " 张图片\n成功替换: " + success + " 张图片\n具体可查看Debug日志", "确认");
        else
            EditorUtility.DisplayDialog("温馨提示", "请先选中任意一张图片!!", "确认");
        AssetDatabase.Refresh(); //刷新
    }

    [MenuItem("Assets/九宫格图片处理/最小尺寸版")]
    public static void AutoDoNineSlice2()
    {
        Object[] objs = Selection.GetFiltered(typeof(Texture2D), SelectionMode.Unfiltered);
        int success = 0;
        for (int i = 0; i < objs.Length; i++) if (DealWithTexture(objs[i] as Texture2D, false, false, false, -1)) success++;
        if (objs.Length > 0)
            EditorUtility.DisplayDialog("结果", "当前选中: " + objs.Length + " 张图片\n成功替换: " + success + " 张图片\n具体可查看Debug日志", "确认");
        else
            EditorUtility.DisplayDialog("温馨提示", "请先选中任意一张图片!!", "确认");
        AssetDatabase.Refresh(); //刷新
    }

    /// <summary>
    /// 处理图片
    /// </summary>
    /// <param name="texture"></param>
    /// <param name="need_division">是否需要弄成宽高被四整除的图片</param>
    /// <param name="block_x">屏蔽横向处理</param>
    ///  <param name="block_y">屏蔽纵向处理</param>
    ///  <param name="min_size">限定最小尺寸为x*x</param>
    /// <returns></returns>
    private static bool DealWithTexture(Texture2D texture, bool need_division = false, bool block_x = false, bool block_y = false, int min_size = 32)
    {
        if(texture.width <= min_size && texture.height <= min_size) { Debug.Log(texture.ToString() + " 已经为最小尺寸， 无需九宫格切割"); return false; }

        string path = AssetDatabase.GetAssetPath(texture);
        TextureImporter ti = (TextureImporter)AssetImporter.GetAtPath(path);
        ti.isReadable = true;  //先设置为readable
        ti.textureCompression = TextureImporterCompression.Uncompressed; //先设置为未压缩
        AssetDatabase.ImportAsset(path);

        if (!texture.isReadable) { Debug.Log(texture.ToString() + "  设置read/write enabled = true  失败！"); return false; }

        //查询九宫格区域
        int cur_top = 0;
        int cur_down = 0;
        int max_top = 0;
        int max_down = 0;
        if (!block_x)
        {
            for (int row = 0; row < texture.height - 1; row++)
            {
                if (EqualRowPixel(texture, row, row + 1))  //两行相等
                    cur_top = row + 1;
                else
                {
                    if (cur_top - cur_down > max_top - max_down)
                    {
                        max_top = cur_top;
                        max_down = cur_down;
                    }
                    cur_top = cur_down = row + 1;
                }
            }
            if (cur_top - cur_down > max_top - max_down)
            {
                max_top = cur_top;
                max_down = cur_down;
            }
        }

        int cur_left = 0;
        int cur_right = 0;
        int max_left = 0;
        int max_right = 0;
        if (!block_y)
        {
            for (int col = 0; col < texture.width - 1; col++)
            {
                if (EqualColPixel(texture, col, col + 1))  //两行相等
                    cur_right = col + 1;
                else
                {
                    if (cur_right - cur_left > max_right - max_left)
                    {
                        max_left = cur_left;
                        max_right = cur_right;
                    }
                    cur_left = cur_right = col + 1;
                }
            }
            if (cur_right - cur_left > max_right - max_left)
            {
                max_left = cur_left;
                max_right = cur_right;
            }
        }

        if (max_right - max_left <= 0 && max_top - max_down <= 0) {
            Debug.Log(texture.ToString() + " 无需九宫格切图");
            ti.isReadable = false;  //还原
            ti.textureCompression = TextureImporterCompression.Compressed; //还原
            return false;
        }

        //根据情况特殊处理
        if(max_right - max_left <= 0)
            ti.spriteBorder = new Vector4(ti.spriteBorder.x, max_down + 1, ti.spriteBorder.z, texture.height - max_top);
        else if(max_top - max_down <= 0)
            ti.spriteBorder = new Vector4(max_left + 1, ti.spriteBorder.y, texture.width - max_right, ti.spriteBorder.w);
        else
            ti.spriteBorder = new Vector4(max_left + 1, max_down + 1, texture.width - max_right, texture.height - max_top);

        Texture2D texture_new = CreateNewTexture(texture, max_left, max_right, max_top, max_down, need_division, min_size);
        if(texture_new == null)
        {
            Debug.Log(texture.ToString() + " 无需九宫格切图（无变化）");
            ti.isReadable = false;  //还原
            ti.textureCompression = TextureImporterCompression.Compressed; //还原
            return false;
        }

        byte[] datas = texture_new.EncodeToPNG();
        File.WriteAllBytes(path, datas);
        Debug.Log("更换图片成功! 路径： " + path);
        ti.isReadable = false;  //还原
        ti.textureCompression = TextureImporterCompression.Compressed; //还原
        return true;
    }

    private static bool EqualRowPixel(Texture2D texture, int row1, int row2)
    {
        Color[] colors1 = texture.GetPixels(0, row1, texture.width, 1);
        Color[] colors2 = texture.GetPixels(0, row2, texture.width, 1);
        for (int i = 0; i < colors1.Length; i++) if (!colors1[i].Equals(colors2[i])) {
               // Debug.Log(string.Format("row {0}: {1}, row {2}: {3}, break index:{4}  ", row1, colors1[i], row2, colors2[i], i));
                return false; }
        return true;
    }

    private static bool EqualColPixel(Texture2D texture, int col1, int col2)
    {
        Color[] colors1 = texture.GetPixels(col1, 0, 1, texture.height);
        Color[] colors2 = texture.GetPixels(col2, 0, 1, texture.height);
        for (int i = 0; i < colors1.Length; i++) if (!colors1[i].Equals(colors2[i])) {
               // Debug.Log(string.Format("col {0}: {1}, col {2}: {3}, break index:{4}  ", col1, colors1[i], col2, colors2[i], i));
                return false; }
        return true;
    }

    private static Texture2D CreateNewTexture(Texture2D old_tex, int left, int right, int top, int down, bool need_division = false, int min_size = 32)
    {
        Debug.Log(string.Format("left: {0}, right: {1}, top: {2}, down: {3}", left, right, top, down));
        int width = old_tex.width - (right - left);
        int height = old_tex.height - (top - down);

        if (need_division)  //需要处理成被四整除
        {
            int mod_w = width % 4;
            int mod_h = height % 4;
            int offset_w = 0;
            int offset_h = 0;
            bool has_break = false;  //凑不齐4和2，则继续使用最小尺寸

            if (mod_w != 0 && 4 - mod_w <= right - left) //凑成被4整除
                offset_w = 4 - mod_w;
            else if (mod_w == 1) //退而求其次，凑成被2整除
                offset_w = 1;
            else if(mod_w != 0)  //凑不齐
                has_break = true;

            if (mod_h != 0 && 4 - mod_h <= top - down) //凑成被4整除
                offset_h = 4 - mod_h;
            else if (mod_h == 1) //退而求其次，凑成被2整除
                offset_h = 1;
            else if (mod_h != 0) //凑不齐
                has_break = true;

            if (!has_break)
            {
                width = width + offset_w;
                left = left + offset_w;

                height = height + offset_h;
                down = down + offset_h;
            }

           // Debug.Log(string.Format("new left: {0}, right: {1}, top: {2}, down: {3}", left, right, top, down));
        }

        if (min_size >= old_tex.width) //原先尺寸比min_size小， 不进行裁切
        {
            width = old_tex.width;
            left = right;
        }
        else if(min_size > width && min_size < old_tex.width)  //原先尺寸比min_size大，但预期裁切后的尺寸比min_size小
        {
            left = left + (min_size - width);
            width = min_size;
        }

        if (min_size >= old_tex.height) //原先尺寸比min_size小， 不进行裁切
        {
            height = old_tex.height;
            down = top;
        }
        else if (min_size > height && min_size < old_tex.height)  //原先尺寸比min_size大，但预期裁切后的尺寸比min_size小
        {
            down = down + (min_size - height);
            height = min_size;
        }

        if (old_tex.height == height && old_tex.width == width) return null; //没变化

        Texture2D tex = new Texture2D(width, height, TextureFormat.ARGB32, true);
        int h = 0;
        int w = 0;

        //左下
        w = left;
        h = down;
        if (w > 0 && h > 0) tex.SetPixels(0, 0, w, h, old_tex.GetPixels(0, 0, w, h));

        //左中
        w = left;
        h = 1;
        if (w > 0 && h > 0) tex.SetPixels(0, down, w, h, old_tex.GetPixels(0, down, w, h));

        //左上
        w = left;
        h = old_tex.height - top - 1;
        if (w > 0 && h > 0) tex.SetPixels(0, down + 1, w, h, old_tex.GetPixels(0, top + 1, w, h));

        //中上
        w = 1;
        h = old_tex.height - top - 1;
        if (w > 0 && h > 0) tex.SetPixels(left, down + 1, w, h, old_tex.GetPixels(left, top + 1, w, h));

        //右上
        w = old_tex.width - right - 1;
        h = old_tex.height - top - 1;
        if (w > 0 && h > 0) tex.SetPixels(left + 1, down + 1, w, h, old_tex.GetPixels(right + 1, top + 1, w, h));

        //右中
        w = old_tex.width - right - 1;
        h = 1;
        if (w > 0 && h > 0) tex.SetPixels(left + 1, down, w, h, old_tex.GetPixels(right + 1, down, w, h));

        //右下
        w = old_tex.width - right - 1;
        h = down;
        if (w > 0 && h > 0) tex.SetPixels(left + 1, 0, w, h, old_tex.GetPixels(right + 1, 0, w, h));

        //中下
        w = 1;
        h = down;
        if (w > 0 && h > 0) tex.SetPixels(left, 0, w, h, old_tex.GetPixels(left, 0, w, h));

        //中间
        w = 1;
        h = 1;
        if (w > 0 && h > 0) tex.SetPixels(left, down, w, h, old_tex.GetPixels(left, down, w, h));

        return tex;
    }
}
