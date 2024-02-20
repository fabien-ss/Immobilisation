<%@ page import="java.sql.Connection" %>
<%@ page import="dokotera.immobilisation.persistence.personne.Employe" %>
<%@ page import="java.util.*" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="dokotera.immobilisation.persistence.action.Rapport" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.action.Tache" %>
<%@ page import="dokotera.immobilisation.persistence.action.Utilisation" %><%--
  Created by IntelliJ IDEA.
  User: fabien
  Date: 2/13/24
  Time: 5:19 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection c;
    List<Employe> employeList = new ArrayList<>();
    List<Rapport> rapports = new ArrayList<>();
    double avancement = 0;
    String error = null;
    try{
        c = new Connexion().enterToBdd();
        employeList = new Employe().obtenirEmployeEnTravaillant(c);
        if(request.getParameter("modifier") != null){
            String utilisation = request.getParameter("idUtilisation");
            String fin = request.getParameter("finir");
            Utilisation utilisation1 = new Utilisation();
            utilisation1.setId(utilisation);
            Utilisation utilisation2 = new Utilisation();
            utilisation2.setDateFin(fin);
            utilisation2.checkDuree(utilisation, c);
            A.update(c, utilisation1, utilisation2);
            c.commit();
        }
        if(request.getParameter("idEmploye") != null){
            Rapport r = new Rapport();
            r.setEmployeId(request.getParameter("idEmploye"));
            rapports = r.getRapportByUser(c);
          //  avancement = r.avancement();
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
        <div class="row">
            <div class="col">
                <ul class="list-group shadow">
                    <li class="list-group-item active">Employes</li>
                    <% for (Employe e : employeList) { %>
                    <li class="list-group-item">
                        <%= e.getNom() %> <%= e.getPrenom() %>
                        <span class="float-right">
                            <a href="tache.jsp?idEmploye=<%= e.getId() %>">View Tasks</a>
                        </span>
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <%for (Rapport r : rapports){%>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-4">
                    <div class="card my-4 shadow">
                        <div class="card-header">
                            <h5 class="mb-0">Terminer le rapport</h5>
                        </div>
                        <div class="card-body">
                            <p class="card-text"><%=r.getDetails()%></p>
                            <p><%=r.avancement()%>%</p>
                            <progress max="100" value="<%=r.avancement()%>" class="w-100"></progress>
                            <p class="card-text"><%=r.getDateDebut()%></p>
                            <form action="../rapport/terminer.jsp" method="post">
                                <div class="form-group">
                                    <label for="date">Date de fin</label>
                                    <input type="datetime-local" class="form-control" id="date" name="date">
                                </div>
                                <input type="hidden" value="<%=r.getId()%>" name="idRapport">
                                <button type="submit" name="Repporter" class="btn btn-primary">Marquer comme terminé</button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="col-md-8 mt-3">
                    <div class="table-responsive">
                        <table class="table table-striped shadow">
                            <thead class="thead-dark">
                            <tr>
                                <th>Details</th>
                                <th>Debut</th>
                                <th>Action</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (Utilisation u : r.getUtilisations()) { %>
                            <tr>
                                <td><%=u.getImmobilisationId()%></td>
                                <td><%=u.getDateDebut()%></td>
                                <td>
                                    <% if(u.getDateFin() == null) { %>
                                    <form action="tache.jsp" method="post" class="form-inline">
                                        <input type="datetime-local" class="form-control mr-2" name="finir">
                                        <input type="hidden" name="idUtilisation" value="<%=u.getId()%>">
                                        <input type="hidden" name="idEmploye" value="<%=r.getEmployeId()%>">
                                        <button type="submit" name="modifier" class="btn btn-primary">Modifier</button>

                                    </form>
                                    <% } else { %>
                                    <span class="text-success">Fini</span>
                                    <% } %>
                                </td>

                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>


        <% } %>
    </div>
<%if(error != null){%>
<div class="alert alert-danger">
    <%=error%>
</div>
<%}%>
    <style>

    </style>
    <!-- Add jQuery, Popper.js, and Bootstrap JS -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>

</html>
