@isTest(SeeAllData=false)

public class ASI_CRM_TW_Function_Test {
    public static testMethod void ASI_CRM_TW_Offtake_Test() {
        
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid, ASI_KOR_User_Region_Code__c
                  from user where (profile.Name = 'System Administrator' or profile.Name = 'ASI System Administrator') and isactive = true and userroleid <> null limit 1];                                                                          
        
        System.runAs(u) {
            List<Account> listOutlet = new List<Account>();
            listOutlet.add(new Account(  RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                                       Name='Test Outlet', ASI_HK_CRM_JDE_Account_Number__c='10300001',Channel__c='WS',
                                       ownerid = u.id ,   ASI_TH_CRM_Region__c ='North')  );  
            listOutlet.add(new Account(  RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Wholesaler'), 
                                       Name='Test Wholesaler', ASI_HK_CRM_JDE_Account_Number__c='10300002',Channel__c='SWS',
                                       ownerid = u.id ,   ASI_TH_CRM_Region__c ='North')  );  
            listOutlet.add(new Account(  RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Wholesaler'), 
                                       Name='Test Wholesaler', ASI_HK_CRM_JDE_Account_Number__c='10300003',Channel__c='SWS',
                                       ownerid = u.id ,   ASI_TH_CRM_Region__c ='North')  );  
            listOutlet.add(new Account(  RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                                       Name='Test Outlet', ASI_HK_CRM_JDE_Account_Number__c='10300004',Channel__c='SWS',
                                       ownerid = u.id ,   ASI_TH_CRM_Region__c ='North')  );  
            insert listOutlet;
            
            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c( RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel') ,
                                                                     Name = 'Subwholesaler');
            insert channel;
            // ASI_CRM_TW_Channel
            
            
            List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
            customerList.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Wholesaler'),
                                                                    Name='Test',ASI_CRM_Channel__c = channel.Id,
                                                                    ASI_CRM_Account__c=listOutlet[0].Id ));
            customerList.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                                                                    Name='Test',ASI_CRM_Channel__c = channel.Id,
                                                                    ASI_CRM_Account__c=listOutlet[1].Id ));
             customerList.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                                                                    Name='Test',ASI_CRM_Channel__c = channel.Id,
                                                                    ASI_CRM_Account__c=listOutlet[2].Id ));
                         customerList.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                                                                    Name='Test',ASI_CRM_Channel__c = channel.Id,
                                                                    ASI_CRM_Account__c=listOutlet[3].Id ));
            insert customerList;
            
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(  name = 'testSubBrand',  ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE,  ASI_TH_CRM_Active__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')   );
            insert sub;
            
            
            List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
            listSKU.add(new ASI_MFM_SKU_Code__c( name = 'POSM SKU',ASI_MFM_SKU_Code__c ='111229' , ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = sub.id, ASI_HK_CRM_IsPOSProduct__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code')));
            insert listSKU;
            
            ASI_CRM_TW_Settings__c customSetting = new ASI_CRM_TW_Settings__c(  ASI_CRM_Daily_Offtake_From_Year_SWS__c ='2020', ASI_CRM_Daily_Offtake_From_Month_SWS__c = '2',
                                                                             ASI_CRM_Daily_Offtake_From_Year_WS__c ='2020' ,ASI_CRM_Daily_Offtake_From_Month_WS__c = '2');
            insert customSetting;
            
            
            ASI_CRM_SKU_Mapping__c smh = new ASI_CRM_SKU_Mapping__c(ASI_CRM_Account__c = listOutlet[0].Id,
                                                                    Recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cASI_CRM_TW_SKU_Mapping_Header'));
            
            insert smh;
            
            
            ASI_CRM_SKU_Mapping__c sm = new ASI_CRM_SKU_Mapping__c(ASI_CRM_Offtake_Product__c ='W0780700',ASI_CRM_SKU_Mapping_Header__c =smh.Id ,ASI_CRM_SKU__c =listSKU[0].Id ,
                                                                   Recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cASI_CRM_TW_SKU_Mapping_Detail'));
            
            insert sm;
            
            
            ASI_CRM_Customer_Mapping__c cmh = new ASI_CRM_Customer_Mapping__c(ASI_CRM_Account__C = listOutlet[0].Id, Recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_TW_Customer_Mapping_Header'));
            
            
            insert cmh;
            
            ASI_CRM_Customer_Mapping__c cm = new ASI_CRM_Customer_Mapping__c(ASI_CRM_JDE_Cust_No__c = listOutlet[0].Id,ASI_CRM_Customer_Mapping__c=cmh.Id ,
                                                                             ASI_CRM_Offtake_Customer_No__c ='10300001',Recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_TW_Customer_Mapping_Detail'));

            insert cm;
            
            test.startTest();
            
            PageReference TestPage = Page.ASI_CRM_TW_Offtake_UploadPage;
            Test.setCurrentPage(TestPage);
            
            ASI_CRM_TW_OfftakeUploadController controller = new ASI_CRM_TW_OfftakeUploadController();
            controller.nameFile = 'OFF_OT_30010199_20201116_Test@pernod-ricard.com.csv';
            String csv = 'INV,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001'; 
            csv += 'INV,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20200205,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'ADJ,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20200705,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20200805,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'BAL,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20200905,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'STK,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'STK,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'ADJ,U,10300001,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
             csv += 'ADJ,U,10300001,縈泰洋酒(股)公司,10300002,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300002,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300003,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300004,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            
            csv += 'INV,U,10300002,縈泰洋酒(股)公司,10300001,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'STK,U,10300001,縈泰洋酒(股)公司,10300002,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300001,縈泰洋酒(股)公司,10300003,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300001,縈泰洋酒(股)公司,10300004,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';

            csv += 'INV,U,10300001,縈泰洋酒(股)公司,10300002,縈泰洋酒(股)公司,20210131,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            csv += 'INV,U,10300001,縈泰洋酒(股)公司,10300002,縈泰洋酒(股)公司,20210128,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';

            csv += 'ADJ,U, ,縈泰洋酒(股)公司, ,縈泰洋酒(股)公司,20201031,111229,W0780700,亞伯樂12年單一純麥威士忌,10,202010310001\r\n';
            
            controller.contentFile = blob.valueOf(csv);
            controller.channelstr = 'WS';
            controller.uploadCSVByBatch();
            
            String[] msgs = controller.StatusMsgs; 
            
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch(listOutlet[0].Id+'_2020_10_false');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch(listOutlet[0].Id+'_2020_07_false'); 
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch(listOutlet[0].Id+'_2020_08_false');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch(listOutlet[0].Id+'_2020_10_false');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch(listOutlet[0].Id+'_2020_10_true');
              
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch2(listOutlet[1].Id+'_2021_01');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch2(listOutlet[1].Id+'_2020_10');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch2(listOutlet[0].Id+'_2020_07'); 
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch2(listOutlet[0].Id+'_2020_08');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch2(listOutlet[0].Id+'_2020_10');
            ASI_CRM_TW_Function.OfftakeBALCalulationBatch2(listOutlet[0].Id+'_2020_10');
            
             ASI_CRM_TW_Function.DeleteOfftakeData('select id,OwnerId,ASI_CRM_Channel__c,ASI_TH_CRM_Offtake_G_L_Date__c from ASI_TH_CRM_Actual_Offtake__c');
         
            test.stopTest();
        }
    }
}