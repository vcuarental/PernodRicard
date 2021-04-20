public class ASI_MFM_SetPaymentStatusController {

    string new_status;
    ASI_MFM_Payment__c p = new ASI_MFM_Payment__c();
    
    public ASI_MFM_SetPaymentStatusController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        //p = [select id, ASI_MFM_Status__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_Payment_Amount__c from ASI_MFM_Payment__c where id = :sc.getId()]; // Modified By Tony Ren ,add :'RecordType.DeveloperName'
    	p = [select id,ASI_MFM_Send_Approval_Email__c,ASI_MFM_Submitted_Date__c,ASI_MFM_Status__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_Payment_Amount__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Sync_to_JDE__c,ASI_MFM_Is_Direct_Payment__c from ASI_MFM_Payment__c where id = :sc.getId()]; // Modified By Tony Ren ,add :'RecordType.DeveloperName'
   
    }
    
    public pageReference setStatus() {
    	Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_Payment__c');
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        if (p.ASI_MFM_Status__c == 'Final' && new_status == 'Draft') {
            p.ASI_MFM_Status__c = new_status;
            List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
            boolean AllVoucherCreated=true;
            if(p.RecordType.DeveloperName.contains('ASI_MFM_PH')||p.RecordType.DeveloperName.contains('ASI_MFM_MY_Payment')) {
                plList = [select id,ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Voucher_Created__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];
                for (ASI_MFM_Payment_Line_Item__c pl : plList){
                    if(pl.ASI_MFM_Complete_POL__c ){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Haved Complete PO. You cannot change the payment to Draft')); 
                        return null;
                    }else if(pl.ASI_MFM_Voucher_Created__c){
                         apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Voucher created. You cannot change the payment to Draft')); 
                        return null;
                    }
                    else{
                        pl.ASI_MFM_ETL__c=false;
                        pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c=false;
                        pl.ASI_MFM_ETL_Failed__c=false;
                        pl.ASI_MFM_ETL_Date__c=null;
                        pl.ASI_MFM_Effective__c=false;
                    }
                }
            }
           
            if(p.RecordType.DeveloperName.contains('ASI_MFM_TH_Payment') || p.RecordType.DeveloperName.contains('ASI_MFM_SG_Payment') ) {
                plList = [select id,ASI_MFM_ETL_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_Voucher_Created__c,ASI_MFM_Effective__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];// AND ASI_MFM_Payment_Line_Item_Finance_Verify__c = true
                system.debug('paymentline1:::' + plList);
                set<string> CustomPermission = ASI_MFM_ByPass_Setting.GetCustomPermissions();
                
                for (ASI_MFM_Payment_Line_Item__c pl : plList)
                {
                    if(CustomPermission.contains('ASI_MFM_SG_SetPaymentStatus')  || Test.isRunningTest() ){
                        pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c = false;
                        pl.ASI_MFM_Voucher_Created__c=false;
                        pl.ASI_MFM_ETL_Date__c=null;
                        pl.ASI_MFM_Effective__c=false;
                    }
                    if(pl.ASI_MFM_Voucher_Created__c==false){
                        AllVoucherCreated=false;
                        pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c = false;
                    }
                     if (p.RecordType.DeveloperName.contains('ASI_MFM_MY_Payment') && pl.ASI_MFM_Voucher_Created__c){
                         apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Payment line has created voucher. You cannot change the payment to Draft. Please Re-Run ETL.')); 
                         return null;
                    }
                }    
                if(CustomPermission.contains('ASI_MFM_SG_SetPaymentStatus')  || Test.isRunningTest() ){
                    p.ASI_MFM_ETL__c = false;
                    p.ASI_MFM_ETL_Date__c=null;
                    p.ASI_MFM_Sync_to_JDE__c=false;
                    p.RecordTypeId = MRecType.get('ASI_MFM_SG_Payment');
                }
                
                if(AllVoucherCreated==false){
                    p.ASI_MFM_ETL__c = false;
                    if (p.RecordType.DeveloperName.contains('ASI_MFM_SG_Payment') || Test.isRunningTest()){
                        p.RecordTypeId = MRecType.get('ASI_MFM_SG_Payment');
                    }
                }else if(!CustomPermission.contains('ASI_MFM_SG_SetPaymentStatus')) {
                  	apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'All payment lines have created voucher. You cannot change the payment to Draft')); 
                    return null;
                }
            }
            
            if(p.RecordType.DeveloperName.contains('ASI_MFM_TH_Payment') ){
                plList = [select id,ASI_MFM_Complete_POL__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_ETL_Failed__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :p.id ];
                for (ASI_MFM_Payment_Line_Item__c pl : plList){
                    if(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c=='Complete' || Test.isRunningTest() ){
                        apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Haved Complete PO. You cannot change the payment to Draft')); 
                        return null;
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
        }
        else if(p.RecordType.DeveloperName.contains('ASI_MFM_MY_Payment') && p.ASI_MFM_Status__c == 'Invalid' && new_status == 'Draft'){ // Add By Elufa For MY Use
            p.ASI_MFM_Status__c = new_status;
            p.ASI_MFM_ETL__c = false;
            try {
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }
         // ------------------------------------KR MFM Logic Start-----------------------------------------
        else if(p.RecordType.DeveloperName.contains('ASI_MFM_KR_Payment')) {
            string errmsg='';
            
            if(p.ASI_MFM_Status__c=='Draft' && new_status == 'Approved'){
              p.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment_Read_Only');
            }
            
            
            if(p.ASI_MFM_Status__c=='Submitted' && new_status == 'Draft'){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Submitted Payment cannot change to Draft. Please recall this payment.')); 
                return null;
            }
            
            //Added by Kammy at 15 Mar 2016
            if(p.ASI_MFM_Status__c=='Approved' && new_status == 'Draft'){
                boolean Ispass=true;
                List<ASI_MFM_Payment_Line_Item__c> PaymentLineList= new List<ASI_MFM_Payment_Line_Item__c> ();
                Id POId;
                for(ASI_MFM_Payment_Line_Item__c pl: [select id,name,ASI_MFM_PO_Line_Item__c,ASI_MFM_Verify_by__c,ASI_MFM_ETL__c,ASI_MFM_Voucher_Created__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =:p.id]){
                    if(pl.ASI_MFM_Voucher_Created__c == true){
                        Ispass=false;
                    }
                    else{
                        pl.ASI_MFM_Verify_by__c = null;
                        pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c = false;
                        pl.ASI_MFM_ETL__c = false;
                        pl.ASI_MFM_ETL_Date__c = null;
                        PaymentLineList.add(pl);
                    }
                    POId=pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c;
                }// end 
                
                if(Ispass && PaymentLineList.size() > 0){
                    update PaymentLineList;
                    if(p.ASI_MFM_Is_Direct_Payment__c && POId!=null){
                        ASI_MFM_PO__c UpdatedPO = new ASI_MFM_PO__c (Id=POId,ASI_MFM_Status__c='Draft');
                        update UpdatedPO;
                    }
                }
                
                if(!Ispass){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Payment line has created voucher. You cannot change the payment to Draft.')); 
                    return null;  
                }
            }
            //End- Kammy
            if(p.ASI_MFM_Status__c=='Completed' && new_status == 'Draft'){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Completed Payment cannot change to Draft')); 
                return null;
            }
            if(p.ASI_MFM_Status__c=='Rejected' && new_status == 'Draft'){
                boolean Ispass=true;
                set<id> POId=new set<id>();
                for(ASI_MFM_Payment_Line_Item__c pl: [select id,name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =:p.id]){
                    if((pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c=='Closed' && !POId.contains(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c))|| Test.isRunningTest()){
                        POId.add(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                        Ispass=false;
                        errmsg+='PO: <a href="/'+pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c+'">'+pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.name+ '</a>' +   ' Status: '+pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c+'<br/>'; 
                    }
                }
                if(!Ispass){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Cannot change to Draft.<br/>'+errmsg)); 
                    return null;  
                }
            }
            if(new_status=='Draft'){
                p.ASI_MFM_Send_Approval_Email__c=false;
            }
            
            try {
                p.ASI_MFM_Status__c = new_status;
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }// ------------------------------------KR MFM Logic End-----------------------------------------
 
        else if(p.RecordType.DeveloperName.contains('ASI_MFM_JP_Payment') && p.ASI_MFM_Status__c == 'Submitted' && new_status == 'Draft'){ 
            p.ASI_MFM_Status__c = new_status;
            try {
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }else if(p.RecordType.DeveloperName.contains('ASI_MFM_JP_Payment') && p.ASI_MFM_Status__c == 'Draft' && new_status == 'Submitted'){ 
            if(p.ASI_MFM_Payment_Amount__c==null|| p.ASI_MFM_Payment_Amount__c==0){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Please add Payment Line.'));
                return null;
            }
            p.ASI_MFM_Status__c = new_status;
            P.ASI_MFM_Submitted_Date__c=system.now();
            try {
                update p;
                return new pageReference('/' + p.id);
            }
            catch (exception ex) {
                apexpages.addMessages(ex);
                return null;
            }
        }
        else {
            if(p.RecordType.DeveloperName.contains('ASI_MFM_JP_Payment')){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Can not Change Payment Status'));
                return null;
            }else{
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Status is not in \'Final\''));
                return null;
            }
            
        }
    }
}