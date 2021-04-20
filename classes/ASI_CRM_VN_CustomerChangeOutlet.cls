/*********************************************************************************
 * Name:ASI_CRM_VN_CustomerChangeOutlet 
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 11/11/2015       Laputa: Hank          Created
*********************************************************************************/
public class ASI_CRM_VN_CustomerChangeOutlet {
    public static void execute(list<ASI_CRM_AccountsAdditionalField__c> cusList, Map<Id,ASI_CRM_AccountsAdditionalField__c> cusOldMap){
        Set<Id> cusIdSet = new Set<Id>();
        Set<String> outletTypeSet = new Set<String>();
        String sVNInactiveOutletRecId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet_Inactive');
        String sVNActiveOutletRecId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet');
        Set<Id> Set_NewServicePackIds = new Set<Id>();
        Set<Id> Set_UpdatedServicePackIds = new Set<Id>();
        Set<Id> Set_CurrentServicePackIds = new Set<Id>();
        List<String> listChangedFields = new List<String>();
        Map<Id, String> Map_updsp = new Map<Id, String>();
        Map<Id, String> Map_newsp = new Map<Id, String>();
        Map<Id, String> Map_cursp = new Map<Id, String>();
        String[] oArrayOldSegment = new String[]{'empty','empty','empty/drop','empty'};
		String[] oArrayNewSegment = new String[]{'empty','empty','empty/drop','empty'};
        String sInactivateReason = '';
        
        List<ASI_CRM_Pros_Segmentation__c> newProsList = new List<ASI_CRM_Pros_Segmentation__c>();
        for(ASI_CRM_AccountsAdditionalField__c cus:cusList){
            if(cus.ASI_CRM_VN_OutletType__c != cusOldMap.get(cus.Id).ASI_CRM_VN_OutletType__c ||
                    cus.ASI_CRM_Outlet_Sub_Type__c != cusOldMap.get(cus.Id).ASI_CRM_Outlet_Sub_Type__c ||
                    cus.ASI_TH_CRM_Contracted_With__c != cusOldMap.get(cus.Id).ASI_TH_CRM_Contracted_With__c){
                cus.ASI_CRM_Service_Pack__c = null;
                cusIdSet.add(cus.Id);
                outletTypeSet.add(cus.ASI_CRM_VN_OutletType__c);
            }
            Set_CurrentServicePackIds.add(cus.ASI_CRM_Service_Pack__c);
            //Vincent@2017/03/22 Populate Last Active Service Pack
            if (cus.recordtypeid != cusOldMap.get(cus.id).recordtypeid && cusOldMap.get(cus.id).recordtypeid == sVNInactiveOutletRecId && cus.recordtypeid == sVNActiveOutletRecId) {
                Set_NewServicePackIds.add(cus.ASI_CRM_Service_Pack__c);
            }
            if (cus.recordtypeid == sVNInactiveOutletRecId && cus.ASI_CRM_Service_Pack__c != cusOldMap.get(cus.id).ASI_CRM_Service_Pack__c) {
                if (cus.ASI_CRM_Service_Pack__c != null) {
                	Set_UpdatedServicePackIds.add(cus.ASI_CRM_Service_Pack__c);
                }
            }
        }
        if (Set_UpdatedServicePackIds.size() > 0) {
            List<ASI_CRM_ServicePack__c> list_updsp = [SELECT id, name FROM ASI_CRM_ServicePack__c WHERE id in :Set_UpdatedServicePackIds];
            if (list_updsp.size() > 0) {
                for (ASI_CRM_ServicePack__c idx_updsp : list_updsp) {
                	Map_updsp.put(idx_updsp.id, idx_updsp.name); 
                }
            }
        }
        
        if (Set_NewServicePackIds.size() > 0) {
        	List<ASI_CRM_ServicePack__c> list_newsp = [SELECT id, name FROM ASI_CRM_ServicePack__c WHERE id in :Set_NewServicePackIds];
            if (list_newsp.size() > 0) {
                for (ASI_CRM_ServicePack__c idx_newsp : list_newsp) {
                    Map_newsp.put(idx_newsp.id, idx_newsp.name);
                }
            }
        }
        List<ASI_CRM_ServicePack__c> CurrentServicePackList = [SELECT id, name, ASI_CRM_SG_Segmentation__c FROM ASI_CRM_ServicePack__c WHERE id in :Set_CurrentServicePackIds];
        for (ASI_CRM_ServicePack__c idx : CurrentServicePackList) {
            Map_cursp.put(idx.id, idx.ASI_CRM_SG_Segmentation__c);
        }
        
        
        for(ASI_CRM_AccountsAdditionalField__c cus:cusList){
            //Vincent@2017/03/22 Populate Last Active Service Pack
            if (Map_newsp.size() > 0 && cus.recordtypeid != cusOldMap.get(cus.id).recordtypeid && cusOldMap.get(cus.id).recordtypeid == sVNInactiveOutletRecId && cus.recordtypeid == sVNActiveOutletRecId) {
				System.debug('cus.ASI_CRM_VN_Last_Active_Service_Pack__c := ' + Map_newsp.get(cus.ASI_CRM_Service_Pack__c));
                cus.ASI_CRM_VN_Last_Active_Service_Pack__c = Map_newsp.get(cus.ASI_CRM_Service_Pack__c);
            }
            if (Map_updsp.size() > 0 && cus.recordtypeid == sVNInactiveOutletRecId) {
                cus.ASI_CRM_VN_Service_Pack_Name__c = Map_updsp.get(cus.ASI_CRM_Service_Pack__c);
            }
            if (Map_cursp.size() > 0) {
				cus.ASI_CRM_CN_New_Image__c = Map_cursp.get(cus.ASI_CRM_Service_Pack__c);
            }
        }
        
        Map<String, ASI_CRM_Group_Outlet_Type__c> outletMap = new Map<String, ASI_CRM_Group_Outlet_Type__c>();
        for(ASI_CRM_Group_Outlet_Type__c outlet: [Select Id, ASI_CRM_SG_Group_Outlet_Name__c From ASI_CRM_Group_Outlet_Type__c Where ASI_CRM_SG_Group_Outlet_Name__c In :outletTypeSet And RecordType.DeveloperName = 'ASI_CRM_VN_Group_Outlet_Type']){
            outletMap.put(outlet.ASI_CRM_SG_Group_Outlet_Name__c, outlet);
        }
        for(ASI_CRM_AccountsAdditionalField__c cus:cusList){  
            if(cus.ASI_CRM_VN_OutletType__c != cusOldMap.get(cus.Id).ASI_CRM_VN_OutletType__c ||
                    cus.ASI_CRM_Outlet_Sub_Type__c != cusOldMap.get(cus.Id).ASI_CRM_Outlet_Sub_Type__c ||
                    cus.ASI_TH_CRM_Contracted_With__c != cusOldMap.get(cus.Id).ASI_TH_CRM_Contracted_With__c){
                ASI_CRM_Pros_Segmentation__c ps = new ASI_CRM_Pros_Segmentation__c();
                ps.ASI_CRM_SG_Customer__c = cus.Id;
                ps.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_VN_PROS_Segmentation');
                if(outletMap.get(cus.ASI_CRM_VN_OutletType__c) != null){
                    ps.ASI_CRM_SG_Group_Outlet_Type__c = outletMap.get(cus.ASI_CRM_VN_OutletType__c).Id;
                }
                newProsList.add(ps);
            }                        
        }
        List<ASI_CRM_Pros_Segmentation__c> oldProsList = [Select Id From ASI_CRM_Pros_Segmentation__c Where ASI_CRM_SG_Customer__c In :cusIdSet];
        If(oldProsList.size() > 0){
            delete oldProsList;
        }
        If(newProsList.size() > 0){
            insert newProsList;
        }
    }
    
}