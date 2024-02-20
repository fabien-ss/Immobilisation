package dokotera.immobilisation.persistence.objet;

import dokotera.immobilisation.persistence.personne.Employe;

public class Cellule {
    String title;
    String start;
    String end;
    String backgroundColor;

    Employe employe;

    public void setEmploye(Employe employe) {
        this.employe = employe;
    }

    public Employe getEmploye() {
        return employe;
    }

    public Cellule(String title, String start, String end, String color) {
        this.title = title;
        this.start = start;
        this.end = end;
        this.backgroundColor = color;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getStart() {
        return start;
    }

    public void setStart(String start) {
        this.start = start;
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public String getColor() {
        return backgroundColor;
    }

    public void setColor(String color) {
        this.backgroundColor = color;
    }
}
