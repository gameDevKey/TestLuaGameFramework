using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

namespace PsdUIExporter {
    public class GroupNode : AbstractNode {

        public GroupNode(OperableVO operVo, PsdLayer layer, INode parentRect) : base(operVo, layer, parentRect) {

        }
    }
}
