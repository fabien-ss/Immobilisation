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
<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../Header.jsp" />
    <div class="container">
        <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-12">
                <div class="card my-4 shadow">
                    <div class="card-header">
                        <h5 class="mb-0">Spécification</h5>
                    </div>
                    <div class="card-body">
                        <form action="amortir.jsp" method="post">
                            <div class="form-group">
                            <label class="">Immobilisation</label>
                            <select name="idImmobilisation"  class="form-control">
                                <% for (Immobilisation i : immobilisationList){%>
                                <option value=<%=i.getId()%>><%=i.getDescription()%></option>
                                <% } %>
                            </select>
                            </div>
                            <div class="form-group">
                            <label>Nombre d'année</label>
                                <input type="number" name="annee"  class="form-control">
                            </div>
                            <div class="form-group">
                            <label>Type</label>
                                <select name="precision" class="form-control">
                                    <option value="1">Linéaire</option>
                                    <option value="2">Dégressif</option>
                                </select>
                            </div>
                            <input type="submit" class="btn btn-primary">
                        </form>
                    </div>
                </div>
            </div>

        </div>
        <div class="row justify-content-center">
            <h3><%=target.getDateAchat()%></h3>
            <h3><%=target.getDescription()%></h3>
            <div class="table-responsive">
            <table class="table table-striped shadow">
                <thead class="thead-dark">
                <tr>
                    <th>Période</th>
                    <th>Montant initial</th>
                    <th>Taux d'amortissement</th>
                    <th>Amortissement périodique</th>
                    <th>Amortissement cumulé</th>
                    <th>Valeur nette comptable</th>
                </tr>
                </thead>
                <tbody>
                <% for(Amortissement a: amortissements) {%>
                <tr>
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
            <style>
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
                th, td {
                    border: 1px solid black;
                    padding: 8px;
                    text-align: center;
                }
                th {
                    background-color: #f2f2f2;
                }
            </style>
        </div>
    </div>
    </div>
</body>
</html>
