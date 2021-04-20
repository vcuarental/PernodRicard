/*********************************************************************************
 * Name: ASI_CRM_SG_PaymentSummaryCtrl
 * Description: Controller class for ASI_CRM_SG_PaymentSummaryPage 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-13    	Laputa: Vincent      	Create
 */


public without sharing class ASI_CRM_SG_PaymentSummaryCtrl extends ASI_CRM_SG_PageControllerBase {
    
	public static final String REPORT_BACKREBATE = 'ASI_CRM_SG_Payment_BackRebate';
	
	public list<wrapper> list_w {get;set;}
	public set<string> set_promotionName {get;set;}
	public list<ASI_TH_CRM_PaymentRequestLineItem__c> childs {get;set;}
	public integer promotionSize {get;set;}
	private string reportAPI;
	private ASI_TH_CRM_PaymentRequest__c header {get;set;}
	
	public boolean getIsWholesalerBackRebate(){
		return header.ASI_CRM_System_Remark__c == 'Wholesaler Back Rebate Payment';
	}
			
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
        
    public ASI_CRM_SG_PaymentSummaryCtrl(ApexPages.StandardController standardController){
		list_w = new list<wrapper>();
		set_promotionName = new set<string>();
		list_w = getSummary(standardController.getId());
		reportAPI = getReportAPI(standardController.getId());
		header = getHeader(standardController.getId());
		childs = getChilds(standardController.getId());
		set_promotionName = getPromotionName(childs);
		promotionSize = set_promotionName.size();
	}
	
	private ASI_TH_CRM_PaymentRequest__c getHeader(String headerId){
		return [
			select id, ASI_CRM_System_Remark__c from ASI_TH_CRM_PaymentRequest__c where id = :headerId
		];
	}
	
	private list<ASI_TH_CRM_PaymentRequestLineItem__c> getChilds(String headerId){
		return [
			select ASI_CRM_Promotion_Detail__c, ASI_CRM_Promotion_Detail__r.ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__r.Name
			from ASI_TH_CRM_PaymentRequestLineItem__c
			where
			ASI_TH_CRM_Payment_Request__c = :headerId
		];
	}
	
	private set<string> getPromotionName(list<ASI_TH_CRM_PaymentRequestLineItem__c> childs){
		set<string> s = new set<string>();
		for(ASI_TH_CRM_PaymentRequestLineItem__c l : childs){
			if(l.ASI_CRM_Promotion_Detail__c != null){
				s.add(l.ASI_CRM_Promotion_Detail__r.ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__r.Name);
			}
		}
		return s;
	}
	
	private list<wrapper> getSummary(String headerId){
		list<wrapper> list_w = new list<wrapper>();
		for(AggregateResult ar : [
			select
				ASI_CRM_SG_Sub_brand__c subBrandId,
				ASI_CRM_SG_Sub_brand__r.name subBrandName,
				ASI_CRM_SG_Type__c type,
				sum(ASI_CRM_CN_Offtake_Vol__c) offtakeBottle,
            	sum(ASI_CRM_Volume_9L__c) offtake9L,
				sum(ASI_CRM_Amount_Number__c) computedAmount,
				sum(ASI_CRM_Actual_Amount_Number__c) actualAmount
			From
				ASI_TH_CRM_PaymentRequestLineItem__c
			Where
				ASI_TH_CRM_Payment_Request__c = :headerId
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
	
	private string getReportAPI(String headerId){
		return REPORT_BACKREBATE;
	}
	
	public string getReportLink(){
		report report = [Select ID from Report where DeveloperName = :reportAPI limit 1];
		return report.id;
	}
}