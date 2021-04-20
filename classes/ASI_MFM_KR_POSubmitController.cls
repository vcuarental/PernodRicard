/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                                                                                                        
|     - Object(s)       | PO                                                                       
|     - Description     | PO submit for approval   :
|                       | System block approval of PO or Direct Payment amount if spend goes over Plan amount tolerance threshold defined as:
|                       | For Plan < 50M => tolerance of 5 M KRW 
|                       | For Plan > 50M => tolerance of 10% OR 20M KRW
|                       | ***************************************************************************************
|                       | For Plan < 50M =>
|                       | Plan Balance= PlanAmount+5M-Total PO amount - roll-up of A&P card
|                       | For Plan > 50M =>
|                       | Case 1)
|                       |       Plan Balance= PlanAmount+20M	-Total PO amount - roll-up of A&P card
|                       | Case 2)
|                       |        Plan Balance= PlanAmount*1.1 	-Total PO amount - roll-up of A&P card
|                       | ***************************************************************************************
|                       | Actual spend for this Plan (=PO approved/closed + roll-up of A&P card + Direct payment PO) + new PO > tolerance level => system block and  send an email notification to Plan owner.
|                       | Plan owner then needs to update Plan with "excess amount", go through new approval routing (standard email for "Plan additional amount" to approvers), 
|                       | and after approval completed Purchasing is notified by email to move on PO approval.
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         |10/01/2016                                                                      
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         | MFM P2
+-----------------------+------------------------------------------------------------------------------------+
|Note                   |       1 million =1,000,000                                                                              
+-----------------------+------------------------------------------------------------------------------------+
*/


public class ASI_MFM_KR_POSubmitController {
    
    ASI_MFM_PO__c p = new ASI_MFM_PO__c(); // public Decimal PlanBalance{get;set;}{PlanBalance= 0;}
    public String Msg{get;set;}{Msg='';}
    public boolean HasError {get;set;}{HasError=false;}
    public boolean Overspendt {get;set;}{Overspendt=false;} //Plan Overspendt 
    public boolean PROver {get;set;}{PROver=false;} //Plan Overspendt  
    
    public string CheckingMsg {get;set;} {CheckingMsg= '';}
    public string PRMsg {get;set;} {PRMsg= '';}
    public ASI_MFM_Setting__c Checking {get;set;} {Checking = new ASI_MFM_Setting__c();}
    public ASI_MFM_KR_POSubmitController(apexpages.standardController sc) {
        Msg='';
        p = [select Id,Name,ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Plan__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_ByPass_Amount_Checking__c,ASI_MFM_PO_Amount__c,ASI_MFM_Status__c,ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Dummy_PO__c,ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c,ASI_MFM_Purchase_Request__c,
             ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
             ASI_MFM_PO_Amount_in_Base_Currency__c from ASI_MFM_PO__c where id = :sc.getId()];
    }
    
    
    
    public pageReference submit() {
        Msg='<strong>Submit for Approval Failed: </strong>';
        
        //Check 1: check Status
        if(p.ASI_MFM_Status__c!='Draft'){
            HasError=true;
            Msg+='Status: '+p.ASI_MFM_Status__c+'.   Cannot Sumbit for Approval.';
            return null;
        }
        
        //Check 2: Direct Payment no need submit for approval
        if(p.ASI_MFM_Is_Direct_Payment__c){
            HasError=true;
            Msg+='This PO is generated from Direct Payment. No need to submit for approval, thank you.';
            return null;
        }
        
        //Check 3: Dummy PO no need submit for approval
        if(p.ASI_MFM_Dummy_PO__c){
            HasError=true;
            Msg+='This PO is Dummy PO. No need to submit for approval, thank you.';
            return null;
        }
        
        //Check 4: Amount checking
        if(!ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_KR_POSubmitApproval') && !p.ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_ByPass_Amount_Checking__c){
            Checking =   [select ASI_MFM_KR_PO_Level1_Amount__c , ASI_MFM_KR_PO_Level1_Checking__c , 
                          ASI_MFM_KR_PO_Level2_Amount__c  , ASI_MFM_KR_PO_Level2_Percent__c ,
                          ASI_MFM_KR_PR_Level1_Amount__c , ASI_MFM_KR_PR_Level1_Checking__c , ASI_MFM_KR_PR_Level2_Amount__c  , 
                          ASI_MFM_KR_PR_Level2_Percent__c  from ASI_MFM_Setting__c ][0];
            
            decimal PB= GenPlanBalance();//Plan Balance 
            
            if(PB<0){
                HasError=true;
                Overspendt=true;
                Msg +='<br/>☹ We found that the Plan Balance is OverSpent:'+CheckingMsg;//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Plan Balance: '+PB+'.   Cannot Sumbit for Approval.')); 
                
            }
            
            if(GenPRBalance()){
                HasError=true;
                PROver=true;
                Msg +='<br/>☹ We found that the PR Balance is OverSpent:'+PRMsg;
                
            }
            
            if(Overspendt){
                Msg+='<br/>☹ You cannot sumbit this PO for approval. <br/>Please contact Plan/PR owner to revise amount and then you can re-submit for approval, thank you.' ;
                
            }
        }
        
        if(HasError){
            return null; 
        }
        
        Approvalprocess();
        return new pageReference('/' + p.id);
    }
    
    
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
        
