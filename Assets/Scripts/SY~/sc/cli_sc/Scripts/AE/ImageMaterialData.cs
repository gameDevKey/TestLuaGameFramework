using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ImageMaterialData : MonoBehaviour
{
    public Material material;
    public string propertiesName1;
    public float propertiesSet1;
    public string propertiesName2;
    public float propertiesSet2;
    public string propertiesName3;
    public float propertiesSet3;
    public string propertiesName4;
    public Color propertiesSet4;

    void Update()
    {
        if(material!= null)
        {
        material.SetFloat(""+ propertiesName1+"",propertiesSet1);
        material.SetFloat(""+ propertiesName2+"",propertiesSet2);
        material.SetFloat(""+ propertiesName3+"",propertiesSet3);
        material.SetColor(""+ propertiesName4+"",propertiesSet4);
        }

    }
}
