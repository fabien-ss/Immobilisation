package dokotera.immobilisation.persistence.objet;

import com.google.gson.Gson;
import dokotera.immobilisation.persistence.info.MoyenneUtilisation;
import dokotera.immobilisation.persistence.personne.Employe;
import generic.annotation.C;
import generic.annotation.P;
import generic.kodro.A;

import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;
import java.util.Locale;

import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
@C(t = "callendrier_utilisation")
@P(s= "callendrier_utilisation_id_seq", l=5, p="")
public class Callendrier {
    @C(pk = true, c="id")
    Integer id;
    @C(c = "numero_jour")
    Integer numeroJour;
    @C(c = "annee")
    Integer annee;
    @C(c = "mois")
    Integer mois;
    @C(c = "jour")
    String jour;
    @C(c = "immobilisation_id")
    String immobilisationId;
    @C(c = "heure")
    Double heure;


    public Callendrier(Integer numeroJour, Integer annee, Integer mois, String jour, String immobilisationId, Double heure) {
        this.numeroJour = numeroJour;
        this.annee = annee;
        this.mois = mois;
        this.jour = jour;
        this.immobilisationId = immobilisationId;
        this.heure = heure;
    }

    public java.util.List<Cellule> getStructuredListData(Connection c) throws Exception {
        java.util.List<Callendrier> callendrierList = A.select(c, this);
        List<Cellule> cellules = new ArrayList<>();
        for (int i = 0; i < callendrierList.size(); i++){

            String sql = "select e.* from employes e join rapport r on e.id = r.employe_id join callendrier_utilisation c on c.annee='"
                    + callendrierList.get(i).getAnnee()+"' and c.mois = '"+callendrierList.get(i).getMois()+"' and c.numero_jour='"+
                    callendrierList.get(i).getNumeroJour()+"' and c.immobilisation_id='"+callendrierList.get(i).getImmobilisationId()+"'";

            System.out.println("sql "+sql);
            Employe e = (Employe) A.executeQuery(c, new Employe(), sql).get(0);
            //(String title, String start, String end, String color
            String start = callendrierList.get(i).getAnnee()+
                    "-"+formatDate(callendrierList.get(i).getMois()+"")+
                    "-"+formatDate(callendrierList.get(i).getNumeroJour()+"");
            String end = "";
                end =callendrierList.get(i).getAnnee()+
                        "-"+formatDate(callendrierList.get(i).getMois()+"")+
                        "-"+formatDate(callendrierList.get(i).getNumeroJour()+"");
            Cellule cellule = new Cellule(callendrierList.get(i).getHeure()+"", start, end, callendrierList.get(i).getColor()+"");
            cellule.setEmploye(e);
            cellules.add(cellule);
        }
        return cellules;
    }

    public String getColor(){
        if(this.heure <= 5) return "yellow";
        else if(this.heure > 5 && this.heure <= 6) return "green";
        else if(this.heure > 6 && this.heure <= 7) return "orange";
        else if(this.heure > 7) return "red";
        return "green";
    }

    public String getJsonList(Connection c) throws Exception {
        Gson gson = new Gson();
        String json = gson.toJson(this.getStructuredListData(c));
        return json;
    }

    public String formatDate(String value){
        if(value.length() == 1) return "0"+value;
        return value;
    }

    public Callendrier() {

    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getNumeroJour() {
        return numeroJour;
    }

    public void setNumeroJour(Integer numeroJour) {
        this.numeroJour = numeroJour;
    }

    public Integer getAnnee() {
        return annee;
    }

    public void setAnnee(Integer annee) {
        this.annee = annee;
    }

    public Integer getMois() {
        return mois;
    }

    public void setMois(Integer mois) {
        this.mois = mois;
    }

    public String getJour() {
        return jour;
    }

    public void setJour(String jour) {
        this.jour = jour;
    }

    public String getImmobilisationId() {
        return immobilisationId;
    }

    public void setImmobilisationId(String immobilisationId) {
        this.immobilisationId = immobilisationId;
    }

    public Double getHeure() {
        return heure;
    }

    public void setHeure(Double heure) {
        this.heure = heure;
    }
}
