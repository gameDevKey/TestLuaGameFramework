
using System.Collections;
using UnityEngine;
namespace Ntreev.Library.Psd
{
    public class TextEffectInfo
    {
        public float outLineWidth = 0;//字体描边宽度
        public float[] outLineColor={1,1,1,1};//描边颜色
        public ArrayList shadeColors; //渐变叠加颜色
        public Vector2 shadowDir;//投影方向
        public float[] shadowColor={1,1,1,1};//投影颜色
        public TextEffectInfo(){
            
        }
        public void SetOutLineArgs(float outLineWidth,float color_r,float color_g,float color_b){
            this.outLineWidth = outLineWidth;
            this.outLineColor=new float[3]{color_r,color_g,color_b};
        }
        public void SetShadowArgs(Vector2 dir,float color_r,float color_g,float color_b,float color_a){
            this.shadowDir=dir;
            this.shadowColor=new float[4]{color_r,color_g,color_b,color_a};
        }
    }
}
