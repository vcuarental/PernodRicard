@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_OfftakeCopyCtl
 2. ASI_CRM_MY_OfftakeMassEditCtl
 3. ASI_CRM_MY_OfftakeReportCtl
****************************************/
public class ASI_CRM_MY_Offtake_TEST{

    
    static testMethod void Offtake_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
         
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        GMList.add(GM);
        insert GMList;
        System.runAs(userA){
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
            
            integer y = today.year();
            integer m = today.month();
            
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
                
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');

            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            
            List<ASI_CRM_ActualOfftakeHeader__c> l_ActualOfftakeHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
            ASI_CRM_ActualOfftakeHeader__c Offtake_H = new ASI_CRM_ActualOfftakeHeader__c();
            Offtake_H.ASI_CRM_ToOutlet__c = customer1.id;
            Offtake_H.ASI_CRM_OfftakeDate__c= date.newinstance(y,m,1);
            Offtake_H.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
            insert Offtake_H;
            
            integer m2 = today.addMonths(-1).month();
            ASI_CRM_ActualOfftakeHeader__c Offtake_H2 = new ASI_CRM_ActualOfftakeHeader__c();
            Offtake_H2.ASI_CRM_ToOutlet__c = customer1.id;
            Offtake_H2.ASI_CRM_OfftakeDate__c= date.newinstance(y,m2,1);
            Offtake_H2.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
            l_ActualOfftakeHeader.add(Offtake_H2);
            
            integer m3 = today.addMonths(-2).month();
            ASI_CRM_ActualOfftakeHeader__c Offtake_H3 = new ASI_CRM_ActualOfftakeHeader__c();
            Offtake_H3.ASI_CRM_ToOutlet__c = customer1.id;
            Offtake_H3.ASI_CRM_OfftakeDate__c= date.newinstance(y,m3,1);
            Offtake_H3.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
            l_ActualOfftakeHeader.add(Offtake_H3);
            insert l_ActualOfftakeHeader;
                
            ASI_TH_CRM_Actual_Offtake__c Offtake_L = new ASI_TH_CRM_Actual_Offtake__c();
            Offtake_L.ASI_CRM_ActualOfftakeHeader__c = Offtake_H.id;
            Offtake_L.ASI_CRM_SKU__c = sku1.id; 
            Offtake_L.ASI_CRM_FromWS__c = customer1.id;
            Offtake_L.ASI_TH_CRM_Quantity__c = 11;
            Offtake_L.ASI_CRM_Price__c = 11;
            Offtake_L.ASI_CRM_InvoiceDate__c = date.newinstance(y,m,1);
            Offtake_L.ASI_CRM_InvoiceNumber__c = 'INV01';
            Offtake_L.recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
            insert Offtake_L;
            
            ASI_CRM_ActualOfftakeHeader__c[] OfftakeList = [SELECT id FROM ASI_CRM_ActualOfftakeHeader__c LIMIT 1];
            
            
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(OfftakeList);
            ApexPages.currentpage().getparameters().put('id', Offtake_H.id);
            
            ASI_CRM_MY_OfftakeCopyCtl controllerCopy = new ASI_CRM_MY_OfftakeCopyCtl(standardSetCtl);
            controllerCopy.AOHeader = Offtake_H;
            controllerCopy.ADDNEW();
            controllerCopy.CLONESELECTED();
            controllerCopy.DELETESELECTED();
            controllerCopy.BEGINNING();
            controllerCopy.PREVIOUS();
            controllerCopy.NEXT();
            controllerCopy.END();
            controllerCopy.ADDNEW();
            controllerCopy.SAVE();
            controllerCopy.ADDNEW();
            controllerCopy.SAVE();
		
            
            ASI_CRM_MY_OfftakeMassEditCtl controllerEdit = new ASI_CRM_MY_OfftakeMassEditCtl(standardSetCtl);
            controllerEdit.ADDNEW();
            controllerEdit.CLONESELECTED();
            controllerEdit.DELETESELECTED();
            controllerEdit.BEGINNING();
            controllerEdit.PREVIOUS();
            controllerEdit.NEXT();
            controllerEdit.END();
            controllerEdit.ADDNEW();
            controllerEdit.SAVE();
            controllerEdit.ADDNEW();
            controllerEdit.SAVE();
            
            //update Offtake_L;
            //Delete Offtake_L;
            
            ASI_TH_CRM_Actual_Offtake__c Offtake_L2 = new ASI_TH_CRM_Actual_Offtake__c(ASI_CRM_Adjustment__c = TRUE, ASI_CRM_ActualOfftakeHeader__c = Offtake_H.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_FromWS__c = customer1.id, ASI_TH_CRM_Quantity__c = 11, ASI_CRM_Price__c = 11, ASI_CRM_InvoiceDate__c = date.newinstance(y,m,1), ASI_CRM_InvoiceNumber__c = 'INV01', recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake'));
            insert Offtake_L2;
        }
    }
    
    

    
    static testMethod void suggestedFOC_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        
        Group gp2 = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        GroupMember Gm2 = new GroupMember();
        GM2.GroupId = gp2.id;
        GM2.UserOrGroupId = userA.Id;
        
