/**
 *
 * @author Eduardo R Carvalho
 */
virtual
public class LAT_QueryMapping {
    public String fieldName {get; set;}
    public String value     {get; set;}

    public LAT_QueryMapping () {} //NOPMD

    public LAT_QueryMapping (String fieldName , String value) {
        this.fieldName = fieldName;
        this.value = value;
    }

    public LAT_QueryMapping ( String fieldName ) {
        this.fieldName = fieldName;
        this.value = '';
    }

    virtual
    public String getValue () {
        return value;
    }

    public Boolean getValueAsBoolean () {
        return value == null ? null : Boolean.valueOf(value);
    }
}