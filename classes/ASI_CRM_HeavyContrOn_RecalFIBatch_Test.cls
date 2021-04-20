/*********************************************************************************
* Name: ASI_CRM_HeavyContrOn_RecalFIBatch_Test
* Description: Test Class for ASI_CRM_HeavyContractOn_RecalFIBatch
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 27/05/2019       Rutuja Bardapurkar            Created
*/


@Istest
public class ASI_CRM_HeavyContrOn_RecalFIBatch_Test {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createRunningNumber();
        
    }
    
    public static testMethod void testController() {
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c,LanguageLocaleKey FROM USER WHERE id =:UserInfo.getUserId()];
        currentUser.LanguageLocaleKey='zh_CN';
        update currentUser;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;
        
        Set<Id> contractIds = new Set<Id>();
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType
                         FROM RecordType
                         WHERE DeveloperName = 'ASI_CRM_CN_Contract'
                         AND SobjectType = 'ASI_TH_CRM_Contract__c'];
        
        ASI_CRM_Region__c CRegion = new ASI_CRM_Region__c();
        insert CRegion;
        
        ASI_CRM_Division__c CDivision = new ASI_CRM_Division__c();
        CDivision.ASI_CRM_Region__c = CRegion.Id;
        insert CDivision;
        
        ASI_CRM_CN_Area__c CCArea = new ASI_CRM_CN_Area__c();
        CCArea.ASI_CRM_Division__c = CDivision.Id;
        insert CCArea;
        
        ASI_CRM_City__c CCCity = new ASI_CRM_City__c();
        CCCity.ASI_CRM_CN_Area__c = CCArea.Id;
        insert CCCity;
        
        ASI_CRM_AccountsAdditionalField__c AAF = new ASI_CRM_AccountsAdditionalField__c();
        AAF.ASI_CRM_CN_CCity__c = CCCity.Id;
        try {
        insert AAF;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        System.debug(rt);
        ASI_TH_CRM_Contract__c CContr1 = new ASI_TH_CRM_Contract__c();
        CContr1.RecordTypeId = rt.Id;
        if(AAF.Id != null) {
        CContr1.ASI_CRM_CN_Outlet_WS__c = AAF.Id;
        }
        CContr1.ASI_CRM_CN_PO_Start_Date__c = date.today();
        CContr1.ASI_CRM_CN_PO_End_Date__c = date.today();
        insert CContr1;
        
        
        Id userid = UserInfo.getUserId();
        List<ASI_TH_CRM_Contract__c> Contrlst = new list<ASI_TH_CRM_Contract__c>();
        ASI_TH_CRM_Contract__c CContr = new ASI_TH_CRM_Contract__c();
        CContr.OwnerId = userid;
        CContr.RecordTypeId = rt.Id;
        CContr.ASI_CRM_CN_Outlet_WS__c = AAF.Id;
        CContr.ASI_CRM_CN_PO_Start_Date__c = date.today();
        CContr.ASI_CRM_CN_PO_End_Date__c = date.today();
        CContr.ASI_CRM_CN_V0_0_PO_version__c = CContr1.Id;
        Contrlst.add(CContr);
        insert Contrlst;
        //contractIds.add(Contrlst[0].id);
        contractIds.add(CContr.Id);
        
        Test.startTest();
        
        ASI_CRM_HeavyContractOn_RecalFIBatch HCR = new ASI_CRM_HeavyContractOn_RecalFIBatch(contractIds);
        HCR.start(BC);
        HCR.finish(BC);
        HCR.execute(BC, Contrlst);
        
        Test.stopTest();
       
    }
  
}