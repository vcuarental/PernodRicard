/*********************************************************************************
 * Name: ASI_CRM_PH_ContractSummaryCtrl
 * Description: Controller class for ASI_CRM_PH_ContractSummary
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-27		Wilken Lee				Create
 */

public class ASI_CRM_PH_ContractSummaryCtrl {
	
    private Id contractId;
	public ASI_TH_CRM_Contract__c Contract {get; set;}
    public boolean external {get; set;}
	public List<String> monthNames = new List<String>{'Jan', 'Feb', 'Mar','Apr', 'May', 'Jun', 'Jul','Aug', 'Sep', 'Oct','Nov', 'Dec'};
	public List<String> contractMonths {get; set;}
    public String contractFundSchemeType {get; set;}
	
    public List<ASI_CRM_Payment_Schedule__c > contractFundSchemeList {get; set;}
    public List<pIncentiveWrap> purchaseSchemeMap {get; set;}
    public List<contractTargetMonthlyWrap> monthlyWrap {get;set;}

    private List < ASI_CRM_SG_AdhocOther__c > contractTargetMonthlyList;
    private Map<Id,Decimal> skuRebateMap = new Map<Id,Decimal>();
    private Map<Id,Decimal> skuStaffIncentiveMap = new Map<Id,Decimal>();

    //Field Map
    private final static Map < String, Schema.SObjectField > CONTRACT_TARGET_ADHOC_FIELD_MAP = Schema.SObjectType.ASI_CRM_SG_AdhocOther__c.fields.getMap();

