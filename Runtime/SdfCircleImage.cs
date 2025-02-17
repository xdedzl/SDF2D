using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(CanvasRenderer))]
public class SdfCircleImage : MaskableGraphic
{
    [SerializeField] private Color _mainColor = Color.white;
    [SerializeField] private Color _edgeColor = Color.black;
    [SerializeField, Range(0, 1)] private float _edgeWidth = 0.1f;
    [SerializeField, Range(0, 1)] private float _radius = 1f;

    public Color mainColor
    {
        get => _mainColor;
        set { _mainColor = value; UpdateMaterialProperties(); }
    }

    public Color edgeColor
    {
        get => _edgeColor;
        set { _edgeColor = value; UpdateMaterialProperties(); }
    }

    public float edgeWidth
    {
        get => _edgeWidth;
        set { _edgeWidth = value; UpdateMaterialProperties(); }
    }

    public float radius
    {
        get => _radius;
        set { _radius = value; UpdateMaterialProperties(); }
    }

    private static readonly int MainColorId = Shader.PropertyToID("_MainColor");
    private static readonly int EdgeColorId = Shader.PropertyToID("_EdgeColor");
    private static readonly int EdgeWidthId = Shader.PropertyToID("_EdgeWidth");
    private static readonly int RadiusId = Shader.PropertyToID("_Radius");

    protected override void OnEnable()
    {
        base.OnEnable();
        var shader = Shader.Find("Custom/SDF_2D_Circle");
        if (shader != null)
        {
            material = new Material(shader);
            UpdateMaterialProperties();
        }
        else
        {
            Debug.LogError("Cannot find shader: Custom/SDF_2D_Circle");
        }
    }

    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();

        Vector2 size = rectTransform.rect.size;
        float width = size.x;
        float height = size.y;
        
        Vector2 uvMin = new Vector2(0f, 0f);
        Vector2 uvMax = new Vector2(1f, 1f);

        vh.AddVert(new Vector3(-width * 0.5f, -height * 0.5f), color, uvMin);
        vh.AddVert(new Vector3(-width * 0.5f, height * 0.5f), color, new Vector2(uvMin.x, uvMax.y));
        vh.AddVert(new Vector3(width * 0.5f, height * 0.5f), color, uvMax);
        vh.AddVert(new Vector3(width * 0.5f, -height * 0.5f), color, new Vector2(uvMax.x, uvMin.y));

        vh.AddTriangle(0, 1, 2);
        vh.AddTriangle(2, 3, 0);
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();
        UpdateMaterialProperties();
    }
#endif

    private void UpdateMaterialProperties()
    {
        if (material != null)
        {
            material.SetColor(MainColorId, _mainColor);
            material.SetColor(EdgeColorId, _edgeColor);
            material.SetFloat(EdgeWidthId, _edgeWidth);
            material.SetFloat(RadiusId, _radius);
        }
    }

#if UNITY_EDITOR
    protected override void Reset()
    {
        base.Reset();
        _mainColor = Color.white;
        _edgeColor = Color.black;
        _edgeWidth = 0.1f;
        _radius = 1f;
    }
#endif
} 