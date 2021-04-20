/*Created by Twinkle Li @introv 04/21/2015
*
* Testclass for ASI_CRM_TW_MerchanTaskByPromotion_Ctrl
*/

@isTest
public class ASI_CRM_TW_MerchanTaskByPromotion_Test {
    public static testMethod void ASI_CRM_TW_MerchanTaskByPromotion_Test() {
        user u = [SELECT id FROM user WHERE profile.Name = 'System Administrator' and isactive = true LIMIT 1];    
        
        Id recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel');    
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='Channel', RecordTypeid = recordTypeid, ASI_CRM_CN_Channel_Code__c ='channel1');                       
        insert channel;
        
        recordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet');    
        Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id , ASI_TH_CRM_Region__c ='North');                       
        insert outlet;
            
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
        ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Test Promotion', ASI_HK_CRM_Promotion_Start_Date__c = date.valueOf('2015-05-01'), 
        RecordTypeid = recordTypeid, ASI_HK_CRM_Promotion_End_Date__c = date.valueOf('2015-05-31'), ASI_CRM_Channel__c = channel.id);
        insert promotion;
        
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
        ASI_CRM_Promotion_Status__c promotionStatus = new ASI_CRM_Promotion_Status__c(
            ASI_CRM_Account__c=outlet.id,ASI_CRM_Promotion__c=promotion.id,ASI_CRM_Confirmed__c=true,
            recordTypeid=recordTypeid);
        insert promotionStatus;
            
        recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Merchandiser_Task__cASI_CRM_TW_Merchandiser_Task');
        ASI_CRM_Merchandiser_Task__c MerchandiserTask = new ASI_CRM_Merchandiser_Task__c(ASI_CRM_Photo_Date__c=Date.newInstance(2015,5,21),ASI_CRM_Promotion_Status__c=promotionStatus.id,ASI_CRM_Task__c='Display Setup',ASI_CRM_Done__c=true);
        insert MerchandiserTask;
        
        List<Attachment> listAttch = new List<Attachment>();
        listAttch.add(new Attachment(ParentId = MerchandiserTask.id, Name = 'General_0001', Body = EncodingUtil.base64Decode('Test Data')));
        listAttch.add(new Attachment(ParentId = MerchandiserTask.id, Name = 'General_0002', Body = EncodingUtil.base64Decode('Test Data')));
        insert listAttch;
                 
        System.runAs(u) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(promotion);
            ApexPages.currentPage().getParameters().put('id', promotion.id);
            ASI_CRM_TW_MerchanTaskByPromotion_Ctrl controller = new ASI_CRM_TW_MerchanTaskByPromotion_Ctrl(stdController);
            
            List<String> listDone = new List<String>();
            listDone.add('true');
            List<String> listChannel = new List<String>();
            listChannel.add('channel');
            List<String> listRegion = new List<String>();
            listRegion.add('North');
            List<String> listType = new List<String>();
            listType.add('Display Setup');
            
            controller.getChannelList();
            controller.getRegionList();
            controller.getDoneList();
            controller.getTaskList();
            
            controller.searchDone = listDone;
            controller.searchTaskType = listType;
            controller.searchChannel = listChannel;
            controller.searchRegion = listRegion;
            
            controller.getSearchDoneSOQL(listDone);
            controller.getSeacrhTaskTypeSOQL(listType);
            controller.getSeacrhChannelTypeSOQL(listChannel);
            controller.getSearchRegionSOQL(listRegion);
            controller.ViewSearch();
            
            
            controller.searchCurrentPage();
            controller.pageRedirect();
            controller.Beginning();
            controller.Previous();
            controller.Next();
            controller.End();
        }
    }
}