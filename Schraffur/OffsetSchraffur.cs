using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OffsetSchraffur : MonoBehaviour
{
    private Vector3 oldPos ;
    private float offset=0;
    private void Start()
    {
        oldPos = new Vector3(0, 0, 0);
    }
    private void Update()
    {
       if(transform.position != oldPos)
        {
            float off=Random.Range(0.0f, 1.0f);
            float alpha = Random.Range(0.4f, 1f);

            Shader.SetGlobalFloat("_SchraffurMovement", off); 
            Shader.SetGlobalFloat("_SchraffurIntensAlpha", alpha);
            oldPos = transform.position;

        }

    }
}
