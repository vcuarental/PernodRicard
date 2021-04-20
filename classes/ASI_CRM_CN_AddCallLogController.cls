public with sharing class ASI_CRM_CN_AddCallLogController {
        
    public ASI_CRM_AccountsAdditionalField__c AccountAdditional {get;set;}
    public ASI_CRM_Call_Log__c CallLog {get;set;}
    public string Type {get;set;}
    public string Msg {get;set;} 
    public boolean CloseWindow{get;set;} 
  
    
    public boolean InventoryInOutCheck { get { return CallLog.ASI_CRM_Inventory_IN_Out_Check__c=='Yes'; } set { CallLog.ASI_CRM_Inventory_IN_Out_Check__c = value? 'Yes':'No'; } }
    public boolean StockCheck { get { return CallLog.ASI_CRM_Stock_Check__c=='Yes'; } set { CallLog.ASI_CRM_Stock_Check__c = value? 'Yes':'No'; } }
    public boolean DiscussCompetiCloseWindowtorProduct { get { return CallLog.ASI_CRM_Discuss_Competitor_Product__c=='Yes'; } set { CallLog.ASI_CRM_Discuss_Competitor_Product__c = value? 'Yes':'No'; } }
    public boolean GMACheck { get { return CallLog.ASI_CRM_GMA_CHECK__c=='Yes'; } set { CallLog.ASI_CRM_GMA_CHECK__c = value? 'Yes':'No'; } }
    public boolean DataQualityCheck { get { return CallLog.ASI_CRM_Data_Quality_Check__c=='Yes'; } set { CallLog.ASI_CRM_Data_Quality_Check__c = value? 'Yes':'No'; } }
    public boolean DiscussBusiness { get { return CallLog.ASI_CRM_Discuss_Business__c=='Yes'; } set { CallLog.ASI_CRM_Discuss_Business__c = value? 'Yes':'No'; } }
    public boolean IncentivePayment { get { return CallLog.ASI_CRM_Incentive_Payment__c=='Yes'; } set { CallLog.ASI_CRM_Incentive_Payment__c = value? 'Yes':'No'; } }
    public boolean DailyBusiness { get { return CallLog.ASI_CRM_Daily_Business__c=='Yes'; } set { CallLog.ASI_CRM_Daily_Business__c = value? 'Yes':'No'; } }
    public boolean BusinessDevelopment { get { return CallLog.ASI_CRM_Business_Development__c=='Yes'; } set { CallLog.ASI_CRM_Business_Development__c = value? 'Yes':'No'; } }
    public boolean OfftakeCheck { get { return CallLog.ASI_CRM_Offtake_Check__c=='Yes'; } set { CallLog.ASI_CRM_Offtake_Check__c = value? 'Yes':'No'; } }
    public boolean RSPCheck { get { return CallLog.ASI_CRM_RSP_Check__c=='Yes'; } set { CallLog.ASI_CRM_RSP_Check__c = value? 'Yes':'No'; } }

    public ASI_CRM_CN_AddCallLogController(ApexPages.StandardController controller) {
     
        AccountAdditional = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
        
        CallLog = new ASI_CRM_Call_Log__c(ASI_CRM_AccountsAdditionalField__c=AccountAdditional.Id);
        CallLog.ASI_CRM_Visit_Date__c = system.today();
        Msg = null;
   
       
      
        
        Type = AccountAdditional.RecordType.DeveloperName=='ASI_CRM_CN_WS'?'WS': 
               AccountAdditional.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c=='On'?'On':
               AccountAdditional.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c=='Off'?'Off':
               '?';
        if(Type!='?') {
            RecordType rt = Global_RecordTypeCache.getRtRec('ASI_CRM_Call_Log__c'+
                (Type=='WS' ? 'ASI_CRM_CallLog_CN_WS' :
                Type=='On' ? 'ASI_CRM_CallLog_CN_ON' :
                Type=='Off' ? 'ASI_CRM_CallLog_CN_OFF' :
                ''));
            CallLog.RecordTypeId = rt.Id;
           
        }
    }
    
     public pagereference submit(){

        string errorMessage;
        Database.SaveResult insertResult = Database.insert(CallLog,false);
        system.debug('Result.......'+insertResult.isSuccess());
          if (!insertResult.isSuccess())
             {
            errorMessage = '';             
              for(Database.Error err : insertResult.getErrors())
              {
                errorMessage += (err.getMessage() + '  ');
                system.debug(errorMessage);
              }
                            
              ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, errorMessage);
              ApexPages.addmessage(errMsg);  
              CloseWindow = true;
              system.debug(errMsg);     
             }
             else{
              CloseWindow = false;
             }
           return null;
         }

 }