using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.SceneManagement;

public class GameLoading : MonoBehaviour
{
    public RectTransform ProgressFill;
    public Text ProgressTips;
    public Text Log;
    public Button EnterButton;

    private string logStr;

    void Awake()
    {
        Application.logMessageReceived += ShowLog;
        HandleProcess(GameLaunch.OpType.Unknown, 0);
        EnterButton.onClick.AddListener(OnEnterButtonClick);
    }

    void Start()
    {
        GameLaunch.Instance.onProcess += HandleProcess;
    }

    void OnDestroy()
    {
        GameLaunch.Instance.onProcess -= HandleProcess;
        Application.logMessageReceived -= ShowLog;
        EnterButton.onClick.RemoveListener(OnEnterButtonClick);
    }

    void OnEnterButtonClick()
    {
        SceneManager.LoadSceneAsync("Main",LoadSceneMode.Single);
    }

    void ShowLog(string condition, string stackTrace, LogType type)
    {
        logStr += condition + "\n";
        Log.text = logStr;
    }

    void HandleProcess(GameLaunch.OpType opType, float progress)
    {
        UpdateImageFill(progress);
        UpdateTips(opType, progress);
    }

    void UpdateImageFill(float progress)
    {
        ProgressFill.localScale = new Vector3(progress, 1, 1);
    }

    void UpdateTips(GameLaunch.OpType opType, float progress)
    {
        var name = "资源准备中";
        switch (opType)
        {
            case GameLaunch.OpType.AddressablesInit:
                name = "引擎初始化中";
                break;
            case GameLaunch.OpType.CatalogCheckUpdate:
                name = "检查资源更新中";
                break;
            case GameLaunch.OpType.CatalogUpdate:
                name = "更新资源中";
                break;
        }
        ProgressTips.text = $"{name}... {GetPercentStr(progress)}";
    }

    string GetPercentStr(float progress)
    {
        int num = (int)Mathf.Ceil(progress * 100);
        return $"{num}%";
    }
}