/*
*    Description    :    Helper class to create test data (ZA Affiliates)
*
*    Version    Author        Date        Description
*    1.0        
*    2.0        Sid           31/12/2015  Method to create test data for SO Item
*/

public class EUR_CRM_ZA_TestClassHelper{

    public static Map<String,Id> zaAccountRecordTypeIdsMap = new Map<String,Id>();
    public static Map<String, Id> zaObjPromoRecordTypeIdsMap = new Map<String, Id>();

    public static Id zaHeadOfficeContractRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__cEUR_ZA_Head_Office_Contract');
    public static Id zaOutletContractRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__cEUR_ZA_Outlet_Contract');
    public static Id zaBQSRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Size__cEUR_ZA_Size');
    public static Id zaVisitFrequencyRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Visit_Frequency__cEUR_ZA_Visit_Frequency');
    public static Id zaRouteTemplateRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Route_Template__cEUR_ZA_Route_Template');
    public static Id zaAccountVOlTrackItemsRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Account_Volume_Tracker_Line_Item__cEUR_CRM_ZA_Account_Volume_Tracker_Line_Item');
    public static Id zaAccountVOlTrackPeriodRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Volume_Tracker_Period__cEUR_CRM_ZA_Account_Volume_Tracker_Period');
    //public static Id zaSalesOrderRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Sales_Order__cEUR_ZA_Direct_Sales_Order');
    public static Id zaSalesOrderRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Sales_Order__cEUR_Direct');
    public static Id zaPOSMOrderRectype = Global_RecordTypeCache.getRtId('EUR_CRM_POSM_Order__cEUR_ZA_POSM_Order');
    public static Id zaSalesOrderItemRectype = Global_RecordTypeCache.getRtId('EUR_CRM_Sales_Order_Items__cEUR_ZA_Direct_Sales_Order_Item');
    public static Id skuRectype = Global_RecordTypeCache.getRtId('EUR_CRM_SKU__cEUR_ZA_SKU');
    public static Id zaPOSMOrderItemRectype = Global_RecordTypeCache.getRtId('EUR_CRM_POSM_Order_Item__cEUR_ZA_POSM_Order_Item');
    public static Id zaAccountMappingRectype = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__cEUR_ZA_OP_Account_Mapping');

    
    public static List<EUR_CRM_Account__c> createEUAccount(Integer ctr, String name, String recordTypeName)
    {
        if(zaAccountRecordTypeIdsMap.size() < 1){
            getRecordAccountTypeIds();
        }
        List<EUR_CRM_Account__c> newEUAccts = new List<EUR_CRM_Account__c>();
        for(integer i=0;i<ctr;i++){ 
            EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c();
            newAccount.Name = name+i;
            newAccount.RecordTypeId = zaAccountRecordTypeIdsMap.get(recordTypeName);
            newAccount.EUR_CRM_Business_Type__c = 'Head Office';
            system.debug('%%RECTYPEMAP: '+zaAccountRecordTypeIdsMap);
            system.debug('%%RECTYPENAME: '+recordTypeName);
            system.debug('%%RECTYPE: '+newAccount.RecordTypeId);

            newEUAccts.add(newAccount);
        }
        
        return newEUAccts;
    }

    public static void getRecordAccountTypeIds(){
        for(RecordType recType : [SELECT Id, DeveloperName FROM RecordType where SobjectType='EUR_CRM_Account__c' AND
                                    (DeveloperName = 'EUR_ZA_Distributor' OR 
                                     DeveloperName = 'EUR_ZA_Off_Trade' OR 
                                     DeveloperName = 'EUR_ZA_On_Trade_Direct' OR 
                                     DeveloperName = 'EUR_ZA_On_Trade_Indirect' OR 
                                     DeveloperName = 'EUR_ZA_On_Trade_Informal')]){
            zaAccountRecordTypeIdsMap.put(recType.DeveloperName, recType.Id);
        }
    }

