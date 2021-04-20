public class ASI_KOR_SRPaymentSettlementValidation extends ASI_KOR_TriggerAbstract{

  public ASI_KOR_SRPaymentSettlementValidation() {
    super('ASI_KOR_SRPaymentSettlementValidation');
  }
  
  public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    if (tAction == TriggerAction.BEFORE_INSERT) {
        
        integer count = 0;
        for(ASI_KOR_SR_Payment_Settlement_Header__c newValues : (List<ASI_KOR_SR_Payment_Settlement_Header__c>)sObjList){
         
         if(count==0) {
             /*
             List<ASI_KOR_NSD_Payment_Settlement_Header__c> nsd =[Select id, ASI_KOR_SYS_Cut_off_date__c From ASI_KOR_NSD_Payment_Settlement_Header__c where ASI_KOR_Month__c = :newValues.ASI_KOR_Month__c and ASI_KOR_Year__c = :newValues.ASI_KOR_Year__c];
			*/        
             user u = [select id, ASI_KOR_User_Region_Name__c from user where id = :newValues.ownerid];
             List<ASI_KOR_RSD_Payment_Settlement_Header__c> nsd =[Select id, ASI_KOR_SYS_Cut_off_date__c From ASI_KOR_RSD_Payment_Settlement_Header__c where ASI_KOR_Month__c = :newValues.ASI_KOR_Month__c and ASI_KOR_Year__c = :newValues.ASI_KOR_Year__c and ASI_KOR_Region__c = :u.ASI_KOR_User_Region_Name__c];
			if(nsd.size()>0){
                if(nsd.get(0).ASI_KOR_Sys_Cut_off_date__c==null)newValues.addError('Payment Settlement for Year: '+ newValues.ASI_KOR_Year__c + ' and Month: ' + newValues.ASI_KOR_Month__c + ' has not started.'   );
             }else{
                newValues.addError('Payment Settlement for Year: '+ newValues.ASI_KOR_Year__c + ' and Month: ' + newValues.ASI_KOR_Month__c + ' has not started.'   );
             }
         }
        
         count++;
       
       
        }

    }
    
  }

}