/*********************************************************************************
 * Name : ASI_CRM_SG_Till_Date_Performance_Summary_ReportController.js
 * Description : Controller for "Till Date Performance" report button on Contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/07/2020       Wilken Lee              [WL 1.0] Change to windows.open to resolve font size issue
*/
({
    doInit : function(component, event, helper) {
        var action = component.get("c.getContract");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            console.log('@#'+JSON.stringify(data));
             $A.get("e.force:closeQuickAction").fire();
            if(data){
                if(data.ASI_CRM_Contract_Exist_Before_RTM__c == true){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "https://hkazap05.pernod-ricard-asia.com:443/analytics/saw.dll?GO&Action=Extract&Path=/shared/PRSG/Report/Till%20Date%20Performance%20Summary%20Report&P0=1&P1=eq&P2=\"ASI_TH_CRM_CONTRACT\".\"ROWID\"&P3=\""+component.get("v.recordId")+"\""
                    });
                    urlEvent.fire();
                }
                else if(data.ASI_CRM_Contract_Exist_Before_RTM__c == false){
                    /*[WL 1.0 BEGIN]*/
                     /*var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/apex/ASI_CRM_SG_ContractComparison_Page?BASE_CONTRACT_ID="+component.get("v.recordId")+"&showComparison=true&submitRTM=1"
                    });
                    urlEvent.fire();*/
                     window.open("/apex/ASI_CRM_SG_ContractComparison_Page?BASE_CONTRACT_ID="+component.get("v.recordId")+"&showComparison=true&submitRTM=1");
                    /*[WL 1.0 END]*/
                }              
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Unexpected error occurred"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})