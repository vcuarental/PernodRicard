public class ASI_MFM_PaymentSubmitController {
    ASI_MFM_Payment__c p = new ASI_MFM_Payment__c();
    public String Msg{get;set;}{Msg='';}
    public boolean HasError {get;set;}{HasError=false;}
    public boolean Overspendt {get;set;}{Overspendt=false;}
    public string CheckingMsg {get;set;} {CheckingMsg= '';}
    
    public ASI_MFM_PaymentSubmitController(apexpages.standardController sc) {
        
        p = [select id, ASI_MFM_Send_Approval_Email__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_AP_Remark__c,ASI_MFM_KR_VAT_Amount__c,ASI_MFM_KR_TotalPayAmtIncludeVAT__c,ASI_MFM_Status__c,recordTypeId,RecordType.DeveloperName,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_ByPass_Amount_Checking__c,
             ASI_MFM_Dummy_Payment__c,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
             ASI_MFM_Need_Attachment__c,ASI_MFM_Payment_Amount__c, ASI_MFM_Cash_Out_Payment__c from ASI_MFM_Payment__c where id = :sc.getId()]; 
    }
    
    public pageReference proceed() {
        if(p.RecordType.DeveloperName.contains('ASI_MFM_SG_Payment')) {
            // Check Attchment number
            Integer numAtts=0;
            numAtts=[select count() from attachment where parentid =: p.id];
            if(numAtts> 0){ //Only If attchment number bigger than 0, it can submit
                p.ASI_MFM_Send_Approval_Email__c=true;
                update p;    //update Flag
                //Submit for approval
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(p.id);
                Approval.ProcessResult result = Approval.process(req1);
                return new pageReference('/' + p.id);
            }else{
                // If there is no attchment 
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Attachment is needed before approval.'));
                return null;
            }
            
        }else if(p.RecordType.DeveloperName.contains('ASI_MFM_KR_Payment')) {
            Msg='<strong>Submit for Approval Failed: </strong><br/>';
            HasError=false;
            
            Set<String> AttachmentTypeSet = new Set<String>();
            List<ASI_MFM_Payment_Line_Item__c> PayList=[select id,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c=:p.id  ];
            for(ASI_MFM_Payment_Line_Item__c pl: PayList){
                AttachmentTypeSet.add(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Payment_Request__c );
            }
            
            if(p.ASI_MFM_Payment_Amount__c==null){
                HasError=true;
                Msg+='☹ Payment Amount has to be larger than zero.<br/>';//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Payment Amount has to be larger than zero.'));
                
            }
            
            if(p.ASI_MFM_Status__c=='Submitted'){
                HasError=true;
                Msg+= '☹ Payment status is Submitted, can not submit for Approval again. <br/>';//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Payment status is Submitted, can not submit for Approval again. '));
                
            } // 	 
            
            
            if(p.ASI_MFM_KR_VAT_Amount__c<0){
                HasError=true;
                Msg+= '☹ We found that VAT Amount <0, you can not submit this payment for Approval. <br/>';
                
            }
            
            if(p.ASI_MFM_AP_Remark__c==null){
                HasError=true;
                Msg+= '☹ We found AP Remark is blank in your Payment header, you can not submit this payment for Approval. <br/>';
                
            }
            
            if(p.ASI_MFM_KR_TotalPayAmtIncludeVAT__c==Null){
                HasError=true;
                Msg+= '☹ We found that Total Payment Amount (Including VAT) is blank, you can not submit this payment for Approval.<br/> ';
                
            }else{
                if(p.ASI_MFM_KR_TotalPayAmtIncludeVAT__c<p.ASI_MFM_Payment_Amount__c){
                     HasError=true;
                     Msg+= '☹ We found that Total Payment Amount (Including VAT) < Payment, you can not submit this payment for Approval. <br/>';
                     
                }
            }
            
            if(p.ASI_MFM_Status__c=='Rejected'){
                HasError=true;
                Msg+='☹ We found that payment status is Rejected, Please set draft and submit for approval again. <br/>';//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Payment status is Rejected, Please set draft and submit for Approval again. '));
                
            } 
            
            if(PayList.size()==0){
                HasError=true;
                Msg+='There is no payment Line, cannot submit for approval.<br/> ';//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'There is no payment Line, cannot submit for approval. '));
                
            } 
            
            if(p.ASI_MFM_Is_Direct_Payment__c){
                if(!ASI_MFM_Function.bypassTriggersFunctionCache('KR_MFMDirectPaymentSubApproval') && !p.ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_ByPass_Amount_Checking__c){
                    decimal PB= GenPlanBalance();
                    if(PB<0){
                        HasError=true;
                        Overspendt=true;
                        
                        Msg +='<br/>Sorry, we found that the  Plan Balance is '+FormatNumber(PB)+CheckingMsg+'.  Cannot Sumbit for Approval. <br/>Please contact plan owner to revise plan amount and then you can re-submit for approval, thank you.<br/>' ;//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Plan Balance: '+PB+'.   Cannot Sumbit for Approval.'));
                        
                    }
                }
            }
            
            //Cash Out payment need attachment //introv 20180117
            if(p.ASI_MFM_Cash_Out_Payment__c){
               p.ASI_MFM_Need_Attachment__c = true; 
            }
            
            //Attachment checking
            if(p.ASI_MFM_Need_Attachment__c){
                Integer numAtts=0;
                numAtts=[select count() from attachment where parentid =: p.id];
                if(numAtts==0){ //Only If attchment number bigger than 0, it can submit
                   // If there is no attchment 
                    List<String> listStrings = new List<String>();
                    
                    if(AttachmentTypeSet!=null && AttachmentTypeSet.size()>0){
                        listStrings = new List<String>(AttachmentTypeSet);
                    }
                    HasError=true;
                    Msg+='Need attachment: ( '+String.join(listStrings, ',')+' ) before approval.'  ;apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Need attachment: ( '+String.join(listStrings, ',')+' ) before approval.<br/>'));
                    
                }
            }
            
            if(!HasError){
                submitforapproval();
                return new pageReference('/' + p.id);
            }else{
                return Null;
            }
            
        }//End of KR MFM Payment case
        else{
            return new pageReference('/' + p.id);
        }
    }
    
    //KR MFM Send email to Plan Owner
    
    public void sendEmail(){
        HasError=false;
        Msg='';
        Id templateId;
        String templateApiName = 'ASI_MFM_KR_Plan_Overspending_Email';     //  Set Email template          
        try {
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
        }catch (Exception e) {
            Msg=' Unable to locate EmailTemplate using name: ' + templateApiName ;
        }
        
        List <String> ToAddresses = new List <String>();  
        ToAddresses.add(p.ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c);
        
        
        //send email 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setTargetObjectId(System.UserInfo.getUserId());
        email.setToAddresses( ToAddresses );
        email.setWhatId(p.ASI_MFM_Plan__c);
        email.setSaveAsActivity(false); 
        email.setBccSender(false);
        email.setUseSignature(false);
        email.setTemplateId(templateId);
        try {
            if(!Test.isRunningTest()){     
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            HasError=false;
            Msg='An email notification has been sent to Plan owner, thank you.';
        }catch (Exception e) {
            HasError=true;
            Msg=e.getMessage();
        }
    }
    
    
    public Decimal GenPlanBalance (){
        CheckingMsg='';
        ASI_MFM_Setting__c  Checking =   [select ASI_MFM_KR_PO_Level1_Amount__c , ASI_MFM_KR_PO_Level1_Checking__c , 
                          ASI_MFM_KR_PO_Level2_Amount__c  , ASI_MFM_KR_PO_Level2_Percent__c ,
                          ASI_MFM_KR_PR_Level1_Amount__c , ASI_MFM_KR_PR_Level1_Checking__c , ASI_MFM_KR_PR_Level2_Amount__c  , 
                          ASI_MFM_KR_PR_Level2_Percent__c  from ASI_MFM_Setting__c ][0];
        
        ASI_MFM_KR_ActSpendWrapClass ResultData=ASI_MFM_KR_PlanToolBarController.calculateActualSpendingAmount(p.ASI_MFM_Plan__c);
        decimal ActSpendingAmount=ResultData.ASI_MFM_Amount;
        
        Decimal PlanBalance=0.0;
        Decimal PlanAmount =p.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c  !=null ? p.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c  :0.0;
        Decimal PaymentAmount= p.ASI_MFM_Payment_Amount__c!=null ? p.ASI_MFM_Payment_Amount__c*p.ASI_MFM_Exchange_Rate__c  :0.0; // Decimal POAmount = p.ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c  !=null ? p.ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c  :0.0;//Decimal AnPAmount =p.ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c  !=null ? p.ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c  :0.0;
        
        if(PlanAmount < Checking.ASI_MFM_KR_PO_Level1_Checking__c){
            PlanBalance=PlanAmount +Checking.ASI_MFM_KR_PO_Level1_Amount__c-ActSpendingAmount-PaymentAmount;
             CheckingMsg+='<br/>  PlanBalance( '+FormatNumber(PlanBalance.SetSCale(0))+')= Plan Amount ( '+FormatNumber(PlanAmount.SetSCale(0))+')+ Tolerance Amount( '+FormatNumber(Checking.ASI_MFM_KR_PO_Level1_Amount__c)
                +') - Actual Spending Amount('+FormatNumber(PaymentAmount.SetSCale(0))+')-Current Payment Acmount('+FormatNumber(PaymentAmount.SetSCale(0))+ ') <br/>  ';
        }else{
            PlanBalance=PlanAmount+Checking.ASI_MFM_KR_PO_Level2_Amount__c-ActSpendingAmount-PaymentAmount;//POAmount-AnPAmount;
            if(PlanBalance<0){
                CheckingMsg+='<br/>  PlanBalance( '+FormatNumber(PlanBalance)+')= Plan Amount ( '+FormatNumber(PlanAmount.SetSCale(0))+')+ Tolerance Amount( '+FormatNumber(Checking.ASI_MFM_KR_PO_Level2_Amount__c)
                    +') - Actual Spending Amount ( '+FormatNumber(PaymentAmount.SetSCale(0))+') - Current Payment Amount ( '+FormatNumber(PaymentAmount.SetSCale(0))+ ') <br/> ';
            }
            Decimal percentage = Checking.ASI_MFM_KR_PO_Level2_Percent__c/100;
            PlanBalance=PlanAmount*(1+percentage)-ActSpendingAmount-PaymentAmount;//POAmount-AnPAmount;
           	if(PlanBalance<0){
                CheckingMsg+='<br/>  PlanBalance( '+FormatNumber(PlanBalance.SetSCale(0))+')= Plan Amount ( '+FormatNumber(PlanAmount.SetSCale(0))+') *(1+ '+String.valueOf(percentage)+ ' )- Actual Spending Amount  ( '+FormatNumber(PlanBalance.SetSCale(0))+') -  Current Payment Acmount ( '+FormatNumber(PaymentAmount.SetSCale(0))+ ') <br/>  ';
            }
        }
        return PlanBalance;    
    }
    
    
    // format number with comma in apex
    public string FormatNumber(Decimal InputNumber ){
        List<String> args = new String[]{'0','number','###,###,##0.00'};
            String str = String.format(InputNumber.format(), args);
        return str;
        
    }
    
    public void submitforapproval(){ 
        p.ASI_MFM_Send_Approval_Email__c=true;
        update p; 
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(p.id);
        Approval.ProcessResult result = Approval.process(req1);
        
    }
}