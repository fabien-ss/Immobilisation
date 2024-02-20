<%@ page import="dokotera.immobilisation.persistence.action.Rapport" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="generic.base.Connexion, java.util.List" %>
<%@ page import="dokotera.immobilisation.persistence.action.Utilisation" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection c;
    c = new Connexion().enterToBdd();
    List<Utilisation> enCours = new ArrayList<>();
    Rapport rapport = new Rapport();
    String date = request.getParameter("date");
    double totalHeure = 0;
    Boolean high = false;
    double t = 0;
    if(request.getParameter("idRapport") != null) {
        String idRapport = request.getParameter("idRapport");
        rapport.setId(idRapport);
        rapport = (Rapport) A.select(c, rapport).get(0);
        rapport.setUtilisations(c);
        enCours = rapport.nonValide();
        rapport.setDateFin(date);
        totalHeure = rapport.getTotalHours();
        Utilisation u = rapport.getUtilisations().get(0);
        String id = u.getImmobilisationId();
       high = rapport.isHigher(c, id);
        t = rapport.getMoyenne(c, id).getMoyenne();
    }if(request.getParameter("valider")!=null){
        String idRapport = request.getParameter("idRapport");
        Rapport rapport1 = new Rapport();
        rapport1.setId(idRapport);
        Rapport rapport2 = new Rapport();
        rapport2.setDateFin(date);
        if(request.getParameter("details") != null){
            String details = request.getParameter("details");
            rapport2.setDetails(details);
            rapport2.setSuspiceux(1);
        }else {
            rapport1 = (Rapport) A.select(c, rapport1).get(0);
            rapport1.setDateFin(date);
            rapport1.updateCallendrier(c);
        }
        A.update(c, rapport1, rapport2);
        c.commit();
        response.sendRedirect("../utilisateur/tache.jsp");
    }
    c.close();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terminer Rapport</title>
    <!-- Add Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../Header.jsp" />
<div class="container">
    <h3 class="my-4">Etes-vous sûr de terminer ce strike?</h3>
    <h3>Durée <%=totalHeure%> heures</h3>
    <h4 class="mb-4"><%=enCours.size()%> sur <%=rapport.getUtilisations().size()%> en cours</h4>
    <%if(enCours.size() >  0){ %>
    <ul class="list-group mb-4">
        <%for (Utilisation e: enCours){ %>
        <li class="list-group-item"><%=e.getImmobilisationId()%> - <%=e.getTacheId()%></li>
        <% } %>
    </ul>
    <%}%>
    <form action="terminer.jsp" method="post" class="mb-4">
        <input type="hidden" name="date" value="<%=date%>">
        <input type="hidden" name="idRapport" value="<%=rapport.getId()%>">
        <%if(high){%>
        <div class="form-group">
            <label>La durée d'utilisation incohérente à la norme <%=totalHeure%> contre <%=t%>. Veuillez fournir une explication</label>
            <textarea name="details" class="form-control" rows="3"></textarea>
        </div>
        <%}%>
        <button type="submit" name="valider" class="">Valider</button>
    </form>
    <a href="../utilisateur/tache.jsp" class="btn btn-secondary">Annuler</a>
</div>

<!-- Add jQuery, Popper.js, and Bootstrap JS -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>

