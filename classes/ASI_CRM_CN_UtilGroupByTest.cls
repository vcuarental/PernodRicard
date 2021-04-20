/***************************************************************************************************************************
* Name:        ASI_CRM_CN_UtilGroupByTest 
* Description: Test class for ASI_CRM_CN_UtilGroupBy
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-08-29       Canter Duan             Created
****************************************************************************************************************************/
@isTest
public class ASI_CRM_CN_UtilGroupByTest {
    @testSetup static void setup() {
        test.startTest();
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
       
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',
                                                                     RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                                                                     ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtWS,
            Name='TEST',
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id, 
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium', 
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c = newChannel.Id));

        insert a2s;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c ();
        insert subBrand;
        
        list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        for(integer i=1; i<5; i++) {
            svols.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = a2s[0].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = system.today().addMonths(-i)));
            svols.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = a2s[1].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = system.today().addMonths(-i)));
            svols.add(new ASI_CRM_Subbrand_Volume__c(
                ASI_CRM_Account__c = a2s[1].Id,
                ASI_CRM_Subbrand__c = subBrand.Id,
                ASI_CRM_End_Date__c = system.today().addMonths(-i)));
        }
        insert svols;
    }
    static testmethod void ASI_CRM_CN_UtilGroupByTest(){
        List<ASI_CRM_Subbrand_Volume__c> volList = new List<ASI_CRM_Subbrand_Volume__c>([select id,ASI_CRM_Account__c from ASI_CRM_Subbrand_Volume__c]);
        Map<Id, List<SObject>> mapvalues = ASI_CRM_CN_UtilGroupBy.groupByIds('ASI_CRM_Account__c',volList);
        Map<String, List<SObject>> mapvalues2 = ASI_CRM_CN_UtilGroupBy.groupByStrings('ASI_CRM_Account__c',volList);
        String values = ASI_CRM_CN_UtilGroupBy.getValuesFromFieldNames('ASI_CRM_Account__c',volList[0]);
    }
}