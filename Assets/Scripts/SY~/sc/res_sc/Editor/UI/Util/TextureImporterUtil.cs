﻿using System;

        public static TextureImporterPlatformSettings CreateImporterSetting(string name, int maxSize, TextureImporterFormat format
            , int compressionQuality = 100, bool allowsAlphaSplitting = false, TextureImporterCompression tc = TextureImporterCompression.Uncompressed)
        {
            TextureImporterPlatformSettings tips = new TextureImporterPlatformSettings();
            tips.overridden = true;
            tips.name = name;
            tips.maxTextureSize = maxSize;
            tips.format = format;
            tips.textureCompression = tc;
            tips.allowsAlphaSplitting = allowsAlphaSplitting;
            tips.compressionQuality = compressionQuality;

            return tips;
        }
            //			importer.textureType = TextureImporterType.Default;
            //			importer.npotScale = TextureImporterNPOTScale.None;
            if (importer.isReadable && importer.mipmapEnabled)
            {
                return false;
            }
            importer.isReadable = true;
            return true;