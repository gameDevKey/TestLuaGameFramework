using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

public class ProcessTask
{

    private ProcessStartInfo processInfo;
    private string processCmd;

    public  ProcessTask(string cmd)
    {
        processCmd = cmd;
    }

    public void Run()
    {
        ProcessStartInfo processInfo = CreateStartInfo();
        Process process = Process.Start(processInfo);

        process.StandardInput.WriteLine();
        process.StandardInput.WriteLine(processCmd);
        process.StandardInput.WriteLine("exit");

        var result = process.StandardOutput.ReadToEnd();
        var error = process.StandardError.ReadToEnd();
        process.WaitForExit();
        var exit = process.ExitCode;
        process.Close();

        byte[] buffer = Encoding.Default.GetBytes(result);
        string outtr = Encoding.UTF8.GetString(buffer, 0, buffer.Length);
        UnityEngine.Debug.Log(outtr);

        if (exit != 0)
        {
            throw new Exception(string.Format("Process ExitCode: {0}\n{1}", exit, error));
        }
    }

    public ProcessStartInfo CreateStartInfo(string fileName = null, string arguments = null, bool createNoWindow = true, bool useShell = false)
    {
        if (string.IsNullOrEmpty(fileName))
        {
            switch (Application.platform)
            {
                case RuntimePlatform.WindowsEditor:
                    {
                        fileName = "cmd.exe";
                        break;
                    }
                case RuntimePlatform.OSXEditor:
                    {
                        fileName = "/bin/bash";
                        break;
                    }
            }
        }

        ProcessStartInfo startInfo = new ProcessStartInfo()
        {
            FileName = fileName,
            Arguments = arguments ?? "",
            CreateNoWindow = createNoWindow,
            UseShellExecute = useShell,
            ErrorDialog = true,
            RedirectStandardInput = true,
            RedirectStandardOutput = !useShell,
            RedirectStandardError = !useShell,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
        };

        return startInfo;
    }

}
