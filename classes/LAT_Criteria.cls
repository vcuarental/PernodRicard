/**
 * Used to construct criteria queries, compound selections, expressions, predicates, orderings.
 * @author: ercarval - topi
 */
public virtual class LAT_Criteria {
    public String query;
    public String soql;

    public List<SObject> queryResult;

    public class SearchException extends Exception {}

    public LAT_Criteria() {
        soql = '';
    }

    public LAT_Criteria(String query) {
        this();
        this.query = query;
        queryResult = new List<SObject>();
    }


    public String toSoqlString () {
        System.debug(soql);
        return ( soql != null && soql != '' ) ? query + ' where ' + soql : query;
    }

    public LAT_Criteria add (LAT_Junction junction) {

        if (junction == null || junction.toString() == '') {
            return this;
        }

        if (this.soql != null && this.soql != '') {
            this.soql += LAT_Restriction.andd(junction.toString());
            return this;
        }

        this.soql += junction.toString();
        return this;
    }

    public LAT_Criteria add ( LAT_Criteria criteria , String expression ) {

        if (expression == null || expression == '') return this;

        if (criteria.soql != null && soql != '') {
            criteria.soql += LAT_Restriction.andd( expression );
        } else {
            criteria.soql +=  expression;
        }
        return this;
    }

    public LAT_Criteria add ( String expression ) {
        return add(this, expression );
    }

    public LAT_Criteria addOr ( LAT_Criteria criteria , String expression ) {

        if (expression == null || expression == '') return this;

        if (criteria.soql != null && soql != '') {
            criteria.soql += LAT_Restriction.orr( expression );
        } else {
            criteria.soql +=  expression;
        }

        return this;
    }

    public LAT_Criteria addOr ( String expression ) {
        return addOr (this, expression );
    }

    public LAT_Criteria limitedBy ( Integer expression ) {
        if (expression == null) return this;
        this.soql += LAT_Restriction.addLimit(expression);
        return this;
    }

    public LAT_Criteria startingBy ( Integer expression ) {
        if (expression == null) return this;
        this.soql += LAT_Restriction.addOffset(expression);
        return this;
    }

    public LAT_Criteria orderingBy ( String expression ) {
        if (expression == null || expression == '') return this;
        this.soql += LAT_Restriction.orderBy(  expression);
        return this;
    }

    virtual
    public List<SObject> search() {

        try {

            String queryStr = this.toSoqlString();

            System.debug ('search [queryStr ' + queryStr + ']');

            queryResult = Database.query(queryStr);

        } catch (System.QueryException e) {
            System.debug ('search [e ' + e + ']');
            throw e;
        }

        return queryResult;
    }

    virtual
    public List<SObject> searchThrowable() {

        try {

            String queryStr = this.toSoqlString();

            System.debug ('\n\n\n [Criteria SQL] : \n\n ------------ \n' + queryStr);

            queryResult = Database.query(queryStr);

        } catch (System.QueryException e) {

            System.debug ('\n\n\n Exception : ' + e);
            throw e;
        }

        return queryResult;
    }
    
    virtual
    public SObject searchFirstResult() {

        List<SObject> results = search();

        if ( results.isEmpty()) throw new SearchException('List has no rows to assigment to instancce');

        return results.get(0);

    }
}