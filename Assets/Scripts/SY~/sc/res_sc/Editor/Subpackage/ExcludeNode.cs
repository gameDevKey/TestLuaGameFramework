using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;

public class ExcludeNode : IParentNode {

    private FilesetType type = FilesetType.INCLUDE;
    private string file = null;
    private string dir = null;
    private string dirPhysics = null;

    public ExcludeNode (XmlElement node, FilesetType type, string dir) {
        this.type = type;
        this.dir = dir;
        this.file = node.GetAttribute ("file");
        this.dirPhysics = dir.Replace("/", "$").ToLower() + "$" + this.file.Replace("/", "$").ToLower();
    }

    public bool Contains (string path) {
        return true;
    }

    public bool Check (string path) {
        if (type == FilesetType.EXCLUDE) {
            return false;
        } else {
            if (dirPhysics.StartsWith(path) || path.StartsWith(dirPhysics)) {
                return false;
            } else {
                return true;
            }
        }
    }

    public int GetSort () {
        return 50;
    }
}
