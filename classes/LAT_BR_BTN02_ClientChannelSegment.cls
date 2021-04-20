/**********************************************************************************************************************
*                                       Company: ValueNet
*-----------------------------------------------------------------------------------------------------------------------
*   Clase que funciona con el boton "New Client Channel Segmentation" en el objeto LAT_BR_ClientChannelSegmentation__c
***********************************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
global with sharing class LAT_BR_BTN02_ClientChannelSegment {
    
    webService static String validationOfNewSeg(String IdAccount){
        
        List<LAT_BR_ClientChannelSegmentation__c> listOfSeg = [SELECT id, Name, LAT_BR_ApprovalStatus__c, LAT_BR_Client__r.Name, LAT_BR_Client__r.Status__c FROM LAT_BR_ClientChannelSegmentation__c WHERE LAT_BR_Client__c =: IdAccount];
        Account accQuery = [SELECT id, Name, RecordTypeId FROM Account WHERE id =: IdAccount LIMIT 1];
        String idOfAccLookup =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='LAT_BR_Client__c' AND ObjectApiName__c='LAT_BR_ClientChannelSegmentation__c'].FieldId__c;
        Set<Id> setProfileId = new Set<Id>();
        
        setProfileId.add(LAT_GlobalProfileCache.getStandardAdminProfileId());
        setProfileId.add(LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator'));
        setProfileId.add(LAT_GlobalProfileCache.getProfileIdByName('Business administrator'));
        setProfileId.add(LAT_GlobalProfileCache.getProfileIdByName('Vendas'));
        setProfileId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_BR2_Vendas'));
        setProfileId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator'));
        setProfileId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator'));
        if(!setProfileId.contains(Userinfo.getProfileId())){
            return Label.LAT_BR_BTN01_CCS_001;
            //Label.LAT_BR_BTN01_CCS_001 = "Your profile doesn't have the required permissions to create a new Segmentation"
        }
        
        for(LAT_BR_ClientChannelSegmentation__c seg: listOfSeg){

            if(seg.LAT_BR_ApprovalStatus__c != 'Rejected'){
                if(seg.LAT_BR_ApprovalStatus__c == 'Draft'){
                    return Label.LAT_BR_BTN01_CCS_002;
                    //Label.LAT_BR_BTN01_CCS_002 = "There already is a Segmentation with status Draft."
                }
                if((seg.LAT_BR_Client__r.Status__c == 'Novo cadastro' || seg.LAT_BR_Client__r.Status__c == 'Não aprovado') && !listOfSeg.isEmpty()){
                    return Label.LAT_BR_BTN01_CCS_004;
                    //Label.LAT_BR_BTN01_CCS_003 = "There is already a segmentation in use."
                }
                if(seg.LAT_BR_ApprovalStatus__c != 'Active' && seg.LAT_BR_ApprovalStatus__c != 'Inactive'){
                    return Label.LAT_BR_BTN01_CCS_005;
                    //Label.LAT_BR_BTN01_CCS_005 = "Favor revisar as Segmentações do cliente, pois já existe alguma em Preenchimento, Reprovada ou em Processo de Aprovação.."
                }
                /*if(seg.LAT_BR_Client__r.Status__c != 'Cliente cadastrado no JDE' && seg.LAT_BR_Client__r.Status__c != 'Cliente cadastrado no CRM'){
                    return Label.LAT_BR_BTN01_CCS_003;
                    //Label.LAT_BR_BTN01_CCS_003 = "Status has to be "Novo cadastro" or "Cliente cadastrado no JDE" in order to create a new Segmentation."
                }*/
            }

            
        }
        
        String prefixObj = LAT_BR_ClientChannelSegmentation__c.SObjectType.getDescribe().getKeyPrefix();   
        String urlReturn = '/' + prefixObj + '/e?';
        if(accQuery.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade')){ 
            urlReturn += '&RecordType=' + Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OnTrade');
        }else{
            urlReturn += '&RecordType=' + Global_RecordTypeCache.getRtId('LAT_BR_ClientChannelSegmentation__c' + 'LAT_BR_CCS_OffTrade');
        }
        urlReturn += '&' + idOfAccLookup + '=' + EncodingUtil.urlEncode(accQuery.Name,'UTF-8');
        urlReturn += '&' + idOfAccLookup + '_lkid=' + IdAccount;
        urlReturn += '&retURL=%2F' + IdAccount;
        
        return urlReturn;
    }


    webService static String validationOfSegBeforeAproval(String IdSegmentation){
        
        
        LAT_BR_ClientChannelSegmentation__c seg = [SELECT id, Name, RecordType.DeveloperName, LAT_BR_ApprovalStatus__c, LAT_BR_ONSegment__c, LAT_BR_Client__r.Name, LAT_BR_Client__r.Status__c, LAT_BR_Client__r.Client_code_AN8__c FROM LAT_BR_ClientChannelSegmentation__c WHERE id =: IdSegmentation];
        
        String strRetunr = '';
        if (seg.LAT_BR_Client__r.Client_code_AN8__c == '' || seg.LAT_BR_Client__r.Status__c == 'Novo cadastro') {
            strRetunr = Label.LAT_BR_VFC15_SegChannelApprovalMessage;
        } else {
            
            try {
                Id id1 = UserInfo.getProfileId();
                List <Profile> profileName = [Select Name from Profile where Id =: id1];
                //return strRetunr = 'seg.LAT_BR_Client__r.Status__c : ' + seg.LAT_BR_Client__r.Status__c + ' RecordType.DeveloperName : ' + seg.RecordType.DeveloperName + ' LAT_BR_ONSegment__c : ' + seg.LAT_BR_ONSegment__c + ' LAT_BR_ApprovalStatus__c : ' + seg.LAT_BR_ApprovalStatus__c + ' Profile Name : ' + profileName[0].Name;
                Approval.ProcessSubmitRequest aprovalRequest = new Approval.ProcessSubmitRequest();
                aprovalRequest.setObjectId(seg.id);
                aprovalRequest.setSubmitterId(Userinfo.getUserId());
                Approval.ProcessResult result = Approval.process(aprovalRequest);
                Database.Error[] errors = result.getErrors();
                if (errors != null) {
                    if (errors.size() > 0) {
                        strRetunr = Label.LAT_BR_VFC15_SegChannelApprovalMessage;
                    }               
                }   
            } catch (Exception e) {
                  if (e.getMessage().contains('ALREADY_IN_PROCESS')) {
      
                      strRetunr = Label.LAT_BR_VFC15_SegChannelApprovalMessage2;
                  } else {
                       strRetunr = Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg;
                  }
            } 
        }
        return strRetunr;
        
    }   
}