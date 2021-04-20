global class ASI_MFM_HK_GenPOReceipt_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>{
/*********************************
 * Created by: Linus @introv
 * Created Date: 2017-08-01
 * Obejctive: Batch job to generate PO receipt item getting from PO line item with today G/L date 
 * Module: MFM HK
*********************************/    
    global String queryFieldList = 'Select id, name, ASI_MFM_PO__c, ASI_MFM_Amount__c, ASI_MFM_Sub_Brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_PO_Remark__c, ASI_MFM_List_Item_Description__c from ASI_MFM_PO_Line_Item__c ';  // PO line Item

    global Id POLRtid;    
    global Id PORHeaderId;
    global Id PORIrtId;

    global Date GLDate_pass = System.today().addDays(-7);
    global Date GLDate_future = Date.newInstance(2018,6,30);
    global String fiscalYear = '';
    
    // for testing only
    //global Date GLDate = Date.newInstance(2017, 8, 15);
    
    global ASI_MFM_HK_GenPOReceipt_Batch(Id input_PORHeaderId, Id input_POLRtId, Id input_PORIrtId){        
        PORHeaderId = input_PORHeaderId;    // HK PO receipt Header ID     
        POLRtid = input_POLRtId;        // HK POL record type ID 
        PORIrtId = input_PORIrtId;      // HK POR Item record type ID 
        
        // Added by 2017-11-10 Linus@introv
        // Using custom setting to obtain cut-off date and fiscal year        
        ASI_MFM_AutoPOReceiptSetting__c setting = ASI_MFM_AutoPOReceiptSetting__c.getValues('HK');
        //GLDate_pass = Test.isRunningTest() == false && setting != null ? setting.ASI_MFM_Start_Date__c: GLDate_pass; 
        GLDate_future = Test.isRunningTest() == false && setting != null ? setting.ASI_MFM_Cut_Off_Date__c: GLDate_future;   
        fiscalYear = Test.isRunningTest() == false && setting != null ? setting.ASI_MFM_Fiscal_Year__c: 'FY1718';
                
        system.debug('Start Batch Job');                        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr;        
        String whereStam = Test.isRunningTest() == true? 'where ASI_MFM_Amount__c != 0 ':
                                                         'where ASI_MFM_Amount__c != 0 and (ASI_MFM_PO_Status__c = \'Final\' or ASI_MFM_PO_Status__c = \'Complete\' or ASI_MFM_PO_Status__c = \'Partial Paid\' or ASI_MFM_PO_Status__c = \'Voided\') and ASI_MFM_Synced__c = false and ASI_MFM_CN_Receipt_Amount__c = 0 and (ASI_MFM_PO__r.LastModifiedDate >= :GLDate_pass and ASI_MFM_G_L_Date__c <= :GLDate_future) and ASI_MFM_Pay_Acc__c != \'C\' and (ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c = :fiscalYear) ';   
        
        queryStr = queryFieldList + whereStam + ' and recordTypeId = :POLRtid'; 

        system.debug('queryStr: ' + queryStr);
        return Database.getQueryLocator(queryStr);
    } 
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        if(Scope == NULL){
            return;
        }

        List<ASI_MFM_PO_Line_Item__c> POLlist = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
        
        for(SObject s: Scope){
            ASI_MFM_PO_Line_Item__c POL = (ASI_MFM_PO_Line_Item__c)s;
            POLlist.add(POL);
        }
        
        system.debug('POLlist Size: ' + POLlist.size());
        
        for(ASI_MFM_PO_Line_Item__c pol: POLlist){
            ASI_MFM_PO_Receipt_Item__c pori = new ASI_MFM_PO_Receipt_Item__c();
            pori.ASI_MFM_PO_Receipt__c = PORHeaderId;
            pori.ASI_MFM_PO__c = pol.ASI_MFM_PO__c;
            pori.ASI_MFM_PO_Line_Item__c = pol.id;
            pori.ASI_MFM_A_C_Code_temp__c = pol.ASI_MFM_A_C_Code__c;
            pori.ASI_MFM_Sub_brand_temp__c = pol.ASI_MFM_Sub_Brand_Code__c;
            pori.ASI_MFM_Amount__c = pol.ASI_MFM_Amount__c;
            pori.ASI_MFM_PO_Remark__c = pol.ASI_MFM_PO_Remark__c;
            pori.ASI_MFM_List_Item_Description_temp__c = pol.ASI_MFM_List_Item_Description__c;
            pori.recordtypeid = PORIrtId;
            PORIList.add(pori);           system.debug(pori);
        }
        
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] srList = Database.insert(PORIList, false);
        
        String logContent = '';
        Boolean isSuccess = false;
        
        for(Integer i=0;i<srList.size();i++){
            if(srList[i].isSuccess()){
                system.debug('PORI ID: ' + srList[i].getID());
                isSuccess = true;
            }else{
                
                Database.Error err = srList[i].getErrors()[0];
                logContent += 'PO Line Item: [' + PORIList[i].ASI_MFM_PO_Line_Item__c + '] with the following error: ' + err.getMessage() + '\n';
                
                System.debug('The following error has occurred.');                   
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('PO Receipt Item fields that affected this error: ' + err.getFields());
                
                Database.rollback(sp);
                isSuccess = false;
            }
        }
        
        Attachment att = new Attachment();
        att.Name = 'Log.txt';
        att.ParentId = PORHeaderId;
        att.Body = isSuccess == true ? blob.valueOf('Success') : blob.valueOf(logContent);
        insert att;
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Batch Generation');
    }
}