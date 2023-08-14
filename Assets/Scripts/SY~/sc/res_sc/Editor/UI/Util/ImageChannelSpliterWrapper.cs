using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Diagnostics;

namespace EditorTools.UI
{
    public class ImageChannelSpliterWrapper
    {
        public static void Execute(string pngPath)
        {
            pngPath = string.Concat(Application.dataPath.Replace("/Assets", "/"), pngPath);
            string toolPath = string.Concat(Application.dataPath.Replace("/Assets", "/"), "Tool");
            string alphaPath = pngPath.Replace(".png", "_alpha.png");
            Process process = new Process();
            string paramContnet = string.Format("\"{0}\" \"{1}\" \"{2}\"", pngPath, alphaPath, toolPath);
            string batPath = toolPath + "/ImageChannelSpliter.bat ";
            // UnityEngine.Debug.Log(batPath);
            ProcessStartInfo info = new ProcessStartInfo(batPath, paramContnet);
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardInput = true;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.WindowStyle = ProcessWindowStyle.Minimized;
            process.StartInfo = info;
            process.Start();
            process.WaitForExit();
        }
    }
}
