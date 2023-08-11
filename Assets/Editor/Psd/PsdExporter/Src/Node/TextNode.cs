using Ntreev.Library.Psd;
using Ntreev.Library.Psd.Structures;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextNode : LayerNode
{
    public TextInfo textInfo = null;
    public Color color;
    public int fontSize = 16;
    public string fontName = null;

    public Color outlineColor;
    public float outlineWidth;

    public bool richText;
    public float lineSpacing = -1;
    public bool isOneline = true;

    public TextNode(int index, PsdLayer layer, LayerNode parent) : base(index, layer, parent)
    {
        objName = "text_" + index;
        textInfo = layer.Records.TextInfo;

        color = new Color(textInfo.color[0], textInfo.color[1], textInfo.color[2], textInfo.color[3]);
        fontSize = textInfo.fontSize;
        fontName = textInfo.fontName;

        if (layer.Records.textEffectInfo != null)
        {
            outlineWidth = layer.Records.textEffectInfo.outLineWidth;
            if (fontSize <= 20 && outlineWidth > 1)
            {
                outlineWidth = 1;
            }
            else if (outlineWidth >= 1.5f)
            {
                outlineWidth = 1.5f;
            }

            outlineColor = new Color(layer.Records.textEffectInfo.outLineColor[0] / 255, layer.Records.textEffectInfo.outLineColor[1] / 255, layer.Records.textEffectInfo.outLineColor[2] / 255, 1.0f);
        }

        isOneline = !textInfo.text.Contains("\r") && !textInfo.text.Contains("\n");

        Ntreev.Library.Psd.Readers.LayerResources.Reader_TySh reader = layer.Resources["TySh"] as Ntreev.Library.Psd.Readers.LayerResources.Reader_TySh;
        DescriptorStructure text = null;
        reader.TryGetValue(ref text, "Text");

        StructureEngineData engineData = text["EngineData"] as StructureEngineData;
        Properties engineDict = engineData["EngineDict"] as Properties;

        Properties stylerun = engineDict["StyleRun"] as Properties;
        ArrayList runarray = stylerun["RunArray"] as ArrayList;

        float[] lastColor = null;
        foreach (Properties v in runarray)
        {
            Properties styleSheet = v["StyleSheet"] as Properties;

            Properties styleSheetsData = styleSheet["StyleSheetData"] as Properties;

            if (lineSpacing == -1 && styleSheetsData.Contains("Leading"))
            {
                lineSpacing = (float)(float.Parse(styleSheetsData["Leading"].ToString()) * textInfo.factor);
            }

            if (!styleSheetsData.Contains("FillColor"))
            {
                continue;
            }

            float[] curColor;
            Properties strokeColorProp = styleSheetsData["FillColor"] as Properties;
            ArrayList strokeColor = strokeColorProp["Values"] as ArrayList;
            if (strokeColor != null && strokeColor.Count >= 4)
            {
                curColor = new float[] {
                        float.Parse(strokeColor[1].ToString()),
                        float.Parse(strokeColor[2].ToString()),
                        float.Parse(strokeColor[3].ToString()),
                        float.Parse(strokeColor[0].ToString())};
            }
            else
            {
                curColor = new float[4] { 0, 0, 0, 1 };
            }

            if (!richText && lastColor != null &&
                    (lastColor[0] != curColor[0] || lastColor[1] != curColor[1] || lastColor[2] != curColor[2] || lastColor[3] != curColor[3]))
            {
                richText = true;
            }

            lastColor = curColor;
        }

        if (lineSpacing == -1)
        {
            lineSpacing = fontSize;
        }
    }
}


