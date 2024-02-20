package dokotera.immobilisation.persistence.action;

import generic.annotation.C;
import generic.kodro.A;

import java.sql.Connection;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@C (t = "v_immobilisation_en_cours")
public class UtilisationEnCours {
    @C(c = "date_debut")
    Timestamp dateDebut;
    @C(c = "details")
    String details;
    @C(c = "nom")
    String nom;
    @C(c = "description")
    String description;
    @C(c = "date_fin")
    Timestamp dateFin;
    @C(c = "immobilation_date_fin")
    Timestamp dateFinImmobilisation;
    @C(c = "id")
    String id;
// 1 pour fini
    public List<UtilisationEnCours> obtenirListeEnCour(Connection c, String id) throws Exception {
        System.out.println("id egele "+id);
        List<UtilisationEnCours> utilisationEnCours = A.select(c, new UtilisationEnCours());
        if(id == "1"){
            List<UtilisationEnCours> fini = new ArrayList<>();
            for (UtilisationEnCours u : utilisationEnCours){
                if(u.getDateFinImmobilisation()!= null){
                    fini.add(u);
                }
            }
            utilisationEnCours = fini;
        }else if (id == "0"){
            List<UtilisationEnCours> fini = new ArrayList<>();
            for (UtilisationEnCours u : utilisationEnCours){
                if(u.getDateFinImmobilisation() == null){
                    fini.add(u);
                }
            }
            utilisationEnCours = fini;
        }
        return utilisationEnCours;
    }

    public List<UtilisationEnCours> tacheEnCours(Connection c) throws Exception {
        return A.executeQuery(c, this, "select * from v_immobilisation_en_cours where immobilation_date_fin is null");
    }
    public Timestamp getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(Timestamp dateDebut) {
        this.dateDebut = dateDebut;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getDateFin() {
        return dateFin;
    }

    public void setDateFin(String dateFin) {
        dateFin = dateFin.replace("T", " ").concat(":00");
        this.setDateFin(Timestamp.valueOf(dateFin));
    }

    public void setDateFin(Timestamp dateFin) {
        this.dateFin = dateFin;
    }

    public Timestamp getDateFinImmobilisation() {
        return dateFinImmobilisation;
    }

    public void setDateFinImmobilisation(Timestamp dateFinImmobilisation) {
        this.dateFinImmobilisation = dateFinImmobilisation;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
}
