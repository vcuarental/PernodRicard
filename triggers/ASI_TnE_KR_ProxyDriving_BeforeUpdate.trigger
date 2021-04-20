trigger ASI_TnE_KR_ProxyDriving_BeforeUpdate on ASI_TnE_Proxy_Driving_Request__c (Before Update) {
    
    ASI_TnE_KR_ProxyDriving_TriggerClass.beforeUpdateMethod(Trigger.new);
}