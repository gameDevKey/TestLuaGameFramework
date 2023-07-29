using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PsdUIExporter {
    public class ParamParser {

        private List<IParamBO> listBO = new List<IParamBO>();
        private List<IParamBO> afterInitBO = new List<IParamBO>();

        public ParamParser() {
            listBO.Add(new AlphaParamBO());
            listBO.Add(new ButtonParamBO());

            afterInitBO.Add(new NoImageParamBO());
            afterInitBO.Add(new MirrorParamBO());
        }

        public void Parser(INode node) {
            if (node.GetParamStr() != null) {
                string paramStr = node.GetParamStr();
                string[] paramArr = paramStr.Split(new char[]{'&'});
                if (paramStr != null) {
                    foreach (string param in paramArr) {
                        foreach (IParamBO bo in listBO) {
                            if (bo.Check(node, param)) {
                                bo.Process(node, param);
                            }
                        }
                    }
                }
            }
        }

        public void AfterInitParser(INode node) {
            if (node.GetParamStr() != null) {
                string paramStr = node.GetParamStr();
                string[] paramArr = paramStr.Split(new char[]{'&'});
                if (paramStr != null) {
                    foreach (string param in paramArr) {
                        foreach (IParamBO bo in afterInitBO) {
                            if (bo.Check(node, param)) {
                                bo.Process(node, param);
                            }
                        }
                    }
                }
            }
        }
    }
}
