<%@ page import="java.sql.Connection" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="dokotera.immobilisation.persistence.action.Rapport, java.util.*" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.action.Utilisation" %>
<%@ page import="dokotera.immobilisation.persistence.action.Tache" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Immobilisation" %><%--
  Created by IntelliJ IDEA.
  User: fabien
  Date: 2/13/24
  Time: 6:55 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection c = new Connexion().enterToBdd();
    Rapport rapport = new Rapport();
    rapport.setSuspiceux(1);
    List<Rapport> suspission = A.select(c, rapport);
    Immobilisation immobilisationdetails = null;
    List<Utilisation> utilisations = new ArrayList<>();
    if(request.getParameter("idRapport") != null){
        rapport.setId(request.getParameter("idRapport"));
        rapport = (Rapport) A.select(c, rapport).get(0);
        rapport.setUtilisations(c);
        Utilisation utilisation = new Utilisation();
        utilisation.setRapportId(rapport.getId());
        utilisations = A.select(c, utilisation);
        utilisation = utilisations.get(0);
        immobilisationdetails = new Immobilisation();
        immobilisationdetails.setId(utilisation.getImmobilisationId());
        immobilisationdetails = (Immobilisation) A.select(c, immobilisationdetails).get(0);
        if(request.getParameter("valider")!=null){
            rapport.setSuspiceux(0);
            rapport.updateCallendrier(c);
            rapport.setDetails(null);
        }else if(request.getParameter("moyenne") != null){
            rapport.setSuspiceux(0);
            rapport.updateCallendrierMoyenne(c);
            rapport.setDetails(null);
        }
    }

%>
<html>
<head>
    <title>Title</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Title</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../Header.jsp" />
    <div class="container">
        <ul class="list-group">
            <%if(suspission.size() > 0){%>
            <% for (Rapport r : suspission){ %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
                    <span><%= r.getDetails() %> </span>
                    <a href="anomalie.jsp?idRapport=<%=r.getId()%>"><%=r.getDateDebut()%></a>
                </li>
            <% } %>
            <% } else { %>
                Aucune anomalie
            <%}%>
        </ul>
    </div>
    <% if (rapport.getDetails() != null) { %>
    <div class="container shadow mt-5" style="padding: 0%">
        <div class="card">
            <div class="card-header" >Détails</div>
            <div class="container card-body" style="display: flex;">
                <div class="col-6">
                    <div class="">
                        <section class="mt-4">
                            <h2>Rapport Details</h2>
                            <p><strong>Description:</strong> <%=rapport.getDetails()%></p>
                            <p><strong>Utilisation:</strong> <%=rapport.getTotalHours()%> heures</p>
                            <p><strong>Moyenne estimée:</strong> <%=rapport.getMoyenne(c, immobilisationdetails.getId()).getMoyenne()%></p>
                            <progress max="<%=rapport.getTotalHours()%>" style="background: crimson" value="<%=rapport.getTotalHours()%>" ></progress>
                            <progress max="<%=rapport.getTotalHours()%>" style="color: green" value="<%=rapport.getMoyenne(c, immobilisationdetails.getId()).getMoyenne()%>" ></progress>
                            <h2>Tâches:</h2>
                            <ul>
                                <% for (Utilisation u : rapport.getUtilisations()) { %>
                                <li><%=Tache.getTacheById(c, u.getTacheId()).getDescription()%></li>
                                <% } %>
                            </ul>
                        </section>

                        <section class="mt-4">
                            <h2>Utilisation</h2>
                            <ul>
                                <% for (Utilisation u : utilisations) { %>
                                <li>
                                    <%=u.getTache(c).getDescription()%>
                                    <%=u.getDateDebut()%>
                                    <%=u.getDateFin()%>
                                </li>
                                <% } %>
                            </ul>
                        </section>

                        <section class="mt-5">
                            <form action="anomalie.jsp" method="post">
                                <input type="hidden" name="idRapport" value="<%=rapport.getId()%>">
                                <button type="submit" name="valider" class="btn btn-primary">Mettre à jour</button>
                            </form>
                            <form action="anomalie.jsp" method="post">
                                <input type="hidden" name="idRapport" value="<%=rapport.getId()%>">
                                <button type="submit" name="moyenne" style="color: black" class="btn btn-danger">Continuer sur la moyenne</button>
                            </form>
                        </section>

                        <section class="">
                            <p>Contacter Responsable</p>
                        </section>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card-body">
                        <figure class="relative max-w-sm transition-all duration-300 cursor-pointer filter grayscale hover:grayscale-0">
                            <a href="#">
                                <img style="width: 500px; height: 250px;" class="rounded-lg" src="../images/<%=immobilisationdetails.getDescription().toLowerCase()%>.png" alt="image description">
                            </a>
                            <figcaption class="absolute px-4 text-lg text-white bottom-6">
                                <p><%=immobilisationdetails.getDescription()%></p>
                            </figcaption>
                        </figure>
                        <div class="mt-4">
                            <p><strong>Date d'Achat:</strong> <%=immobilisationdetails.getDateAchat()%></p>
                            <p><strong>Prix d'Achat:</strong> <%=immobilisationdetails.getPrixAchat()%></p>
                            <ul class="list-disc list-inside">
                                <% for(String[] ss : immobilisationdetails.splitDetails()) { %>
                                <li><%=ss[0].replace("_", " ")%>: <%=ss[1]%></li>
                                <% } %>
                            </ul>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </div>
    <% } %>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
<%
    c.close();
%>
