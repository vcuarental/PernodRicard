public with sharing class ASI_CRM_CN_IssueMobile_Controller{
    public string strUserId {get;set;}
    public string locale_code {get;set;}
    public string ConsumerComplaint {get;set;}
    public string ConflictwithTrade {get;set;}
    public string Cointerfeit{get;set;}
    public string ExternalGMA {get;set;}
    public string ImageOutletExecution {get;set;}
    public string InternalGMA {get;set;}
    public string Lookalike {get;set;}
    public string Traceability {get;set;}
    public string Others {get;set;}
    public string TradeComplaint {get;set;}
    
    
    public id RTId {get;set;}
    public ASI_CRM_CN_IssueMobile_Controller(ApexPages.StandardController controller) {
        strUserId = UserInfo.getUserId();
        system.debug('UserId: ' + strUserId );
        
        List <User> user = [SELECT LanguageLocaleKey from User WHERE id = :strUserId];
        for (User a : user){
            locale_code = a.LanguageLocaleKey;
        }
        system.debug('LanguageLocaleKey: ' + locale_code);
        
        List <Recordtype> RT = [SELECT id, DeveloperName  from RecordType where SObjectType = 'ASI_CRM_Issue_Zone__c'];
        for (Recordtype b : RT){
            if (b.DeveloperName == 'ASI_CRM_CN_Consumer_Complaint'){
                ConsumerComplaint = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Conflict_with_Trade'){
                ConflictwithTrade = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Counterfeit'){
                Cointerfeit = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_External_GMA'){
                ExternalGMA = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Image_Outlet_Execution'){
                ImageOutletExecution = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Internal_GMA'){
                InternalGMA = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Look_alike'){
                Lookalike = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Traceability'){
                Traceability = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Others'){
                Others = b.id;
            }else if (b.DeveloperName == 'ASI_CRM_CN_Trade_Complaint'){
                TradeComplaint = b.id;
            }
        }
    }
   
}