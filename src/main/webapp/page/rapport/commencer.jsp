<%@ page import="java.sql.Connection" %>
<%@ page import="dokotera.immobilisation.persistence.personne.Employe, java.util.List" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Immobilisation" %>
<%@ page import="dokotera.immobilisation.persistence.action.Rapport" %><%--
  Created by IntelliJ IDEA.
  User: fabien
  Date: 2/13/24
  Time: 9:19 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection c = null;
    List<Employe> employeList = new ArrayList<>();
    List<Immobilisation> immobilisations = new ArrayList<>();
    String error = null;
    try{
        c = new Connexion().enterToBdd();
        employeList = A.select(c, new Employe());
        immobilisations = A.select(c, new Immobilisation());
        if(request.getParameter("submit") != null){
            String employeId = request.getParameter("employeId");
            String immobilisationId = request.getParameter("immobilisationId");
            String details = request.getParameter("details");
            String dateDebut = request.getParameter("dateDebut");
            String[] taskId = request.getParameterValues("taskCheckbox[]");
            Rapport rapport = new Rapport(employeId, details, dateDebut);
            A.insert(c, rapport);
            rapport.insererUtilisation(c, taskId, immobilisationId);
        }
        c.commit();

        c.close();
    }catch (Exception e){
        error = e.getMessage();
        c.rollback();
    }
%>
<html>
<head>
    <title>Title</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Title</title>
    <!-- Add Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>

<jsp:include page="../Header.jsp" />
<div class="container">
    <div class="row justify-content-center">
        <div class="col-10">
            <div class="card my4 shadow">
                <div class="card-header">
                    Commencer une nouvelle tâche
                </div>
                <div class="card-body">
                    <form action="commencer.jsp" method="post" class="">
                        <div class="form-group">
                            <label for="employeId">Employé</label>
                            <select class="form-control" name="employeId" id="employeId">
                                <%for (Employe e: employeList) { %>
                                <option value="<%=e.getId()%>"><%=e.getNom()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="details">Détails</label>
                            <textarea class="form-control" name="details" id="details"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="dateDebut">Date début</label>
                            <input type="datetime-local" class="form-control" name="dateDebut" id="dateDebut">
                        </div>
                        <div class="form-group">
                            <label>Immobilisation</label>
                            <select class="form-control" name="immobilisationId" id="immobilisationSelect">
                                <%for (Immobilisation i: immobilisations) { %>
                                <option value="<%=i.getId()%>"><%=i.getDescription()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div id="tasksContainer"></div>
                        <button type="submit" name="submit" class="btn btn-primary">Valider</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<% if (error != null) { %>
<div class="alert alert-danger mt-3" role="alert">
    <%= error %>
</div>
<% } %>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        document.getElementById('immobilisationSelect').addEventListener('change', function(event) {
            // Clear the container
            document.getElementById('tasksContainer').innerHTML = '';

            var selectedImmobilisationId = event.target.value;
            fetch('http://localhost:8081/Immobilisation_war_exploded/tache?immobilisationId=' + selectedImmobilisationId)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(tasks => {
                    // Generate the checkboxes for each task
                    tasks.forEach(function(task) {
                        var checkbox = document.createElement('input');
                        checkbox.type = 'checkbox';
                        checkbox.id = task.id;
                        checkbox.name = 'taskCheckbox[]';
                        checkbox.value = task.id;

                        var label = document.createElement('label');

                        label.htmlFor = task.id;
                        label.className= "checkmark";
                        label.appendChild(document.createTextNode(task.description));

                        // Append the checkbox and label to the container
                        document.getElementById('tasksContainer').appendChild(checkbox);
                        document.getElementById('tasksContainer').appendChild(label);
                        document.getElementById('tasksContainer').appendChild(document.createElement('br'));
                    });
                })
                .catch(error => {
                    console.error('There has been a problem with your fetch operation:', error);
                });
        });
    </script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <style>
        /* Hide the default checkbox */
        .checkbox input[type="checkbox"] {
            position: absolute;
            opacity:  0;
            cursor: pointer;
        }

        /* Create a custom checkmark */
        .checkbox .checkmark {
            position: absolute;
            top:  0;
            left:  0;
            height:  20px;
            width:  20px;
            background-color: #eee;
        }

        /* On mouse-over, add a grey background color */
        .checkbox:hover input ~ .checkmark {
            background-color: #ccc;
        }

        /* When the checkbox is checked, add a blue background */
        .checkbox input:checked ~ .checkmark {
            background-color: #2196F3;
        }

        /* Create the checkmark/indicator (hidden when not checked) */
        .checkbox .checkmark:after {
            content: "";
            position: absolute;
            display: none;
        }

        /* Show the checkmark when checked */
        .checkbox input:checked ~ .checkmark:after {
            display: block;
        }

        /* Style the checkmark/indicator */
        .checkbox .checkmark:after {
            left:  7px;
            top:  3px;
            width:  5px;
            height:  10px;
            border: solid white;
            border-width:  0  3px  3px  0;
            transform: rotate(45deg);
        }

        /* Optional: Add a label to the checkbox */
        .checkbox label {
            position: relative;
            padding-left:  35px;
            cursor: pointer;
            font-size:  14px;
            user-select: none;
        }

    </style>
</body>
</html>
