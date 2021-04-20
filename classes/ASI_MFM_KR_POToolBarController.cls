public class ASI_MFM_KR_POToolBarController {
    
    public ASI_MFM_PO__c header                               	{set;get;}
    public Id headerId                                          {set;get;}
    public Set<String>  brandGroups                             {set;get;}
    public List<String> brandGroupNames                         {set;get;}
    public Boolean needAttachment                               {set;get;}
    public String relatedPRmsg						            {set;get;}
    public String msg                                           {set;get;}{msg='';}
    public Decimal ActSpendingAmount                          {set;get;}{ActSpendingAmount=0;}
    public Decimal relatedPREstimatedBudget                     {set;get;}
    public Decimal relatedApprovedPOAmount                      {set;get;}
    public Decimal POAmountinBaseCurrency                       {set;get;}
    
    public ASI_MFM_KR_POToolBarController (ApexPages.StandardController controller) {
        
        this.header = (ASI_MFM_PO__c)controller.getRecord();
        this.headerId = this.header.Id;
        this.brandGroups = new Set<String>();
        this.brandGroupNames = new List<String>();
        
    }
    
    public void init(){
        
        relatedPREstimatedBudget = 0;
        POAmountinBaseCurrency  =0;
        relatedApprovedPOAmount = 0;
        relatedPRmsg= '';
        
        Set<Id> prs = new Set<Id>();
        
        header = [Select id , ASI_MFM_Plan__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c, ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c, ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c,  ASI_MFM_Purchase_Request__c, ASI_MFM_Status__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_PO_Amount_in_Base_Currency__c	,	ASI_MFM_Email_Sent_Time__c from ASI_MFM_PO__c where id=: this.headerId];
        
        for(ASI_MFM_PO_Line_Item__c poLine : [Select id ,ASI_MFM_Sub_brand_Code__c , ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name ,
                                              ASI_MFM_Purchase_Request_Line__c, ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Amount_in_Local_Currency__c,
                                              ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__c
                                              from ASI_MFM_PO_Line_Item__c where ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c!=null and ASI_MFM_PO__c =: this.headerId] ){
                                                  
                                                  brandGroups.add(poLine.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name);
                                              }
        
		if(header.ASI_MFM_Purchase_Request__c!=null){
            //relatedPREstimatedBudget  = (header.ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c!=null?header.ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c:0 * header.ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c!=null?header.ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c:1).setScale(0);
            if(header.ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c!=null &&  header.ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c!=null ){
                relatedPREstimatedBudget=header.ASI_MFM_Purchase_Request__r.ASI_MFM_Total_Amount__c*header.ASI_MFM_Purchase_Request__r.ASI_MFM_Exchange_Rate__c;
                relatedPREstimatedBudget=relatedPREstimatedBudget.setScale(0);
            }

                
                for(ASI_MFM_PO_Line_Item__c poLine : [Select id , ASI_MFM_BaseCurrencyAmount__c , ASI_MFM_PO__r.ASI_MFM_Status__c,
                                                      (select Id, Name,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,
                                                      ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c
                                                      from Payment_Line_Items__r where  
                                                      ASI_MFM_Payment__r.ASI_MFM_Status__c !='Submitted' 
                                                      and ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft' 
                                                      and ASI_MFM_Payment__r.ASI_MFM_Status__c!='Rejected')
                                                      from ASI_MFM_PO_Line_Item__c 
                                                      where ASI_MFM_PO__r.ASI_MFM_Purchase_Request__c  =:header.ASI_MFM_Purchase_Request__c
                                                      AND ( ASI_MFM_PO__r.ASI_MFM_Status__c ='Approved'
                                                      OR ASI_MFM_PO__r.ASI_MFM_Status__c ='Closed')
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
        
            
            POAmountinBaseCurrency =  POAmountinBaseCurrency.setScale(0);
            relatedApprovedPOAmount = relatedApprovedPOAmount.setScale(0);
            relatedPRmsg ='Rest Estimated PR Budget = Total Estimated PR Budget(' + relatedPREstimatedBudget +') - Approved/Closed PO Amount('+ relatedApprovedPOAmount +')= '  + (relatedPREstimatedBudget-  relatedApprovedPOAmount) ;
        }

        POAmountinBaseCurrency  = header.ASI_MFM_PO_Amount_in_Base_Currency__c!=null?header.ASI_MFM_PO_Amount_in_Base_Currency__c.setScale(0):0;
        
        brandGroupNames = new List<String>(brandGroups);
        ASI_MFM_KR_ActSpendWrapClass ResultData=ASI_MFM_KR_PlanToolBarController.calculateActualSpendingAmount(header.ASI_MFM_Plan__c);
        ActSpendingAmount=ResultData.ASI_MFM_Amount;
        msg=ResultData.ASI_MFM_Message;
        
        //ASI_MFM_KR_ActSpendWrapClass ResultData=calculateActualSpendingAmount(header.Id);
        //ActSpendingAmount=ResultData.ASI_MFM_Amount;
       // msg=ResultData.ASI_MFM_Message;
    }
    /*
    public ASI_MFM_KR_ActSpendWrapClass calculateActualSpendingAmount(Id InputPO){
        ASI_MFM_PO__c POHeader =[Select id , ASI_MFM_Status__c, ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Is_Direct_Payment__c, 	ASI_MFM_Email_Sent_Time__c from ASI_MFM_PO__c where id=: InputPO];
        
        List<ASI_MFM_PO_Line_Item__c> POLineList= [select Id,Name,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_Is_Direct_Payment__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Amount__c,
                                                   (select Id, Name,ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c from Payment_Line_Items__r where  ASI_MFM_Payment__r.ASI_MFM_Status__c !='Submitted' and ASI_MFM_Payment__r.ASI_MFM_Status__c !='Draft')
                                                   from ASI_MFM_PO_Line_Item__c 
                                                   where ASI_MFM_PO__c =:InputPO];
        
        
        Decimal DirectPaymentAmount = 0.0; // Status is approved
        Decimal ApprovedPOAmount = 0.0;
        Decimal ClosedPOPaymentAmount = 0.0;
        
        for(ASI_MFM_PO_Line_Item__c pol:POLineList){
            if(POHeader.ASI_MFM_Status__c=='Approved' && !POHeader.ASI_MFM_Is_Direct_Payment__c ){
                if(pol.ASI_MFM_Base_Currency_Amount__c !=null){
                    ApprovedPOAmount += pol.ASI_MFM_Base_Currency_Amount__c.SetSCale(0);
                }                
            }
            
            if(pol.Payment_Line_Items__r.size()==0 && POHeader.ASI_MFM_Is_Direct_Payment__c ){ //Normal Payment : PO is closed , but have not created Payment line, actually spending =0 
                if(pol.ASI_MFM_Base_Currency_Amount__c!=null){
                    //ClosedPOPaymentAmount +=pol.ASI_MFM_Base_Currency_Amount__c.SetSCale(0);
                }else{
                    //ClosedPOPaymentAmount+=pol.ASI_MFM_Amount__c.SetSCale(2);
                }
            }
            
            for(ASI_MFM_Payment_Line_Item__c payl:pol.Payment_Line_Items__r){
                if(POHeader.ASI_MFM_Status__c=='Closed' && POHeader.ASI_MFM_Is_Direct_Payment__c){
                    DirectPaymentAmount+=payl.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                }
                if(POHeader.ASI_MFM_Status__c=='Closed' && !POHeader.ASI_MFM_Is_Direct_Payment__c){
                    ClosedPOPaymentAmount+=payl.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                }
            }
            
        }
        Decimal PlanActualSpending = ApprovedPOAmount+ ClosedPOPaymentAmount+DirectPaymentAmount;
        String Mesg='Approved PO('+ApprovedPOAmount.SetSCale(0).format()+') + Closed PO or Closed/Approved Payment Amount('+integer.valueOf(ClosedPOPaymentAmount.SetSCale(0)).format()+') +Approved or Completed Direct Payment Amount('+DirectPaymentAmount.SetSCale(0).format()+'). ';
        ASI_MFM_KR_ActSpendWrapClass returnData = new ASI_MFM_KR_ActSpendWrapClass (PlanActualSpending,Mesg);// 
        
        return returnData;
        
    }
    */
    
}