<%@ page import="java.sql.Connection" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Immobilisation" %>
<%@ page import="java.util.*" %>
<%@ page import="generic.base.Connexion" %>
<%@ page import="generic.kodro.A" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Callendrier" %>
<%@ page import="dokotera.immobilisation.persistence.info.Utilisation" %>
<%@ page import="dokotera.immobilisation.persistence.info.Amortissement" %>
<%@ page import="dokotera.immobilisation.persistence.objet.Type" %><%--
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
    String json = "[]";
    Immobilisation target = new Immobilisation();
    Utilisation utilisation = new Utilisation();
    String[] dateToDisplay = new String[2];
    boolean showAmmort = false;
    List<Amortissement> amortissements = new ArrayList<>();
    List<Type> types = new ArrayList<>();
    try{
        c = new Connexion().enterToBdd();
        immobilisationList = A.select(c, new Immobilisation());
        types = A.select(c, new Type());
        if(request.getParameter("idIm") != null){
            Callendrier callendrier = new Callendrier();
            callendrier.setImmobilisationId(request.getParameter("idIm"));
            json = callendrier.getJsonList(c);
            target.setId(request.getParameter("idIm"));
            target = (Immobilisation) A.select(c, target).get(0);
            utilisation.setImmobilisationId(request.getParameter("idIm"));
            dateToDisplay = utilisation.jsonFormat(c);
        }
        if(request.getParameter("insertion") != null){
            // description, String dateAchat, String typeId, String details, String prixAchat
            Immobilisation immobilisation = new Immobilisation(request.getParameter("description"),
                    request.getParameter("dateAchat"), request.getParameter("type"), request.getParameter("details"), request.getParameter("prixAchat"));
            A.insert(c, immobilisation);
            c.commit();
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
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            var calendar = new FullCalendar.Calendar(calendarEl, {
                weekday: false,
                weekends: false,
                initialView: 'dayGridMonth',
                events: <%=json%>,
                eventClick: function(info) {
                    console.log("info ", info);
                    alert('Utilisateur: ' + info.event._def.extendedProps.employe.nom + ", "+info.event._def.extendedProps.employe.id);
                }
            });
            calendar.render();
        });
    </script>
</head>
<jsp:include page="../Header.jsp" />
<body>
<div class="container">
    <div class="row">
        <div class="col">
            <ul class="list-group shadow">
                <li class="list-group-item active">Immobilisation</li>
                <% int y=0; for (Immobilisation i : immobilisationList) { %>
                <li class="list-group-item">
                    <%= i.getDescription() %>
                    <span class="float-right">
                        <a href="liste.jsp?idIm=<%=i.getId()%>&idAmort=1&indexImm=<%=y%>" class="btn btn-primary">Utilisation</a>
                    </span>
                </li>
                <%  y += 1;} %>
            </ul>
        </div>
        <div class="col">
            <div class="card">
                <div class="card-header">Enregistrer immobilisation</div>
                <div class="card-body">
                    <form action="liste.jsp" method="post">
                    <label>Description</label>
                    <input type="text" name="description" class="form-control">
                    <label>Date achat</label>
                    <input type="date" name="dateAchat" class="form-control">
                    <label>Détails</label>
                    <textarea name="details" class="form-control"></textarea>
                    <label>Prix</label>
                    <input name="prixAchat" type="number" class="form-control">
                    <label>Type</label>
                    <select name="type" class="form-control">
                        <%for(Type t: types){%>
                            <option value="<%=t.getId()%>"><%=t.getLabel()%></option>
                        <%}%>
                    </select> <br>
                    <input type="submit" name="insertion" class="btn btn-primary">
                    </form>
                </div>
            </div>
        </div>
    </div>

</div>

<%if(target.getDescription() != null){%>
<div class="container mx-auto px-4 sm:px-6 lg:px-8">
    <div class="py-8">
        <div class="bg-white shadow rounded-lg">
            <div class="p-6">
                <h3 class="text-2xl font-bold text-gray-700">Description: <%=target.getDescription()%></h3>
                <h3 class="text-xl font-semibold text-gray-600">Achat: <%=target.getDateAchat()%></h3>
                <% List<String[]> details = target.splitDetails(); %>
                <ul>
                    <% for(String[] ss : details ) { %>
                    <li><%=ss[0].replace("_", " ")%>: <%=ss[1]%></li>
                    <% } %>
                </ul>
            </div>
        </div>
    </div>
</div>
<%}%>
<div class="container mt-3">
    <div id="calendar"></div>
</div>

