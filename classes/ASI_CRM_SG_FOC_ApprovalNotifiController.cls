/*********************************************************************************
* Name: ASI_CRM_SG_FOC_ApprovalNotifiController
* Description: Show all information of FOC request in the approval email
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??
* 2017-01-06       Laputa: Vincent Lam     Update
* 2017-05-12       Laputa: Vincent Lam     [VL 1.0] P4.2, promotion
*/
public class ASI_CRM_SG_FOC_ApprovalNotifiController {
    
    public class FOCLinkageWrapper {
        public ASI_CRM_FOC_Linkage__c focLinkage {get; set;}
        public Decimal entitledBottle {get; set;}
        public FOCLinkageWrapper(ASI_CRM_FOC_Linkage__c focLinkage) {
            this.focLinkage     = focLinkage;
            this.entitledBottle = (focLinkage.ASI_CRM_Contract_Target__r.ASI_CRM_SG_Sales_Incentive__c == null ? 0 : focLinkage.ASI_CRM_Contract_Target__r.ASI_CRM_SG_Sales_Incentive__c)
                / (focLinkage.ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c == null ? 1 : focLinkage.ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c)
                * (focLinkage.ASI_CRM_Actual_Offtake__r.ASI_TH_CRM_Quantity__c == null ? 0 : focLinkage.ASI_CRM_Actual_Offtake__r.ASI_TH_CRM_Quantity__c)
                * (focLinkage.ASI_CRM_Actual_Offtake__r.ASI_CRM_Std_Bottle_Size__c == null ? 0 : focLinkage.ASI_CRM_Actual_Offtake__r.ASI_CRM_Std_Bottle_Size__c)
                / (focLinkage.ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c == null ? 1 : focLinkage.ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c);
            this.entitledBottle = this.entitledBottle.setScale(2);
        }
    }
    
    public ASI_CRM_SG_FOC_ApprovalNotifiController(){
        focChilds = new List<ASI_FOC_Request_Item__c>();
    }
    
    public String focID {get;set;}
    private List<ASI_FOC_Request_Item__c> focChilds;
    public Decimal totalCost {get;set;}
    public Map<Id, Decimal> focCarryOverMap {get; set;} 
    public Map<string, boolean> map_focHasLinkage {get; set;} 
    
    /* [VL 1.0] BEGIN */
    public Boolean isPromotionIncentive {get;set;}{isPromotionIncentive = false;}
    /* [VL 1.0] END */
    
    public String getApproverName(){
        string username = '';
        if (!Test.isRunningTest()) {
            List<user> uList = 
                [select id, firstname, lastname from user where id in 
                 (select ActorId
                  from processinstanceWorkitem 
                  where processinstance.targetobjectid = :focID)
                 limit 1];
            if(uList != null && uList.size() > 0) {
                username = uList.get(0).firstname + ' ' + uList.get(0).lastname;
            }
        }
        return username;
    }
    
    public Map<Id, list<FOCLinkageWrapper>> getChildLinkages() {
        focCarryOverMap = new Map<Id, Decimal>();
        
        List<ASI_CRM_FOC_Linkage__c> focLinkageList = [SELECT ASI_CRM_Actual_Offtake__r.ASI_CRM_SKU__r.Name, ASI_CRM_Actual_Offtake__r.ASI_TH_CRM_Sub_brand__r.Name,
                                                       ASI_CRM_Actual_Offtake__r.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__r.Name, ASI_CRM_Actual_Offtake__r.ASI_CRM_FromWS__r.Name,
                                                       ASI_CRM_Actual_Offtake__r.ASI_TH_CRM_Offtake_G_L_Date__c, ASI_CRM_Actual_Offtake__r.ASI_TH_CRM_Quantity__c, 
                                                       ASI_CRM_Actual_Offtake__r.ASI_CRM_Std_Bottle_Size__c,
                                                       ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.Name, ASI_CRM_Contract_Target__r.ASI_CRM_Subbrand__r.Name, 
                                                       ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__r.Name, ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c, 
                                                       ASI_CRM_Contract_Target__r.ASI_CRM_SG_Sales_Incentive__c, ASI_CRM_Contract_Target__r.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,
                                                       ASI_CRM_FOC_Request_Item__c, ASI_CRM_Match_By__c
                                                       FROM ASI_CRM_FOC_Linkage__c
                                                       WHERE ASI_CRM_FOC_Request_Item__r.ASI_FOC_Request_Order__c = :focId];
        
        Map<Id, list<FOCLinkageWrapper>> focLinkageWrapperMap = new Map<Id, list<FOCLinkageWrapper>>();
        if (focLinkageList.size()>0){
            for(ASI_CRM_FOC_Linkage__c focLinkage : focLinkageList) {
				list<FOCLinkageWrapper> list_focLinkageWrapper = focLinkageWrapperMap.containsKey(focLinkage.ASI_CRM_FOC_Request_Item__c) ? focLinkageWrapperMap.get(focLinkage.ASI_CRM_FOC_Request_Item__c) : new list<FOCLinkageWrapper>();
                FOCLinkageWrapper focLinkageWrapper = new FOCLinkageWrapper(focLinkage);
				list_focLinkageWrapper.add(focLinkageWrapper);
                focLinkageWrapperMap.put(focLinkage.ASI_CRM_FOC_Request_Item__c, list_focLinkageWrapper);
                Decimal focCarryOver = focLinkageWrapper.entitledBottle;
                if(focCarryOverMap.containsKey(focLinkage.ASI_CRM_FOC_Request_Item__c)) {
                    focCarryOver += focCarryOverMap.get(focLinkage.ASI_CRM_FOC_Request_Item__c);
                }
                focCarryOverMap.put(focLinkage.ASI_CRM_FOC_Request_Item__c, focCarryOver);
                map_focHasLinkage.put(focLinkage.ASI_CRM_FOC_Request_Item__c, true);
            }
        }
        
        return focLinkageWrapperMap;
    }
    
