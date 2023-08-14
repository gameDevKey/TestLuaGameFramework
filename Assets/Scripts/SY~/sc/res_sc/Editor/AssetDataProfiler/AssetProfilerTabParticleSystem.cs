using System.Collections.Generic;

namespace Tools
{
    internal class AssetProfilerTabParticleSystem : AssetProfilerTab<UIParticleSystemData>
	{
        public AssetProfilerTabParticleSystem(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
		{
		}

        protected override string tabName()
        {
            return "特效";
        }
    }
}
