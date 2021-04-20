/**
 * VO para lista
 * @author : Eduardo R Carvalho
 */
public class LAT_QueryListMapping extends LAT_QueryMapping {

    public LAT_QueryListMapping(String field) {
        super(field);
    }

    private List<String> values;

    public List<String> getValues() {
        return values;
    }

    public void setValues (List<String> values) {
        this.values = values;
    }
}