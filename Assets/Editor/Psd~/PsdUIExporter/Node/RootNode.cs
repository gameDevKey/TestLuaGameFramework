using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ntreev.Library.Psd;
using UnityEngine;

namespace PsdUIExporter {
    class RootNode : INode {

        public List<INode> childList = new List<INode>();

        public string name = null;
        public GameObject gameObject = null;
        public Transform transform = null;
        public Rect rect = new Rect(0, 0, 720, 1280);

        public RootNode(string name) {
            this.name = name;
        }

        public void AddChild(INode node) {
            childList.Add(node);
        }

        public void Parse() {
            foreach (INode node in childList) {
                node.Parse();
            }
        }

        public void Build() {
        }

        public Rect GetRect() {
            return rect;
        }

        public Transform GetTransform() { 
            return transform; 
        }

        public INode GetParentNode() {
            return null;
        }

        public string GetName() {
            return name;
        }

        public void SetName(string name) {
            this.name = name;
        }

        public LayerType GetLayerType() {
            return LayerType.Group;
        }

        public bool IsPublic() {
            return false;
        }

        public bool IsIgnore() {
            return false;
        }

        public void SetIgnore(bool ignore) {
        }

        public GameObject GetGameObject() {
            return gameObject;
        }

        public bool IsRepeated() {
            return false;
        }

        public bool IsLocal () {
            return false;
        }

        public bool IsTransformOnly() {
            return false;
        }

        public void SetTransformOnly(bool only) {
        }

        public string GetParamStr() {
            return null;
        }

        public List<INode> GetChilds() {
            return new List<INode>();
        }

        public bool NoImage() {
            return false;
        }

        public void SetNoImage(bool noimage) {
        }

        public ButtonComponent GetButtonComponent() {
            return null;
        }
        public void SetButtonComponent(ButtonComponent comp) {
        }

        public string GetNameVerify() {
            return null;
        }

        public void CreatePrefab() {
            this.gameObject = ExportUtility.CreateGameObject(this.name, new Rect(0, 0, 0, 0), new Vector2(0.5f, 0.5f), new Vector2(1, 1), new Vector2(0, 0));
            this.transform = this.gameObject.transform;
            this.transform.SetParent(GameObject.Find("Canvas").transform, false);

            foreach (INode node in childList) {
                node.CreatePrefab();
            }
        }

        public void CreateImage() {
            foreach (INode node in childList) {
                node.CreateImage();
            }
        }

        public void CheckRepeated() {
            foreach (INode node in childList) {
                node.CheckRepeated();
            }
        }

        public void AddComponent() {
        }
    }
}
