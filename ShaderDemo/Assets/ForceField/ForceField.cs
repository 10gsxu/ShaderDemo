using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceField : MonoBehaviour
{
    void Start()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }
}
