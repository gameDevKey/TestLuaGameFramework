#region License
//Ntreev Photoshop Document Parser for .Net
//
//Released under the MIT License.
//
//Copyright (c) 2015 Ntreev Soft co., Ltd.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
//documentation files (the "Software"), to deal in the Software without restriction, including without limitation the 
//rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
//persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the 
//Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
//WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
//OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Ntreev.Library.Psd.Structures;
using UnityEngine;

namespace Ntreev.Library.Psd
{
    public class LayerRecords
    {
        private Channel[] channels;
        private TextInfo textinfo;
        public TextEffectInfo textEffectInfo;
        private LayerMask layerMask;
        private LayerBlendingRanges blendingRanges;
        private IProperties resources;
        private string name;
        private SectionType sectionType;
        private Guid placedID;
        private LayerType layerType;
        public int deepth;
        private int version;

        public void SetExtraRecords(LayerMask layerMask, LayerBlendingRanges blendingRanges, IProperties resources, string name)
        {
            this.layerMask = layerMask;
            this.blendingRanges = blendingRanges;
            this.resources = resources;
            this.name = name;

            this.resources.TryGetValue<string>(ref this.name, "luni.Name");
            this.resources.TryGetValue<int>(ref this.version, "lyvr.Version");
            if (this.resources.Contains("lsct.SectionType") == true)
                this.sectionType = (SectionType)this.resources.ToInt32("lsct.SectionType");
            if (this.resources.Contains("lsdk.SectionType") == true)
                this.sectionType = (SectionType)this.resources.ToInt32("lsdk.SectionType");
            if (this.resources.Contains("SoLd.Idnt") == true)
                this.placedID = this.resources.ToGuid("SoLd.Idnt");
            else if (this.resources.Contains("SoLE.Idnt") == true)
                this.placedID = this.resources.ToGuid("SoLE.Idnt");

            JudgeType();

            foreach (var item in this.channels)
            {
                switch (item.Type)
                {
                    case ChannelType.Mask:
                        {
                            if (this.layerMask != null)
                            {
                                item.Width = this.layerMask.Width;
                                item.Height = this.layerMask.Height;
                            }
                        }
                        break;
                    case ChannelType.Alpha:
                        {
                            if (this.resources.Contains("iOpa") == true)
                            {
                                byte opa = this.resources.ToByte("iOpa", "Opacity");
                                item.Opacity = opa / 255.0f;
                            }
                        }
                        break;
                }
            }
        }

