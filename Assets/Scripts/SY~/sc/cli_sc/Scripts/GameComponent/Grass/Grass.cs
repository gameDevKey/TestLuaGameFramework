using UnityEngine;
using System.Collections.Generic;
using XLua;

[LuaCallCSharp]
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
    public bool isshow;
    public int posKey = 0;

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
        int x = (int)pos.x;
        int z = (int)pos.z;
        this.posKey = GetPosKey(x, z);
        GrassManager.Instance.AddItem(this);
    }

    public static int GetPosKey(int x, int z)
    {
        return x * 1000000 + z;
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