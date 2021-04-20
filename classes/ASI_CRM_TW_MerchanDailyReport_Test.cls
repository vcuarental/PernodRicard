/*Created by Stella Li @introv 05/06/2015
* Updated by Twinkle Li @introv 19/06/2015
*
* Testclass for:
* ASI_CRM_TW_MerchanDailyReport_Ctrl 
*/

@isTest
public class ASI_CRM_TW_MerchanDailyReport_Test {
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
    
    
  public static testMethod void ASI_CRM_TW_MerchanDailyReportCtrl_Test () {
    user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
             from user where profile.Name like '%System Administrator%' and isactive = true and userroleid <> null limit 1];    
             
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
            ASI_HK_CRM_Cancellation_Reason__c='Test', RecordTypeid = recordTypeid, ASI_TH_CRM_Visit_Date_Time_To__c=null
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
        ASI_CRM_Merchandiser_Task__c MerchandiserTask = new ASI_CRM_Merchandiser_Task__c(ASI_CRM_Promotion_Status__c=promotionStatus.id,ASI_CRM_Visitation_Plan_Detail__c=vpDetail.id,ASI_CRM_Photo_Date__c=null);
        ASI_CRM_Merchandiser_Task__c MerchandiserTask1 = new ASI_CRM_Merchandiser_Task__c(ASI_CRM_Photo_Date__c=Date.newInstance(2015,5,21),ASI_CRM_Promotion_Status__c=promotionStatus.id,ASI_CRM_Visitation_Plan_Detail__c=vpDetail.id);
        insert MerchandiserTask;
        insert MerchandiserTask1;
              
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(outlet);
        ApexPages.currentPage().getParameters().put('vpid', vpDetail.id);    
        ApexPages.currentPage().getParameters().put('accid', outlet.id);
        ASI_CRM_TW_MerchanDailyReport_Ctrl controller = new ASI_CRM_TW_MerchanDailyReport_Ctrl(stdController);   
        controller.strRemarks = 'Testing Remarks';
        controller.strCxlReason= 'Testing Reason';
        controller.VisitDateF = datetime.valueOf('2015-05-27 12:00:00');
        controller.VisitDateT = datetime.valueOf('2015-05-27 13:00:00');
        
        String a = ASI_CRM_TW_MerchanDailyReport_Ctrl.fileSeq(0);
        String b = ASI_CRM_TW_MerchanDailyReport_Ctrl.fileSeq(00);
        String c = ASI_CRM_TW_MerchanDailyReport_Ctrl.fileSeq(000);
        String d = ASI_CRM_TW_MerchanDailyReport_Ctrl.fileSeq(0000);
        
