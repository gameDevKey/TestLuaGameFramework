using System.Collections.Generic;

namespace Tools
{
    internal class AssetProfilerTabModel : AssetProfilerTab<UIModelData>
	{
        public AssetProfilerTabModel(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
		{
		}

        protected override string tabName()
        {
            return "模型";
        }
    }
}
