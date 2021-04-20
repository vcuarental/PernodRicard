/**********************************************************************************
 * Name : ASI_GiftBox_RequestItemHelperTest
 * Created : DC @03/30/2016 3:14 PM
 * Revision History:
 * 1. 03/30/2016 - [DC 1.0] Created
 * 2019/01/07 - Andy Zhang insert unit price
 
 **********************************************************************************/

@isTest(seeAllData=false)
    private class ASI_GiftBox_RequestItemHelperTest { 
        static ASI_GiftBox_Request_Header__c requestHeader=new ASI_GiftBox_Request_Header__c();
        static ASI_GiftBox_Request_Item__c requestItem=new ASI_GiftBox_Request_Item__c();
        static ASI_GiftBox_Customer__c customer = new ASI_GiftBox_Customer__c();
        static ASI_GiftBox_Inventory_Master__c item = new ASI_GiftBox_Inventory_Master__c();
        
        static void insertCustomer(){
            Id recordId = Schema.SObjectType.ASI_GiftBox_Request_Item__c.getRecordTypeInfosByName().get('ASI VN POSM Request Item').getRecordTypeId();
            customer.RecordTypeID = recordId ;
            customer.Name='test customer';
            insert customer;
            
            
        }
       
       
        static testMethod  void insertItem(){    
            item.RecordTypeID = Schema.SObjectType.ASI_GiftBox_Inventory_Master__c.getRecordTypeInfosByName().get('ASI GiftBox VN GiftBox Master').getRecordTypeId();
            item.Name='test_item1';
            item.ASI_GiftBox_Unit_Price__c = 10;
            item.ASI_CRM_Category__c = ' Podium stand';      
            insert item;
           
            
        }
        
        static testMethod  void insertRequest(){
            insertItem();
            requestHeader.RecordTypeID = Schema.SObjectType.ASI_GiftBox_Request_Header__c.getRecordTypeInfosByName().get('ASI POSM VN Request').getRecordTypeId();
            requestHeader.ASI_CRM_Customer__c=customer.RecordTypeID;   
            requestHeader.ASI_GiftBox_Status__c='Complete';
            insert requestHeader;            
                         
            ASI_GiftBox_Request_Header__c headerID = new ASI_GiftBox_Request_Header__c();
            headerID = [SELECT Id,OwnerId,
                               RecordTypeID,
                               ASI_CRM_Customer__c,
                               ASI_GiftBox_Status__c
                        FROM ASI_GiftBox_Request_Header__c 
                        WHERE Id =: requestHeader.Id];   
            System.assertEquals('Complete',headerID.ASI_GiftBox_Status__c);
            System.assertEquals(headerID.ASI_CRM_Customer__c,requestHeader.ASI_CRM_Customer__c);

            ASI_CRM_VN_TestClassHelper.createCustomSettings();
            ASI_CRM_VN_TestClassHelper.createRunningNumber();
            ASI_CRM_VN_TestClassHelper.createExchangeRate();

            ASI_GiftBox_Inventory_Master__c inventoryItem = ASI_CRM_VN_TestClassHelper.createInventoryItem();
            insert inventoryItem;

            ASI_GiftBox_Inventory_Detail__c inventoryItemDetail = ASI_CRM_VN_TestClassHelper.createInventoryItemDetail(inventoryItem.Id);
            insert inventoryItemDetail;

            ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
            insert subBrand;

            ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
            insert sku;

            ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
            insert servicePack;

            ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
            onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
            insert onTradeCustomer;

            ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
            contract.ASI_CRM_Area_Code__c       = '123456';
            contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
            contract.ASI_CRM_Contract_Status__c = 'Approved';
            insert contract;

           
            requestItem.RecordTypeID = Schema.SObjectType.ASI_GiftBox_Request_Item__c.getRecordTypeInfosByName().get('ASI VN POSM Request Item').getRecordTypeId();
            requestItem.ASI_GiftBox_Request_Item__c=item.Id;
            requestItem.ASI_GiftBox_Request_Id__c=requestHeader.Id;
            requestItem.ASI_GiftBox_Request_Item_Warehouse__c='W';
            requestItem.ASI_GiftBox_Request_Quantity__c = 1;
            requestItem.ASI_GiftBox_Request_Item_Unit_Price__c =1;
            //requestItem.ASI_GiftBox_Unit_Price__c = 1;
            insert requestItem;         
           
            ASI_GiftBox_Request_Item__c itemRecord = new ASI_GiftBox_Request_Item__c();
            itemRecord = [SELECT Id,
                               RecordTypeID,
                               ASI_GiftBox_Request_Item__c,
                               ASI_GiftBox_Request_Id__c,
                               ASI_GiftBox_Request_Quantity__c,
                               ASI_CRM_Quantity_Adjusted__c,
                               ASI_CRM_Item_Delivered__c                              
                        FROM ASI_GiftBox_Request_Item__c 
                        WHERE Id =: requestItem.Id];                         
            System.assertEquals(1,itemRecord.ASI_CRM_Quantity_Adjusted__c);
                                  
            requestItem=new ASI_GiftBox_Request_Item__c();
            requestItem.ASI_GiftBox_Request_Item__c=item.Id;
            requestItem.RecordTypeID = Schema.SObjectType.ASI_GiftBox_Request_Item__c.getRecordTypeInfosByName().get('ASI VN POSM Request Item').getRecordTypeId();
            requestItem.ASI_GiftBox_Request_Id__c=requestHeader.Id;
            requestItem.ASI_GiftBox_Request_Item_Warehouse__c='W';
            requestItem.ASI_GiftBox_Request_Quantity__c = 2;
            insert requestItem; 
            
            ASI_GiftBox_Request_Item__c itemID = new ASI_GiftBox_Request_Item__c();
            itemID = [SELECT Id,
                               RecordTypeID,
                               ASI_GiftBox_Request_Item__c,
                               ASI_GiftBox_Request_Id__c,
                               ASI_GiftBox_Request_Quantity__c,
                               ASI_CRM_Quantity_Adjusted__c,
                               ASI_CRM_Item_Delivered__c
                        FROM ASI_GiftBox_Request_Item__c 
                        WHERE Id =: requestItem.Id];  
            System.assertEquals(2,itemID.ASI_CRM_Quantity_Adjusted__c);
              
        } 
    }