@IsTest(IsParallel = true)
private class EUR_CRM_SE_ContractPageControllerTest {

    @TestSetup
    static void setup() {

    }

    @IsTest
    static void testSetup() {

    }


    @IsTest
    static void test() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        Contact cont = makeContact(acc);
        insert cont;
        EUR_CRM_Contract__c contr = makeContract(acc, cont);
        insert contr;
        EUR_CRM_Mechanic_Type__c mecType = makeMechanicType();
        insert mecType;
        mecType = [
            SELECT Id, Name, EUR_CRM_Country_Code__c, RecordType.DeveloperName
            FROM EUR_CRM_Mechanic_Type__c
            WHERE Id = :mecType.Id
        ];
        System.debug('Country code:' + mecType.EUR_CRM_Country_Code__c);
        System.debug('RecordType.DeveloperName:' + mecType.RecordType.DeveloperName);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contr);
        EUR_CRM_SE_ContractPageController controller = new EUR_CRM_SE_ContractPageController(stdCtrl);
        String mechanicTypeName = controller.mechanicTypeName;
        Set<String> machanicTypes = controller.getMechanicTypes();


    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'test'
            ,   EUR_CRM_Status__c = 'Active'
            ,   EUR_CRM_Postal_Code__c = '00000'
        );
    }

    private static Contact makeContact(EUR_CRM_Account__c acc) {
        return new Contact(
            EUR_CRM_Account__c = acc.Id
            ,   LastName = 'testContact'
        );
    }

    private static EUR_CRM_Contract__c makeContract(EUR_CRM_Account__c acc, Contact cont) {
        return new EUR_CRM_Contract__c(
            EUR_CRM_Start_Date__c = Date.today()
        ,   EUR_CRM_End_Date__c = Date.today().addDays(1)
        ,   EUR_CRM_Payment_Method__c = 'Monthly'
        ,   EUR_CRM_Account__c = acc.Id
        ,   EUR_CRM_Contact__c = cont.Id
        ,   EUR_CRM_Nominated_Supplier__c = acc.Id
        );
    }

    private static EUR_CRM_Mechanic_Type__c makeMechanicType() {
        RecordType rt = [SELECT Id From RecordType Where DeveloperName ='EUR_SE_Mechanic_Type' LIMIT 1];
        return new EUR_CRM_Mechanic_Type__c(
            Name = 'Pouring Wine'
        ,   RecordTypeId = rt.Id
        );
    }

}