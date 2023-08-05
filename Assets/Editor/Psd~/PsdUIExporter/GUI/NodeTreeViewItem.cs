using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor.IMGUI.Controls;
using UnityEditor;

namespace PsdUIExporter {
    public class NodeTreeViewItem : TreeViewItem {

        public INode node = null;

        public NodeTreeViewItem(int id, int depth, INode node = null) : base(id, depth, node == null ? "" : node.GetName()) {
            this.node = node;
        }
    }
}
