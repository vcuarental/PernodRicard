/*********************************************************************************
 * Name: ASI_CRM_SG_Payment_ApprovalNotifiCtrl
 * Description: Show all information of payment request in the approval email, controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-05       Laputa: Vincent Lam     Created
 * 2018-03-23		Laputa: Vincent Lam	    [VL 1.0] P4.2 Handle wholesaler back rebate
 */
public class ASI_CRM_SG_Payment_ApprovalNotifiCtrl {
  public ASI_CRM_SG_Payment_ApprovalNotifiCtrl(){
    paymentChilds = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
	//getHeader();
	//getChilds();
	//init();
  }
  
  public void init(){
	  getHeader();
	getChilds();
  }
  
  public String paymentID {get;set;}
  private List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentChilds;
    
    public boolean isGenerated {get;set;}
    public boolean isBottleIncentive {get;set;}
    /* [VL 1.0] BEGIN */
    public Boolean isBackRebates {get;set;}
    public Boolean isWholesalerBackRebate {get;set;}
	public final String BACKREBATEPAYMENT_REMARK = 'Wholesaler Back Rebate Payment';
	public list<wrapper> list_w {get;set;}
    /* [VL 1.0] END */
	
	
    
    public String getApproverName(){
        string username = '';
        if (!Test.isRunningTest()) {
            user u = 
                [select id, firstname, lastname from user where id in 
                    (select ActorId
                     from processinstanceWorkitem 
                     where processinstance.targetobjectid = :paymentID)
                limit 1];
            username = u.firstname + ' ' + u.lastname;
        }
        return username;
    }
  
  public List<ASI_TH_CRM_PaymentRequestLineItem__c> getChilds(){
    
    List<ASI_TH_CRM_PaymentRequestLineItem__c> childs = 
        [select id, 
         name,
         ASI_CRM_SG_Sub_brand__r.name,
         ASI_CRM_SG_Type__c,
         ASI_TH_CRM_Amount__c,
         ASI_CRM_Adjusted_Amount__c,
         ASI_CRM_Difference_Adjusted_Amount__c,
         ASI_CRM_Adjustment_Remark__c,
         ASI_CRM_Volume_9L__c,
         ASI_CRM_Contracted_Rate_9L__c,
		 ASI_CRM_SKU__c,
		 ASI_CRM_SKU__r.Name,
		 ASI_CRM_Contribution_From__c,
		 ASI_CRM_Contribution_To__c,
		 ASI_CRM_Contribution__c
         from ASI_TH_CRM_PaymentRequestLineItem__c 
         where ASI_TH_CRM_Payment_Request__c = :paymentID];
      
    paymentChilds = childs;
      
      if (childs.size()>0 && childs.get(0).ASI_CRM_SG_Type__c == 'Bottle Incentive') isBottleIncentive = true;
      else isBottleIncentive = false;

	/* [VL 1.0] BEGIN */
	if(isGenerated && childs.get(0).ASI_CRM_SG_Type__c == 'Back Rebates' && !isWholesalerBackRebate) {
		isBackRebates = true;
	} else {
		isBackRebates = false;
	}
	/* [VL 1.0] END */
	
    return childs;
  }
  
  public ASI_TH_CRM_PaymentRequest__c getHeader(){
    
    ASI_TH_CRM_PaymentRequest__c header = 
        [select id,
         Name, 
         Owner.FirstName, Owner.LastName, 
         ASI_CRM_CN_OutletWS__r.name,
         ASI_TH_CRM_Contract__r.name,
         ASI_CRM_Vendor__r.name,
         ASI_TH_CRM_VendorAddress__c,
         ASI_TH_CRM_PaymentTerm__c,
         ASI_TH_CRM_DeliveryAddress__c,
         ASI_CRM_SG_Invoice_No__c,
         ASI_CRM_CN_Description__c,
         ASI_TH_CRM_Status__c,
         ASI_TH_CRM_GL_Date__c,
         ASI_TH_CRM_PaymentDate__c,
         ASI_TH_CRM_Total_Amount__c,
         ASI_CRM_GST__c,
         ASI_CRM_SG_GST__c,
         ASI_CRM_SG_Invoice_Date__c,
         ASI_CRM_Contract_No_Original__c,
         ASI_CRM_Reject_Return_Comments__c,
         ASI_CRM_Total_Adjusted_Amount__c,
         ASI_CRM_System_Generated__c,
		 ASI_CRM_System_Remark__c
         from ASI_TH_CRM_PaymentRequest__c
         where id = :paymentID];
    
      if (header.ASI_CRM_System_Generated__c) isGenerated = true;
      else isGenerated = false;
    
        /* [VL 1.0] BEGIN */
        isWholesalerBackRebate = (header.ASI_CRM_System_Remark__c == BACKREBATEPAYMENT_REMARK) ? true : false;
        /* [VL 1.0] END */
		getChilds();
        
    return header;  
  }
  
	/* [VL 1.0] BEGIN */
	public class wrapper{
		public String subBrandId {get;set;}
		public String subBrandName {get;set;}
		public String type {get;set;}
		public Decimal offtakeBottle {get;set;}
		public Decimal offtake9L {get;set;}
		public Decimal computedAmount {get;set;}
		public Decimal actualAmount {get;set;}
		
		public Decimal getAdjustedDiff(){
		  return actualAmount - computedAmount;
		}
		
		public wrapper(String subBrandId, String subBrandName, String type, Decimal offtakeBottle, Decimal offtake9L, Decimal computedAmount, Decimal actualAmount){
		  this.subBrandId = subBrandId;
		  this.subBrandName = subBrandName;
		  this.type = type;
		  this.offtakeBottle = offtakeBottle;
		  this.offtake9L = offtake9L;
		  this.computedAmount = computedAmount;
		  this.actualAmount = actualAmount;
		}
	}
	
	public list<wrapper> getSummary(){
		list<wrapper> list_w = new list<wrapper>();
		for(AggregateResult ar : [
		  select
			ASI_CRM_SG_Sub_brand__c subBrandId,
			ASI_CRM_SG_Sub_brand__r.name subBrandName,
			ASI_CRM_SG_Type__c type,
			sum(ASI_CRM_CN_Offtake_Vol__c) offtakeBottle,
			sum(ASI_CRM_Volume_9L__c) offtake9L,
			sum(ASI_TH_CRM_Amount__c) computedAmount,
			sum(ASI_CRM_Adjusted_Amount__c) actualAmount
		  From
			ASI_TH_CRM_PaymentRequestLineItem__c
		  Where
			ASI_TH_CRM_Payment_Request__c = :paymentID
		  Group by 
			ASI_CRM_SG_Sub_brand__c, 
			ASI_CRM_SG_Sub_brand__r.name,
			ASI_CRM_SG_Type__c
		  Order by
			ASI_CRM_SG_Sub_brand__r.name asc
		]){
		  String subBrandId = String.valueOf(ar.get('subBrandId'));
		  String subBrandName = String.valueOf(ar.get('subBrandName'));
		  String type = String.valueOf(ar.get('type'));
		  Decimal offtakeBottle = (Decimal)ar.get('offtakeBottle');
		  Decimal offtake9L = (Decimal)ar.get('offtake9L');
		  Decimal computedAmount = (Decimal)ar.get('computedAmount');
		  Decimal actualAmount = (Decimal)ar.get('actualAmount');
		  list_w.add(new wrapper(subBrandId, subBrandName, type, offtakeBottle, offtake9L, computedAmount, actualAmount));
		}
		return list_w;
	}
	/* [VL 1.0] END */
}