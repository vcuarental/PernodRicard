@isTest(seeAllData=true)
    private class ASI_GiftBox_Test {    
        static ASI_MFM_Brand__c brand=new ASI_MFM_Brand__c();
        static ASI_GiftBox_Inventory_Master__c item=new ASI_GiftBox_Inventory_Master__c();
        static ASI_GiftBox_Order_Header__c header = new ASI_GiftBox_Order_Header__c();
        static ASI_GiftBox_Order_Item__c detail= new ASI_GiftBox_Order_Item__c();
        static ASI_GiftBox_Good_Receipt__c receipt=new ASI_GiftBox_Good_Receipt__c();
        static ASI_GiftBox_Customer__c customer = new ASI_GiftBox_Customer__c();
        static ASI_GiftBox_Request_Header__c requestHeader=new ASI_GiftBox_Request_Header__c();
        static ASI_GiftBox_Request_Item__c requestItem=new ASI_GiftBox_Request_Item__c();
        static ASI_GiftBox_Transfer_Log__c transferLog=new ASI_GiftBox_Transfer_Log__c();
        static ASI_GiftBox_Transfer_Log__c transferLog2=new ASI_GiftBox_Transfer_Log__c();
    
        static void insertBrand(){
            //Obsolete, did not use Brand field at Inventory Master object
            brand.Name='test_brand1';
            brand.ASI_MFM_Brand_Code__c ='Test1';
            brand.ASI_MFM_Brand_Description__c='test brand 1';
            brand.ASI_MFM_Brand_External_ID__c='testbrand1';       
            insert brand;
        }
        
        static void insertCustomer(){
            customer.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Customer__cASI_GiftBox_VN_Customer');
            customer.Name='test customer';
            insert customer;
        }
        
        static void insertItem(){    
            item.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Inventory_Master__cASI_GiftBox_VN_GiftBox_Master');
            item.Name='test_item1';
            item.ASI_GiftBox_Item_Brand__c=brand.Id;         
            insert item;
        }
        
        static void insertOrder(){         
            header.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Order_Header__cASI_GiftBox_VN_Order');
            header.Name='Test_Order_Header1';
            header.ASI_GiftBox_Order_Supplier__c='Vinagift';
            header.ASI_GiftBox_Order_MCF__c='A'; 
            insert header;
            
            detail.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Order_Item__cASI_GiftBox_VN_Order_Item');
            detail.ASI_GiftBox_Order_Item_Id__c=item.Id;
            detail.ASI_GiftBox_Order_Id__c=header.Id;
            detail.ASI_GiftBox_Order_Item_Order_Quantity__c=10;           
            insert detail;
        }
        
        static void insertReceipt(){   
            receipt.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Good_Receipt__cASI_GiftBox_VN_Good_Receipt');
            receipt.ASI_GiftBox_Receipt_Charge_Out_Price__c=100.3;
            receipt.ASI_GiftBox_Order_Item_Id__c=detail.Id;
            receipt.ASI_GiftBox_Receipt_Quantity__c=2;
            receipt.ASI_GiftBox_Receipt_Receive_Date__c=date.today();
            receipt.ASI_GiftBox_Receipt_Warehouse__c='W';        
            insert receipt;
            
            ASI_GiftBox_Order_Item__c detail2= new ASI_GiftBox_Order_Item__c();
            detail2.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Order_Item__cASI_GiftBox_VN_Order_Item');
            detail2.ASI_GiftBox_Order_Item_Id__c=item.Id;
            detail2.ASI_GiftBox_Order_Id__c=header.Id;
            detail2.ASI_GiftBox_Order_Item_Order_Quantity__c=10;           
            insert detail2;
            
            receipt=new ASI_GiftBox_Good_Receipt__c();
            receipt.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Good_Receipt__cASI_GiftBox_VN_Good_Receipt');
            receipt.ASI_GiftBox_Receipt_Charge_Out_Price__c=100.3;
            receipt.ASI_GiftBox_Order_Item_Id__c=detail.Id;
            receipt.ASI_GiftBox_Receipt_Quantity__c=2;
            receipt.ASI_GiftBox_Receipt_Receive_Date__c=date.today();
            receipt.ASI_GiftBox_Receipt_Warehouse__c='W';        
            insert receipt;
            
            receipt.ASI_GiftBox_Receipt_Quantity__c=5;
            receipt.ASI_GiftBox_Receipt_Warehouse__c='A';
            
            update receipt;
        }
        
        static void insertTransferLog(){
            List<ASI_GiftBox_Transfer_Log__c> listTransferLog = new List<ASI_GiftBox_Transfer_Log__c>();
            
            //Test normal condition
            transferLog.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Transfer_Log__cASI_GiftBox_VN_Transfer_Log');
            transferLog.ASI_GiftBox_Master__c = item.id;
            transferLog.ASI_GiftBox_Quantity__c = 1;
            transferLog.ASI_GiftBox_Transfer_From__c = 'W';
            transferLog.ASI_GiftBox_Transfer_To__c = 'A';
            listTransferLog.add(transferLog);
            
            //Test exception
            transferLog2.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Transfer_Log__cASI_GiftBox_VN_Transfer_Log');
            transferLog2.ASI_GiftBox_Master__c = item.id;
            transferLog2.ASI_GiftBox_Quantity__c = 1000;
            transferLog2.ASI_GiftBox_Transfer_From__c = 'W';
            transferLog2.ASI_GiftBox_Transfer_To__c = 'A';
            listTransferLog.add(transferLog2);
            
            try {
                insert listTransferLog;
            }
            catch (Exception e){
            }
        }
        
        static void insertShare(){            
            ASI_GiftBox_Notification_User__c emailRecep=new ASI_GiftBox_Notification_User__c();
            emailRecep.HR_User__c=UserInfo.getUserId();
            emailRecep.Finance_User__c=UserInfo.getUserId();
            emailRecep.MKT_User__c=UserInfo.getUserId();
             
            insert emailRecep;
             
            UserRole role=[select DeveloperName from UserRole where Id = :UserInfo.getUserRoleId() limit 1][0];
            ASI_GiftBox_Notification_Mapping__c mapping =new ASI_GiftBox_Notification_Mapping__c();
            mapping.ASI_GiftBox_User_Role_Name__c=role.DeveloperName;
            mapping.Notification_Id__c=emailRecep.Id;
            mapping.ASI_GiftBox_Sales_Representative__c = UserInfo.getUserId();
             
            insert mapping ;
        }
        
        static void insertRequest(){
            insertShare();
            
            requestHeader.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__cASI_GiftBox_VN_Request');
            requestHeader.ASI_GiftBox_Request_Customer__c=customer.Id;     
            requestHeader.ASI_GiftBox_Status__c='Open';
           	requestHeader.ASI_GiftBox_Finance_User__c = UserInfo.getUserId();
            insert requestHeader;    
            update requestHeader;  
            
            ApexPages.standardController controller = new ApexPages.standardController(requestHeader);
            ASI_GiftBox_RequestHeaderController extension = new ASI_GiftBox_RequestHeaderController (controller); 
            extension.runSearch();   
            extension.getEditForSales();
            extension.getReadForSales ();
            extension.getGiftBoxList();         
            
            requestItem.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__cASI_VN_GiftBox_Request_Item');
            requestItem.ASI_GiftBox_Request_Item__c=item.Id;
            requestItem.ASI_GiftBox_Request_Id__c=requestHeader.Id;
            requestItem.ASI_GiftBox_Request_Item_Warehouse__c='W';
            requestItem.ASI_GiftBox_Request_Quantity__c=1;
            insert requestItem;         
            //requestItem.ASI_GiftBox_Request_Item_Warehouse__c='A';
            update requestItem;      
            
            requestItem=new ASI_GiftBox_Request_Item__c();
            requestItem.RecordTypeID = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__cASI_VN_GiftBox_Request_Item');
            requestItem.ASI_GiftBox_Request_Item__c=item.Id;
            requestItem.ASI_GiftBox_Request_Id__c=requestHeader.Id;
            requestItem.ASI_GiftBox_Request_Item_Warehouse__c='W';
            requestItem.ASI_GiftBox_Request_Quantity__c=1;
            insert requestItem; 
            
            delete requestItem;
                  
            ApexPages.standardController controller2 = new ApexPages.standardController(requestHeader);
            ASI_GiftBox_RequestStatusController extension2 = new ASI_GiftBox_RequestStatusController (controller2);
            extension2.submit(); 
            
            requestHeader.ASI_GiftBox_Status__c='Open';
            update requestHeader; 
            controller2 = new ApexPages.standardController(requestHeader);
            extension2 = new ASI_GiftBox_RequestStatusController (controller2);           
            extension2.submit();
            
            requestHeader.ASI_GiftBox_Status__c='Waiting for HR Review';
            update requestHeader;  
            controller2 = new ApexPages.standardController(requestHeader);
            extension2 = new ASI_GiftBox_RequestStatusController (controller2);          
            extension2.submit();
            
            requestHeader.ASI_GiftBox_Status__c='Waiting for Delivery';
            update requestHeader;     
            controller2 = new ApexPages.standardController(requestHeader);
            extension2 = new ASI_GiftBox_RequestStatusController (controller2);       
            extension2.submit();
            //extension2.checkAvaliable();
            extension2.calRequestedQuantity();   
            extension2.approve();
            extension2.reject();      
        }
        
        static testMethod void test_RequestController(){
           insertBrand();
           insertItem();
           insertOrder();
           insertReceipt();
           insertRequest();
           insertTransferLog();
        }
    
        static testMethod void test_ASI_GiftBox_MassUpsertController() {
            insertBrand();
            insertItem();
            insertOrder();  
            
            ApexPages.standardController controller = new ApexPages.standardController(header);
            
            // Initialize the page
            PageReference testPage = Page.ASI_GiftBox_MassUpsertOrderDetailPage;
            Map<String, String> pageParams = testPage.getParameters();
            pageParams.put('id', header.Id);
            Test.setCurrentPageReference(testPage);
            ASI_GiftBox_OrderHeaderController testCon = new ASI_GiftBox_OrderHeaderController(controller);
            testCon.mcau_initPageBlockActionButtonList();
            testCon.getComponentController();
            testCon.getComponentController(null);
            testCon.mcau_initPageBlockActionButtonList();
            testCon.mcau_triggerPageBlockAction(null,null);
            
            ASI_GiftBox_MassUpsertController massCreateCon = new ASI_GiftBox_MassUpsertController();
            
            // Assign component attributes
            massCreateCon.isFastModeBool = false;
            massCreateCon.sObjTypeStr = 'ASI_GiftBox_Order_Item__c';
            massCreateCon.displayFieldsStr = 'ASI_GiftBox_Order_Item_Brand__c&req=T&width=80px,ASI_GiftBox_Order_Item_Id__c&req=T&width=200px, ASI_GiftBox_Order_Item_Description__c&width=200px,ASI_GiftBox_Order_Item_Order_Quantity__c&req=T&width=150px,ASI_GiftBox_Order_Item_Unit_Cost__c&req=T&width=100px,ASI_GiftBox_Order_Item_Amt__c&width=100px';                            
            massCreateCon.fieldToURLParamStr = 'ASI_GiftBox_Order_Id__c=>id';
            massCreateCon.whereStatm = 'ASI_GiftBox_Order_Id__c = \'' + header.Id + '\'';
            massCreateCon.pageBlockTitleStr = '';
            massCreateCon.successLink = '/{!$CurrentPage.parameters.id}';
            massCreateCon.cancelLink = '/{!$CurrentPage.parameters.id}';
            massCreateCon.mode = 'BOTH';
            massCreateCon.isDefaultEditVal = true;
            massCreateCon.ShowAllRT = true;
            massCreateCon.isUseFirstRowForNew = true;
            massCreateCon.ComponentKey = 'massCreateAndUpdate';
            massCreateCon.PageController = testCon;
            massCreateCon.lookupToPicklist = 'ASI_GiftBox_Order_Id__c';
            
            Boolean initPageBool = massCreateCon.dummyVar;
            
             // Start testing user actions
            pageParams.put(massCreateCon.PARAM_RTID, 'ASI_GiftBox_VN_Order_Item');
            
            integer recordIndex= 0;
            for (integer i = 0; i< massCreateCon.theRecordTypeElementList.size(); i++)
            {
                system.debug('massCreateCon.theRecordTypeElementList IS ' +  massCreateCon.theRecordTypeElementList.get(i));
                if (massCreateCon.theRecordTypeElementList.get(i).myRecordList.size() > 0)
                {
                    system.debug('ID IS ' +  massCreateCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                    system.debug('#1 massCreateCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' +  massCreateCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
            
                    recordIndex = i;
                    break;
            
                }
            }
            
            if (massCreateCon.theRecordTypeElementList.size()>recordIndex && massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList.size()>0 ){
                system.debug('#2 massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0) IS ' +  massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);
                pageParams.put(massCreateCon.PARAM_TRID, massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     
                massCreateCon.enableForEdit();
                massCreateCon.cloneRow();
                massCreateCon.addNewRow();
                pageParams.put(massCreateCon.PARAM_RTID, 'ASI_GiftBox_VN_Order_Item');
                List<ASI_GiftBox_MassUpsertController.TableRow> recordList = massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList;
                pageParams.put(massCreateCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
                massCreateCon.removeNew();        
                massCreateCon.addMoreBlankRows();
                
                // Save
                massCreateCon.commitAll();
                massCreateCon.triggerPageBlockAction();
                massCreateCon.refresh();
                massCreateCon.clearAll();
            }
        }
        
    }//class