/*********************************************************************************
 * Name:ASI_CRM_SG_AssignWineCat_Batch
 * Description: Check if each type of price/cost exist in SKU, and send email
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-03-29       Laputa: Vincent		     Created
*********************************************************************************/
global class ASI_CRM_SG_AssignWineCat_Batch implements Database.Batchable<sObject>, Database.stateful {

    private static final String SKU_RECORD_TYPE = 'ASI_CRM_SG_SKU';

    private static final String WINECATEGORY_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_CRM_SG_Wine_Category__cASI_CRM_SG_Wine_Category');

    public static final map<String, integer> CAT_DIGIT = new map<String, integer>{
        'Wine'=>5,
        'Champagne'=>3          
    };

    global map<string, string> map_skuCode_wineCat = new map<string, string>();
    global list<ASI_CRM_SG_Wine_Category__c> list_newWineCat = new list<ASI_CRM_SG_Wine_Category__c>();
    
    private static final String SUBJECT = 'New Wine Category Created';
    private static final String TABLE_START = '<table border="1">';
    private static final String TABLE_END = '</table>';
    private static final String TABLE_THEAD = '<thead><tr><th>Wine Category</th><th>Link</th></tr></thead>';
    private static final String TABLE_TBODY_START = '<tbody>';
    private static final String TABLE_TBODY_END = '</tbody>';
    private static final String TABLE_ROW_START = '<tr>';
    private static final String TABLE_ROW_END = '</tr>';
    private static final String TABLE_CELL_START = '<td>';
    private static final String TABLE_CELL_END = '</td>';
    private static final String TICK_SYMBOL = '&#10004;';
    private static final String SFDC_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    private static final String SFDC_EDIT_WITH_RETURL = '/e?retURL=';
    private static final String A_START = '<a href="';
    private static final String A_END = '">Edit Name</a>';

    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        string query = 
            'select id, name, ASI_CRM_SG_Wine_Category__c , ASI_CRM_Wine_Category_Digit__c ' +
            'from ASI_MFM_SKU_Code__c ' +
            'where ASI_HK_CRM_Active__c = true ' +
            'and ASI_HK_CRM_IsPOSProduct__c = false ' +
            'and recordtype.developername = :SKU_RECORD_TYPE ' +
            'and ASI_MFM_Sub_brand__r.ASI_CRM_Wine_Category_Group__c != null ' +
            // order by can sort all SKU (first X digits) which have wine category at the top
            // so that no need other soql to retrieve existing wine category info
            'order by ASI_CRM_Wine_Category_Digit__c asc, ASI_CRM_SG_Wine_Category__c desc nulls last';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext contextInstance, List<Sobject> sObjectList) { 

        List<ASI_MFM_SKU_Code__c> list_sku_all = (List<ASI_MFM_SKU_Code__c>) sObjectList;
        List<ASI_MFM_SKU_Code__c> list_skuToUpdate = new List<ASI_MFM_SKU_Code__c>();
        List<ASI_CRM_SG_Wine_Category__c> list_wineCatToInsert = new List<ASI_CRM_SG_Wine_Category__c>();

        // map all SKU (first X digits) with existing wine category; and
        // if the SKU has wine category already, filter them out from the list
        for (ASI_MFM_SKU_Code__c sku : list_sku_all){
            // skip if the SKU is not eligible to be grouped into wine category
            if (sku.ASI_CRM_Wine_Category_Digit__c == '') {
                continue;
            } else
            // map SKU first X digits with existing wine category
            if (sku.ASI_CRM_SG_Wine_Category__c != null){
                if (map_skuCode_wineCat != null && !map_skuCode_wineCat.containsKey(sku.ASI_CRM_Wine_Category_Digit__c)){
                    map_skuCode_wineCat.put(sku.ASI_CRM_Wine_Category_Digit__c,sku.ASI_CRM_SG_Wine_Category__c);
                }
            } else
            // prepare eligible list of SKU to update; and
            // check if need to create new wine category
            {
                list_skuToUpdate.add(sku);
                if (map_skuCode_wineCat != null && !map_skuCode_wineCat.containsKey(sku.ASI_CRM_Wine_Category_Digit__c)){
                    ASI_CRM_SG_Wine_Category__c wineCategory = new ASI_CRM_SG_Wine_Category__c(
                    	name = sku.ASI_CRM_Wine_Category_Digit__c,
                        recordtypeid = WINECATEGORY_RECORD_TYPE_ID
                    );
                    list_wineCatToInsert.add(wineCategory);
                    map_skuCode_wineCat.put(sku.ASI_CRM_Wine_Category_Digit__c,'');
                }
            }
        }
        
        // if there is any SKU needs to be updated
        if (list_skuToUpdate.size()>0){
            
            // insert new wine category
            if (list_wineCatToInsert.size()>0){
                system.debug(list_wineCatToInsert);
                insert list_wineCatToInsert;
                
                for (ASI_CRM_SG_Wine_Category__c wineCat : list_wineCatToInsert){
                    map_skuCode_wineCat.put(wineCat.name,wineCat.id);
                    list_newWineCat.add(wineCat);
                }
            }
            
            // update SKU's wine category
            for (ASI_MFM_SKU_Code__c sku : list_skuToUpdate){
                sku.ASI_CRM_SG_Wine_Category__c = map_skuCode_wineCat.get(sku.ASI_CRM_Wine_Category_Digit__c);
            }
            system.debug(list_skuToUpdate);
            update list_skuToUpdate;
            
        }
        
    }

    global void finish(Database.BatchableContext contextInstance) {
        system.debug(this.list_newWineCat);
        String table_content = '';
        for (ASI_CRM_SG_Wine_Category__c wineCat : this.list_newWineCat){
            string row = TABLE_ROW_START;
            row += TABLE_CELL_START + wineCat.name + TABLE_CELL_END;
            row += TABLE_CELL_START + A_START + SFDC_URL + wineCat.Id + SFDC_EDIT_WITH_RETURL + wineCat.Id + A_END + TABLE_CELL_END;            
            row += TABLE_ROW_END;
            
            table_content += row;
        }
        
        if (table_content<>''){
            sendEmail(table_content);
        }
    }
    
    public void sendEmail(string content){
        try {
            Messaging.SingleEmailMessage emailPlaceHolder = new Messaging.SingleEmailMessage();
            
            list<string> list_email = new list<string>();
            list<string> list_user = new list<string>();
            
            for (GroupMember u : [select userOrGroupId from GroupMember where group.developername = 'ASI_CRM_SG_Wine_Category_Admin']){
                list_user.add(u.userOrGroupId);
            }
            
            for (user u : [select email from user where id in :list_user]){
                list_email.add(u.email);
            }
            
            emailPlaceHolder.setToAddresses(list_email);
            emailPlaceHolder.setSubject(SUBJECT);
            emailPlaceHolder.setHtmlBody(
                TABLE_START + TABLE_THEAD + TABLE_TBODY_START + content + TABLE_TBODY_END + TABLE_END
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailPlaceHolder });
        } catch(Exception exceptionInstance) {
            System.debug('------ exceptionInstance ------ : ' + exceptionInstance.getMessage());
        }
    }
    
}