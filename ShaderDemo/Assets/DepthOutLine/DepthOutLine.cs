using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthOutLine : MonoBehaviour
{
    // Start is called before the first frame update
    public Material effectMaterial;

    private void Start()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial == null) return;
        Graphics.Blit(source, destination, effectMaterial);
    }
}