        private void JudgeType()
        {
            if (SectionType == SectionType.Closed || SectionType == SectionType.Opend )
            {
                layerType = LayerType.Group;
            }
            else if (this.resources.Contains("SoLd.Idnt"))
            {
                layerType = LayerType.Normal;
            }
            else if (this.resources.Contains("SoCo") == true)
            {
                layerType = LayerType.Color;
            }
            else if (this.resources.Contains("TySh.Idnt"))
            {
                //字体效果图层
                if (this.resources.Contains("lfx2") == true)
                {
                    Readers.LayerResources.Reader_lfx2 lfx2 = null;
                    Ntreev.Library.Psd.DescriptorStructure FrFX = null;
                    Ntreev.Library.Psd.DescriptorStructure GrFl = null;
                    Ntreev.Library.Psd.DescriptorStructure DrSh = null;

                    if (resources.Contains("lfx2"))
                    {
                        lfx2 = resources["lfx2"] as Readers.LayerResources.Reader_lfx2;
                    }

                    if (lfx2 != null && lfx2.Contains("FrFX")) 
                    {
                        FrFX = lfx2["FrFX"] as Ntreev.Library.Psd.DescriptorStructure;
                    }

                    if (lfx2 != null && lfx2.Contains("GrFl")) 
                    {
                        GrFl = lfx2["GrFl"] as Ntreev.Library.Psd.DescriptorStructure;
                    }

                    if (lfx2 != null && lfx2.Contains("DrSh")) 
                    {
                        DrSh = lfx2["DrSh"] as Ntreev.Library.Psd.DescriptorStructure;
                    }

                    //描边
                    if (FrFX != null)
                    {
                        object outLineEnable=1,width=1,color_r=1,color_g=1,color_b=1;
                        object[] color=new object[3];
                        Ntreev.Library.Psd.Structures.StructureUnitFloat Sz = FrFX["Sz"] as Ntreev.Library.Psd.Structures.StructureUnitFloat;
                        Ntreev.Library.Psd.DescriptorStructure Clr = FrFX["Clr"] as Ntreev.Library.Psd.DescriptorStructure;
                        FrFX.TryGetValue<object>(ref outLineEnable, "enab");
                        Sz.TryGetValue<object>(ref width, "Value");
                        Clr.TryGetValue<object>(ref color_r, "Rd");
                        Clr.TryGetValue<object>(ref color_g, "Grn");
                        Clr.TryGetValue<object>(ref color_b, "Bl");
                        this.textEffectInfo = new TextEffectInfo();
                        if (Convert.ToBoolean(outLineEnable))
                        {
                            this.textEffectInfo.SetOutLineArgs((float)Convert.ToSingle(width), (float)Convert.ToSingle(color_r), (float)Convert.ToSingle(color_g), (float)Convert.ToSingle(color_b));
                        }
                    }
                    //渐变叠加
                    if (GrFl != null)
                    {
                        object shadeEnable = 1;
                        GrFl.TryGetValue<object>(ref shadeEnable, "enab");
                        if (Convert.ToBoolean(shadeEnable))
                        {
                            Ntreev.Library.Psd.DescriptorStructure Grad = GrFl["Grad"] as Ntreev.Library.Psd.DescriptorStructure;
                            Ntreev.Library.Psd.Structures.StructureList Clrs = Grad["Clrs"] as Ntreev.Library.Psd.Structures.StructureList;
                            System.Object[] objList = Clrs["Items"] as System.Object[];
                            if (objList.Length == 2)
                            {
                                ArrayList arrayList = new ArrayList();
                                for(int j = 1; j <= objList.Length; j++)
                                {
                                    Ntreev.Library.Psd.DescriptorStructure det = objList[j-1] as Ntreev.Library.Psd.DescriptorStructure;
                                    Ntreev.Library.Psd.DescriptorStructure shadeClr = det["Clr"] as Ntreev.Library.Psd.DescriptorStructure;
                                    object colorR = 1, colorG = 1, colorB = 1;
                                    shadeClr.TryGetValue<object>(ref colorR, "Rd");
                                    shadeClr.TryGetValue<object>(ref colorG, "Grn");
                                    shadeClr.TryGetValue<object>(ref colorB, "Bl");
                                    object[] colors = { colorR, colorG, colorB };
                                    arrayList.Add(colors);
                                }
                                if (this.textEffectInfo == null)
                                {
                                    this.textEffectInfo = new TextEffectInfo();
                                }
                                this.textEffectInfo.shadeColors = arrayList;
                            }
                        }
                    }
                    //投影
                    if(DrSh!=null){
                        object projectionEnable=1;
                        DrSh.TryGetValue<object>(ref projectionEnable, "enab");
                        if(Convert.ToBoolean(projectionEnable)){
                            object angle=1,distance=1,color_r=1,color_g=1,color_b=1,color_a=1;
                            int angleNum=0,distanceNum=0;
                            Ntreev.Library.Psd.Structures.StructureUnitFloat lagl=DrSh["lagl"] as Ntreev.Library.Psd.Structures.StructureUnitFloat;
                            Ntreev.Library.Psd.Structures.StructureUnitFloat Dstn=DrSh["Dstn"] as Ntreev.Library.Psd.Structures.StructureUnitFloat;
                            lagl.TryGetValue<object>(ref angle, "Value");
                            angleNum=Convert.ToInt32(angle);
                            Dstn.TryGetValue<object>(ref distance, "Value");
                            distanceNum=Convert.ToInt32(distance);
                            //投影方向与距离
                            Vector2 dir;
                            if(angleNum>-90&&angleNum<90){
                                float tan=Mathf.Tan((180-angleNum)*Mathf.Deg2Rad);
                                dir=new Vector2(-1,tan);
                            }else{
                                float tan=Mathf.Tan(angleNum*Mathf.Deg2Rad);
                                dir=new Vector2(1,tan);
                            }
                            dir=dir.normalized*distanceNum;
                            //投影颜色与透明度
                            Ntreev.Library.Psd.DescriptorStructure Clr = DrSh["Clr"] as Ntreev.Library.Psd.DescriptorStructure;
                            Ntreev.Library.Psd.Structures.StructureUnitFloat Opct = DrSh["Opct"] as Ntreev.Library.Psd.Structures.StructureUnitFloat;
                            Clr.TryGetValue<object>(ref color_r, "Rd");
                            Clr.TryGetValue<object>(ref color_g, "Grn");
                            Clr.TryGetValue<object>(ref color_b, "Bl");
                            Opct.TryGetValue<object>(ref color_a, "Value");

                            if(this.textEffectInfo==null){
                                this.textEffectInfo=new TextEffectInfo();
                            }
                            this.textEffectInfo.SetShadowArgs(dir,Convert.ToSingle(color_r),Convert.ToSingle(color_g),Convert.ToSingle(color_b),Convert.ToSingle(color_a)/100);
                        }
                    }
                }
                layerType = LayerType.Text;
                Readers.LayerResources.Reader_TySh reader = resources["TySh"] as Readers.LayerResources.Reader_TySh;
                DescriptorStructure text = null;
                double[] trnfs = null;
                double factor = 1;
                if (reader.Contains("Transforms")) {
                    trnfs = (double [])reader["Transforms"];
                    if (trnfs.Length >= 4) {
                        factor = trnfs[3];
                        if (factor < 0.01) {
                            factor = 1;
                        }
                    }
                }
                if (reader.TryGetValue<DescriptorStructure>(ref text, "Text"))
                {
                    textinfo = new TextInfo(text, factor);
                }
            }
            else if(deepth > 6)
            {
                layerType = LayerType.Overflow;
            }
            else
            {
                layerType = LayerType.Complex;
            }
        }

