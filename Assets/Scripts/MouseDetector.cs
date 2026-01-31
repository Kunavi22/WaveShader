using UnityEngine;

public class MouseDetector : MonoBehaviour
{

    [SerializeField] private RenderTexture canvas;

    [SerializeField] private Material drawMat;

    [SerializeField][Range(0.001f, 0.7f)] private float radius = 0.05f;



    void Start()
    {

        _mainCamera = Camera.main;

        _tempTexture = new RenderTexture(canvas.width, canvas.height, 0, canvas.format);

        Graphics.Blit(Texture2D.blackTexture, canvas); // clear once
    }

    void Update()
    {
        Vector2 mousePos;
        Vector2 mouseDelta;

        if (GetMousePositionOnObject(out mousePos, out mouseDelta))
        {
            drawMat.SetVector("_PaintUV", mousePos);

            drawMat.SetVector("_MouseDelta", mouseDelta);

            drawMat.SetFloat("_BrushRadius", radius);

            //drawMat.SetFloat("_BrushRadius", radius);

            // copy old → temp
            Graphics.Blit(canvas, _tempTexture);
            drawMat.SetTexture("_Prev", _tempTexture);
            Graphics.Blit(_tempTexture, canvas, drawMat);

            // Graphics.Blit(canvas, temp, drawMat);
            // Graphics.Blit(temp, canvas);
        }
    }




    bool GetMousePositionOnObject(out Vector2 position, out Vector2 mouseDir)
    {
        // Check if the left mouse button is held down, or do this every frame
        if (Touch.IsDown)
        {
            // Create a ray from the camera through the mouse position
            Ray ray = _mainCamera.ScreenPointToRay(Touch.Position);
            RaycastHit hit;

            // Perform the raycast
            if (Physics.Raycast(ray, out hit))
            {
                // hit.point contains the Vector3 position where the ray hit the collider


                Vector2 hitPoint = new Vector2(
                (hit.point.x / 10) + 0.5f,
                (hit.point.z / 10) + 0.5f);



                if (Touch.Tap)
                {
                    _prevPosition = hitPoint;
                    _prevMouseDir = Vector2.zero;
                }


                position = hitPoint;


                if (hitPoint == _prevPosition)
                {
                    mouseDir = _prevMouseDir;
                }
                else
                {
                    mouseDir = (hitPoint - _prevPosition).normalized;
                }

                _prevMouseDir = mouseDir;


                _prevPosition = hitPoint;
                return true;

            }
        }

        position = new Vector2();
        mouseDir = Vector2.zero;
        return false;
    }

    private Vector2 _prevPosition;
    private Vector2 _prevMouseDir;
    private Camera _mainCamera;
    private RenderTexture _tempTexture;
}
