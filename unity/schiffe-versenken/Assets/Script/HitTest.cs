using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HitTest : MonoBehaviour
{
    GameObject[] spielFelder;

    public void StartTest() {
        spielFelder = GameObject.FindGameObjectsWithTag("SpielFeld");

        foreach (GameObject feldObject in spielFelder) {
            BattleField battleField = feldObject.GetComponent<BattleField>();
            battleField.HitTest();
        }
    
    }
}
