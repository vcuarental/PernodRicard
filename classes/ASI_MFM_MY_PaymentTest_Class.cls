@isTest (seealldata=true)
/* 
* 
* /
*/
public class ASI_MFM_MY_PaymentTest_Class {
    
    
    static testMethod void ASI_MFM_POSubmitControllerTest(){ // Test ASI_MFM_POSubmitController
        
        
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_MY_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        preList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo);
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> preRList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pro);
        insert preRList;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Customer'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name3');           
        accList.add(acc3);
        
        insert accList;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=pxo.id);
        insert rtms;
        
        // ASI MFM  PO Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
        insert rrds;
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        insert rrds2;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        List<ASI_MFM_PO__c> poList = new List<ASI_MFM_PO__c>();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po);
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po1);
        ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po2);
         ASI_MFM_PO__c po3= new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po3);
         ASI_MFM_PO__c po4 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po4);
        insert poList;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        List<ASI_MFM_PO_Line_Item__c> polineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=50001,ASI_MFM_Base_Currency_Amount__c=50001,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi);// Base_Currency_Amount__c>50000,but don't include attachments
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_Base_Currency_Amount__c=10001,ASI_MFM_Amount__c=10001,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi1);// _Base_Currency_Amount__c>10000,but include attachments
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po3.id,ASI_MFM_Base_Currency_Amount__c=100,ASI_MFM_Amount__c=100,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi2);// PO without PO Line
        ASI_MFM_PO_Line_Item__c poi3 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po4.id,ASI_MFM_Base_Currency_Amount__c=10001,ASI_MFM_Amount__c=10001,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi3);//Base_Currency_Amount__c<10000
        insert polineList;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        List<Attachment> attList = new List<Attachment>();
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=po1.id;
        attList.add(attach);
        
        Attachment attach1=new Attachment();    
        attach1.Name='Unit Test Attachment';
        Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob1;
        attach1.parentId=po1.id;
        attList.add(attach1);
        
        insert attList;
        
        ASI_MFM_POSubmitController ext1 = new ASI_MFM_POSubmitController(new ApexPages.StandardController(po));
        ext1.submit();
        ASI_MFM_POSubmitController ext2 = new ASI_MFM_POSubmitController(new ApexPages.StandardController(po1));
        ext2.submit();
        ASI_MFM_POSubmitController ext3 = new ASI_MFM_POSubmitController(new ApexPages.StandardController(po2));
        ext3.submit();
        ASI_MFM_POSubmitController ext4 = new ASI_MFM_POSubmitController(new ApexPages.StandardController(po3));
        ext4.submit();
        ASI_MFM_POSubmitController ext5 = new ASI_MFM_POSubmitController(new ApexPages.StandardController(po4));
        ext5.submit();
        
        Test.stopTest();
        
    }
    
}