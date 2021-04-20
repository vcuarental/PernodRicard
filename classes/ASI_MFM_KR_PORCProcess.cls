/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Elufa                                                                
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | ASI_MFM_Settings__c                                                                                
|     - Description     | For PO Receipt closing data                             
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 21/01/2017                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Related Informations  |          run  //database.executebatch(new ASI_MFM_KR_PORCProcess(),200);                                                                           
+-----------------------+------------------------------------------------------------------------------------+
*/


global without sharing class ASI_MFM_KR_PORCProcess implements Database.Batchable<sObject> ,Database.Stateful{
    
    public Set<Id> PlanLineIDSet {GET;SET;}{PlanLineIDSet= new Set<Id>();}
    private String InfoMesg='';
    private String Version='';
    public String FiscalYear='';
    public boolean hasError {set;get;}{hasError=false;}
    private Schema.SObjectType ObjType;
    //20170412, Elufa
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
            '12' => 6};
    //20170412, Elufa
    
    
    global ASI_MFM_KR_PORCProcess(){
        system.debug('Test ENTER ASI_MFM_KR_PORCProcess WELCOME');
        ObjType = Schema.getGlobalDescribe().get('ASI_MFM_Settings__c');
        Version=[select id,ASI_MFM_KR_POReceiptClosing_DataVersion__c from ASI_MFM_Setting__c limit 1][0].ASI_MFM_KR_POReceiptClosing_DataVersion__c;
        //select id,ASI_MFM_KR_POReceiptClosing_DataVersion__c from ASI_MFM_Setting__c
        
        // Added by 2018-04-26 Linus@introv
        FiscalYear=getFiscalYear();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('Enter start Method ASI_MFM_KR_PORCProcess ');
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
        
        Set<Id> PlanLineIDSet = new Set<id>();
        for(ASI_MFM_Plan_Line_Item__c planline: PlanLineList){
            PlanLineIDSet.add(planline.ID);
        }
        
        if(PlanLineIDSet.size()>0){
            List<ASI_MFM_PO_Line_Item__c> POlineList = new List<ASI_MFM_PO_Line_Item__c> ();
            List<ASI_MFM_PO_Receipt_Item__c> PORLineList = new List<ASI_MFM_PO_Receipt_Item__c> ();
            List<ASI_MFM_Payment_Line_Item__c> PaidLineList = new List<ASI_MFM_Payment_Line_Item__c> ();
            
            //Get PO Line Data 
            POlineList=[select Id,Name,ASI_MFM_Plan_Line_Item__c,CreatedDate,ASI_MFM_G_L_Date__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_Plan_Line_Item__c in:PlanLineIDSet and ASI_MFM_Plan_Line_Item__c !=null ];
            for(ASI_MFM_PO_Line_Item__c poline: POlineList){
                if(!POlineMap.containsKey(poline.ASI_MFM_Plan_Line_Item__c)){
                    List<ASI_MFM_PO_Line_Item__c> TempLine= new List<ASI_MFM_PO_Line_Item__c>();
                    TempLine.add(poline);
                    POlineMap.put(poline.ASI_MFM_Plan_Line_Item__c, TempLine);
                }else{
                    POlineMap.get(poline.ASI_MFM_Plan_Line_Item__c).add(poline);
                }
            }
            
            
            //Get PO Receipt Line Data
            PORLineList=[select Id,Name,CreatedDate,ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c,ASI_MFM_ACC_Verify__c,ASI_MFM_Remark__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.Name,ASI_MFM_Venue_Where__c,ASI_MFM_Venue_Where__r.Name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_AccountsAdditionalField__r.Name,ASI_MFM_Receipt_Amount_in_Local_Currency__c,ASI_MFM_Amount__c,ASI_MFM_Receipt_Date__c,ASI_MFM_PO_Line_Item__r.Name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_Plan_Line_Item__c in:PlanLineIDSet ];
            for(ASI_MFM_PO_Receipt_Item__c porline: PORLineList){
                if(!PORlineMap.containsKey(porline.ASI_MFM_Plan_Line_Item__c)){
                    List<ASI_MFM_PO_Receipt_Item__c> TempLine= new List<ASI_MFM_PO_Receipt_Item__c>();
                    TempLine.add(porline);
                    PORlineMap.put(porline.ASI_MFM_Plan_Line_Item__c, TempLine);
                }else{
                    PORlineMap.get(porline.ASI_MFM_Plan_Line_Item__c).add(porline);
                }
            }
            
            
            //get Payment line Data
            PaidLineList=[select Id,ASI_MFM_Plan_Line_Item__c,CreatedDate,ASI_MFM_Invoice_Date__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Paid_Amount_in_Base_Currency__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Plan_Line_Item__c in:PlanLineIDSet];
            for(ASI_MFM_Payment_Line_Item__c payline: PaidLineList){
                if(!PaidlineMap.containsKey(payline.ASI_MFM_Plan_Line_Item__c)){
                    List<ASI_MFM_Payment_Line_Item__c> TempLine= new List<ASI_MFM_Payment_Line_Item__c>();
                    TempLine.add(payline);
                    PaidlineMap.put(payline.ASI_MFM_Plan_Line_Item__c, TempLine);
                }else{
                    PaidlineMap.get(payline.ASI_MFM_Plan_Line_Item__c).add(payline);
                }
            }//end of for loop
        }
        
        
        
        Set<Id> POLineIdSet= new Set<Id>();
        
        Map<String,ASI_MFM_Settings__c> lineItemMap = new Map<String,ASI_MFM_Settings__c>();
        
        //Construct Map
        String Mapkey='';
        for(ASI_MFM_Plan_Line_Item__c planline: PlanLineList){
            Decimal TotalPOAmount=0;
            Decimal TotalPORAmount=0;
            Decimal TotalPaidAmount=0;
            //Construct Map Key based on Plan ID,Sub-Brand, AP Type ,Fiscal Year   'Map Key'='Name'+'Sub Brand'+ 'AP Type'+PR/PONeeded
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
            if(!lineItemMap.containsKey(Mapkey)){ //Not cantain in Map, insert into the Map
                
                lineItemMap.put(Mapkey, PlanLineInsert(Mapkey,planline));
            }else{
                ASI_MFM_Settings__c TempData=lineItemMap.get(Mapkey);
                lineItemMap.remove(Mapkey);
                for (Integer i = 1; i < 13; i++) {
                    String mapField = 'ASI_MFM_Month_' + i + '_Cost__c'; 
                    Decimal PLAmountTemp=TempData.get(mapField)!=null?(Decimal)TempData.get(mapField):0;
                    PLAmountTemp=PLAmountTemp+(planline.get(mapField)!=null?(Decimal)planline.get(mapField):0);
                    TempData.put(mapField,PLAmountTemp);
                }//End of for loop
                TempData.ASI_MFM_Plan_Line_ID__c+=';'+planline.Id;
                lineItemMap.put(Mapkey, TempData);
            }
            
            
            if(POlineMap.containsKey(planline.Id)){
                //PO line 
                for(ASI_MFM_PO_Line_Item__c pol:POlineMap.get(planline.Id)){
                    
                    
                    ASI_MFM_Settings__c TempData=lineItemMap.get(Mapkey);
                    lineItemMap.remove(Mapkey);
                    Integer MonthNumber=1;
                    if(pol.ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c!=null){
                        //MonthNumber=pol.ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c.month(); //20170412, Elufa
						MonthNumber=MonthMap.get(string.valueOf(pol.ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c.month())); //20170412, Elufa
                    }else{
                        //MonthNumber=pol.CreatedDate.month(); //20170412, Elufa
						MonthNumber=MonthMap.get(string.valueOf(pol.CreatedDate.month())); //20170412, Elufa
                    }
                    String mapField = 'ASI_MFM_Month_'+MonthNumber+ '_POAmount__c'; 
                    Decimal PLAmountTemp=TempData.get(mapField)!=null?(Decimal)TempData.get(mapField):0;
                    PLAmountTemp+=(Decimal)pol.ASI_MFM_Base_Currency_Amount__c;
                    TotalPOAmount+=(Decimal)pol.ASI_MFM_Base_Currency_Amount__c;
                    TempData.put(mapField,PLAmountTemp);
                    
                    TempData.ASI_MFM_PO_Line_ID__c+=';'+pol.Id;
                    lineItemMap.put(Mapkey, TempData);
                    
                }//End of PO line Id Set
            }
            
            
            if(PORlineMap.containsKey(planline.Id)){
                //PO Receipt line
                for(ASI_MFM_PO_Receipt_Item__c porl:PORlineMap.get(planline.Id)){
                    ASI_MFM_Settings__c TempData=lineItemMap.get(Mapkey);
                    lineItemMap.remove(Mapkey);
                    Integer MonthNumber=1;
                    if(porl.ASI_MFM_Receipt_Date__c!=null){
                        //MonthNumber=porl.ASI_MFM_Receipt_Date__c.month(); //20170412, Elufa
						MonthNumber=MonthMap.get(string.valueOf(porl.ASI_MFM_Receipt_Date__c.month())); //20170412, Elufa
                    }else{
                        //MonthNumber=porl.CreatedDate.month(); //20170412, Elufa
						MonthNumber=MonthMap.get(string.valueOf(porl.CreatedDate.month())); //20170412, Elufa
                    }
                    String mapField = 'ASI_MFM_Month_'+MonthNumber+ '_PORAmount__c';
                    Decimal PLRAmountTemp=TempData.get(mapField)!=null?(Decimal)TempData.get(mapField):0;
                    PLRAmountTemp+=(Decimal)porl.ASI_MFM_Receipt_Amount_in_Local_Currency__c;
                    TotalPORAmount+=(Decimal)porl.ASI_MFM_Receipt_Amount_in_Local_Currency__c;
                    TempData.put(mapField,PLRAmountTemp);
                    TempData.ASI_MFM_PO_Receipt_Line__c+=';'+porl.Id; 
                    lineItemMap.put(Mapkey, TempData);
                }
                
            }
           
            //Payment line 
            if(PaidlineMap.containsKey(planline.Id)){
                for(ASI_MFM_Payment_Line_Item__c payl:PaidlineMap.get(planline.Id)){
                    ASI_MFM_Settings__c TempData=lineItemMap.get(Mapkey);
                    lineItemMap.remove(Mapkey);
                    Integer MonthNumber=1;
                    if(payl.ASI_MFM_Invoice_Date__c!=null){
                        //MonthNumber=payl.ASI_MFM_Invoice_Date__c.month(); //20170412, Elufa
						MonthNumber=MonthMap.get(string.valueOf(payl.ASI_MFM_Invoice_Date__c.month())); //20170412, Elufa
                    }else{
                        //MonthNumber=payl.CreatedDate.month(); //20170412, Elufa
						MonthNumber=MonthMap.get(string.valueOf(payl.CreatedDate.month())); //20170412, Elufa
                    }
                    String mapField = 'ASI_MFM_Month_'+MonthNumber+ '_PaymentAmount__c';
                    Decimal PayAmountTemp=TempData.get(mapField)!=null?(Decimal)TempData.get(mapField):0;
                    PayAmountTemp+=(Decimal)payl.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    TotalPaidAmount+=(Decimal)payl.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                    TempData.put(mapField,PayAmountTemp);
                    TempData.ASI_MFM_Payment_Line_ID__c+=';'+payl.Id; 
                    lineItemMap.put(Mapkey, TempData);
                }
            }
           
           
            
            lineItemMap.get(Mapkey).ASI_MFM_Payment_Amount__c=lineItemMap.get(Mapkey).ASI_MFM_Payment_Amount__c+TotalPaidAmount;
            lineItemMap.get(Mapkey).ASI_MFM_PO_Amount__c=lineItemMap.get(Mapkey).ASI_MFM_PO_Amount__c+TotalPOAmount;
            lineItemMap.get(Mapkey).ASI_MFM_PO_Receipt_Amount__c=lineItemMap.get(Mapkey).ASI_MFM_PO_Receipt_Amount__c+TotalPORAmount;
            
        }//End of Plan For Loop
        
        
     
        
        
        
        //Upsert
        List<Database.upsertResult> uResults = new List<Database.upsertResult>();
        
        try{
            uResults= database.upsert(lineItemMap.values(),ObjType.getDescribe().fields.getMap().get('ASI_MFM_External_ID__c'),false);
        }catch(exception e){
            InfoMesg=e.getMessage();
            hasError = true;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        if(hasError){
           
            ASI_MFM_ByPass_Setting.ErrorHandling('Batch Process has completed:'+InfoMesg,'ASI_MFM_KR_PORCProcess','Batch Process Failed!');
        }else{
            ASI_MFM_Setting__c updatedSetting =[select id,ASI_MFM_KR_PORC_Data_Last_Cal_Time__c from ASI_MFM_Setting__c limit 1][0];
            updatedSetting.ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now();
            update updatedSetting;
            
            //Success!
			user currentUser =[select id,Name,ASI_MFM_Permission_Sets__c,Email from user where id=:UserInfo.getUserId() ];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
           
            List<String> EmailList= new List<String>();
            EmailList.add('prasia.mobile@pernod-ricard.com');
            
            
            if(currentUser.ASI_MFM_Permission_Sets__c!=null && currentUser.ASI_MFM_Permission_Sets__c.contains('ASI_MFM_PO_Receipt_Closing_Process')){
                 EmailList.add(currentUser.Email);
            }
            mail.setToAddresses(EmailList);
            mail.setReplyTo('prasia.mobile@pernod-ricard.com');
            mail.setSenderDisplayName('PO Receipt Closing Processing');
            mail.setSubject('PO Receipt Closing Process Completed');
            string link=System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/ASI_MFM_KR_POReceiptClosing_Page2';
            String body = 'Please be noted that KR MFM PO Receipt Closing Batch Process Job has completed successfully.<br/> Please refer :'+link;// mail.setPlainTextBody('Please be noted that KR MFM PO Receipt Closing Batch Process Job has completed successfully.'+);
            mail.setHtmlBody(body);
            if(!Test.isRunningTest())
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }//end method: finish
    
    //Plan insert into the Map
    public ASI_MFM_Settings__c PlanLineInsert(String MapK, ASI_MFM_Plan_Line_Item__c InputPlanLine){
        ASI_MFM_Settings__c TempData= new ASI_MFM_Settings__c(ASI_MFM_A_P_Type__c=InputPlanLine.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_Payment_Amount__c=0,ASI_MFM_PO_Amount__c=0,ASI_MFM_PO_Receipt_Amount__c=0,ASI_MFM_External_ID__c=MapK,
                                                              ASI_MFM_Plan__c=InputPlanLine.ASI_MFM_Plan__c,
                                                              ASI_MFM_Plan_Line_ID__c=InputPlanLine.Id,
                                                              ASI_MFM_PO_Line_ID__c='',
                                                              ASI_MFM_PO_Receipt_Line__c='',
                                                              ASI_MFM_Payment_Line_ID__c='',
                                                              ASI_MFM_Sub_brand__c=InputPlanLine.ASI_MFM_Sub_brand_Code__c,
                                                              ASI_MFM_Active__c=true,      // [SH] 2018-10-15
                                                              ASI_MFM_Version__c=Version,ASI_MFM_PRPO_Needed__c=InputPlanLine.ASI_MFM_PRPO_Needed__c);
        for (Integer i = 1; i < 13; i++) {
            String mapField = 'ASI_MFM_Month_' + i+ '_Cost__c'; 
            Decimal PLAmountTemp=0.0;
            PLAmountTemp+=(InputPlanLine.get(mapField)!=null?(Decimal)InputPlanLine.get(mapField):0);
            TempData.put(mapField,PLAmountTemp);
        }
        return TempData;
    }
    
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