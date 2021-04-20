@isTest(seeAllData=true)
    private class ASI_TnE_ClaimHeaderTest {
        static testMethod void test_ClaimHeaderTriggerClass() {
                User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
                u.ASI_TnE_Department_Code__c = 'ABC';
                u.ASI_TnE_Monthly_Allowance__c = 100000;
                u.ASI_TnE_Sub_Ledger__c  = 'ABC';

    //Prepare Account Mapping
                List<ASI_TnE_Account_Mapping__c> accMapList = new List<ASI_TnE_Account_Mapping__c>();
                ASI_TnE_Account_Mapping__c accMap1 = new ASI_TnE_Account_Mapping__c(ASI_TnE_Account_Number__c = 'ABC', ASI_TnE_Country__c = 'VN', ASI_TnE_Expense_Type__c = 'Hotel');            
                ASI_TnE_Account_Mapping__c accMap2 = new ASI_TnE_Account_Mapping__c(ASI_TnE_Account_Number__c = 'ABC', ASI_TnE_Country__c = 'VN', ASI_TnE_Expense_Type__c = 'Hotel');            
                accMapList.add(accMap1);
                accMapList.add(accMap2);
                insert accMapList;
                
                Test.startTest();
                
                ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_VN_ClaimHeader'));
                insert header;
                
                List<ASI_TnE_ClaimDetail__c> detailList = new List<ASI_TnE_ClaimDetail__c>();
                ASI_TnE_ClaimDetail__c detail1 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'));
                ASI_TnE_ClaimDetail__c detail2 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = true, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Local Ent', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'));
                ASI_TnE_ClaimDetail__c detail3 = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = true, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Wrong Expense Type Test', recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'));
                
                detailList.add(detail1);
                detailList.add(detail2);
                detailList.add(detail3);
                insert detailList;
                
                Test.stoptest();
        }
          
        static testMethod void test_Controllers() {
                User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
                
                System.runAs(u) {
                    List<Group> groups = [select id from Group where DeveloperName = 'ASI_TnE_VN_Finance_Review_User'];
                    
                    if (groups.size() == 1){
                        GroupMember faGroupMember = new GroupMember(GroupId = groups.get(0).id, UserOrGroupId =     userInfo.getUserId());
                        insert faGroupMember;
                    }
                }
                
                ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_VN_ClaimHeader'));
                insert header;
                
                ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, 
                recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'), ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel');
                insert detail;          
                
                Test.startTest();

    //Test ClaimHeaderController            
                ApexPages.standardController controller = new ApexPages.standardController(header);
                ASI_TnE_ClaimHeaderController extension = new ASI_TnE_ClaimHeaderController (controller);
                
    //Test ClaimHeaderPDFController
                ASI_TnE_ClaimHeaderPDFController extension2 = new ASI_TnE_ClaimHeaderPDFController(controller);
                
    //Test MonthlyAllowanceController
                ASI_TnE_MonthlyAllowanceController extension3 = new ASI_TnE_MonthlyAllowanceController(controller);
                
                Test.stoptest();
        }
        
        static testMethod void test_FieldHistoryComponentController() {
             User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
                
                System.runAs(u) {
                    List<Group> groups = [select id from Group where DeveloperName = 'ASI_TnE_VN_Finance_Review_User'];
                    
                    if (groups.size() == 1){
                        GroupMember faGroupMember = new GroupMember(GroupId = groups.get(0).id, UserOrGroupId = userInfo.getUserId());
                        insert faGroupMember;
                    }
                }
                
                ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_VN_ClaimHeader'), ASI_TnE_Purpose_of_Travel__c = 'TestABC');
                insert header;
            
                List<ASI_TnE_ClaimHeader__History> headerHistoryList = new List<ASI_TnE_ClaimHeader__History>();
                ASI_TnE_ClaimHeader__History headerHistory = new ASI_TnE_ClaimHeader__History (ParentID = header.id, Field = 'ASI_TnE_Purpose_of_Travel__c');
                headerHistoryList.add(headerHistory);
                
                ASI_TnE_ClaimHeader__History headerHistory2 = new ASI_TnE_ClaimHeader__History (ParentID = header.id, Field = 'created');
                headerHistoryList.add(headerHistory2);
                
                insert headerHistoryList;
                
                ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, 
                recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'), ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel');
                insert detail;          
                
                List<ASI_TnE_ClaimDetail__History> detailHistoryList = new List<ASI_TnE_ClaimDetail__History>();
                ASI_TnE_ClaimDetail__History detailHistory1 = new ASI_TnE_ClaimDetail__History(ParentID = detail.id, Field = 'ASI_TnE_Amount__c');
                detailHistoryList.add(detailHistory1);
                
                ASI_TnE_ClaimDetail__History detailHistory2 = new ASI_TnE_ClaimDetail__History(ParentID = detail.id, Field = 'created');
                detailHistoryList.add(detailHistory2);
                
                insert detailHistoryList;
            
                Test.startTest();
                
    //Test FieldHistoryComponentController          
                ASI_TnE_FieldHistoryComponentController historyController = new ASI_TnE_FieldHistoryComponentController();
                historyController.recordLimit = 50;
                historyController.myObject = header;
                historyController.childObjectName = 'ASI_TnE_ClaimDetail__c';
                historyController.parentObjLookupName = 'ASI_TnE_ClaimHeader__c';
                
                string objectLabel = ASI_TnE_FieldHistoryComponentController.objectLabel;
                
                LIST<ASI_TnE_FieldHistoryComponentController.objectHistoryLine> historyLines = historyController.getObjectHistory();
                
                Test.stoptest();
        }
        
        static testMethod void test_MassCreateAndUpdateController() {
            User u = [select userRole.developerName, ASI_TnE_Department_Code__c, ASI_TnE_Monthly_Allowance__c, ASI_TnE_Sub_Ledger__c from user where id = :userInfo.getUserId()];
            ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(ownerID = u.id, recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_VN_ClaimHeader'));
            insert header;
            
            ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'), ASI_TnE_ClaimHeader__c = header.id, ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel');
            insert detail;        
            
            Test.startTest();
            
            ApexPages.standardController controller = new ApexPages.standardController(header);
            
            // Initialize the page
            PageReference testPage = Page.ASI_TnE_MassUpdateClaimDetailPage;
            Map<String, String> pageParams = testPage.getParameters();
            pageParams.put('id', header.Id);
            Test.setCurrentPageReference(testPage);
            ASI_TnE_ClaimHeaderController testCon = new ASI_TnE_ClaimHeaderController(controller);
            ASI_TnE_MassCreateAndUpdateController massCreateCon = new ASI_TnE_MassCreateAndUpdateController();

             // Assign component attributes
            massCreateCon.isFastModeBool = false;
            massCreateCon.sObjTypeStr = 'ASI_TnE_ClaimDetail__c';
            massCreateCon.displayFieldsStr = 'ASI_TnE_Date__c&req=T&width=80px&read=a, ASI_TnE_Destination__c&req=T&width=100px&read=a, ASI_TnE_Description__c&req=T&width=200px&read=a,                        ASI_TnE_Details_of_Expense__c&req=T&width=150px&read=a, ASI_TnE_Expense_Type__c&req=T&width=100px&read=a,ASI_TnE_Total_Number_Pax__c&req=T&width=30px&read=a, ASI_TnE_Exchange_Rate_to_VND__c&req=T&width=60px&read=a, ASI_TnE_Currency__c&req=T&width=70px&read=a, ASI_TnE_VAT__c&req=F&width=20px&read=a, ASI_TnE_Amount__c&req=T&width=100px&read=a,ASI_TnE_Total_Expense__c&req=F&width=100px&read=a';                 
            
            massCreateCon.fieldToURLParamStr = 'ASI_TnE_ClaimHeader__c=>id';
            massCreateCon.whereStatm = 'ASI_TnE_ClaimHeader__c = \'' + header.Id + '\'';
            massCreateCon.pageBlockTitleStr = '';
            massCreateCon.successLink = '/{!$CurrentPage.parameters.id}';
            massCreateCon.cancelLink = '/{!$CurrentPage.parameters.id}';
            massCreateCon.mode = 'BOTH';
            massCreateCon.isDefaultEditVal = true;
            massCreateCon.ShowAllRT = true;
            massCreateCon.isUseFirstRowForNew = true;
            massCreateCon.ComponentKey = 'massCreateAndUpdate';
            massCreateCon.PageController = testCon.thisController;
            massCreateCon.lookupToPicklist = 'ASI_TnE_Expense_Category__c'; //20180504 Introv changed from ASI_TnE_ClaimHeader__c to ASI_TnE_Expense_Category__c to fix too many query rows issue
            
            Boolean initPageBool = massCreateCon.dummyVar;
            
             // Start testing user actions
            pageParams.put(massCreateCon.PARAM_RTID, 'ASI_TnE_VN_Claim_Detail');
            
            integer recordIndex= 0;
            for (integer i = 0; i< massCreateCon.theRecordTypeElementList.size(); i++)
            {
                system.debug('massCreateCon.theRecordTypeElementList IS ' +  massCreateCon.theRecordTypeElementList.get(i));
                if (massCreateCon.theRecordTypeElementList.get(i).myRecordList.size() > 0)
                {
                    system.debug('ID IS ' +  massCreateCon.theRecordTypeElementList.get(i).myRecordList.get(0).id);
                    system.debug(' massCreateCon.theRecordTypeElementList.get(i).myRecordList.get(0) IS ' +  massCreateCon.theRecordTypeElementList.get(i).myRecordList.get(0));
    
                    recordIndex = i;
                    break;
    
                }
            }

            pageParams.put(massCreateCon.PARAM_TRID, massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList.get(0).id);     
            massCreateCon.enableForEdit();
            massCreateCon.cloneRow();
            massCreateCon.addNewRow();
            pageParams.put(massCreateCon.PARAM_RTID, 'ASI_TnE_VN_Claim_Detail');
            List<ASI_TnE_MassCreateAndUpdateController.TableRow> recordList = massCreateCon.theRecordTypeElementList.get(recordIndex).myRecordList;
            pageParams.put(massCreateCon.PARAM_TRID, recordList.get(recordList.size() - 1).id);
            massCreateCon.removeNew();        
            massCreateCon.addMoreBlankRows();
            
            // Save
            massCreateCon.commitAll();
            massCreateCon.triggerPageBlockAction();
            massCreateCon.refresh();
            massCreateCon.clearAll();
            
            Test.stoptest();
        }
    }