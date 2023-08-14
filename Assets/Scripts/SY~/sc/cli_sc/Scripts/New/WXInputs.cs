using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class WXInputs : MonoBehaviour, IPointerClickHandler, IPointerExitHandler
{
    public InputField input;
    private bool isShowKeyboad = false;
    public string confirmType = "done";

    public void OnPointerClick(PointerEventData eventData)
    {
    }

    public void OnPointerExit(PointerEventData eventData)
    {
    }
}