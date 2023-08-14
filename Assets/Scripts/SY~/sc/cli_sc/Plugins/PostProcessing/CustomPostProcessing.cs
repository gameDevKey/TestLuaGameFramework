using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;

public class CustomPostProcessing : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        public List<BaseCustomPostProcessing> customPostProcessings;


        public ProfilingSampler sampler = new ProfilingSampler("CustomPostProcessing");


        public RenderTargetIdentifier originTarget;


        public RenderTargetHandle fisrtTex;
       public RenderTargetHandle sceTex;

        public RenderTargetHandle[] Handles;

        public Vector2Int  texSize;

        public string shaderName = "Name";
        public Material material;


        public void SetUp(ScriptableRenderer renderer ,params BaseCustomPostProcessing[] processings)
        {
            originTarget = renderer.cameraColorTarget;

            CommandBufferPool.Get("CustomPostprocessing");
            RenderTextureDescriptor desc = new RenderTextureDescriptor(texSize.x,texSize.y,RenderTextureFormat.ARGB32,16);
            desc.useMipMap = false;

            material = CoreUtils.CreateEngineMaterial(Shader.Find(shaderName));
            for (int i = 0; i < customPostProcessings.Count; i++)
            {
                customPostProcessings[i].SetUp(material);
            }
            



        }


        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {

            fisrtTex.Init("_PostProcessingHandler");
            sceTex.Init("_PostProcessingHandler");
            

            cmd.GetTemporaryRT(fisrtTex.id,cameraTextureDescriptor);
            cmd.GetTemporaryRT(sceTex.id,cameraTextureDescriptor);
            Handles = new RenderTargetHandle[2]
            {
                fisrtTex,sceTex
            };



        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {

            if (renderingData.cameraData.camera.cameraType == CameraType.Preview) return;
            var cmd = CommandBufferPool.Get("customPorcessingCommandBuffer");

            for(int i = 0; i< customPostProcessings.Count; i++)
            {
                var source = Handles[i % 2];
                var dest = Handles[(i + 1) % 2];
                customPostProcessings[i].Excute(cmd, source.Identifier(), dest.Identifier(), context, ref renderingData);
            }

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
           

        }

        /// Cleanup any allocated resources that were created during the execution of this render pass.
        public override void FrameCleanup(CommandBuffer cmd)
        {

            cmd.ReleaseTemporaryRT(fisrtTex.id);
            cmd.ReleaseTemporaryRT(sceTex.id);

        }
    }


     public abstract class  BaseCustomPostProcessing {

        protected Material mat;

        public void SetUp(Material mat)
        {
            this.mat = mat;
        }
        

        public abstract void Config(RenderTextureDescriptor renderTextureDescriptor);

        public abstract void Excute(CommandBuffer cmd, RenderTargetIdentifier source,RenderTargetIdentifier dest, ScriptableRenderContext context, ref RenderingData renderingData);

        public abstract void FrameCleanup(CommandBuffer command);

    }





    public class BloomEffect : BaseCustomPostProcessing
    {

        public override void Config(RenderTextureDescriptor renderTextureDescriptor)
        {
                
        }

        public override void Excute(CommandBuffer cmd,RenderTargetIdentifier source ,RenderTargetIdentifier dest,ScriptableRenderContext context, ref RenderingData renderingData)
        {
            cmd.Blit(source, dest, mat, 0);
        }

        public override void FrameCleanup(CommandBuffer command)
        {

        }
    }



    CustomRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }


    public void SetUp()
    {

    }


    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);

        //TODO 通过Volume介入到后处理 
        //扩展到自定义后处理 ， 可选择的后处理顺序， 非特殊性后处理统一使用用一个commandbuffer进行绘制操作。
        //Volume  根据区域生效功能判断是否要实现？
    }


    

}


