using Ntreev.Library.Psd;
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;

namespace PsdUIExporter {
    public class ImageNode : AbstractNode {

        private string path = null;
        public string nodeSubAtlasName = null;
        private Texture2D texture = null;
        private Texture2D sliceTexture = null;
        private PSlice pslice = null;

        public bool isMirror = false;

        public ImageNode(OperableVO operVo, PsdLayer layer, INode parentRect) : base(operVo, layer, parentRect) {
            try {
                texture = ExportUtility.CreateTexture(layer);
            } catch (Exception e) {
                operVo.parseErrorLayer = name;
                throw e;
            }
            AutoCheckResInfo resInfo = ExportContext.GetInstance().GetAutoCheckFile(name);
            if (!isPublic) {
                if (resInfo != null && resInfo.dirName.Equals(ExportContext.GetInstance().GetConfigVo().basePath)) {
                    isPublic = true;
                }
            }
            if (resInfo != null) {
                nodeSubAtlasName = resInfo.dirName;
            } else {
                string module = ExportContext.GetInstance().CheckPreDefined(name);
                if (module != null) {
                    nodeSubAtlasName = module;
                }
            }
            string cpath = GetResPath();
            if (File.Exists(cpath)) {
                isRepeated = true;
                isLocal = true;
            } else {
                isRepeated = false;
            }
        }

        public override void AddComponent() {
            imageComp = new ImageComponent();
            imageComp.AddComponent(gameObject);
            Button button = gameObject.GetComponent<Button>();
            if (button != null) {
                imageComp.image.raycastTarget = true;
            }

            if (isMirror) {
                DoMirror();
            }

            string cpath = GetResPath();
            if (File.Exists(cpath)) {
                isRepeated = true;
                // Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(cpath);
            	// imageComp.image.sprite = sprite;
            } else {
                isRepeated = false;
            }
            base.AddComponent();
        }

        private void SaveTexture() {
            byte[] buf = ExportUtility.EncordToPng(texture);
            path = GetResPath();
            string dir = Path.GetDirectoryName(path);
            if (!Directory.Exists(dir)) {
                Directory.CreateDirectory(dir);
            }
            File.WriteAllBytes(Path.GetFullPath(path), buf);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            ExportUtility.SetPlatformTextureSettings(path, 2048, ExportUtility.TRUE_COLOR);
            TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
            if (pslice != null) {
                importer.spriteBorder = new Vector4(pslice.left, pslice.bottom, pslice.right, pslice.top);
                imageComp.image.type = UnityEngine.UI.Image.Type.Sliced;
            }
            importer.spritePackingTag = GetAtlasName();
            AssetDatabase.ImportAsset(path);
            Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(path);
            imageComp.image.sprite = sprite;
        }

        public void SetImageAlpha() {
            if (imageComp != null && imageComp.image != null) {
                Color color = imageComp.image.color;
                Channel aChannel = Array.Find(layer.Channels, i => i.Type == ChannelType.Alpha);
                color.a = aChannel.Opacity;
                imageComp.image.color = color;
            }
        }

        public override void CreateImage() {
            if (isIgnore)
                return;

            if (gameObject == null)
                return;
            if (isMirror) {
                if (operVo.gimageType == GImageType.Single) {
                    operVo.warnError = operVo.warnError + " 【" + name + "】该结点为镜像结点，不能导出图片";
                }
                string cpath = GetResPath();
            	Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(cpath);
                if (sprite == null) {
                    operVo.warnError = operVo.warnError + " 【" + name + "】该结点为镜像结点，但找不到本地本地图片";
                } else {
                    imageComp.image.sprite = sprite;
                }
                return;
            }
            if (!(isRepeated && operVo.gimageType == GImageType.NotRepeated)) {
                if (!noImage) {
                    if (GetNameVerify() == null) {
                        SaveTexture();
                        isLocal = false;
                        isRepeated = true;
                    } else {
                        operVo.warnError = operVo.warnError + " 【" + name + "】该结点非法名字，不能导出图片";
                    }
                } else {
                    operVo.warnError = operVo.warnError + " 【" + name + "】该结点设置为NoImage，不导出图片";
                }
            }
            base.CreateImage();
        }

        public override void CheckRepeated() {
            string cpath = GetResPath();
            if (File.Exists(cpath)) {
                isRepeated = true;
            } else {
                isRepeated = false;
            }
            base.CheckRepeated();
        }

        public Texture2D GetTexture() {
            return texture;
        }

        public void SetTexture(Texture2D texture) {
            this.texture = texture;
        }

        public Texture2D GetFinalTexture() {
            if (sliceTexture != null) {
                return sliceTexture;
            } else {
                return texture;
            }
        }

        public void ResetTexture() {
            this.texture = ExportUtility.CreateTexture(layer);
            this.sliceTexture = null;
            this.pslice = null;
        }

        public Texture2D GetSclieTexture() {
            return sliceTexture;
        }

        public void SetSliceTexture(Texture2D texture) {
            this.sliceTexture = texture;
            if (texture != null) {
                // this.texture = texture;
                this.pslice = this.operVo.pslice.Clone();
            }
        }

        public void RelationImage() {
            if (isIgnore)
                return;
            if (gameObject == null || imageComp == null)
                return;
            string cpath = GetResPath();
            if (File.Exists(cpath)) {
                isRepeated = true;
            } else {
                isRepeated = false;
            }
            if (isRepeated) {
                Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(cpath);
            	imageComp.image.sprite = sprite;
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                Vector4 vect = importer.spriteBorder;
                if (vect != null && (vect.x + vect.y + vect.z + vect.w) > 2) {
                    imageComp.image.type = UnityEngine.UI.Image.Type.Sliced;
                }
            }
        }

        public void DoMirror() {
            if (transform == null)
                return;
            Vector3 scale = transform.localScale;
            if (isMirror) {
                if (scale.x == 1) {
                    transform.localScale = new Vector3(-1, scale.y, scale.z);
                }
            } else {
                if (scale.x == -1) {
                    transform.localScale = new Vector3(1, scale.y, scale.z);
                }
            }
        }

        private string GetAtlasName() {
            if (nodeSubAtlasName != null && nodeSubAtlasName.Trim().Length > 0) {
                return nodeSubAtlasName;
            } else {
                return operVo.subAtlasName;
            }
        }

        public string GetResPath() {
            if (isPublic) {
                if (nodeSubAtlasName != null && nodeSubAtlasName.Trim().Length > 0) {
                    path = "Assets/Things/Textures/UI/" + nodeSubAtlasName + "/" + GetName() + ".png";
                } else {
                    path = ExportContext.GetInstance().GetConfigVo().basePath + "/" + GetName() + ".png";
                }
            } else {
                if (nodeSubAtlasName != null && nodeSubAtlasName.Trim().Length > 0) {
                    path = "Assets/Things/Textures/UI/" + nodeSubAtlasName + "/" + GetName() + ".png";
                } else {
                    path = "Assets/Things/Textures/UI/" + operVo.subAtlasName + "/" + GetName() + ".png";
                }
            }
            return path;
        }
    }
}
