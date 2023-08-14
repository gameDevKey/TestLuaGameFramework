using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

namespace EditorTools.UI
{
    [InitializeOnLoad]
    class CreateDragImage
    {
        static CreateDragImage()
        {
            EditorApplication.hierarchyWindowItemOnGUI += HierachyWindowItemFunc;
            SceneView.duringSceneGui += HierachyWindowItemFunc;
        }

        static void HierachyWindowItemFunc(SceneView scene)
        {
            if(Event.current.type != EventType.DragPerform)
                return;

            Vector2 mousePos = Event.current.mousePosition;
            mousePos.y = scene.camera.pixelHeight - mousePos.y;
            HierachyWindowItemFunc(null, scene.camera.ScreenToWorldPoint(mousePos));
        }

        static void HierachyWindowItemFunc(int instanceID, Rect selectionRect)
        {
            if (Event.current.type != EventType.DragPerform)
                return;

            Vector2 mousePos = Event.current.mousePosition;
            if (!selectionRect.Contains(Event.current.mousePosition))
                return;

            GameObject gameObject = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
            if (gameObject == null || gameObject.GetComponentInParent<Canvas>() == null)
                return;

            HierachyWindowItemFunc(gameObject.transform, Vector2.zero);
        }

        static void HierachyWindowItemFunc(Transform target, Vector2 position)
        {
            List<Sprite> sprites = new List<Sprite>();
            foreach(Object obj in DragAndDrop.objectReferences)
            {
                string path = AssetDatabase.GetAssetPath(obj);
                if(!string.IsNullOrEmpty(path))
                {
                    if (obj is Sprite)
                        sprites.Add(obj as Sprite);
                    else if( obj is Texture2D)
                    {
                        Sprite sp = AssetDatabase.LoadAssetAtPath<Sprite>(path);
                        if (sp)
                            sprites.Add(sp);
                    }
                }
            }
            if (sprites.Count == 0)
                return;

            Canvas canvas = GameObject.FindObjectOfType<Canvas>();
            if (canvas)
                canvas = canvas.rootCanvas;

            List<GameObject> list = new List<GameObject>();
            foreach(Sprite sprite in sprites)
            {
                var gameObject = new GameObject(sprite.name);
                var image = gameObject.AddComponent<UnityEngine.UI.Image>();
                if (target)
                    gameObject.transform.SetParent(target,false);
                else if (canvas)
                {
                    gameObject.transform.SetParent(canvas.transform,false);
                    gameObject.transform.position = position;
                }
                image.sprite = sprite;
                image.SetNativeSize();
                image.raycastTarget = false;
                list.Add(gameObject);
            }
            Selection.objects = list.ToArray();
            Event.current.Use();
        }
    }
}