    //Record Type IDs
    public String contractTargetMonthlyRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_SG_AdhocOther__cASI_CRM_PH_AdhocOther');
        }
    }
    
    public ASI_CRM_PH_ContractSummaryCtrl(ApexPages.StandardController stdController) {
        contractId = APexPages.currentPage().getParameters().get('Id');
        external = APexPages.currentPage().getParameters().get('external') == '1' ? true : false;
		
		Contract = [
            select id, name,
            owner.firstname, owner.lastname,
            ASI_TH_CRM_Start_Date__c,
            ASI_TH_CRM_End_Date__c,
			
			//custom fields
			ASI_CRM_CN_Outlet_WS__r.name,
			ASI_CRM_CN_Approval_Status__c,
			ASI_CRM_VN_Objective__c,
			ASI_CRM_Revision_Extension_Remarks__c,
			ASI_CRM_Special_Contract__c,
			ASI_CRM_DF_DP__c,
			ASI_CRM_Over_Budget_Details__c,
            ASI_CRM_CN_Currency__c,
            ASI_CRM_Total_Support_Amount__c,
            ASI_CRM_Contract_Fund_Amount__c,
            ASI_CRM_Marketing_Support_Fund_Amount__c,
            ASI_CRM_Activation_Fund_Amount__c,
            ASI_CRM_Merchandise_Amount__c,
            ASI_CRM_Purchase_Incentive_Amount__c,
            ASI_CRM_Staff_Incentive_Amount__c,
            ASI_CRM_Bottle_Rebate_Amount__c,

            //Support Section
            ASI_CRM_Contract_Fund_A_P_Segment__c,

            ASI_CRM_Marketing_Support_Fund_APSegment__c,
            ASI_CRM_Activation_Fund_A_P_Segment__c,
            ASI_CRM_Merchandise_A_P_Segment__c,
            ASI_CRM_Purchase_Incentive_A_P_Segment__c,
            ASI_CRM_Bottle_Rebate_A_P_Segment__c,
            ASI_CRM_Staff_Incentive_A_P_Segment__c
            
			//from
            FROM ASI_TH_CRM_Contract__c
            WHERE id = :contractId
            LIMIT 1];
			
		contractMonths = new List<String>();
        monthlyWrap = new List<contractTargetMonthlyWrap>();

        contractFundPayment = 0;
        marketingFundPayment = 0;
        activationFundPayment = 0;
        merchandisePayment = 0;
        pIncentivePayment = 0;
        bottleRebatePayment = 0;
        staffIncentivePayment = 0;  

        contractFundEntitle = 0;
        pIncentiveEntitle = 0;
        bottleRebateEntitle = 0;
        staffIncentiveEntitle = 0;

        contractFundRemain = 0;
        marketingFundRemain = 0;
        activationFundRemain = 0;
        merchandiseRemain = 0;
        pIncentiveRemain = 0;
        bottleRebateRemain = 0;
        staffIncentiveRemain = 0;  

        contractFundBal = 0;
        marketingFundBal= 0;
        activationFundBal = 0;
        merchandiseBal = 0;
        pIncentiveBal = 0;
        bottleRebateBal = 0;
        staffIncentiveBal = 0;  

        contractFundSchemeList = new List<ASI_CRM_Payment_Schedule__c >();
        purchaseSchemeMap = new List<pIncentiveWrap>();
    }
    
    //Support variables
    public decimal contractFundPayment {get; set;}
    public decimal marketingFundPayment {get; set;}
    public decimal activationFundPayment {get; set;}
    public decimal merchandisePayment {get; set;}
    public decimal pIncentivePayment {get; set;}
    public decimal bottleRebatePayment {get; set;}
    public decimal staffIncentivePayment {get; set;}

    public decimal contractFundEntitle {get; set;}
    public decimal marketingFundEntitle {get; set;}
    public decimal activationFundEntitle {get; set;}
    public decimal merchandiseEntitle {get; set;}
    public decimal pIncentiveEntitle {get; set;}
    public decimal bottleRebateEntitle {get; set;}
    public decimal staffIncentiveEntitle {get; set;}

    public decimal contractFundRemain {get; set;}
    public decimal marketingFundRemain {get; set;}
    public decimal activationFundRemain {get; set;}
    public decimal merchandiseRemain {get; set;}
    public decimal pIncentiveRemain {get; set;}
    public decimal bottleRebateRemain {get; set;}
    public decimal staffIncentiveRemain {get; set;}
    
    public decimal contractFundBal {get; set;}
    public decimal marketingFundBal {get; set;}
    public decimal activationFundBal {get; set;}
    public decimal merchandiseBal {get; set;}
    public decimal pIncentiveBal {get; set;}
    public decimal bottleRebateBal {get; set;}
    public decimal staffIncentiveBal {get; set;}

    public list<ASI_CRM_Payment_Schedule__c> CashSponsorshipSchedule {get; set;}
    public list<ASI_CRM_Payment_Schedule__c> ContractSponsorshipSchedule {get; set;}
    
    public List<ASI_CRM_ContractTarget__c> getContractTarget(){
        List<ASI_CRM_ContractTarget__c> ctList = [
            select id, 
            // SKU
			ASI_CRM_Approved__c,
            ASI_CRM_SKU__c,
            ASI_CRM_SKU__r.name,
			ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name,
			ASI_CRM_TargetCase__c,
			ASI_CRM_Bottle_Rebate__c,
			ASI_CRM_Total_Bottle_Rebate__c,
			ASI_CRM_Staff_Incentive__c,
			ASI_CRM_Total_Staff_Incentive__c,
            ASI_CRM_FOC__c
			
			//from
            FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c = : contractId
            AND recordtype.developername = 'ASI_CRM_PH_Contract_Target'
			ORDER BY ASI_CRM_SKU__r.name
        ];
        
        for (ASI_CRM_ContractTarget__c ct: ctList){
           if (ct.ASI_CRM_Bottle_Rebate__c != null)
                skuRebateMap.put(ct.ASI_CRM_SKU__c, ct.ASI_CRM_Bottle_Rebate__c);

            if (ct.ASI_CRM_Staff_Incentive__c != null)
                skuStaffIncentiveMap.put(ct.ASI_CRM_SKU__c, ct.ASI_CRM_Staff_Incentive__c);
        }
        
        system.debug('skuRebateMap: ' + skuRebateMap);
        system.debug('skuStaffIncentiveMap: ' + skuStaffIncentiveMap);

        /*notDisplayFGTab = (totalSalesIncentive + totalManagementIncentive + totalCSTargetIncentive + totalOthers) <= 0;
        notDisplayCMTab = (totalConsumerOffer + totalWSMargin + totalBottleIncentive) <= 0;
        notDisplayCSTab = (totalGoodsInKind + totalCash) <= 0;
        notDisplayAPTab = (totalEventCase + totalEventValue + totalAdhoc) <= 0;*/
        
        return ctList;
    }
    
    public boolean notDisplayCOTab {get; set;}
    
    public void calculcateSupportScheme(){
        List<ASI_CRM_Payment_Schedule__c> cFundSchemeList = [SELECT RecordType.DeveloperName, ASI_CRM_Target_Achievement_Amount__c, ASI_CRM_Target_Start_Date__c, ASI_CRM_Target_End_Date__c, 
            ASI_CRM_Sponsorship__c, ASI_CRM_Contract__c, ASI_CRM_Target_Purchase_Amount_From__c, ASI_CRM_Target_Purchase_Amount_To__c, ASI_CRM_Incentive_to_issue__c, 
            ASI_CRM_Sys_Parent_Record__c, ASI_CRM_Achieved__c, ASI_CRM_Issuable__c, ASI_CRM_Type__c, ASI_CRM_Schedule_Date__c,ASI_CRM_Target_Bottle__c, 
            ASI_CRM_Payout_Amount__c  FROM ASI_CRM_Payment_Schedule__c WHERE ASI_CRM_Contract__c = :contractId];   

        for (ASI_CRM_Payment_Schedule__c scheme:cFundSchemeList){
            if (scheme.RecordType.DeveloperName == 'ASI_CRM_PH_Contract_Fund'){
                contractFundSchemeList.add(scheme);
                contractFundSchemeType = scheme.ASI_CRM_Type__c;

                if (scheme.ASI_CRM_Issuable__c) //Calculcate Entitle Amount
                    contractFundEntitle += scheme.ASI_CRM_Sponsorship__c;
            }
            else if (scheme.RecordType.DeveloperName == 'ASI_CRM_PH_Purchase_Incentive' && scheme.ASI_CRM_Sys_Parent_Record__c){
                pIncentiveWrap p = new pIncentiveWrap();
                p.parent = new ASI_CRM_Payment_Schedule__c();
                p.pIncentiveDetailList = new List<ASI_CRM_Payment_Schedule__c>();
                p.parent = scheme;

                purchaseSchemeMap.add(p);

                if (scheme.ASI_CRM_Issuable__c)
                    pIncentiveEntitle += scheme.ASI_CRM_Sponsorship__c;

                system.debug('Parent Purchase Scheme: ' + p);
            } 
        }

        for (ASI_CRM_Payment_Schedule__c scheme:cFundSchemeList){
             if (scheme.RecordType.DeveloperName == 'ASI_CRM_PH_Purchase_Incentive' && !scheme.ASI_CRM_Sys_Parent_Record__c){
                for (pIncentiveWrap pWrap:purchaseSchemeMap){
                    if (pWrap.parent.ASI_CRM_Target_Start_Date__c == scheme.ASI_CRM_Target_Start_Date__c)
                        pWrap.pIncentiveDetailList.add(scheme);
                }
            }
        }

        system.debug('purchaseSchemeMap: ' + purchaseSchemeMap);
    }

    public void calculcateSupportAmount(){
        List<ASI_TH_CRM_PaymentRequest__c> paymentList = [SELECT ASI_CRM_Payment_Type__c, ASI_CRM_Payment_Amount__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c = :contractId];

        system.debug('No of Payments:' + paymentList.size());

        for (ASI_TH_CRM_PaymentRequest__c pay:paymentList){
            if (pay.ASI_CRM_Payment_Type__c == 'Contract Fund')
                contractFundPayment+= pay.ASI_CRM_Payment_Amount__c;
            else if (pay.ASI_CRM_Payment_Type__c == 'Activation Fund')
                activationFundPayment+= pay.ASI_CRM_Payment_Amount__c;                
            else if (pay.ASI_CRM_Payment_Type__c == 'Merchandise')
                merchandisePayment+= pay.ASI_CRM_Payment_Amount__c;
            else if (pay.ASI_CRM_Payment_Type__c == 'Purchase Incentive')
                pIncentivePayment+= pay.ASI_CRM_Payment_Amount__c;
            else if (pay.ASI_CRM_Payment_Type__c == 'Bottle Rebate')
                bottleRebatePayment+= pay.ASI_CRM_Payment_Amount__c;
            else if (pay.ASI_CRM_Payment_Type__c == 'Staff Incentive')
                staffIncentivePayment+= pay.ASI_CRM_Payment_Amount__c;
        }

        system.debug('contractFundPayment: ' + contractFundPayment);

        //Cal Bottle Rebate
        

         List<ASI_TH_CRM_Actual_Offtake__c> offtakeList = retrieveActualOfftake(contractId);
         for (ASI_TH_CRM_Actual_Offtake__c offtake:offtakeList){
            if (skuRebateMap.get(offtake.ASI_CRM_SKU__c) != null)
                bottleRebateEntitle  += skuRebateMap.get(offtake.ASI_CRM_SKU__c) * offtake.ASI_TH_CRM_Quantity__c;

            if (skuStaffIncentiveMap.get(offtake.ASI_CRM_SKU__c) != null)
                staffIncentiveEntitle  += skuStaffIncentiveMap.get(offtake.ASI_CRM_SKU__c) * offtake.ASI_TH_CRM_Quantity__c;                
         }



        contractFundRemain = contractFundEntitle - contractFundPayment;
        marketingFundRemain = Contract.ASI_CRM_Marketing_Support_Fund_Amount__c - marketingFundPayment;
        activationFundRemain = Contract.ASI_CRM_Activation_Fund_Amount__c - activationFundPayment;
        merchandiseRemain = Contract.ASI_CRM_Merchandise_Amount__c - merchandisePayment;
        pIncentiveRemain = pIncentiveEntitle - pIncentivePayment;
        bottleRebateRemain = bottleRebateEntitle - bottleRebatePayment;
        staffIncentiveRemain = staffIncentiveEntitle - staffIncentivePayment;


        contractFundBal = Contract.ASI_CRM_Contract_Fund_Amount__c - contractFundPayment;
        marketingFundBal= Contract.ASI_CRM_Marketing_Support_Fund_Amount__c - marketingFundPayment;
        activationFundBal = Contract.ASI_CRM_Activation_Fund_Amount__c - activationFundPayment;
        merchandiseBal = Contract.ASI_CRM_Merchandise_Amount__c - merchandisePayment;
        pIncentiveBal = Contract.ASI_CRM_Purchase_Incentive_Amount__c - pIncentivePayment;
        bottleRebateBal = Contract.ASI_CRM_Bottle_Rebate_Amount__c - bottleRebatePayment;
        staffIncentiveBal = Contract.ASI_CRM_Staff_Incentive_Amount__c - staffIncentivePayment;
        
    }

    public void calculcateMonthlyTarget(List<ASI_CRM_ContractTarget__c> contractTarget, List < ASI_CRM_SG_AdhocOther__c > monthlyTarget){
        for (ASI_CRM_ContractTarget__c ct:contractTarget){
            contractTargetMonthlyWrap targetWrap = new contractTargetMonthlyWrap();
            targetWrap.target = ct;
            
            /*targetWrap.M1 = 0;
            targetWrap.M2 = 0;
            targetWrap.M3 = 0;
            targetWrap.M4 = 0;
            targetWrap.M5 = 0;
            targetWrap.M6 = 0;
            targetWrap.M7 = 0;
            targetWrap.M8 = 0;
            targetWrap.M9 = 0;
            targetWrap.M10 = 0;
            targetWrap.M11 = 0;
            targetWrap.M12 = 0;*/

            for (ASI_CRM_SG_AdhocOther__c mt:monthlyTarget){
                if (ct.Id == mt.ASI_CRM_SG_Contract_Target__c && mt.ASI_CRM_Month__c != null){
                    if (mt.ASI_CRM_Month__c == 1) 
                        targetWrap.M1 = mt.ASI_CRM_Monthly_Target_Bottle__c;
                    else if (mt.ASI_CRM_Month__c == 2) 
                        targetWrap.M2 = mt.ASI_CRM_Monthly_Target_Bottle__c;                        
                    else if (mt.ASI_CRM_Month__c == 3) 
                        targetWrap.M3 = mt.ASI_CRM_Monthly_Target_Bottle__c;                        
                    else if (mt.ASI_CRM_Month__c == 4) 
                        targetWrap.M4 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 5) 
                        targetWrap.M5 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 6) 
                        targetWrap.M6 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 7) 
                        targetWrap.M7 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 8) 
                        targetWrap.M8 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 9) 
                        targetWrap.M9 = mt.ASI_CRM_Monthly_Target_Bottle__c;                                                                                                                                                
                    else if (mt.ASI_CRM_Month__c == 10) 
                        targetWrap.M10 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 11) 
                        targetWrap.M11 = mt.ASI_CRM_Monthly_Target_Bottle__c;    
                    else if (mt.ASI_CRM_Month__c == 12) 
                        targetWrap.M12 = mt.ASI_CRM_Monthly_Target_Bottle__c;                                                    
                }
            }

            monthlyWrap.add(targetWrap);
        }
        system.debug('monthlyWrap: ' + monthlyWrap);
    }

    public void init(){	
        calculcateSupportScheme();

        calculcateSupportAmount();



        contractTargetMonthlyList = retrieveContractTargetMonthlyList(contractId);

        List<ASI_CRM_ContractTarget__c> ctList = getContractTarget();

        calculcateMonthlyTarget(ctList, contractTargetMonthlyList);
		
        Integer i = 0;
        Date tempDate = Date.newInstance(Contract.ASI_TH_CRM_Start_Date__c.Year(), Contract.ASI_TH_CRM_Start_Date__c.Month(), 1);
		
		while (tempDate < Contract.ASI_TH_CRM_End_Date__c) {
			system.debug('tempDate: ' + tempDate + ' ASI_TH_CRM_End_Date__c: ' + Contract.ASI_TH_CRM_End_Date__c + ' tempDate.Month(): ' + tempDate.Month());
			contractMonths.add(monthNames.get(tempDate.Month()-1)+ ' ' + tempDate.year());
			
			if (tempDate.month() == 12){
				tempDate = tempDate.addMonths(-11);
				tempDate = tempDate.addYears(1);
			}
			else 
				tempDate =  tempDate.addMonths(1);
		}
		
		system.debug('Contract Months: ' + contractMonths);
    }

    public class pIncentiveWrap {
        public ASI_CRM_Payment_Schedule__c  parent {get; set;}
        public List<ASI_CRM_Payment_Schedule__c> pIncentiveDetailList {get; set;}
    }

    public class contractTargetMonthlyWrap {
        public ASI_CRM_ContractTarget__c  target {get; set;}
        public Decimal M1 {get; set;}
        public Decimal M2 {get; set;}
        public Decimal M3 {get; set;}
        public Decimal M4 {get; set;}
        public Decimal M5 {get; set;}
        public Decimal M6 {get; set;}
        public Decimal M7 {get; set;}
        public Decimal M8 {get; set;}
        public Decimal M9 {get; set;}
        public Decimal M10 {get; set;}
        public Decimal M11 {get; set;}
        public Decimal M12 {get; set;}
    }

    private String genQueryField(Map < String, Schema.SObjectField > fieldMap) {
        String queryField = '';
        for (String fields: fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private List < ASI_CRM_SG_AdhocOther__c > retrieveContractTargetMonthlyList(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_TARGET_ADHOC_FIELD_MAP) +
            ', RecordType.DeveloperName ' +
            'FROM ASI_CRM_SG_AdhocOther__c ' +
            'WHERE ASI_CRM_SG_Contract_Target__r.ASI_CRM_Contract__c = :contractId ' +
            'AND RecordTypeId = \'' + contractTargetMonthlyRecordTypeId +  '\' ' +
            'order by ASI_CRM_SG_Contract_Target__c, ASI_CRM_Month__c';

        List < ASI_CRM_SG_AdhocOther__c > contractList = (List < ASI_CRM_SG_AdhocOther__c > ) Database.query(query);
        return contractList;
    }

    private List<ASI_TH_CRM_Actual_Offtake__c> retrieveActualOfftake(Id contractId) {

        String query = 'SELECT Id, ASI_TH_CRM_Quantity__c ' +
                'FROM ASI_TH_CRM_Actual_Offtake__c ' +
                'WHERE ASI_CRM_Contract__c = :contractId ';

        final List<ASI_TH_CRM_Actual_Offtake__c> actualOfftake = Database.query(query);

        if (actualOfftake.isEmpty()) return new List<ASI_TH_CRM_Actual_Offtake__c>();

        return actualOfftake;
    }
}