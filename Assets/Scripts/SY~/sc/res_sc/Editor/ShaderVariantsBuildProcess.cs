using System.Collections.Generic;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;


class ShaderVariantsBuildProcess : IPreprocessShaders
{
    ShaderKeyword m_Blue;

    List<ShaderKeyword> skipKeywordList = new List<ShaderKeyword>();

    public ShaderVariantsBuildProcess()
    {
        skipKeywordList.Add(new ShaderKeyword("_MAIN_LIGHT_SHADOWS"));
        skipKeywordList.Add(new ShaderKeyword("_MAIN_LIGHT_SHADOWS_CASCADE"));
        skipKeywordList.Add(new ShaderKeyword("_ADDITIONAL_LIGHT_SHADOWS"));
        skipKeywordList.Add(new ShaderKeyword("_SHADOWS_SOFT"));
        skipKeywordList.Add(new ShaderKeyword("_MIXED_LIGHTING_SUBTRACTIVE"));
        skipKeywordList.Add(new ShaderKeyword("FOG_EXP"));
        skipKeywordList.Add(new ShaderKeyword("FOG_EXP2"));
        //暂时没用上
        skipKeywordList.Add(new ShaderKeyword("_CUSTOM_ENV_CUBE"));
        //Debug 不需要打包
        skipKeywordList.Add(new ShaderKeyword("_DEBUG"));
        //顶点灯光不需要
        skipKeywordList.Add(new ShaderKeyword("_ADDITIONAL_LIGHTS_VERTEX"));

    }

    public int callbackOrder { get { return 0; } }

    public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
    {
        for (int i = data.Count - 1; i >= 0; --i)
        {
            //if ("ShiYue/URP/Lit" != shader.name)
            //{
            //    return;
            //}

            ShaderKeywordSet set = data[i].shaderKeywordSet;
            //System.Text.StringBuilder sb = new System.Text.StringBuilder();

            for (int k = 0; k < skipKeywordList.Count; k++)
            {
                //foreach (var vk in set.GetShaderKeywords())
                //{
                //    sb.AppendFormat("{0}, ", vk.GetKeywordName());
                //}

                if (set.IsEnabled(skipKeywordList[k]))
                {
                    data.RemoveAt(i);
                    //Debug.Log(sb.ToString());
                    break;
                }
            }

        }
    }
}