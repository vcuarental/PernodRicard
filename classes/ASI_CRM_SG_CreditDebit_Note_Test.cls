/*********************************************************************************
 * Name: ASI_CRM_SG_CreditDebit_Note_Test
 * Description: Test Class for ASI_CRM_SG_ManualCNoteController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 02/03/2018       Wilken Lee              Created          
*/
@isTest
public class ASI_CRM_SG_CreditDebit_Note_Test {    
    @TestSetup
    public static void setupData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
		
		ASI_CRM_AccountsAdditionalField__c manualCNoteCustomer = new ASI_CRM_AccountsAdditionalField__c (
                                                                    name = 'Manual CNote Customer',
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Customer'),
                                                                    ASI_CRM_MY_CustomerCode__c = '123test',
																	ASI_CRM_SG_Tax_Rate_Area__c = 'SG3'
                                                              );
		insert manualCNoteCustomer;
		
		ASI_CRM_Credit_Debit_Note__c cNote = new ASI_CRM_Credit_Debit_Note__c(
												ASI_CRM_Reason__c = 'Manual Credit Note',
												recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Manual_Credit_Note'),
												ASI_CRM_GL_Date__c = System.Today(),
												ASI_CRM_Currency__c = 'USD',
												ASI_CRM_Status__c = 'Draft',
												ASI_CRM_Wholesaler__c = manualCNoteCustomer.Id);
		insert cNote;
		
		ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c = 1.5, ASI_MFM_Counter_Currency__c = 'USD', ASI_MFM_Country__c = 'SG', ASI_MFM_Effective_Date__c = System.Today(),
																	ASI_MFM_Application__c = 'MFM', ASI_MFM_Base_Currency__c = 'SGD');
		insert ex;
	}
	
    public static testMethod void test_ASI_CRM_SG_ManualCNoteController() {
		ASI_CRM_Credit_Debit_Note__c cNote = [select Id, Name, ASI_CRM_GL_Date__c, ASI_CRM_Wholesaler__c from  ASI_CRM_Credit_Debit_Note__c where ASI_CRM_Reason__c = 'Manual Credit Note' LIMIT 1];
		
		cNote.ASI_CRM_GL_Date__c = System.Today() + 1;
		cNote.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Manual_Credit_Note_Read_Only');
		cNote.ASI_CRM_Status__c = 'Approved';
		
		//Test Update Validation Error
		try {
			update cNote;
		}
		catch (Exception e){
		}
        
        PageReference pageRef = Page.ASI_CRM_SG_ManualCNoteManageAll;
        Test.setCurrentPage(pageRef);
        
		List<ASI_CRM_Credit_Debit_Note_Line_Item__c> lineList = new List<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
		
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(lineList);
		ApexPages.currentPage().getParameters().put('id', cNote.id);
        ASI_CRM_SG_ManualCNoteController controller = new ASI_CRM_SG_ManualCNoteController(stdController);
		
		//Test Delete validation Error
		try {
			delete cNote;
		}
		catch (Exception e){
		}		
    }
	
	public static testMethod void test_ASI_MFM_MassCreateAndUpdateController() { 
		ASI_CRM_Credit_Debit_Note__c cNote = [select Id, Name, ASI_CRM_GL_Date__c, ASI_CRM_Wholesaler__c from  ASI_CRM_Credit_Debit_Note__c where ASI_CRM_Reason__c = 'Manual Credit Note' LIMIT 1];		
        
		ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
		PageReference testPage = Page.ASI_CRM_SG_ManualCNoteManageAll;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', cNote.Id);
		Test.setCurrentPageReference(testPage);
		
        // Assign component attributes
		mcauCon.fieldToURLParamStr = 'ASI_CRM_Credit_Debit_Note__c=>id';
		mcauCon.displayFieldsStr = 'ASI_CRM_A_C_Code__c&req=T&width=350px,ASI_CRM_Sub_brand__c&req=F&width=350px,ASI_CRM_Actual_Amount__c&req=T&width=100px';
		mcauCon.whereStatm = 'ASI_CRM_Credit_Debit_Note__c = \'' + cNote.Id + '\'';
		mcauCon.pageBlockTitleStr= 'Credit/Debit Note Line Items';
		mcauCon.successLink = '/' + cNote.Id;
        mcauCon.cancelLink = '/' + cNote.Id;
		mcauCon.mode = 'BOTH';
		mcauCon.lookupToPicklist = 'ASI_CRM_A_C_Code__c,ASI_CRM_Sub_brand__c';
		
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_CRM_Credit_Debit_Note_Line_Item__c';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.isUseFirstRowForNew = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        //Boolean initPageBool = mcauCon.dummyVar;
        
        // Start testing user actions
        pageParams.put(mcauCon.PARAM_RTID, 'ASI_CRM_Credit_Debit_Note_Line_Item__c');
       
	   mcauCon.init();
    }
}