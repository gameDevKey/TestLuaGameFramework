using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ntreev.Library.Psd;
using UnityEngine;
using UnityEngine.UI;
using System.Text.RegularExpressions;

namespace PsdUIExporter {
    public abstract class AbstractNode : INode {
        public INode parent;
        private List<INode> childList = new List<INode>();

        protected ImageComponent imageComp = null;
        protected ButtonComponent buttonComp = null;

        public PsdLayer layer = null;
        public Rect rect;
        public string name = null;
        public bool IsVisible = true;
        public LayerType layerType = LayerType.Normal;
        public INode parentNode = null;
        public bool isPublic = false;
        public bool isIgnore = false;
        public bool isRepeated = false;
        public bool isLocal = false;
        public bool transformOnly = false;
        public bool noImage = false;
        public bool isRef = false;

        public GameObject gameObject = null;
        public Transform transform = null;
        public OperableVO operVo = null;

        public string paramStr = null;
        public string nameVerify = null;

        private Regex nameRegex = new Regex(@"^([A-Za-z0-9_%])+$");

        public AbstractNode (OperableVO operVo, PsdLayer layer, INode parentNode) {
            this.operVo = operVo;
            this.layer = layer;
            this.name = layer.Name.Trim();
            if (this.name.Contains("拷贝")) {
                this.name = this.name.Substring(0, this.name.IndexOf("拷贝")).Trim();
            }
            if (this.name.IndexOf("|") > 0) {
                this.paramStr = this.name.Substring(this.name.IndexOf("|") + 1);
                this.name = this.name.Substring(0, this.name.IndexOf("|"));
            }
            this.name = this.name.Replace(" ", "");
            //美术老是命名错，特殊处理下
            if (this.name == "c_zhuangsh4") {
                this.name = "c_zhuangshi4";
            }
            this.nameVerify = DoVerifyName(name);
            this.IsVisible = layer.IsVisible;
            this.layerType = layer.LayerType;
            this.parentNode = parentNode;
            this.rect = ExportUtility.GetRectFromLayer(layer, parentNode);

            if (this.name != null && this.name.StartsWith("c_")) {
                isPublic = true;
            }

            isIgnore = NeedIgnore();

            ExportContext.GetInstance().ParamAfterInitProcess(this);
        }

        public bool NeedIgnore() {
            if (!IsVisible) {
                return true;
            }
            if (name != null && (name.ToLower().StartsWith("noexport_") || name.ToLower().StartsWith("ignore_"))) {
                return true;
            } else {
                return false;
            }
        }

        public void AddChild(INode node) {
            childList.Add(node);
        }
        public List<INode> GetChilds() {
            return childList;
        }

        public Rect GetRect() {
            return rect;
        }

        public virtual Transform GetTransform() {
            return transform;
        }

        public INode GetParentNode() {
            return parentNode;
        }

        public string GetName() {
            return name;
        }

        public void SetName(string name) {
            this.name = name;
        }

        public LayerType GetLayerType() {
            return this.layerType;
        }

        public bool IsPublic() {
            return isPublic;
        }

        public bool IsIgnore() {
            return isIgnore;
        }

        public void SetIgnore(bool ignore) {
            isIgnore = ignore;
        }

        public GameObject GetGameObject() {
            return gameObject;
        }

        public bool IsRepeated() {
            return isRepeated;
        }

        public bool IsLocal () {
            return isLocal;
        }

        public void SetRepeated(bool rep) {
            isRepeated = rep;
        }

        public bool IsTransformOnly() {
            return transformOnly;
        }
        public void SetTransformOnly(bool only) {
            transformOnly = only;
        }

        public string GetParamStr() {
            return paramStr;
        }

        public ButtonComponent GetButtonComponent() {
            return buttonComp;
        }
        public void SetButtonComponent(ButtonComponent comp) {
            Image image = comp.button.gameObject.GetComponent<Image>();
            if (image != null) {
                image.raycastTarget = true;
            }
            this.buttonComp = comp;
        }

        public bool NoImage() {
            return noImage;
        }

        public void SetNoImage(bool noimage) {
            this.noImage = noimage;
            foreach (INode node in childList) {
                node.SetNoImage(noimage);
            }
        }

        public string GetNameVerify() {
            return nameVerify;
        }

        private string DoVerifyName(string str) {
            return null;
            if (!nameRegex.IsMatch(str)) {
                return "非法名";
            } else {
                return null;
            }
        }

        public void CreatePrefab() {
            if (isIgnore)
                return;
            if (this.gameObject == null) {
                this.gameObject = ExportUtility.CreateGameObject(this.name, this.rect, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f));
                this.transform = this.gameObject.transform;
                this.gameObject.transform.SetParent(parentNode.GetTransform(), false);
            }

            if (transformOnly)
                return;
            AddComponent();

            foreach (INode node in childList) {
                node.CreatePrefab();
            }
        }

        public virtual void CreateImage() {
            if (isIgnore)
                return;
            if (gameObject == null) {
                return;
            }
            if (transformOnly)
                return;
            foreach (INode node in childList) {
                node.CreateImage();
            }
        }

        public virtual void CheckRepeated() {
            DoVerifyName(name);
            if (isIgnore)
                return;
            if (gameObject == null) {
                return;
            }
            foreach (INode node in childList) {
                node.CheckRepeated();
            }
        }


        public virtual void AddComponent() {
            ExportContext.GetInstance().ParamProcess(this);
        }

        public virtual void Parse() { }
    }
}
