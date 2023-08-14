using UnityEngine;

[ExecuteInEditMode]
[AddComponentMenu ("ImageEffect/ScreenBlur")]
public class ScreenBlurEffect : MonoBehaviour {
	#region Variables
	public Shader RadialBlurShader = null;
	private Material RadialBlurMaterial = null;
    // private RenderTextureFormat rtFormat = RenderTextureFormat.Default;

    /// Blur iterations - larger number means more blur.
    [Range(0, 10)]
    public int iterations = 3;

    /// Blur spread for each iteration. Lower values
    /// give better looking blur, but require more iterations to
    /// get large blurs. Value is usually between 0.5 and 1.0.
    [Range(0.0f, 1.0f)]
    public float blurSpread = 0.6f;

    public string shadername = "Xcqy/BlurEffectConeTap";
	#endregion


	void Start () {
		FindShaders ();
		CheckSupport ();
		CreateMaterials ();
	}

	void FindShaders () {
		if (!RadialBlurShader) {
			RadialBlurShader = Shader.Find(shadername) as Shader; 
		}
	}

	void CreateMaterials() {
		if(!RadialBlurMaterial){
			RadialBlurMaterial = new Material(RadialBlurShader);
			RadialBlurMaterial.hideFlags = HideFlags.HideAndDontSave;	
		}
	}

	bool Supported() {
        //return (SystemInfo.supportsImageEffects && RadialBlurShader.isSupported);
        // return true;
        return RadialBlurShader.isSupported;
    }


	bool CheckSupport() {
		if(!Supported()) {
			enabled = false;
			return false;
		}
		// rtFormat = SystemInfo.SupportsRenderTextureFormat (RenderTextureFormat.RGB565) ? RenderTextureFormat.RGB565 : RenderTextureFormat.Default;
		return true;
	}

    // Performs one blur iteration.
    public void FourTapCone(RenderTexture source, RenderTexture dest, int iteration)
    {
        float off = 0.5f + iteration * blurSpread;
        Graphics.BlitMultiTap(source, dest, RadialBlurMaterial,
                               new Vector2(-off, -off),
                               new Vector2(-off, off),
                               new Vector2(off, off),
                               new Vector2(off, -off)
            );
    }

    // Downsamples the texture to a quarter resolution.
    private void DownSample4x(RenderTexture source, RenderTexture dest)
    {
        float off = 1.0f;
        Graphics.BlitMultiTap(source, dest, RadialBlurMaterial,
                               new Vector2(-off, -off),
                               new Vector2(-off, off),
                               new Vector2(off, off),
                               new Vector2(off, -off)
            );
    }
    void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture)
	{	
		#if UNITY_EDITOR
		FindShaders ();
		CheckSupport ();
		CreateMaterials ();	
		#endif

		if(RadialBlurMaterial)
        {

			int rtW = sourceTexture.width/8;
			int rtH = sourceTexture.height/8;


            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.Default);

            // Copy source to the 4x4 smaller texture.
            DownSample4x(sourceTexture, buffer);

            // Blur the small texture
            for (int i = 0; i < iterations; i++)
            {
                RenderTexture buffer2 = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.Default);
                FourTapCone(buffer, buffer2, i);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer2;
            }
            Graphics.Blit(buffer, destTexture, RadialBlurMaterial);
            RenderTexture.ReleaseTemporary(buffer);

        }

		else{
			Graphics.Blit(sourceTexture, destTexture);

		}


	}

	public void OnDisable () {
		#if UNITY_EDITOR
		if (RadialBlurMaterial)
			DestroyImmediate (RadialBlurMaterial);
		#endif
		// RadialBlurMaterial = null;
	}
}
