
namespace Tools
{
    using UnityEngine;
    using System.Collections;

    public class SetSortIdAttribute : PropertyAttribute
    {
        public int SortId { get; private set; }
        //public bool IsDirty { get; set; }

        public SetSortIdAttribute(int id)
        {
			this.SortId = id;
        }
    }
}
