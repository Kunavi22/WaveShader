using UnityEngine;

public static class Touch
{
    public static bool IsDown
    {
        get
        {
#if  UNITY_STANDALONE_WIN || UNITY_STANDALONE_LINUX || UNITY_EDITOR
            
            return Input.GetMouseButton(0);
#elif UNITY_ANDROID
            return Input.touchCount > 0;
#endif
        }
    }

    public static bool Tap
    {
        get
        {
#if  UNITY_STANDALONE_WIN || UNITY_STANDALONE_LINUX || UNITY_EDITOR
            
            return Input.GetMouseButtonDown(0);
#elif UNITY_ANDROID
            return Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began;
#endif
        }

    }

    public static Vector2 Position
    {
        get
        {
#if  UNITY_STANDALONE_WIN || UNITY_STANDALONE_LINUX || UNITY_EDITOR
            return Input.mousePosition; 
   
#elif UNITY_ANDROID
            if (Input.touchCount > 0)
            {
                return Input.GetTouch(0).position;
            }
            else
            {
                return Vector2.zero;
            }
#endif
        }
    }
}
