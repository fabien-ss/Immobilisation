package dokotera.immobilisation.persistence.action;

import dokotera.immobilisation.persistence.info.MoyenneUtilisation;
import dokotera.immobilisation.persistence.objet.Callendrier;
import generic.annotation.C;
import generic.annotation.P;
import generic.kodro.A;

import java.awt.*;
import java.sql.Connection;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@C(t = "rapport")
@P(s = "rapport_id_seq", l = 10, p = "R")
public class Rapport {
    @C(pk = true, c = "id")
    String id;
    @C(c = "employe_id")
    String employeId;
    @C(c = "details")
    String details;
    @C(c = "date_debut")
    Timestamp dateDebut;
    @C(c = "date_fin")
    Timestamp dateFin;
    @C(c = "suspicieux")
    Integer suspiceux;
    List<Utilisation> utilisations;

    public void updateCallendrier(Connection c) throws Exception {
        String sql = "update rapport set suspicieux=0 where id='"+this.id+"'";
        A.executeUpdate(c, sql);
        this.setUtilisations(c);
        String idImmobilisation = this.utilisations.get(0).getImmobilisationId();
        double totalHours = getTotalHours();
        Integer annee = this.dateFin.getYear() + 1900;
        Integer mois = this.dateFin.getMonth();
        Integer jour = this.dateFin.getDay();
        LocalDateTime localDateTime = this.dateFin.toLocalDateTime();
        Callendrier callendrier = new Callendrier(localDateTime.getDayOfMonth(), annee, localDateTime.getMonthValue(), jour+"", idImmobilisation, totalHours);
        A.insert(c, callendrier);
        c.commit();
    }

    public void updateCallendrierMoyenne(Connection c) throws Exception {
        String sql = "update rapport set suspicieux=0 where id='"+this.id+"'";
        A.executeUpdate(c, sql);
        this.setUtilisations(c);
        String idImmobilisation = this.utilisations.get(0).getImmobilisationId();
        double totalHours = getTotalHours();
        Integer annee = this.dateFin.getYear() + 1900;
        Integer mois = this.dateFin.getMonth();
        Integer jour = this.dateFin.getDay();
        LocalDateTime localDateTime = this.dateFin.toLocalDateTime();
        Callendrier callendrier = new Callendrier(localDateTime.getDayOfMonth(), annee, localDateTime.getMonthValue(), jour+"", idImmobilisation, getMoyenne(c,idImmobilisation).getMoyenne());
        A.insert(c, callendrier);
        c.commit();
    }

    public MoyenneUtilisation getMoyenne(Connection c, String immobilisation) throws Exception {
        MoyenneUtilisation m = new MoyenneUtilisation();
        m.setImmobilisationId(immobilisation);
        Integer jour = dateDebut.getDay();
        m.setJour(jour+"");
        return (MoyenneUtilisation) A.select(c, m).get(0);
    }
    public Boolean isHigher(Connection c, String idIm) throws Exception {
        MoyenneUtilisation m = getMoyenne(c, idIm);
        double difference = m.getMoyenne() - getTotalHours();
        if(difference < 0) return true;
        return false;
    }

    public double getTotalHours(){
        LocalDateTime debut = LocalDateTime.of(dateDebut.getYear(), dateDebut.getMonth(), dateDebut.getDay(), dateDebut.getHours(), dateDebut.getMinutes());
        LocalDateTime fin = LocalDateTime.of(dateFin.getYear(), dateFin.getMonth(), dateFin.getDay(), dateFin.getHours(), dateFin.getMinutes());
        return ChronoUnit.HOURS.between(debut, fin);
    }

    public List<Utilisation> nonValide(){
        List<Utilisation> retour = new ArrayList<>();
        for (Utilisation u : utilisations){
            if(u.getDateFin() == null){
                retour.add(u);
            }
        }
        return  retour;
    }
    public List<Utilisation> valide(){
        List<Utilisation> retour = new ArrayList<>();
        for (Utilisation u : utilisations){
            if(u.getDateFin() != null){
                retour.add(u);
            }
        }
        return  retour;
    }

    public List<Rapport> getRapportByUser(Connection c) throws Exception {
        List<Rapport> rapports = A.select(c, this);
        for(Rapport r: rapports) r.setUtilisations(c);
        return rapports;
    }

    public double avancement(){
        List<Utilisation> nonValide = valide();
        return (float) nonValide.size() * 100 / (float) utilisations.size();
    }

    public void setUtilisations(Connection c) throws Exception {
        Utilisation utilisation = new Utilisation();
        utilisation.setRapportId(this.id);
        this.utilisations = A.select(c, utilisation);
    }

    public List<Utilisation> getUtilisations() {
        return this.utilisations;
    }

    public Rapport(){}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getEmployeId() {
        return employeId;
    }

    public void setEmployeId(String employeId) {
        this.employeId = employeId;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
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
        System.out.println("date fin "+dateFin);
        this.setDateFin(Timestamp.valueOf(dateFin));
    }

    public Rapport(String employeId, String details, Timestamp dateDebut, Timestamp dateFin) {
        this.employeId = employeId;
        this.details = details;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
    }

    public Rapport(String employeId, String details, String dateDebut) {
        this.employeId = employeId;
        this.details = details;
        this.setDateDebut(dateDebut);
    }

    public void insererUtilisation(Connection c, String[] idTask, String idImmobilisation) throws Exception {
        List<Object> utilisationList = new ArrayList<>();
// String rapportId, String immobilisationId, String tacheId, Timestamp dateDebut
        for (String id : idTask){
            String sql = "select * from utilisations where immobilisation_id='"+idImmobilisation+"' and date_fin is null";
            List<Utilisation> utilisations = A.executeQuery(c, new Utilisation(), sql);
            if(utilisations.size() > 0) throw new Exception("Immobilisation en cours d'utilisation "
                    +utilisations.get(0).getImmobilisationId()+ " par "+utilisations.get(0).rapportId);
            utilisationList.add(new Utilisation(idImmobilisation, id, this.dateDebut, this.id));
        }
        A.insertList(c, utilisationList);
    }

    public void setDateDebut(String dateDebut) {
        dateDebut = dateDebut.replace("T", " ").concat(":00");
        this.setDateDebut(Timestamp.valueOf(dateDebut));
    }

    public Integer getSuspiceux() {
        return suspiceux;
    }

    public void setSuspiceux(Integer suspiceux) {
        this.suspiceux = suspiceux;
    }

    public void setUtilisations(List<Utilisation> utilisations) {
        this.utilisations = utilisations;
    }
}