    public List<ASI_FOC_Request_Item__c> getChilds(){
        
        List<ASI_FOC_Request_Item__c> childs = 
            [select Id, ASI_CRM_SG_FOC_Type__c, 
             ASI_CRM_SG_A_G_Code__c, 
             ASI_FOC_Sub_brand__c, 
             ASI_FOC_SKU__r.Name, 
             ASI_FOC_Request_Quantity_Bottle__c,
             ASI_FOC_Actual_Quantity_Bottle__c, 
             ASI_CRM_Adjustment_Remarks__c, 
             ASI_CRM_Offtake_Quantity__c,
             ASI_CRM_Wholesaler__r.name,
             ASI_CRM_IGC_Cost_Per_case__c, ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c 
        	/* [VL 1.0] BEGIN */
             , ASI_CRM_Offtake_Quantity_9L__c
             , ASI_CRM_Promotion_Mechanic_Text__c
             , ASI_CRM_Carry_Over_Bottle__c
             , ASI_CRM_Promotion_Detail__r.ASI_HK_CRM_Promotion__r.ASI_CRM_Promotion_Plan__r.Name
        	/* [VL 1.0] END */
             from ASI_FOC_Request_Item__c 
             where ASI_FOC_Request_Order__c = :focID];
        
        focChilds = childs;
        
        map_focHasLinkage = new map<string, boolean>();
		/*
        for (ASI_FOC_Request_Item__c focItem : childs){
            map_focHasLinkage.put(focItem.id, false);
        }
		*/
		getChildLinkages();
        
        return childs;
    }
    
    public ASI_FOC_Free_Goods_Request__c getHeader(){
        
        List<ASI_FOC_Free_Goods_Request__c> headerList = 
            [select id,
             Name, 
             Owner.FirstName, Owner.LastName, 
             ASI_CRM_Outlet__r.Name, 
             ASI_CRM_Contract__r.name,
             ASI_CRM_JDE_SO_Number__c,
             ASI_FOC_Deliver_to_Address_Line_1__c,
             ASI_FOC_Deliver_to_Address_Line_2__c,
             ASI_FOC_Deliver_to_Address_Line_3__c,
             ASI_FOC_Deliver_to_Address_Line_4__c,
             ASI_FOC_Delivery_Remarks__c,
             ASI_CRM_SG_Year__c,
             ASI_CRM_SG_Month__c,
             ASI_CRM_SG_Order_Date__c,
             ASI_CRM_SG_Total_Amount__c,
             ASI_FOC_Request_Status__c,
             ASI_CRM_Contract_No_Original__c,
             ASI_CRM_Contracted_ROI_Percent__c,
             ASI_CRM_SG_Target_Benchmark_Threshold__c,
             ASI_CRM_Revised_ROI_Percent__c,
             ASI_CRM_Sampling_Approval_Level__c
        	/* [VL 1.0] BEGIN */
             , ASI_CRM_System_Remark__c
        	/* [VL 1.0] END */
             from ASI_FOC_Free_Goods_Request__c 
             where id = :focID];
        
        totalCost = 0;
        
        for (ASI_FOC_Request_Item__c child:focChilds){
            Double qty = 0;
            qty = child.ASI_FOC_Actual_Quantity_Bottle__c == null ? child.ASI_FOC_Request_Quantity_Bottle__c : child.ASI_FOC_Actual_Quantity_Bottle__c;
            if (child.ASI_CRM_IGC_Cost_Per_case__c > 0){
                totalCost+= child.ASI_CRM_IGC_Cost_Per_case__c / child.ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c * qty;
            }
        }
        
        totalCost = totalCost.setScale(1);
        
        /* [VL 1.0] BEGIN */
        if(headerList.get(0).ASI_CRM_System_Remark__c == 'SG Promotion') isPromotionIncentive = true;
        /* [VL 1.0] END */
        
        return headerList != null && headerList.size() > 0 ? headerList.get(0) : null;  
    }
}