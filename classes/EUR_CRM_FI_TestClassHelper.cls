public class EUR_CRM_FI_TestClassHelper{
    public static Map<String,Id> fiAccountRecordTypeIds = new Map<String,Id>();
    public static Id fiChainContractRectype = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_FI_Chain_Contract');
    public static Id fiIndependentContractRectype = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_FI_Independent_Contract');
    public static Id fiBQSRectype = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c', 'EUR_FI_Size');
    public static Id fiVisitFrequencyRectype = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Frequency__c', 'EUR_FI_Visit_Frequency');
    public static Id fiObjecttivesAndPromotionsRectype = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo__c', 'EUR_FI_On_Trade_O_P');

    public static List<EUR_CRM_Account__c> createEUAccount(Integer ctr, String name, String recordTypeName)
    {
        getRecordAccountTypeIds();
        List<EUR_CRM_Account__c> newEUAccts = new List<EUR_CRM_Account__c>();
        for(integer i=0;i<ctr;i++){
            EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c();
            newAccount.Name = name+i;
            newAccount.RecordTypeId = fiAccountRecordTypeIds.get(recordTypeName);
            newAccount.EUR_CRM_Business_Type__c = 'Head Office';
            system.debug('%%RECTYPEMAP: '+fiAccountRecordTypeIds);
            system.debug('%%RECTYPENAME: '+recordTypeName);
            system.debug('%%RECTYPE: '+newAccount.RecordTypeId);

            newEUAccts.add(newAccount);
        }
        
        return newEUAccts;
    }

    public static void getRecordAccountTypeIds(){
        fiAccountRecordTypeIds.put('EUR_FI_Direct_On_Trade', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_FI_Direct_On_Trade'));
        fiAccountRecordTypeIds.put('EUR_FI_Direct_Off_Trade', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_FI_Direct_Off_Trade'));
        fiAccountRecordTypeIds.put('EUR_FI_Indirect_On_Trade', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_FI_Indirect_On_Trade'));
        fiAccountRecordTypeIds.put('EUR_FI_Indirect_Off_Trade', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_FI_Indirect_Off_Trade'));
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

    public static List<EUR_CRM_Contract__c> createFIContract(Integer ctr, String name, EUR_CRM_Account__c euaccount, Contact contact, String recordtypeName){

        List<EUR_CRM_Contract__c> fiContracts = new List<EUR_CRM_Contract__c>();

        for(integer i=0;i<ctr;i++){
            EUR_CRM_Contract__c fiContract = new EUR_CRM_Contract__c();
            //fiContract.Name = name;
            fiContract.EUR_CRM_Account__c = euaccount.Id;
            if(recordtypeName == 'EUR_FI_Independent_Contract'){
                fiContract.RecordtypeId = fiIndependentContractRectype;
            } else{
                fiContract.RecordtypeId = fiChainContractRectype;
            }
            fiContract.EUR_CRM_Start_Date__c = Date.Today();
            fiContract.EUR_CRM_End_Date__c = Date.Today().addDays(365);


            fiContracts.add(fiContract);
        }
        
        return fiContracts;
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
            brandQualitySize.RecordTypeId = fiBQSRectype;
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
            visitFreq.RecordTypeId = fiVisitFrequencyRectype;
            visitFreq.Name = frequencyName;
            
            visitFrequencies.add(visitFreq);
        }
        
        return visitFrequencies;
    }


    public static List<EUR_CRM_ObjPromo__c> createObjAndProms(Integer ctr){
        
        List<EUR_CRM_ObjPromo__c> objAndProms = new List<EUR_CRM_ObjPromo__c>();
        
        for(integer i = 0;i < ctr;i++){
            EUR_CRM_ObjPromo__c objAndProm = new EUR_CRM_ObjPromo__c();
            objAndProm.RecordTypeId = fiObjecttivesAndPromotionsRectype;
            objAndProm.Name = 'TestName'+i;
            objAndProm.EUR_CRM_Active_Start_Date__c = Date.Today();
            objAndProm.EUR_CRM_Active_End_Date__c = Date.Today().addDays(360);
            objAndProm.EUR_CRM_Evaluation_Period_End_Date__c = Date.Today().addDays(20);
            
            objAndProms.add(objAndProm);
        }
        
        return objAndProms;
    }
}