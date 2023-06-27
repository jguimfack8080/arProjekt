using System.Collections;
using System.Collections.Generic;
using FlutterUnityIntegration;
using UnityEngine;

public class EchoScript : MonoBehaviour
{
    //echoTest function, which is called from flutter
    public void echoTest(string message)
    {
        UnityMessageManager.Instance.SendMessageToFlutter(message);
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
