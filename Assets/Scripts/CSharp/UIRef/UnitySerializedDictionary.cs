using System;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class UnitySerializedDictionary<K, V> : Dictionary<K, V>, ISerializationCallbackReceiver
{
    [SerializeField, HideInInspector]
    private List<K> m_Keys = new List<K>();
    [SerializeField, HideInInspector]
    private List<V> m_Values = new List<V>();

    public void OnBeforeSerialize()
    {
        m_Keys.Clear();
        m_Values.Clear();
        foreach (var data in this)
        {
            m_Keys.Add(data.Key);
            m_Values.Add(data.Value);
        }
    }

    public void OnAfterDeserialize()
    {
        Clear();
        for (int i = 0; i < m_Keys.Count && i < m_Values.Count; i++)
        {
            this[m_Keys[i]] = m_Values[i];
        }
    }
}
