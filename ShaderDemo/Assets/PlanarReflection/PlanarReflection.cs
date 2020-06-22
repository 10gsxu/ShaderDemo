using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanarReflection : MonoBehaviour
{
    private Camera mainCamera, reflectCamera;
    private RenderTexture reflectTex;
    private Renderer render;
    private Material reflectMaterial;

    private Matrix4x4 reflectMatrix;
    private bool isRendering = false;

    public Material blurMaterial;
    public int downSample = 0;
    private RenderTexture blurTex;
    void Start()
    {
        mainCamera = Camera.main;
        GameObject go = new GameObject("ReflectCamera", typeof(Camera));
        reflectCamera = go.GetComponent<Camera>();
        reflectCamera.fieldOfView = mainCamera.fieldOfView;
        reflectCamera.aspect = mainCamera.aspect;
        reflectCamera.cullingMask = mainCamera.cullingMask;
        //自己控制渲染的层级
        //reflectCamera.cullingMask = 1 << LayerMask.NameToLayer("Player");
        reflectCamera.enabled = false;

        reflectTex = RenderTexture.GetTemporary(1024, 1024, 24);
        reflectCamera.targetTexture = reflectTex;

        render = GetComponent<Renderer>();
        reflectMaterial = render.sharedMaterial;

        if (blurMaterial != null)
        {
            blurTex = RenderTexture.GetTemporary(1024 >> downSample, 1024 >> downSample, 24);
        }
    }

    private void OnDisable()
    {
        if (reflectTex != null)
            RenderTexture.ReleaseTemporary(reflectTex);
        if (blurTex != null)
            RenderTexture.ReleaseTemporary(blurTex);
    }

    //这个函数会在渲染管线的剔除环节执行，需要目标有Renderer组件
    private void OnWillRenderObject()
    {
        if (isRendering) return;
        isRendering = true;
        float w = -Vector3.Dot(transform.up, transform.position);
        Vector3 normal = transform.up;
        Vector4 plane = new Vector4(normal.x, normal.y, normal.z, w);
        reflectMatrix = Matrix4x4.identity;
        CalculateReflectMatrix(ref reflectMatrix, plane);
        reflectCamera.worldToCameraMatrix = mainCamera.worldToCameraMatrix * reflectMatrix;
        //reflectCamera.projectionMatrix = mainCamera.projectionMatrix;
        //为了反射相机近裁剪平面紧贴我们的反射平面，防止错误渲染
        //我们需要重新计算反射相机的投影矩阵，斜裁剪矩阵(ObliqueMatrix)
        //因为本项目没有出现这种问题，所以没有使用
        Vector4 viewPlane = CameraSpacePlane(reflectCamera.worldToCameraMatrix, transform.position, normal);
        reflectCamera.projectionMatrix = reflectCamera.CalculateObliqueMatrix(viewPlane);
        //是否反转背面剔除
        GL.invertCulling = true;
        reflectCamera.Render();
        GL.invertCulling = false;

        if (blurMaterial != null)
        {
            RenderTexture tempTex = RenderTexture.GetTemporary(1024 >> downSample, 1024 >> downSample, 24);
            //使用第1个Pass渲染
            Graphics.Blit(reflectTex, blurTex, blurMaterial, 0);
            //使用第2个Pass渲染
            Graphics.Blit(blurTex, tempTex, blurMaterial, 1);
            Graphics.Blit(tempTex, blurTex);
            RenderTexture.ReleaseTemporary(tempTex);
            reflectMaterial.SetTexture("_ReflectTex", blurTex);
        }
        else
        {
            reflectMaterial.SetTexture("_ReflectTex", reflectTex);
        }

        isRendering = false;
    }

    //计算plane平面的反射矩阵
    private void CalculateReflectMatrix(ref Matrix4x4 matrix, Vector4 plane)
    {
        matrix.m00 = (1F - 2F * plane[0] * plane[0]);
        matrix.m01 = (-2F * plane[0] * plane[1]);
        matrix.m02 = (-2F * plane[0] * plane[2]);
        matrix.m03 = (-2F * plane[3] * plane[0]);

        matrix.m10 = (-2F * plane[1] * plane[0]);
        matrix.m11 = (1F - 2F * plane[1] * plane[1]);
        matrix.m12 = (-2F * plane[1] * plane[2]);
        matrix.m13 = (-2F * plane[3] * plane[1]);

        matrix.m20 = (-2F * plane[2] * plane[0]);
        matrix.m21 = (-2F * plane[2] * plane[1]);
        matrix.m22 = (1F - 2F * plane[2] * plane[2]);
        matrix.m23 = (-2F * plane[3] * plane[2]);
    }

    //计算视图空间的平面
    private Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal)
    {
        Vector3 viewPos = worldToCameraMatrix.MultiplyPoint3x4(pos);
        Vector3 viewNormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
        float w = -Vector3.Dot(viewPos, viewNormal);
        return new Vector4(viewNormal.x, viewNormal.y, viewNormal.z, w);
    }
}
