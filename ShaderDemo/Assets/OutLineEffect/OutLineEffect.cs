using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class OutLineEffect : MonoBehaviour
{
    // Start is called before the first frame update
    public Material effectMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(effectMaterial == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            Graphics.Blit(source, destination, effectMaterial);
        }
    }
}