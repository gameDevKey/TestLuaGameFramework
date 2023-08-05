using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PsdUIExporter {
    public abstract class AbstractParamBO : IParamBO {

        public virtual void Process(INode node, string param) {
        }

        public virtual bool Check(INode node, string param) {
            return false;
        }
    }
}
