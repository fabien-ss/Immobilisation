package dokotera.immobilisation.persistence.objet;

import generic.annotation.C;
import generic.annotation.P;
import generic.base.Connexion;
import generic.kodro.A;

import java.sql.Connection;

@C(t = "type")
@P(s = "type_id_seq", l = 10, p = "T")
public class Type {
    @C(pk = true, c = "id")
    String id;
    @C(c = "label")
    String label;

    public Type(String label) {
        this.label = label;
    }

    public Type(){}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public static void main(String[] args) throws Exception {
        Connection c = new Connexion().enterToBdd();
        Type type = new Type("Electronique");
        A.insert(c, type);
        c.commit();
    }
}
