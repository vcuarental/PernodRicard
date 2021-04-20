/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | SH Ho                                                                 
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | ASI_MFM_Settings__c                                                                                
|     - Description     | Validate existing ASI MFM Setting record
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 16/10/2018                                                                     
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                       
+-----------------------+------------------------------------------------------------------------------------+
*/
global without sharing class ASI_MFM_KR_PORCProcess_Validate implements Database.Batchable<sObject> ,Database.Stateful{
    
    public Set<Id> PlanLineIDSet {GET;SET;}{PlanLineIDSet= new Set<Id>();}
    private String InfoMesg='';
    private String Version='';
    public String FiscalYear='';
    public boolean hasError {set;get;}{hasError=false;}
    private Schema.SObjectType ObjType;

    private static Map<String, Integer> MonthMap = new Map<String, Integer>{
            '1' => 7,
            '2' => 8,
            '3' => 9,
            '4' => 10,
            '5' => 11,
            '6' => 12,
            '7' => 1,
            '8' => 2,
            '9' => 3,
            '10' => 4,
            '11' => 5,
            '12' => 6
    };

        
        
        global ASI_MFM_KR_PORCProcess_Validate(){
            system.debug('Test ENTER ASI_MFM_KR_PORCProcess_Validate WELCOME');
            ObjType = Schema.getGlobalDescribe().get('ASI_MFM_Settings__c');
            Version=[select id,ASI_MFM_KR_POReceiptClosing_DataVersion__c from ASI_MFM_Setting__c limit 1][0].ASI_MFM_KR_POReceiptClosing_DataVersion__c;                
            
            FiscalYear=getFiscalYear();
            
        }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Enter start Method ASI_MFM_KR_PORCProcess_Validate ');
        //Get All related ID Plan Line Items
        //choice 1: Get All Plan line
        List<ASI_MFM_Plan_Line_Item__c> ChangedPlanIdList= [select id from ASI_MFM_Plan_Line_Item__c where RecordType.DeveloperName LIKE 'ASI_MFM_KR%' and ( ASI_MFM_Plan__r.ASI_MFM_Status__c='Approved' or ASI_MFM_Plan__r.ASI_MFM_Status__c='Closed' ) ];
        
        //Choice 2: last modified date is this month
        
        
        PlanLineIDSet=(new Map<Id,ASI_MFM_Plan_Line_Item__c>(ChangedPlanIdList)).keySet();
        
        return Database.getQueryLocator([select Id,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.ASI_MFM_Email_Notification__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Plan__r.Name,Name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.Name,ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_AP_Type__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_AP_Code__r.ASI_MFM_A_P_Types__c,ASI_MFM_Total_Cost__c,ASI_MFM_PRPO_Needed__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c from ASI_MFM_Plan_Line_Item__c where RecordType.DeveloperName LIKE 'ASI_MFM_KR%' and id in : ChangedPlanIdList  order by ASI_MFM_Plan__c ]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //Get Data: 
        List<ASI_MFM_Plan_Line_Item__c> PlanLineList= scope;
                
        //Plan line id: list of po line/po receipt / payment 
        Map<ID, List<ASI_MFM_PO_Line_Item__c>> POlineMap = new Map<ID, List<ASI_MFM_PO_Line_Item__c>>();
        Map<ID, List<ASI_MFM_PO_Receipt_Item__c>> PORlineMap = new Map<ID, List<ASI_MFM_PO_Receipt_Item__c>>();
        Map<ID, List<ASI_MFM_Payment_Line_Item__c>> PaidlineMap = new Map<ID, List<ASI_MFM_Payment_Line_Item__c>>();
        
        // Get existing ASI MFM Setting record with queried plan
        List<ASI_MFM_Settings__c> MFMsettingList = new List<ASI_MFM_Settings__c>();
        
        Set<Id> PlanIDSet = new Set<id>();
        List<String> MapKeyList = new List<String>();
        for(ASI_MFM_Plan_Line_Item__c planline: PlanLineList){
            PlanIDSet.add(planline.ASI_MFM_Plan__c);
            
            //Construct Map Key based on Plan ID,Sub-Brand, AP Type ,Fiscal Year   'Map Key'='Name'+'Sub Brand'+ 'AP Type'+PR/PONeeded
            String Mapkey='';
            Mapkey=planline.ASI_MFM_Plan__c;
            if(planline.ASI_MFM_Sub_brand_Code__c!=null) Mapkey+= planline.ASI_MFM_Sub_brand_Code__c;
            if(planline.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c!=null)  Mapkey+= planline.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
            if(planline.ASI_MFM_PRPO_Needed__c){
                Mapkey+='Needed';
            }
            if(Mapkey != null && !Test.isRunningTest()){
                Mapkey=Mapkey.replace('&', '');
                Mapkey=Mapkey.replace('\'', '');
            }
            MapKeyList.add(MapKey);
        }
        
        if(PlanIDSet.size()>0){                          
            // Get ASI MFM Settings Data
            MFMSettingList = [Select id, ASI_MFM_Sub_brand__c, ASI_MFM_A_P_Type__c, ASI_MFM_PRPO_Needed__c, ASI_MFM_External_ID__c, ASI_MFM_Active__c from ASI_MFM_Settings__c where ASI_MFM_Plan__c IN: PlanIDSet];            
        }
        
        List<ASI_MFM_Settings__c> updateList = new List<ASI_MFM_Settings__c>();
        for(ASI_MFM_Settings__c setting: MFMSettingList){
            String extId = setting.ASI_MFM_External_ID__c;
            
            // Check if there is no MapKey matched of the ASI MFM Setting record, set 'Active' to false 
            if(!MapKeyList.contains(extId)){
                setting.ASI_MFM_Active__c = false;
                updateList.add(setting);
            }
        }                
        
        //Upsert
        List<Database.upsertResult> uResults = new List<Database.upsertResult>();
        
        try{
            uResults= database.upsert(updateList,ObjType.getDescribe().fields.getMap().get('ASI_MFM_External_ID__c'),false);
        }catch(exception e){
            InfoMesg=e.getMessage();
            hasError = true;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        if(hasError){
            
            ASI_MFM_ByPass_Setting.ErrorHandling('Batch Process has completed:'+InfoMesg,'ASI_MFM_KR_PORCProcess_Validate','Batch Process Failed!');
        }else{
            ASI_MFM_Setting__c updatedSetting =[select id,ASI_MFM_KR_PORC_Data_Last_Cal_Time__c from ASI_MFM_Setting__c limit 1][0];
            updatedSetting.ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now();
            update updatedSetting;
            
            /*
            //Success!
            user currentUser =[select id,Name,ASI_MFM_Permission_Sets__c,Email from user where id=:UserInfo.getUserId() ];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
            List<String> EmailList= new List<String>();
            EmailList.add('prasia.mobile@pernod-ricard.com');
            
            
            if(currentUser.ASI_MFM_Permission_Sets__c!=null && currentUser.ASI_MFM_Permission_Sets__c.contains('ASI_MFM_PO_Receipt_Closing_Process')){
                EmailList.add(currentUser.Email);
            }
            mail.setToAddresses(EmailList);
            mail.setReplyTo('prasia.mobile@pernod-ricard.comm');
            mail.setSenderDisplayName('PO Receipt Closing Processing');
            mail.setSubject('PO Receipt Closing Process Completed');
            string link=System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/ASI_MFM_KR_POReceiptClosing_Page2';
            String body = 'Please be noted that KR MFM PO Receipt Closing Batch Process Job has completed successfully.<br/> Please refer :'+link;// mail.setPlainTextBody('Please be noted that KR MFM PO Receipt Closing Batch Process Job has completed successfully.'+);
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			*/
        }
    }//end method: finish
    
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        
        Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        
        return Current_Fiscal_year;
    }
}