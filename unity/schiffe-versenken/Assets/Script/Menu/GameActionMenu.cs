using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameActionMenu : MonoBehaviour
{
    public GameObject buttonPrefab;
    private BattleField battleField;
    //Zum übersetzten der Koordinaten in lokale Positionsdaten zum Spielfeld.
    private Dictionary<Tuple<int, int>, GameObject> coordToButtonObjectMap = new Dictionary<Tuple<int, int>, GameObject>();
    private GridLayoutGroup gridLayoutGroup;

    // Start is called before the first frame update
    void Start()
    {
        //Referenz zum Spielfeld.
        battleField = GameObject.FindGameObjectWithTag("SpielFeld").GetComponent<BattleField>();
        gridLayoutGroup = GetComponent<GridLayoutGroup>();
        InitMenu();

    }

    // Update is called once per frame
    void Update()
    {
        
    }


    void InitMenu() {
        for (int y = 1; y <= battleField.rowAndColumAmountPerHalf; y++) {
            for (int x = 1; x <= battleField.rowAndColumAmountPerHalf; x++)
            {
                //Erstellt ein Button als Kind dieses Objektes(GameActionMenuTest)
                GameObject buttonObject = Instantiate(buttonPrefab, transform);
                //Mapt die Koordinaten plus 1 weil das Spielfeld mit (1,1) beginnt.
                coordToButtonObjectMap.Add(new Tuple<int, int>(x, y), buttonObject);
            }
          

        }
    }

}
