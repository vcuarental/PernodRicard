@isTest
private class EUR_CRM_WYSIWYGEditorControllerTest {

    @testSetup
    private static void init(){
        EUR_CRM_CTM_DigitalSignatureSettings__c setting = makeDigitalSignatureSettings();
        insert setting;
        System.assertNotEquals(null,setting.Id);

        List<Folder> folders = [SELECT Name FROM Folder WHERE Name=:setting.EUR_CRM_ObjectsToSign__c];
        System.assertNotEquals(0, folders.size());

        Document doc = makeDocument(folders[0].Id);
        insert doc;
        System.assertNotEquals(null,doc.Id);
    }

    @isTest
    private static void constructorTestEnableButtons(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();
        System.assertEquals(null, test.objFields);
    }

    @isTest
    private static void getMethodsTest(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();

        test.getParentToChildReferences();
        test.getChildObjectWithFields();
        test.getChildObjectWithDescribeFields();
        test.getChildObject();
        test.getTypesOperatorsMap();
        test.getClasters();
        EUR_CRM_WYSIWYGEditorController.splitSetting('1;2');

        List<SelectOption> docSo = test.getDocSO();
        System.assertNotEquals(0, docSo.size());

        List<SelectOption> folderSO = test.getFolderSO();
        System.assertNotEquals(0, folderSO.size());

        test.getDescription();
        System.assertEquals('', test.docName);

        Boolean disableButtons = test.getDisableButtons();
        System.assertEquals(false, disableButtons);

        test.back();
        System.assertEquals(false, test.isNewDoc);

        test.newDoc();
        System.assertEquals(true, test.isNewDoc);
    }

    @isTest
    private static void nextStepSelectTest(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();
        test.nextStepSelect();
    }

    @isTest
    private static void nextStepCreateTest(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();
        test.docName = 'qwe';
        test.nextStepCreate();
    }

    @isTest
    private static void save(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();
        test.docName = 'qwe';
        test.isNewDoc = true;
        test.textArea = 'test';
        EUR_CRM_CTM_DigitalSignatureSettings__c setting = EUR_CRM_CTM_DigitalSignatureSettings__c.getValues('EUR_CRM_Contract__c');
        test.chosenFolderNew = [SELECT Name FROM Folder WHERE Name=:setting.EUR_CRM_ObjectsToSign__c LIMIT 1].Id;
        test.save();
    }

    @isTest
    private static void nextStepCreateDocNameEmpty(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();
        test.docName = '';
        test.nextStepCreate();
    }

    @isTest
    private static void nextStepCreateDevNameEmpty(){
        EUR_CRM_WYSIWYGEditorController test = new EUR_CRM_WYSIWYGEditorController();
        test.docName = '111';
        test.nextStepCreate();
    }


    /*======================================================
    *  High Level Helpers
    * ======================================================*/
    private static void deleteDigitalSignatures(){
        delete [select Id from EUR_CRM_CTM_DigitalSignatureSettings__c];
    }

    /*======================================================
    *  Makers
    * ======================================================*/

    private static EUR_CRM_CTM_DigitalSignatureSettings__c makeDigitalSignatureSettings(){
        return new EUR_CRM_CTM_DigitalSignatureSettings__c(
            Name = 'EUR_CRM_Contract__c',
            EUR_CRM_ContractRelationToCall__c = 'none',
            EUR_CRM_Detailing__c = 'EUR_CRM_Contract_Product_Item__c, EUR_CRM_Contract_Activity_Item__c,EUR_CRM_GB_Volume_Tracker_Line_Item__c',
            EUR_CRM_EnvelopeId__c = 'none',
            EUR_CRM_ObjectsToSign__c = 'EUR_CRM_Contract__c',
            EUR_CRM_ObjectToSignFieldOnSign__c = 'EUR_CRM_Contract__c',
            EUR_CRM_Status__c = 'EUR_CRM_Status__c',
            EUR_CRM_ChildTableParentToChildRefFields__c = 'EUR_CRM_Contract__c,EUR_CRM_Contract__c,EUR_CRM_Contract__c',
            EUR_CRM_CountryCode__c = 'DE',
            EUR_CRM_Object__c = 'EUR_CRM_Contract__c'
        );
    }

    private static Document makeDocument(Id folderId){
        return new Document(
            Name = 'EUR_CRM_Contract__c',
            Body = Blob.valueOf('test'),
            FolderId = folderId,
            Type = 'html',
            Description = '{"countryCode":"DE"}'
        );
    }
}