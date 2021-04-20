/*********************************************************************************
 * Name: ASI_CRM_SG_CreditNoteSummaryCtrl
 * Description: Controller class for ASI_CRM_SG_CreditNoteSummaryPage 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-01    	Laputa: Vincent      	Create
 */


public without sharing class ASI_CRM_SG_CreditNoteSummaryCtrl extends ASI_CRM_SG_PageControllerBase {
    
	public static final String REPORT_CONTRACTMARGIN = 'ASI_CRM_SG_Credit_Debit_Note_Breakdown';
	public static final String REPORT_BACKREBATE = 'ASI_CRM_SG_CreditDebitNote_BackRebate';
	public static final String RTAPI_CONTRACTMARGIN = 'ASI_CRM_SG_Contract_Margin';
	public static final String RTAPI_BACKREBATE = 'ASI_CRM_SG_Back_Rebate';
	
	public list<wrapper> list_w {get;set;}
	private string reportAPI;
			
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
        
    public ASI_CRM_SG_CreditNoteSummaryCtrl(ApexPages.StandardController standardController){
		list_w = new list<wrapper>();
		list_w = getSummary(standardController.getId());
		reportAPI = getReportAPI(standardController.getId());
	}
	
	private list<wrapper> getSummary(String creditNoteId){
		list<wrapper> list_w = new list<wrapper>();
		for(AggregateResult ar : [
			select
				ASI_CRM_Sub_brand__c subBrandId,
				ASI_CRM_Sub_brand__r.name subBrandName,
				ASI_CRM_Type__c type,
				sum(ASI_CRM_Volume_Bottle__c) offtakeBottle,
            	sum(ASI_CRM_Volume_9L__c) offtake9L,
				sum(ASI_CRM_Amount__c) computedAmount,
				sum(ASI_CRM_Actual_Amount__c) actualAmount
			From
				ASI_CRM_Credit_Debit_Note_Line_Item__c
			Where
				ASI_CRM_Credit_Debit_Note__c = :creditNoteId
			Group by 
				ASI_CRM_Sub_brand__c, 
				ASI_CRM_Sub_brand__r.name,
				ASI_CRM_Type__c
			Order by
				ASI_CRM_Sub_brand__r.name asc
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
	
	private string getReportAPI(String creditNoteId){
		string rtAPI =  [select recordtype.developername from ASI_CRM_Credit_Debit_Note__c where id = :creditNoteId limit 1].recordtype.developername;
		string reportAPI;
		if(rtAPI.contains(RTAPI_CONTRACTMARGIN)){
			reportAPI = REPORT_CONTRACTMARGIN;
		} else 
		if(rtAPI.contains(RTAPI_BACKREBATE)){
			reportAPI = REPORT_BACKREBATE;
		}
		return reportAPI;
	}
	
	public string getReportLink(){
		report report = [Select ID from Report where DeveloperName = :reportAPI limit 1];
		return report.id;
	}
}