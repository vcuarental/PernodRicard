public class ASI_FOC_CN_SOA_RegenerateFOCCtrl {

    public ASI_FOC_Request_Item__c focItem {get;set;}
    
    public ASI_FOC_CN_SOA_RegenerateFOCCtrl(ApexPages.StandardController stdController){
		focItem = new ASI_FOC_Request_Item__c();
    }
    
    public PageReference submit(){
        system.debug('FOC: ' + focItem.ASI_FOC_Request_Order__c);        
        
        ASI_FOC_Free_Goods_Request__c req = [select id, ASI_FOC_Request_Status__c, ASI_FOC_JDE_Order_Number__c from ASI_FOC_Free_Goods_Request__c where id = :focItem.ASI_FOC_Request_Order__c];
        
         if (req.ASI_FOC_Request_Status__c == 'Approved by Logistic' && req.ASI_FOC_JDE_Order_Number__c == null){
                    ASI_SOA_Setting__c customSetting = ASI_SOA_Setting__c.getValues('ASI_FOC_CN_EnableSOAInterface');

             if (customSetting != null && customSetting.ASI_SOA_Enable__c == true){
                 ASI_FOC_CN_Invoke_SOA.invokeChinaFOCSOA(req.Id);
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'INFO: Free Goods has been re-interfaced.');
            	ApexPages.addMessage(myMsg);
             }
         }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Free Goods can be re-interfaced only if status is [Approved by Logistics] and JDE Order Number is blank .');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
}