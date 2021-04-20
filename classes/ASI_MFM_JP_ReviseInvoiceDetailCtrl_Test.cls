/*********************************
 *  Created by: Linus@introv
 * Created at: 2017-09-12
 * Class coverage: 
 * ASI_MFM_JP_ReviseInvoiceDetailController  
 * 
 ***************************************/
@isTest

public class ASI_MFM_JP_ReviseInvoiceDetailCtrl_Test {
	
    static testMethod void ASI_MFM_JP_ReviseInvoiceDetailController() {
    	//User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'JP';
        update u;
        
        //Permission Set Assignment
        PermissionSet PS = [Select id from PermissionSet where name = 'ASI_MFM_JP_Accounting_User' limit 1];
        PermissionSetAssignment PSassign = new PermissionSetAssignment();
        PSassign.AssigneeId = u.id;
        PSassign.PermissionSetId = PS.id;
        insert PSassign;
        
        System.runAs(u){
            //Prefix
            List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_JP_TestClassHelper.getFiscalYear());
            prefixList.add(px); 
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
            prefixList.add(pxo);
            ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
            prefixList.add(pxa);
            insert prefixList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            RPList.add(pr);
            ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            RPList.add(pro);
            ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            RPList.add(pra);
            insert RPList;
            
            //Plan
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_JP_Plan'), name='test',
                                                    ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', 
                                                    ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Prefix__c=px.id, ASI_MFM_Status__c = 'Final');
            insert p;
            
