public with sharing class ASI_MFM_SC_GenPaymentController {
    id po_id;
    

    public ASI_MFM_SC_GenPaymentController(apexpages.standardController sc) {
        po_id = apexpages.currentPage().getParameters().get('poid');  // sc.getId();//
    }
    
    public pageReference GenPayment() {
        Id SCPaymentHeadRtId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SC_Payment');               system.debug('SC PO Receipt RtId: ' + SCPaymentHeadRtId);
        //Id SCPaymentDetailRtId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item');    system.debug('SC PO Receipt Item RtId: ' + SCPaymentDetailRtId);
      
        Id prefixId;
        List<ASI_MFM_Prefix__c> prefixL=[Select id,name from ASI_MFM_Prefix__c where recordtype.name='ASI MFM SC Prefix' and ASI_MFM_Inactive__c=false and ASI_MFM_Module__c='Payment'];
        for(ASI_MFM_Prefix__c prefix:prefixL){
            prefixId=prefix.id;
        }
        
        date sysDate = date.today();
        String sysMonth=sysDate.year()+'.'+sysDate.month();
        
        
        List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
        List<ASI_MFM_PO__c> poL= [Select id,name,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_SC_Supplier_Name__c,ASI_MFM_PO_Type__c from ASI_MFM_PO__c where id= :po_id];
        List<ASI_MFM_AP_Code__c> apList = [SELECT Id, Name,asi_mfm_sc_Need_Subleger__c , ASI_MFM_A_C_Code__c FROM ASI_MFM_AP_Code__c WHERE RecordType.DeveloperName = 'ASI_MFM_SC_AP_Code' AND ASI_MFM_Inactive__c = false];        
        Map<ID, ID> apcCMap = new Map<ID, ID>();
        for(ASI_MFM_AP_Code__c ap : apList){
            apcCMap.put(ap.ID,ap.ASI_MFM_A_C_Code__c);     
        }
        
        ASI_MFM_Payment__c paymentHeader;
        
        for(ASI_MFM_PO__c po:poL){
            Date invoiceD=Date.newInstance(sysDate.year(),sysDate.month(),1);
            paymentHeader = new ASI_MFM_Payment__c(
                                                    ASI_MFM_Status__c = 'Draft',
                                                    recordtypeId = SCPaymentHeadRtId,
                                                    ASI_MFM_Prefix__c=prefixId,
                                                    ASI_MFM_po__c=po.id,
                                                    ASI_MFM_Payment_Type__c=po.ASI_MFM_PO_Type__c,
                                                    ASI_MFM_SC_Supplier_Name__c=po.ASI_MFM_SC_Supplier_Name__c,
                                                    ASI_MFM_Currency__c=po.ASI_MFM_Currency__c,
                                                    ASI_MFM_G_L_Date__c=sysDate,
                                                    ASI_MFM_Invoice_Date__c=sysDate,
                                                    ASI_MFM_Payment_External_ID__c=po.name+ ' '+Datetime.now().format('YYYYMMdd HH:mm:ss'),
                                                    ASI_MFM_Sys_Is_Not_Gen_Line__c = false
                                                  );                                                                      
            paymentList.add( paymentHeader );
        }
           
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] srList = Database.insert(paymentList, false);
        Id paymentHeaderId=po_id;
        
        List<Id> newPaymentHeaderId= new List<id>();
        for(Database.SaveResult sr: srList){
            if(sr.isSuccess()){
                system.debug('Payment header creates successful '+sr.getId()); 
                paymentHeaderId=sr.getId();
            }else{
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Payment fields that affected this error: ' + err.getFields());        
                }
                Database.rollback(sp);
            }
        }
    
        return new pageReference('/'+paymentHeaderId);
    }
}