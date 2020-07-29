using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RebuildWorldSpace1 : MonoBehaviour
{
    // Start is called before the first frame update
    public Material effectMaterial;
    public Camera camera;
    public Transform cameraTransform;

    public float fogDensity;
    public Color fogColor;
    public float fogStart;
    public float fogEnd;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView;
            float near = camera.nearClipPlane;
            float far = camera.farClipPlane;
            float aspect = camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = cameraTransform.right * halfHeight * aspect;
            Vector3 toTop = cameraTransform.up * halfHeight;

            Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = cameraTransform.forward * near + toTop + toRight;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = cameraTransform.forward * near - toTop + toRight;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            effectMaterial.SetMatrix("_FrustumCornersRay", frustumCorners);
            effectMaterial.SetMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);

            effectMaterial.SetFloat("_FogDensity", fogDensity);
            effectMaterial.SetColor("_FogColor", fogColor);
            effectMaterial.SetFloat("_FogStart", fogStart);
            effectMaterial.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(source, destination, effectMaterial);
        }
    }
}