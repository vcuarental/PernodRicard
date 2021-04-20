@isTest
private class ASI_CRM_CN_TP_BudgetPlanUploadTest {
    @testSetup
    static void testDataPre() {
        User admin = ASI_CRM_CN_TP_TestUtils.generateAdminUser('testAdmin@Pernod.com');
        System.runAs(admin){
            ASI_CRM_CN_CustomSetting__c tpSetting = new ASI_CRM_CN_CustomSetting__c();
            tpSetting.ASI_CRM_CN_TP_BP_Table_Header__c = '客户,财年,CRM,预算所属人,预算总金额,去年促销销量,去年促销金额,去年海报/陈列费,去年Cont. Margin金额,去年Gross Sales金额,备注';
            tpSetting.ASI_CRM_CN_TP_BP_Table_Error_Header__c = '客户,财年,CRM,预算所属人,预算总金额,去年促销销量,去年促销金额,去年海报/陈列费,去年Cont Margin金额,去年Gross Sales金额,备注,错误信息';
            tpSetting.ASI_CRM_CN_TP_Table_Header__c = '活动编号,区域,客户类型,渠道,客户,财年,活动开始时间,活动结束时间,CRM,DM(Y/N),二次陈列,二次陈列门店数,海报费,陈列费,子品牌Code,尺寸(cl),促销方式,促销内容,产品零售价,促销单价/瓶,正常进价,促销进价/瓶,单瓶补贴,预计销量,Remark,备注';
            tpSetting.ASI_CRM_CN_TP_Table_Error_Header__c = '活动编号,区域,客户类型,渠道,客户,财年,活动开始时间,活动结束时间,CRM,DM(Y/N),二次陈列,二次陈列门店数,海报费,陈列费,子品牌Code,尺寸(cl),促销方式,促销内容,产品零售价,促销单价/瓶,正常进价,促销进价/瓶,单瓶补贴,预计销量,Remark,备注,错误信息';
            tpSetting.ASI_CRM_CN_TP_Sub_Brand_Header__c = '子品牌名称,子品牌 Code,中文名称';
            tpSetting.ASI_CRM_CN_TP_BP_Table_Body__c = '世纪联华,FY1920,ONSHA3629,Mousa SUN,10000,10000,10000,10000,100000,12000,备注内容';
            tpSetting.ASI_CRM_CN_TP_City_Header__c = '城市名称,中文名称';
            insert tpSetting;

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;

            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
            insert subChannel;
            
            ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
            insert newChannel;

            Account acc = new Account(Name = 'TestAccount', 
                                      RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
                                      ASI_KOR_Addr_Region__c = 'Central Region');
            insert acc;
            
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'a', 
                                                                                                ASI_CRM_CN_Chi_Name__c = 'a', 
                                                                                                Name = 'TestCustomer',
                                                                                                ASI_CRM_CN_Commercial_Team__c = 'Premium', 
                                                                                                ASI_CRM_CN_Sub_Channel__c=subChannel.Id, 
                                                                                                ASI_CRM_CN_CCity__c=city.Id, 
                                                                                                ASI_CRM_Account__c = acc.Id,
                                                                                                ASI_CRM_CN_WS_Tier__c = 'T2',
                                                                                                ASI_CRM_CN_CRM_Code__c = '123456',
                                                                                                ASI_CRM_CN_JDE_Code_Premium__c = '9500001',
                                                                                                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                                                                                                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));
            insert customer;
            ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c(Name = 'CN Budget Plan', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix'));
            prefix.ASI_MFM_Module__c = 'Plan';
            prefix.Plan_Type__c = 'Budget Plan';
            prefix.ASI_MFM_Fiscal_year__c = 'FY1920';
            insert prefix;

            ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip = new ASI_MFM_Role_Prefix_Relationship__c();
            prefixRelationShip.ASI_MFM_Prefix__c = prefix.Id;
            prefixRelationShip.ASI_MFM_Role_Name__c = 'ASI_CN';
            insert prefixRelationShip;
        }
        

    }
         
    static testMethod void testMethod1() {
        User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
            List<ASI_CRM_CN_TP_BudgetPlanUpload.BudgetPlan> bpList = new List<ASI_CRM_CN_TP_BudgetPlanUpload.BudgetPlan>();
            ASI_CRM_CN_TP_BudgetPlanUpload.BudgetPlan bp = new ASI_CRM_CN_TP_BudgetPlanUpload.BudgetPlan();
            bp.index = 1;
            bp.CRM = '123456';
            bp.fiscalYear = 'FY1920';
            bp.budgetAmount = '1200';
            bp.LYAmount = '1200';
            bp.LYContMarginAmount = '1200';
            bp.LYDMDisplayAmount = '1200';
            bp.LYGrossSalesAmount = '1200';
            bp.LYPromotionVol = '120';
            bpList.add(bp);
            ASI_CRM_CN_TP_BudgetPlanUpload planUpload = new ASI_CRM_CN_TP_BudgetPlanUpload();
            ASI_CRM_CN_TP_BudgetPlanUpload.checkUploadData(JSON.serialize(bp));
            ASI_CRM_CN_TP_BudgetPlanUpload.saveData(JSON.serialize(bpList));
        }
       
        Test.stopTest();

    }
}