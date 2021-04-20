@isTest
/********************************
Tested Classes:
1. ASI_MFM_TR_InputReceiptItemsController
2. ASI_MFM_CN_POReceiptItem_TriggerClass
3. ASI_MFM_POReceipt_TriggerClass
*********************************/
public class ASI_MFM_HK_POReceipt_Test{
    
    static testMethod void ASI_MFM_HK_InputReceiptItemsController(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert poi;
        
        //po.ASI_MFM_Status__c = 'Final';
        //update po;
        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_HK_PO_Receipt'),ASI_MFM_Status__c='Draft');
        insert recp;
        
        list<ASI_MFM_PO_Receipt_Item__c> recpliList = new list<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_HK_PO_Receipt_Item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id, ASI_MFM_PO_Line_Item__c=poi.id);
        recpliList.add(recpli);
        ASI_MFM_PO_Receipt_Item__c recpli1 = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_HK_PO_Receipt_Item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id, ASI_MFM_PO_Line_Item__c=poi.id);
        recpliList.add(recpli1);
        
        insert recpliList;
        
        recp.ASI_MFM_Status__c = 'Final';
        update recp;
        
        test.starttest();
        
        ASI_MFM_SFObjSelectTableController selectTableCon = new ASI_MFM_SFObjSelectTableController();
        //ApexPages.StandardSetController setcon = new ApexPages.StandardSetController(recpliList);
        ApexPages.StandardController scon = new ApexPages.StandardController(recp);
        ApexPages.currentPage().getParameters().put('poid', po.id);
        ASI_MFM_HK_InputReceiptItemsController con = new ASI_MFM_HK_InputReceiptItemsController(scon);
        //con.poid = po.id;
        con.createPOReceipt();
        con.updatePOReceipt();
        selectTableCon.sObjTypeStr = 'ASI_MFM_PO_line_Item__c';
        selectTableCon.displayFieldsStr = 'id,name';
        selectTableCon.init();
        con.setComponentController('selectTable', selectTableCon);
        con.addAll();
        con.FilterPOItems();
        
        con.sobjst_initActionButtonList();
        con.sobjst_initActionButtonStageMap();
        con.sobjst_triggerActionForSObject(null, 'add', poi); //  try null
        con.mcau_initPageBlockActionButtonList();
        con.mcau_triggerPageBlockAction(null, 'TEST');
        con.mcau_triggerActionForSObject(null, 'add', null);
        
        con.setComponentController(null);
        con.setComponentController('TEST', null);
        con.getComponentController();
        con.getComponentController('TEST');
        
        test.stoptest();
    }
    
    static testMethod void ASI_MFM_POReceipt_TriggerClass_Test(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_HK_Plan'), name='test',
            ASI_MFM_End_Date__c = Date.today().addMonths(1), ASI_MFM_Plan_Description__c = 'testDescription', 
                ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(),  ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p; 
        
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');           
        accList.add(acc1);
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');           
        accList.add(acc2);
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO'), name='test', ASI_MFM_Plan__c=p.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;  
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_HK_A_C_Code'));
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', ASI_MFM_Inactive__c = false, recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
            ASI_MFM_Amount__c = 1
            );
        insert poi;
        
        test.starttest();
        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_HK_PO_Receipt'),ASI_MFM_Status__c='Draft');
        insert recp;
        recp.ASI_MFM_Status__c = 'Final';
        //update recp;
        
        list<ASI_MFM_PO_Receipt_Item__c> recpliList = new list<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_HK_PO_Receipt_Item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        recpliList.add(recpli);
        ASI_MFM_PO_Receipt_Item__c recpli1 = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_HK_PO_Receipt_Item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id);
        recpliList.add(recpli1);
        
        insert recpliList;
        
        ASI_MFM_PO_Receipt__c recp2 = [SELECT ASI_MFM_Status__c FROM ASI_MFM_PO_Receipt__c WHERE id=:recp.id];
        recp2.ASI_MFM_Status__c = 'submitted';
        update recp2;
        recp2.ASI_MFM_Status__c = 'Final';
        update recp2;
        delete recpli;        
        test.stoptest();
    }

    /*
    static testMethod void ASI_MFM_POReceipt_TriggerClass2_Test(){
        //user uprex = [select id, userRole.developerName from user where ASI_MFM_Country__c = 'GF' LIMIT 1];
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_Prefix__cASI_MFM_GF_Prefix'), name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px;
        
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_Prefix__cASI_MFM_GF_Prefix'),name='test', ASI_MFM_Fiscal_year__c='FY1415', ASI_MFM_Module__c='Payment', ASI_MFM_Inactive__c = false,ownerid=Userinfo.getUserId());
        insert px1;

        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_GF_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        List<Account> accToInsert = new List<Account>();
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        accToInsert.add(acc2);
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'),Name='Name2');           
        accToInsert.add(acc1);
        
        insert accToInsert;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_GF_BU'), name='test');
        insert bu;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_Prefix__cASI_MFM_GF_Prefix'),name='1014', ASI_MFM_Module__c='PO',ASI_MFM_Fiscal_year__c='FY1415');
        //ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        User usergf = [SELECT Id from User where Profile.Name = 'ASI GF Standard Platform User' AND ASI_MFM_Country__c='GF' LIMIT 1];
        system.runas(usergf){
            insert pxo;
        }
         
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=px.id );
        insert rtm;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;      
        ASI_MFM_Role_Prefix_Relationship__c pro2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro2;                
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
        ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
        insert podr;

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_GF_PO'), name='test',  ASI_MFM_Status__c='Draft',ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today(),
            ASI_MFM_PO_Type__c= 'VAP Brand Owner'); 
        insert po;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        test.starttest();
        
        ASI_MFM_PO_Receipt__c recp = new ASI_MFM_PO_Receipt__c(RecordTypeid=Global_RecordTypeCache.getRTid('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'),ASI_MFM_Status__c='Final');
        insert recp;
        
        ASI_MFM_PO_Receipt__c recp1 = [SELECT id FROM ASI_MFM_PO_Receipt__c WHERE id = :recp.id];
        update recp1;
        
        list<ASI_MFM_PO_Receipt_Item__c> recpliList = new list<ASI_MFM_PO_Receipt_Item__c>();
        ASI_MFM_PO_Receipt_Item__c recpli = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_Amount__c=100);
        recpliList.add(recpli);
        ASI_MFM_PO_Receipt_Item__c recpli1 = new ASI_MFM_PO_Receipt_Item__c(RecordTypeid=Global_recordtypecache.getRTid('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'),ASI_MFM_PO_Receipt__c=recp.id, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_Amount__c=1);
        recpliList.add(recpli1);
        
        insert recpliList;
        
        ASI_MFM_PO_Receipt__c recp2 = [SELECT ASI_MFM_Status__c FROM ASI_MFM_PO_Receipt__c WHERE id=:recp.id];
        recp2.ASI_MFM_Status__c = 'submitted';
        update recp2;
        //recp2.ASI_MFM_Status__c = 'Final';
        //update recp2;
        test.stoptest();
    }*/
}