    public static void getObjPromoRecordTypeIds(){
        for(RecordType recType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='EUR_CRM_ObjPromo__c' AND 
                                    (DeveloperName = 'EUR_ZA_On_Trade_Promotion' OR 
                                    DeveloperName = 'EUR_ZA_Off_Trade_Promotion')]){
            zaObjPromoRecordTypeIdsMap.put(recType.DeveloperName, recType.Id);
        }
    }

    public static List<Contact> createContact(Integer ctr, String name, EUR_CRM_Account__c euaccount){
        List<Contact> contacts = new List<Contact>();

        for(integer i=0;i<ctr;i++){
            Contact contact = new Contact();
            contact.LastName = name;
            contact.EUR_CRM_Account__c = euaccount.Id;

            contacts.add(contact);
        }
        
        return contacts;
    }

    public static List<EUR_CRM_Contract__c> createZAContract(Integer ctr, String name, EUR_CRM_Account__c euaccount, Contact contact, String recordtypeName){

        List<EUR_CRM_Contract__c> zaContracts = new List<EUR_CRM_Contract__c>();

        for(integer i=0;i<ctr;i++){
            EUR_CRM_Contract__c zaContract = new EUR_CRM_Contract__c();
            //zaContract.Name = name;
            zaContract.EUR_CRM_Account__c = euaccount.Id;
            if(recordtypeName == 'EUR_ZA_Head_Office_Contract'){
                zaContract.RecordtypeId = zaHeadOfficeContractRectype;
            } else{
                zaContract.RecordtypeId = zaOutletContractRectype;
            }
            zaContract.EUR_CRM_Start_Date__c = Date.Today();
            zaContract.EUR_CRM_End_Date__c = Date.Today().addDays(365);
            zaContract.EUR_CRM_Contact__c = contact.Id;

            zaContracts.add(zaContract);
        }
        
        return zaContracts;
    }


    public static List<EUR_CRM_Contract_Activity_Item__c> createContractActivityItem(Integer ctr, EUR_CRM_Contract__c contract, EUR_CRM_Mechanic_Type__c mechanicType){

        List<EUR_CRM_Contract_Activity_Item__c> activityItems = new List<EUR_CRM_Contract_Activity_Item__c>();

        for(integer i=0;i<ctr;i++){
            EUR_CRM_Contract_Activity_Item__c activityItem = new EUR_CRM_Contract_Activity_Item__c();
            activityItem.EUR_CRM_Amount__c = 100;
            activityItem.EUR_CRM_Contract__c = contract.Id;
            activityItem.EUR_CRM_Mechanic_Type__c = mechanicType.Id;

            activityItems.add(activityItem);
        }
        
        return activityItems;
    }

    public static List<EUR_CRM_Contract_Product_Item__c> createProductItem(Integer ctr, EUR_CRM_Contract_Activity_Item__c contractActivityItem){

        List<EUR_CRM_Contract_Product_Item__c> productItems = new List<EUR_CRM_Contract_Product_Item__c>();

        for(integer i=0;i<ctr;i++){
            EUR_CRM_Contract_Product_Item__c productItem = new EUR_CRM_Contract_Product_Item__c();
            productItem.EUR_CRM_Contract_Activity_Item__c = contractActivityItem.Id;
            productItem.EUR_CRM_Amount__c = 100;
            productItem.EUR_CRM_Quantity__c = 10;


            productItems.add(productItem);
        }
        
        return productItems;
    }

    //CREATE Brand Quality
    public static List<EUR_CRM_Size__c> createBrandQualitySize(Integer ctr, String brandQualityName, String externalID, Id brandQuality){
        
        List<EUR_CRM_Size__c> brandQUalitySizes = new List<EUR_CRM_Size__c>();
        
        for(integer i = 0;i < ctr;i++){
            EUR_CRM_Size__c brandQualitySize = new EUR_CRM_Size__c();
            brandQualitySize.RecordTypeId = zaBQSRectype;
            brandQualitySize.Name = brandQualityName;
            brandQualitySize.EUR_CRM_External_ID__c = externalID;
            brandQualitySize.EUR_CRM_Brand_Quality__c = brandQuality;
            brandQUalitySizes.add(brandQualitySize);
        }
        
        return brandQUalitySizes;
    }

    public static List<EUR_CRM_Visit_Frequency__c> createVisitFrequency(Integer ctr, String frequencyName){
        
        List<EUR_CRM_Visit_Frequency__c> visitFrequencies = new List<EUR_CRM_Visit_Frequency__c>();
        
        for(integer i = 0;i < ctr;i++){
            EUR_CRM_Visit_Frequency__c visitFreq = new EUR_CRM_Visit_Frequency__c();
            visitFreq.RecordTypeId = zaVisitFrequencyRectype;
            visitFreq.Name = frequencyName;
            
            visitFrequencies.add(visitFreq);
        }
        
        return visitFrequencies;  
    }


    public static List<EUR_CRM_ObjPromo__c> createObjAndProms(Integer ctr, String recordtypeName){
        if(zaObjPromoRecordTypeIdsMap.size() < 1 ){
            getObjPromoRecordTypeIds();
        }
        List<EUR_CRM_ObjPromo__c> objAndProms = new List<EUR_CRM_ObjPromo__c>();
        for(integer i = 0;i < ctr;i++){
            EUR_CRM_ObjPromo__c objAndProm = new EUR_CRM_ObjPromo__c();
            objAndProm.RecordTypeId = zaObjPromoRecordTypeIdsMap.get(recordtypeName);
            objAndProm.Name = 'TestName'+i;
            objAndProm.EUR_CRM_Active_Start_Date__c = Date.Today();
            objAndProm.EUR_CRM_Active_End_Date__c = Date.Today().addDays(360);
            objAndProm.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20);
            
            objAndProms.add(objAndProm);
        }
        
        return objAndProms;
    }

    public static List<EUR_CRM_Route_Template__c> createRT(Integer ctr, String name)
    {
    
        List<EUR_CRM_Route_Template__c> rTemplates = new List<EUR_CRM_Route_Template__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_Route_Template__c rTemplate = new EUR_CRM_Route_Template__c();
            rTemplate.EUR_CRM_Route_Template_Name__c = name+i;
            rTemplate.RecordTypeId = zaRouteTemplateRectype;
            rTemplate.EUR_CRM_Start_Date__c = Date.Today().AddDays(7).toStartOfWeek().AddDays(1);

            rTemplates.add(rTemplate);
        }
        
        return rTemplates;
    }

    // Create Budgets
    public static List<EUR_CRM_Budget__c> createBudget(Integer ctr)
    {
        RecordType recType = Global_RecordTypeCache.getRtRec('EUR_CRM_Budget__cEUR_ZA_On_Trade_Budget');

        List<EUR_CRM_Budget__c> budgetList = new List<EUR_CRM_Budget__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_Budget__c budget = new EUR_CRM_Budget__c();
            budget.RecordTypeId = recType.Id;
            budget.RecordType = recType;
            budgetList.add(budget);
        }
        return budgetList;
    }

    //Create Budget Transactions
    public static List<EUR_CRM_Budget_Transaction__c> createBudgetTransactions (String recordTypeDeveloperName, Id budgetId, 
                                                                                Integer numberOfTxn, Decimal amount,
                                                                                String transactionCategory, String transactionType)
    {
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Budget_Transaction__c'+recordTypeDeveloperName);
        List<EUR_CRM_Budget_Transaction__c> transactions = new List<EUR_CRM_Budget_Transaction__c>();
        
        for(Integer i=0; i<=numberOfTxn; i++){
            EUR_CRM_Budget_Transaction__c txn = new EUR_CRM_Budget_Transaction__c();
            txn.RecordTypeId = recordtypeId;
            txn.EUR_CRM_Budget_Header__c = budgetId;
            txn.EUR_CRM_Amount__c = amount;
            txn.EUR_CRM_Transaction_Category__c = transactionCategory;
            txn.EUR_CRM_Transaction_Type__c = transactionType;
            transactions.add(txn);
        }
        return transactions;
    }

    public static List<EUR_CRM_Account_Volume_Tracker__c> createAccountVolumeTracker(Integer ctr, EUR_CRM_Account__c account)
    {
    
        List<EUR_CRM_Account_Volume_Tracker__c> volTracks = new List<EUR_CRM_Account_Volume_Tracker__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_Account_Volume_Tracker__c volTrack = new EUR_CRM_Account_Volume_Tracker__c();
            volTrack.EUR_CRM_Account__c = account.id;

            volTracks.add(volTrack);
        }
        
        return volTracks;
    }

    public static List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> createAccountVolumeTrackerLineItem(Integer ctr, EUR_CRM_Account_Volume_Tracker__c accountVolTracker)
    {
    
        List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackItems = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
            volTrackItem.EUR_CRM_Account_Volume_Tracker__c = accountVolTracker.id;
            volTrackItem.EUR_CRM_Active__c = true;
            volTrackItem.RecordtypeId = zaAccountVOlTrackItemsRectype;

            volTrackItems.add(volTrackItem);
        }
        
        return volTrackItems;
    }
    
    public static List<EUR_CRM_Sales_Order__c> createSalesOrder(Integer ctr, EUR_CRM_Account__c account)
    {
    
        List<EUR_CRM_Sales_Order__c> salesOrders = new List<EUR_CRM_Sales_Order__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_Sales_Order__c salesOrder = new EUR_CRM_Sales_Order__c();
            salesOrder.EUR_CRM_Account__c = account.id;
            salesOrder.EUR_CRM_Order_Date__c = Date.Today();
            salesOrder.RecordtypeId = zaSalesOrderRectype;

            salesOrders.add(salesOrder);
        }
        
        return salesOrders;
    }
    
    public static List<EUR_CRM_POSM_Order__c> createPOSMOrder(Integer ctr, EUR_CRM_Account__c account)
    {
    
        List<EUR_CRM_POSM_Order__c> posmOrders = new List<EUR_CRM_POSM_Order__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_POSM_Order__c posmOrder = new EUR_CRM_POSM_Order__c();
            posmOrder.EUR_CRM_Account__c = account.id;
            posmOrder.EUR_CRM_Order_Date__c = Date.Today();
            posmOrder.RecordtypeId = zaPOSMOrderRectype;

            posmOrders.add(posmOrder);
        }
        
        return posmOrders;
    }
    
    public static List<EUR_CRM_Sales_Order_Items__c> createSalesOrderItem(Integer ctr){
        
        List<EUR_CRM_Sales_Order_Items__c> soItemList = new List<EUR_CRM_Sales_Order_Items__c>();
        for(Integer i = 0; i < ctr; i++){
            
            EUR_CRM_Sales_Order_Items__c objSoItem = new EUR_CRM_Sales_Order_Items__c();
            objSoItem.RecordtypeId = zaSalesOrderItemRectype;
            soItemList.add(objSoItem);
        }
        return soItemList;
    }
    
    public static List<EUR_CRM_POSM_Order_Item__c> createPOSMOrderItems(Integer ctr){
        
        List<EUR_CRM_POSM_Order_Item__c> posmItemList = new List<EUR_CRM_POSM_Order_Item__c>();
        for(Integer i = 0; i < ctr; i++){
            
            EUR_CRM_POSM_Order_Item__c objPosmItem = new EUR_CRM_POSM_Order_Item__c();
            objPosmItem.RecordtypeId = zaPOSMOrderItemRectype;
            posmItemList.add(objPosmItem);
        }
        return posmItemList;
    }
    
    public static List<EUR_CRM_SKU__c> createSku(Integer ctr){
    
        List<EUR_CRM_SKU__c> skuList = new List<EUR_CRM_SKU__c>();
        for(Integer i = 0; i < ctr; i++){
            
            EUR_CRM_SKU__c objSku = new EUR_CRM_SKU__c();
            objSku.RecordtypeId = skuRectype;
            skuList.add(objSku);
        }
        return skuList; 
    }
    
	public static List<EUR_CRM_ObjPromo_Account_Mapping__c> createAccMap(Integer ctr, EUR_CRM_Account__c euaccount, EUR_CRM_ObjPromo__c objProm){
      
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccMapList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
       
        for(integer i = 0; i < ctr; i++){
            
            EUR_CRM_ObjPromo_Account_Mapping__c accMap = new EUR_CRM_ObjPromo_Account_Mapping__c();
            accMap.RecordTypeId = zaAccountMappingRectype;
            accMap.EUR_CRM_Account__c = euaccount.Id;
            accMap.EUR_CRM_ObjPromo__c = objProm.Id; 
            accMap.EUR_CRM_Do_Not_Reactivate__c = false;
            opAccMapList.add(accMap); 
        }
        return opAccMapList;   
	}

    /*
        Creates Visit Actions
        EUR_CRM_Visit_Action__c
    */ 
    public static List<EUR_CRM_Visit_Action__c> createVisitAction(Integer ctr, EUR_CRM_ObjPromo__c objPromo){
        List<EUR_CRM_Visit_Action__c> actionsList = new List<EUR_CRM_Visit_Action__c>();
        for(Integer i = 0; i < ctr; i++){
            EUR_CRM_Visit_Action__c newVisit = new EUR_CRM_Visit_Action__c();
            newVisit.EUR_CRM_ObjPromo__c = objPromo.Id;
            actionsList.add(newVisit);
        }
        return actionsList;
    }
}