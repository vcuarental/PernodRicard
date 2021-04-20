@RestResource(UrlMapping='/ASI_NPL_CN_FirstPOStatusAPI/*')
global without sharing class ASI_NPL_CN_FirstPOStatusAPI {

    @HttpPost
    global static string updateFirstPOStatusByItemGroup(RequestWrapper req){
        if(req.Item_Group_Code != null && req.Item_Group_Code != ''){

            List<ASI_CN_NPL_NPL_Request__c> nplList = [select id, ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c from ASI_CN_NPL_NPL_Request__c where ASI_CN_NPL_Item_Master__r.recordtype.developername in ('ASI_CN_NPL_Item_Master_TypeA', 'ASI_CN_NPL_Item_Master_TypeB') and ASI_CN_NPL_Item_Master__r.ASI_CN_NPL_Item_Goup_Code__c = :req.Item_Group_Code ];

            for(ASI_CN_NPL_NPL_Request__c npl : nplList){

                if(req.PO_Release_Date != null && req.PO_Release_Date != ''){
                    npl.ASI_CN_NPL_PO_Released_Date__c = Date.valueOf(req.PO_Release_Date);
                }
                if(req.Request_ETA_Date != null && req.Request_ETA_Date != ''){
                    npl.ASI_CN_NPL_Request_ETA__c = Date.valueOf(req.Request_ETA_Date);
                }
                if(req.Invoice_Date != null && req.Invoice_Date != ''){
                    npl.ASI_CN_NPL_Invoice_Receipt_Date__c = Date.valueOf(req.Invoice_Date);
                }
                if(req.ETA_Date != null && req.ETA_Date != ''){
                    npl.ASI_NPL_ETA_Domestic__c = Date.valueOf(req.ETA_Date);
                }
                if(req.ATA_Date != null && req.ATA_Date != ''){
                    npl.ASI_CN_NPL_Actual_ETA__c = Date.valueOf(req.ATA_Date);
                }
                if(req.Estimate_Customer_Clearance_Date != null && req.Estimate_Customer_Clearance_Date != ''){
                    npl.ASI_CN_NPL_Estimate_Available_Date__c = Date.valueOf(req.Estimate_Customer_Clearance_Date);
                }
                if(req.Available_Date != null && req.Available_Date != ''){
                    npl.ASI_CN_NPL_Available_Date__c = Date.valueOf(req.Available_Date);
                }
            }
            update nplList;
            //system.debug(nplList);
            //return JSON.serialize(nplList);
            return 'success';
        }else{
            return 'Item_Group_Code is Mandatory';
        }
    }

    global class RequestWrapper{
        Global String Item_Group_Code;
        Global String PO_Release_Date;
        Global String Request_ETA_Date;
        Global String Invoice_Date;
        Global String ETA_Date;
        Global String ATA_Date;
        Global String Estimate_Customer_Clearance_Date;
        Global String Available_Date;
    }

}