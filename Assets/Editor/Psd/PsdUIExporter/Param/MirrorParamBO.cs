using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PsdUIExporter {
    public class MirrorParamBO : AbstractParamBO {

        public override void Process(INode node, string param) {
            if (node is ImageNode) {
                ImageNode inode = (ImageNode)node;
                inode.isMirror = true;
            }
        }

        public override bool Check(INode node, string param) {
            if (param == null)
                return false;
            if (param.Contains("mirror")) {
                return true;
            } else {
                return false;
            }
        }
    }
}
