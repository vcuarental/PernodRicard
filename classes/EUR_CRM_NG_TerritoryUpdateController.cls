/* Controller for a dummy page for Territory Owner Mass Update Account
  Initialization of datas//Checking if theres any Account Owner to be Updated before executing batch apex
-----
*/

public class EUR_CRM_NG_TerritoryUpdateController{

    private ApexPages.StandardController controller;
    public EUR_CRM_NG_TerritoryUpdateController (ApexPages.StandardController controller) {
        this.controller = controller;
    } 

    public Pagereference massUpdateNigeriaAccounts(){
        Pagereference pr = new Pagereference('/'+controller.getId());
        pr.setRedirect(true);
        try{
            /*String query = 'SELECT EUR_CRM_Prestige_Territory__c, EUR_CRM_Prestige_Territory__r.EUR_CRM_Territory_Owner__r.Name, EUR_CRM_Prestige_Territory__r.EUR_CRM_Territory_Owner__r.Id, Name, ID, EUR_CRM_Territory__c, OwnerID, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.id FROM EUR_CRM_Account__c ' +
            ' WHERE (EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c =  true '+
            ' OR EUR_CRM_Prestige_Territory__r.EUR_CRM_IsOwnerChanged__c =  true)' +
            ' AND eur_crm_country_code__c = \'NG\'';*/

             String query = 'SELECT Id, RecordTypeId, OwnerId, EUR_CRM_Territory__c, EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Off_Trade_Owner__c, EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c, EUR_CRM_Image_Level__c, EUR_CRM_RTDevName__c, EUR_CRM_Image_Level_Name__c, EUR_CRM_Territory_KD_Owner__c FROM EUR_CRM_Account__c' +
            ' WHERE EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c =  true '+
            ' AND eur_crm_country_code__c = \'NG\'';
            
            
            EUR_CRM_MassUpdateNGAccountOwner massUpdateAccountOwner = new EUR_CRM_MassUpdateNGAccountOwner(Query);
            Database.executeBatch(massUpdateAccountOwner);
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info, label.EUR_CRM_BatchJobMessage));
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        return pr;
    }
    

    
}