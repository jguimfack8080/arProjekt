using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MenuGameField : MonoBehaviour
{
    public Button button;
    public Image image;
    public Tuple<int,int> coordinates;
    //Hier vielleicht Enum für Zustand des Feldes..

    // Start is called before the first frame update
    void Start()
    {
        button = GetComponent<Button>();
        image = GetComponent<Image>();
        //Methode TestClickEvent dem Button hinzufügen.
        button.onClick.AddListener(TestClickEvent);
     
    }


    public void TestClickEvent() {
        /*ColorBlock cb = button.colors;
        cb.normalColor = Color.blue;
        button.colors = cb;*/
        image.color = Color.blue;
    }


}
