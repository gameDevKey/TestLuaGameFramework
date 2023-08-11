using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEditor;
using UnityEngine;

namespace PsdUIExporter {
    public class SliceAuto {

        private string root = "Assets/Things/Textures/UI";
        private string module = null;
        private Queue<SliceAction> actionQueue = new Queue<SliceAction>();
        private SliceAction action = null;
        private SliceWindow window = null;
        public bool isStop = false;

        public SliceAuto(SliceWindow window, string module) {
            this.window = window;
            this.module = module;
            this.InitList();
        }

        private void InitList() {
            string path = root + "/" + module;
            DirectoryInfo dirInfo = new DirectoryInfo(path);
            FileInfo[] files = dirInfo.GetFiles();
            foreach (FileInfo file in files) {
                if (file.Name.ToLower().EndsWith("png")) {
                    actionQueue.Enqueue(new SliceAction(window, path + "/" + file.Name));
                }
            }
        }

        private int count = 0;
        public void Update(float deltaTime) {
            count++;
            if (count == 20) {
                count = 0;
                if (action != null) {
                    int statue = action.Next();
                    if (statue == -1) {
                        action = null;
                    }
                } else {
                    if (actionQueue.Count > 0 && !isStop) {
                        action = actionQueue.Dequeue();
                    } else {
                        if (window.sliceAuto != null) {
                            EditorUtility.DisplayDialog("提示", "完成", "确定");
                        }
                        window.sliceAuto = null;
                    }
                }
            }
        }
    }
}
