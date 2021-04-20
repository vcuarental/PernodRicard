global with sharing class ASI_MFM_SC_GenPORecurringPayment_Sche implements Schedulable {
/********************************
 * Created by: Mark @ssc    
 * Created Date: 2018-05-23
 * Objective: Schedule job to auto generate Payment
 * Module: MFM HK SC
******************************/
    
    public void execute(SchedulableContext SC){
        system.debug('execute start');
        init();
        system.debug('execute end');
    }    
    
    public void init(){
        system.debug('Start running Gen PO Payment scheduler');        
        
        Id SCPaymentHeadRtId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SC_Payment');               system.debug('SC PO Receipt RtId: ' + SCPaymentHeadRtId);
        Id SCPaymentDetailRtId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item');    system.debug('SC PO Receipt Item RtId: ' + SCPaymentDetailRtId);
        Id SCPODetailRTId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_SC_PO_Line_Item');           system.debug('SC PO Line Item RtId: ' + SCPODetailRTId);       
        
        // Create PO receipt header
        List<Id> PORHeaderid = new List<id>();
        List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
        
        Map<String,ASI_MFM_Payment__c> payMap = new Map<String,ASI_MFM_Payment__c>();
        
        List<ASI_MFM_Payment__c> existedPaymentL=[Select ASI_MFM_Payment_External_ID__c from ASI_MFM_Payment__c where recordtype.name like 'SC Payment%' and ASI_MFM_Payment_External_ID__c!=''];
        for(ASI_MFM_Payment__c pay:existedPaymentL){
            payMap.put(pay.ASI_MFM_Payment_External_ID__c,pay);
        }
        
        Id prefixId;
        List<ASI_MFM_Prefix__c> prefixL=[Select id,name from ASI_MFM_Prefix__c where recordtype.name='ASI MFM SC Prefix' and ASI_MFM_Inactive__c=false and ASI_MFM_Module__c='Payment'];
        for(ASI_MFM_Prefix__c prefix:prefixL){
            prefixId=prefix.id;
        }
        
        date sysDate = date.today();
        String sysMonth=sysDate.year()+'.'+sysDate.month();
        
        
        
        List<ASI_MFM_PO__c> poL= [Select id,name,ASI_MFM_SC_Supplier_Name__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Type__c,asi_mfm_Recurring_Payment_day_of_month__c,ownerid from ASI_MFM_PO__c where recordtype.name='SC PO Read-Only' and ASI_MFM_Recurring_payment__c=true and ASI_MFM_PO_Start_Date__c<=today and ASI_MFM_PO_End_Date__c>=today and ASI_MFM_Status__c='Final' and  ASI_MFM_Remaining_Balance__c>0 and asi_mfm_Recurring_payment_amount__c>0];
        
        for(ASI_MFM_PO__c po:poL){
            if(payMap.containskey(po.name+'_'+sysMonth))
                continue;
            else{
                PORHeaderid.add(po.id);
                Date invoiceD=Date.newInstance(sysDate.year(),sysDate.month(),Integer.valueof(po.asi_mfm_Recurring_Payment_day_of_month__c));
                ASI_MFM_Payment__c paymentHeader = new ASI_MFM_Payment__c(ASI_MFM_Remarks__c = sysMonth,
                                                                    ASI_MFM_Status__c = 'Draft',
                                                                    recordtypeId = SCPaymentHeadRtId,
                                                                    ASI_MFM_Prefix__c=prefixId,
                                                                    ASI_MFM_po__c=po.id,
                                                                    ASI_MFM_Payment_Type__c=po.ASI_MFM_PO_Type__c,
                                                                    ASI_MFM_SC_Supplier_Name__c=po.ASI_MFM_SC_Supplier_Name__c,
                                                                    ASI_MFM_Currency__c=po.ASI_MFM_Currency__c,
                                                                    ASI_MFM_G_L_Date__c=invoiceD,
                                                                    ASI_MFM_Invoice_Date__c=invoiceD,
                                                                    ASI_MFM_Payment_External_ID__c=po.name+ '_'+sysMonth,
                                                                    ASI_MFM_SC_Recurring__c=true,
                                                                    ownerid =po.ownerid );
                                                          
                paymentList.add(paymentHeader);
            }           
            
        }
           
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] srList = Database.insert(paymentList, false);
        
        List<Id> newPaymentHeaderId= new List<id>();
        for(Database.SaveResult sr: srList){
            if(sr.isSuccess()){
                system.debug('Payment header creates successful '+sr.getId()); 
                newPaymentHeaderId.add(sr.getId());
            }else{
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Payment fields that affected this error: ' + err.getFields());        
                }
                Database.rollback(sp);
            }
        }

        if(newPaymentHeaderId.size() != 0){
            Map<id,id> poPaymentM=new Map<id,id>();
            for(integer i=0; i <PORHeaderid.size();i++){
                poPaymentM.put(PORHeaderid.get(i),newPaymentHeaderId.get(i));
            }
            
            
            database.executeBatch(new ASI_MFM_SC_GenPORecurringPayment_Batch(PORHeaderid,poPaymentM, SCPaymentDetailRtId));
        }
        
    }

}