global class ASI_MFM_SC_GenPORecurringPayment_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>{
/*********************************
 * Created by: Linus @introv
 * Created Date: 2017-08-01
 * Obejctive: Batch job to generate PO receipt item getting from PO line item with today G/L date 
 * Module: MFM HK
*********************************/    

    global List<Id>  poHeaderId;    
    global Id payDrtId;
    global Map<id,id> poPaymentM;

    global Date GLDate_pass = System.today().addDays(-7);
    global Date GLDate_future = Date.newInstance(2018,6,30);
    global String fiscalYear = '';
    
    // for testing only
    //global Date GLDate = Date.newInstance(2017, 8, 15);

    global ASI_MFM_SC_GenPORecurringPayment_Batch(List<Id> input_poHeadId, Map<id,id> input_poPaymentM, Id input_payDrtId){ 
        poHeaderId=input_poHeadId ;
        payDrtId = input_payDrtId;      // HK POR Item record type ID 
        poPaymentM=input_poPaymentM;   
        system.debug('Start Batch Job');                        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr= 'Select id,name, ASI_MFM_PO__c, ASI_MFM_AP_Code__c,asi_mfm_bu_code__c,asi_mfm_sc_Subledger__c, ASI_MFM_List_Item_Description__c,ASI_MFM_PO__r.asi_mfm_Recurring_Payment_day_of_month__c, asi_mfm_Recurring_payment_amount__c from ASI_MFM_PO_Line_Item__c ' 
        +'where ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' and recordtype.name =\'SC PO Line Item\' and ASI_MFM_PO__c = :poHeaderId and asi_mfm_Recurring_payment_amount__c >0 order by ASI_MFM_PO__c, id';       

        system.debug('queryStr: ' + queryStr);
        return Database.getQueryLocator(queryStr);
    } 
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        if(Scope == NULL){
system.debug('Scope = NULL');        
            return;
        }
        
        date sysDate = date.today();
        String sysMonth=sysDate.year()+'.'+sysDate.month();
        
        List<ASI_MFM_AP_Code__c> apList = [SELECT Id, Name,asi_mfm_sc_Need_Subleger__c , ASI_MFM_A_C_Code__c FROM ASI_MFM_AP_Code__c WHERE RecordType.DeveloperName = 'ASI_MFM_SC_AP_Code' AND ASI_MFM_Inactive__c = false];        
        Map<ID, ID> apcCMap = new Map<ID, ID>();
        for(ASI_MFM_AP_Code__c ap : apList){
            apcCMap.put(ap.ID,ap.ASI_MFM_A_C_Code__c);     
        }

        List<ASI_MFM_PO_Line_Item__c> POLlist = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_Payment_Line_Item__c> paymentDetailList = new List<ASI_MFM_Payment_Line_Item__c>();
        
        for(SObject s: Scope){
            ASI_MFM_PO_Line_Item__c POL = (ASI_MFM_PO_Line_Item__c)s;
            POLlist.add(POL);
        }
        
        system.debug('POLlist Size: ' + POLlist.size());
        
        for(ASI_MFM_PO_Line_Item__c pol: POLlist){
            ASI_MFM_Payment_Line_Item__c payD = new ASI_MFM_Payment_Line_Item__c();
            payD.ASI_MFM_Payment__c = poPaymentM.get(pol.ASI_MFM_PO__c);
            payD.ASI_MFM_PO__c = pol.ASI_MFM_PO__c;
            payD.ASI_MFM_PO_Line_Item__c = pol.id;
            payD.ASI_MFM_BU__c = pol.ASI_MFM_BU_Code__c;
            payD.ASI_MFM_AP_Code__c = pol.ASI_MFM_AP_Code__c;
            payD.ASI_MFM_A_C_Code__c = apcCMap.get(pol.ASI_MFM_AP_Code__c);
            payD.ASI_MFM_Payment_Amount__c = pol.asi_mfm_Recurring_payment_amount__c;
            payD.ASI_MFM_Invoice_Date__c = Date.newInstance(sysDate.year(),sysDate.month(),Integer.valueof(pol.ASI_MFM_PO__r.asi_mfm_Recurring_Payment_day_of_month__c));
            payD.ASI_MFM_G_L_Date__c= Date.newInstance(sysDate.year(),sysDate.month(),Integer.valueof(pol.ASI_MFM_PO__r.asi_mfm_Recurring_Payment_day_of_month__c));
            payD.asi_mfm_sc_Subledger__c = pol.asi_mfm_sc_Subledger__c;
            payD.recordtypeid = payDrtId;
            //payD.ASI_MFM_Invoice_Number__c=pol.name +' '+sysMonth;
            paymentDetailList.add(payD);           system.debug(payD);
        }
        
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] srList = Database.insert(paymentDetailList, false);
        
        String logContent = '';
        Boolean isSuccess = false;
        
        for(Integer i=0;i<srList.size();i++){
            if(srList[i].isSuccess()){
                system.debug('payD ID: ' + srList[i].getID());
                isSuccess = true;
            }else{
                
                Database.Error err = srList[i].getErrors()[0];
                logContent += 'PO Line Item: [' + paymentDetailList[i].ASI_MFM_PO_Line_Item__c + '] with the following error: ' + err.getMessage() + '\n';
                
                System.debug('The following error has occurred.');                   
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('PO Receipt Item fields that affected this error: ' + err.getFields());
                
                Database.rollback(sp);
                isSuccess = false;
            }
        }
   /*     
        Attachment att = new Attachment();
        att.Name = 'Log.txt';
        att.ParentId = paymentHeadId;
        att.Body = isSuccess == true ? blob.valueOf('Success') : blob.valueOf(logContent);
        insert att;*/
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Batch Generation');
    }
}