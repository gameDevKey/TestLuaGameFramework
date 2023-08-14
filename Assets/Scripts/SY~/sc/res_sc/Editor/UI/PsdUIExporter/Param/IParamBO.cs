using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PsdUIExporter {
    // 没有状态对象
    public interface IParamBO {

        void Process(INode node, string param);
        bool Check(INode node, string param);
    }
}