            //Brand and Sub-Brand
            ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c(Name='Brand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_JP_Brand'));
            insert brand1;
            ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_JP_Sub_brand'), ASI_MFM_Brand__c=brand1.id);
            insert subBrand1;
            
            //AP AC Code
            ASI_MFM_AP_Code__c ap = ASI_MFM_JP_TestClassHelper.createJPAPCode();
            ASI_MFM_A_C_Code__c ac = ASI_MFM_JP_TestClassHelper.createJPACCode();
            
            //Account : Customer  Supplier
            List<Account> accToInsert = new List<Account>();
            Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Customer'), Name='Name3');           
            accToInsert.add(acc2);
            Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2',ASI_MFM_Payment_Terms__c='test 301');           
            Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2',ASI_MFM_Payment_Terms__c='test 601');           
            Account acc4 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_JP_Supplier'),Name='Name2',ASI_MFM_Payment_Terms__c='test 902');           
            accToInsert.add(acc1);
            accToInsert.add(acc3);
            accToInsert.add(acc4);
            insert accToInsert;
            
            //Plan line 
            ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_JP_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
                                                                         ,ASI_MFM_Sub_brand_Code__c = subBrand1.id,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_List_Item_Description__c='testDescription');   
            insert pi;  
            
            
            //Create PO 
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO');
            insert rt;
            
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
            insert rtm;
            ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id,Brand_MFM__c=brand1.id);
            insert rtbr;
            
            date startDate = date.newInstance(Date.Today().Year(), Date.Today().Month(), 1);
            ASI_MFM_PO_Date_Range__c podr = new ASI_MFM_PO_Date_Range__c(Name='testPODR',ASI_MFM_PO_Start_Date__c=startDate,ASI_MFM_PO_End_Date__c=startDate.addDays(30),ASI_MFM_GL_Date__c=Date.today(),asi_mfm_next_number__c=1,ASI_MFM_Fiscal_Period__c='201404');
            insert podr;
            
            //PO 
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_JP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id,ASI_MFM_Currency__c='JPY', ASI_MFM_Status__c='Final',
                                                 ASI_MFM_Plan__c = p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Responsible_By__c=u.id,ASI_MFM_PO_Raised_Date__c=Date.today(),ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today()); 
            insert po;
            
            
            
            // PO Line
            List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                      ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                      ASI_MFM_G_L_Date__c = Date.today());
            POLineList.add(poi);
            ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_JP_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=100,
                                                                      ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, 
                                                                      ASI_MFM_G_L_Date__c = Date.today());
            POLineList.add(pol);
            insert POLineList;
            
            // PO Receipt 
            ASI_MFM_PO_Receipt__c POR =new ASI_MFM_PO_Receipt__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_JP_PO_Receipt'),ASI_MFM_PO__c=po.id);
            insert POR;
            
            System.debug(Limits.getDMLRows());
            
            //PO Receipt Item
            List<ASI_MFM_PO_Receipt_Item__c> PORIList = new List<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c PORI = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=poi.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
            PORIList.add(PORI);
            ASI_MFM_PO_Receipt_Item__c PORI2 = new ASI_MFM_PO_Receipt_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),ASI_MFM_Amount__c=10,ASI_MFM_PO_Receipt__c=POR.id,ASI_MFM_PO_Line_Item__c=pol.id,ASI_MFM_PO__c=po.id,ASI_MFM_Marketing_Verify__c=true);
            PORIList.add(PORI2);
            insert PORIList;
            
            // Create Payment  
            List<ASI_MFM_Payment__c> paymentList = new List<ASI_MFM_Payment__c>();
            ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,9,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');  
            ASI_MFM_Payment__c py11 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,11,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
            ASI_MFM_Payment__c py12 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,12,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
            paymentList.add(py1);
            paymentList.add(py11);
            paymentList.add(py12);
            ASI_MFM_Payment__c py2 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,9,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');  
            ASI_MFM_Payment__c py21 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,10,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');
            ASI_MFM_Payment__c py22 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,11,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');
            ASI_MFM_Payment__c py23 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,12,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');
            paymentList.add(py2);
            paymentList.add(py21);
            paymentList.add(py22);
            paymentList.add(py23);            
            ASI_MFM_Payment__c py3 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,8,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc4.id,ASI_MFM_Status__c='Draft');  
            ASI_MFM_Payment__c py31 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,9,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc4.id,ASI_MFM_Status__c='Draft'); 
            ASI_MFM_Payment__c py32 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,10,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc4.id,ASI_MFM_Status__c='Draft'); 
            ASI_MFM_Payment__c py33 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,11,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc4.id,ASI_MFM_Status__c='Draft'); 
            ASI_MFM_Payment__c py34 = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_JP_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Amount__c=100,ASI_MFM_Invoice_Date__c=date.newInstance(2017,12,13),
                                                           ASI_MFM_Currency__c='JPY', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = acc4.id,ASI_MFM_Status__c='Draft');             
            paymentList.add(py3);
            paymentList.add(py31);
            paymentList.add(py32);
            paymentList.add(py33);
            paymentList.add(py34);
            insert paymentList;
            
            /*
            //Paymet line item
            List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
            ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=82, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
            payLineList.add(pyi);
            ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_JP_Payment_Line_Item'), ASI_MFM_PO_Receipt_Item__c=PORI.id,ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=pol.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc1.id); 
            payLineList.add(pyi2);
            insert payLineList;
            */
            
            Test.startTest();
            
            PageReference pageRef1 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py1.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef1);            
            ASI_MFM_JP_ReviseInvoiceDetailController con1 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py1));
            con1.init();
            con1.save();            
            PageReference pageRef11 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py11.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef11);            
            ASI_MFM_JP_ReviseInvoiceDetailController con11 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py11));
            con11.init();
            con11.save();
            PageReference pageRef12 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py12.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef12);            
            ASI_MFM_JP_ReviseInvoiceDetailController con12 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py12));
            con12.init();
            con12.save();
            
            PageReference pageRef2 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py2.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef2);            
            ASI_MFM_JP_ReviseInvoiceDetailController con2 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py2));
            con2.init();
            con2.save();
            PageReference pageRef21 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py21.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef21);            
            ASI_MFM_JP_ReviseInvoiceDetailController con21 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py21));
            con21.init();
            con21.save();
            PageReference pageRef22 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py22.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef22);            
            ASI_MFM_JP_ReviseInvoiceDetailController con22 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py22));
            con22.init();
            con22.save();
            PageReference pageRef23 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py23.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef23);            
            ASI_MFM_JP_ReviseInvoiceDetailController con23 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py23));
            con23.init();
            con23.save();
            
            PageReference pageRef3 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py3.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef3);            
            ASI_MFM_JP_ReviseInvoiceDetailController con3 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py3));
            con3.init();
            con3.save();
            PageReference pageRef31 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py31.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef31);            
            ASI_MFM_JP_ReviseInvoiceDetailController con31 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py31));
            con31.init();
            con31.save();
            PageReference pageRef32 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py32.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef32);            
            ASI_MFM_JP_ReviseInvoiceDetailController con32 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py32));
            con32.init();
            con32.save();
            PageReference pageRef33 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py33.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef33);            
            ASI_MFM_JP_ReviseInvoiceDetailController con33 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py33));
            con33.init();
            con33.save();
            PageReference pageRef34 = new PageReference('/apex/ASI_MFM_JP_ReviseInvoiceDetailPage?id='+ py34.id +'&userid='+u.Id);
            Test.setCurrentPage(pageRef34);            
            ASI_MFM_JP_ReviseInvoiceDetailController con34 = new ASI_MFM_JP_ReviseInvoiceDetailController(new ApexPages.StandardController(py34));
            con34.init();
            con34.save();
            
            Test.stopTest();
        }
    }
}