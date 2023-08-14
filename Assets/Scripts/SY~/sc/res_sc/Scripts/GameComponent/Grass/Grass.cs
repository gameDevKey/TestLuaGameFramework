using UnityEngine;
using System.Collections.Generic;

public class GrassManager
{
    public List<Grass> allList = new List<Grass>();
    public List<Grass> tempGrassList = new List<Grass>();
    public List<Transform> heroList = new List<Transform>();

    private Dictionary<Vector2, List<Grass>> grassGridDict = new Dictionary<Vector2, List<Grass>>();
    private Dictionary<int, Vector3> lastTriggerPosDict = new Dictionary<int, Vector3>();
    private List<Vector3> tempTriggerPosList = new List<Vector3>();
    private GrassInstanced currentinstanced;

    public static int hitRange = 1;
    public static GrassManager _Instance;

    public static GrassManager Instance
    {
        get
        {
            if(_Instance == null)
            {
                _Instance = new GrassManager();
            }
            return _Instance;
        }
    }

    public void ClearAll()
    {
        allList.Clear();
        tempGrassList.Clear();
        grassGridDict.Clear();
        lastTriggerPosDict.Clear();
        tempGrassList.Clear();
    }

    public void AddItem(Grass grass)
    {
        Vector2 grid = new Vector2((int)grass.pos.x, (int)grass.pos.z);
        if (grassGridDict.ContainsKey(grid))
        {
            grassGridDict[grid].Add(grass);
        }
        else
        {
            grassGridDict[grid] = new List<Grass>();
            grassGridDict[grid].Add(grass);
        }
        allList.Add(grass);
    }

    public List<Grass> movingList = new List<Grass>();

    public void UpdateAllList(Dictionary<int, Vector3> triggerPosDict)
    {
        //检查对象是否移动
        tempTriggerPosList.Clear();
        foreach (var one in triggerPosDict)
        {
            int uid = one.Key;
            if (lastTriggerPosDict.ContainsKey(uid))
            {
                if (Vector3.Distance(lastTriggerPosDict[uid], triggerPosDict[uid]) > 0.01)
                {
                    tempTriggerPosList.Add(triggerPosDict[uid]);
                }
            }
            else
            {
                tempTriggerPosList.Add(triggerPosDict[uid]);
            }
        }
        
        lastTriggerPosDict.Clear();
        foreach (var one in triggerPosDict)
        {
            lastTriggerPosDict[one.Key] = one.Value;
        }

        //检查被击中的草
        for (int i = 0; i < tempTriggerPosList.Count; i++)
        {
            int ox = (int)tempTriggerPosList[i].x;
            int oz = (int)tempTriggerPosList[i].z;
            for (int x = ox - hitRange; x < ox + hitRange; x++)
            {
                for (int z = oz - hitRange; z < oz + hitRange; z++)
                {
                    Vector2 grid = new Vector2(x, z);
                    List<Grass> grassList;
                    grassGridDict.TryGetValue(grid, out grassList);
                    if (grassList != null)
                    {
                        for (int k = 0; k < grassList.Count; k++)
                        {
                            if (!movingList.Contains(grassList[k]) && Vector3.Distance(grassList[k].pos, tempTriggerPosList[i]) < hitRange)
                            {
                                grassList[k].StartMove();
                                movingList.Add(grassList[k]);
                            }
                        }
                    }
                }
            }
        }

        Grass.MoveStep();

        for(int i = 0; i < allList.Count; i++)
        {
            allList[i].Move();
        }

        tempGrassList.Clear();
        for (int i = 0; i < movingList.Count; i++)
        {
            movingList[i].MoveFast();
            if(!movingList[i].isplay)
            {
                tempGrassList.Add(movingList[i]);
            }
        }

        for(int i = 0; i < tempGrassList.Count; i++)
        {
            movingList.Remove(tempGrassList[i]);
        }
        
        //Debug.Log("moveHitList " + tempTriggerPosList.Count);
        //Debug.Log("movingGrassList " + movingList.Count);
    }

