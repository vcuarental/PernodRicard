/*********************************************************************************
 * Name:ASI_MFM_CAP_SG_Payment_Test
 * Description: Test Class for payment object components
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/16/2015       Laputa: Conrad          Created
 * 24/10/2019       Wilken Lee          	[WL 1.0] Test class coverage fix
*********************************************************************************/
@isTest
public class ASI_MFM_CAP_SG_Payment_Test {

    static testMethod void testDirectPayment()
    {
        user u = ASI_MFM_CAP_SG_TestClassHelper.createUser();
        system.runAs(u) {
            ASI_MFM_Prefix__c prefixPayment = ASI_MFM_CAP_SG_TestClassHelper.createPrefixPayment(u);
            ASI_MFM_Prefix__c prefixPO = ASI_MFM_CAP_SG_TestClassHelper.createPrefixPO(u);
            ASI_MFM_AP_Code__c apCode = ASI_MFM_CAP_SG_TestClassHelper.createapCode();
            
            ASI_MFM_Payment__c py = new ASI_MFM_CAP_SG_TestClassHelper.createPayment(prefixPayment).payment;
			py.ASI_MFM_Exchange_Rate__c = 1; //WL 1.0
			update py; //WL 1.0
			
            ASI_MFM_PO__c po = new ASI_MFM_CAP_SG_TestClassHelper.createPO(prefixPO).po;
            ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_CAP_SG_TestClassHelper.createPOLine(po).poLine;
            
            ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);
    
            apexpages.currentPage().getParameters().put('paid', py.id); 
            apexpages.currentPage().getParameters().put('poid', po.id); 
    
            Test.StartTest();
        
            Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);
            ApexPages.currentPage().getHeaders().put('referer', 'test');
            
            ASI_MFM_CAP_SG_EditSmallAmountPay_Ctrl controller = new ASI_MFM_CAP_SG_EditSmallAmountPay_Ctrl(); 
            controller.init();
            List<SelectOption> selectOptions = controller.getTypeItems();
            String[] testString = controller.getselectedtype();
            controller.setselectedType(testString);
            
            controller.LSAPHeader[0].type = '--None--';
            controller.LSAPHeader[0].isTnE = true;
            controller.LSAPHeader[0].po = po.clone(false, true, false, false);
            controller.LSAPHeader[0].po.id = null;
            
            controller.payment_prefixes.id = py.ASI_MFM_Prefix__c;
            controller.LSAPHeader[0].pay = py.clone(false, true, false, false);
            controller.LSAPHeader[0].pay.id = null;
            
            controller.AddNew_SAPL();
            
            ASI_MFM_CAP_SG_EditSmallAmountPay_Ctrl.SAPLineObj sapl_Clone = controller.SAPL_Item_Map.get(0);
            sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
            sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
            sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
            sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
            sapl_Clone.APSelected = apCode.id;
            sapl_clone.updateAP();
            //sapl_clone.updateBU();
            String[] testPlan = ASI_MFM_CAP_SG_EditSmallAmountPay_Ctrl.findSObjects('ASI_MFM_Plan__c', '');
            String[] testAccount = ASI_MFM_CAP_SG_EditSmallAmountPay_Ctrl.findCustSObjects('account', 'ASI_MFM_HK_Supplier');
            sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
            
            System.currentPageReference().getParameters().put('APChoice', (String)apCode.id);
            System.currentPageReference().getParameters().put('cpiKey', '0');
            controller.updateAPPick();
            
            controller.rowidSAPL = 0;
            controller.Clone_SAPL();
            controller.rowidSAPL = 1;
            controller.RemoveRow_SAPL();
            controller.SaveRecord();
            controller.LSAPHeader[0].type = 'Brand Owner Invoice';
            controller.SaveRecord();
            controller.cancel();
        
            Test.StopTest();
        }
   }

    static testMethod void testMangeAllPayment() {
        ASI_MFM_Prefix__c prefixPayment = ASI_MFM_CAP_SG_TestClassHelper.createPrefixPayment();
        ASI_MFM_Prefix__c prefixPO = ASI_MFM_CAP_SG_TestClassHelper.createPrefixPO();
        ASI_MFM_AP_Code__c apCode = ASI_MFM_CAP_SG_TestClassHelper.createapCode();
        
        ASI_MFM_Payment__c py = new ASI_MFM_CAP_SG_TestClassHelper.createPayment(prefixPayment).payment;
		
		py.ASI_MFM_Exchange_Rate__c = 1; //WL 1.0
		update py; //WL 1.0
		
        ASI_MFM_PO__c po = new ASI_MFM_CAP_SG_TestClassHelper.createPO(prefixPO).po;
        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_CAP_SG_TestClassHelper.createPOLine(po).poLine;
        
        ASI_MFM_Payment_Line_Item__c pyi = ASI_MFM_CAP_TestClassHelper.createPaymentLines(py, poLine);
        
        Test.StartTest();
        Test.setCurrentPage(Page.ASI_MFM_CAP_SG_MgAll_PaymentPage);
        ApexPages.currentPage().getHeaders().put('referer', 'test');
        apexpages.currentPage().getParameters().put('id', py.id); 
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(py);
        
        ASI_MFM_CAP_SG_MgAll_PaymentController controller = new ASI_MFM_CAP_SG_MgAll_PaymentController(stdCon); 
        controller.addPaymentLine();
        System.currentPageReference().getParameters().put('PARAM_Payment_SOURCE_ITEM_ID', (String)pyi.id);
        controller.clonePaymentLine();
        System.currentPageReference().getParameters().put('PARAM_PAYMENT_LINE_ID', (String)pyi.id);
        controller.removePaymentLine();
        controller.savePayment();
        controller.cancel();
        py.ASI_MFM_Invoice_Date__c = date.today().addDays(1);
        update py;
        py.ASI_MFM_Status__c = 'Submitted';
        update py;
        delete py;
        Test.StopTest();
        
    }

}