package dokotera.immobilisation.persistence.info;

import dokotera.immobilisation.persistence.objet.Immobilisation;
import generic.kodro.A;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Year;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class Amortissement {
    Integer dureeAmortissement;
    Integer dureeAmortissementInitiale;
    double valeurBase;
    double tauxAmortissement = 20;
    LocalDate dateDebut;
    LocalDate dateFin;
    Double amortissement;
    Double annuiteAmortissement;
    Integer annee;
    double amortissementCumule;

    double valeurNetteComptable;

    public static void main(String[] args) {
        LocalDate d1 = LocalDate.parse("2010-01-01");
        LocalDate d2 = LocalDate.parse("2010-07-01");
        System.out.println("1");
        System.out.println("2");
        System.out.println(Amortissement.getDayBetween(d1, d2));
    }
    public static int getDayBetween(LocalDate date1, LocalDate date2){
        int nombre = 0;
        while (date1.getDayOfYear() < date2.getDayOfYear()){
            if(date1.getDayOfMonth() <= 30){
                if(date1.getMonth().getValue() == 2 && date1.getDayOfMonth() == 28){
                    nombre += 3;
                    date1 = date1.plusMonths(1);
                    date1 = date1.withDayOfMonth(1);
                }else {
                    nombre += 1;
                    date1 = date1.plusDays(1);
                }
            }else {
                date1 = date1.plusMonths(1).withDayOfMonth(1);
            //    nombre += 1;
            }
        }
        return nombre;
    }

    public List<Amortissement> tableauAmortissementLineaire(){
        List<Amortissement> tableau = new ArrayList<>();
        dureeAmortissement = dureeAmortissement + 1;
        int anniversaire = Amortissement.getDayBetween(LocalDate.MIN.withYear(this.dateFin.getYear()), this.dateFin);
        int jourUtilisation = 0;
        int annee = 0;
        int dureeInitiale = dureeAmortissement;
        double cumulAmortissement = 0;
        while (dureeAmortissement > 0){
            LocalDate dateFinExercice = LocalDate.MAX.withYear(this.dateFin.getYear());
            jourUtilisation = (int) Math.abs(Amortissement.getDayBetween(this.dateFin, dateFinExercice));
            if(dureeAmortissement == 1) jourUtilisation = anniversaire;
            System.out.println("jour="+jourUtilisation);

            annee = (dureeInitiale - dureeAmortissement) + 1;
            Amortissement amortissement1 = ligneAmortissement(jourUtilisation, annee, cumulAmortissement, 360);
            cumulAmortissement = amortissement1.getAmortissementCumule();
            tableau.add(amortissement1);
            this.dateFin = this.dateFin.plusYears(1).withDayOfYear(1).withMonth(1);
            dureeAmortissement --;
        }
        return tableau;
    }


    public Amortissement ligneAmortissement(
            long jourUtilisation, int annee, double dernierAmortissement, int lengtYear
    ){
        Amortissement amortissement1 = new Amortissement();
        amortissement1.setAnnee(annee);
        amortissement1.setTauxAmortissement(getTauxAmortissement());
        amortissement1.setValeurBase(this.valeurBase);
        amortissement1.setAnnuiteAmortissement(this.valeurBase * (jourUtilisation / (float) lengtYear) * (getTauxAmortissement()/100));
        amortissement1.setAmortissementCumule(dernierAmortissement + amortissement1.getAnnuiteAmortissement());
        amortissement1.setValeurNetteComptable(this.valeurBase - amortissement1.getAmortissementCumule());
        return amortissement1;
    }

    public List<Amortissement> tableauAmortissementDegressif(){
        List<Amortissement> tableau = new ArrayList<>();
        dureeAmortissement = dureeAmortissement + 1;
        int anniversaire = Amortissement.getDayBetween(LocalDate.MIN.withYear(this.dateFin.getYear()), this.dateFin);
        int jourUtilisation = 0;
        int annee = 0;
        int dureeInitiale = dureeAmortissement;
        double cumulAmortissement = 0;
        while (dureeAmortissement > 0){
            LocalDate dateFinExercice = LocalDate.MAX.withYear(this.dateFin.getYear());
            jourUtilisation = (int) Math.abs(Amortissement.getDayBetween(this.dateFin, dateFinExercice));
            annee = (dureeInitiale - dureeAmortissement) ; // annee
           // if(dureeAmortissement == 1) jourUtilisation = anniversaire;
            Amortissement amortissement1 = ligneAmortissementDegressif(jourUtilisation, annee, cumulAmortissement);
            cumulAmortissement = amortissement1.getAmortissementCumule();
            tableau.add(amortissement1);
            this.dateFin = this.dateFin.plusYears(1).withDayOfYear(1).withMonth(1);
            dureeAmortissement --;
        }
        return tableau;
    }
    public Amortissement ligneAmortissementDegressif(
            long jourUtilisation, int annee, double dernierAmortissement
    ){
        Amortissement amortissement1 = new Amortissement();
        amortissement1.setAnnee(this.dureeAmortissementInitiale - annee);
        amortissement1.setValeurBase(Double.valueOf(this.valeurBase));
        double tauxDegressif = getTauxAmortissement() * getCoefficientDegressif();
        int dureeLineaire = (int) (1 / (tauxDegressif / 100));
        amortissement1.setTauxAmortissement(tauxDegressif);
        System.out.println(amortissement1.getAnnee() +" &"+ dureeLineaire);
        if(amortissement1.getAnnee() <= dureeLineaire){
            amortissement1.setAnnuiteAmortissement(this.valeurBase  / amortissement1.getAnnee());
        }else if(amortissement1.getAnnee() > dureeLineaire){
            if (jourUtilisation < 360) {
                amortissement1.setAnnuiteAmortissement(this.valeurBase * Math.ceil( (jourUtilisation/(float)30))/  12 * (tauxDegressif / 100));
            } else {
                amortissement1.setAnnuiteAmortissement(this.valeurBase * (tauxDegressif / (float) 100));
            }
        }//else if(amortissement1.getAnnee() < dureeLineaire){
        //    amortissement1.setAnnuiteAmortissement(this.valeurBase);
        //}
        amortissement1.setAmortissementCumule(dernierAmortissement + amortissement1.getAnnuiteAmortissement());
        amortissement1.setValeurNetteComptable(this.valeurBase - amortissement1.getAnnuiteAmortissement());
        // eto izy lasa 0
        this.setValeurBase(this.valeurBase - amortissement1.getAnnuiteAmortissement());
        return amortissement1;
    }

    double getCoefficientDegressif() {
        // =SI(DUREE>6;2,5;SI(OU(DUREE=3;DUREE=4);1,5;2))
        if (this.dureeAmortissementInitiale == 3 || this.dureeAmortissementInitiale == 4) {
            return 1.5;
        } else if (this.dureeAmortissementInitiale == 6 || this.dureeAmortissementInitiale == 5) {
            return 1.75;
        } else if (this.dureeAmortissementInitiale > 6) {
            return 2.5;
        }
        return 1;
    }

    public Integer getDureeAmortissementInitiale() {
        return dureeAmortissementInitiale;
    }

    public void setDureeAmortissementInitiale(Integer dureeAmortissementInitiale) {
        this.dureeAmortissementInitiale = dureeAmortissementInitiale;
    }

    public double getAmortissementCumule() {
        return amortissementCumule;
    }

    public void setValeurNetteComptable(double valeurNetteComptable) {
        this.valeurNetteComptable = valeurNetteComptable;
    }

    public double getValeurNetteComptable() {
        return valeurNetteComptable;
    }

    public void setAmortissementCumule(double amortissementCumule) {
        this.amortissementCumule = amortissementCumule;
    }

    public Integer getAnnee() {
        return annee;
    }

    public void setAnnee(Integer annee) {
        this.annee = annee;
    }

    public Integer getDureeAmortissement() {
        return dureeAmortissement;
    }

    public void setDureeAmortissement(Integer dureeAmortissement) {
        this.dureeAmortissement = dureeAmortissement;
    }

    public Double getTauxAmortissement() {
        return tauxAmortissement;
    }

    public void setTauxAmortissement(Double tauxAmortissement) {
        this.tauxAmortissement = tauxAmortissement;
    }

    public LocalDate getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDate dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDate getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDate dateFin) {
        this.dateFin = dateFin;
    }

    public Double getAmortissement() {
        return amortissement;
    }

    public void setAmortissement(Double amortissement) {
        this.amortissement = amortissement;
    }

    public double getValeurBase() {
        return valeurBase;
    }

    public void setValeurBase(double valeurBase) {
        this.valeurBase = valeurBase;
    }

    public void setTauxAmortissement(double tauxAmortissement) {
        this.tauxAmortissement = tauxAmortissement;
    }

    public Double getAnnuiteAmortissement() {
        return annuiteAmortissement;
    }

    public void setAnnuiteAmortissement(Double annuiteAmortissement) {
        this.annuiteAmortissement = annuiteAmortissement;
    }
}
