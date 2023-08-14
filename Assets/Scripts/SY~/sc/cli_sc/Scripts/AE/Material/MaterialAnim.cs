using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MaskableGraphic))]
[ExecuteAlways]
public class MaterialAnim : MonoBehaviour
{
    [System.Serializable]
    public class Data
    {
        public string name;
        public string type;
        public bool enable;
    }

    public List<Data> Property = new List<Data>();

    private MaskableGraphic graphic;
    private Material animMat;
    private MeshRenderer meshRenderer;
    private MaterialPropertyBlock materialPropertyBlock;

    public void InitAnim()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        materialPropertyBlock = new MaterialPropertyBlock();
        graphic = GetComponent<MaskableGraphic>();
        animMat = Instantiate(graphic.material);
        graphic.material = animMat;
    }

    private void LateUpdate()
    {
        if (meshRenderer != null && meshRenderer.HasPropertyBlock())
        {
            meshRenderer.GetPropertyBlock(materialPropertyBlock);
            foreach (var item in Property)
            {
                if (item.enable)
                {
                    SetValue(item.name, item.type);
                }
            }
        }
    }

    public void EditorUpdate()
    {
        LateUpdate();
    }

    public void ActiveEditorUpdate(bool flag)
    {
#if UNITY_EDITOR
        if(flag)
        {
            UnityEditor.EditorApplication.update  += EditorUpdate;
        }
        else
        {
            UnityEditor.EditorApplication.update -= EditorUpdate;
        }
#endif
    }

    void SetValue(string name, string type)
    {
        switch (type)
        {
            case "Color":
                graphic.color = materialPropertyBlock.GetColor(name);
                break;
            case "Float":
            case "Range":
                graphic.material.SetFloat(name, materialPropertyBlock.GetFloat(name));
                break;
            case "Vector":
                graphic.material.SetVector(name, materialPropertyBlock.GetVector(name));
                break;
            default:
                break;
        }
    }

#if UNITY_EDITOR
    private void OnDestroy()
    {
        ActiveEditorUpdate(false);
    }
#endif
}
