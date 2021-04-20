/*********************************************************************************
    * Name: ASI_TnE_MassUploadCorpCardControllerTest
    * Description: Test Class for ASI_TnE_MassUploadCorpCardController.
    *
    * Version History
    * Date             Developer               Comments
    * ---------------  --------------------    --------------------------------------
    * 16/4/2015        Dandelo                  Created
*********************************************************************************/
@isTest
public class ASI_TnE_MassUploadCorpCardCont_TH_Test {
    public testMethod static void unitUploadGenerateThailand(){
        User cUserTH = ASI_TnE_TestClassHelper.createUser('uploadUserSG@testorg.com', 'Thailand');
        
        System.runAs(cUserTH){
            test.startTest();
                Account acc = ASI_TnE_TestClassHelper.createAccount('AccountASI_MFM_TR_Supplier');
                ASI_TnE_Corp_Card_Employee_Mapping__c empMapping1 = ASI_TnE_TestClassHelper.createEmployeeMapping('000-1110-1', '000-1110-2', null, null);
                empMapping1.ASI_TnE_Card_Issuer_1__c = acc.Id;
                empMapping1.ASI_TnE_Card_Issuer_2__c = acc.Id;
                update empMapping1;
                
                ASI_TnE_Corp_Card_Employee_Mapping__c empMapping2 = ASI_TnE_TestClassHelper.createEmployeeMapping('000-1110-3', '000-1110-4', null, null);
                empMapping2.ASI_TnE_Card_Issuer_1__c = acc.Id;
                empMapping2.ASI_TnE_Card_Issuer_2__c = acc.Id;
                update empMapping2;
                
                ASI_TnE_Corp_Card_MCC_Account_Mapping__c mccGroup = ASI_TnE_TestClassHelper.createMCCGroupMapping('RESTAURANT', 'ASI_TnE_Corp_Card_MCC_Account_Mapping__cASI_TnE_SG_Corp_Card_Merchant_Category_Account_Mapping');
                
                Date sDate1 = date.parse('12/12/2000');
                ASI_TnE_Corp_Card_Statement_Upload__c statement1 = ASI_TnE_TestClassHelper.createStatement('000-1110-1', sDate1);
                ASI_TnE_Corp_Card_Statement_Upload__c statement2 = ASI_TnE_TestClassHelper.createStatement('000-1110-2', sDate1);
                ASI_TnE_Corp_Card_Statement_Upload__c statement3 = ASI_TnE_TestClassHelper.createStatement('000-1110-3', sDate1);
                
                ASI_HK_CRM_Running_Number__c runnNumberHeader = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Header', 
                                                                                   ASI_HK_CRM_Format__c = '{YY}{MM}{000}',
                                                                                   ASI_HK_CRM_Running_Number__c = 100);
                insert runnNumberHeader;
                
                ASI_TnE_ClaimHeader__c cHeader1 = ASI_TnE_TestClassHelper.createTestClaimHeader('000-1110-4~' + String.valueOf(date.today()), 'ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');

                
                ASI_TnE_MassUploadCorpCardController cls = new ASI_TnE_MassUploadCorpCardController();
                cls.ObjAPIName = 'ASI_TnE_Corp_Card_Statement_Upload__c';
                cls.fields = 'ASI_TnE_Control_Account_Name__c,ASI_TnE_Charge_Date__c,ASI_TnE_Statement_Date__c,ASI_TnE_Full_Name__c,ASI_TnE_Card_Number__c,ASI_TnE_Supplier_Name__c,ASI_TnE_Transaction_Description__c,ASI_TnE_MCC_Group__c,ASI_TnE_Amount__c';
                cls.fieldsLabel = 'Control Account Name,Charge Date,Statement Date,Full Name,Card Number,Supplier Name,Transaction Description,MCC Group,Amount';
                cls.template = 'ASI_TnE_CorpCard_Template';
                cls.report = '';
                cls.opt_allOrNone = true;
                cls.currentPageURL = '';
                cls.inlineVF = true;
                cls.defaultValues = '';
                cls.recEXIDcol = 'Id';
                cls.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
                cls.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
                cls.upsertmode = true;
                cls.batchMode = true;
                cls.emailNotification = true;
                cls.parentID = null;
                cls.parentField = null;
                cls.lookupEXID = null;
                cls.reloadNeeded = false;
                cls.recEXID = null;
                cls.objName = '';
                cls.nameFile = 'test.csv';
                cls.contentFile = blob.valueOf('Control Account Name,Charge Date,Statement Date,Full Name,Card Number,Supplier Name,Transaction Description,MCC Group,Amount\rControl Account Name,2015/0404,2015-04-04,Full Name,000-1110-2,Supplier Name,Transaction Description,RESTAURANT,err\rControl Account Name,2015-04-04,,Full Name,,Supplier Name,Transaction Description,RESTAURANT,');
                cls.fileSize = 2000;
                cls.currentPageURLOutput = '';
                cls.hasError = false;
                cls.msgGenerateTnEEmail = '';
                
                cls.getItems();
                cls.uploadCSVByBatch();
                List<String> sm = cls.StatusMsgs;
                
                //cls.generateTnERecords();
            test.stopTest();
            
            System.assertEquals(cUserTH.Id, Userinfo.getUserId());
            System.assertEquals(cls.country, 'THA');
            System.assertNotEquals(cls.BatchId, null);
        }
    }
}