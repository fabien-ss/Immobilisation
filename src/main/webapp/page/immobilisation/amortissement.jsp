<%--
  Created by IntelliJ IDEA.
  User: fabien
  Date: 2/15/24
  Time: 2:42 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="java.sql.Connection" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Immobilisation" %>
<%@ page import="java.util.*" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Callendrier" %>
<%@ page import="dokotera.immobilisation.persistence.info.Utilisation" %>
<%@ page import="dokotera.immobilisation.persistence.info.Amortissement" %><%--
  Created by IntelliJ IDEA.
  User: fabien
  Date: 2/13/24
  Time: 11:06 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection c;
    List<Immobilisation> immobilisationList = new ArrayList<>();
    String error = null;
    Immobilisation target = new Immobilisation();
    List<Amortissement> amortissements = new ArrayList<>();
    try{
        c = new Connexion().enterToBdd();
        immobilisationList = A.select(c, new Immobilisation());
        if(request.getParameter("idImmobilisation") != null){
            String id = (request.getParameter("idImmobilisation"));
            String annee = request.getParameter("annee");
            String precision = request.getParameter("precision");
            target.setId(id);
            target = (Immobilisation) A.select(c, target).get(0);
            amortissements = target.getAmortissement(precision, annee);
        }
        c.close();
    }catch (Exception e){
        error = e.getMessage();
    }
%>
<!doctype html>
<html lang="en">
<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link href="https://fonts.googleapis.com/css?family=Roboto:300,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="./assets/fonts/icomoon/style.css">
    <link rel="stylesheet" href="./assets/css/owl.carousel.min.css">
    <link rel="stylesheet" href="./assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="./assets/css/style.css">
    <title>Table #6</title>
</head>
<body>

<div class="content">

    <div class="container">
        <div class="">
            <div class="">
                <div class="">
                    <form action="amortissement.jsp" method="post">
                        <label class="">Immobilisation</label>
                        <select name="idImmobilisation" class="form-select">
                            <% for (Immobilisation i : immobilisationList){%>
                            <option value=<%=i.getId()%>><%=i.getDescription()%></option>
                            <% } %>
                        </select>
                        <label>Nombre d'annjée</label>
                        <input type="number" class="form-control" name="annee">
                        <label>Type</label>
                        <select name="precision" class="form-select">
                            <option value="1">Linéaire</option>
                            <option value="2">Dégressif</option>
                        </select>
                        <input type="submit">
                    </form>
                </div>
            </div>
        </div>

        <div class="table-responsive">

            <table class="table table-striped custom-table">
                <thead>
                <tr>

                    <th scope="col">Période</th>
                    <th scope="col">Montant initial</th>
                    <th scope="col">Taux d'amortissement</th>
                    <th scope="col">Amortissement périodique</th>
                    <th scope="col">Amortissement cumulé</th>
                    <th scope="col">Valeur nette comptable</th>
                    <th scope="col"></th>
                </tr>
                </thead>
                <tbody>
                    <% for(Amortissement a: amortissements) {%>
                    <tr scope="row">
                        <td><%=a.getAnnee()%></td>
                        <td><%=a.getValeurBase()%></td>
                        <td><%=a.getTauxAmortissement()%></td>
                        <td><%=a.getAnnuiteAmortissement()%></td>
                        <td><%=a.getAmortissementCumule()%></td>
                        <td><%=a.getValeurNetteComptable()%></td>
                    </tr>
                    <%}%>
                </tbody>
            </table>
        </div>
    </div>

</div>



<script src="./assets/js/jquery-3.3.1.min.js"></script>
<script src="./assets/js/popper.min.js"></script>
<script src="./assets/js/bootstrap.min.js"></script>
<script src="./assets/js/main.js"></script>
</body>
</html>