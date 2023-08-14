using System;
using System.Collections;

namespace EditorTools.AssetBundle {
    public class CollectionSortHelper {
        /// <summary>
        /// 使用默认的按字母对集合进行排序
        /// </summary>
        /// <param name="collection"></param>
        /// <returns></returns>
        public static string[] GetSortedArray(ICollection collection) {
            string[] result = new string[collection.Count];
            collection.CopyTo(result, 0);
            Array.Sort<string>(result);
            return result;
        }
    }
}
