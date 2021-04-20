/**
 *  Controller for the custom
 *  lookup component to facilitate
 *  searching
 *  
 *  @author: PZ - Customertimes Corp.
 *  @created: 10.01.17
 */
public with sharing class EUR_CRM_LookupController {
    /* Initialize existing value SOQL*/
    @AuraEnabled
    public static List<SObject> getInitial(String objectAPIName, String rId){
        final String query = String.format(
            'SELECT Id,Name FROM {0} WHERE Id =:rId'
            , new List<String>{objectAPIName}
        );
        return Database.query(query);
    }
   /* Method to query records using SOSL*/
    @AuraEnabled
    public static String search(String objectAPIName, String searchText,
            List<String> whereClause, List<String> extrafields){

        objectAPIName = String.escapeSingleQuotes(objectAPIName);
        searchText = String.escapeSingleQuotes(searchText);
        String searchQuery = 'FIND \'' + searchText + '*\' IN ALL FIELDS RETURNING ' + objectAPIName + '(Id,Name' ;
        if(!extrafields.isEmpty()){
            searchQuery = searchQuery + ',' + String.join(extrafields, ',') ;
        }
      
        if(!whereClause.isEmpty()){
            searchQuery = searchQuery + ' WHERE ' ;
            searchQuery = searchQuery + String.join(whereClause, 'AND') ;
        }
        searchQuery = searchQuery + ' LIMIT 10 ) ';
        
        return JSON.serializePretty(search.query(searchQuery)) ;
    }

    /* Method to query records using SOQL*/
    @AuraEnabled
    public static List<SObject> getRecentlyViewed(
            String objectAPIName,
            List<String> whereClause,
            List<String> extrafields){

        String searchQuery = 'SELECT Id, Name';
        if(!extrafields.isEmpty()){
            searchQuery = searchQuery + ',' + String.join(extrafields, ',') ;
        }
        searchQuery = searchQuery + ' FROM ' + objectAPIName + ' WHERE LastViewedDate != NULL ';
        if(!whereClause.isEmpty()){
            searchQuery = searchQuery + ' AND ' ;
            searchQuery = searchQuery + String.join(whereClause, 'AND') ;
            
        }
        searchQuery = searchQuery + ' ORDER BY LastViewedDate DESC' ;
        List<SObject> objectList =  new List<SObject>();
        objectList = Database.query(searchQuery);
        return objectList;
    }
}