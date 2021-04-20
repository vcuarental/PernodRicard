/**
*   Controller for a VF page for Territory Owner Mass Update Account
*   Calls the affiliate specific batch file through TypeClass
*
*/

public without sharing class EUR_CRM_TerritoryUpdateController {
    private ApexPages.StandardController controller;
    private String countryCode; 
    public EUR_CRM_TerritoryUpdateController(ApexPages.StandardController controller) {
        if(!Test.isRunningTest()) {
            controller.addFields(new List<String>{'RecordType.developerName'});
        }
        this.controller = controller;
    }
    
    public PageReference massUpdateAccounts() {
        EUR_CRM_Territory__c territory = (EUR_CRM_Territory__c) this.controller.getRecord();
        
        //countryCode = territory.recordType.developerName.split('_')[1];    //Sid
        countryCode = [select DeveloperName from RecordType where Id =: territory.recordTypeId LIMIT 1][0].DeveloperName.split('_')[1];
        System.debug(countryCode);
        
        Pagereference pr = new Pagereference('/'+controller.getId());
        pr.setRedirect(true);
        
        try{
             String query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, OwnerId, EUR_CRM_Territory__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Off_Trade_Owner__c, EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c, EUR_CRM_Image_Level__c FROM EUR_CRM_Account__c' +
            ' WHERE EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c =  true '+
            ' AND eur_crm_country_code__c = ' + '\'' + countryCode + '\'';
            
            // Execute the specific batch 
            if(countryCode == 'MA'){
                System.debug(territory);
                EUR_CRM_MassUpdateMAAccountOwner massUpdateBatchFile = new EUR_CRM_MassUpdateMAAccountOwner(query);
                Database.executeBatch(massUpdateBatchFile); 
            } else if(countryCode == 'DK') {
                EUR_CRM_MassUpdateAccountOwner massUpdateBatchFile = new EUR_CRM_MassUpdateAccountOwner(query);
                Database.executeBatch(massUpdateBatchFile);
            }
            else if(countryCode == 'BG') {
                EUR_CRM_MassUpdateAccountOwner massUpdateBatchFile = new EUR_CRM_MassUpdateAccountOwner(query);
                Database.executeBatch(massUpdateBatchFile);
            }
            
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, label.EUR_CRM_BatchJobMessage));

        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        return pr;  
    }
}