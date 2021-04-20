public class ASI_MFM_KR_POSMSubmitController {
    
    //TWO Purposes for this Controller
    //1. Check if user input as least one POSM Line before "Submit for Aapproval"
    //2. Check if user upload at least one attachment for each POSM Line before "Submit for Aapproval"
    public String headerStatus {GET;SET;}
    List <ASI_KOR_POSM_Order_Detail__c> POSMlines =  new  List<ASI_KOR_POSM_Order_Detail__c>();
    Set<ID> POSMLinesIDset = new Set<ID>();
    Boolean checkAllLines ;
    public id headerID {GET;SET;}
    List <attachment> attach =  new  List<attachment>();
    
    public ASI_MFM_KR_POSMSubmitController(apexpages.standardController SubmitCtrl) {
        headerID =     SubmitCtrl.getId();
    }
    
    public pageReference setStatus() { 
        
        headerStatus = [select id, ASI_KOR_Status__c  from ASI_KOR_POSM_Order_Request__c where id =: headerID].ASI_KOR_Status__c;
        
        //Check status
        if(headerStatus == 'Draft'){
            POSMlines = [select id, name, ASI_KOR_POSM_Order_Request__c 
                         from ASI_KOR_POSM_Order_Detail__c 
                         where ASI_KOR_POSM_Order_Request__c = :headerID ];                          
            for (ASI_KOR_POSM_Order_Detail__c lines: POSMlines){
                POSMLinesIDset.add(lines.id);
            }
            if(POSMLinesIDset.size() == 0 ){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Please add at least one line before approval.'));
            }            
        }
        
        
        
        
        
        TRY{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(headerID);
            Approval.ProcessResult result = Approval.process(req1);
            return new pageReference('/' +headerID );
        }catch  (DmlException dmle){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, dmle.getMessage()));
            return null;
        }catch  (Exception e){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, e.getMessage()));
            return null;
        }
        
        
    }
    
}