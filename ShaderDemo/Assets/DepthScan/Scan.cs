using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scan : MonoBehaviour
{
    [Range(0f, 0.05f)]
    [SerializeField]
    private float _lightWidth = 0.002f;

    [Range(0.0f, 2.0f)]
    [SerializeField]
    private float _speed = 0.3f;

    [SerializeField]
    private Color _lightColor = new Color(1.0f, 0.0f, 0.0f, 0.5f);
    private Camera camera;
    public Material material;

    void OnEnable()
    {
        camera = GetComponent<Camera>();
        camera.depthTextureMode |= DepthTextureMode.Depth;
        material.SetFloat("_LightWidth", _lightWidth);
        material.SetFloat("_Speed", _speed);
        material.SetColor("_LightColor", _lightColor);
    }

    private void OnDisable()
    {
        camera.depthTextureMode &= ~DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            Graphics.Blit(source, destination, material);
        }
    }
}
