@IsTest
public class ASI_MFM_CN_POSMReturnRequest_Upload_Test {
	private static Final String POSMSKU_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    private static Final String ORDER_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM');
    private static Final String ORDER_RO_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_RO');
    private static Final String BATCH_LOG_ID = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');  
    private static Final String ORDER_ITEM_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item');
    
	public class TestData{

        public List<ASI_MFM_Item_Group__c> itemgroupList;
        public List<ASI_MFM_SKU_Code__c> skuList; 
        public List<ASI_FOC_Warehouse__c> warehouseList; 
        
        public TestData(){
            initFirst();
		}
		
        public void initFirst(){

        	itemgroupList = new List<ASI_MFM_Item_Group__c>();
            String strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
			itemgroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId=strRTId,name='test',ASI_MFM_CN_OneTimeItem__c='Yes',ASI_CRM_CN_Chinese_Name__c='test2', ASI_MFM_Item_Group_Code__c='11',ASI_MFM_Utilization_Status__c='Active',ASI_CRM_CN_Hidden__c=FALSE));
            itemgroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId=strRTId,name='test',ASI_MFM_CN_OneTimeItem__c='Yes',ASI_CRM_CN_Eng_Name__c='test2', ASI_MFM_Item_Group_Code__c='11',ASI_MFM_Utilization_Status__c='Active',ASI_CRM_CN_Hidden__c=FALSE));
            insert itemgroupList;

        	strRTId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
            warehouseList = new List<ASI_FOC_Warehouse__c>();
            warehouseList.add(new ASI_FOC_Warehouse__c(RecordTypeId=strRTId,Name='1',ASI_FOC_Warehouse_Code__c='398PSHRT',ASI_FOC_Warehouse_Type__c='Region Warehouse',ASI_FOC_Warehouse_Description__c='desc1'
                                                       ,ASI_FOC_Warehouse_Address__c='11111',ASI_FOC_Contact__c='111', ASI_FOC_SIR_Email_Address_1__c ='aaa@aa.com'
                                                       ,ASI_MFM_Is_Active__c = true));

            warehouseList.add(new ASI_FOC_Warehouse__c(RecordTypeId=strRTId,Name='2',ASI_FOC_Warehouse_Code__c='398PSHRT',ASI_FOC_Warehouse_Type__c='Region Warehouse',ASI_FOC_Warehouse_Description__c='desc2'
                                                       ,ASI_FOC_Warehouse_Address__c='22222',ASI_FOC_Contact__c='222', ASI_FOC_SIR_Email_Address_1__c ='aaa@cv.com'
                                                       ,ASI_MFM_Is_Active__c = true));
            insert warehouseList;
            
            strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
            skuList = new List<ASI_MFM_SKU_Code__c>();
            skuList.add(new ASI_MFM_SKU_Code__c(RecordTypeId=strRTId,ASI_HK_CRM_Available_Quantity__c=null,ASI_MFM_Item_Group__c=itemgroupList[0].id,Name='1',ASI_MFM_SKU_Description__c='desc',ASI_MFM_SKU_Code__c='X4CH3311801',ASI_MFM_Minimum_Packing_Qty__c=1,ASI_MFM_Minimum_Box_Qty__c=2));
            skuList.add(new ASI_MFM_SKU_Code__c(RecordTypeId=strRTId,ASI_HK_CRM_Available_Quantity__c=null,ASI_MFM_Item_Group__c=itemgroupList[1].id,Name='2',ASI_MFM_SKU_Description__c='desc',ASI_MFM_SKU_Code__c='X4CH3311802',ASI_MFM_Minimum_Packing_Qty__c=1,ASI_MFM_Minimum_Box_Qty__c=2));
            insert skuList;
        }
    }    
    static testMethod void testCatalogCtrlSecond() {
        list<User> users = new list<User>();
        User User1 = new User(managerid = UserInfo.getUserId(),lastname = 'Koh',firstname = 'Lawrence', ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8',languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        User User2 = new User(managerid = UserInfo.getUserId(),lastname = 'Koh',firstname = 'Lawrence', ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
        users.add(user2);
        users.add(user1);
        try{insert users;}catch(Exception e){}
        
        user1 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user1.id 
                            LIMIT 1];
        user2 = [SELECT Id, Name, ManagerId, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                            FROM User
                            WHERE id =: user2.id 
                            LIMIT 1];
        
        
        System.runAs(user1) {         
            String key = '123456';
            List<ASI_MFM_POSM_Return_Request__c> reqList = new List<ASI_MFM_POSM_Return_Request__c>();
            ASI_MFM_POSM_Return_Request__c prrq = new ASI_MFM_POSM_Return_Request__c(
                            RecordTypeId = ORDER_ID, ASI_MFM_Batch_Import_KEY__c = key ,ASI_MFM_Request_Status__c = 'In Progress',ASI_MFM_Return_Request_Date__c = Date.today()
                        );
            reqList.add(prrq);
            try{insert reqList;}catch(Exception e){System.debug(LoggingLevel.INFO, '*** e.getStackTraceString(): ' + e.getStackTraceString());}

            List<ASI_MFM_POSM_Return_Request_Item__c> reqItemList = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            ASI_MFM_POSM_Return_Request_Item__c item = new ASI_MFM_POSM_Return_Request_Item__c(
                            RecordTypeId = ORDER_ITEM_ID, ASI_MFM_Batch_Import_KEY__c = key , ASI_MFM_Request_Order__c = prrq.Id,ASI_MFM_Approval_Status__c='Open',ASI_MFM_Item_Owner__c = user1.Id
                        );
            reqItemList.add(item);
            try{insert reqItemList;}catch(Exception e){System.debug(LoggingLevel.INFO, '*** e.getStackTraceString(): ' + e.getStackTraceString());}
            TestData testdata = new TestData();
            testdata.initFirst();
            
            Test.startTest();
            
            Boolean showBatch = false;
            String submitType = '';
            ASI_MFM_CN_POSMReturnRequest_Upload_EXT ctrl2 = new ASI_MFM_CN_POSMReturnRequest_Upload_EXT(new ASI_MFM_CN_POSMCatalog_CTRL());
            
            String jsonStr = '{"index":1,"show":true,"errorMap":{},"selected":"","loading":true,"status":"loading","returnRequestDate":"2020-07-22","returnRequestTime":"9:00-12:00","formAddress":"XXX市YYY区ZZZ路HHH号","toAddress":"XXX市YYY区ZZZ路HHH号","recipient":"LI XIA","towarehouse":"398PSHRT","recipientContact":"1388888888","items":[{"sku":"X4CH3311801","qty":"10","owner":"Amy WANG","vas":"垃圾清理","success":false},{"sku":"X4CH3311802","qty":"20","owner":"Amy WANG","vas":"垃圾清理","success":false},{"sku":"X4CH3311803","qty":"30","owner":"Amy WANG","vas":"垃圾清理","success":false},{"sku":"X4CH3311804","qty":"40","owner":"Amy WANG","vas":"垃圾清理","success":false}],"orgData":{"index":1,"show":true,"errorMap":{},"selected":"","loading":true,"status":"loading","returnRequestDate":"2020-07-22","returnRequestTime":"9:00-12:00","formAddress":"XXX市YYY区ZZZ路HHH号","toAddress":"XXX市YYY区ZZZ路HHH号","recipient":"LI XIA","towarehouse":"398PSHRT","recipientContact":"1388888888","items":[{"sku":"X4CH3311801","qty":"10","owner":"Amy WANG","vas":"垃圾清理","success":false},{"sku":"X4CH3311802","qty":"20","owner":"Amy WANG","vas":"垃圾清理","success":false},{"sku":"X4CH3311803","qty":"30","owner":"Amy WANG","vas":"垃圾清理","success":false},{"sku":"X4CH3311804","qty":"40","owner":"Amy WANG","vas":"垃圾清理","success":false}]}}';
            ASI_MFM_CN_POSMReturnRequest_Upload_EXT.checkUploadData(jsonStr);
            jsonStr = '{"index":1,"show":true,"errorMap":{},"selected":"selected","loading":true,"status":"loading","returnRequestDate":"2020-07-22","returnRequestTime":"9:00-12:00","formAddress":"XXX市YYY区ZZZ路HHH号","toAddress":"XXX市YYY区ZZZ路HHH号","recipient":"LI XIA","towarehouse":"398PSHRT","recipientContact":"13888888888","items":[{"sku":"芝华士骰盅-传统业务部NCO-X4CH3311801","qty":"10","owner":"Koh Lawrence","vas":"垃圾清理","success":true,"skuId":"'+testdata.skuList[0].ID+'","ownerid":"'+user1.ID+'"},{"sku":"芝华士骰盅-传统业务部NCO/null - X4CH3311802","qty":"20","owner":"WANG Amy","vas":"垃圾清理","success":true,"skuId":"'+testdata.skuList[0].ID+'","ownerid":"'+user1.ID+'"}],"towarehouseid":"'+testdata.warehouseList[0].ID+'","hasError":false}';
            ASI_MFM_CN_POSMReturnRequest_Upload_EXT.submitOrder(jsonStr,key,showBatch,submitType);           
            ASI_MFM_CN_POSMReturnRequest_Upload_EXT.finishProcess(key,10,10,'10');
            Test.stopTest();
        }
    }
 
}