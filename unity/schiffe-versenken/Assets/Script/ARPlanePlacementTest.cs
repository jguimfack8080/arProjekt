using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.XR.ARFoundation;

public class ARPlanePlacementTest : MonoBehaviour
{
    
    public GameObject objectToPlace;
    private ARRaycastManager arRaycastManager;
    private ARAnchorManager arAnchorManager;
    private ARPlaneManager arPlaneManager;
    private GameObject arSessionOriginObject;
    


    void Awake()
    {
        arSessionOriginObject = GameObject.FindGameObjectWithTag("ARSessionOrigin");
        arRaycastManager = arSessionOriginObject.GetComponent<ARRaycastManager>();
        arAnchorManager = arSessionOriginObject.GetComponent<ARAnchorManager>();
        arPlaneManager = arSessionOriginObject.GetComponent<ARPlaneManager>();
        

    }


    // Update is called once per frame
    void Update()
    {
        if (!IsPointerOverButtonObject())
        {
            if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
            {   // Liste der AR-Treffer, die durch den Raycast gefunden wurden
                List<ARRaycastHit> hits = new List<ARRaycastHit>();
                // Raycast - Abfrage auf der erkannten Fläche durchführen
                if (arRaycastManager.Raycast(Input.GetTouch(0).position, hits, UnityEngine.XR.ARSubsystems.TrackableType.Planes))
                {   // Einen neuen ARAnchor an der Position des Treffers hinzufügen
                    ARAnchor anchor = arAnchorManager.AddAnchor(hits[0].pose);
                    // Das zu platzierende GameObject an der Position und Rotation des Ankers instanziieren
                    Instantiate(objectToPlace, anchor.transform.position, anchor.transform.rotation, anchor.transform);

                }
                Debug.Log("Anzahl der erkannten Flächen: " + hits.Count);
            }
        }
    }
        




    bool IsPointerOverButtonObject()
    {
        PointerEventData eventDataCurrentPosition = new PointerEventData(EventSystem.current);
        eventDataCurrentPosition.position = new Vector2(Input.mousePosition.x, Input.mousePosition.y);

        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);

        foreach (RaycastResult result in results)
        {
            if (result.gameObject.CompareTag("Button")) // Schauen ob der getroffene GameObject einen "Button" Tag hat
            {
                return true;
            }
        }

        return false;
    }



}
