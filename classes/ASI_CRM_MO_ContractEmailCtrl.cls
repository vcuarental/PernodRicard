public class ASI_CRM_MO_ContractEmailCtrl{
    public Id cid{get;set;}

    public list<ASI_CRM_Contract_Cost__c> getcontractCost(){
        list<ASI_CRM_Contract_Cost__c> cc = new list<ASI_CRM_Contract_Cost__c>();
        
        cc = [
                SELECT id, Name, ASI_CRM_Investment_Value__c, ASI_CRM_Investment_Value_Base__c, ASI_CRM_Payment_Schedule__c
                FROM ASI_CRM_Contract_Cost__c
                WHERE ASI_CRM_CN_Contract__c = :cid
            ];
        
        system.debug('--- cc' + cc);
        return cc;
    }
}