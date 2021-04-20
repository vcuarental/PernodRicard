/*Created by Stella Li @introv 05/19/2015
* Updated by Twinkle Li @introv 19/06/2015
*
* Testclass for:
* ASI_CRM_TW_MerchanTaskReportPDF_Ctrl
*/
@isTest
public class ASI_CRM_TW_MerchanTaskReportPDF_Test {
    static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
        for (recordtype pl : sobjectlist ){
            if (pl.developername == rt_name)
            RT_id = pl.id;
        }
        system.debug('RT_id: ' + RT_id);
        return RT_id;           
    }
    public static testMethod void ASI_CRM_TW_MerchanTaskReportPDF_Test() {
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
                 from user where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1];    
             
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_CRM_CN_Channel__c','ASI_CRM_TW_Channel');
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name = 'HBR', ASI_CRM_CN_Channel_Code__c = 'HBR', RecordTypeid = recordTypeid);
            insert channel ; 
            
            recordTypeid = checkRecordType('ASI_MFM_Sub_Channel__c','ASI_CRM_TW_SubChannel');
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(Name = 'Sub-Channel', ASI_CRM_CN_Channel__c = channel.id, RecordTypeid = recordTypeid);
            insert subChannel;         
        
            recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', ASI_CRM_Sub_Channel__c = subChannel.id, RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);                        
            insert insertAccountList;
            
            ASI_TH_CRM_OutletImage__c outletImage = new ASI_TH_CRM_OutletImage__c(Name = 'Iconic', ASI_TH_CRM_Code__c = 'TW_ICN');
            insert outletImage;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12',
                ASI_TH_CRM_OutletImage__c = outletImage.id, ASI_CRM_Channel__c = channel.id
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
        
            recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_TW_Merchandiser_Visitation_Plan');
            ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = recordTypeid,
                ASI_HK_CRM_Year__c = '2015', ASI_HK_CRM_Month__c = 'May');
                
            insert visitationPlan;
            
            recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail');
            ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_HK_CRM_Account__c = outlet.id, ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_HK_CRM_Cancellation_Reason__c='Test', RecordTypeid = recordTypeid,ASI_TH_CRM_Visit_Date_Time_To__c=null
            );
            insert vpDetail;
           
            recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
            ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Test Promotion', ASI_HK_CRM_Promotion_Start_Date__c = date.valueOf('2015-05-01'), 
            RecordTypeid = recordTypeid, ASI_HK_CRM_Promotion_End_Date__c = date.valueOf('2015-05-31'));
            insert promotion;
    
            recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
            ASI_CRM_Promotion_Status__c promotionStatus = new ASI_CRM_Promotion_Status__c(ASI_CRM_Account__c=outlet.id,ASI_CRM_Promotion__c=promotion.id,ASI_CRM_Confirmed__c=true,recordTypeid=recordTypeid);
            insert promotionStatus;
                
            recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Merchandiser_Task__cASI_CRM_TW_Merchandiser_Task');
            ASI_CRM_Merchandiser_Task__c MerchandiserTask = new ASI_CRM_Merchandiser_Task__c(ASI_CRM_Photo_Date__c=Date.newInstance(2015,5,21),ASI_CRM_Promotion_Status__c=promotionStatus.id,ASI_CRM_Visitation_Plan_Detail__c=vpDetail.id,
            ASI_CRM_Remarks__c='test');
            insert MerchandiserTask;
            
            //1 attachment
            Attachment att = new Attachment();
            att.ParentId = MerchandiserTask.id;
            att.Name = 'General_0001';
            att.Body = EncodingUtil.base64Decode('Test Data');
            insert att;
            String attachmentBody = 'Test Photo Upload';
            String attachmentName = 'Test Photo';
            string attachmentId='';
            String ParentId=MerchandiserTask.id;
            ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(ParentId), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),att.Name, '1',att.id);   
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(MerchandiserTask);
            ApexPages.currentPage().getParameters().put('id', MerchandiserTask.id);
            ASI_CRM_TW_MerchanTaskReportPDF_Ctrl controller = new ASI_CRM_TW_MerchanTaskReportPDF_Ctrl(stdController);
            
            //2 attachments
            att = new Attachment();
            att.ParentId = MerchandiserTask.id;
            att.Name = 'General_0002';
            att.Body = EncodingUtil.base64Decode('Test Data');
            insert att;
            attachmentBody = 'Test Photo Upload';
            attachmentName = 'Test Photo';
            attachmentId='';
            ParentId=MerchandiserTask.id;
            ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(ParentId), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),att.Name, '1',att.id);   
            controller = new ASI_CRM_TW_MerchanTaskReportPDF_Ctrl(stdController);
            
            //3 attachments
            att = new Attachment();
            att.ParentId = MerchandiserTask.id;
            att.Name = 'General_0003';
            att.Body = EncodingUtil.base64Decode('Test Data');
            insert att;
            attachmentBody = 'Test Photo Upload';
            attachmentName = 'Test Photo';
            attachmentId='';
            ParentId=MerchandiserTask.id;
            ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(ParentId), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),att.Name, '1',att.id);   
            controller = new ASI_CRM_TW_MerchanTaskReportPDF_Ctrl(stdController);
            
            //4 attachments
            att = new Attachment();
            att.ParentId = MerchandiserTask.id;
            att.Name = 'General_0004';
            att.Body = EncodingUtil.base64Decode('Test Data');
            insert att;
            attachmentBody = 'Test Photo Upload';
            attachmentName = 'Test Photo';
            attachmentId='';
            ParentId=MerchandiserTask.id;
            ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(ParentId), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),att.Name, '1',att.id);   
            controller = new ASI_CRM_TW_MerchanTaskReportPDF_Ctrl(stdController);
        }
    }
}