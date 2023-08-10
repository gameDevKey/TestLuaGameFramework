using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.SceneManagement;
using UnityEditor;

public class GameLoading : MonoBehaviour
{
    public RectTransform ProgressFill;
    public Text ProgressTips;
    public Text Log;
    public Button EnterButton;

    private string logStr;
    private bool isFinish;

    void Awake()
    {
        Application.logMessageReceived += ShowLog;
        HandleProcess(GameLaunch.OpType.Unknown, 0);
        EnterButton.onClick.AddListener(OnEnterButtonClick);
        EnterButton.gameObject.SetActive(false);
    }

    void Start()
    {
        GameLaunch.Instance.onProcess += HandleProcess;
        GameLaunch.Instance.onFinish += UpdateBtnState;
    }

    void OnDestroy()
    {
        GameLaunch.Instance.onProcess -= HandleProcess;
        GameLaunch.Instance.onFinish -= UpdateBtnState;
        Application.logMessageReceived -= ShowLog;
        EnterButton.onClick.RemoveListener(OnEnterButtonClick);
    }

    void OnEnterButtonClick()
    {
        SceneManager.LoadSceneAsync("Main", LoadSceneMode.Single);
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

    void UpdateBtnState()
    {
        if (!isFinish)
        {
            isFinish = true;
            EnterButton.gameObject.SetActive(true);
        }
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