@isTest
public with sharing class LAT_ApprovalProcessSLA_Batch_Test {
	@testSetup
	public static void setup(){
		
		LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
   			name = 'OPP_Verification_Email_Recipients',
    		lat_value__c = 'test@zimmic.com,test@zimmic.com');
		LAT_GeneralConfig__c cfg8 = new LAT_GeneralConfig__c(
   			name = 'BR_ADMIN_Receipients',
    		lat_value__c = 'test@zimmic.com,test@zimmic.com');
		LAT_GeneralConfig__c cfg9 = new LAT_GeneralConfig__c(
   			name = 'AR_ADMIN_Receipients',
    		lat_value__c = 'test@zimmic.com,test@zimmic.com');
		LAT_GeneralConfig__c cfg10 = new LAT_GeneralConfig__c(
   			name = 'MX_ADMIN_Receipients',
    		lat_value__c = 'test@zimmic.com,test@zimmic.com');

        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(
   			name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
   			lat_value__c = 'SELECT Id, Name FROM Account LIMIT 1');
 
        LAT_GeneralConfig__c cfg3 = new LAT_GeneralConfig__c(
   			name = 'OPP_Verification_StatusToCheck',
   			lat_value__c = 'Novo Pedido');

        LAT_GeneralConfig__c cfg4 = new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_OBJECTS',
                    LAT_Value__c = '\'Account\',\'LAT_Contract2__c\',\'LAT_MasiveOwnerHeader__c\'');

        LAT_GeneralConfig__c cfg5 = new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_USER_DAYS_QTY',
                    LAT_Value__c = '5');

        LAT_GeneralConfig__c cfg6 = new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_ADMIN_DAYS_QTY',
                    LAT_Value__c = '4');

        LAT_GeneralConfig__c cfg7 = new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_MANAGER_DAYS_QTY',
                    LAT_Value__c = '3');
		
        insert new List<LAT_GeneralConfig__c> {cfg1, cfg2, cfg3, cfg4, cfg5, cfg6, cfg7, cfg8, cfg9, cfg10 };
	
	}

	@isTest static void test_1() {

		Map<String, String> mapBodyXUsuarios = new Map<String, String>();
		mapBodyXUsuarios.put(UserInfo.getUserId(), 'TEST MSG');
		LAT_ApprovalProcessSLA_Batch.enviarNotificacionUsuarios(mapBodyXUsuarios, 2);
		LAT_ApprovalProcessSLA_Batch.enviarNotificacionManagers(mapBodyXUsuarios, 2);
		LAT_ApprovalProcessSLA_Batch.enviarNotificacionAdmins('TEST MSG', 2);
		LAT_ApprovalProcessSLA_Batch.enviarNotificacionAdminsBR('TEST MSG', 2);
		LAT_ApprovalProcessSLA_Batch.enviarNotificacionAdminsAR('TEST MSG', 2);
		LAT_ApprovalProcessSLA_Batch.enviarNotificacionAdminsMX('TEST MSG', 2);

	}

	@isTest static void test_2() {

    	LAT_MasiveOwnerHeader__c header = new LAT_MasiveOwnerHeader__c();
    	header.LAT_Status__c = 'New';
    	header.LAT_Approver__c = UserInfo.getUserId();
    	insert header;
    	System.debug('%%%% encontrados : ' + [SELECT ProcessInstance.targetobject.name, Actor.email, Actor.Name, ActorId, OriginalActorId, ProcessInstanceId, ProcessInstance.ProcessDefinition.TableEnumOrId, ProcessInstance.targetobjectid, CreatedDate,ProcessInstance.Status FROM ProcessInstanceWorkitem where createddate = LAST_N_DAYS:4 AND ProcessInstance.ProcessDefinition.TableEnumOrId IN ('Account','LAT_Contract2__c') Order by CreatedDate]);
	 	System.debug('%%%% encontrados todos : ' + [SELECT ProcessInstance.targetobject.name, Actor.email, Actor.Name, ActorId, OriginalActorId, ProcessInstanceId, ProcessInstance.ProcessDefinition.TableEnumOrId, ProcessInstance.targetobjectid, CreatedDate,ProcessInstance.Status FROM ProcessInstanceWorkitem] );
	 	Approval.ProcessSubmitRequest ap = new Approval.ProcessSubmitRequest();
        ap.setObjectId(header.Id);
        Approval.ProcessResult result = Approval.process(ap);
		Test.startTest();
 		Database.executeBatch(new LAT_ApprovalProcessSLA_Batch(),20);
 		Test.stopTest();

	}
}