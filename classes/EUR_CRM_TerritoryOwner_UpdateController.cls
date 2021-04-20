/* Controller for a dummy page for Territory Owner Mass Update Account
  Initialization of datas//Checking if theres any Account Owner to be Updated before executing batch apex
-----
update 4/23/2014
- added a new functionality where it can filter the
  the territories to specific country(ies)
  countryfilter - filter all account where account country code is in the filter
  includeRecordType - filter all account where account recordtype in the filter
  excludeRecordType - filter all account where account recordtype not in the filter
  extraQueryFilter - additional paramter filter if there are extra filter/special cases

*/
public class EUR_CRM_TerritoryOwner_UpdateController {

    public String countryFilter{get;set;}
    public String excludeRecordTypesFilter{get;set;}
    public String includeRecordTypesFilter{get;set;}
    public String extraQueryFilter{get;set;}

    public EUR_CRM_TerritoryOwner_UpdateController() 
    {    
        
    }
    
    // Function to execute batch apex for Owner Mass Update of Accounts (query string initialization)
    public void executeMassAccountOwnerUpdate()
    {
        try{
            String query = 'SELECT Name, ' +
                'RecordType.DeveloperName, Id, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.ManagerId, ' +
                'EUR_CRM_Territory__c, OwnerID, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, ' +
                'EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.Id ' +
                'FROM EUR_CRM_Account__c ' +
                'WHERE (EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c =  true ';
            
            if(countryFilter != null && countryFilter != ''){
                query += ' AND eur_crm_country_code__c in ('+ format(countryFilter) +')';
            }
            if(excludeRecordTypesFilter != null && excludeRecordTypesFilter != ''){ 
                query += ' AND recordType.developername not in ('+ format(excludeRecordTypesFilter) +')';
            }
            if(includeRecordTypesFilter != null && includeRecordTypesFilter != ''){ 
                query += ' AND recordType.developername in ('+ format(includeRecordTypesFilter) +')';
            }
            
            query += ')';
            if(extraQueryFilter != null && extraQueryFilter != ''){ 
                query += ' ' + extraQueryFilter;
            } 
                        system.debug ('query: ' + query);
            EUR_CRM_MassUpdateAccountOwner massUpdateAccountOwner = new EUR_CRM_MassUpdateAccountOwner(Query);
            Database.executeBatch(massUpdateAccountOwner);
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, label.EUR_CRM_BatchJobMessage));
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
    }
    
    private String format(String input){
         List<String> inputs = input.split(',');
         String filter = '';
         for(Integer i = 0 ; i < inputs.size() ; i++){
             filter += '\'' + inputs.get(i) + '\'';
             if(i < inputs.size() - 1){
                 filter += ',';
             }
         }
        return filter;
    }
    
}