public without sharing class ASI_MFM_KR_PlanToolBarController {
    
    public ASI_MFM_Plan__c header                               {set;get;}
    public Id headerId                                          {set;get;}
    public Set<String>  brandGroups                             {set;get;}
    public List<String> brandGroupNames                         {set;get;}
    public Boolean overBudget                                   {set;get;}
    public Boolean needAttachment                               {set;get;}
    public String msg                                           {set;get;}{msg='';}
    public Decimal ActSpendingAmount                          {set;get;}{ActSpendingAmount=0;}
    
    public ASI_MFM_KR_PlanToolBarController (ApexPages.StandardController controller) {
        
        this.header = (ASI_MFM_Plan__c)controller.getRecord();
        this.headerId = this.header.Id;
        this.brandGroups = new Set<String>();
        this.brandGroupNames = new List<String>();
        
    }
    
    public void init(){
        
        
        header = [Select id , Name, ASI_MFM_Plan_Amount__c,ASI_MFM_Status__c,ASI_MFM_Need_Attachment__c from ASI_MFM_Plan__c where id=: this.headerId];
        
        overBudget = false;
        
        needAttachment = header.ASI_MFM_Need_Attachment__c? true: false;
        
        List<Attachment> noOfAttachment = new List<Attachment>();
        
        noOfAttachment = [Select id from Attachment where parentId =: headerId];
        
        if(needAttachment  && (noOfAttachment == null || noOfAttachment.size()==0)) needAttachment = true; else needAttachment = false;
        
        for(ASI_MFM_Plan_Line_Item__c planLine : [Select 
                                                  ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_Plan__c, 
                                                  id ,ASI_MFM_Sub_brand_Code__c , ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name ,ASI_MFM_Over_Budget__c 
                                                  from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c!=null and ASI_MFM_Plan__c =: this.headerId order by ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name ] ){
                                                      if(planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name!=null){
                                                          brandGroups.add(planLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name);
                                                      }
                                                      if(planLine.ASI_MFM_Over_Budget__c) overBudget = true;
                                                  }
        
        brandGroupNames = new List<String>(brandGroups);
        ASI_MFM_KR_ActSpendWrapClass ResultData=calculateActualSpendingAmount(header.Id);
        ActSpendingAmount=ResultData.ASI_MFM_Amount;
        msg=ResultData.ASI_MFM_Message;
    }
    
    public static ASI_MFM_KR_ActSpendWrapClass calculateActualSpendingAmount(Id InputPlan){
        //SQL
        ASI_MFM_Plan__c Plan =[select Id,ASI_MFM_Status__c,ASI_MFM_KR_AnP_RollupAmount__c from ASI_MFM_Plan__c where id= :InputPlan];//List<ASI_MFM_PO__c> POList = [select Id,ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_Is_Direct_Payment__c from ASI_MFM_PO__c where ASI_MFM_Plan__c = : InputPlan];
        
        List<ASI_MFM_PO_Line_Item__c> POLineList= [select Id,Name,ASI_MFM_BaseCurrencyAmount__c,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Amount__c,
                                                   (select Id, Name,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c from Payment_Line_Items__r where  ASI_MFM_Payment__r.ASI_MFM_Status__c ='Complete' or ASI_MFM_Payment__r.ASI_MFM_Status__c ='Approved')
                                                   from ASI_MFM_PO_Line_Item__c 
                                                   where ASI_MFM_PO__r.ASI_MFM_Plan__c=:InputPlan];
        
        Decimal DirectPaymentAmount = 0.0; // Status is approved
        Decimal ApprovedPOAmount = 0.0;
        Decimal ClosedPOPaymentAmount = 0.0;
        Decimal CorporateCardUsedAmount = Plan.ASI_MFM_KR_AnP_RollupAmount__c!=null ? Plan.ASI_MFM_KR_AnP_RollupAmount__c:0.0;
        for(ASI_MFM_PO_Line_Item__c pol:POLineList){
            if(pol.ASI_MFM_PO__r.ASI_MFM_Status__c=='Approved' && !pol.ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c ){
                if(pol.ASI_MFM_BaseCurrencyAmount__c !=null){
                    ApprovedPOAmount += pol.ASI_MFM_BaseCurrencyAmount__c.SetSCale(2);
                }                
            }else if (pol.ASI_MFM_PO__r.ASI_MFM_Status__c=='Closed'){ //Closed Status
                /**
                if(pol.Payment_Line_Items__r.size()==0 && !pol.ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c ){ //Normal Payment : PO is closed , but have not created Payment line
                    if(pol.ASI_MFM_Base_Currency_Amount__c!=null){
                        ClosedPOPaymentAmount +=pol.ASI_MFM_Base_Currency_Amount__c.SetSCale(2);
                    }else{
                        ClosedPOPaymentAmount+=pol.ASI_MFM_Amount__c.SetSCale(2);
                    }
                }**/
                
                for(ASI_MFM_Payment_Line_Item__c payl:pol.Payment_Line_Items__r){
                    if(payl.ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c){ //Closed Direct Payment
                        
                        if( payl.ASI_MFM_Paid_Amount_in_Base_Currency__c!=null){
                            DirectPaymentAmount += payl.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                        }
                        
                    }else{
                        if(payl.ASI_MFM_Paid_Amount_in_Base_Currency__c!=null){
                            ClosedPOPaymentAmount+=payl.ASI_MFM_Paid_Amount_in_Base_Currency__c.SetSCale(2);
                        }
                        
                    }
                    
                }
            }
            
        }
        //Plan Actual Spending: =PO approved+closed PO OR Payment amount + roll-up of A&P card + Direct payment PO 
        Decimal PlanActualSpending = ApprovedPOAmount+ ClosedPOPaymentAmount+ CorporateCardUsedAmount+DirectPaymentAmount;
        String Mesg='Roll-up of A&P Card('+CorporateCardUsedAmount.SetSCale(0).format()+')  + Approved PO('+ApprovedPOAmount.SetSCale(0).format()+') + Closed PO or Closed/Approved Payment Amount('+ClosedPOPaymentAmount.SetSCale(0).format()+') +Approved/ Completed Direct Payment Amount('+DirectPaymentAmount.SetSCale(0).format()+') ';
        ASI_MFM_KR_ActSpendWrapClass returnData = new ASI_MFM_KR_ActSpendWrapClass (PlanActualSpending,Mesg);// 
        
        return returnData;
    }
        
    
    
    
    
}