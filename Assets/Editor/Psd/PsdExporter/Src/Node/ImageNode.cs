using Ntreev.Library.Psd;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class ImageNode : LayerNode
{
    public Texture2D texture;

    public ImageNode(int index, PsdLayer layer, LayerNode parent) : base(index, layer, parent)
    {
        objName = "image_" + +index;
        texture = PsdExporterUtils.CreateTexture(layer);
    }

    public void SaveTexture(string file)
    {
        byte[] buf = texture.EncodeToPNG();
        File.WriteAllBytes(file, buf);
    }
}