<% if (error != null) { %>
<div class="alert alert-danger mt-3 row" role="alert">
    <%= error %>
</div>
<% } %>
<div>
    <div class="container mt-5">
        <div id="bar-chart"></div>
    </div>

    <script>
        // ApexCharts options and config
        window.addEventListener("load", function() {
            var options = {
                series: [
                    {
                        name: "Income",
                        color: "#31C48D",
                        data: [<%=dateToDisplay[0]%>],
                    }
                ],
                chart: {
                    sparkline: {
                        enabled: false,
                    },
                    type: "bar",
                    width: "100%",
                    height: 400,
                    toolbar: {
                        show: false,
                    }
                },
                fill: {
                    opacity: 1,
                },
                plotOptions: {
                    bar: {
                        horizontal: true,
                        columnWidth: "100%",
                        borderRadiusApplication: "end",
                        borderRadius: 6,
                        dataLabels: {
                            position: "top",
                        },
                    },
                },
                legend: {
                    show: true,
                    position: "bottom",
                },
                dataLabels: {
                    enabled: false,
                },
                tooltip: {
                    shared: true,
                    intersect: false,
                    formatter: function (value) {
                        return "" + value
                    }
                },
                xaxis: {
                    labels: {
                        show: true,
                        style: {
                            fontFamily: "Inter, sans-serif",
                            cssClass: 'text-xs font-normal fill-gray-500 dark:fill-gray-400'
                        },
                        formatter: function(value) {
                            return "" + value
                        }
                    },
                    categories: [<%=dateToDisplay[1]%>],
                    axisTicks: {
                        show: false,
                    },
                    axisBorder: {
                        show: false,
                    },
                },
                yaxis: {
                    labels: {
                        show: true,
                        style: {
                            fontFamily: "Inter, sans-serif",
                            cssClass: 'text-xs font-normal fill-gray-500 dark:fill-gray-400'
                        }
                    }
                },
                grid: {
                    show: true,
                    strokeDashArray: 4,
                    padding: {
                        left: 2,
                        right: 2,
                        top: -20
                    },
                },
                fill: {
                    opacity: 1,
                }
            }

            if(document.getElementById("bar-chart") && typeof ApexCharts !== 'undefined') {
                const chart = new ApexCharts(document.getElementById("bar-chart"), options);
                chart.render();
            }
        });
    </script>

    <div class="container">

        <div class="max-w-sm w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6">
            <div class="flex justify-between">
                <div>
                    <h5 class="leading-none text-3xl font-bold text-gray-900 dark:text-white pb-2">32.4k</h5>
                    <p class="text-base font-normal text-gray-500 dark:text-gray-400">Users this week</p>
                </div>
                <div
                        class="flex items-center px-2.5 py-0.5 text-base font-semibold text-green-500 dark:text-green-500 text-center">
                    12%
                    <svg class="w-3 h-3 ms-1" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 14">
                        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13V1m0 0L1 5m4-4 4 4"/>
                    </svg>
                </div>
            </div>
            <div id="area-chart2"></div>
            <div class="grid grid-cols-1 items-center border-gray-200 border-t dark:border-gray-700 justify-between">
                <div class="flex justify-between items-center pt-5">
                    <!-- Button -->
                    <button
                            id="dropdownDefaultButton"
                            data-dropdown-toggle="lastDaysdropdown"
                            data-dropdown-placement="bottom"
                            class="text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-900 text-center inline-flex items-center dark:hover:text-white"
                            type="button">
                        Last 7 days
                        <svg class="w-2.5 m-2.5 ms-1.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 4 4 4-4"/>
                        </svg>
                    </button>
                    <!-- Dropdown menu -->
                    <div id="lastDaysdropdown" class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700">
                        <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdownDefaultButton">
                            <li>
                                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Yesterday</a>
                            </li>
                            <li>
                                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Today</a>
                            </li>
                            <li>
                                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 7 days</a>
                            </li>
                            <li>
                                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 30 days</a>
                            </li>
                            <li>
                                <a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Last 90 days</a>
                            </li>
                        </ul>
                    </div>
                    <a
                            href="#"
                            class="uppercase text-sm font-semibold inline-flex items-center rounded-lg text-blue-600 hover:text-blue-700 dark:hover:text-blue-500  hover:bg-gray-100 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700 px-3 py-2">
                        Users Report
                        <svg class="w-2.5 h-2.5 ms-1.5 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 6 10">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 9 4-4-4-4"/>
                        </svg>
                    </a>
                </div>
            </div>
        </div>

    </div>
    <script>

        const options = {
            chart: {
                height: "100%",
                maxWidth: "100%",
                type: "area",
                fontFamily: "Inter, sans-serif",
                dropShadow: {
                    enabled: false,
                },
                toolbar: {
                    show: false,
                },
            },
            tooltip: {
                enabled: true,
                x: {
                    show: false,
                },
            },
            fill: {
                type: "gradient",
                gradient: {
                    opacityFrom: 0.55,
                    opacityTo: 0,
                    shade: "#1C64F2",
                    gradientToColors: ["#1C64F2"],
                },
            },
            dataLabels: {
                enabled: false,
            },
            stroke: {
                width: 6,
            },
            grid: {
                show: false,
                strokeDashArray: 4,
                padding: {
                    left: 2,
                    right: 2,
                    top: 0
                },
            },
            series: [
                {
                    name: "New users",
                    data: [6500, 6418, 6456, 6526, 6356, 6456],
                    color: "#1A56DB",
                },
            ],
            xaxis: {
                categories: ['01 February', '02 February', '03 February', '04 February', '05 February', '06 February', '07 February'],
                labels: {
                    show: false,
                },
                axisBorder: {
                    show: false,
                },
                axisTicks: {
                    show: false,
                },
            },
            yaxis: {
                show: false,
            },
        }

        if (document.getElementById("area-chart2") && typeof ApexCharts !== 'undefined') {
            const chart = new ApexCharts(document.getElementById("area-chart2"), options);
            chart.render();
        }

    </script>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.2.1/flowbite.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
<!-- Add jQuery, Popper.js, and Bootstrap JS -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</body>
</html>
