using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RadialBlurEffect : MonoBehaviour
{
    public Material effectMaterial;
    //模糊程度
    [Range(0, 0.05f)]
    public float blurFactor = 0.0f;
    //模糊中心（0-1）屏幕空间，默认为中心点
    public Vector2 blurCenter = new Vector2(0.5f, 0.5f);

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            effectMaterial.SetFloat("_BlurFactor", blurFactor);
            effectMaterial.SetVector("_BlurCenter", blurCenter);
            Graphics.Blit(source, destination, effectMaterial);
        }
    }
}