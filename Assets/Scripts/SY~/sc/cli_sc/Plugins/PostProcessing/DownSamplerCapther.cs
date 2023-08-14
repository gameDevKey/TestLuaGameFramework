using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class DownSamplerCapther : ScriptableRendererFeature
{
    class DownSamplerPass : ScriptableRenderPass
    {

        RenderTargetIdentifier originTarget;
        RenderTargetHandle dest;
        Res res;

        string name = "downSamplerColor";
        public void SetUp(ScriptableRenderer renderer,Res res)
        {
            originTarget = renderer.cameraColorTarget;
            this.res = res;
            dest.Init("_DownSamplerTex");
        }


        

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var desc = cameraTextureDescriptor;
            desc.msaaSamples = 1;
            desc.depthBufferBits = 0;
            if (res == Res.HALF)
            {
                desc.width /= 2;
                desc.height /= 2;
            }else if(res == Res.QUAD)
            {
                desc.height /= 4;
                desc.width /= 4;
            }

            cmd.GetTemporaryRT(dest.id, desc);

        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {


            // if(renderingData.cameraData.camera.cameraType == CameraType.Preview|| renderingData.cameraData.camera.cameraType == CameraType.SceneView)return;
            var cmd = CommandBufferPool.Get("DownSampler");

            using (new ProfilingScope(cmd, new ProfilingSampler("DownSamplerTex")))
            {

                var opaqueColorRT = dest.Identifier();
                Blit(cmd, originTarget, opaqueColorRT);


            }
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);


        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (dest != RenderTargetHandle.CameraTarget)
            {
                cmd.ReleaseTemporaryRT(dest.id);
            }

        }

    }

    DownSamplerPass m_ScriptablePass;



    public RenderPassEvent passEvent = RenderPassEvent.AfterRenderingSkybox;

    public Res res = Res.HALF;
    public enum Res {
    
        FULL,HALF,QUAD
    }


    public override void Create()
    {
        m_ScriptablePass = new DownSamplerPass();
        m_ScriptablePass.renderPassEvent = passEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.SetUp(renderer,res);
        renderer.EnqueuePass(m_ScriptablePass);


    }
}


