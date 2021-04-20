/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCS_createCSRequestLine
 * Description: 

 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ----------------------------------------
 * 23/11/2017       Kevin Choi             Created          
***********************************************************************************/
public class ASI_CRM_VN_CapsuleCS_createCSRequestLine{

    private final static Set<String> OUTLET_RECORD_TYPE_SET = new Set<String> {
    	'ASI_CRM_VN_Outlet',
        'ASI_CRM_VN_Outlet_Inactive',
        'ASI_CRM_VN_PG_Outlets',
        'ASI_CRM_VN_Inactive_Off_Trade_Outlet',
        'ASI_CRM_VN_Off_Trade_Outlet'
    };
    
    private final static String ACTUAL_OFFTAKE_RECORD_TYPE = 'ASI_CRM_VN_Actual_Offtake';
    
    public ASI_CRM_VN_CapsuleCS_createCSRequestLine(){

    }

    public void executeTrigger(List<sObject> newList) {
        system.debug('Trigger createCSRequestLineItem function');
        Map<Id,ASI_GiftBox_Request_Header__c> contractIdHeaderMap = new Map<Id,ASI_GiftBox_Request_Header__c>();
        Set<Id> customerIdSet = new Set<Id>();

        List<ASI_GiftBox_Request_Header__c> reuquestHeaderList = (List<ASI_GiftBox_Request_Header__c>) newList; 

        for (ASI_GiftBox_Request_Header__c reuquest : reuquestHeaderList){
            system.debug('reuquest.ASI_CRM_Customer__c: '+reuquest.ASI_CRM_Customer__c);
            customerIdSet.add(reuquest.ASI_CRM_Customer__c);
            contractIdHeaderMap.put(reuquest.ASI_CRM_VN_Contract__c, reuquest);
        }
        system.debug('customerIdSet: '+customerIdSet);
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> childCustomerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerList());

