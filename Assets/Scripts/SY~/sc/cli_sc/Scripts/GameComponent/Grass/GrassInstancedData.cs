using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[System.Serializable]
public class GrassData
{
    public Vector3 pos;
    public Quaternion rotation;
    public float scale;
    public Vector4 color;
    public int mat_id;
}



public class GrassInstancedData : MonoBehaviour
{
    public List<GrassData> grassDataList = new List<GrassData>();

    public void Start()
    {
    }
}
