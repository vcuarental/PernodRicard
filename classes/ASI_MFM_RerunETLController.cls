public class ASI_MFM_RerunETLController {
    
    string new_status;
    ASI_MFM_Payment__c p = new ASI_MFM_Payment__c();
    
    public ASI_MFM_RerunETLController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        p = [select id, ASI_MFM_Status__c,recordTypeId,RecordType.DeveloperName from ASI_MFM_Payment__c where id = :sc.getId()]; 
    }
    
    
    public pageReference setStatus() {
        List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
        
        if (p.ASI_MFM_Status__c == 'Final'  && p.RecordType.DeveloperName.contains('ASI_MFM_PH') ){
            
            if(p.RecordType.DeveloperName.contains('ASI_MFM_PH') ){
                // p.ASI_MFM_Status__c = new_status;
                plList = [select id,ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Effective__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Voucher_Created__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];
                for (ASI_MFM_Payment_Line_Item__c pl : plList){
                    if(!pl.ASI_MFM_Voucher_Created__c){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The voucher is not yet created.')); 
                        return null;                        
                    }
                    else if(pl.ASI_MFM_Complete_POL__c){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Haved Complete PO line. You cannot Rerun ETL')); 
                        return null;
                    }else{
                        pl.ASI_MFM_ETL__c=false;
                        pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
                        pl.ASI_MFM_ETL_Failed__c=false;
                        pl.ASI_MFM_Voucher_Created__c=false;
                        pl.ASI_MFM_Effective__c=false;
                        pl.ASI_MFM_ETL_Date__c=null;
                    }
                }
                
            }
            
            try {
                update p;
                if(plList.size()>0)
                {
                    update plList;
                }
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
            
            
        }else if(p.RecordType.DeveloperName.contains('ASI_MFM_JP_Payment') && (p.ASI_MFM_Status__c == 'Draft' || p.ASI_MFM_Status__c == 'Submitted') && new_status == 'Complete'){ 
            plList = [select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Effective__c,ASI_MFM_ETL_Failed__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];
            for (ASI_MFM_Payment_Line_Item__c pl : plList){
                pl.ASI_MFM_ETL__c=true;
                pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c=true;
                pl.ASI_MFM_Voucher_Created__c=true;
                pl.ASI_MFM_Effective__c=true;

            }
            p.ASI_MFM_Status__c = new_status;
            try {
                update p;
                 if(plList.size()>0)
                {
                    update plList;
                }
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }else if(p.ASI_MFM_Status__c == 'Submitted'){
            if(p.RecordType.DeveloperName.contains('ASI_MFM_JP')){
                //p.ASI_MFM_Status__c = new_status;
                plList = [select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Effective__c,ASI_MFM_ETL_Failed__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];
                for (ASI_MFM_Payment_Line_Item__c pl : plList){
                    if(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c=='Complete'){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Haved Complete PO. You cannot change the payment to Draft')); 
                        return null;
                    }else{
                        pl.ASI_MFM_ETL__c=false;
                        pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
                        pl.ASI_MFM_ETL_Failed__c=false;
                        pl.ASI_MFM_Voucher_Created__c=false;
                        pl.ASI_MFM_Effective__c=false;
                        pl.ASI_MFM_ETL_Date__c=null;
                    }
                }
                
            }
            try {
                update p;
                if(plList.size()>0)
                {
                    update plList;
                }
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
            
            
        }else if(p.RecordType.DeveloperName.contains('ASI_MFM_JP_Payment') && p.ASI_MFM_Status__c == 'Draft' && new_status == 'Complete'){ 
            p.ASI_MFM_Status__c = new_status;
            try {
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        } else if(p.RecordType.DeveloperName.contains('ASI_MFM_MY_Payment')) {
            //add MY MFM 20151215 By Elufa
            plList = [select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Effective__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Voucher_Created__c,ASI_MFM_Finance_Verify_Save_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];
            for (ASI_MFM_Payment_Line_Item__c pl : plList){
                if(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c=='Complete'){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Haved Comlpete PO. You cannot Re-Run ETL.')); 
                    return null;
                }else{
                    pl.ASI_MFM_ETL__c=false;
                    pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
                    pl.ASI_MFM_ETL_Failed__c=false;
                    pl.ASI_MFM_Voucher_Created__c=false;
                    pl.ASI_MFM_Effective__c=false;
                    pl.ASI_MFM_ETL_Date__c=null;
                    PL.ASI_MFM_Finance_Verify_Save_Date__c=NULL;
                }
            }
                
            try {
                update p;
                if(plList.size()>0)
                {
                    update plList;
                }
                
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }
        else {
            
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot Re-Run ETL'));
            return null;
        }
        
    }
    
    
}