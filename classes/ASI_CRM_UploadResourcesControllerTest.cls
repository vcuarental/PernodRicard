@isTest
public class ASI_CRM_UploadResourcesControllerTest {
   
    @testSetup 
    static void setup(){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON', ASI_CRM_For_Outlet__c=true, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
        insert channel;
        List<ASI_MFM_Sub_Channel__c> tmpSubChannel = new List<ASI_MFM_Sub_Channel__c>();   
        tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id));
        tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel.Id));
        
        insert tmpSubChannel;
        ASI_CRM_AccountsAdditionalField__c  tmpCustomer = new ASI_CRM_AccountsAdditionalField__c(
            ASI_CRM_CN_Chi_Name__c = 'testing3', 
            ASI_CRM_CN_NewChannel__c=channel.Id, 
            ASI_CRM_CN_CRM_Code__c='test003', 
            ASI_CRM_CN_Eng_Name__c = 'Testing3', 
            ASI_CRM_CN_Estimated_annual_order_amount__c = 1,
            ASI_CRM_CN_Is_IHBR_Outlet__c = True, 
            ASI_CRM_CN_Commercial_Team__c='Premium', 
            ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, 
            ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', 
            ASI_CRM_Latest_Call_Plan_Date__c=system.today(), 
            RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN'));
        insert tmpCustomer;
        
        ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_SG_Item_Group')
            , Name = 'TestItemGroup'
            , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
            , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
            , ASI_CRM_CN_Not_In_Use__c = FALSE
            , ASI_CRM_CN_Gift_Set_C__c = FALSE
            , ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
            , OwnerID = UserInfo.getUserId()
        );
        insert tmpItemGroup;
        
        ASI_CRM_Price_And_Discount__c tmpPnD = new ASI_CRM_Price_And_Discount__c(
            OwnerId =  UserInfo.getUserId()
            , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_Rebate_Period')
            , ASI_CRM_Customer__c = tmpCustomer.id
            , ASI_CRM_Status__c = 'Open'
            , ASI_CRM_SG_Effective_Date__c = Date.valueOf('2020-07-01') 
        );
        insert tmpPnD;
        System.debug ('tmpPnD: '+tmpPnD);
        
    }
    
    static testMethod void testUploadContext () {
        
        
        //ASI_CRM_Upload_Resources_Setting__mdt uploadResource = [Select Id,ASI_CRM_Upload_Resources_Id__c 
        //                                                        from ASI_CRM_Upload_Resources_Setting__mdt 
        //                                                        where developername = 'ASICRMSGPortfolioBack_Rebate_Amount' limit 1];
        
        //ASI_CRM_UploadResourcesController.getUploadResourcesSetting(uploadResource.Id);
        
        
        ASI_CRM_Price_And_Discount__c recordId = [Select Id, ASI_CRM_Customer__r.Name from ASI_CRM_Price_And_Discount__c limit 1];
        ASI_CRM_UploadResourcesController.uploadContext(
            '[{"productgroup":"TestItemGroup", "rebateamount":1, "market":1}]',
            'uploadresouceid',
            (String.valueOf(recordId.Id)),
            'ASI_CRM_Price_And_Discount__c');                                       
        
        List<String> rkList = new List<String>();
        rkList.add('ASI_CRM_Customer__r.Name');
        rkList.add('Id');
        ASI_CRM_UploadResourcesController.createRecordKey(rkList, (sObject)recordId);
        
        ASI_CRM_UploadResourcesController.createUploadResultList(1,'1','1','1');
        ASI_CRM_UploadResourcesController.createBatchUploadResult(1,1,'1','1','1');
    }
    
    /*
    static testMethod void testUploadContext2 () {
    ASI_CRM_Upload_Resources_Setting__mdt uploadResource = [Select Id,ASI_CRM_Upload_Resources_Id__c from ASI_CRM_Upload_Resources_Setting__mdt where developername = 'ASICRMSGPortfolioBack_Rebate_Amount' limit 1];
    ASI_CRM_UploadResourcesController.getUploadResourcesSetting(uploadResource.Id);
        ASI_CRM_Price_And_Discount__c disc = [Select Id from ASI_CRM_Price_And_Discount__c limit 1];
        String itmGrp =[Select Id from ASI_MFM_Item_Group__c limit 1].Id;
        String rtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_SG_Rebate_Period');
        ASI_CRM_UploadResourcesController.uploadContext(
                                                '[{"RecordTypeId":"'+rtypeId+'","ASI_CRM_SG_Product_Grouping__c":"'+itmGrp+'"}]',
                                                
                                                string.valueOf(uploadResource.ASI_CRM_Upload_Resources_Id__c),
                                                string.valueOf(disc.Id),
                                                'ASI_CRM_Price_And_Discount__c');                                         
        
    }
	*/	

    /*   static testMethod void testUploadContext2 () {
        
     UploadResource__c up = [SELECT Id FROM UploadResource__c WHERE Name =: 'upp'];
        ASI_CRM_UploadResourcesController.uploadContext('[{"Body":"upgrade1","Key":"11","Reference":"uprf"},'+
                                                '{"Body":"upgrade1","Key":"22","Reference":"uprf"}]"', 
                                                'TestExcel', 
                                                up.id,
                                                'UploadResourceContext');
        
    }
    
    
    static testMethod void testCreateUploadResultList () { 
        ASI_CRM_UploadResourcesController.createUploadResultList (1, 'status', 'errorMessage', 'internalstatus');
    }
    
    static testMethod void testCreateBatchUploadResult () {
        ASI_CRM_UploadResourcesController.createBatchUploadResult (1, 2, 'status', 'errorMessage', 'internalstatus');
    }
    
    static testMethod void testCreateRecordKey () {
        sObject up = [SELECT Id, Name FROM UploadResource__c WHERE Name =: 'upp'];
        List<String> ff = new List<String>();
        ff.add('Name');
        ASI_CRM_UploadResourcesController.createRecordKey (ff, up);
    }  
    */
}