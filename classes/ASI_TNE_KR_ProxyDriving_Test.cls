@isTest
public class ASI_TNE_KR_ProxyDriving_Test {

    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                                         ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
                                                                          ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                                         ASI_eForm_Employee_Work_Email__c='123.345@email.com', ASI_eForm_Employee_Eligible_PD__c = true);

    private static Profile tempP = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    
    Private static User tempU = [select id, Name, ASI_KOR_Commission_Code__c, ProfileId from user where id = :userInfo.getUserId()];
    private static User tempU2 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666@testorg.com', ASI_KOR_Commission_Code__c='1234567', ManagerId = tempU.id,
                                          CompanyName = 'testUserCompanyName', Country = 'Korea');

    
    //Private static ASI_TnE_Proxy_Driving_Detail__c tempPDItem = new ASI_TnE_Proxy_Driving_Detail__c();
    

    static testMethod void testTriggerClassAndPDFController(){
        
        insert tempU2;
        insert tempMDM;
        
        List<ASI_TnE_KR_proxyBrand__c> settings = new List<ASI_TnE_KR_proxyBrand__c>();
        settings.add(new ASI_TnE_KR_proxyBrand__c(ASI_TnE_KR_proxyBrandCode__c ='BA4',name ='222-PRK',ASI_TnE_KR_CompanyCode__c ='222'));
    	settings.add(new ASI_TnE_KR_proxyBrand__c(ASI_TnE_KR_proxyBrandCode__c ='BA4',name ='286-PRKI',ASI_TnE_KR_CompanyCode__c ='286'));
        insert settings;
        
        Test.startTest();
        
        ASI_TnE_KR_ProxyDrivingTransaction__c tmpPDT = new ASI_TnE_KR_ProxyDrivingTransaction__c(ASI_TnE_KR_MDM_Employee_No__c = tempMDM.Id,
                                                                                                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_KR_ProxyDrivingTransaction__cASI_TnE_KR_PD_Transaction'));
        insert tmpPDT;
        
        ASI_TnE_Proxy_Driving_Request__c tmpPD = new ASI_TnE_Proxy_Driving_Request__c(OwnerId = tempU2.id,
                                                                                      ASI_TnE_Requester_ID__c ='1234567'
                                                                                      , recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Proxy_Driving_Request__cASI_TnE_KR_Proxy_Driving_Request')
                                                                                      , ASI_TnE_Currency__c = 'KRW'
                                                                                      , ASI_TnE_KR_PD_Status__c= 'Draft'
                                                                                      , ASI_TnE_Proxy_Agency_Code__c = '12345'
                                                                                     );
        insert tmpPD;
        update tmpPD;
        
        ASI_TnE_Proxy_Driving_Detail__c tmpPDitem = new ASI_TnE_Proxy_Driving_Detail__c(ASI_TnE_Proxy_Driving_Request__c = tmpPD.id
                                                                                        , ASI_TnE_Date__c = date.today()
                                                                                        , ASI_TnE_Phone_No__c = '1234567'
                                                                                        , ASI_TnE_Departure_Place__c = 'test'
                                                                                        , ASI_TnE_Departure_Time__c = '20:00:00'
                                                                                        , ASI_TnE_First_Dest__c = 'test'
                                                                                        , ASI_TnE_Destination_Place__c = 'test'
                                                                                        , ASI_TnE_Destination_Time__c = 'test'
                                                                                        , ASI_TnE_Amount__c = 12345
                                                                                        , ASI_TnE_Usage__c = 'Employee Only'
                                                                                       );
        
        
        insert tmpPDItem;
        
        Test.setCurrentPage(Page.ASI_TnE_KR_ProxyDriving_PDFPage);
        Apexpages.currentPage().getParameters().put('id', tmpPD.id);
        Apexpages.standardController sc1 = new apexpages.standardController(tmpPD);
        //PDFController
        ASI_TnE_KR_ProxyDriving_PDFController cx1 = new ASI_TnE_KR_ProxyDriving_PDFController(sc1);
        cx1.currentHeaderID = tmpPD.id;
        cx1.getHeader();
        cx1.getDetails();
        //ClaimHeaderController
        ASI_TnE_KR_PD_ClaimHeaderController cx = new ASI_TnE_KR_PD_ClaimHeaderController(sc1);
        
        cx.thisController = cx;
        cx.dynamicAttributeFieldsPixels = 'trigger';
        
        String language = cx.getUserLanguage();

        List<ASI_TnE_KR_MassCreateAndUpdateController.PageBlockActionBtn> tempObj1 = cx.mcau_initPageBlockActionButtonList();

        ASI_TnE_KR_MassCreateAndUpdateController tempCon1 = new ASI_TnE_KR_MassCreateAndUpdateController();

        String tempKey1 = 'A';
        sObject tempSO = new ASI_TnE_Proxy_Driving_Request__c();
        
		PageReference tempObj2 = cx.mcau_triggerPageBlockAction(tempCon1, tempKey1);
        cx.mcau_triggerActionForSObject(tempCon1,tempKey1,tempSO);
        
        String tempKey2 = 'DEFAULT';
        
        ASI_TnE_ComponentInterface tempObj4 = cx.getComponentController();
        ASI_TnE_ComponentInterface tempObj5 = cx.getComponentController(tempKey2);
        cx.setComponentController(tempObj4);
        cx.setComponentController(tempKey2,tempObj4);
        
        Test.stopTest();
    }
    
    static testMethod void testUploadController(){
        
        
        tempU.country='korea';
        update tempU;
        
        insert tempU2;
        insert tempMDM;
        
        List<ASI_TnE_KR_proxyBrand__c> settings = new List<ASI_TnE_KR_proxyBrand__c>();
        settings.add(new ASI_TnE_KR_proxyBrand__c(ASI_TnE_KR_proxyBrandCode__c ='BA4',name ='222-PRK',ASI_TnE_KR_CompanyCode__c ='222'));
    	settings.add(new ASI_TnE_KR_proxyBrand__c(ASI_TnE_KR_proxyBrandCode__c ='BA4',name ='286-PRKI',ASI_TnE_KR_CompanyCode__c ='286'));
        insert settings;
        
        ASI_TnE_KR_ProxyDrivingTransaction__c tmpPDT = new ASI_TnE_KR_ProxyDrivingTransaction__c(ASI_TnE_KR_MDM_Employee_No__c = tempMDM.Id,
                                                                                                 recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_KR_ProxyDrivingTransaction__cASI_TnE_KR_PD_Transaction'));
        insert tmpPDT;
        
        ASI_TnE_Proxy_Driving_Request__c tmpPD = new ASI_TnE_Proxy_Driving_Request__c(OwnerId = tempU2.id,
                                                                                      ASI_TnE_Requester_ID__c ='1234567'
                                                                                      , recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Proxy_Driving_Request__cASI_TnE_KR_Proxy_Driving_Request')
                                                                                      , ASI_TnE_Currency__c = 'KRW'
                                                                                      , ASI_TnE_KR_PD_Status__c= 'Draft'
                                                                                      , ASI_TnE_Proxy_Agency_Code__c = '12345'
                                                                                      , ASI_TnE_KR_PD_External_ID__c = '123~1234#12345'
                                                                                     );
        insert tmpPD;
        
        List<ASI_TnE_ProxyDriving_Statement_Upload__c> tmpInTrayObj = new List<ASI_TnE_ProxyDriving_Statement_Upload__c>(); 
        
        tmpInTrayObj.add(new ASI_TnE_ProxyDriving_Statement_Upload__c(OwnerId = tempU.Id,
                                                                      Name = 'Test',
                                                                      ASI_TnE_KR_Employee_No__c = '1234567',
                                                                      ASI_TnE_KR_First_Dest__c = 'test',
                                                                      ASI_TnE_KR_Amount__c = 10000,
                                                                      ASI_TnE_KR_Departure_Place__c = 'test',
                                                                      ASI_TnE_KR_Departure_Time__c = '20:00:00',
                                                                      ASI_TnE_KR_Destination_Place__c = 'test',
                                                                      ASI_TnE_KR_Destination_Time__c = 'test',
                                                                      ASI_TnE_KR_Month__c = '05',
                                                                      ASI_TnE_KR_Phone_No__c = '123123',
                                                                      ASI_TnE_KR_Proxy_Agency_Code__c = '12345',
                                                                      ASI_TnE_KR_Statement_Date__c = date.today(),
                                                                      ASI_TnE_KR_UsageDate__c = date.today()-50,
                                                                      ASI_TnE_KR_Year__c =2015
                                                                     ));
        
        tmpInTrayObj.add(new ASI_TnE_ProxyDriving_Statement_Upload__c(OwnerId = tempU.Id,
                                                                      Name = 'Test',
                                                                      ASI_TnE_KR_Employee_No__c = '1234333',
                                                                      ASI_TnE_KR_First_Dest__c = 'test',
                                                                      ASI_TnE_KR_Amount__c = 10000,
                                                                      ASI_TnE_KR_Departure_Place__c = 'test',
                                                                      ASI_TnE_KR_Departure_Time__c = '20:00:00',
                                                                      ASI_TnE_KR_Destination_Place__c = 'test',
                                                                      ASI_TnE_KR_Destination_Time__c = 'test',
                                                                      ASI_TnE_KR_Month__c = '05',
                                                                      ASI_TnE_KR_Phone_No__c = '123123',
                                                                      ASI_TnE_KR_Proxy_Agency_Code__c = '12345',
                                                                      ASI_TnE_KR_Statement_Date__c = date.today(),
                                                                      ASI_TnE_KR_UsageDate__c = date.today()-50,
                                                                      ASI_TnE_KR_Year__c =2015
                                                                     ));
        
        ASI_TnE_Branch_Channel__c tmpBC = new ASI_TnE_Branch_Channel__c(OwnerID = tempU.id
                                                                        , Name = 'abc'
                                                                        , ASI_TnE_Branch_Channel_Desc__c = '1234'
                                                                        , ASI_TnE_Branch_Default__c = false
                                                                       ); 
        insert tmpBC;
        
        test.startTest();
        
        insert tmpInTrayObj[0];
        
        ASI_TnE_KR_ProxyDriving_UploadController tmpClass = new ASI_TnE_KR_ProxyDriving_UploadController();
        
        tmpClass.ObjAPIName = 'ASI_TnE_ProxyDriving_Statement_Upload__c';
        tmpClass.fields = 'ASI_TnE_KR_Year__c,ASI_TnE_KR_Month__c,ASI_TnE_KR_Proxy_Agency_Code__c,ASI_TnE_KR_UsageDate__c,ASI_TnE_KR_Employee_No__c,ASI_TnE_KR_Phone_No__c,ASI_TnE_KR_Departure_Place__c,ASI_TnE_KR_Departure_Time__c,ASI_TnE_KR_First_Dest__c,ASI_TnE_KR_Destination_Place__c,ASI_TnE_KR_Destination_Time__c,ASI_TnE_KR_Amount__c';
		tmpClass.fieldsLabel = 'Year,Month,Proxy Agency Code,Date,Employee No,Phone No,Departure Place,Departure Time,1st Destination,Destination Place,Destination Time,Amount';
        tmpClass.template = 'ASI_TnE_KR_Proxy_Driving_Header_Template';
        tmpClass.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
        tmpClass.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
        tmpClass.recEXID = 'Id';
        tmpClass.recEXIDcol = 'Id';
        tmpClass.upsertMode = true;
        tmpClass.batchMode = true;
        tmpClass.report = '';
        tmpClass.lookupEXID = '';
        tmpClass.DefaultValues = 'ASI_TnE_KR_Year__c:2015';
        tmpClass.opt_allOrNone = true;
        tmpClass.currentPageURL = '';
        tmpClass.inlineVF = true;
        tmpClass.emailNotification = true;
        tmpClass.namefile = '2015-05-05.csv';
        tmpClass.filesize = 2000;
        tmpClass.contentFile = blob.valueOf('Year,Month,Proxy Agency Code,Date,Employee No,Phone No,Departure Place,Departure Time,1st Destination,Destination Place,Destination Time,Amount\r2015,05,12345,2015-04-21,1234567,18888688,test,20:00:00,test,test,21:00:00,10000');
            
        tmpClass.uploadCSVByBatch();
        tmpClass.generateTnERecords();
        tmpClass.deleteCorpCardStatements();
        tmpClass.refreshPage2();
        tmpClass.getItems();
        
        insert tmpIntrayObj[1];
        tmpClass.generateTnERecords();
        
        tmpClass.contentFile = blob.valueOf('Year,Month,Proxy Agency Code,Date,Employee No,Phone No,Departure Place,Departure Time,1st Destination,Destination Place,Destination Time,Amount\r');
        tmpClass.uploadCSVByBatch();
        
        tmpClass.contentFile = blob.valueOf('Year,Month,Proxy Agency Code,Date,Employee No,Phone No,Departure Place,Departure Time,1st Destination,Destination Place,Destination Time,Amount\r20111115,05,12345,2015-04-21,1234567,18888688,test,20:00:00,test,test,21:00:00,10000');
        tmpClass.uploadCSVByBatch();
        
        //tmpClass.lookupEXID = 'ASI_TnE_ClaimHeader__c/ASI_TnE_ClaimHeader__c:External ID&ASI_TnE_KR_External_ID__c';
        //tmpClass.uploadCSVByBatch();
        
        tmpClass.fields = 'ASI_TnE_KR_Month__c,ASI_TnE_KR_Proxy_Agency_Code__c,ASI_TnE_KR_UsageDate__c,ASI_TnE_KR_Employee_No__c,ASI_TnE_KR_Phone_No__c,ASI_TnE_KR_Departure_Place__c,ASI_TnE_KR_Departure_Time__c,ASI_TnE_KR_First_Dest__c,ASI_TnE_KR_Destination_Place__c,ASI_TnE_KR_Destination_Time__c,ASI_TnE_KR_Amount__c';
		tmpClass.uploadCSVByBatch();
        
        tmpClass.ObjAPIName = 'ASI_TnE_ClaimDetail__c';
        tmpClass.lookupEXID = 'ASI_TnE_Branch_Channel__c/ASI_TnE_Branch_code_Channel__c:Branch-Channel Code&Name';
        tmpClass.fields = 'ASI_TnE_Dispute__c,ASI_TnE_Branch_code_Channel__c';
        tmpClass.fieldsLabel = 'Year,BC';
        tmpClass.contentFile = blob.valueOf('Year,BC\ry,abc');
        tmpClass.uploadCSVByBatch();
        
        test.stopTest();
    }
}