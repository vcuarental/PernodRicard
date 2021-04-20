public with sharing class ASI_CRM_KR_ItemUploadCtrl {
    
    public Id BatchId {set;get;}
    public ASI_MFM_Mass_Upload_Log__c MFMlog {set;get;}
    // fields for SIT Template
    public String TemplateYear {get;set;}
    public String TemplateMonth {get;set;}
    
    
    // fields for SIT Report
    public String selectedYear {get;set;}
    public String selectedMonth {get;set;}
    //public String reportId {get;set;}
   
    public String Msg {get;set;}{Msg='';}
    public String Msg1 {get;set;}
    public Boolean DeletePermission {get;set;} {DeletePermission = false;}
    public Boolean GenerateMsg {get;set;} {GenerateMsg = false;}
    public Boolean DeleteMsg {get;set;} {DeleteMsg = false;}
    
    public String[] statusMsgs{get;set;} 
    
    public String[] GenStatusMsgs{
        
        get{
            String s = Msg1 ==null? '': Msg1;
            
            system.debug('BatchId : + '+BatchId);
            if(BatchId!=null ){ // && DeletePermission == false
                s = BatchId;
                List<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id =: BatchId  ];
                if(aajs.size()>0){
                    s = '<div style="height: 25px;"> <span style="color:red; font-weight: bold; vertical-align: middle;"> '+ aajs[0].Status + '</span></div>';
                }
                
                if(aajs[0].Status=='Completed' && MFMlog.Id != null){
                    ASI_MFM_Mass_Upload_Log__c uploadLog = [SELECT ASI_MFM_Configuration__c,ASI_MFM_Status__c,ASI_MFM_Error_Message__c FROM ASI_MFM_Mass_Upload_Log__c WHERE Id =: MFMlog.Id];
                    
                    if(uploadLog.ASI_MFM_Status__c == 'Success' && uploadLog.ASI_MFM_Error_Message__c == null) {    
                        if( uploadLog.ASI_MFM_Configuration__c != null){
                            uploadLog.ASI_MFM_Configuration__c = uploadLog.ASI_MFM_Configuration__c.remove('null');
                        } 
                        s = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully generated Stock-in Trade records. ' +  uploadLog.ASI_MFM_Configuration__c + '</span></div>' ;
                    }
                    if(uploadLog.ASI_MFM_Status__c == 'Failed') {  
                        s =  '<div style="height: 25px;"> <span style="color:red; font-weight: bold; vertical-align: middle;"> '+'Failed' +  uploadLog.ASI_MFM_Error_Message__c  + '</span></div>';
                    }
                    if(uploadLog.ASI_MFM_Error_Message__c != null  &&  uploadLog.ASI_MFM_Error_Message__c !=''){
                        
                        s =  '<div style="height: 25px;"> <span style="color:red; font-weight: bold; vertical-align: middle;"> '+ uploadLog.ASI_MFM_Error_Message__c + '</span></div>';
                    } 
                } 
            }
            
            if(GenerateMsg == true){
                s = 'There is no Temp Data can be used to create Stock-in Trade Header and Line.';
            }
            if(DeleteMsg == true){
                s = 'There is no Temp record can be deleted.';
            }
            return s.split('\n');
        }
        //private set;
        
    }
    
    
    public String report_SITItem {get;set;} //For Report generation
    public String report_TempDataReport {get;set;} //For Report generation
    
    public class interimData {   
        ASI_KOR_Stock_In_Trade__c create_Header {set;get;}    
        ASI_KOR_WS_Stock_In_Trade_Detail__c create_Line {set;get;}   
    }
    
    public ASI_CRM_KR_ItemUploadCtrl(){
        report_SITItem = retrieveSITItemReport('ASI_KR_CRM_Item_Group_SIT');
        report_TempDataReport = retrieveSITItemReport('ASI_CRM_KR_Temp_StockInTrade');
        
        // Set selected year and month to last month
        Date lastMonth = Date.today().addMonths(-1);
        selectedYear = String.valueOf(lastMonth.year());
        selectedMonth = Datetime.newInstance(lastMonth, Time.newInstance(3, 3, 3, 0)).format('MMMMM');
        TemplateYear = String.valueOf(lastMonth.year());
        TemplateMonth = Datetime.newInstance(lastMonth, Time.newInstance(3, 3, 3, 0)).format('MMMMM');
        
    }
    
    public PageReference download_EXCEL(){ 
        
        PageReference pageRef = new PageReference('/apex/ASI_CRM_KR_SITCSVPage');
        pageRef.getParameters().put('Year',TemplateYear);
        pageRef.getParameters().put('Month',TemplateMonth);
        return pageRef;
        
    }
    
    public PageReference GoToPage1(){
        PageReference pr = new PageReference('/apex/ASI_CRM_KR_ItemUploadPage');
        pr.setRedirect(true);
        return pr;
    }
    
    public String getSelectedEXCELDownloadUrl() {
        string urlString;        
        urlString = System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/ASI_CRM_KR_SITCSVPage?Year='+TemplateYear+'&Month='+TemplateMonth;
        return urlString; 
    }
    
    public String getPage2() {
        string urlString;        
        urlString = System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/ASI_CRM_KR_ItemUploadPage2';
        return urlString; 
    }
    
    public string getreportId(){
        Report report = [SELECT Id FROM Report WHERE DeveloperName = 'Report616' LIMIT 1];
        return report.Id;
    }
    
    
    public List<SelectOption> getYears() {
        return getSelectOptions('ASI_CRM_KR_Temp_SIT__c', 'ASI_CRM_KR_Year__c');
    }
    
    public List<SelectOption> getMonths() {
        return getSelectOptions('ASI_KOR_Stock_In_Trade__c', 'ASI_KOR_Month__c');
        
    }
    
    public List<SelectOption> getSelectOptions(String objectName, String fieldName) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = f.getPicklistValues();
        
        for (Schema.PicklistEntry picklistEntry : ple) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }
    
    
    public static String retrieveSITItemReport(String repRecType){
        String reportType = '#';
        List<Report> report = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName =: repRecType];
        
        
        if(report.size() > 0){
            
            if(repRecType == 'ASI_KR_CRM_Item_Group_SIT'){
                reportType = '/' + report[0].Id + '?export=1&enc=UTF-8&xf=xls';
            }else{
                reportType = '/' + report[0].Id;
            }
        }
        return reportType;
    }
    
    public void generateHeader(){
        
        DeleteMsg = false;
        DeletePermission = false; 
        
        MFMlog= new ASI_MFM_Mass_Upload_Log__c();
        
        // Block conversion if SIT record of the year and month is locked already
        Set<String> lockedMonths = new Set<String>();
        List<ASI_CRM_KR_Temp_SIT__c> tempLine = [SELECT Id, ASI_CRM_KR_Sys_Date__c,ASI_CRM_KR_Customer_Code__c,ASI_CRM_KR_Year__c,ASI_CRM_KR_Sys_Month__c,ASI_CRM_KR_Status__c FROM ASI_CRM_KR_Temp_SIT__c WHERE ASI_CRM_KR_AccountOwnerChecking__c = TRUE ]; //AND ASI_CRM_KR_SIT_Created__c = FALSE
        Set<Date> dates = new Set<Date>();
        Set<Date> datesPreviousMonth = new Set<Date>();
        Set<String> TempSITKey = new Set<String>();
        for (ASI_CRM_KR_Temp_SIT__c item : tempLine) {
            dates.add(item.ASI_CRM_KR_Sys_Date__c);
            datesPreviousMonth.add(item.ASI_CRM_KR_Sys_Date__c.addMonths(-1));
            if(item.ASI_CRM_KR_Year__c!=null && item.ASI_CRM_KR_Sys_Month__c!=null && item.ASI_CRM_KR_Customer_Code__c!=null){
                string keystr = item.ASI_CRM_KR_Year__c +'_'+ item.ASI_CRM_KR_Sys_Month__c +'_'+ item.ASI_CRM_KR_Customer_Code__c;
                TempSITKey.add(keystr);
            }
            
        }
        List<ASI_KOR_Stock_In_Trade__c> stockInTradesLocked = [SELECT Id, ASI_KOR_SYS_Date__c FROM ASI_KOR_Stock_In_Trade__c WHERE RecordType.DeveloperName = 'ASI_KOR_SIT_Locked' 
                                                               AND ASI_KOR_SYS_Date__c IN :dates AND ASI_KOR_Status__c = 'Locked'];
        for (ASI_CRM_KR_Temp_SIT__c tempSIT : tempLine) {
            for (ASI_KOR_Stock_In_Trade__c locked : stockInTradesLocked) {
                if (tempSIT.ASI_CRM_KR_Sys_Date__c == locked.ASI_KOR_SYS_Date__c) {
                    lockedMonths.add(tempSIT.ASI_CRM_KR_Sys_Date__c.year() + ' ' + tempSIT.ASI_CRM_KR_Sys_Date__c.month());
                }
            }
        }
        if (!lockedMonths.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'You cannot convert SIT because TMKT team has locked the SIT for selected months : ' + String.join(new List<String>(lockedMonths), ', ') + '.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        if(TempSITKey.size()>0){
            List<ASI_KOR_Stock_In_Trade__c> stockInTradesTBD = [SELECT Id, ASI_KOR_SYS_Date__c FROM ASI_KOR_Stock_In_Trade__c 
                                                                where ASI_KOR_Sys_Stock_in_trade_header_ID__c in :TempSITKey
                                                               and ASI_KOR_Status__c = 'Editable' and RecordType.DeveloperName = 'ASI_KOR_SIT_Editable' ];
            if(stockInTradesTBD.size()>0){
                delete stockInTradesTBD;
            }
        }
        
        
        
        // Clone last month T3 wholesaler owned by current user if there is no upload record this month
        // Get all T3 wholesaler owned by current user
        List<Account> t3Wholesalers = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ASI_KOR_Wholesaler' AND ASI_KOR_Grade__c = 'T3' AND ASI_KOR_Venue_Status__c = 'Active' AND OwnerId = :UserInfo.getUserId()];
        // Get all T3 wholesaler uploaded by current user
        List<ASI_CRM_KR_Temp_SIT__c> t3WholesalersUploaded = [SELECT ASI_CRM_KR_WS_CRM_No__c FROM ASI_CRM_KR_Temp_SIT__c WHERE ASI_CRM_KR_AccountOwnerChecking__c = TRUE AND ASI_CRM_KR_WS_CRM_No__r.ASI_KOR_Grade__c = 'T3' AND ASI_CRM_KR_SIT_Created__c = FALSE];
        Set<Id> t3WholesalersUploadedId = new Set<Id>();
        for (ASI_CRM_KR_Temp_SIT__c tempSIT : t3WholesalersUploaded) {
            t3WholesalersUploadedId.add(tempSIT.ASI_CRM_KR_WS_CRM_No__c);
        }
        
        Set<Id> missingWholesalerIds = new Set<Id>();
        Set<Id> userOwnedWholesalerIds = new Set<Id>();
        // Find the missing wholesales, they are to be cloned
        for (Account wholesaler : t3Wholesalers) {
            userOwnedWholesalerIds.add(wholesaler.Id);
            if (!t3WholesalersUploadedId.contains(wholesaler.Id)) {
                missingWholesalerIds.add(wholesaler.Id);
            }
        }
        
        System.debug('t3WholesalersUploaded ' + t3WholesalersUploaded );
        System.debug('t3WholesalersUploadedId ' + t3WholesalersUploadedId );
        System.debug('missingWholesalerIds ' + missingWholesalerIds );
        
        // Determine if this is first upload. Clone only if this is first upload. No SIT record in current month => is first upload
        Boolean isFirstUpload = [SELECT Id FROM ASI_KOR_Stock_In_Trade__c WHERE RecordType.DeveloperName IN ('ASI_KOR_SIT_Locked','ASI_KOR_SIT_Editable') AND ASI_KOR_SYS_Date__c IN :dates AND ASI_KOR_Wholesaler__c IN :userOwnedWholesalerIds].isEmpty();
        
        System.debug('dates ' + dates );
        System.debug('isFirstUpload ' + isFirstUpload );
        System.debug('datesPreviousMonth ' + datesPreviousMonth );
        
        
        if (isFirstUpload && !missingWholesalerIds.isEmpty()) {
            List<ASI_KOR_WS_Stock_In_Trade_Detail__c > sitToClone = [SELECT Id, Stock_In_Trade__r.ASI_KOR_Wholesaler__c, Stock_In_Trade__r.ASI_KOR_SYS_Date__c, ASI_KOR_WS_SIT_End_Stock__c, ASI_KOR_Item_Group_Code__c FROM ASI_KOR_WS_Stock_In_Trade_Detail__c WHERE Stock_In_Trade__r.RecordType.DeveloperName IN ('ASI_KOR_SIT_Locked','ASI_KOR_SIT_Editable') AND Stock_In_Trade__r.ASI_KOR_SYS_Date__c IN :datesPreviousMonth AND Stock_In_Trade__r.ASI_KOR_Wholesaler__c IN :missingWholesalerIds];
            List<ASI_CRM_KR_Temp_SIT__c> tempSITS = new List<ASI_CRM_KR_Temp_SIT__c>();
            for (ASI_KOR_WS_Stock_In_Trade_Detail__c detail : sitToClone) {
                Date nextMonthDate = detail.Stock_In_Trade__r.ASI_KOR_SYS_Date__c.addMonths(1);
                
                ASI_CRM_KR_Temp_SIT__c tempSIT = new ASI_CRM_KR_Temp_SIT__c(
                    ASI_CRM_KR_Year__c = String.valueOf(nextMonthDate.year()),
                    ASI_CRM_KR_Month__c = Datetime.newInstance(nextMonthDate, Time.newInstance(0,0,0,0)).format('MMM'),
                    ASI_CRM_KR_WS_CRM_No__c = detail.Stock_In_Trade__r.ASI_KOR_Wholesaler__c,
                    ASI_CRM_KR_End_Stock_Case__c = detail.ASI_KOR_WS_SIT_End_Stock__c,
                    ASI_CRM_KR_Item_Group_Code__c = detail.ASI_KOR_Item_Group_Code__c,
                    RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_KR_Temp_SIT__cASI_CRM_KR_SIT'),
                    ASI_CRM_KR_Status__c = 'Editable'
                );
                
                tempSIT.ASI_CRM_KR_External_ID_Upload__c = tempSIT.ASI_CRM_KR_Year__c +'&' + tempSIT.ASI_CRM_KR_Month__c +'&' + tempSIT.ASI_CRM_KR_WS_CRM_No__c +'&' + tempSIT.ASI_CRM_KR_Item_Group_Code__c;
                tempSITS.add(tempSIT);
            }
            //insert tempSITS;
        }
        
        
        
        if(tempLine.size() > 0 && tempLine != null){
            
            insert MFMlog;  
            BatchId= Database.executeBatch(new ASI_CRM_KR_ItemUploadBatch(MFMlog),500);    
            
        }
        
        if(tempLine.size() == 0){
            DeletePermission = true;
            
            GenerateMsg = true;
            
        }
        
        
        
    }
    
    public void deleteUploads(){
        
        
        GenerateMsg = false;
        DeletePermission = true;
        
        List<ASI_CRM_KR_Temp_SIT__c> DeleteTempList =new List<ASI_CRM_KR_Temp_SIT__c> ();
        for(ASI_CRM_KR_Temp_SIT__c templine : [SELECT Id, ASI_CRM_KR_SIT_Created__c, CreatedBy.Id FROM ASI_CRM_KR_Temp_SIT__c WHERE ASI_CRM_KR_AccountOwnerChecking__c = TRUE]){
            
            DeleteTempList.add(templine);                                      
        }
        if(DeleteTempList.size() == 0){
            DeleteMsg = true;
            
        }
        
        if(DeleteTempList.size()>0){
            try{  
                delete DeleteTempList;
                Msg1 = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully deleted ' + DeleteTempList.size() + ' Temp Records </span></div>';
            }catch (DmlException dmle) {
                Msg1 =  dmle.getMessage();
            }catch (Exception e){
                Msg1 =e.getMessage();
            }
        }
        
    }
    
}