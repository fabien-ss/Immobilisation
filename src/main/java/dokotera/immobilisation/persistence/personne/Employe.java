package dokotera.immobilisation.persistence.personne;

import generic.annotation.C;
import generic.annotation.P;
import generic.base.Connexion;
import generic.kodro.A;

import java.sql.Connection;
import java.util.*;

@C(t = "employes")
@P(s = "employes_id_seq", l = 10, p = "EMP")
public class Employe {
    @C(pk = true, c = "id")
    String id;
    @C(c = "nom")
    String nom;
    @C(c = "prenom")
    String prenom;

    public List<Employe> obtenirEmployeEnTravaillant(Connection c) throws Exception {
        String sql = "with part1 as\n" +
                "    (\n" +
                "        select employe_id from rapport where date_fin is null\n" +
                "    )\n" +
                "    select e.* from employes e join part1 on part1.employe_id = e.id";
        return A.executeQuery(c, new Employe(), sql);
    }

    public Employe(String nom, String prenom) {
        this.nom = nom;
        this.prenom = prenom;
    }

    public Employe(){}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public static void main(String[] args) throws Exception {
        Connection connection = new Connexion().enterToBdd();
        Employe employe = new Employe("Fabien", "Dupain");
        A.insert(null, employe);
    }
}

