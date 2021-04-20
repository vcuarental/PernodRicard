public class ASI_MFM_POSubmitController {
    string new_status;
    ASI_MFM_PO__c p = new ASI_MFM_PO__c();
    public ASI_MFM_POSubmitController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        p = [select id,ASI_MFM_Submit_for_Approval__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_PO_Amount__c,ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id = :sc.getId()];
    }
    
    
    public pageReference submit() {
        if(p.RecordType.DeveloperName.contains('ASI_MFM_MY_PO')) {
            Integer numAtts=0;
            numAtts=[select count() from attachment where parentid =: p.id];
            
            
            if(p.ASI_MFM_Base_Currency_Amount__c>0){  // || p.ASI_MFM_PO_Amount__c>0
                if(p.ASI_MFM_Base_Currency_Amount__c>50000){
                    if(numAtts>3){
                        Approvalprocess();
                        return new pageReference('/' + p.id);
                    }else{
                        if(!Test.isRunningTest()){ 
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, '4 Attachments are needed before approval.'));
                        }
                        return null;
                    }
                }else if(p.ASI_MFM_Base_Currency_Amount__c>10000 && p.ASI_MFM_Base_Currency_Amount__c<50000){
                    if(numAtts>1){
                        Approvalprocess();
                        return new pageReference('/' + p.id);
                    }else{
                        if(!Test.isRunningTest()){ 
                            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, '2 Attachments are needed before approval.'));
                        }
                        return null;
                    }
                }else{
                    Approvalprocess();
                    return new pageReference('/' + p.id);
                }
                
            }else{
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'PO Amount has to be larger than zero'));
                return null;
            }
        }else{
            return new pageReference('/' + p.id);
        }
    }
    
    public void Approvalprocess() {
        p.ASI_MFM_Submit_for_Approval__c=true;
        update p;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(p.id);
        if(!Test.isRunningTest()){ 
            Approval.ProcessResult result = Approval.process(req1);
        }
    }
}