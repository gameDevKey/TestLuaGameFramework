using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PsdUIExporter {
    public class OperableVO {
        public string subAtlasName = null;

        public string nodeName = null;

        public int noteType = PNoteType.Image;
        public int resType = PResType.Private;
        public string nodeSubAtlasName = null;
        public NodeTreeViewItem item = null;

        public bool ignore = false;
        public bool transformOnly = false;
        public bool noImage = false;
        public bool isMirror = false;

        public int select_width = 0;
        public int select_heigth = 0;

        public PSlice pslice = new PSlice();
        public string parseErrorLayer = null;
        public string paramStr = null;
        public string warnError = null;

        public GImageType gimageType = GImageType.All;

        public void Clear() {
        	nodeName = null;
        	noteType = PNoteType.Image;
        	resType = PResType.Private;
        	nodeSubAtlasName = null;
            if (item != null && item.node is ImageNode) {
                ((ImageNode)item.node).SetSliceTexture(null);
            }
            item = null;
            transformOnly = false;
            noImage = false;
            isMirror = false;
            paramStr = null;

            select_width = 0;
            select_heigth = 0;
            pslice = new PSlice();
        }

        public void SetNodeItem(NodeTreeViewItem item) {
            Clear();

            this.item = item;
            INode node = item.node;
            nodeName = node.GetName();
            switch (node.GetLayerType()) {
                case LayerType.Group:
                    noteType = PNoteType.Group;
                    break;
                case LayerType.Text:
                    noteType = PNoteType.Text;
                    break;
                default:
                    noteType = PNoteType.Image;
                    break;
            }
            if (node.IsIgnore()) {
                ignore = true;
            } else {
                ignore = false;
            }
            transformOnly = node.IsTransformOnly();
            noImage = node.NoImage();
            paramStr = node.GetParamStr();
            if (node is ImageNode) {
                select_width = (int)node.GetRect().width;
                select_heigth = (int)node.GetRect().height;
                nodeSubAtlasName = ((ImageNode)node).nodeSubAtlasName;
                isMirror = ((ImageNode)node).isMirror;
            }
        }

        public string GetTextureSizeStr() {
            if (select_width == 0) {
                return "";
            }
            return "" + select_width + "X" + select_heigth;
        }
    }


    public class PNoteType {
        public const int Image = 1;
        public const int Group = 2;
        public const int Text = 3;
    }

    public class PResType {
        public const int Public = 1;
        public const int Private = 2;
    }

    public class PBool {
        public const int False = 0;
        public const int True = 1;
    }

    public enum GImageType {
        All = 1,
        NotRepeated = 2,
        Single = 3
    }

    public class PSlice {
        public PSlice() {
        }

        public PSlice(int top, int right, int bottom, int left) {
            this.top = top;
            this.right = right;
            this.bottom = bottom;
            this.left = left;
        }
        public int top = 0;
        public int right = 0;
        public int bottom = 0;
        public int left = 0;

        public PSlice Clone() {
            return new PSlice(top, right, bottom, left);
        }
    }
}
