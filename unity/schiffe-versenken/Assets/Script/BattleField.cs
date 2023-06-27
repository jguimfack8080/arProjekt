
using System.Collections.Generic;
using UnityEngine;
using System;


public class BattleField : MonoBehaviour
{
    public float länge;
    public int rowAndColumAmountPerHalf =10;
    public float gridLineWidth =0.04f;
    
    public GameObject schiff2er;
    public GameObject schiff3er;
    public GameObject schiff4er;
    public GameObject schiff5er;

    //Zum �bersetzten der Koordinaten in lokale Positionsdaten zum Spielfeld.
    private Dictionary<Tuple<int, int>, Vector3> coordToPositionMapFirstField = new Dictionary<Tuple<int, int>, Vector3>();
    private Dictionary<Tuple<int, int>, Vector3> coordToPositionMapSecondField = new Dictionary<Tuple<int, int>, Vector3>();

    //Map gibt zu einem Koordinatenpaar ein Schiff zur�ck.
    //Z.B. f�r Treffer-Effekte oder das entfernen der Schiffe
    private Dictionary<Tuple<int, int>, Ship> coordToShipMapFirstField = new Dictionary<Tuple<int, int>, Ship>();
    private Dictionary<Tuple<int, int>, Ship> coordToShipMapSecondField = new Dictionary<Tuple<int, int>, Ship>();

    //Breite ist die H�lfte der L�nge 
    private float breite;

    //Leeres GameObjekt in welches die Lines vom Grid gespeichert werden.
    private GameObject lines;
    private GameObject linePrefab;

    private float cellSize;

    private void Start()
    {
        this.breite = länge/2;
        linePrefab = Resources.Load<GameObject>("Line");

        //Zellengr��e ist abh�ngig von der L�nge und Anzahl der Reihen beider h�lften.
        cellSize = länge / (rowAndColumAmountPerHalf*2);
        
        DrawGrid();
        fillMapsCoordToPosition();
        
        //-----Test Plazierungen-----
        Tuple<int, int>[] pos1 = { Tuple.Create(2, 2), Tuple.Create(3, 2) };
        PlaceShip( pos1,  SpielFeld.SpielFeldSpieler1, 2);
        PlaceShip(pos1, SpielFeld.SpielFeldSpieler2, 2);

        Tuple<int, int>[] pos2 = { Tuple.Create(2, 5), Tuple.Create(2, 6), Tuple.Create(2, 7) };
        PlaceShip(pos2, SpielFeld.SpielFeldSpieler1, 3);
        PlaceShip(pos2, SpielFeld.SpielFeldSpieler2, 3);

        Tuple<int, int>[] pos3 = { Tuple.Create(2, 8), Tuple.Create(3, 8), Tuple.Create(4, 8), Tuple.Create(5, 8) };
        PlaceShip(pos3, SpielFeld.SpielFeldSpieler1, 4);
        Tuple<int, int>[] pos4 = { Tuple.Create(2, 8), Tuple.Create(3, 8), Tuple.Create(4, 8), Tuple.Create(5, 8), Tuple.Create(6, 8) };
        PlaceShip(pos4, SpielFeld.SpielFeldSpieler2, 5);
        //---------------------------

        //-----Test Markierung-------
        this.MarkHitArea(7, 1, SpielFeld.SpielFeldSpieler1,true);
        this.MarkHitArea(1, 1, SpielFeld.SpielFeldSpieler2,false);
        //---------------------------


        //-----Test Zerst�rung-------
        this.DestroyShip(Tuple.Create(2, 2), SpielFeld.SpielFeldSpieler2);
        //---------------------------

    }





    /*
     Zeichnet das Grid beider Spieler gleichzeitig.
     */
    private void DrawGrid()
    {
        lines = new GameObject("Lines");
        lines.transform.SetParent(transform);
        // Vertikale Linien zeichnen
        for (int i = 0; i <= rowAndColumAmountPerHalf * 2; i++)
        {
            drawLine(i, true);
        }
        // Horizontalen Linien zeichnen
        for (int i = 0; i <= rowAndColumAmountPerHalf; i++)
        {
            drawLine(i, false);
        }
    }
    /*Wird nur von DrawGrid genutzt.*/
    private void drawLine(int i, bool vertical)
    {
        Color lineColor = Color.red;
        Color lineColorgreen = Color.green;

        Vector3 startPoint;
        Vector3 endPoint;

        if (vertical)
        {
            startPoint = transform.TransformPoint(new Vector3(-breite / 2, 0f, länge / 2 - i * cellSize));
            endPoint = transform.TransformPoint(new Vector3(breite / 2, 0f, länge / 2 - i * cellSize));
        }
        else
        {
            startPoint = transform.TransformPoint(new Vector3(-breite / 2 + i * cellSize, 0f, länge / 2));
            endPoint = transform.TransformPoint(new Vector3(-breite / 2 + i * cellSize, 0f, -länge / 2));
        }
       

        GameObject lineObject =Instantiate(linePrefab,lines.transform);
        
        LineRenderer lineRenderer = lineObject.GetComponent<LineRenderer>();
        //Wenn es die mittlere vertikale Linie ist soll sie gr�n sein.
        if (i == (int)Math.Ceiling((double)rowAndColumAmountPerHalf) && vertical)
        {
            lineRenderer.startColor = lineColorgreen;
            lineRenderer.endColor = lineColorgreen;
        }
        //Sonst rot.
        else
        {
            lineRenderer.startColor = lineColor;
            lineRenderer.endColor = lineColor;
        }
        lineRenderer.startWidth = gridLineWidth;
        lineRenderer.endWidth = gridLineWidth;
        //Setzten der vorher berechneten Position.
        lineRenderer.SetPosition(0, startPoint);
        lineRenderer.SetPosition(1, endPoint);
    }

    

