/*******************************************************************************
 *  Summary         : 促销付款申请对于大数据量,批量删除付款申请行明细数据
 *  Refer Object    : 
 *  Author          : Zhonghui Li
 *  CreatedDate     : 2020-09-22
 *  Change Log      : 
 ******************************************************************************/
global without sharing class ASI_CRM_CN_PromotionDataDeleteBatch implements Database.Batchable<sObject> {
    public String query;

    global ASI_CRM_CN_PromotionDataDeleteBatch() {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<ASI_TH_CRM_PaymentRequestLineItem__c> scope) {
        List<ASI_CRM_Module__c> deleteModuleList = new List<ASI_CRM_Module__c>();
        Set<Id> modulesSet = new Set<Id>();
        // 删除相关module
        for(ASI_TH_CRM_PaymentRequestLineItem__c pay : scope)
        {
            if (String.isNotBlank(pay.ASI_CRM_Module__c)) {
                modulesSet.add(pay.ASI_CRM_Module__c);
            }
        }
        deleteModuleList = [select Id from ASI_CRM_Module__c where Id in: modulesSet and ASI_CRM_Line_Type__c =: 'PSF'];
        delete scope;
        delete deleteModuleList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}