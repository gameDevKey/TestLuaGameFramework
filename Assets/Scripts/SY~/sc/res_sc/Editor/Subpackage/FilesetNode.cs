using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

public class FilesetNode : IParentNode {

    private FilesetType type = FilesetType.INCLUDE;
    private List<IParentNode> subList = new List<IParentNode> ();
    private List<IParentNode> excList = new List<IParentNode> ();
    private string dir = null;
    private string dirPhysics = null;
    public int sort = 50;

    public FilesetNode (XmlElement node) {
        dir = node.GetAttribute ("dir");
        if (dir.ToLower().Equals("Prefabs/UI".ToLower())) {
            dir = dir + "_" + SubpackageTool.platform;
        } else if (dir.ToLower().Equals("Textures/UI".ToLower())) {
            dir = dir + "_" + SubpackageTool.platform;
        } 
        dirPhysics = dir.Replace("/", "$").ToLower();
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

        if (node.HasAttribute ("sort")) {
            this.sort = Convert.ToInt32 (node.GetAttribute ("sort"));
        }

        XmlNodeList list = node.ChildNodes;
        foreach (XmlNode subNode in list) {
            if (subNode is XmlElement) {
                if (subNode.Name.Equals ("include")) {
                    subList.Add (new IncludeNode ((XmlElement)subNode, type, dir));
                } else if (subNode.Name.Equals ("exclude")) {
                    excList.Add (new ExcludeNode ((XmlElement)subNode, type, dir));
                }
            }
        }
    }

    public bool Contains (string path) {
        if (path.StartsWith (dirPhysics)) {
            return true;
        } else {
            return false;
        }
    }

    public bool Check (string path) {
        if (!path.StartsWith (dirPhysics)) {
            return true;
        }
        if (subList.Count > 0 || excList.Count > 0) {
            foreach (IParentNode node in subList) {
                if (node.Check (path)) {
                    return true;
                }
            }
            foreach (IParentNode node in excList) {
                if (!node.Check (path)) {
                    return false;
                }
            }
            // return false;
        // } else {
        }
            if (type == FilesetType.INCLUDE) {
                return true;
            } else {
                return false;
            }
        // }
    }

    public int GetSort () {
        return sort;
    }
}

public enum FilesetType {
    INCLUDE = 1
    ,EXCLUDE = 2
}