    /*
    Setzt ein Schiff auf das Spielfeld mittels eines Tuple-Arrays welches alle Koordinaten besitzt. 
    Dabei wird der boolean player1 genutzt um das Spielfeld zu ermitteln.
    type wird verwenden um das gew�nschte Schiff zu bestimmen.
     */

    public void PlaceShip(Tuple<int,int>[] coordinates,SpielFeld spielFeld, int type) {
        GameObject selectedShipPrefab = null;
        bool isVertical;
        
        //Ausrichtung des Schiffes anhand der ersten beiden X-Koordinaten berechnen.
        if (coordinates[0].Item1 == coordinates[1].Item1)
            isVertical = true;
        else
            isVertical = false;
        //Schiffsprefab anhand des Types bestimmen.
        if (type == 2)
            selectedShipPrefab = this.schiff2er;
        else if (type == 3)
            selectedShipPrefab = this.schiff3er;
        else if (type == 4)
            selectedShipPrefab = this.schiff4er;
        else if (type == 5)
            selectedShipPrefab = this.schiff5er;
        


        //Schiff-GameObjekt erstellen.
        GameObject shipObject = Instantiate(selectedShipPrefab, transform);

        //Position setzten.
        Vector3 position;
        //Wenn Spieler 1 FirstFieldMap nutzen um Koordinaten zu ermitteln.
        if (SpielFeld.SpielFeldSpieler1.Equals(spielFeld))
            this.coordToPositionMapFirstField.TryGetValue(coordinates[0], out position);
        //Wenn Spieler 2 SecondFieldMap nutzen um Koordinaten zu ermitteln.
        else
            this.coordToPositionMapSecondField.TryGetValue(coordinates[0], out position); 
        shipObject.transform.localPosition = position;

         //Anpassungen werden �ber die Ship-Komponente vorgenommen.
         Ship ship = shipObject.GetComponent<Ship>();
        
        ship.AdjustPositionAndRotation(isVertical, SpielFeld.SpielFeldSpieler1.Equals(spielFeld), cellSize);

        //Anpassen der Skalierung der Schiffe zur Zellen Gr��e.
        ship.ScaleShipToCellSize(cellSize);
        //Koordinaten in relation mit dem Schiff setzten.
        foreach (Tuple<int, int> pos in coordinates) {
            if (SpielFeld.SpielFeldSpieler1.Equals(spielFeld)) {
                this.coordToShipMapFirstField.Add(pos, ship);
            }
            else
            {
                this.coordToShipMapSecondField.Add(pos, ship);
            }
        }
    }
    /*
     Setzt f�r jedes Feld die lokalen Koordinaten in die coordToPositionMapFirstField und coordToPositionMapSecondField Maps. 
     */
    private void fillMapsCoordToPosition()
    {
        //Feld Spieler 1
        float startX = -this.breite / 2;
        Vector3 actualPosition = new Vector3(-this.breite / 2, 0, this.breite);
        for (int rowCount = 1; rowCount <= this.rowAndColumAmountPerHalf; rowCount++)
        {
            for (int columCount = 1; columCount <= this.rowAndColumAmountPerHalf; columCount++)
            {
                //Hinzuf�gen der Positionen f�r das Spielfeld des 1.Spielers.
                this.coordToPositionMapFirstField.Add(Tuple.Create(rowCount, columCount), (actualPosition + new Vector3(cellSize / 2, 0, -cellSize / 2)));
                
                //N�chste Spalte
                actualPosition += new Vector3(cellSize, 0, 0);
            }
            //Eine  Reihe runter und zur ersten Spalte wechseln.
            actualPosition = new Vector3(startX, actualPosition.y, actualPosition.z - cellSize);

        }
        //Feld Spieler 2
        startX = -this.breite / 2;
        actualPosition = new Vector3(-this.breite / 2, 0, -this.breite);

        for (int rowCount = 1; rowCount <= this.rowAndColumAmountPerHalf; rowCount++)
        {
            for (int columCount = 1; columCount <= this.rowAndColumAmountPerHalf; columCount++)
            {
                //Hinzuf�gen der Positionen f�r das Spielfeld des 2.Spielers.
                this.coordToPositionMapSecondField.Add(Tuple.Create(rowCount, columCount), (actualPosition + new Vector3(cellSize / 2, 0, +cellSize / 2)));
                
                //N�chste Spalte
                actualPosition += new Vector3(cellSize, 0, 0);
            }
            //Eine  Reihe runter und zur ersten Spalte wechseln.
            actualPosition = new Vector3(startX, actualPosition.y, actualPosition.z + cellSize);

        }

    }

