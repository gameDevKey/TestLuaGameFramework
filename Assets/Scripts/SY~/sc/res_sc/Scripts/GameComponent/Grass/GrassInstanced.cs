using UnityEngine;
using System.Collections.Generic;


[ExecuteInEditMode]
public class GrassInstanced : MonoBehaviour
{
    public List<Transform> heroList = new List<Transform>();
    private Dictionary<int, Vector3> posDict = new Dictionary<int, Vector3>();

    public static int instanceCount = 200;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public List<Material> matList = new List<Material>();

    public int normalSpeed = 3;
    public int fastSpeed = 6;
    public int fastSpeedCircle = 314 * 4;
    public float normalSwayRange = 4f;
    public float fastSwayRange = 8f;

    //private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    private MaterialPropertyBlock materialPropertyBlock;
    
    private List<Matrix4x4> materixList = new List<Matrix4x4>(instanceCount);
    private List<float> offsetxList = new List<float>(instanceCount);
    private List<float> offsetzList = new List<float>(instanceCount);
    private List<Vector4> colorList = new List<Vector4>(instanceCount);
    private List<float> scaleList = new List<float>(instanceCount);
    private List<GrassData> grassDataList;

    //private bool isEditorTest = false;

    private void Awake()
    {
        Grass.normalSpeed = this.normalSpeed;
        Grass.fastSpeed = this.fastSpeed;
        Grass.fastSpeedCircle = this.fastSpeedCircle;
        Grass.normalSwayRange = this.normalSwayRange;
        Grass.fastSwayRange = this.fastSwayRange;
        materialPropertyBlock = new MaterialPropertyBlock();
    }

    private void Start()
    {
        InitGrass();
        heroList = GrassManager.Instance.heroList;
#if UNITY_EDITOR
        GameObject go = GameObject.Find("Character");
        if (go != null)
        {
            heroList = new List<Transform>();
            heroList.Add(go.transform);
        }
#endif
    }

    private void InitGrass()
    {
        GrassManager.Instance.ClearAll();
        GrassInstancedData instancedData = GetComponent<GrassInstancedData>();
        if (instancedData != null)
        {
            grassDataList = instancedData.grassDataList;
            for (int i = 0; i < grassDataList.Count; i++)
            {
                GrassData one = grassDataList[i];
                Grass grass = new Grass(one.pos, one.rotation, one.scale, one.color, one.mat_id);
            }
        }
    }

    void Update()
    {
        //isEditorTest = false;
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            InitGrass();
            materialPropertyBlock = new MaterialPropertyBlock();
        }
#endif
    
        posDict.Clear();
        for (int i = 0; i < heroList.Count; i++)
        {
            if(heroList[i] != null)
                posDict[heroList[i].GetInstanceID()] = heroList[i].position;
            else
            {
                RemoveHero(i);
                break;
            }
        }
        if (Application.isPlaying)
        {
            GrassManager.Instance.UpdateAllList(posDict);
        }
        SubmitDrawCall();
    }

    private void SubmitDrawCall()
    {
        List<Grass> allList = GrassManager.Instance.allList;

        for (int ii = 0; ii < matList.Count; ii++)
        {
            for (int i = 0; i < allList.Count; i++)
            {
                Grass grass = allList[i];
                if (grass.mat_id == ii)
                {
                    materixList.Add(grass.materix);
                    offsetxList.Add(grass.offset.x);
                    offsetzList.Add(grass.offset.y);
                    colorList.Add(grass.color);
                    scaleList.Add(grass.scale);

                    if (materixList.Count >= instanceCount)
                    {
                        materialPropertyBlock.SetFloatArray("_offsetx", offsetxList);
                        materialPropertyBlock.SetFloatArray("_offsetz", offsetzList);
                        materialPropertyBlock.SetVectorArray("_color", colorList);
                        materialPropertyBlock.SetFloatArray("_scale", scaleList);
                        Graphics.DrawMeshInstanced(instanceMesh, 0, matList[ii], materixList, materialPropertyBlock);

                        materixList.Clear();
                        offsetxList.Clear();
                        offsetzList.Clear();
                        colorList.Clear();
                        scaleList.Clear();
                        materialPropertyBlock.Clear();
                    }
                }
            }
            if (materixList.Count > 0)
            {
                materialPropertyBlock.SetFloatArray("_offsetx", offsetxList);
                materialPropertyBlock.SetFloatArray("_offsetz", offsetzList);
                materialPropertyBlock.SetVectorArray("_color", colorList);
                materialPropertyBlock.SetFloatArray("_scale", scaleList);
                Graphics.DrawMeshInstanced(instanceMesh, 0, matList[ii], materixList, materialPropertyBlock);

                materixList.Clear();
                offsetxList.Clear();
                offsetzList.Clear();
                colorList.Clear();
                scaleList.Clear();
                materialPropertyBlock.Clear();
            }
        }
    }


    void Init()
    {
        for (int i = 0; i < 1000; i++)
        {
            float x = Random.Range(0f, 10f);
            float z = Random.Range(0f, 10f);
            Vector3 pos = new Vector4(x, 0f, z, 1f);

            float r = Random.Range(0f, 1f);
            float g = Random.Range(0f, 1f);
            float b = Random.Range(0f, 1f);
            Vector4 color = new Vector4(r, g, b, 1.0f);

            Quaternion rotation = Quaternion.Euler(0, Random.Range(0, 90), 0f);
            Grass grass = new Grass(pos, rotation, 1.0f, color, 0);
        }
    }

    public int AddMat(Material mat) {
        for (int i = 0; i < matList.Count; i++)
        {
            if (matList[i].GetInstanceID() == mat.GetInstanceID())
                return i;
        }
        matList.Add(mat);
        return matList.Count-1;
    }

    public void AddHero(Transform ts)
    {
        //for (int i = 0; i < heroList.Count; i++)
        //{
        //    if (heroList[i] == ts)
        //        return;
        //}
        //heroList.Add(ts);
        GrassManager.Instance.AddHero(ts);
    }
    public void RemoveHero(Transform ts) {
        //int num = heroList.Count;
        //for (int i = 0; i < num; i++)
        //{
        //    if (heroList[i] == ts)
        //    {
        //        Transform h = heroList[i];
        //        heroList[i] = heroList[num - 1];
        //        heroList[num - 1] = h;
        //        break;
        //    }
        //}
        //heroList.RemoveAt(num-1);
        GrassManager.Instance.RemoveHero(ts);
    }
    public void RemoveHero(int idx)
    {
        //int num = heroList.Count;
        //Transform h = heroList[idx];
        //heroList[idx] = heroList[num - 1];
        //heroList[num - 1] = h;
        //heroList.RemoveAt(num - 1);
        GrassManager.Instance.RemoveHero(idx);
    }

}