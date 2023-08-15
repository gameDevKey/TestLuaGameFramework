﻿using UnityEngine;

namespace EditorTools.UI {
    public class AtlasOptimizer {
        /// <summary>
        /// 优化图集
        /// 1.可强制设置正方形Atlas
        /// 2.若出现超过一半面积为空的情况，可以删除空的部分
        /// </summary>
        public static Texture2D Optimize(Texture2D atlas, Rect[] rects, bool forceSquare = false) {
            Texture2D result = atlas;
            Rect rect = GetAtlasContentRect(rects);
            if (rect.width <= 0.5f) {
                result = CreateResizedAtlas(atlas, 0.5f, 1.0f, rects);
            }
            if (rect.height <= 0.5f) {
                result = CreateResizedAtlas(atlas, 1.0f, 0.5f, rects);
            }
            Texture2D squareResult = result;
            if (forceSquare == true) {
                if (result.width > result.height) {
                    squareResult = CreateResizedAtlas(result, 1.0f, 2.0f, rects);
                } else if (result.width < result.height) {
                    squareResult = CreateResizedAtlas(result, 2.0f, 1.0f, rects);
                }
            }
            return squareResult;
        }

        private static Texture2D CreateResizedAtlas(Texture2D atlas, float xScale, float yScale, Rect[] rects) {
            int width = (int)(atlas.width * xScale);
            int height = (int)(atlas.height * yScale);
            Texture2D result = new Texture2D(width, height);
            result.name = atlas.name;
            int pixelWidth = width > atlas.width ? atlas.width : width;
            int pixelHeight = height > atlas.height ? atlas.height : height;
            result.SetPixels(0, 0, pixelWidth, pixelHeight, atlas.GetPixels(0, 0, pixelWidth, pixelHeight));
            result.Apply();
            for (int i = 0; i < rects.Length; i++) {
                Rect rect = rects[i];
                rects[i] = new Rect(rect.xMin / xScale, rect.yMin / yScale, rect.width / xScale, rect.height / yScale);
            }
            return result;
        }

        private static Rect GetAtlasContentRect(Rect[] rects) {
            Rect result = new Rect(0, 0, 0, 0);
            foreach (Rect rect in rects) {
                if (rect.xMin < result.xMin) {
                    result.xMin = rect.xMin;
                }
                if (rect.yMin < result.yMin) {
                    result.yMin = rect.yMin;
                }
                if (rect.xMax > result.xMax) {
                    result.xMax = rect.xMax;
                }
                if (rect.yMax > result.yMax) {
                    result.yMax = rect.yMax;
                }
            }
            return result;
        }
    }
}