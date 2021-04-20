public with sharing class ASI_MFM_CN_POSM_ReturnRequest_NewPageCls {

    public ASI_MFM_CN_POSM_ReturnRequest_NewPageCls(apexpages.standardController sc) {
    }
    
    public PageReference redirect() {
        //sample: /aHB/e?retURL=%2FaHB%2Fo&RecordType=012M00000009O3g&ent=01IM00000006ADW&Name=Automated%2C+Do+not+change&nooverride=1
        //string sURL = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_prefix + '&CF' + field_id + '=' + prefix_name + '&Name=' + 'Automated, Do not change';
        string ObjID = sObjectType.ASI_MFM_POSM_Return_Request__c.getKeyPrefix();
        String RecordtypeID = ApexPages.currentPage().getParameters().get('RecordType');
        
        string sURL = '/' + ObjID + '/e?retURL=%2F' + ObjID + '%2Fo&RecordType=' + RecordtypeID + '&Name=Automated%2C+Do+not+change&nooverride=1';
        return new PageReference(sURL);
    }
    
}