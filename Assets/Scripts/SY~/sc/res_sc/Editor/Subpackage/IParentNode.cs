using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public interface IParentNode {

    bool Contains (string path);
    bool Check (string path);
    int GetSort ();
}
