@isTest
public class ASI_CN_NPL_ChannelMgmtCompCtrlTest {
    @testSetup static void setUpData(){
      
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(Name='Test',
                                                                                   RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Group__cASI_NPL_CN_Channel_Group'));
        insert ChannelGroup;
        
        List<ASI_CRM_CN_Channel__c> channelInsertList = new List<ASI_CRM_CN_Channel__c>();
        ASI_CRM_CN_Channel__c channel1 = new ASI_CRM_CN_Channel__c(Name='Test Channel 1',
                                                                   ASI_CRM_BC_Rate__c=98,
                                                                   ASI_CRM_CN_On_Off__c='ON',
                                                                   ASI_CRM_For_Outlet__c=true,
                                                                   RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_NPL_CN_Channel'),
                                                                   ASI_CRM_For_Contract__c=TRUE, 
                                                                   ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        
        ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(Name='Test Channel 2',
                                                                   ASI_CRM_BC_Rate__c=98,
                                                                   ASI_CRM_CN_On_Off__c='ON',
                                                                   ASI_CRM_For_Outlet__c=true,
                                                                   RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_NPL_CN_Channel'),
                                                                   ASI_CRM_For_Contract__c=TRUE, 
                                                                   ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        channelInsertList.add(channel1);
        channelInsertList.add(channel2);
        insert channelInsertList;
        
        
        List<ASI_MFM_Sub_Channel__c> subChannelInsertList = new List<ASI_MFM_Sub_Channel__c>();
        ASI_MFM_Sub_Channel__c subChannel1 = new ASI_MFM_Sub_Channel__c(Name = 'Test sub channel 1', ASI_CRM_CN_Channel__c=channel1.Id,
                                                                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_NPL_CN_Sub_Channel')
                                                                        , ASI_MFM_Is_All_Region__c = true);//MT@202004
        
        ASI_MFM_Sub_Channel__c subChannel2 = new ASI_MFM_Sub_Channel__c(Name = 'Test sub channel 2', ASI_CRM_CN_Channel__c=channel2.Id,
                                                                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_NPL_CN_Sub_Channel')
                                                                        , ASI_MFM_Is_All_Region__c = true);//MT@202004
        
        subChannelInsertList.add(subChannel1);
        subChannelInsertList.add(subChannel2);
        insert subChannelInsertList;
        
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator GDT'];
        //User DMLUser = [Select Id From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];
        //DMLUser.CompanyName = 'Pernod Ricard China';
        //update DMLUser;
        
        User u2 = new User(Username = 'NPLuser@user.com', CompanyName = 'Pernod Ricard China', email = 'user@user.com', 
                           profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', 
                           LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        
        //UserRole supervisorRole = new UserRole(Name='Supervisor Role', DeveloperName = 'Supervisor_Role');
        //insert supervisorRole;
        
        //UserRole ownerRole = new UserRole(Name='Owner Role', DeveloperName = 'Owner_Role', ParentRoleID = supervisorRole.Id);
        //insert ownerRole;
        //u2.UserRoleID = ownerRole.id;
        insert u2;
        
        ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
                                                                      ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CRM_CN_NPLT1PriceFlag__c = false, ASI_CN_NPL_Date__c = date.today(), 
                                                                      RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__cASI_CN_NPL_Class_A'), 
                                                                      ASI_CN_NPL_Classification_Text__c = 'Class A', ASI_CN_NPL_Status__c = 'Final Approved', ownerID = u2.id, 
                                                                      ASI_CN_NPL_Comparable_PR_Product__c = 'ABC', ASI_CN_NPL_Profit_Loss__c ='ABC', ASI_CN_NPL_Final_Proposed_Selling_Price__c  = 1);
        insert npl;
        ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = 'TestItemGroup'
                                                                       , ASI_MFM_Item_Group_Code__c = 'aaa'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                      );
        insert tmpItemGroup;
        List<ASI_CRM_CN_Channel_Strategy__c> cslist = new List<ASI_CRM_CN_Channel_Strategy__c>();
        ASI_CRM_CN_Channel_Strategy__c cs = new ASI_CRM_CN_Channel_Strategy__c(ASI_CRM_CN_Status__c = 'Draft', 
                                                                               ASI_NPL_Vision__c = 1,
                                                                               ASI_NPL_New_Product_Launch_Request__c = npl.Id,
                                                                               ASI_NPL_Item_Group__c = tmpItemGroup.Id);
        ASI_CRM_CN_Channel_Strategy__c cs2 = new ASI_CRM_CN_Channel_Strategy__c(ASI_CRM_CN_Status__c = 'Draft', 
                                                                                ASI_NPL_Vision__c = 2,
                                                                                ASI_NPL_New_Product_Launch_Request__c = npl.Id,
                                                                                ASI_NPL_Item_Group__c = tmpItemGroup.Id);
        cslist.add(cs);
        cslist.add(cs2);
        insert cslist;
        
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> cslineItemList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        ASI_CRM_CN_Channel_Strategy_Line_Item__c cslineItem = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_NPL_Type__c = 'Channel Percentage',
                                                                                                           ASI_NPL_Version__c = 1,
                                                                                                           ASI_NPL_Percentage__c = 0, 
                                                                                                           ASI_NPL_Channel__c = channel1.Id,
                                                                                                           ASI_CRM_CN_Channel_Strategy__c = cs.Id);
        
        ASI_CRM_CN_Channel_Strategy_Line_Item__c cslineItem2 = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_NPL_Type__c = 'Sub-Channel Entitlement',
                                                                                                            ASI_NPL_Version__c = 1,
                                                                                                            ASI_NPL_Entitled__c = false, 
                                                                                                            ASI_NPL_Channel__c = channel1.Id,
                                                                                                            ASI_NPL_Sub_Channel__c = subChannel1.Id,
                                                                                                            ASI_CRM_CN_Channel_Strategy__c = cs.Id);
        
        ASI_CRM_CN_Channel_Strategy_Line_Item__c cslineItem3 = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_NPL_Type__c = 'Channel Percentage',
                                                                                                            ASI_NPL_Version__c = 2,
                                                                                                            ASI_NPL_Percentage__c = 40, 
                                                                                                            ASI_NPL_Channel__c = channel1.Id,
                                                                                                            ASI_CRM_CN_Channel_Strategy__c = cs2.Id);
        