        Set<Id> parentCustomerIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : childCustomerMap.values()) {
            parentCustomerIdSet.add(customer.ASI_CRM_CN_Parent_Outlet__c);
        }

        for(ASI_CRM_AccountsAdditionalField__c customer : retrieveCustomerList(parentCustomerIdSet)) {
            childCustomerMap.put(customer.Id, customer);
        }
        
        Set<Id> allCustomerIdSet = new Set<Id>();
        Map<Id, Set<Id>> parentChildCustomerIdMap = new Map<Id, Set<Id>>();
        ASI_CRM_VN_OutletHierarchy outletHierarchyHelper = new ASI_CRM_VN_OutletHierarchy(childCustomerMap.values());
        for(Id customerId : customerIdSet) {
            Set<Id> tempCustomerIdSet = new Set<Id>();
            tempCustomerIdSet.add(customerId);
            allCustomerIdSet.add(customerId);
        	for(ASI_CRM_AccountsAdditionalField__c customer : outletHierarchyHelper.getAllOutlet(customerId)) {
                tempCustomerIdSet.add(customer.Id);
                allCustomerIdSet.add(customer.Id);
            }
            parentChildCustomerIdMap.put(customerId, tempCustomerIdSet);
        }
        
        //Get all expenditure related to Contract
        List<ASI_CRM_VN_Contract_Expenditure__c> contactExpenditureList = [select Id, ASI_CRM_Sub_Brand__c, ASI_CRM_Sub_Brand__r.Name, 
                                                                           ASI_CRM_VN_Unit_Incentive__c, ASI_CRM_VN_Contract__c, 
                                                                           ASI_CRM_VN_Total_Amount__c, ASI_CRM_Cal_Balance_Amount__c, 
                                                                           ASI_CRM_VN_Sales_Target__c
                                                                           from ASI_CRM_VN_Contract_Expenditure__c 
                                                                           where ASI_CRM_VN_Contract__c IN : contractIdHeaderMap.keySet()];
        system.debug('contactExpenditureList: '+contactExpenditureList);
        Set<Id> subBrandIdSet = new Set<Id>();

        for (ASI_CRM_VN_Contract_Expenditure__c expenditure : contactExpenditureList){
            subBrandIdSet.add(expenditure.ASI_CRM_Sub_Brand__c);
        }
		// Get all Actual Offtake with sub-brand in expenditures
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = [select Id, ASI_TH_CRM_Offtake_G_L_Date__c, ASI_TH_CRM_Quantity__c,
                                                                ASI_TH_CRM_Sub_brand__c,ASI_CRM_CS_Request_Item__c,ASI_CRM_SG_Customer__c
                                                                from ASI_TH_CRM_Actual_Offtake__c 
                                                                where ASI_TH_CRM_Sub_brand__c IN: subBrandIdSet 
                                                                AND ASI_CRM_SG_Customer__c IN: allCustomerIdSet
                                                                AND ASI_CRM_CS_Request_Item__c = null 
                                                                AND RecordType.DeveloperName = :ACTUAL_OFFTAKE_RECORD_TYPE];

        Map<String,ASI_TH_CRM_Actual_Offtake__c> actualOfftakeMap = new Map<String,ASI_TH_CRM_Actual_Offtake__c>();
        system.debug('actualOfftakeList: '+actualOfftakeList);

        for (ASI_TH_CRM_Actual_Offtake__c offTake : actualOfftakeList){
            actualOfftakeMap.put(offTake.ASI_TH_CRM_Sub_brand__c, offTake);
        }

        List<ASI_GiftBox_Request_Item__c> requestItemInsertList = new List<ASI_GiftBox_Request_Item__c>();
        List<ASI_CRM_VN_Contract_Expenditure__c> expenditureNoBalanceList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        Map<String,ASI_GiftBox_Request_Item__c> requestItemInsertMap = new Map<String,ASI_GiftBox_Request_Item__c>();
		Map<String, List<ASI_TH_CRM_Actual_Offtake__c>> subbrandActualOfftakeMap = new Map<String, List<ASI_TH_CRM_Actual_Offtake__c>>();
        
        for (ASI_CRM_VN_Contract_Expenditure__c expenditure : contactExpenditureList){
            if (expenditure.ASI_CRM_Cal_Balance_Amount__c != 0){
        		List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeInsertList = new List<ASI_TH_CRM_Actual_Offtake__c>();
                Boolean isActualOfftakeExist = false;
				Decimal totalAmount = 0;
                Decimal totalQty = 0;
                for (ASI_TH_CRM_Actual_Offtake__c offTake : actualOfftakeList){
					Set<Id> parentChildCustomerIdSet = parentChildCustomerIdMap.get(contractIdHeaderMap.get(expenditure.ASI_CRM_VN_Contract__c).ASI_CRM_Customer__c);
                    
                    Date startDate = contractIdHeaderMap.get(expenditure.ASI_CRM_VN_Contract__c).ASI_CRM_VN_Contract_Start_Date__c.toStartOfMonth();
                    Date endDate = contractIdHeaderMap.get(expenditure.ASI_CRM_VN_Contract__c).ASI_CRM_VN_Contract_Ending_Date__c;
                    Integer numberOfDays = Date.daysInMonth(endDate.year(), endDate.month());
                    endDate = Date.newInstance(endDate.year(), endDate.month(), numberOfDays);
                    
                    if (startDate <= offTake.ASI_TH_CRM_Offtake_G_L_Date__c &&
                        endDate >= offTake.ASI_TH_CRM_Offtake_G_L_Date__c &&
                        parentChildCustomerIdSet.contains(offTake.ASI_CRM_SG_Customer__c) && 
                        expenditure.ASI_CRM_Sub_Brand__c == offTake.ASI_TH_CRM_Sub_brand__c)
                    {
                        totalQty += (offTake.ASI_TH_CRM_Quantity__c == null ? 0 : offTake.ASI_TH_CRM_Quantity__c);
                        isActualOfftakeExist = true;
                        actualOfftakeInsertList.add(offTake);
                    }
                }
                
                totalAmount += totalQty * (expenditure.ASI_CRM_VN_Unit_Incentive__c);

                // If actual offtake found, generate the request line with the qunatity in actual offtake 
                if (isActualOfftakeExist){
                    ASI_GiftBox_Request_Item__c newRequestItem = new ASI_GiftBox_Request_Item__c();
                    newRequestItem.recordTypeId = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__cASI_CRM_VN_Capsule_CS_Request_Item');
                    newRequestItem.ASI_GiftBox_Request_Id__c = contractIdHeaderMap.get(expenditure.ASI_CRM_VN_Contract__c).Id;
                    newRequestItem.ASI_CRM_Subbrand__c = expenditure.ASI_CRM_Sub_Brand__c;
                    newRequestItem.ASI_GiftBox_Request_Item_Unit_Price__c = expenditure.ASI_CRM_VN_Unit_Incentive__c;
                    newRequestItem.ASI_GiftBox_Request_Quantity__c = totalQty;
                    newRequestItem.ASI_CRM_Amount__c = totalAmount > expenditure.ASI_CRM_Cal_Balance_Amount__c ? expenditure.ASI_CRM_Cal_Balance_Amount__c : totalAmount;
                    newRequestItem.ASI_CRM_Original_Amount__c = totalAmount > expenditure.ASI_CRM_Cal_Balance_Amount__c ? expenditure.ASI_CRM_Cal_Balance_Amount__c : totalAmount;

                    requestItemInsertMap.put(expenditure.ASI_CRM_Sub_Brand__c,newRequestItem);
                    subbrandActualOfftakeMap.put(expenditure.ASI_CRM_Sub_Brand__c,actualOfftakeInsertList);
                }
            }else expenditureNoBalanceList.add(expenditure);
        }

        insert requestItemInsertMap.values();

		
        List<ASI_TH_CRM_Actual_Offtake__c> updateActualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        for (String subBrandId : subbrandActualOfftakeMap.keySet()){
            if (requestItemInsertMap.get(subBrandId) != null) {
                for(ASI_TH_CRM_Actual_Offtake__c offtake : subbrandActualOfftakeMap.get(subBrandId)) {
                	offtake.ASI_CRM_CS_Request_Item__c = requestItemInsertMap.get(offtake.ASI_TH_CRM_Sub_brand__c).Id;
                    updateActualOfftakeList.add(offtake);
                }
            }
        }
		// Start Error Handling
        for (ASI_GiftBox_Request_Header__c reuquest : reuquestHeaderList){
            if (subBrandIdSet.size() > 0 && subbrandActualOfftakeMap.size() == 0){
                reuquest.addError('Cannot Generate Request Line Item for any Sub-Brand, no Actual Offtake found.');
            }

            if (contactExpenditureList.size() == expenditureNoBalanceList.size()){
                reuquest.addError('Cannot Generate any Request Line Item for any Sub-Brand, all banlance are zero.');
            }
        }
        if (updateActualOfftakeList.size() > 0)
            update updateActualOfftakeList;
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList() {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE RecordType.DeveloperName in :OUTLET_RECORD_TYPE_SET ' +
                       'AND ASI_CRM_CN_Parent_Outlet__c != null';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE Id in :customerIdSet ';

        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
}