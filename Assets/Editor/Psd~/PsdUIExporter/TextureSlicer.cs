using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace PsdUIExporter {

    public class TextureSlicer {

        public static Texture2D Slice(Texture2D srcTexture, PSlice rect) {
            int srcWidth = srcTexture.width;
            int srcHeight = srcTexture.height;
            int top = rect.top;
            int right = rect.right;
            int bottom = rect.bottom;
            int left = rect.left;

            if (!CheckBound(left, right, top, bottom)) {
                return null;
            }

            int destWidth = GetTarWidth(srcWidth, left, right);
            int destHeight = GetTarHeight(srcHeight, top, bottom);

            Texture2D destTexture = new Texture2D(destWidth, destHeight);
            if (HorizontalSlice(left, right) && (VerticalSlice(top, bottom))) {
                SetPixels(destTexture, 0, 0, srcTexture, 0, 0, left, bottom);//下左
                SetPixels(destTexture, left, 0, srcTexture, left, 0, 1, bottom);//下中
                SetPixels(destTexture, left + 1, 0, srcTexture, srcWidth - right, 0, right, bottom);//下右

                SetPixels(destTexture, 0, bottom, srcTexture, 0, bottom, left, 1);//中左
                SetPixels(destTexture, left, bottom, srcTexture, left, bottom, 1, 1);//中中
                SetPixels(destTexture, left + 1, bottom, srcTexture, srcWidth - right, bottom, right, 1);//中右

                SetPixels(destTexture, 0, bottom + 1, srcTexture, 0, srcHeight - top, left, top);//上左
                SetPixels(destTexture, left, bottom + 1, srcTexture, left, srcHeight - top, 1, top);//上中
                SetPixels(destTexture, left + 1, bottom + 1, srcTexture, srcWidth - right, srcHeight - top, right, top);//上右
            } else if (HorizontalSlice(left, right)) {
                SetPixels(destTexture, 0, 0, srcTexture, 0, 0, left + 1, destHeight);//左 和 中
                SetPixels(destTexture, left + 1, 0, srcTexture, srcWidth - right, 0, right, destHeight);//右
            } else if (VerticalSlice(top, bottom)) {
                SetPixels(destTexture, 0, 0, srcTexture, 0, 0, destWidth, bottom + 1);//下 和 中
                SetPixels(destTexture, 0, bottom + 1, srcTexture, 0, srcHeight - top, destWidth, top);//上
            }
            destTexture.Apply();
            return destTexture;
        }


        private static bool CheckBound(int left, int right, int top, int bottom) {
            if (left * right == 0) {
                if ((left != 0) || (right != 0)) {
                    // throw new Exception("目前不支持 left right 只有一个为0");
                    EditorUtility.DisplayDialog("提示", "目前不支持 left right 只有一个为0[left:" + left + " right:" + right + " top:" + top + " bottom:" + bottom + "]", "确定");
                    return false;
                }
            }

            if (top * bottom == 0) {
                if ((top != 0) || (bottom != 0)) {
                    // throw new Exception("目前不支持 top bottom 只有一个为0");
                    EditorUtility.DisplayDialog("提示", "目前不支持 top bottom 只有一个为0[left:" + left + " right:" + right + " top:" + top + " bottom:" + bottom + "]", "确定");
                    return false;
                }
            }
            return true;
        }


        private static int GetTarHeight(int srcHeight, int top, int bottom) {
            if (VerticalSlice(top, bottom)) {
                return 1 + top + bottom;
            }
            return srcHeight;
        }

        private static int GetTarWidth(int srcWidth, int left, int right) {
            if (HorizontalSlice(left, right)) {
                return 1 + left + right;
            }
            return srcWidth;
        }

        private static bool HorizontalSlice(int left, int right) {
            return left != 0 && right != 0;
        }

        private static bool VerticalSlice(int top, int bottom) {
            return top != 0 && bottom != 0;
        }

        private static void SetPixels(Texture2D destTexture, int destPositionX, int destPositionY, Texture2D srcTexture, int srcPositionX, int srcPositionY, int width, int height) {
            destTexture.SetPixels(destPositionX, destPositionY, width, height, srcTexture.GetPixels(srcPositionX, srcPositionY, width, height));
        }

//------------------------------------------------------------------
        public static void Slice(INode node, PSlice pslice) {
            if (node == null || !(node is ImageNode)) {
                return;
            } else {
                Slice((ImageNode)node, pslice);
            }
        }

        public static void Slice(ImageNode node, PSlice pslice) {
            Texture2D texture = node.GetTexture();
            PSlice rect;
            if (pslice.top == 0 && pslice.bottom == 0 && pslice.left == 0 && pslice.right == 0) {
                rect = AutoSlice(texture);
                pslice.top = rect.top;
                pslice.right = rect.right;
                pslice.bottom = rect.bottom;
                pslice.left = rect.left;
            } else {
                rect = new PSlice(pslice.top, pslice.right, pslice.bottom, pslice.left);
            }
            Texture2D sliceTexture = texture;
            if ((rect.top + rect.right + rect.bottom + rect.left) > 1) {
                sliceTexture = Slice(texture, rect);
                node.SetSliceTexture(sliceTexture);
            } else {
                EditorUtility.DisplayDialog("提示", "该图不可切", "确定");
            }
        }

        public static PSlice AutoSlice(Texture2D texture) {
            int width = texture.width;
            int height = texture.height;

            int top = 0;
            int bottom = 0;
            int left = 0;
            int right = 0;
            int mid = 0;

            if (width > 12) {
                mid = width / 2;
                Color[] midColor = new Color[height];
                Color[] tmpColor = new Color[height];
                for (int i = 0; i < height; i++) {
                    midColor[i] = texture.GetPixel(mid, i);
                }

                int w = mid - 1;
                for (; w > 4; w--) {
                    for (int h = 0; h < height; h++) {
                        tmpColor[h] = texture.GetPixel(w, h);
                    }
                    if (!CompareArray(midColor, tmpColor)) {
                        break;
                    } 
                }
                if (w != (mid -1))
                    left = w + 2;

                w = mid + 1;
                for (; w < (width - 4); w++) {
                    for (int h = 0; h < height; h++) {
                        tmpColor[h] = texture.GetPixel(w, h);
                    }
                    if (!CompareArray(midColor, tmpColor)) {
                        break;
                    } 
                }
                if (w != (mid -1))
                    right = w - 1;
            }

            if (height > 12) {
                top = 0;
            	bottom = 0;
                mid = height / 2;
                Color[] midColor = new Color[width];
                Color[] tmpColor = new Color[width];
                for (int i = 0; i < width; i++) {
                    midColor[i] = texture.GetPixel(i, mid);
                }

                int hh = mid - 1;
                for (; hh > 4; hh--) {
                    for (int ww = 0; ww < width; ww++) {
                        tmpColor[ww] = texture.GetPixel(ww, hh);
                    }
                    if (!CompareArray(midColor, tmpColor)) {
                        break;
                    }
                }
                if (hh != (mid - 1))
                    bottom = hh + 2;

                hh = mid + 1;
                for (; hh < (height - 4); hh++) {
                    for (int ww = 0; ww < width; ww++) {
                        tmpColor[ww] = texture.GetPixel(ww, hh);
                    }
                    if (!CompareArray(midColor, tmpColor)) {
                        break;
                    }
                }
                if (hh != (mid - 1))
                    top = hh - 1;
            }

            if (bottom <= 5 || (bottom + 5) > (height / 2)) {
                Debug.LogError("差值太小，归零[bottom:" + bottom + " mid:" + (height/ 2) + "]");
                bottom = 0;
            }
            if (left <= 5 || (left + 5) > (width / 2)) {
                Debug.LogError("差值太小，归零[left:" + left + " mid:" + (width/ 2) + "]");
                left = 0;
            }
            if (right > (width - 5) || (right - 5) < (width / 2)) {
                Debug.LogError("差值太小，归零[right:" + right + " mid:" + (width/ 2) + "]");
                right = 0;
            } else {
                right = width - right;
            }
            if (top > (height - 5) || (top - 5) < (height / 2)) {
                Debug.LogError("差值太小，归零[top:" + top + " mid:" + (height / 2) + "]");
                top = 0;
            } else {
                top = height - top;
            }
            if (left * right == 0) {
                left = 0;
                right = 0;
            }
            if (top * bottom == 0) {
                top = 0;
                bottom = 0;
            }
            return new PSlice(top, right, bottom, left);
        }

        private static bool CompareArray(Color [] arr1, Color [] arr2) {
            int length1 = arr1.Length;
            int length2 = arr2.Length;
            if (length1 != length2)
                return false;
            for (var i = 0; i < length1; i++) {
                if (!arr1[i].Equals(arr2[i])) {
                    return false;
                }
            }
            return true;
        }
    }
}
