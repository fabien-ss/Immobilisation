package dokotera.immobilisation.persistence.objet;

import dokotera.immobilisation.persistence.action.Tache;
import dokotera.immobilisation.persistence.info.Amortissement;
import generic.annotation.C;
import generic.annotation.P;
import generic.base.Connexion;
import generic.kodro.A;

import java.sql.Connection;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

@C(t = "immobilisations")
@P(s = "immobilisations_id_seq", l = 10, p = "IMM")
public class Immobilisation {
    @C(pk = true, c = "id")
    String id;
    @C(c = "description")
    String description;
    @C(c = "date_achat")
    Date dateAchat;
    @C(c = "type_id")
    String typeId;
    @C(c="details")
    String details;

    @C(c = "prix_achat")
    Double prixAchat;
    Amortissement amortissement;

    List<Tache> tacheList;

    public Immobilisation() {
    }

    public Immobilisation(String description, Date dateAchat, String typeId) {
        this.description = description;
        this.dateAchat = dateAchat;
        this.typeId = typeId;
    }

    public Immobilisation(String description, String dateAchat, String typeId, String details, String prixAchat) {
        this.description = description;
        this.setDateAchat(dateAchat);
        this.typeId = typeId;
        this.details = details;
        this.setPrixAchat(prixAchat);
    }

    private void setPrixAchat(String prixAchat) {
        setPrixAchat(Double.valueOf(prixAchat));
    }


    private void setDateAchat(String dateAchat) {
        setDateAchat(Date.valueOf(dateAchat));
    }

    public List<Immobilisation> obtenirImmobilisation(Connection c) throws Exception {
        List<Immobilisation> immobilisations = A.select(c, this);
        for (Immobilisation i : immobilisations) {
            i.setTacheList(c);
        }
        return immobilisations;
    }

    public void setTacheList(Connection c) throws Exception {
        Tache tache = new Tache();
        tache.setImmobilisationId(this.id);
        this.tacheList = A.select(c, tache);
    }

    public List<Tache> getTacheList() {
        return tacheList;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getDateAchat() {
        return dateAchat;
    }

    public void setDateAchat(Date dateAchat) {
        this.dateAchat = dateAchat;
    }

    public String getTypeId() {
        return typeId;
    }

    public void setTypeId(String typeId) {
        this.typeId = typeId;
    }

    public static void main(String[] args) throws Exception {
        Connection c = new Connexion().enterToBdd();
        Immobilisation immobilisation =
                new Immobilisation("Ordinateur de bureau",
                        java.sql.Date.valueOf(LocalDate.now()), "T000000002");
        A.insert(c, immobilisation);
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }


    public List<String[]> splitDetails(){
        String[] strings = this.details.split(",");
        List<String[]> retour = new ArrayList<>();
        for(String s : strings) retour.add(s.split("="));
        return retour;
    }

    public void setAmortissements() {

    }

    public List<Amortissement> getAmortissement(String types, String durees) {
        int duree = Integer.valueOf(durees);
        int type = Integer.valueOf(types);
        //duree -= 1;
        Amortissement amortissement1 = new Amortissement();
        amortissement1.setValeurBase(this.prixAchat);
        amortissement1.setDureeAmortissement(duree);
        amortissement1.setDureeAmortissementInitiale(duree);
        amortissement1.setTauxAmortissement(100 / (float) amortissement1.getDureeAmortissement());
        amortissement1.setDateFin(LocalDate.parse(this.dateAchat.toString()));
        amortissement1.setAnnuiteAmortissement(Double.valueOf(0));
        List<Amortissement> amortissements;
        if(type == 1){
            //amortissement1.setDureeAmortissement(amortissement1.getDureeAmortissement() - 1);
            //amortissement1.setDureeAmortissementInitiale(amortissement1.getDureeAmortissementInitiale() - 1);
            amortissements =  amortissement1.tableauAmortissementLineaire();
        }else{
            amortissements = amortissement1.tableauAmortissementDegressif();
            amortissements.remove(amortissements.size() - 1);
       }
        return amortissements;
    }

    public Double getPrixAchat() {
        return prixAchat;
    }

    public void setPrixAchat(Double prixAchat) {
        this.prixAchat = prixAchat;
    }
}
