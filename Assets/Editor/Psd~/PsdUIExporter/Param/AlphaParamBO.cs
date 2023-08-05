using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace PsdUIExporter {
    public class AlphaParamBO : AbstractParamBO {

        public override void Process(INode node, string param) {
            if (node is ImageNode) {
                ImageNode inode = (ImageNode)node;
                inode.SetImageAlpha();
            }
        }

        public override bool Check(INode node, string param) {
            if (param == null)
                return false;
            if (param.Contains("alpha")) {
                return true;
            } else {
                return false;
            }
        }
    }
}
