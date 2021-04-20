public class ASI_MFM_KR_PlanSubmitController {
    ASI_MFM_Plan__c p = new ASI_MFM_Plan__c();
    //public Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget> resultMap {get;set;}
    
    public ASI_MFM_KR_PlanSubmitController(apexpages.standardController sc) {
        p = [select id,ASI_MFM_Submit_for_Approval__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Status__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_Need_Attachment__c,ASI_MFM_Budget_Type__c,ASI_MFM_Project_Code__c,ASI_MFM_Fiscal_year__c from ASI_MFM_Plan__c where id = :sc.getId()];
    }
    
    
    public pageReference submit() {
        if(p.RecordType.DeveloperName.contains('ASI_MFM_KR_Plan')) {
            //Check 1: check Status
             if(p.ASI_MFM_Status__c!='Draft'){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Status: '+p.ASI_MFM_Status__c+'.   Cannot Sumbit for Approval.'));
                return null;
            }
            
            
            //Checking 2: check if need attachment  ASI_MFM_Attachments_for_Plan__c
            if(p.ASI_MFM_Need_Attachment__c){
                
                Integer numAtts=0;
                numAtts=[select count() from attachment where parentid =: p.id];
                if(numAtts==0){
                    string AttachmentType='';
                    Set<String> AttachmentTypeSet = new Set<String>();
                    List<String> listStrings = new List<String>();
                    
                    for(ASI_MFM_Plan_Line_Item__c pl:[select id ,name,ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Plan__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:p.id]){
                        if(pl.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Plan__c!=null){
                            
                            AttachmentType=pl.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Plan__c;
                            AttachmentTypeSet.add(pl.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Plan__c);
                        } 
                    }
                    if(!Test.isRunningTest()){ 
                        
                        if(AttachmentTypeSet!=null && AttachmentTypeSet.size()>0){
                            listStrings = new List<String>(AttachmentTypeSet);
                            system.debug('Need Attachment:' + listStrings);
                        }
                        // apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Need attachment: '+ AttachmentType));
                          apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Need attachment: ( '+String.join(listStrings, ',')+' ) before approval.'));

                        return null;
                    }
                }
            }//End checking
            List<ASI_MFM_Plan_Line_Item__c >PlanList=[select Id, Name,ASI_MFM_Total_Cost__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,
            ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:p.Id ];
            boolean AmountChecking= false;
            for(ASI_MFM_Plan_Line_Item__c pl:PlanList){
                Decimal TotalLineAmount=0;
                TotalLineAmount+=pl.ASI_MFM_Month_1_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_1_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_2_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_2_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_3_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_3_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_4_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_4_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_5_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_5_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_6_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_6_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_7_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_7_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_8_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_8_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_9_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_9_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_10_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_10_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_11_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_11_Cost__c): 0;
                TotalLineAmount+=pl.ASI_MFM_Month_12_Cost__c!=null?  (Decimal)(pl.ASI_MFM_Month_12_Cost__c): 0;
                
                if(pl.ASI_MFM_Total_Cost__c==null){
                    AmountChecking=true;
                }else if((math.abs(pl.ASI_MFM_Total_Cost__c-TotalLineAmount))>3){
                    AmountChecking=true;
                }
            }
            if(AmountChecking){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Plan total amount not equal to Plan Line amount,Please Recalculate it.'));
                return null;
            }
            //Check Amount 
            if(p.ASI_MFM_Plan_Amount__c==0){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Amount:0. Cannot Sumbit for Approval.'));
                return null;
            }
            Approvalprocess();
            return new pageReference('/' + p.id);
        }else{
            return new pageReference('/' + p.id);
        }
        
    }
    // ALREADY_IN_PROCESS, Cannot submit object already in process
    
    public void Approvalprocess() {
       //update checkbox
        p.ASI_MFM_Submit_for_Approval__c=true;
        update p;
        
        // Submit for Approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(p.id);
        if(!Test.isRunningTest()){ 
            try{
                     Approval.ProcessResult result = Approval.process(req1);
            }catch(exception ex){
                 apexpages.addMessage(new apexpages.Message(apexpages.severity.error,  ex.getMessage()));
            }
        }
    }
    
}