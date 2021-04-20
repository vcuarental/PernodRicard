/**
 * @author: Eduardo - @ercarval
 */
public class LAT_Restriction { // NOPMD
    static final String SINGLE_QUOTES       =   '\'' ;
    static final String EQUALS              =   ' = ' ;
    static final String ANDZ                =   ' and ' ;
    static final String ORZ                 =   ' or ' ;
    static final String LIKEZ               =   ' like ' ;
    static final String NOT_NULL            =   ' != null ' ;
    static final String IS_NULL             =   ' = null ' ;
    static final String IS_IN               =   ' in ' ;
    static final String IS_NOT_IN           =   ' not in ' ;
    static final String NOT_EQUALS          =   ' != ' ;
    static final String GREATER_THAN        =   ' > ' ;
    static final String GREATER_THAN_EQUALS =   ' >= ' ;
    static final String LESS_THAN           =   ' < ' ;
    static final String LESS_THAN_EQUALS    =   ' <= ' ;
    static final String LIMIT_RESTRICTION   =   ' limit ' ;
    static final String OFFSET_RESTRICTION   =   ' offset ' ;
    static final String ORDER_BY            =   ' order by ' ;

    public static String logicalOperator (String operator, String constrant) {
        if ( nullToEmpty(constrant) == '') return '';
        return  operator + constrant;
    }

    public static String constrantWithOutSingleQuotes (String fieldName
            , String value
            , String operator) {
        if (nullToEmpty(value) == '') return '';
        return fieldName + operator + value.replace ('"', '');
    }

    public static String constrant (String fieldName, String operator) {
        return fieldName + operator;
    }

    public static String constrant (String fieldName, String value, String operator) {

        value = nullToEmpty(value);
        if (value == '') return '';

        return fieldName + operator + SINGLE_QUOTES + String.escapeSingleQuotes( value ) + SINGLE_QUOTES;
    }

    public static String constrant (String fieldName, Integer value, String operator) {

        return fieldName + operator +   value ;
    }

    public static String constrant (String fieldName, Boolean value, String operator) {
        return fieldName + operator + value;
    }

    public static String eq (String fieldName, String value) {
        return constrant(fieldName, value , EQUALS);
    }

    public static String eq (String fieldName, Boolean value) {
        return constrant(fieldName, value , EQUALS);
    }

    public static String eq (String fieldName, Integer value) {
        return constrant(fieldName, value , EQUALS);
    }

    public static String eq (String fieldName, Double value) {
        return constrantWithoutSingleQuotes(fieldName, String.valueOf(value) , EQUALS);
    }

    public static String eq (String fieldName, LAT_QueryMapping mapping) {
        return constrant(mapping.fieldName, (String) mapping.getValue() , EQUALS);
    }

    public static String eq (LAT_QueryMapping mapping) {
        return constrant(mapping.fieldName, (String) mapping.getValue() , EQUALS);
    }

    public static String booleanEq (LAT_QueryMapping mapping) {
        return constrant(mapping.fieldName, mapping.getValueAsBoolean() , EQUALS);
    }

    public static String dateLiteralsEq(LAT_QueryMapping mapping) {
        return constrantWithoutSingleQuotes(mapping.fieldName, mapping.getValue(), EQUALS);
    }

    public static String notEq (String fieldName, String value) {
        return constrant(fieldName, value , NOT_EQUALS);
    }

    public static String notEq (String fieldName, Integer value) {
        return constrant(fieldName, value , NOT_EQUALS);
    }

    public static String notEq (LAT_QueryMapping mapping) {
        return constrant(mapping.fieldName, (String) mapping.getValue() , NOT_EQUALS);
    }

    public static String lt (String fieldName, String value) {
        return constrant(fieldName, value , LESS_THAN);
    }

    public static String lt (LAT_QueryMapping mapping) {
        return constrant(mapping.fieldName, (String) mapping.getValue() , LESS_THAN);
    }

