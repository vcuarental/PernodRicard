@isTest
public class EUR_CRM_PT_TestClassHelper {
    
    public static RecordType ApexConfigRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Apex_Configuration__c' and DeveloperName = 'EUR_CRM_Account_Running_Number_Normal' LIMIT 1];
    public static RecordType euacctPTRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_PT_Off_Trade' LIMIT 1];
    
    public static List<EUR_CRM_Region__c> createRegion(integer numberOfEURegion, String currencyCode, Id user){
        
        List<EUR_CRM_Region__c> regionEUList = new List<EUR_CRM_Region__c>();
        
        for(integer i = 0;i < numberOfEURegion;i++){
            EUR_CRM_Region__c regionEU = new EUR_CRM_Region__c();
            regionEU.CurrencyIsoCode = currencyCode;
            regionEU.EUR_CRM_Region_Code__c = 'TEST CODE';
            regionEU.EUR_CRM_Region_Owner__c = user;
            
            regionEUList.add(regionEU);
        }
        
        return regionEUList;
    }
    
    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner,  String recordtypename){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Region__c'+recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=recordtypeId,name = name,EUR_CRM_Region_Owner__c = regionOwner, ownerid = regionOwner);
        insert region;
        return region;
    }
    
    public static List<EUR_CRM_Territory__c> createTerritory(integer numberOfEUTerritory, String currencyCode, Id user, Id region){
        
        List<EUR_CRM_Territory__c> territoryEUList = new List<EUR_CRM_Territory__c>();
        
        for(integer i = 0;i < numberOfEUTerritory;i++){
            EUR_CRM_Territory__c territoryEU = new EUR_CRM_Territory__c();
            territoryEU.CurrencyIsoCode = currencyCode;
            territoryEU.EUR_CRM_Description__c = 'TEST DESCRIPTION';
            territoryEU.EUR_CRM_Territory_Owner__c = user;
            territoryEU.EUR_CRM_Territory_Code__c = 'TEST CODE';
            territoryEU.EUR_CRM_Region__c = region;
            
            territoryEUList.add(territoryEU);
        }
        
        return territoryEUList;
    }
    
    public static EUR_CRM_Account__c createEUAccount(String name){
        Id userId = UserInfo.getUserId();
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctPTRecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        //newAccount.EUR_CRM_Force_PRS_Image_Level__c = 'Leading';
        //newAccount.EUR_CRM_Force_PRS_Volume_Potential__c = 'Low';
        newAccount.EUR_CRM_Territory__c = territory.Id;
        return newAccount;
    }
    
    public static List<EUR_CRM_Account__c> createEUAccountList(Integer numberOfRecord, String name, String externalId){
        Id userId = UserInfo.getUserId();
        List<EUR_CRM_Account__c> createAccountList = new List<EUR_CRM_Account__c>();
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        
        for(integer i = 0; i<numberOfRecord; i++){
            EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
            newAccount.RecordTypeId = euacctPTRecordType.Id;
            newAccount.EUR_CRM_Status__c = 'New';
            newAccount.EUR_CRM_Business_Type__c = 'Outlet';
            newAccount.EUR_CRM_Territory__c = territory.Id;
            newAccount.EUR_CRM_External_ID__c = externalId+i;
            createAccountList.add(newAccount);
        }
        return createAccountList;
    }
    
    public static EUR_CRM_OP_Action_List_Template__c createActionListTemplate(){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__c' + 'EUR_PT_OP_Action_List_Template');
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'template';
        listTemplate.EUR_CRM_External_ID__c = 'PT_Check_Off_Trade_Display';
        listTemplate.recordtypeId = recordtypeId;
        return listTemplate;
    }
    
    public static List<EUR_CRM_ObjPromo__c> createObjPromo(integer numberofObjPromo, String recordTypeDeveloperName, String Name,EUR_CRM_OP_Action_List_Template__c template){
        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c'+ recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        for(integer i = 0;i < numberofObjPromo;i++){
            EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
            objPromo.RecordTypeId = recordtypeId;
            objPromo.Name = Name+i;
            objPromo.EUR_CRM_OP_Action_List_Template__c = template.Id;
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today() -1;
            objPromo.EUR_CRM_Active_End_Date__c = Date.today() + 1; 
            objPromoList.add(objPromo);
        }
        
        return objPromoList;
    }
    
    public static EUR_CRM_Visit_Action__c createVisitAction(EUR_CRM_Account__c euaccount, EUR_CRM_ObjPromo__c promo){
        EUR_CRM_Visit_Action__c visit = new EUR_CRM_Visit_Action__c();
        visit.EUR_CRM_Account__c = euaccount.id;
        visit.EUR_CRM_ObjPromo__c =  promo.Id;
        return visit;
    }
    
    public static List<EUR_CRM_ObjPromo_Target__c> createOPTarget(integer numberofOPTarget, String recordTypeDeveloperName, Id objPromoId, Id opTargetId, Id euAccountId, Id brandId){
        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c'+ recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
        
        for(integer i = 0;i < numberofOPTarget;i++){
            EUR_CRM_ObjPromo_Target__c opTarget = new EUR_CRM_ObjPromo_Target__c();
            opTarget.RecordTypeId = recordtypeId;
            opTarget.EUR_CRM_ObjPromo__c = objPromoId;
            opTarget.EUR_CRM_O_P_Target__c = opTargetId;
            opTarget.EUR_CRM_Account__c = euAccountId;
            opTarget.EUR_CRM_Brand__c = brandId;
            opTarget.EUR_CRM_Actual_No_of_Display__c = 10;
            opTarget.EUR_CRM_Actual_No_of_Display_per_Brand__c = 10;
            opTargetList.add(opTarget);
        }
        
        return opTargetList;
    }
    
    public static EUR_CRM_Category__c createCategory(String recordTypeDeveloperName){
        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Category__c'+ recordTypeDeveloperName);
        EUR_CRM_Category__c newCategory = new EUR_CRM_Category__c();
        newCategory.RecordTypeId = recordtypeId;
        newCategory.EUR_CRM_External_ID__c = 'Test Id';       
        return newCategory;
    }
    
    public static EUR_CRM_Brand__c createBrand(String Name, EUR_CRM_Category__c category){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Brand__c'+ 'EUR_PT_Brand');
        EUR_CRM_Brand__c newBrand = new EUR_CRM_Brand__c();
        newBrand.EUR_CRM_Category__c = category.Id;
        newBrand.Name = Name;
        
        return newBrand;         
    }
    
    public static EUR_CRM_ObjPromo_Account_Mapping__c createobjPromoAccMapping(String recordtypename, Id accountId, Id objectPromoId){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c'+ recordtypename);
        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMap = new EUR_CRM_ObjPromo_Account_Mapping__c
            (recordtypeid=recordtypeId,
             EUR_CRM_Account__c	=accountId,
             EUR_CRM_ObjPromo__c = objectPromoId             
            );
        
        return objPromoAccMap;
    }
    
    public static List<EUR_CRM_Contract__c> createTRContract(Integer numberOfRecord, String name, EUR_CRM_Account__c euaccount, Contact contact, String recordtypename){
        
        List<EUR_CRM_Contract__c> contractList = new List<EUR_CRM_Contract__c>();
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__c'+ recordtypename);
        for(integer i=0; i<numberOfRecord; i++){
            EUR_CRM_Contract__c testContract = new EUR_CRM_Contract__c();
            //fiContract.Name = name;
            testContract.EUR_CRM_Account__c = euaccount.Id;
            testContract.RecordtypeId = recordtypeId; 
            testContract.EUR_CRM_Start_Date__c = Date.Today();
            testContract.EUR_CRM_End_Date__c = Date.Today().addDays(365);            
            contractList.add(testContract);
        }        
        return contractList;
    }
    
    public static List<Contact> createContact(Integer numberOfRecord, String name, EUR_CRM_Account__c euaccount){
        List<Contact> contacts = new List<Contact>();
        for(integer i=0; i<numberOfRecord; i++){
            Contact contact = new Contact();
            contact.LastName = name;
            contact.EUR_CRM_Account__c = euaccount.Id;
            
            contacts.add(contact);
        }        
        return contacts;
    }
    public static List<EUR_CRM_Mechanic_Type__c> createMechType(String recordtypename){
        
        Map<String, String> mechTypeMap = new Map<String, String>{'Pouring Refund Spirits' => 'Finland - Pouring',
            'Pouring Refund Wines' => 'Finland - Pouring',
            'Selection Brands Spirits' => 'Finland - Selection',
            'Selection Brands Wines' => 'Finland - Selection',
            'Volume Targets and Rebates' => 'Finland - Selection'};         
                
                Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Mechanic_Type__c'+ recordtypename);
        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();
        
        for(String mechTypeName : mechTypeMap.keyset()){
            EUR_CRM_Mechanic_Type__c mechType = new EUR_CRM_Mechanic_Type__c();
            mechType.RecordTypeId = recordtypeId;
            mechType.EUR_CRM_Lump_Sum_Or_Per_BQ__c = true;
            mechType.Name = mechTypeName;
            mechTypeList.add(mechType);
        }              
        return mechTypeList;
    }
    
    public static List<EUR_CRM_Contract_Activity_Item__c> createContractActivityItem(Integer numberOfRecord, EUR_CRM_Contract__c contract, EUR_CRM_Mechanic_Type__c mechanicType){
        
        List<EUR_CRM_Contract_Activity_Item__c> activityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        
        for(integer i=0; i<numberOfRecord; i++){
            EUR_CRM_Contract_Activity_Item__c activityItem = new EUR_CRM_Contract_Activity_Item__c();
            activityItem.EUR_CRM_Amount__c = 100;
            activityItem.EUR_CRM_Contract__c = contract.Id;
            activityItem.EUR_CRM_Mechanic_Type__c = mechanicType.Id;
            activityItems.add(activityItem);
        }        
        return activityItems;
    }
    
    public static EUR_CRM_Size__c createSize(String name, String recordtypename ){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Size__c'+ recordtypename);
        EUR_CRM_Size__c size = new EUR_CRM_Size__c();
        size.recordtypeid=recordtypeId;
        size.name = name;
        return size ;
    }
    
    public static EUR_CRM_GB_Volume_Tracker_Line_Item__c createVolumeTracker(String recordtypename, EUR_CRM_Size__c size, EUR_CRM_Contract_Activity_Item__c contractActivityItem, EUR_CRM_GB_Volume_Tracker__c volumeReference){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_GB_Volume_Tracker_Line_Item__c'+ recordtypename);
        EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTracker = new EUR_CRM_GB_Volume_Tracker_Line_Item__c();
        volumeTracker.recordtypeid = recordtypeId;
        volumeTracker.EUR_CRM_Brand_Quality_Size__c = size.Id; 
        volumeTracker.EUR_CRM_Contract_Activity_Item__c = contractActivityItem.id;
        volumeTracker.EUR_CRM_Initial_Contract_Volume__c= 100;
        volumeTracker.EUR_CRM_Actual_Qty__c = 80;
        volumeTracker.EUR_CRM_Distance_To_Go__c = 2000;   
        volumeTracker.EUR_CRM_Volume_Tracker__c = volumeReference.Id;
        return volumeTracker ;
    }
    
     public static List<EUR_CRM_GB_Volume_Tracker__c> createVolumeTracker(integer numberofVolumeTracker, String recordTypeDeveloperName, Id contract){        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_GB_Volume_Tracker__c'+ recordTypeDeveloperName);
        List<EUR_CRM_GB_Volume_Tracker__c> volumeTrackerList = new List<EUR_CRM_GB_Volume_Tracker__c>();        
        for(integer i = 0;i < numberofVolumeTracker;i++){
            EUR_CRM_GB_Volume_Tracker__c volumeTracker = new EUR_CRM_GB_Volume_Tracker__c();
            volumeTracker.RecordTypeId = recordtypeId;
            volumeTracker.EUR_CRM_Contract__c = contract;
            
            volumeTrackerList.add(volumeTracker);
        }        
        return volumeTrackerList;
    }    
}