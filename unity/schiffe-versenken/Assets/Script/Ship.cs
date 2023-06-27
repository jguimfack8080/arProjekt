using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering;
using UnityEditor;
using UnityEngine;



/*Info zur Skallierung der Schiffe: Die Schiffe dürfen maximal eine Koordinate Breit sein und je nach ob 2er, 3er ..  2,3 .. Koordinaten lang sein.
  Dann sollten sie korrekt skaliert werden und bleiben in den entsprechenden Zellen.
*/

public class Ship : MonoBehaviour
{  
    Animator animator;
    private GameObject hitEffect;

    private void Awake()
    {
        animator = GetComponentInChildren<Animator>();
        hitEffect = Resources.Load<GameObject>("Effect/HitSmoke");
    }


    //Diese Methode setzt die Rotation und passt die Position zur Rotation an damit das Schiff richtig im Grid sitzt.
    public void AdjustPositionAndRotation(bool vertical,bool player1, float cellSize) {
        float zAcheKorrektur = 0;
        float xAcheKorrektur = 0;
        Vector3 rotation;
        //Wenn Horizontal
        if (!vertical)
        {     
            if (player1)
            {
                zAcheKorrektur = cellSize / 2;
                rotation = new Vector3(0, 0, 0);
            }
            else
            {
                zAcheKorrektur = -cellSize / 2;
                rotation = new Vector3(0, 180, 0);
            }
        }
        //Wenn Vertikal
        else
        {
            xAcheKorrektur = -cellSize / 2;
            if (player1)
                rotation = new Vector3(0, -90, 0);
            else
                rotation= new Vector3(0, -90, 0);
        }
       
        //Lokale Rotation wird gesetzt.
        transform.localRotation = Quaternion.Euler(rotation);
        //lokale Position wird gesetzt.
        transform.localPosition = transform.localPosition + new Vector3(xAcheKorrektur,0,zAcheKorrektur);
    }

    //Skaliert die Größe des Schiffes anhand der Zellen Größe.
    public void ScaleShipToCellSize(float cellSize) {
        transform.localScale = new Vector3(cellSize, cellSize, cellSize);
       
    }

    public void HitAnimation() {
        animator.SetTrigger("Hit");
        GameObject effect = Instantiate(hitEffect,transform);
        //Nimm die position des Kindes damit der Effekt in der Mitte des Schiffes ist.
        effect.transform.localPosition = transform.GetChild(0).transform.localPosition;
        Destroy(effect, 3);
    }

    public void DestroyShip()
    {
        Destroy(gameObject);
    }
    





}