    public Vector3 GetPositionByCoordinates(Tuple<int,int> posTuple,SpielFeld spielFeld) {
        Vector3 posVector;
        if (SpielFeld.SpielFeldSpieler1 == spielFeld)
        {
            this.coordToPositionMapFirstField.TryGetValue(posTuple, out posVector);
        }
        else
        {
            this.coordToPositionMapSecondField.TryGetValue(posTuple, out posVector);
        }
        return posVector;


    }
    

    //Zum Zerst�ren eines Schiffes mittels den Koordinaten.
    public void DestroyShip(Tuple<int,int> coordinates, SpielFeld spielFeld) {
        Ship ship;
        if (spielFeld == SpielFeld.SpielFeldSpieler1) {
            this.coordToShipMapFirstField.TryGetValue(coordinates, out ship);
        }
        else
        {
            this.coordToShipMapFirstField.TryGetValue(coordinates, out ship);
        }

        ship.DestroyShip();
    }
    //Zum Animieren eines Treffers mittels den Koordinaten.
    public void SimulateHit(Tuple<int, int> coordinates, SpielFeld spielFeld) {
        Ship ship;
        if (spielFeld == SpielFeld.SpielFeldSpieler1)
        {
            this.coordToShipMapFirstField.TryGetValue(coordinates, out ship);
        }
        else
        {
            this.coordToShipMapFirstField.TryGetValue(coordinates, out ship);
        }

        ship.HitAnimation();
    }
    //Zum Makieren der bereits getroffenen Felder.
    public void MarkHitArea(int x, int y, SpielFeld spielFeld, bool hitShip)
    {
        Vector3 middlePositionCell = GetPositionByCoordinates(Tuple.Create(x, y), spielFeld);
        Color lineColor;
        if (hitShip)
            lineColor = Color.green;
        else
            lineColor = Color.red;

        Vector3 startPoint1 = transform.TransformPoint(new Vector3(cellSize / 2, 0, -cellSize / 2) + middlePositionCell);
        Vector3 endPoint1 = transform.TransformPoint(new Vector3(-cellSize / 2, 0, cellSize / 2) + middlePositionCell);

        Vector3 startPoint2 = transform.TransformPoint(new Vector3(-cellSize / 2, 0, -cellSize / 2) + middlePositionCell);
        Vector3 endPoint2 = transform.TransformPoint(new Vector3(cellSize / 2, 0, cellSize / 2) + middlePositionCell);


        GameObject lineObject1 = Instantiate(linePrefab, lines.transform);

        GameObject lineObject2 = Instantiate(linePrefab, lines.transform);

        LineRenderer lineRenderer1 = lineObject1.GetComponent<LineRenderer>();
        LineRenderer lineRenderer2 = lineObject2.GetComponent<LineRenderer>();

        lineRenderer1.startColor = lineColor;
        lineRenderer1.endColor = lineColor;
        lineRenderer2.startColor = lineColor;
        lineRenderer2.endColor = lineColor;

        lineRenderer1.startWidth = gridLineWidth;
        lineRenderer1.endWidth = gridLineWidth;
        lineRenderer2.startWidth = gridLineWidth;
        lineRenderer2.endWidth = gridLineWidth;

        //Setzten der vorher berechneten Position.
        lineRenderer1.SetPosition(0, startPoint1);
        lineRenderer1.SetPosition(1, endPoint1);

        lineRenderer2.SetPosition(0, startPoint2);
        lineRenderer2.SetPosition(1, endPoint2);

    }




    //Methoden zum Testen
    public void HitTest()
    {
        IEnumerable<Ship> values = this.coordToShipMapFirstField.Values;

        foreach (Ship value in values)
        {
            if (value != null)
                value.HitAnimation();
        }
        values = this.coordToShipMapSecondField.Values;

        foreach (Ship value in values)
        {
            if (value != null)
                value.HitAnimation();
        }
    }



}

public enum SpielFeld { 
    SpielFeldSpieler1,
    SpielFeldSpieler2,
}