package dokotera.immobilisation.persistence.action;

import generic.annotation.C;
import generic.annotation.P;
import generic.kodro.A;

import java.sql.Connection;

@C(t = "taches")
@P(s = "taches_id_seq", l = 7, p = "TC")
public class Tache {
    @C(pk = true, c = "id")
    String id;
    @C(c = "description")
    String description;
    @C(c = "duree_moyenne")
    Integer dureeMoyenne;
    @C(c = "immobilisation_id")
    String immobilisationId;

    public static Tache getTacheById(Connection c, String tacheId) throws Exception {
        Tache tache = new Tache();
        tache.setId(tacheId);
        return (Tache) A.select(c, tache).get(0);
    }

    public Tache(String description, Integer dureeMoyenne, String tacheId) {
        this.description = description;
        this.dureeMoyenne = dureeMoyenne;
        this.immobilisationId = tacheId;
    }

    public Tache(){}

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

    public Integer getDureeMoyenne() {
        return dureeMoyenne;
    }

    public void setDureeMoyenne(Integer dureeMoyenne) {
        this.dureeMoyenne = dureeMoyenne;
    }

    public String getImmobilisationId() {
        return immobilisationId;
    }

    public void setImmobilisationId(String immobilisationId) {
        this.immobilisationId = immobilisationId;
    }
}