        ASI_CRM_CN_Channel_Strategy_Line_Item__c cslineItem4 = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_NPL_Type__c = 'Sub-Channel Entitlement',
                                                                                                            ASI_NPL_Version__c = 2,
                                                                                                            ASI_NPL_Entitled__c = false, 
                                                                                                            ASI_NPL_Channel__c = channel1.Id,
                                                                                                            ASI_NPL_Sub_Channel__c = subChannel1.Id,
                                                                                                            ASI_CRM_CN_Channel_Strategy__c = cs2.Id);
        ASI_CRM_CN_Channel_Strategy_Line_Item__c cslineItem5 = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_NPL_Type__c = 'Channel Percentage',
                                                                                                            ASI_NPL_Version__c = 1,
                                                                                                            ASI_NPL_Percentage__c = 40, 
                                                                                                            ASI_NPL_Channel__c = channel1.Id,
                                                                                                            ASI_CRM_CN_Channel_Strategy__c = cs2.Id);
        
        ASI_CRM_CN_Channel_Strategy_Line_Item__c cslineItem6 = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(ASI_NPL_Type__c = 'Sub-Channel Entitlement',
                                                                                                            ASI_NPL_Version__c = 1,
                                                                                                            ASI_NPL_Entitled__c = true, 
                                                                                                            ASI_NPL_Channel__c = channel1.Id,
                                                                                                            ASI_NPL_Sub_Channel__c = subChannel1.Id,
                                                                                                            ASI_CRM_CN_Channel_Strategy__c = cs2.Id);
        
        cslineItemList.add(cslineItem);
        cslineItemList.add(cslineItem2);
        cslineItemList.add(cslineItem3);
        cslineItemList.add(cslineItem4);
        cslineItemList.add(cslineItem5);
        cslineItemList.add(cslineItem6);
        insert cslineItemList;
    }
    
    static testMethod void testChannelStrategyOne(){
        List<ASI_CRM_CN_Channel__c> testChannelList = [select Id,name, ASI_CRM_CN_Channel_Group__c, ASI_CRM_CN_Channel_Group__r.Name 
                                                       from ASI_CRM_CN_Channel__c 
                                                       order by ASI_CRM_CN_Sequence__c];
        
        List<ASI_MFM_Sub_Channel__c> testSubChannelList = [select id, name, ASI_CRM_CN_Channel__c,ASI_CRM_CN_Channel__r.Name 
                                                           , ASI_MFM_Is_All_Region__c //MT@202004
															, ASI_MFM_Region__c//MT@202004
                                                           from ASI_MFM_Sub_Channel__c
                                                           order by ASI_CRM_CN_Sequence__c];	
        
        
        ASI_CRM_CN_Channel_Strategy__c channelStrategy = [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c 
                                                          from ASI_CRM_CN_Channel_Strategy__c where ASI_NPL_Vision__c = 1 limit 1];
        
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> channelStrategyLineItem = [select id, Name, ASI_NPL_Version__c, ASI_NPL_Type__c, 
                                                                                  ASI_NPL_Percentage__c, ASI_NPL_Channel__c, ASI_NPL_Channel__r.Name, 
                                                                                  ASI_NPL_Sub_Channel__c, ASI_NPL_Entitled__c , ASI_NPL_Sub_Channel__r.Name, 
                                                                                  ASI_CRM_CN_Channel_Strategy__c, ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Vision__c 
                                                                                  , ASI_NPL_Region__c, ASI_NPL_Sub_Channel__r.ASI_MFM_Is_All_Region__c, ASI_NPL_Sub_Channel__r.ASI_MFM_Region__c //MT@202004
                                                                                  from ASI_CRM_CN_Channel_Strategy_Line_Item__c 
                                                                                  where ASI_CRM_CN_Channel_Strategy__c =: channelStrategy.Id
                                                                                  AND ASI_NPL_Version__c =: channelStrategy.ASI_NPL_Vision__c];
        
        Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> percentageList = new Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c> entitlementList = new Map<String,ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        Map<String,ASI_CN_NPL_ChannelMgmtCompCtrl.channelPercentageWrapper> percentageWrapper = new Map<String,ASI_CN_NPL_ChannelMgmtCompCtrl.channelPercentageWrapper>();
        Map<String,ASI_CN_NPL_ChannelMgmtCompCtrl.channelEntitledWrapper> entitlementWrapper = new Map<String,ASI_CN_NPL_ChannelMgmtCompCtrl.channelEntitledWrapper>();
        
        for (ASI_CRM_CN_Channel_Strategy_Line_Item__c lineItem : channelStrategyLineItem){
            if (lineItem.ASI_NPL_Type__c ==  'Channel Percentage'){
                
                ASI_CN_NPL_ChannelMgmtCompCtrl.channelPercentageWrapper testPercent = new ASI_CN_NPL_ChannelMgmtCompCtrl.channelPercentageWrapper();
                testPercent.channelType = lineItem.ASI_NPL_Type__c;
                testPercent.percentage = lineItem.ASI_NPL_Percentage__c;
                testPercent.channel = lineItem.ASI_NPL_Channel__c;
                //channelPercentage.strategyLineItem = lineItem;
                
                percentageList.put(lineItem.ASI_NPL_Channel__r.Name,lineItem);
                percentageWrapper.put(lineItem.ASI_NPL_Channel__r.Name, testPercent);
                
                
            }else if (lineItem.ASI_NPL_Type__c ==  'Sub-Channel Entitlement'){
                system.debug('found Sub Channel:'+lineItem.ASI_NPL_Channel__r.Name +'-'+lineItem.Name);
                string mapkey = lineItem.ASI_NPL_Channel__r.Name+lineItem.ASI_NPL_Sub_Channel__r.Name;
                
                ASI_CN_NPL_ChannelMgmtCompCtrl.channelEntitledWrapper testEntitlement = new ASI_CN_NPL_ChannelMgmtCompCtrl.channelEntitledWrapper();
                testEntitlement.channelType = lineItem.ASI_NPL_Type__c;
                testEntitlement.entitled = lineItem.ASI_NPL_Entitled__c == true? 'Y' : 'N';
                testEntitlement.subChannel = lineItem.ASI_NPL_Sub_Channel__c;
                testEntitlement.channel = lineItem.ASI_NPL_Channel__c;

                //MT@202004 START
                testEntitlement.isAllRegion = lineItem.ASI_NPL_Sub_Channel__r.ASI_MFM_Is_All_Region__c == null? false : lineItem.ASI_NPL_Sub_Channel__r.ASI_MFM_Is_All_Region__c;
                testEntitlement.region_to_rc = lineItem.ASI_NPL_Region__c == null? '' : lineItem.ASI_NPL_Region__c;
                testEntitlement.availableRegions = lineItem.ASI_NPL_Sub_Channel__r.ASI_MFM_Region__c == null? new List<String>() : lineItem.ASI_NPL_Sub_Channel__r.ASI_MFM_Region__c.split(';');
                testEntitlement.regionsSelected = lineItem.ASI_NPL_Region__c == null? '' : lineItem.ASI_NPL_Region__c;
                //MT@202004 END
                
                entitlementList.put(mapkey,lineItem);
                entitlementWrapper.put(mapkey, testEntitlement);
            }
        }
        
        for (ASI_CRM_CN_Channel__c channel : testChannelList){
            if (percentageWrapper.get(channel.Name) == null){
                system.debug('Channel:'+channel.Name);
                
                ASI_CN_NPL_ChannelMgmtCompCtrl.channelPercentageWrapper channelPercentage = new ASI_CN_NPL_ChannelMgmtCompCtrl.channelPercentageWrapper();
                channelPercentage.channelType = 'Channel Percentage';
                channelPercentage.percentage = 0;
                channelPercentage.channel = channel.id;
                percentageWrapper.put(channel.Name, channelPercentage);
            }
        }
        
        for (ASI_MFM_Sub_Channel__c subChannel :testSubChannelList){
            string mapkey = subChannel.ASI_CRM_CN_Channel__r.Name + subChannel.Name;
            if (entitlementWrapper.get(mapkey) == null){
                system.debug('add Sub Channel:'+subChannel.ASI_CRM_CN_Channel__r.Name+'-'+subChannel.Name);
                
                ASI_CN_NPL_ChannelMgmtCompCtrl.channelEntitledWrapper channelEntitled = new ASI_CN_NPL_ChannelMgmtCompCtrl.channelEntitledWrapper();
                channelEntitled.channelType = 'Sub-Channel Entitlement';
                channelEntitled.entitled =  'N';
                channelEntitled.subChannel = subChannel.id;
                channelEntitled.channel = subChannel.ASI_CRM_CN_Channel__c;
                //MT@202004 START
                channelEntitled.isAllRegion = subChannel.ASI_MFM_Is_All_Region__c;
                channelEntitled.region_to_rc = '';
                channelEntitled.availableRegions = subChannel.ASI_MFM_Region__c != null? subChannel.ASI_MFM_Region__c.split(';') : new List<String>();
                channelEntitled.regionsSelected = '';
                //MT@202004 END 
                entitlementWrapper.put(mapkey, channelEntitled);
            }
        }
        
        test.startTest();
        ASI_CN_NPL_ChannelMgmtCompCtrl controller = new ASI_CN_NPL_ChannelMgmtCompCtrl();
        controller.initialised = false;
        controller.recordId = (String)channelStrategy.Id;
        controller.ObjectType = 'Channel Strategy';
        controller.email = false;
        
        Boolean testboolean = controller.initialised;
        ASI_CN_NPL_ChannelMgmtCompCtrl.reviseChannelStrategy(JSON.serialize(percentageWrapper),JSON.serialize(entitlementWrapper),JSON.serialize(percentageList),JSON.serialize(entitlementList),(string)channelStrategy.id);
        ASI_CN_NPL_ChannelMgmtCompCtrl.saveChannelStrategy(JSON.serialize(percentageWrapper),JSON.serialize(entitlementWrapper),JSON.serialize(percentageList),JSON.serialize(entitlementList),(string)channelStrategy.id);
        
        
        test.stopTest();
        
    }
    
    static testMethod void testChannelStrategyTwo(){
        
        ASI_CRM_CN_Channel_Strategy__c channelStrategy = [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c 
                                                          from ASI_CRM_CN_Channel_Strategy__c where ASI_NPL_Vision__c = 2 limit 1];
        
        test.startTest();
        ASI_CN_NPL_ChannelMgmtCompCtrl controller = new ASI_CN_NPL_ChannelMgmtCompCtrl();
        controller.initialised = false;
        controller.recordId = (String)channelStrategy.Id;
        controller.ObjectType = 'Channel Strategy';
        controller.email = false;
        controller.init();
        //ASI_CN_NPL_ChannelMgmtCompCtrl.reviseChannelStrategy('','','','',(string)channelStrategy.id);
        //ASI_CN_NPL_ChannelMgmtCompCtrl.saveChannelStrategy('','','','',(string)channelStrategy.id);
        
        
        test.stopTest();
        
    }
    
    static testMethod void testItemGroup(){
        
        ASI_CRM_CN_Channel_Strategy__c channelStrategy = [select id, Name,ASI_CRM_CN_Status__c, ASI_NPL_Vision__c 
                                                          from ASI_CRM_CN_Channel_Strategy__c where ASI_NPL_Vision__c = 2 limit 1];
        
        ASI_MFM_Item_Group__c itemGroup = [select id from ASI_MFM_Item_Group__c limit 1];
        
        test.startTest();
        ASI_CN_NPL_ChannelMgmtCompCtrl controller = new ASI_CN_NPL_ChannelMgmtCompCtrl();
        controller.initialised = false;
        controller.recordId = (String)itemGroup.Id;
        controller.ObjectType = 'Item Group';
        controller.email = false;
        controller.init();
        
        
        
        test.stopTest();
        
    }
    
    static testMethod void testNewProductLaunch(){
        
        ASI_CN_NPL_NPL_Request__c nplRequest = [select id from ASI_CN_NPL_NPL_Request__c limit 1];
        
        test.startTest();
        ASI_CN_NPL_ChannelMgmtCompCtrl controller = new ASI_CN_NPL_ChannelMgmtCompCtrl();
        controller.initialised = false;
        controller.recordId = (String)nplRequest.Id;
        controller.ObjectType = 'New Product Launch Request';
        controller.email = false;
        controller.init();
        
        
        
        test.stopTest();
        
    }
    
}