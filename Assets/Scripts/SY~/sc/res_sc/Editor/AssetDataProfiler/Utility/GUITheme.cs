using UnityEditor;
using UnityEngine;

namespace Tools
{
	public static class GUITheme
	{
		static GUITheme()
		{
			AcceptColor = Color.green;

			ActionButtonStyle = new GUIStyle(GUI.skin.button)
			{
				fixedHeight = 20,
				margin = new RectOffset(50, 50, 10, 0),
			};

			IconButtonStyle = new GUIStyle(GUI.skin.button)
			{
				stretchWidth = false,
				fixedHeight = 20,
				margin = new RectOffset(5, 5, 0, 0),
				fontSize = 10,
				alignment = TextAnchor.MiddleCenter,
			};
			IconButtonStyle.normal.background = null;

			TextureNameStyle = new GUIStyle(EditorStyles.textField)
			{
				stretchHeight = false,
				fontSize = 20,
				fixedHeight = 25,
			};
		}

		public static GUIStyle ActionButtonStyle { get; private set; }

		public static GUIStyle IconButtonStyle { get; private set; }

		public static GUIStyle TextureNameStyle { get; private set; }

		public static Color AcceptColor { get; private set; }
	}
}