        String BccAddresses='pra.sfdc.uat@gmail.com'; 
        //send email 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setTargetObjectId(System.UserInfo.getUserId());
        email.setToAddresses( ToAddresses );
        email.setWhatId(p.ASI_MFM_Plan__c);
        email.setBccAddresses(new String[] {BccAddresses});
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
    
    
    
    // format number with comma in apex
    public string FormatNumber(Decimal InputNumber ){
        List<String> args = new String[]{'0','number','###,###,##0.00'};
            String str = String.format(InputNumber.format(), args);
        return str;
        
    }
    
    
    
    public Boolean GenPRBalance (){
        Decimal POAmount = 0.0;
        Boolean OverBalance= false;
        Decimal currentPOAmount = 0.0;
        Decimal CurrentPOLineAmount=0;
        Decimal actualSpending = 0.0;
        
        List<ASI_MFM_PO_Line_Item__c> polist = [select id,name,ASI_MFM_BaseCurrencyAmount__c,ASI_MFM_Amount_Local_Currency__c,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c,
                                                (select Id, Name,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c from Payment_Line_Items__r where  ASI_MFM_Payment__r.ASI_MFM_Status__c ='Complete' or ASI_MFM_Payment__r.ASI_MFM_Status__c ='Closed' or ASI_MFM_Payment__r.ASI_MFM_Status__c ='Approved')
                                                from ASI_MFM_PO_Line_Item__c 
                                                where  ASI_MFM_PO__r.ASI_MFM_Purchase_Request__c =:p.ASI_MFM_Purchase_Request__c and RecordType.DeveloperName like 'ASI_MFM_KR%' 
                                                and ((ASI_MFM_PO__r.ASI_MFM_Status__c='Approved' or ASI_MFM_PO__r.ASI_MFM_Status__c='Closed' ) or ASI_MFM_PO__c=:p.Id) ];
        
        for(ASI_MFM_PO_Line_Item__c pol:polist){
            
            if(pol.ASI_MFM_PO__c==p.Id){ // current PO
                CurrentPOLineAmount =pol.ASI_MFM_BaseCurrencyAmount__c;
                currentPOAmount +=pol.ASI_MFM_BaseCurrencyAmount__c;
            }else{
                if(pol.ASI_MFM_PO__c!=p.Id && pol.ASI_MFM_PO__r.ASI_MFM_Status__c=='Approved' && !pol.ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c && pol.ASI_MFM_BaseCurrencyAmount__c !=null ){
                    CurrentPOLineAmount=pol.ASI_MFM_BaseCurrencyAmount__c.SetSCale(2);
                    actualSpending +=pol.ASI_MFM_BaseCurrencyAmount__c;
                }else if (pol.ASI_MFM_PO__r.ASI_MFM_Status__c=='Closed'){  //Closed Status
                    for(ASI_MFM_Payment_Line_Item__c payl:pol.Payment_Line_Items__r){
                        if(payl.ASI_MFM_Paid_Amount_in_Base_Currency__c!=null){
                            actualSpending +=payl.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                            CurrentPOLineAmount+=payl.ASI_MFM_Paid_Amount_in_Base_Currency__c.SetSCale(2);
                        }
                    }
                }
            }            
            POAmount+=CurrentPOLineAmount;
        }
        
        PRMsg='';  
        Decimal PRBalance=0.0;
        Decimal PRAmount=0.0;
        if(p.ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c!=null && p.ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c!=null  ){
            PRAmount= p.ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c*p.ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c;
        }else{
            PRAmount=0.0;
        }
        
        //PR Checking
        Decimal percentage = Checking.ASI_MFM_KR_PR_Level2_Percent__c/100;
        PRBalance=PRAmount+Checking.ASI_MFM_KR_PR_Level1_Amount__c-POAmount;
        
        Decimal RestPRBalance = 0.0;
        currentPOAmount = p.ASI_MFM_PO_Amount_in_Base_Currency__c!=null ?p.ASI_MFM_PO_Amount_in_Base_Currency__c:0.0;
        RestPRBalance =  PRAmount - actualSpending ;        
        
        
        if(currentPOAmount > (RestPRBalance + Checking.ASI_MFM_KR_PR_Level1_Amount__c) ){
        //if(PRBalance<0){
            // this is checking + ASI_MFM_KR_PR_Level1_Amount__c

            PRMsg+='<br/>  This Total PO Amount ('+  FormatNumber(currentPOAmount.SetSCale(0))+') > Rest Purchase Request Budget ( '+FormatNumber(RestPRBalance.SetSCale(0))+') + Tolerance Amount( '+FormatNumber(Checking.ASI_MFM_KR_PR_Level1_Amount__c.SetSCale(0))+') <br/>  ';
            /*
            PRMsg+='<br/>  Purchase Request Balance( '+FormatNumber(PRBalance.SetSCale(0))+')= Purchase Request Amount ( '+FormatNumber(PRAmount.SetSCale(0))+')+ Tolerance Amount( '+FormatNumber(Checking.ASI_MFM_KR_PR_Level2_Amount__c.SetSCale(0))
                +') - PO Amount ( '+FormatNumber(POAmount.SetSCale(0))+') <br/>  ';
            */
            OverBalance=true;
        }
        
        
        PRBalance=PRAmount*(1+percentage)-POAmount;
        
        if(currentPOAmount > (RestPRBalance + PRAmount * (1+percentage ))){
        //if(PRBalance<0){
            // this is checking +ASI_MFM_KR_PR_Level2_Percent__c

            PRMsg+='<br/> This Total PO Amount ('+  FormatNumber(currentPOAmount.SetSCale(0))+') > Rest Purchase Request Budget ( '+FormatNumber(RestPRBalance.SetSCale(0))+') + Purchase Request Amount ( '+FormatNumber(PRAmount.SetSCale(0))+') *(1+ '+String.valueOf(percentage)+ ' ) <br/>  ';

   
            //PRMsg+='<br/>  Purchase Request Balance( '+FormatNumber(PRBalance.SetSCale(0))+')= Purchase Request Amount ( '+FormatNumber(PRAmount.SetSCale(0))+') *(1+ '+String.valueOf(percentage)+ ' )- PO Amount ( '+FormatNumber(POAmount.SetSCale(0))+') <br/>  ';
            
            OverBalance=true;
        }
        
        
        return OverBalance;
    }
    
    
    
    
    
    
    public Decimal GenPlanBalance (){
        CheckingMsg='';
        
        ASI_MFM_KR_ActSpendWrapClass ResultData=ASI_MFM_KR_PlanToolBarController.calculateActualSpendingAmount(p.ASI_MFM_Plan__c);
        decimal ActSpendingAmount=ResultData.ASI_MFM_Amount;
        
        Decimal PlanBalance=0.0;
        Decimal PlanAmount =p.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c  !=null ? p.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c  :0.0;
        Decimal POAmount = p.ASI_MFM_PO_Amount__c  !=null ? p.ASI_MFM_PO_Amount__c*p.ASI_MFM_Exchange_Rate__c :0.0;
        // Decimal AnPAmount =p.ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c  !=null ? p.ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c  :0.0;
        
        
        if(PlanAmount < Checking.ASI_MFM_KR_PO_Level1_Checking__c){
            PlanBalance=PlanAmount +Checking.ASI_MFM_KR_PO_Level1_Amount__c-ActSpendingAmount-POAmount;// -current PO Amount
            CheckingMsg='<br/>  PlanBalance('+FormatNumber(PlanBalance.SetSCale(0))+')= Plan Amount ('+FormatNumber(PlanAmount.SetSCale(0))+')+ Tolerance Amount('+FormatNumber(Checking.ASI_MFM_KR_PO_Level1_Amount__c)
                +') - Actual Spending Amount ('+FormatNumber(ActSpendingAmount.SetSCale(0))+') - Current PO Amount ('+FormatNumber(POAmount.SetSCale(0))+')<br/>  ';
            
        }else{
            
            Decimal percentage = Checking.ASI_MFM_KR_PO_Level2_Percent__c/100;
            PlanBalance=PlanAmount+Checking.ASI_MFM_KR_PO_Level2_Amount__c-POAmount-ActSpendingAmount;
            if(PlanBalance<0){
                CheckingMsg='<br/>  PlanBalance('+FormatNumber(PlanBalance.SetSCale(0))+')= Plan Amount ( '+FormatNumber(PlanAmount.SetSCale(0))+')+ Tolerance Amount( '+FormatNumber(Checking.ASI_MFM_KR_PO_Level2_Amount__c)
                    +')- Actual Spending Amount ('+FormatNumber(ActSpendingAmount.SetSCale(0))+')  - Current PO Amount ('+FormatNumber(POAmount.SetSCale(0))+') <br/>  ';
            }
            
            PlanBalance=PlanAmount*(1+percentage)-POAmount-ActSpendingAmount;
            if(PlanBalance<0){
                CheckingMsg='<br/>  PlanBalance('+FormatNumber(PlanBalance.SetSCale(0))+')= Plan Amount ('+FormatNumber(PlanAmount.SetSCale(0))+') *(1+ '+String.valueOf(percentage)+ ' )- Actual Spending Amount( '+FormatNumber(ActSpendingAmount.SetSCale(0))+') - Current PO Amount ('+FormatNumber(POAmount.SetSCale(0))+')<br/>  ';//-  Roll-Up A&P Card Amount ( '+FormatNumber(AnPAmount)+ ')
                
            }
        }
        
        return PlanBalance;    
    }
    
    
    public void Approvalprocess() {
        
        // Submit for Approval
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(p.id);
   
            try{
                Approval.ProcessResult result = Approval.process(req1);
            }catch(exception ex){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error,  ex.getMessage()));
                Msg=ex.getMessage();
            }

    }
    
    
}