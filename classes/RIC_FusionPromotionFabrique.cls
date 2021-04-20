global class RIC_FusionPromotionFabrique implements Database.Batchable<sObject>{
    List<Milestone1_Project__c> ListProjToUpdate = new List<Milestone1_Project__c>();
    id RIC_PromotionBrandCompanyAvecReprise_RecordType=Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('RIC - Promotion d\'une marque BC avec reprise').getRecordTypeId();
    id RIC_Promotion_fabrique_RecordType=Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('RIC - Promotion fabriquée').getRecordTypeId();
    id RIC_PER_PromotionBrandCompanyAvecReprise_RecordType=Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('PER - Promotion d\'une marque BC avec reprise').getRecordTypeId();
    id RIC_PER_Promotion_fabrique_RecordType=Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().get('PER - Promotion fabriquée').getRecordTypeId();
    global String query = 'select id,recordtypeid from Milestone1_Project__c where (recordtypeid =:RIC_PromotionBrandCompanyAvecReprise_RecordType or recordtypeid=:RIC_PER_PromotionBrandCompanyAvecReprise_RecordType)';
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator(query);  
        
    }
    global void execute(Database.BatchableContext BC, list<Milestone1_Project__c> Listproj){ 
         User currUser = [select id,BypassVR__c 
                         from user
                         where id=:UserInfo.getUserId()
                         limit 1];
        currUser.BypassVR__c = true;
        currUser.BypassWF__c=true;
        update currUser;
        for(Milestone1_Project__c proj: Listproj)
        {
            if(proj.recordtypeid==RIC_PromotionBrandCompanyAvecReprise_RecordType)
            {
                proj.recordtypeid=RIC_Promotion_fabrique_RecordType;
            }
            else if(proj.recordtypeid==RIC_PER_PromotionBrandCompanyAvecReprise_RecordType)
            {
                proj.recordtypeid=RIC_PER_Promotion_fabrique_RecordType;  
            }
            ListProjToUpdate.add(proj);
        }
        if(ListProjToUpdate!=null && ListProjToUpdate.size()>0)
        {
        update ListProjToUpdate;
            }
    }
    global void finish(Database.BatchableContext BC)
    {       
       User currUser = [select id,BypassVR__c 
                         from user
                         where id=:UserInfo.getUserId()
                         limit 1];
        currUser.BypassVR__c = false;
        update currUser; 
    }
}