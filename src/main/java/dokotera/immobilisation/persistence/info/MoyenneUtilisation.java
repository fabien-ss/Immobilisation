package dokotera.immobilisation.persistence.info;

import generic.annotation.C;

@C(t = "v_moyenne_utilisation")
public class MoyenneUtilisation {
    @C(c = "sum")
    Double sum;
    @C(c = "immobilisation_id")
    String immobilisationId;
    @C(c = "count")
    Integer count;
    @C(c = "jour")
    String jour;
    @C(c = "moyenne")
    Double moyenne;


    public Double getSum() {
        return sum;
    }

    public void setSum(Double sum) {
        this.sum = sum;
    }

    public String getImmobilisationId() {
        return immobilisationId;
    }

    public void setImmobilisationId(String immobilisationId) {
        this.immobilisationId = immobilisationId;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public String getJour() {
        return jour;
    }

    public void setJour(String jour) {
        this.jour = jour;
    }

    public Double getMoyenne() {
        return moyenne;
    }

    public void setMoyenne(Double moyenne) {
        this.moyenne = moyenne;
    }
}