    public static String lt (String fieldName, DateTime value) {
        String dateTimeValue = (value != null ? value.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT') : '');
        return  constrantWithOutSingleQuotes(fieldName, dateTimeValue , LESS_THAN);
    }

    public static String le (String fieldName, String value) {
        return  constrant(fieldName, value , LESS_THAN_EQUALS);
    }

    /**
     * @deprecated
     */
    public static String le (String fieldName, LAT_QueryMapping value) {
        return le(value);
    }

    public static String le (LAT_QueryMapping mapping) {
        return le (mapping.fieldName, (String) mapping.getValue());
    }

    public static String le (String fieldName, DateTime value) {
        String dateTimeValue = (value != null ? value.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT') : '');
        return  lessThanEqualsDateLiteral(fieldName, dateTimeValue );
    }

    public static String lessThanEqualsDateLiteral (String fieldName, String value) {
        return  constrantWithOutSingleQuotes(fieldName, value , LESS_THAN_EQUALS);
    }

    public static String gt (String fieldName, String value) {
        return  constrant(fieldName, value , GREATER_THAN);
    }

    public static String gt (LAT_QueryMapping mapping) {
        return  constrant(mapping.fieldName, mapping.getValue(), GREATER_THAN);
    }

    public static String gt (String fieldName, DateTime value) {
        String dateTimeValue = (value != null ? value.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT') : '');
        return  constrantWithOutSingleQuotes(fieldName, dateTimeValue , GREATER_THAN);
    }

    public static String ge (String fieldName, String value) {
        return  constrant(fieldName, value , GREATER_THAN_EQUALS);
    }

    public static String greaterThanEqualsDateLiteral (String fieldName, String value) {
        return  constrantWithOutSingleQuotes(fieldName, value , GREATER_THAN_EQUALS);
    }

    public static String greaterThanEqualsDateLiteral ( LAT_QueryMapping mapping) {
        return  greaterThanEqualsDateLiteral(mapping.fieldName, mapping.getValue());
    }

    public static String ge (String fieldName, LAT_QueryMapping mapping) {
        return  constrant(fieldName, mapping.getValue() , GREATER_THAN_EQUALS);
    }

    public static String ge (LAT_QueryMapping mapping) {
        return  constrant(mapping.fieldName, mapping.getValue() , GREATER_THAN_EQUALS);
    }

    public static String ge (String fieldName, DateTime value) {
        String dateTimeValue = (value != null ? value.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT') : '');
        return  greaterThanEqualsDateLiteral(fieldName, dateTimeValue );
    }

    public static String between ( String fieldName ,  DateTime lo, DateTime hi  ) {
        String lowFormatedDate =  ( lo != null ) ? lo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT') : '';
        String hightFormatedDate = ( hi != null ) ? hi.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT') : '';
        return  betweenDates(fieldName, lowFormatedDate, hightFormatedDate);
    }

    public static String betweenDates (String fieldName, String lo , String hi  ) {

        if ( (lo == null || lo == '') && (hi == null || hi == '') ) return '';

        if (lo == null || lo == '')
            return constrantWithOutSingleQuotes ( fieldName, hi ,   EQUALS);

        if (hi == null || hi == '')
            return constrantWithOutSingleQuotes ( fieldName, lo ,   EQUALS);

        return    constrantWithOutSingleQuotes (fieldName, lo , GREATER_THAN_EQUALS)
                  + andd ( constrantWithOutSingleQuotes (fieldName, hi , LESS_THAN_EQUALS) ) ;

    }

    public static String betweenDates (LAT_QueryMapping lo  , LAT_QueryMapping hi  ) {
        return betweenDates (lo.fieldName , lo.getValue() , hi.getValue());
    }

    public static String between (String fieldName, String lo , String hi ) {
        if ( (lo == null || lo == '') && (hi == null || hi == '') ) return '';
        if (lo == null || lo == '') return eq(fieldName, hi);
        if (hi == null || hi == '') return eq(fieldName, lo);

        return    constrant(fieldName, lo , GREATER_THAN_EQUALS)
                  + andd ( constrant(fieldName, hi , LESS_THAN_EQUALS) ) ;

    }

    public static String isLike (String fieldName, String value) {
        return    constrant(fieldName, value , LIKEZ);
    }

    public static String isLike (String fieldName, LAT_QueryMapping value) {
        return    constrant(fieldName, (String) value.getValue() , LIKEZ);
    }

    public static String eqOrLike ( LAT_QueryMapping mapping ) {
        return eqOrLike( mapping.fieldName, mapping.getValue() );
    }

    public static String eqOrLike (String fieldName, String value) {
        if (value == null) return '';

        if (value.indexOf('*') > -1) {
            return isLike(fieldName, value.replace ('*', '%'));
        }

        return eq (fieldName, value);
    }

    //@deprecated
    public static String isNotNull (String fieldName, String value) {
        return    constrant(fieldName, NOT_NULL);
    }

    public static String isNotNull (String fieldName) {
        return    constrant(fieldName, NOT_NULL);
    }

    /**
     * @deprecated
     */
    public static String isNull (String fieldName, String value) {
        return isNull(fieldName);
    }

    public static String isNull (String fieldName) {
        return constrant(fieldName, IS_NULL);
    }

    public static String isNull (LAT_QueryMapping mapping ) {
        return isNull( mapping.fieldName );
    }

    public static String isIn ( String fieldName ,  LAT_Criteria criteria) {
        String value = ( criteria.toSoqlString() != criteria.query ) ? '(' + criteria.toSoqlString() + ')'  : '' ;
        return constrantWithOutSingleQuotes (fieldName, value , IS_IN )  ;
    }

    public static String isNotIn ( String fieldName ,  LAT_Criteria criteria) {
        String value = ( criteria.toSoqlString() != criteria.query ) ? '(' + criteria.toSoqlString() + ')'  : '' ;
        return constrantWithOutSingleQuotes (fieldName, value , IS_NOT_IN )  ;
    }

    public static String isIn (LAT_QueryMapping mapping) {
        return    constrantWithOutSingleQuotes(mapping.fieldName
                                               , mapping.getValue()
                                               , IS_IN );
    }

    public static String isIn (LAT_QueryListMapping mapping) {
        return    isIn ( mapping.fieldName , mapping.getValues() );
    }

    public static String isIn (String fieldName, String[] values) {
        return    isIn (fieldName , convertArrayStringIntoInClause(values) );
    }

    public static String isIn (String fieldName, String values) {
        return    constrantWithOutSingleQuotes(fieldName, values , IS_IN );
    }

    public static String isInSubQuery (String fieldName, String subquery) {
        String value = subquery != null ? '(' + subquery + ')' : subquery;
        return    constrantWithOutSingleQuotes(fieldName, value , IS_IN );
    }

    public static String isNotIn (LAT_QueryMapping mapping) {
        return    isNotIn(mapping.fieldName , mapping.getValue());
    }

    public static String isNotIn (String fieldName, String[] values) {
        return    isNotIn (fieldName , convertArrayStringIntoInClause(values) );
    }

    public static String isNotIn (String fieldName, String values) {
        return    constrantWithOutSingleQuotes(fieldName, values , IS_NOT_IN );
    }

    public static String convertArrayStringIntoInClause (String[] values) {

        if (isNullOrEmpty(values)) {
            return null;
        }

        String value = '( ';
        Integer i = 0;
        for (String val : values) {
            if (val == null) continue;
            if (i > 0) value += ',';
            value += addStringInQuery(val);
            i++;
        }
        value += ' )';
        return value;
    }

    public static String andd ( String constrant ) {
        return logicalOperator(ANDZ, constrant);
    }

    public static String orr ( String constrant ) {
        return logicalOperator(ORZ, constrant);
    }

    public static String addLimit (Integer queryLimit) {
        return LIMIT_RESTRICTION + queryLimit;
    }

    public static String addOffset (Integer queryOffset) {
        return OFFSET_RESTRICTION + queryOffset;
    }

    public static String orderBy ( String expression ) {
        return ORDER_BY + expression;
    }

    @TestVisible
    private static String addStringInQuery (String value) {
        return SINGLE_QUOTES + String.escapeSingleQuotes(value) + SINGLE_QUOTES;
    }

    @TestVisible
    private static String nullToEmpty (String value) {
        return (value != null) ? value.trim() : '';
    }

    public static LAT_Junction disjunction() {
        return new LAT_Disjunction();
    }

    public static LAT_Junction conjunction() {
        return new LAT_Conjunction();
    }

    public static boolean isNullOrEmpty(List<Object> targetList) {
        return  targetList == null || targetList.isEmpty();
    }
}