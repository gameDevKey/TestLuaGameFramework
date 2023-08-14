using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

public class FileNode : IParentNode {

    private FilesetType type = FilesetType.INCLUDE;
    private string file = null;
    private string filePhysics = null;
    public int sort = 50;

    public FileNode (XmlElement node) {
        this.file = node.GetAttribute ("file");
        this.filePhysics = this.file.Replace("/", "$").ToLower();
        if (node.HasAttribute ("sort")) {
            this.sort = Convert.ToInt32 (node.GetAttribute ("sort"));
        }
        if (node.HasAttribute ("type")) {
            string types = node.GetAttribute ("type");
            if (types.ToLower ().Equals ("exclude")) {
                type = FilesetType.EXCLUDE;
            } else {
                type = FilesetType.INCLUDE;
            }
        } else {
            type = FilesetType.INCLUDE;
        }
    }

    public bool Contains (string path) {
        if (path != null && (path.Trim().ToLower().StartsWith((filePhysics.Trim())) || filePhysics.Trim().StartsWith(path.Trim().ToLower()))) {
            return true;
        } else {
            return false;
        }
    }

    public bool Check (string path) {
        if (path != null && (path.Trim().ToLower().StartsWith((filePhysics.Trim())) || filePhysics.Trim().StartsWith(path.Trim().ToLower()))) {
            if (type == FilesetType.INCLUDE) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public int GetSort () {
        return sort;
    }
}
