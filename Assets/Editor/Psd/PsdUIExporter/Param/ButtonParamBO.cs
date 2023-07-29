using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PsdUIExporter {
    public class ButtonParamBO : AbstractParamBO {

        public override void Process(INode node, string param) {
            if (node is ImageNode && ((ImageNode)node).isRef) {
                return;
            }
            List<INode> childs = node.GetChilds();
            ImageNode imageNode = null;
            if (node.GetLayerType() == Ntreev.Library.Psd.LayerType.Group) {
                foreach (INode inode in childs) {
                    if (inode is ImageNode) {
                        imageNode = (ImageNode)inode;
                        imageNode.gameObject = node.GetGameObject();
                        imageNode.isRef = true;
                        break;
                    }
                }
            }
            ButtonComponent comp = new ButtonComponent();
            comp.AddComponent(node.GetGameObject());
            node.SetButtonComponent(comp);
        }

        public override bool Check(INode node, string param) {
            if (param == null)
                return false;
            if (param.StartsWith("button") && node.GetLayerType() != Ntreev.Library.Psd.LayerType.Text) {
                return true;
            } else {
                return false;
            }
        }
    }
}