        controller.quickSave();
        controller.SaveVPD();
        /*
        String attachmentBody = 'Test Photo Upload';
        String attachmentName = 'Test Photo';
        ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(vpDetail.id), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),attachmentName, '1',null);
        ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(vpDetail.id), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),attachmentName, '2',null);
        ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(vpDetail.id), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),attachmentName, '3',null);*/
    
   }
      System.runAs(u) {
        String recordTypeid = checkRecordType('ASI_CRM_CN_Channel__c','ASI_CRM_TW_Channel');
        ASI_CRM_CN_Channel__c channel1 = new ASI_CRM_CN_Channel__c(Name = 'HBR1', ASI_CRM_CN_Channel_Code__c = 'HBR1', RecordTypeid = recordTypeid);
        insert channel1 ; 
        
        recordTypeid = checkRecordType('ASI_MFM_Sub_Channel__c','ASI_CRM_TW_SubChannel');
        ASI_MFM_Sub_Channel__c subChannel1 = new ASI_MFM_Sub_Channel__c(Name = 'Sub-Channel1', ASI_CRM_CN_Channel__c = channel1.id, RecordTypeid = recordTypeid);
        insert subChannel1;         
    
        recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
        ASI_TH_CRM_OutletType__c outletType1 = new ASI_TH_CRM_OutletType__c(Name = 'LS1 (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS1', ASI_CRM_Sub_Channel__c = subChannel1.id, RecordTypeid = recordTypeid);
        insert outletType1;
    
        List<Account> insertAccountList1 = new List<Account>();
        List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList1 = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
        Account outlet1 = new Account(Name='Test Outlet1', RecordTypeid = recordTypeid, ownerid = u.id);
        insertAccountList1.add(outlet1);                        
        insert insertAccountList1;
        
        ASI_TH_CRM_OutletImage__c outletImage1 = new ASI_TH_CRM_OutletImage__c(Name = 'Iconic1', ASI_TH_CRM_Code__c = 'TW_ICN1');
        insert outletImage1;
        
        recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
        ASI_CRM_AccountsAdditionalField__c accountAdditionalField1 = new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Test Outlet1', ASI_CRM_Account__c = outlet1.id, ASI_TH_CRM_OutletType__c = outletType1.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
            ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12',
            ASI_TH_CRM_OutletImage__c = outletImage1.id, ASI_CRM_Channel__c = channel1.id
        );
        insertAccountAdditionalFieldList1.add(accountAdditionalField1);
        
        insert insertAccountAdditionalFieldList1;
    
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_TW_Merchandiser_Visitation_Plan');
        ASI_HK_CRM_Visitation_Plan__c visitationPlan1 = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan1', RecordTypeid = recordTypeid,
            ASI_HK_CRM_Year__c = '2015', ASI_HK_CRM_Month__c = 'August');
            
        insert visitationPlan1;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail');
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail1 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
            ASI_HK_CRM_Account__c = outlet1.id, ASI_HK_CRM_Visitation_Plan__c = visitationPlan1.id,
            RecordTypeid = recordTypeid,ASI_HK_CRM_Visit_Date__c=Date.newInstance(2015,8,21)
        );
        insert vpDetail1;
       
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
        ASI_HK_CRM_Promotion__c promotion1 = new ASI_HK_CRM_Promotion__c(Name = 'Test Promotion1', ASI_HK_CRM_Promotion_Start_Date__c = date.valueOf('2015-08-01'), 
            RecordTypeid = recordTypeid, ASI_HK_CRM_Promotion_End_Date__c = date.valueOf('2015-08-31'));
        insert promotion1;

        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
        ASI_CRM_Promotion_Status__c promotionStatus1 = new ASI_CRM_Promotion_Status__c(ASI_CRM_Account__c=outlet1.id,ASI_CRM_Promotion__c=promotion1.id,ASI_CRM_Confirmed__c=true,recordTypeid=recordTypeid);
        insert promotionStatus1;
            
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Merchandiser_Task__cASI_CRM_TW_Merchandiser_Task');
        ASI_CRM_Merchandiser_Task__c MerchandiserTask1 = new ASI_CRM_Merchandiser_Task__c(ASI_CRM_Promotion_Status__c=promotionStatus1.id,ASI_CRM_Visitation_Plan_Detail__c=vpDetail1.id);
        insert MerchandiserTask1;
              
        ApexPages.StandardController stdController1 = new ApexPages.StandardController(outlet1);
        ApexPages.currentPage().getParameters().put('vpid', vpDetail1.id);    
        ApexPages.currentPage().getParameters().put('accid', outlet1.id);
        ASI_CRM_TW_MerchanDailyReport_Ctrl controller1 = new ASI_CRM_TW_MerchanDailyReport_Ctrl(stdController1);   
        controller1.strRemarks = 'Testing Remarks1';
        controller1.strFeedback= 'Testing Feedback1';
        controller1.VisitDateF = datetime.valueOf('2015-05-30 12:00:00');
        controller1.VisitDateT = datetime.valueOf('2015-05-30 13:00:00');
        
        controller1.quickSave();
        controller1.SaveVPD();
            
        Attachment att = new Attachment();
        att.ParentId = MerchandiserTask1.id;
        att.Name = 'General_0001';
        att.Body = EncodingUtil.base64Decode('Test Data');
        
        insert att;
        String attachmentBody = 'Test Photo Upload';
        String attachmentName = 'Test Photo';
        string attachmentId='';
        String ParentId=MerchandiserTask1.id;
        ASI_CRM_TW_MerchanDailyReport_Ctrl.insertAttachment(String.valueof(ParentId), EncodingUtil.base64Encode(Blob.valueof(attachmentBody)),att.Name, '1',att.id);
            
    
   }
 }
}