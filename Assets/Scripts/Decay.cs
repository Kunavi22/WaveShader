using UnityEngine;

public class Decay : MonoBehaviour
{

    [SerializeField] private RenderTexture canvas;
    [SerializeField] private Material drawMat;
    [SerializeField] private float damping = 1.2f;
    [SerializeField] private float viscosity = 8.0f;



    void Start()
    {
        _tempTexture = new RenderTexture(canvas.width, canvas.height, 0, canvas.format);

    }
    // Update is called once per frame
    void Update()
    {
        drawMat.SetFloat("_DeltaTime", Time.deltaTime);
        drawMat.SetFloat("_Damping", damping);
        drawMat.SetFloat("_Viscosity", viscosity);


        Graphics.Blit(canvas, _tempTexture);
        drawMat.SetTexture("_Prev", _tempTexture);
        Graphics.Blit(_tempTexture, canvas, drawMat);
    }

    private RenderTexture _tempTexture;
}
