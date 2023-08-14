using UnityEditor;
using UnityEngine;

namespace Tools
{
	public static class GUILayoutEx
	{
		/// <summary>
		/// Draw an action button.
		/// </summary>
		public static bool ActionButton(string label)
		{
			var originalColor = GUI.backgroundColor;
			GUI.backgroundColor = GUITheme.AcceptColor;

			bool result = false;
			if (GUILayout.Button(label, GUITheme.ActionButtonStyle))
			{
				result = true;
			}

			GUI.backgroundColor = originalColor;
			return result;
		}

		public static void DrawOutline(Rect rect, float size)
		{
			Color orgColor = GUI.color;
			GUI.color = Color.black;
			GUI.DrawTexture(new Rect(rect.x, rect.y, rect.width, size), EditorGUIUtility.whiteTexture);
			GUI.DrawTexture(new Rect(rect.x, rect.yMax - size, rect.width, size), EditorGUIUtility.whiteTexture);
			GUI.DrawTexture(new Rect(rect.x, rect.y + 1, size, rect.height - 2 * size), EditorGUIUtility.whiteTexture);
			GUI.DrawTexture(new Rect(rect.xMax - size, rect.y + 1, size, rect.height - 2 * size), EditorGUIUtility.whiteTexture);

			GUI.color = orgColor;
		}

	}
}
