@isTest
/********************************
Created By: Linus@introv

Tested Classes:
1. ASI_MFM_TR_GenPOReceipt_Sche
2. ASI_MFM_TR_GenPOReceipt_Batch
3. ASI_MFM_TR_AutoPORSettingController
*********************************/

public class ASI_MFM_TR_GenPOReceipt_Test{


    static testMethod void ASI_MFM_TR_GenPOReceipt_Sche(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1718');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Supplier'),Name='Name2', ASI_HK_CRM_Inactive__c = false);           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TR_Customer'),Name='Name3', ASI_HK_CRM_Inactive__c = false);           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;                   
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TR_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c='Final',ASI_MFM_Route_Type__c=rt.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today());
        insert po;  
        
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert pol;
        
        System.runAs(u){
        Test.startTest();
        
        ASI_MFM_TR_GenPOReceipt_Sche s = new ASI_MFM_TR_GenPOReceipt_Sche();
        s.init();
        
        Test.stopTest();
        }
    }
    
    static testMethod void ASI_MFM_TR_AutoPORSetting_Test(){
        ASI_MFM_AutoPOReceiptSetting__c setting = new ASI_MFM_AutoPOReceiptSetting__c(name='TR',ASI_MFM_Cut_Off_Date__c=System.today(),ASI_MFM_Fiscal_Year__c='FY1718');
        insert setting;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        System.runAs(u){
            Test.startTest();
            
            PageReference pageRef = new Pagereference('/apex/ASI_MFM_TR_AutoPORSettingPage');
            Test.setCurrentPage(pageRef);
            ASI_MFM_TR_AutoPORSettingController controller = new ASI_MFM_TR_AutoPORSettingController();
            
            PageReference result;
            
            result = controller.getSetting();
            result = controller.save();
        }                
        
    }
        
}