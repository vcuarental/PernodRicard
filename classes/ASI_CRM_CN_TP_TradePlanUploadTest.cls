@isTest
private class ASI_CRM_CN_TP_TradePlanUploadTest {
	@testSetup
    static void testDataPre() {
        User admin = ASI_CRM_CN_TP_TestUtils.generateAdminUser('testAdmin@Pernod.com');
        System.runAs(admin){
        	ASI_CRM_CN_CustomSetting__c tpSetting = new ASI_CRM_CN_CustomSetting__c();
            tpSetting.ASI_CRM_CN_TP_BP_Table_Header__c = '客户,财年,CRM,预算所属人,预算总金额,去年促销销量,去年促销金额,去年海报/陈列费,去年Cont. Margin金额,去年Gross Sales金额,备注';
            tpSetting.ASI_CRM_CN_TP_BP_Table_Error_Header__c = '客户,财年,CRM,预算所属人,预算总金额,去年促销销量,去年促销金额,去年海报/陈列费,去年Cont Margin金额,去年Gross Sales金额,备注,错误信息';
            tpSetting.ASI_CRM_CN_TP_Table_Error_Header__c = '活动编号,区域,客户类型,渠道,客户,财年,活动开始时间,活动结束时间,CRM,DM(Y/N),二次陈列,二次陈列门店数,海报费,陈列费,子品牌Code,尺寸(cl),促销方式,促销内容,产品零售价,促销单价/瓶,正常进价,促销进价/瓶,单瓶补贴,预计销量,Remark,备注,错误信息';
            tpSetting.ASI_CRM_CN_TP_Sub_Brand_Header__c = '子品牌名称,子品牌 Code,中文名称,产品名称,产品Code';
            tpSetting.ASI_CRM_CN_TP_City_Header__c = '城市名称,中文名称';
            tpSetting.ASI_CRM_CN_TP_Promotion_Mode__c = '进价核销,scan data,进价核销(含税)';
            tpSetting.ASI_CRM_CN_TP_Table_Header__c = '活动编号,区域,客户类型,渠道,客户,财年,活动开始时间,活动结束时间,CRM,DM(Y/N),二次陈列,二次陈列门店数,海报费,陈列费,子品牌Code,尺寸(cl),促销方式,促销内容,产品零售价,促销单价/瓶,正常进价,促销进价/瓶,单瓶补贴,预计销量,Remark,备注';
            tpSetting.ASI_CRM_CN_TP_Upload_Comments__c = '1.促销方式选项值: 进价核销,scan data,进价核销(含税),其中进价核销(含税)，括号请使用英文括号;2.Remark选项值: Q1,Q2,Q3,Q4,MAF,CNY,HY1,HY2;3.子品牌: 填写品牌列表中子品牌code;4.区域填写值:East,Central,North,South,North West,South West. 若是全国该字段可以不填或者填写Headquarter;5.城市:填写城市列表中的中文名称,如要填多个城市用英文逗号分开,如果促销是该区域所有城市该字段可不填';
            insert tpSetting;
            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='North Region');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id, ASI_CRM_Chinese_Name__c = 'TEST');
            insert city;

            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
            insert subChannel;
            
            ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
            insert newChannel;

            ASI_MFM_Sub_brand__c sbrand = new ASI_MFM_Sub_brand__c ();
    	    sbrand.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
    	    sbrand.Name = 'Aberlour 16 Yo-AR6';
    	    sbrand.ASI_MFM_Sub_brand_Code__c = 'AR6';
    	    sbrand.ASI_HK_CRM_English_Name__c = 'Aberlour 16YO';
    	    sbrand.ASI_CRM_CN_CHI_NAME_C__c = '雅伯乐16年';
            sbrand.ASI_MFM_Active_for_FOC__c = true;
            sbrand.ASI_MFM_Active_for_CRM__c = true;
    	    insert sbrand;

    	    ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(
                    RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'), 
                    Name = 'Test', ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode', ASI_MFM_Sub_brand__c = sbrand.Id, 
                    ASI_CRM_CN_Chinese_Name__c = 'TestItemGroup_CN', ASI_CRM_CN_Eng_Name__c = 'TestItemGroup_EN', ASI_CRM_CN_BT_Size_C__c = '70',
                    ASI_CRM_Allocation_Information__c = true, ASI_CRM_CN_TP_Is_For_CN_TP__c = true); 

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
                                                                                                ASI_CRM_CN_TP_Dummy_Outlet__c = true,
                                                                                                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));
            insert customer;
            ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c(Name = 'CN Trade Plan', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix'));
            prefix.ASI_MFM_Module__c = 'Plan';
            prefix.Plan_Type__c = 'Trade Plan' ;
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
            ASI_CRM_CN_TP_TradePlanUpload tpUpload = new ASI_CRM_CN_TP_TradePlanUpload();
            ASI_CRM_CN_TP_TradePlanUpload.downloadProducts();
            ASI_CRM_CN_TP_TradePlanUpload.downloadCitys();
            List<ASI_CRM_CN_TP_TradePlanUpload.TradePlan> tpList = new List<ASI_CRM_CN_TP_TradePlanUpload.TradePlan>();
            ASI_CRM_CN_TP_TradePlanUpload.TradePlan tp = new ASI_CRM_CN_TP_TradePlanUpload.TradePlan();
            tp.CRM = '123456';
            tp.region = 'North';
            tp.planCity = 'TEST';
            tp.fiscalYear = 'FY1920';
            tp.subBrandCode = 'AR6';
            tp.bottleSize = '70';
            tp.startDate = '2019/10/10';
            tp.endDate = '2019/12/12';
            tp.secondDisplayStoreNO = '3';
            tp.promotionMode = 'scan data';
            tp.posterFee = '2';
            tp.displayFee = '33';
            tp.unitPrice = '122';
            tp.promotionPrice = '122';
            tp.purchasePrice = '122';
            tp.promotionPurchasePrice = '122';
            tp.planQty = '23';
            tp.remark = 'Q1';
            tp.ownerId = admin.Id;
            tpList.add(tp);
            ASI_CRM_CN_TP_TradePlanUpload.checkUploadData(JSON.serialize(tp));
            ASI_CRM_CN_TP_TradePlanUpload.saveData(JSON.serialize(tpList));
        }
        Test.stopTest();
    }



}