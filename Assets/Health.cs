using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Health : MonoBehaviour
{
    private Material mat;

    public float health = 1f;

    private static readonly int Health1 = Shader.PropertyToID("_Health");

    // Start is called before the first frame update
    void Start()
    {
        mat = GetComponent<MeshRenderer>().materials[0];
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetFloat(Health1, health);
    }
}
