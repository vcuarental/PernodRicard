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
public class EUR_CRM_DE_TerritoryUpdateController{

    private ApexPages.StandardController controller;
    public EUR_CRM_DE_TerritoryUpdateController (ApexPages.StandardController controller) {
        this.controller = controller;
        
    } 

    public Pagereference massUpdateGermanyAccounts(){
        Pagereference pr = new Pagereference('/'+controller.getId());
        pr.setRedirect(true);
        try{
            String query = 'SELECT EUR_CRM_Prestige_Territory__c, EUR_CRM_Prestige_Territory__r.EUR_CRM_Territory_Owner__r.Name, EUR_CRM_Prestige_Territory__r.EUR_CRM_Territory_Owner__r.Id, Name, ID, EUR_CRM_Territory__c, OwnerID, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.id FROM EUR_CRM_Account__c ' +
            ' WHERE (EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c =  true '+
            ' OR EUR_CRM_Prestige_Territory__r.EUR_CRM_IsOwnerChanged__c =  true)' +
            ' AND eur_crm_country_code__c = \'DE\'';
            
            
            EUR_CRM_MassUpdateAccountOwner massUpdateAccountOwner = new EUR_CRM_MassUpdateAccountOwner(Query);
            Database.executeBatch(massUpdateAccountOwner);
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, label.EUR_CRM_BatchJobMessage));
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        return pr;
    }
    

    
}