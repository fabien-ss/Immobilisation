package dokotera.immobilisation.persistence.info;

import generic.annotation.C;
import generic.kodro.A;

import java.sql.Connection;
import java.util.List;

@C(t = "v_employe_immobilisation")
public class Utilisation {
    @C(c = "nombre")
    Integer nombre;
    @C(c="employe")
    String employeId;
    @C(c ="immobilisation")
    String immobilisationId;
    @C(c = "nom")
    String nom;

    public List<Utilisation> getMoyenneUtilisation(Connection c) throws Exception {
        List<Utilisation> moyenneUtilisations = A.select(c, this);
        return moyenneUtilisations;
    }

    public String[] jsonFormat(Connection c) throws Exception {
        String[] retour = new String[2];
        List<Utilisation> moyenneUtilisations = getMoyenneUtilisation(c);
        String indice1 = "";
        String indece2 = "";
        for (Utilisation m : moyenneUtilisations){
            indice1 += m.getNombre() + ",";
            indece2 += "'"+m.getNom() + "',";
        }
        retour[0] = indice1;
        retour[1] = indece2;
        return retour;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getNom() {
        return nom;
    }

    public Integer getNombre() {
        return nombre;
    }

    public void setNombre(Integer nombre) {
        this.nombre = nombre;
    }

    public String getEmployeId() {
        return employeId;
    }

    public void setEmployeId(String employeId) {
        this.employeId = employeId;
    }

    public String getImmobilisationId() {
        return immobilisationId;
    }

    public void setImmobilisationId(String immobilisationId) {
        this.immobilisationId = immobilisationId;
    }
}