        GMList.add(GM2);
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
        
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            integer y = today.year();
            integer m = today.month();
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            ASI_CRM_AccountsAdditionalField__c customerParent = ASI_CRM_MY_TestClassHelper.createParentCustomer('customerParent', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createChildrenCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet', customerParent);
			
            customerParent.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customerParent;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customerParent, today, true);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                          	id, 
                                          	ASI_CRM_Terminate__c, 
                                          	ASI_CRM_Obsolete_Version__c, 
                                          	ASI_TH_CRM_End_Date__c, 
                                          	ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            //update con;
            
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            //update con;
            
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku3', productCategory);
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_SKU_Group__c skuGroup = ASI_CRM_MY_TestClassHelper.createSKUGroup(sku1);
            //sku1.ASI_CRM_SKU_Group__c = skuGroup.Id;
            sku1.ASI_CRM_SKU_Group_Code__c = 'BLE130';
            sku1.ASI_MFM_SKU_Code__c = 'BLE130';
            update sku1;
            
            
            Date perviousDate = today.addMonths(-1);
            String strPY = String.valueOf(perviousDate.year());
            String strPM = String.valueOf(perviousDate.month());
            strPM = strPM.length() == 1 ? '0' + strPM : strPM;
            
			// create calculated foc header             
            ASI_CRM_Calculated_FOC__c foc = ASI_CRM_MY_TestClassHelper.createCalculatedFOC(customer1, con, strPY, strPM, userA);
            
            // create calculated foc line   
            ASI_CRM_Calculated_FOC_Line__c focLine = ASI_CRM_MY_TestClassHelper.createCalculatedFOCLine(foc, sku1);
            
            // create calculated payment 
            ASI_CRM_Calculated_Payment__c calPayment = ASI_CRM_MY_TestClassHelper.createCalculatedPayment(customer1, con, strPY, strPM, userA, 'Other Incentive');
            
