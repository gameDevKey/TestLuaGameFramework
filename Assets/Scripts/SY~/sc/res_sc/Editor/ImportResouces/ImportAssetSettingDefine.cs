using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImportAssetSettingDefine
{
   
}

//匹配案例1：匹配某格式路径
//Regex.IsMatch("Assets/Editor/100/anim", @"Assets/Editor/(\d+)/anim$")

//匹配案例2：不递归路径
//Regex.IsMatch("Assets/Editor/100/anim", @"Assets/Editor$")

//匹配案例2：递归路径
//Regex.IsMatch("Assets/Editor/100/anim", @"Assets/Editor")