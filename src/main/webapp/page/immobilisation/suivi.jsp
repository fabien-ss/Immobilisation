<%@ page import="java.sql.Connection" %>
<%@ page import="dokotera.immobilisation.persistence.action.UtilisationEnCours, java.util.List" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.action.Utilisation" %>
<%@ page import="java.util.ArrayList" %>
<%--
  Created by IntelliJ IDEA.
  User: fabien
  Date: 2/13/24
  Time: 9:18 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection c;
    List<UtilisationEnCours> utilisationEnCours = new ArrayList<>();
    String error = null;
    try{
        c = new Connexion().enterToBdd();
        UtilisationEnCours u = new UtilisationEnCours();
        if(request.getParameter("modifier") != null){
            String utilisation = request.getParameter("idUtilisation");
            String fin = request.getParameter("finir");
            Utilisation utilisation1 = new Utilisation();
            utilisation1.setId(utilisation);
            Utilisation utilisation2 = new Utilisation();
            utilisation2.setDateFin(fin);
            A.update(c, utilisation1, utilisation2);
        }
        utilisationEnCours = u.obtenirListeEnCour(c, request.getParameter("dateFin"));
        c.commit();
    }catch (Exception e){
        error = e.getMessage();
    }
%>
<%@ page import="java.sql.Connection" %>
<%@ page import="dokotera.immobilisation.persistence.action.UtilisationEnCours, java.util.List" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.action.Utilisation" %>
<%@ page import="java.util.ArrayList" %>
<%--
  Created by IntelliJ IDEA.
  User: fabien
  Date:  2/13/24
  Time:  9:18 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Your Java logic here...
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Suivi des Utilisations en Cours</title>
    <!-- Add Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../Header.jsp" />
<div class="container">
    <h3 class="my-3">Filtrer les Utilisations</h3>
    <form action="suivi.jsp" method="post">
        <div class="form-group">
            <label for="dateFin">Status</label>
            <select name="dateFin" class="form-control" id="dateFin">
                <option value="1">Fini</option>
                <option value="0">En cours</option>
            </select>
        </div>
        <button type="submit" name="filtre" class="btn btn-primary">Appliquer le Filtre</button>
    </form>
</div>
<div class="container mt-4">
    <h3 class="my-3">Liste des Utilisations en Cours</h3>
    <table class="table table-striped">
        <thead>
        <tr>
            <th>Date début</th>
            <th>Détails</th>
            <th>Employé</th>
            <th>Immobilisation</th>
            <th>Date fin</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% for (UtilisationEnCours utilisation : utilisationEnCours) { %>
        <tr>
            <td><%=utilisation.getDateDebut()%></td>
            <td><%=utilisation.getDetails()%></td>
            <td><%=utilisation.getNom()%></td>
            <td><%=utilisation.getDescription()%></td>
            <td>
                <% if(utilisation.getDateFinImmobilisation() == null) { %>
                   <p style="color: #1025a8">En cours</p>
                <% } else { %>
                   <p style="color: yellowgreen">Fini</p>
                <% } %>
            </td>
            <td>
                <form action="suivi.jsp" method="post" class="form-inline">
                    <div class="form-group mr-2">
                        <input type="datetime-local" name="finir" class="form-control" value="<%=utilisation.getDateFinImmobilisation()%>">
                    </div>
                    <input type="hidden" name="idUtilisation" value="<%=utilisation.getId()%>">
                    <button type="submit" name="modifier" class="btn btn-sm btn-warning mb-2">Modifier</button>
                </form>

            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<% if (error != null) { %>
<div class="alert alert-danger mt-3" role="alert">
    <%= error %>
</div>
<% } %>

<!-- Add jQuery, Popper.js, and Bootstrap JS -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>