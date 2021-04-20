public with sharing class ASI_CRM_CustomLookupCtrl {
    
    @AuraEnabled
    public static List<LookupRecord> getRecordList(String objectName, 
                                                   String labelField, 
                                                   String sublabelField, 
                                                   List<String> filterFieldList, 
                                                   String searchKey,
                                                   String additionalFilterString,
                                                   Integer recordCount) {                                    

        List<LookupRecord> lookupRecordList = new List<LookupRecord>();
        
        if(String.isBlank(searchKey) || 
          	searchKey.length() < 2)
            return lookupRecordList;
                                                       
        String selectQuery = 'SELECT Id, '
            			   + labelField 
            			   + ' ';
        if(String.isNotBlank(sublabelField))
            selectQuery += ', ' + sublabelField + ' ';
            
        selectQuery += 'FROM ' + objectName + ' ';
        
        List<String> whereClauseList = new List<String>();
        
        if(filterFieldList.size() > 0) {                  
            List<String> filterFieldQueryStringList = new List<String>();                                               
            for(String filterField : filterFieldList) {
                filterFieldQueryStringList.add(filterField + ' LIKE \'%' + searchKey + '%\' ');	 	                                                  
            }
            String filterFieldQueryString = String.join(filterFieldQueryStringList, ' OR ');
            whereClauseList.add(' (' + filterFieldQueryString + ') ');    
        }
        
        if(String.isNotBlank(additionalFilterString))                                               
        	whereClauseList.add(additionalFilterString);
                                                       
        if(whereClauseList.size() > 0)
        	selectQuery += 'WHERE ' + String.join(whereClauseList, ' AND ') + ' ';   
        
        selectQuery += 'ORDER BY Id LIMIT ' + recordCount;                                              
                     
        for(sObject obj : Database.query(selectQuery)) {
            String sublabel = '';
            
            if(String.isNotBlank(sublabelField) && obj.get(sublabelField) != null)
            	sublabel = obj.get(sublabelField).toString();
            
        	lookupRecordList.add(new LookupRecord(obj.get(labelField).toString(),
                                                  sublabel,
                                                  obj.get('id').toString()));                                                   
        }                      
                                                       
        return lookupRecordList;                                               
    }
    
    public class LookupRecord {
        @AuraEnabled 
        public String label;
        @AuraEnabled
        public String sublabel;
        @AuraEnabled
        public String value;
        
        public LookupRecord(String label, String sublabel, String value) {
            this.label    = label;
            this.sublabel = sublabel;
            this.value    = value;
        }
    }

}