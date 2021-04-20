public class ASI_MFM_KR_PRToolBarController {
    
    public ASI_MFM_Purchase_Request__c header                               {set;get;}
    public Id headerId                                          {set;get;}
    public Set<String>  brandGroups                             {set;get;}
    public Boolean checkAttachNeed {set;get;} 
    public List<String> brandGroupNames                         {set;get;}
    public String msg                                           {set;get;}
    public Decimal PlanRemainingAmount                          {set;get;}
    public Decimal AllRelatedPRAmount                           {set;get;}
    public Decimal relatedPREstimatedBudget                     {set;get;}
    public Decimal relatedApprovedPOAmount                      {set;get;}
    public Decimal ActSpendingAmount                            {set;get;}{ActSpendingAmount=0;}
    public Decimal currentPRBudget                              {set;get;}
    
    public ASI_MFM_KR_PRToolBarController (ApexPages.StandardController controller) {
        
        this.header = (ASI_MFM_Purchase_Request__c)controller.getRecord();
        this.headerId = this.header.Id;
        this.brandGroups = new Set<String>();
        this.brandGroupNames = new List<String>();
        
    }
    
    public void init(){
        checkAttachNeed = false;  
        relatedApprovedPOAmount = 0;
        AllRelatedPRAmount = 0;
        relatedPREstimatedBudget = 0;
        currentPRBudget  = 0;
        
        header = [Select id , Name,ASI_MFM_Plan__c, ASI_MFM_Status__c , ASI_MFM_Service_Item_POSM__c , ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c , ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c, ASI_MFM_Total_Amount__c, 	ASI_MFM_Exchange_Rate__c  from ASI_MFM_Purchase_Request__c where id=: this.headerId];
        
        
        if(header.ASI_MFM_Status__c!='Draft' ||header.ASI_MFM_Status__c!='Submitted' ||header.ASI_MFM_Status__c!='Rejected' )
                    currentPRBudget   = header.ASI_MFM_Exchange_Rate__c * header.ASI_MFM_Total_Amount__c;
        //Checking 2: PR Header: type is Service?     &&              PR Line: AP Code need attachment?
        for(ASI_MFM_Purchase_Request_Line__c prLine : [Select id ,
                                                       ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_PR__c,
                                                       ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c , ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name 
                                                       from ASI_MFM_Purchase_Request_Line__c where ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c!=null and ASI_MFM_Purchase_Request__c =: this.headerId] ){
                                                           
                                                           if(prLine.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_PR__c != NULL && header.ASI_MFM_Service_Item_POSM__c == 'Service'){
                                                               checkAttachNeed = true;
                                                           }
                                                           
                                                           brandGroups.add(prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name);
                                                       }
        
        brandGroupNames = new List<String>(brandGroups);
        
        List<Attachment> noOfAttachment = new List<Attachment>();
        
        noOfAttachment = [Select id from Attachment where parentId =: headerId];
        
        if(checkAttachNeed  && (noOfAttachment == null || noOfAttachment.size()==0))checkAttachNeed = true; else checkAttachNeed = false;  
        
        calculateRemainingPlanAmount();
    }
    
    public void calculateRemainingPlanAmount(){
        //Modified by Elufa PRA Support on 18 Jan 2017
        /*
            Current: 
            Sum of PR belonging to the same Plan for respective brand
            - If PR approved => sum of PR amount
            - If PR closed =>  sum of closed PO
            
            To be:
            Show "remaining Plan amount" in standard header instead of report. 
            To be defined as Plan - sum of PR belonging to the same Plan:
            - If PR submitted or approved => sum of PR amount
            - If PR closed =>  sum of approved/closed PO + roll-up of A&P card + direct payment PO
            If PR approved, sum of PR amount under than Plan
            If PR closed, sum of closed PO
            */
        PlanRemainingAmount = 0.0;
        msg ='';
        /*
        Decimal PlanAmount = header.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c!=null?header.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c:0;
        Decimal CorporateCardUsedAmount = header.ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c!=null?header.ASI_MFM_Plan__r.ASI_MFM_KR_AnP_RollupAmount__c:0;
		Decimal ApprovedPRAmount = 0; 
		Decimal PlanActualSpending = 0;        
        */
	        
        //Actual Spending for this Plan
        //
        //ASI_MFM_KR_ActSpendWrapClass returnedData = ASI_MFM_KR_PlanToolBarController.calculateActualSpendingAmount(header.ASI_MFM_Plan__c);
       // if(returnedData!=null){
		//		PlanActualSpending = returnedData.ASI_MFM_Amount;
       // }		
        
        //Approved PR Amount
        /*
        AllRelatedPRAmount = 0; 
        for(ASI_MFM_Purchase_Request_Line__c PRLine : [Select id,ASI_MFM_Amount_in_Local_Currency__c	
                                                        from ASI_MFM_Purchase_Request_Line__c
                                                        where (ASI_MFM_Purchase_Request__r.ASI_MFM_Status__c ='Approved'
                                                        OR ASI_MFM_Purchase_Request__r.ASI_MFM_Status__c ='Submitted'
                                                        OR ASI_MFM_Purchase_Request__r.ASI_MFM_Status__c ='Closed')
                                                        AND ASI_MFM_Purchase_Request__r.ASI_MFM_Plan__c =: header.ASI_MFM_Plan__c]){
                                                            
                                                            AllRelatedPRAmount += PRLine.ASI_MFM_Amount_in_Local_Currency__c!=null?PRLine.ASI_MFM_Amount_in_Local_Currency__c:0;
                                                        }
         
        AllRelatedPRAmount = AllRelatedPRAmount.setScale(0);
        PlanRemainingAmount  =  PlanAmount - AllRelatedPRAmount;
        msg = 'Plan Remaining Amount = Plan Amount('+ PlanAmount.setScale(0)+') - Submitted/Approved/Closed PR Amount('+ AllRelatedPRAmount.setScale(0)+')= ' ;
        //msg = 'Plan Remaining Amount = Plan Amount - Roll-up of A&P card - Approved PO Amount - Closed PO Payment Amount = ' ;
        //msg = 'Plan Remaining Amount = Plan amount('+ PlanAmount +') – (Plan Actual Spending('+ PlanActualSpending+') + Approved PR + Closed PR actual spending) = ';
   
                for(ASI_MFM_PO_Line_Item__c poLine : [Select id , ASI_MFM_BaseCurrencyAmount__c , ASI_MFM_PO__r.ASI_MFM_Status__c,
                                                      (select Id, Name,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,
                                                      ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c
                                                      from Payment_Line_Items__r where  
                                                      ASI_MFM_Payment__r.ASI_MFM_Status__c !='Submitted' and ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft' and ASI_MFM_Payment__r.ASI_MFM_Status__c!='Rejected')
                                                      from ASI_MFM_PO_Line_Item__c 
                                                      where ASI_MFM_PO__r.ASI_MFM_Purchase_Request__c =: header.Id 
                                                      ]){
                                                          if(poLine.ASI_MFM_PO__r.ASI_MFM_Status__c =='Approved')
                                                                relatedApprovedPOAmount+= poLine.ASI_MFM_BaseCurrencyAmount__c ;
                                                            else if(poLine.ASI_MFM_PO__r.ASI_MFM_Status__c =='Closed'){
                                                                    for(ASI_MFM_Payment_Line_Item__c paymentLine: poLine.Payment_Line_Items__r){
                                                                        if(paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Approved'||paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Closed')
                                                                        relatedApprovedPOAmount+= paymentline.ASI_MFM_Paid_Amount_in_Base_Currency__c !=null?paymentline.ASI_MFM_Paid_Amount_in_Base_Currency__c:0;
                                                                    }
                                                                }
                                                      }   
   
        currentPRBudget =  currentPRBudget.setScale(0);
        relatedApprovedPOAmount = relatedApprovedPOAmount.setScale(0);
        */
        if(header.ASI_MFM_Plan__c!=null){
            ASI_MFM_KR_ActSpendWrapClass ResultData=ASI_MFM_KR_PlanToolBarController.calculateActualSpendingAmount(header.ASI_MFM_Plan__c);
            ActSpendingAmount=ResultData.ASI_MFM_Amount;
            msg=ResultData.ASI_MFM_Message;            
            
        }

           
    }
    
    
    
}