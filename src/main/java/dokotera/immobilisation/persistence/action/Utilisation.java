package dokotera.immobilisation.persistence.action;

import dokotera.immobilisation.persistence.objet.Immobilisation;
import generic.annotation.C;
import generic.annotation.P;
import generic.kodro.A;

import java.sql.Connection;
import java.sql.Timestamp;

@C(t = "utilisations")
@P(s = "utilisations_id_seq", l = 10, p = "US")
public class Utilisation {

    public void checkDuree(String id, Connection c) throws Exception{
        Utilisation utilisation = new Utilisation();
        utilisation.setId(id);
        utilisation = (Utilisation) A.select(c, utilisation).get(0);
        double duree  = Math.abs(utilisation.getDateDebut().getTime() - this.getDateFin().getTime());
        double differenceInMinutes = duree / (60 * 1000); // 1 minute = 60 secondes = 60 * 1000 millisecondes
        if(differenceInMinutes < 59) throw new Exception("Heure non valide");
    }
    @C(pk = true, c = "id")
    String id;
    @C(c = "rapport_id")
    String rapportId;
    @C(c = "immobilisation_id")
    String immobilisationId;
    @C(c = "tache_id")
    String tacheId;
    @C(c = "date_debut")
    Timestamp dateDebut;
    @C(c = "date_fin")
    Timestamp dateFin;

    public Utilisation(){}

    public Immobilisation getImmobilisation(Connection c) throws Exception {
        Immobilisation i = new Immobilisation();
        i.setId(this.getImmobilisationId());
        return (Immobilisation) A.select(c, i).get(0);
    }

    public Tache getTache(Connection c) throws Exception{
        Tache t = new Tache();
        t.setId(this.getTacheId());
        return (Tache) A.select(c, t).get(0);
    }

    public Utilisation(String rapportId, String immobilisationId, String tacheId, Timestamp dateDebut, Timestamp dateFin) {
        this.rapportId = rapportId;
        this.immobilisationId = immobilisationId;
        this.tacheId = tacheId;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
    }

    public Utilisation(String rapportId, String immobilisationId, String tacheId, Timestamp dateDebut) {
        this.rapportId = rapportId;
        this.immobilisationId = immobilisationId;
        this.tacheId = tacheId;
        this.dateDebut = dateDebut;
    }

    public Utilisation(String idImmobilisation, String id, Timestamp dateDebut, String rapportId) {
        this.setImmobilisationId(idImmobilisation);
        this.setTacheId(id);
        this.setDateDebut(dateDebut);
        this.setRapportId(rapportId);
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getRapportId() {
        return rapportId;
    }

    public void setRapportId(String rapportId) {
        this.rapportId = rapportId;
    }


    public String getImmobilisationId() {
        return immobilisationId;
    }

    public void setImmobilisationId(String immobilisationId) {
        this.immobilisationId = immobilisationId;
    }

    public String getTacheId() {
        return tacheId;
    }

    public void setTacheId(String tacheId) {
        this.tacheId = tacheId;
    }

    public Timestamp getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(Timestamp dateDebut) {
        this.dateDebut = dateDebut;
    }

    public Timestamp getDateFin() {
        return dateFin;
    }

    public void setDateFin(Timestamp dateFin) {
        this.dateFin = dateFin;
    }
    public void setDateFin(String dateFin) {
        dateFin = dateFin.replace("T", " ").concat(":00");
        this.setDateFin(Timestamp.valueOf(dateFin));
    }
}
