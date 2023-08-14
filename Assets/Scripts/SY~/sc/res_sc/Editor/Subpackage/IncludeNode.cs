using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;

public class IncludeNode : IParentNode {

    private FilesetType type = FilesetType.INCLUDE;
    private string dir = null;
    private string dirPhy = null;
    private string file = null;

    public IncludeNode (XmlElement node, FilesetType type, string dir) {
        this.type = type;
        this.dir = dir;
        this.file = node.GetAttribute ("file");
        this.dirPhy = dir.Replace("/", "$").ToLower() + "$" + this.file.Replace("/", "$").ToLower();
    }

    public bool Contains (string path) {
        return true;
    }

    public bool Check (string path) {
        if (type == FilesetType.INCLUDE) {
            return true;
        } else {
            if (path.Contains("51001") && dirPhy.Contains("51001")) {
                string ss = "";
            }
            if (this.dirPhy.StartsWith(path) || path.StartsWith(dirPhy)) {
                return true;
            } else {
                return false;
            }
        }
    }

    public int GetSort () {
        return 50;
    }
}
