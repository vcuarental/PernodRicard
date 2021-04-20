@isTest
/********************************
Tested Classes:
1. ASI_MFM_Plan_TriggerClass
2. ASI_MFM_TR_InputPlanItemsPage_MassEdit
**********************************/
public class ASI_MFM_TR_Plan_Test{
    static testMethod void ASI_MFM_Plan_TriggerClass_TEST() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordtypeid=Global_RecordTypeCache.getRTId('ASI_MFM_Prefix__cASI_MFM_TR_Prefix'),name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test');
        insert bu;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(recordtypeid=Global_RecordTypeCache.getRTId('ASI_MFM_Route_Type__cASI_MFM_TR_MFM_Route_Type'), name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id); // Note :use Payment Prefix
        insert rtm;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=0));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=1));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=2));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=3));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=4));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=5));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=6));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=7));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=8));
        rrdlist.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Sequence__c=9));  
        insert rrdlist;
        
        Test.startTest();
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Submitted');
        
        insert p;
        
        ASI_MFM_Plan__c p0 = [SELECT ASI_MFM_Status__c FROM ASI_MFM_Plan__c WHERE id = :p.id];
        p0.ASI_MFM_Status__c = 'Draft';
        update p0;
 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Cloned_Plan_ID__c=p0.id,
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p1;
                
        /*
        ASI_MFM_Plan_Line_Item__c planli1 = new ASI_MFM_Plan_Line_Item__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'),ASI_MFM_A_C_Code__c=ac.id,
        ASI_MFM_AP_Code__c=ap.id,ASI_MFM_Unit_Cost__c=1,ASI_MFM_Quantity__c=1,ASI_MFM_Plan__c=p1.id,ASI_MFM_BU_Code__c);
        insert planli1;
        */
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi;  
        ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p0.id
            ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        insert pi1; 
        
        p1.ASI_MFM_Status__c = 'Complete';
        update pi;
        delete p0;
        Test.stopTest();
            
    }
    
    static testMethod void ASI_MFM_TR_InputPlanItemsPage_MassEdit1_TEST(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordtypeid=Global_RecordTypeCache.getRTId('ASI_MFM_Prefix__cASI_MFM_TR_Prefix'),name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand2;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test');
        insert bu;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
                                                ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        
        insert p;
        /*
        ASI_MFM_Plan__c p0 = [SELECT ASI_MFM_Status__c FROM ASI_MFM_Plan__c WHERE id = :p.id];
        p0.ASI_MFM_Status__c = 'Draft';
        update p0;
 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
            ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Cloned_Plan_ID__c=p0.id,
                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        insert p1;
        
        delete p0;
        
        ASI_MFM_Plan_Line_Item__c planli1 = new ASI_MFM_Plan_Line_Item__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'),ASI_MFM_A_C_Code__c=ac.id,
        ASI_MFM_AP_Code__c=ap.id,ASI_MFM_Unit_Cost__c=1,ASI_MFM_Quantity__c=1,ASI_MFM_Plan__c=p1.id,ASI_MFM_BU_Code__c);
        insert planli1;
        */
         list<ASI_MFM_Plan_Line_Item__c > liList = new list<ASI_MFM_Plan_Line_Item__c >();
         ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                      ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
         liList.add(pi);  
         
         ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                       ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
         liList.add(pi1); 
         
         ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id,
                                                                       ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand2.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testD453escription',ASI_MFM_BU_Code__c=bu.id);   
         liList.add(pi2); 
         
         insert liList;
         
         test.starttest();
         
         ApexPages.StandardController scon = new ApexPages.StandardController(p);
         ApexPages.StandardsetController setcon = new ApexPages.StandardsetController(liList);
         ApexPages.currentPage().getParameters().put('id', p.id);
         ASI_MFM_TR_InputPlanItemsPage_MassEdit con = new ASI_MFM_TR_InputPlanItemsPage_MassEdit(setcon);
         //con.pid = p.id;
         for (ASI_MFM_Plan_Line_Item__c templist : liList){
             ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj item1 = new ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj();
             item1.ppl = templist;
             item1.selected = true;
             con.results.add(item1);
         }
         
         con.search();
         
         //con.rowObjAll.ASI_MFM_Customer_Name__c = 'testAbc';
         con.APPLY();
         con.DELETESELECTED() ;
         con.CLONESELECTED();
         con.ADDNEW();
         
         con.results.clear();
         
         con.search();
         con.APPLY();
         con.DELETESELECTED() ;
         con.CLONESELECTED();
         
         for (ASI_MFM_Plan_Line_Item__c templist : liList){
             ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj item1 = new ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj();
             item1.ppl = templist;
             item1.selected = true;
             con.results.add(item1);
         }
         con.ADDNEW();
         con.Previous();
         con.Beginning();
         con.Next() ;
         con.End() ;
         con.getDisablePrevious() ;
         con.getDisableNext();
         //con.searchCurrentPage();
         con.save();
         con.quickSave();
         con.onclickCheckbox();
         con.onclickAllCheckbox();
         ASI_MFM_TR_InputPlanItemsPage_MassEdit.findCustSObjects('Account','Commercial;c;ATR');
         ASI_MFM_TR_InputPlanItemsPage_MassEdit.findSObjects('ASI_MFM_Sub_brand__c','WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = \'ATR\'');
         ASI_MFM_TR_InputPlanItemsPage_MassEdit.findCustSObjects('Account','Commercial;c;JDF');        
         ASI_MFM_TR_InputPlanItemsPage_MassEdit.findSObjects('ASI_MFM_Sub_brand__c','WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = \'JDF\'');
         test.stoptest();
     }
    static testMethod void ASI_MFM_TR_InputPlanItemsPage_MassEdit2_TEST(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordtypeid=Global_RecordTypeCache.getRTId('ASI_MFM_Prefix__cASI_MFM_TR_Prefix'),name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415',ASI_MFM_Location__c='');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand2;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test');
        insert bu;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
                                                ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        
        insert p;
        
        list<ASI_MFM_Plan_Line_Item__c > liList = new list<ASI_MFM_Plan_Line_Item__c >();
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        liList.add(pi);  
        
        ASI_MFM_Plan_Line_Item__c pi1 = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                      ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        liList.add(pi1); 
        
        ASI_MFM_Plan_Line_Item__c pi2 = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                      ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand2.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        liList.add(pi2); 
        
        
        
        
        test.starttest();
        
        ApexPages.StandardController scon = new ApexPages.StandardController(p);
        ApexPages.StandardsetController setcon = new ApexPages.StandardsetController(liList);
        ApexPages.currentPage().getParameters().put('id', p.id);
        ASI_MFM_TR_InputPlanItemsPage_MassEdit con = new ASI_MFM_TR_InputPlanItemsPage_MassEdit(setcon);
        con.pid = p.id;
        for (ASI_MFM_Plan_Line_Item__c templist : liList){
            ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj item1 = new ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj();
            item1.ppl = templist;
            item1.selected = true;
            con.results.add(item1);
        }
        
        con.search();
        
        //con.rowObjAll.ASI_MFM_Customer_Name__c = 'testAbc';
        con.APPLY();
        con.DELETESELECTED() ;
        con.CLONESELECTED();
        con.ADDNEW();
        insert liList;
        con.Previous();
        con.Beginning();
        con.Next() ;
        con.End() ;
        con.getDisablePrevious() ;
        con.getDisableNext();
        //con.searchCurrentPage();
        con.save();
        con.quickSave();
        con.onclickCheckbox();
        con.onclickAllCheckbox();
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findCustSObjects('Account','Commercial;c;ATR');
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findSObjects('ASI_MFM_Sub_brand__c','WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = \'ATR\'');
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findCustSObjects('Account','Commercial;c;JDF');        
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findSObjects('ASI_MFM_Sub_brand__c','WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = \'JDF\'');
        test.stoptest();
    }
    //-- Added by Alan Wong (Elufa) 20150715 --//
    static testMethod void ASI_MFM_TR_InputPlanItemsPage_MassEdit3_TEST(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(recordtypeid=Global_RecordTypeCache.getRTId('ASI_MFM_Prefix__cASI_MFM_TR_Prefix'),name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415',ASI_MFM_Location__c='');
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_TR_Brand'));
        insert brand1;
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand1;
        ASI_MFM_Sub_brand__c subBrand2 = new ASI_MFM_Sub_brand__c(Name='subBrand2', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TR_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
        insert subBrand2;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAP');
        insert ap;
        
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(Recordtypeid=Global_recordtypecache.getrtid('ASI_MFM_BU__cASI_MFM_TR_BU'), name='test');
        insert bu;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TR_Plan'), name='test',
                                                ASI_MFM_End_Date__c=Date.today().addmonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                                ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
        
        insert p;
        
        list<ASI_MFM_Plan_Line_Item__c > liList = new list<ASI_MFM_Plan_Line_Item__c >();
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TR_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                     ,ASI_MFM_Total_Cost__c=0,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription',ASI_MFM_BU_Code__c=bu.id);   
        liList.add(pi);  
        
        test.starttest();
        
        ApexPages.StandardController scon = new ApexPages.StandardController(p);
        ApexPages.StandardsetController setcon = new ApexPages.StandardsetController(liList);
        ApexPages.currentPage().getParameters().put('id', p.id);
        ASI_MFM_TR_InputPlanItemsPage_MassEdit con = new ASI_MFM_TR_InputPlanItemsPage_MassEdit(setcon);
        con.pid = p.id;
        for (ASI_MFM_Plan_Line_Item__c templist : liList){
            ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj item1 = new ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj();
            item1.ppl = templist;
            item1.selected = true;
            con.results.add(item1);
        }
        
        con.ADDNEW();
        insert liList;
        con.save();
        con.quickSave();
        con.results.clear();
        for (ASI_MFM_Plan_Line_Item__c templist : liList){
            ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj item1 = new ASI_MFM_TR_InputPlanItemsPage_MassEdit.PlanLineobj();
            item1.ppl = templist;
            item1.selected = true;
            item1.CCode = 'testCustomer';
            item1.APCode = 'testAP';
            item1.SBCode = 'subBrand1';
            con.results.add(item1);
        }
        con.save();
        con.quickSave();
        con.onclickCheckbox();
        con.onclickAllCheckbox();
        con.Previous();
        con.Beginning();
        con.Next() ;
        con.End() ;
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findCustSObjects('Account','Commercial;c;ATR');
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findSObjects('ASI_MFM_Sub_brand__c','WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = \'ATR\'');
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findCustSObjects('Account','Commercial;c;JDF');        
        ASI_MFM_TR_InputPlanItemsPage_MassEdit.findSObjects('ASI_MFM_Sub_brand__c','WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = \'JDF\'');
        test.stoptest();
    }
    //-- End --//
}