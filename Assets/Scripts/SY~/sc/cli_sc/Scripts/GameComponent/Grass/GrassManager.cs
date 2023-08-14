using UnityEngine;
using System.Collections.Generic;
using XLua;

[LuaCallCSharp]
public class GrassManager
{
    public List<Grass> allList = new List<Grass>();
    public List<Grass> tempGrassList = new List<Grass>();
    public List<Transform> heroList = new List<Transform>();

    private Dictionary<int, List<Grass>> grassGridDict = new Dictionary<int, List<Grass>>();
    private Dictionary<int, Vector3> lastTriggerPosDict = new Dictionary<int, Vector3>();
    private List<Vector3> tempTriggerPosList = new List<Vector3>();
    private GrassInstanced currentinstanced;

    private int checkIndex = 0;
    public static int hitRange = 1;
    public static GrassManager _Instance;

    public static Camera camera;
    public static Transform cameraTransform;
    private static Vector3 lastCameraPos;
    private static int lastFrame;

    public static GrassManager Instance
    {
        get
        {
            if (_Instance == null)
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


    public bool IsInView(Vector3 worldPos)
    {
        Vector2 viewPos = camera.WorldToViewportPoint(worldPos);
        Vector3 dir = (worldPos - cameraTransform.position).normalized;
        float dot = Vector3.Dot(cameraTransform.forward, dir);//判断物体是否在相机前面

        if (dot > 0 && viewPos.x >= -0.2 && viewPos.x <= 1.2 && viewPos.y > -0.2 && viewPos.y <= 1.2)
            return true;
        else
            return false;
    }


    public void CheckGrassInView()
    {
        if (camera == null || cameraTransform == null)
            return;
        int allcount = allList.Count;
        if (allcount == 0)
            return;
        int n = Mathf.Max(allcount / 30, 1);
        while (n > 0)
        {
            n -= 1;
            checkIndex += 1;
            if (checkIndex >= allcount)
                checkIndex = 0;

            Grass grass = allList[checkIndex];
            if (IsInView(grass.pos))
            {
                grass.isshow = true;
            }
            else
            {
                grass.isshow = false;
            }
        }

    }

    public void AddItem(Grass grass)
    {
        int key = grass.posKey;
        if (grassGridDict.ContainsKey(key))
        {
            grassGridDict[grass.posKey].Add(grass);
        }
        else
        {
            grassGridDict[key] = new List<Grass>();
            grassGridDict[key].Add(grass);
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
                    int key = Grass.GetPosKey(x, z);
                    if (grassGridDict.ContainsKey(key))
                    {
                        List<Grass> grassList = grassGridDict[key];
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
        }

        Grass.MoveStep();

        for (int i = 0; i < allList.Count; i++)
        {
            if (allList[i].isshow)
            {
                allList[i].Move();
            }

        }

        tempGrassList.Clear();
        for (int i = 0; i < movingList.Count; i++)
        {
            movingList[i].MoveFast();
            if (!movingList[i].isplay)
            {
                tempGrassList.Add(movingList[i]);
            }
        }

        for (int i = 0; i < tempGrassList.Count; i++)
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
        bool has = false;
        int num = heroList.Count;
        for (int i = 0; i < num; i++)
        {
            if (heroList[i] == ts)
            {
                Transform h = heroList[i];
                heroList[i] = heroList[num - 1];
                heroList[num - 1] = h;
                has = true;
                break;
            }
        }
        if (!has)
        {
            return;
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