        public void ValidateSize()
        {
            int width = this.Right - Left;
            int height = this.Bottom - this.Top;

            if ((width > 0x3000) || (height > 0x3000))
            {
                throw new NotSupportedException(string.Format("Invalidated size ({0}, {1})", width, height));
            }
        }

        public int Left { get; set; }

        public int Top { get; set; }

        public int Right { get; set; }

        public int Bottom { get; set; }

        public int Width
        {
            get { return this.Right - this.Left; }
        }

        public int Height
        {
            get { return this.Bottom - this.Top; }
        }

        public int ChannelCount
        {
            get
            {
                if (this.channels == null)
                    return 0;
                return this.channels.Length;
            }
            set
            {
                if (value > 0x38)
                {
                    throw new Exception(string.Format("Too many channels : {0}", value));
                }

                this.channels = new Channel[value];
                for (int i = 0; i < value; i++)
                {
                    this.channels[i] = new Channel();
                }
            }
        }

        public Channel[] Channels
        {
            get { return this.channels; }
        }

        public BlendMode BlendMode { get; set; }

        public byte Opacity { get; set; }

        public bool Clipping { get; set; }

        public LayerFlags Flags { get; set; }

        public int Filter { get; set; }
        public int Version
        {
            get { return this.version; }
        }
        public long ChannelSize
        {
            get { return this.channels.Select(item => item.Size).Aggregate((v, n) => v + n); }
        }

        public SectionType SectionType
        {
            get { return this.sectionType; }
            set { this.sectionType = value; }
        }

        public Guid PlacedID
        {
            get { return this.placedID; }
        }

        public string Name
        {
            get { return this.name; }
        }
        public LayerType LayerType
        {
            get { return layerType; }
        }
        public LayerMask Mask
        {
            get { return this.layerMask; }
        }

        public object BlendingRanges
        {
            get { return this.blendingRanges; }
        }

        public TextInfo TextInfo
        {
            get
            {
                return this.textinfo;
            }
        }

        public IProperties Resources
        {
            get { return this.resources; }
        }
    }
}
