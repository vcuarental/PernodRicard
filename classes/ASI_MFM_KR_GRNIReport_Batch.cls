global class ASI_MFM_KR_GRNIReport_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Id PO_Number = null;
    public Id Supplier_Name = null;
    public String Company = '';
    public String FiscalYear = '';
    public Date PO_Start_Date = null;
    public Date PO_End_Date = null;
    public String ReportToken;
    public Id userId = null;
    
    global ASI_MFM_KR_GRNIReport_Batch()
    {
	}

    global database.querylocator start(Database.BatchableContext BC)
    {
        system.debug('ASI_MFM_KR_GRNIReport_Batch start');
        system.debug('PO_Number : '+ PO_Number);  
        system.debug('Supplier_Name : '+ Supplier_Name);  
        system.debug('Company : '+ Company);
        system.debug('PO_Start_Date : '+ PO_Start_Date);  
        system.debug('PO_End_Date : '+ PO_End_Date);   
        system.debug('ReportToken : '+ ReportToken);
        system.debug('userId : '+ userId);
        
        // This methods returns a SOQL query locator containing the records
		
		if(PO_Number!=null) 
			return Database.getQueryLocator([SELECT id, name FROM ASI_MFM_PO__c WHERE ID = :PO_Number 
                                             									AND (RecordType.DeveloperName = 'ASI_MFM_KR_PO_Read_Only' OR RecordType.DeveloperName = 'ASI_MFM_KR_PO') 
                                             									AND ASI_MFM_Dummy_PO__c = false
                                             									AND ASI_MFM_Is_Direct_Payment__c = false
									                                            AND ASI_MFM_Is_Pre_Payment__c = false
                                             									AND ASI_MFM_Status__c != 'Draft'
                                             									AND ASI_MFM_Status__c != 'Submitted'
                                             									ORDER BY CreatedDate DESC]);
		if(Supplier_Name!=null) 
        	return Database.getQueryLocator([SELECT id, name FROM ASI_MFM_PO__c WHERE ASI_MFM_Company__c = :Company 
                                             									AND ASI_MFM_PO_Raised_Date__c >= :PO_Start_Date 
                                             									AND ASI_MFM_PO_Raised_Date__c <= :PO_End_Date 
                                             									AND ASI_MFM_Supplier_Name__c = :Supplier_Name 
                                             									AND (RecordType.DeveloperName = 'ASI_MFM_KR_PO_Read_Only' OR RecordType.DeveloperName = 'ASI_MFM_KR_PO') 
                                             									AND ASI_MFM_Dummy_PO__c = false
                                             									AND ASI_MFM_Is_Direct_Payment__c = false
                                             									AND ASI_MFM_Is_Pre_Payment__c = false
                                             									AND ASI_MFM_Status__c != 'Draft'
                                             									AND ASI_MFM_Status__c != 'Submitted'
                                             									ORDER BY CreatedDate DESC]);
        
        return Database.getQueryLocator([SELECT id, name FROM ASI_MFM_PO__c WHERE ASI_MFM_Company__c = :Company 
                                         									AND ASI_MFM_PO_Raised_Date__c >= :PO_Start_Date 
                                         									AND ASI_MFM_PO_Raised_Date__c <= :PO_End_Date 
                                         									AND (RecordType.DeveloperName = 'ASI_MFM_KR_PO_Read_Only' OR RecordType.DeveloperName = 'ASI_MFM_KR_PO') 
                                             								AND ASI_MFM_Dummy_PO__c = false
                                             								AND ASI_MFM_Is_Direct_Payment__c = false
									                                        AND ASI_MFM_Is_Pre_Payment__c = false
                                             								AND ASI_MFM_Status__c != 'Draft'
                                             								AND ASI_MFM_Status__c != 'Submitted'
                                         									ORDER BY CreatedDate DESC]);
    }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('ASI_MFM_KR_GRNIReport_Batch execute');   
        
		list<ASI_MFM_GRNI_Report__c> insertList = new list<ASI_MFM_GRNI_Report__c>();
        
        //get the po set
        list<ASI_MFM_PO__c> polist = (list<ASI_MFM_PO__c>)scope;
        Set<Id> ids = new Set<Id>();
   		for(ASI_MFM_PO__c sObj : polist){
        	ids.add(sObj.Id);
    	}
        
        ID KRRecordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_GRNI_Report__cASI_MFM_KR_GRNI_Report');
        
        //add PO Receipt Item record
        list<ASI_MFM_PO_Receipt_Item__c> poRecList = [select id, ASI_MFM_PO__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO__c in :ids and ASI_MFM_ETL__c = true];
        if(poRecList.size()>0){
            for(ASI_MFM_PO_Receipt_Item__c sObj: poRecList){
                ASI_MFM_GRNI_Report__c report = new ASI_MFM_GRNI_Report__c();
                report.ASI_MFM_PO_Number__c = sObj.ASI_MFM_PO__c;
                report.ASI_MFM_PO_Receipt_Item__c = sObj.id;
                report.ASI_MFM_Report_Token__c  = ReportToken;
                report.RecordTypeId = KRRecordTypeID;
                insertList.add(report);
            }
        }
        
        //add Payment Line Item record
        list<ASI_MFM_Payment_Line_Item__c> payItemList = [select id, ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO__c in :ids and ASI_MFM_ETL__c = true];
		if(payItemList.size()>0){
            for(ASI_MFM_Payment_Line_Item__c sObj: payItemList){
                ASI_MFM_GRNI_Report__c report = new ASI_MFM_GRNI_Report__c();
                report.ASI_MFM_PO_Number__c = sObj.ASI_MFM_PO__c;
                report.ASI_MFM_Payment_Line_Item__c = sObj.id;
                report.ASI_MFM_Report_Token__c  = ReportToken;
                report.RecordTypeId = KRRecordTypeID;
                insertList.add(report);
            }
        }
        
        integer maxCount = 10000 - insertList.size();        
        //clear GRNI Report record before 60 days
        list<ASI_MFM_GRNI_Report__c> delRpt = [select id from ASI_MFM_GRNI_Report__c where  RecordType.DeveloperName = 'ASI_MFM_KR_GRNI_Report' AND ASI_MFM_Report_Token__c != :ReportToken AND OwnerId = :userId LIMIT :maxCount];
        if(delRpt.size()>0)
	        delete delRpt;

        system.debug('insertList : '+insertList);
        if(insertList.size()>0){
            insert insertList;
        }
        
    }//end method: excute 
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('ASI_MFM_KR_GRNIReport_Batch finish'); 
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Name, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];        
        if(a.Status == 'Completed' || a.Status == 'Failed'){
            String reportUrl = ''; 
            list<Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'ASI_MFM_KR_GRNI_Report' limit 1];
            if(reportList.size()>0){
                reportUrl = System.Url.getSalesforceBaseURL().toExternalForm()+'/'+reportList[0].id+'?pv0='+ReportToken;
                system.debug('reportUrl : '+reportUrl);
            }
            
            // 1. Send Email (CSV created in execute method)
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Send the email to the job submitter
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('GRNI Report Batch Process');
            Date today = Date.today();
            mail.setSubject('Generate GRNI Report Status: ' + a.Status + ' ' + today.day()+'/'+today.month()+'/'+today.year());
            
            String body = 'Dear '+a.CreatedBy.Name+',<br/>'
                +'<br/>Generate GRNI Report Status is ' + a.Status;
            
            if(a.Status == 'Completed' && reportList.size()>0){
                body = body+'<br/>GRNI Report : <a href="'+reportUrl+'">click here</a>';
            }else{
                body = body+'<br/>Failed to Generate GRNI Report, please try again.'
		                   +'<br/>The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus;
            }
            
            mail.setHtmlBody (body);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
    }//end method: finish
}