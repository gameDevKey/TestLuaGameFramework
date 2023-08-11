using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ntreev.Library.Psd;
using UnityEngine;

namespace PsdUIExporter {
    public interface INode {

        void AddChild(INode node);
        void Parse();
        string GetName();
        void SetName(string name);
        Rect GetRect();
        Transform GetTransform();
        INode GetParentNode();
        LayerType GetLayerType();
        bool IsPublic();
        bool IsIgnore();
        void SetIgnore(bool ignore);
        GameObject GetGameObject();
        bool IsRepeated();
        bool IsLocal();
        bool IsTransformOnly();
        bool NoImage();
        void SetNoImage(bool noImage);
        void SetTransformOnly(bool only);
        string GetParamStr();
        List<INode> GetChilds();
        ButtonComponent GetButtonComponent();
        void SetButtonComponent(ButtonComponent comp);
        string GetNameVerify();

        void CreatePrefab();
        void CreateImage();
        void CheckRepeated();

        void AddComponent();
    }
}