    public void AddHero(Transform ts)
    {
        for (int i = 0; i < heroList.Count; i++)
        {
            if (heroList[i] == ts)
                return;
        }
        heroList.Add(ts);
        if (currentinstanced != null)
            currentinstanced.heroList = heroList;
    }
    public void RemoveHero(Transform ts)
    {
        int num = heroList.Count;
        for (int i = 0; i < num; i++)
        {
            if (heroList[i] == ts)
            {
                Transform h = heroList[i];
                heroList[i] = heroList[num - 1];
                heroList[num - 1] = h;
                break;
            }
        }
        heroList.RemoveAt(num - 1);
        if (currentinstanced != null)
            currentinstanced.heroList = heroList;
    }
    public void RemoveHero(int idx)
    {
        int num = heroList.Count;
        Transform h = heroList[idx];
        heroList[idx] = heroList[num - 1];
        heroList[num - 1] = h;
        heroList.RemoveAt(num - 1);
        if (currentinstanced != null)
            currentinstanced.heroList = heroList;
    }
}


public class Grass
{

    public Vector2 offset;
    public Vector3 pos;
    public bool isplay;

    public static int globalStep;
    public int selfStep;
    public int passStep;
    public int mat_id;

    public Quaternion rotation;
    public Vector4 color;
    public Matrix4x4 materix;
    public float scale;

    public static int hitRange = 1;
    public static int normalSpeed = 3;
    public static int fastSpeed = 6;
    public static int fastSpeedCircle = 314 * 4;
    public static float normalSwayRange = 3f;
    public static float fastSwayRange = 6f;

    public Grass(Vector3 pos, Quaternion r, float scale, Vector4 c, int matid)
    {
        this.rotation = r;
        this.pos = pos;
        this.color = c;
        this.materix = Matrix4x4.TRS(pos, r, new Vector3(1, 1, 1));
        this.scale = scale;
        this.mat_id = matid;

        GrassManager.Instance.AddItem(this);
    }

    public static void MoveStep()
    {
        globalStep += normalSpeed;
        if (globalStep > fastSpeedCircle)
            globalStep -= fastSpeedCircle;
    }

    public void StartMove()
    {
        isplay = true;
        passStep = 0;
        selfStep = 0;
    }



    public void MoveFast()
    {
        float range = 0f;
        float speed = 0f;
        float lerp = 0f;
        if (fastSpeedCircle <= 0)
        {
            isplay = false;
            return;
        }

        //if(selfStep < fastSpeedCircle / 3)
        //{
        //    lerp = selfStep / (fastSpeedCircle / 3.0f);
        //    speed = Mathf.Lerp(normalSpeed, fastSpeed, lerp);
        //    range = Mathf.Lerp(normalSwayRange, fastSwayRange, lerp);
        //}
        //else
        if (selfStep < fastSpeedCircle * 2/ 3)
        {
            speed = fastSpeed;
            range = fastSwayRange;
        }
        else
        {
            lerp = (fastSpeedCircle - selfStep) / (fastSpeedCircle / 3.0f);
            speed = Mathf.Lerp(normalSpeed, fastSpeed, lerp);
            range = Mathf.Lerp(normalSwayRange, fastSwayRange, lerp);
        }


        selfStep += (int)speed;
        int index = globalStep + selfStep;
        offset = new Vector2(Mathf.Sin(index * 0.01f) * range, Mathf.Cos(index * 0.01f) * range);
        if (selfStep > fastSpeedCircle)
        {
            isplay = false;
        }
    }

    public void Move()
    {
        int index = globalStep + selfStep;
        offset = new Vector2(Mathf.Sin(index * 0.01f) * normalSwayRange, Mathf.Cos(index * 0.01f) * normalSwayRange);
    }
}