@isTest
private class ASI_CRM_HK_PAFExpireListTest {
	static testMethod void ASI_CRM_HK_PAFPLInfoEditCtrltest(){
		ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
		
		list<Account> accList = new list<Account>{};
		Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');   
        acctCredit.recordTypeId = ASI_HK_CRM_AccountGenerator.getRecordTypeByDevName(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT).id;
        accList.add(acctCredit);
        Insert accList;
		
		ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generateBasicPreApprovalForm(accList[0]); 
		insert paf;
		
		test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(paf);
        ASI_CRM_HK_PAFPLInfoEditCtrl editController = new ASI_CRM_HK_PAFPLInfoEditCtrl(sc);
        editController.saveRecord();
        test.stopTest();
	}
	
    static testMethod void ASI_CRM_HK_PAFExpireListTest(){      
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        list<ASI_HK_CRM_Pre_Approval_Form__c> testDataList = new list<ASI_HK_CRM_Pre_Approval_Form__c>{};
        list<Account> accList = new list<Account>{};
        Date today = system.today();
        Date dateOffset = today.addDays(7);
        List<id> typeId = new List<id>{Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form'),Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form_Date_Adjustment'),Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form_Read_Only')};
        
        String[] status = new String[]{'Confirmed with Customer','FD Approved','FM Approved','MD Final'};
            
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');   
        acctCredit.recordTypeId = ASI_HK_CRM_AccountGenerator.getRecordTypeByDevName(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT).id;
        accList.add(acctCredit);
        Insert accList;
        
        for(integer i=1;i<35;i++){
            ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generateBasicPreApprovalForm(accList[0]); 
            paf.ASI_HK_CRM_PAF_Nature_of_Promotion__c = 'This record is used for testing';
            paf.RecordTypeId = typeId[0];
            paf.ASI_HK_CRM_PAF_End_Date__c = today.addDays(i/3);
            paf.ASI_HK_CRM_PAF_Status__c = 'Confirmed with Customer';
            testDataList.add(paf);
        }
        Insert testDataList;
        
        integer expected_total_size = [select count() from ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_HK_CRM_Expiry_Date__c >= :today AND ASI_HK_CRM_Expiry_Date__c < :dateOffset AND ASI_HK_CRM_PAF_Status__c LIKE :status AND recordTypeid = :typeId];
        integer expected_total_pages = (math.mod(expected_total_size, 15) > 0?expected_total_size/15 + 1:expected_total_size/15);
        
        Test.startTest();
        ASI_CRM_HK_PAFExpireListController testController = new ASI_CRM_HK_PAFExpireListController();
        ASI_CRM_HK_PAFExpireListController.PafList pafWeekList = testController.getPafWeekList();
        ASI_CRM_HK_PAFExpireListController.PafList pafMonthList = testController.getPafMonthList();
        list<ASI_HK_CRM_Pre_Approval_Form__c> pafWeekRecords = pafWeekList.pafRecords;
        list<ASI_HK_CRM_Pre_Approval_Form__c> pafMonthRecords = pafMonthList.pafRecords;
        system.assertEquals(True, pafWeekRecords.size()<=15);
        system.assertEquals(True, pafMonthRecords.size()<=15);
        
        system.assertEquals(expected_total_size, pafWeekList.getTotal_size());
        system.assertEquals(expected_total_pages, pafWeekList.getTotalPages());
        
        
        for(ASI_HK_CRM_Pre_Approval_Form__c pafForm : pafWeekRecords){
            system.assertEquals(True, pafForm.ASI_HK_CRM_Expiry_Date__c >= today && pafForm.ASI_HK_CRM_Expiry_Date__c < today.addDays(30));
        }
        for(ASI_HK_CRM_Pre_Approval_Form__c pafForm : pafMonthRecords){
            system.assertEquals(True, pafForm.ASI_HK_CRM_Expiry_Date__c >= today && pafForm.ASI_HK_CRM_Expiry_Date__c < today.addDays(30));
        }
        system.assertEquals(false, pafMonthList.getDisableNext());
        pafMonthList.End();
        system.assertEquals(True, pafMonthList.getPageNumber()==pafMonthList.getTotalPages());
        pafMonthList.Previous();
        system.assertEquals(True, pafMonthList.getPageNumber()==pafMonthList.getTotalPages()-1);
        system.assertEquals(false, pafMonthList.getDisablePrevious());
        pafMonthList.Beginning();
        system.assertEquals(True, pafMonthList.getPageNumber()==1);
        pafMonthList.Next();
        system.assertEquals(True, pafMonthList.getPageNumber()==2);
        
        Test.stopTest(); 
    }
}