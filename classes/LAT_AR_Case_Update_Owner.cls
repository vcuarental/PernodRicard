public class LAT_AR_Case_Update_Owner {

    /***
     * Nombre del metodo: UpdateCaseOwner
     * Descripcion: Cuando un Caso de inactivacion de cliente es creado por Inteligencia Comercial, 
     *              se debe cambiar el Owner al dueño de la Account
     * Desarrollador: nico@zimmic.com
     * Fecha: 21/08/2014
     * Modo: after insert
     ***/
     /********************************************************************************
    * 
    * MIGRACION LICENCIAS 
    * AUTHOR: ZIMMIC                     DATE: 02/11/2016
    * AUTHOR: ZIMMIC                     DATE: 05/12/2016
    *
    ********************************************************************************/
    public static void UpdateCaseOwner (List<Case> triggerNew){
         String recordTypeARG = Global_RecordTypeCache.getRtId('Case' + 'CSE_1_AccountAlteration_ARG');
         String recordTypeUY = Global_RecordTypeCache.getRtId('Case' + 'CSE_2_AccountAlteration_URU');
         String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
         
         if(profileName.equals('ARG_Int Comercial') || profileName.equals('LAT_AR2_IntComercial')){
             List<id> tmpIds = new List<id>();
             List<CaseShare> toUpdate = new List<CaseShare>();
             
             for (Case c : triggerNew){
                 tmpIds.add(c.id);
             }
             List<Case> cases = [Select id,reason, RecordTypeId,Account.OwnerId from Case where id in: tmpIds];
             
             for (Case c : cases){
                 if ((recordTypeARG.equals(c.RecordTypeId)|| recordTypeUY.equals(c.RecordTypeId))
                     && (profileName.equals('ARG_Int Comercial') || profileName.equals('LAT_AR2_IntComercial')) 
                     && 'Solicitação de inativação de cliente'.equals(c.reason)) {
                         CaseShare newCaseShare = new CaseShare(
                            UserOrGroupId = c.Account.OwnerId,
                            CaseAccessLevel='Read',
                            CaseId = c.id
                        );
                        toUpdate.add(newCaseShare);
                 }
             }  
             insert toUpdate;
         }
         
    }


    //MIGRATED 02/11/2016 
    public static void UpdateCaseOwner (List<Lat_Case__c> triggerNew){
         String recordTypeARG = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_1_AccountAlteration_ARG');
         String recordTypeUY = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_2_AccountAlteration_URU');
         String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
         
         if(profileName.equals('ARG_Int Comercial') || profileName.equals('LAT_AR2_IntComercial')){
             List<id> tmpIds = new List<id>();
             List<LAT_Case__Share> toUpdate = new List<LAT_Case__Share>();
             
             for (Lat_Case__c c : triggerNew){
                 tmpIds.add(c.id);
             }
             List<Lat_Case__c> cases = [Select id,LAT_Reason__c, RecordTypeId,LAT_Account__c,LAT_Account__r.OwnerId from Lat_Case__c where id in: tmpIds];
             
             for (Lat_Case__c c : cases){
                if ((recordTypeARG.equals(c.RecordTypeId)|| recordTypeUY.equals(c.RecordTypeId))
                 && (profileName.equals('ARG_Int Comercial') || profileName.equals('LAT_AR2_IntComercial'))
                 && 'Solicitação de inativação de cliente'.equals(c.LAT_Reason__c)) {
                    LAT_Case__Share newCaseShare = new LAT_Case__Share();
                    newCaseShare.UserOrGroupId = c.LAT_Account__r.OwnerId;
                    newCaseShare.AccessLevel='Read';
                    newCaseShare.ParentId  = c.id;
                    toUpdate.add(newCaseShare);
                 }
             }  
             insert toUpdate;
         }
         
    }

    public static void shareRecordsWithAccountOwner(List<Lat_Case__c> triggerNew){
            
        List<id> tmpIds = new List<id>();
        List<LAT_Case__Share> toUpdate = new List<LAT_Case__Share>();

        for (Lat_Case__c c : triggerNew){
             tmpIds.add(c.id);
        }
        List<Lat_Case__c> cases = [Select id, LAT_Account__c, LAT_Account__r.OwnerId from Lat_Case__c where id in: tmpIds];
         
        for (Lat_Case__c c : cases){
            LAT_Case__Share jobShr = new LAT_Case__Share();
            jobShr.ParentId  = c.id;
            jobShr.UserOrGroupId = c.LAT_Account__r.OwnerId;
            jobShr.AccessLevel='Read';
            jobShr.RowCause = 'Manual';
            toUpdate.add(jobShr);
        }

        if (!toUpdate.isEmpty()){

            try{
                Database.insert(toUpdate,false);
            }catch(exception ex){
                LAT_DebugUtil debugUtil = new LAT_DebugUtil();
                debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
                debugUtil.setOrigin('LAT CASES');
                debugUtil.insertDebug();
            }
        }
    }

}