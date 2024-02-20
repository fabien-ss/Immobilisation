package dokotera.immobilisation.servlet;

import java.awt.*;
import java.io.*;
import java.sql.Connection;
import java.util.List;

import com.google.gson.Gson;
import dokotera.immobilisation.persistence.action.Tache;
import generic.base.Connexion;
import generic.kodro.A;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet(name = "tache", value = "/tache")
public class tacheServlet extends HttpServlet {
    private String message;

    public void init() {
        message = "Hello World!";
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Assuming you have a HttpServletResponse object named response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String immobilisationId = request.getParameter("immobilisationId");
        Tache tache = new Tache();
        Connection c = null;
        try {
            PrintWriter out = response.getWriter();
            c = new Connexion().enterToBdd();
            tache.setImmobilisationId(immobilisationId);
            List<Tache> tacheList = A.select(c, tache);
            Gson gson = new Gson();
            String json = gson.toJson(tacheList);
            out.println(json);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    public void destroy() {
    }
}