            // create calculated payment line   
            ASI_CRM_Calculated_Payment_Item__c calPaymentLine = ASI_CRM_MY_TestClassHelper.createCalculatedPaymentLine(calPayment, sku1);
            
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 20);
            ASI_CRM_ContractTarget__c ct2 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku2, 100);
            ASI_CRM_ContractTarget__c ct3 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku3, 0);
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            ASI_CRM_ContractVolumeIncentive__c vi2 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku2);
            ASI_CRM_ContractVolumeIncentive__c vi3 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku3);
            
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            ASI_CRM_ContractSalesStaffIncentive__c  ss2 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku2);
            ASI_CRM_ContractSalesStaffIncentive__c  ss3 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku3);
            
             
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1);
            ASI_CRM_ContractOtherIncentive__c oi2 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku2);
            ASI_CRM_ContractOtherIncentive__c oi3 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku3);
          
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            
            //ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1');
            
                
            // Create Actual Offtake Header
            ASI_CRM_ActualOfftakeHeader__c Offtake_H = ASI_CRM_MY_TestClassHelper.createActualOfftakeHeader(customer1, today);
                
             
            // Create Actual Offtake 
            ASI_TH_CRM_Actual_Offtake__c Offtake_L = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku1, customerParent, today, 'INV01', 100);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L2 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku2, customerParent, today, 'INV02', 600);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L3 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku3, customerParent, today, 'INV03', 100);
            
            
            ASI_CRM_MY_CalculatedFOC_Schedule schCtl = new ASI_CRM_MY_CalculatedFOC_Schedule();
            schCtl.genFOC();
                
            ASI_CRM_MY_CalculatedPayment_Schedule payment_sch = new ASI_CRM_MY_CalculatedPayment_Schedule();
            payment_sch.genCalculatedPayment();
            
            ASI_CRM_MY_SKUGroupUpdate_Schedule skuGroupUpdate_sch = new ASI_CRM_MY_SKUGroupUpdate_Schedule();
            String sch = '0 0 * * * ?'; 
        	system.schedule('SKUGroupUpdateTest', sch, skuGroupUpdate_sch); 
            
            
            //ASI_CRM_MY_SKU_TriggerClass sku_triggerClass = new ASI_CRM_MY_SKU_TriggerClass();
            //sku_triggerClass.l_NewMappedSKU.add(sku1);
        }
    }
    
    
    static testMethod void payment_and_freeGoodRequest_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        
        Group gp2 = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        GroupMember Gm2 = new GroupMember();
        GM2.GroupId = gp2.id;
        GM2.UserOrGroupId = userA.Id;
        
        GMList.add(GM2);
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
        
            
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            
            integer y = today.year();
            integer m = today.month();
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
			
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                          	id, 
                                          	ASI_CRM_Terminate__c, 
                                          	ASI_CRM_Obsolete_Version__c, 
                                          	ASI_TH_CRM_End_Date__c, 
                                          	ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            //update con;
            
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            //update con;
            
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku3', productCategory);

            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            
            Date perviousDate = today.addMonths(-1);
            String strPY = String.valueOf(perviousDate.year());
            String strPM = String.valueOf(perviousDate.month());
            strPM = strPM.length() == 1 ? '0' + strPM : strPM;
            
			// create calculated foc header             
            ASI_CRM_Calculated_FOC__c foc = ASI_CRM_MY_TestClassHelper.createCalculatedFOC(customer1, con, strPY, strPM, userA);
            
            // create calculated foc line   
            ASI_CRM_Calculated_FOC_Line__c focLine = ASI_CRM_MY_TestClassHelper.createCalculatedFOCLine(foc, sku1);
            
            // create calculated payment 
            ASI_CRM_Calculated_Payment__c calPayment = ASI_CRM_MY_TestClassHelper.createCalculatedPayment(customer1, con, strPY, strPM, userA, 'Other Incentive');
            
            // create calculated payment line   
            ASI_CRM_Calculated_Payment_Item__c calPaymentLine = ASI_CRM_MY_TestClassHelper.createCalculatedPaymentLine(calPayment, sku1);
            
            Test.startTest();
    		ASI_CRM_MY_Contract_GenClaimRequest_Ctrl genClaimRequest = new ASI_CRM_MY_Contract_GenClaimRequest_Ctrl();
            genClaimRequest.getJSONContract();
            genClaimRequest.selectedFromYear = perviousDate.year();
            genClaimRequest.selectedToMonth = perviousDate.month();
            genClaimRequest.selectedToYear = perviousDate.year();
            genClaimRequest.selectedToMonth = perviousDate.month();
            genClaimRequest.contractId = con.Id;
            genClaimRequest.previewRelatedCalcRecords();
            
            genClaimRequest.genMonthly = true;
            genClaimRequest.selectedType = 'FOC';
            //genClaimRequest.proceedGeneration();
            genClaimRequest.genRequest();
            
            
            genClaimRequest.genMonthly = true;
            genClaimRequest.selectedType = 'Cash';
            genClaimRequest.genRequest();
            
            
            // create calculated foc header             
            foc = ASI_CRM_MY_TestClassHelper.createCalculatedFOC(customer1, con, strPY, strPM, userA);
            
            // create calculated foc line   
            focLine = ASI_CRM_MY_TestClassHelper.createCalculatedFOCLine(foc, sku1);
            
            // create calculated payment 
            calPayment = ASI_CRM_MY_TestClassHelper.createCalculatedPayment(customer1, con, strPY, strPM, userA, 'Other Incentive');
            
            // create calculated payment line   
            calPaymentLine = ASI_CRM_MY_TestClassHelper.createCalculatedPaymentLine(calPayment, sku1);
            
            
    		genClaimRequest = new ASI_CRM_MY_Contract_GenClaimRequest_Ctrl();
            genClaimRequest.getJSONContract();
            genClaimRequest.selectedFromYear = perviousDate.year();
            genClaimRequest.selectedToMonth = perviousDate.month();
            genClaimRequest.selectedToYear = perviousDate.year();
            genClaimRequest.selectedToMonth = perviousDate.month();
            genClaimRequest.contractId = con.Id;
            genClaimRequest.previewRelatedCalcRecords();
            
            genClaimRequest.genMonthly = false;
            genClaimRequest.selectedType = 'FOC';
            genClaimRequest.genRequest();
            
            
            genClaimRequest.genMonthly = false;
            genClaimRequest.selectedType = 'Cash';
            genClaimRequest.genRequest();
            Test.stopTest();
            
            ASI_TH_CRM_PaymentRequest__c paymentRequest = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c LIMIT 1];
            paymentRequest.ASI_TH_CRM_Status__c = 'Final';
            update paymentRequest;
            
           	
        } 
    }
    
    static testMethod void changeRequestStatusTEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        
        Group gp2 = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        GroupMember Gm2 = new GroupMember();
        GM2.GroupId = gp2.id;
        GM2.UserOrGroupId = userA.Id;
        
        GMList.add(GM2);
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
        
            
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            
            ASI_CRM_MY_Function.IsValidDate('2018/05/24');
            integer y = today.year();
            integer m = today.month();
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
			
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                          	id, 
                                          	ASI_CRM_Terminate__c, 
                                          	ASI_CRM_Obsolete_Version__c, 
                                          	ASI_TH_CRM_End_Date__c, 
                                          	ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            //update con;
            
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            //update con;
            
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku3', productCategory);

            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            
            Date perviousDate = today.addMonths(-1);
            String strPY = String.valueOf(perviousDate.year());
            String strPM = String.valueOf(perviousDate.month());
            strPM = strPM.length() == 1 ? '0' + strPM : strPM;
            
			// create calculated foc header             
            ASI_CRM_Calculated_FOC__c foc = ASI_CRM_MY_TestClassHelper.createCalculatedFOC(customer1, con, strPY, strPM, userA);
            
            // create calculated foc line   
            ASI_CRM_Calculated_FOC_Line__c focLine = ASI_CRM_MY_TestClassHelper.createCalculatedFOCLine(foc, sku1);
            
            // create calculated payment 
            ASI_CRM_Calculated_Payment__c calPayment = ASI_CRM_MY_TestClassHelper.createCalculatedPayment(customer1, con, strPY, strPM, userA, 'Other Incentive');
            
            // create calculated payment line   
            ASI_CRM_Calculated_Payment_Item__c calPaymentLine = ASI_CRM_MY_TestClassHelper.createCalculatedPaymentLine(calPayment, sku1);
            
            // Create Free Goods Request
            ASI_FOC_Free_Goods_Request__c fgr = ASI_CRM_MY_TestClassHelper.createFreeGoodsRequest(con, customer1, today);
            fgr.ASI_CRM_Status__c = 'Final';
            update fgr;  
            
            
            ApexPages.StandardController standardCtl = new ApexPages.StandardController(fgr);
            ApexPages.currentpage().getparameters().put('id', fgr.id);
            ASI_CRM_MY_FOCClaimsCtl controller = new ASI_CRM_MY_FOCClaimsCtl(standardCtl);
            controller.getFOCItem();
            
            
            // create payment request header
    		ASI_TH_CRM_PaymentRequest__c paymentRequest = ASI_CRM_MY_TestClassHelper.createPaymentRequest(con, customer1, today);
            paymentRequest.ASI_TH_CRM_Status__c = 'Final';
            update paymentRequest;
            
            ASI_TH_CRM_PaymentRequest__c paymentRequest2 = ASI_CRM_MY_TestClassHelper.createPaymentRequest(con, customer1, today);
            
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
            User u1 = new User(
            Alias = 'standt2', 
            Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='two.testing@introv.com');
            insert u1;
            
            customer1.OwnerId = u1.Id;
            update customer1;
            
        	delete paymentRequest2;
            
           	delete calPayment;
        } 
    }
		
	
    static testMethod void regenFOC_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        
        Group gp2 = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        GroupMember Gm2 = new GroupMember();
        GM2.GroupId = gp2.id;
        GM2.UserOrGroupId = userA.Id;
        
        GMList.add(GM2);
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
        
            
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
  
            
            integer y = today.year();
            integer m = today.month();
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
			
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                          	id, 
                                          	ASI_CRM_Terminate__c, 
                                          	ASI_CRM_Obsolete_Version__c, 
                                          	ASI_TH_CRM_End_Date__c, 
                                          	ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            //update con;
            
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            //update con;
            
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku3', productCategory);

            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            
            Date perviousDate = today.addMonths(-3);
            String strPY = String.valueOf(perviousDate.year());
            String strPM = String.valueOf(perviousDate.month());
            strPM = strPM.length() == 1 ? '0' + strPM : strPM;
            
            
            // Create Actual Offtake Header
            ASI_CRM_ActualOfftakeHeader__c Offtake_H = ASI_CRM_MY_TestClassHelper.createActualOfftakeHeader2(customer1, perviousDate);
            system.debug('@@@Offtake_H: '+Offtake_H);
            
            // Create Actual Offtake 
            ASI_TH_CRM_Actual_Offtake__c Offtake_L = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku1, customer1, perviousDate, 'INV01', 400);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L2 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku2, customer1, perviousDate, 'INV02', 100);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L3 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku3, customer1, perviousDate, 'INV03', 100);
            
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
            ASI_CRM_ContractTarget__c ct2 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku2, 100);
            ASI_CRM_ContractTarget__c ct3 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku3, 0);
            
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            ASI_CRM_ContractVolumeIncentive__c vi2 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku2);
            ASI_CRM_ContractVolumeIncentive__c vi3 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku3);
            
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            ASI_CRM_ContractSalesStaffIncentive__c  ss2 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku2);
            ASI_CRM_ContractSalesStaffIncentive__c  ss3 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku3);
            
             
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1);
            ASI_CRM_ContractOtherIncentive__c oi2 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku2);
            ASI_CRM_ContractOtherIncentive__c oi3 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku3);
            
            
            ASI_CRM_MY_FOCRegen_Ctl focRegrn = new ASI_CRM_MY_FOCRegen_Ctl();
            focRegrn.AOH1 = Offtake_H;
            system.debug('@@@strPY: '+strPY);
            system.debug('@@@strPM: '+strPM);
            focRegrn.strYear = strPY;
            focRegrn.strMonth = strPM;
            focRegrn.doChange();
            focRegrn.doRegenFOC();
            
            focRegrn.doUnlockCalculatePayment();
            focRegrn.doRegenCalculatedPayment();
            
            
        } 
    }

    
}