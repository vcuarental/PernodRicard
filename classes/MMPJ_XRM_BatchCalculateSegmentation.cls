global class MMPJ_XRM_BatchCalculateSegmentation implements Database.Batchable<sObject>
{
    global String query;
    // global List<String> fields;
    global Map<String, List<MMPJ_XRM_Segmentation__mdt>> mapSegmentation;
    // global List<MMPJ_XRM_Segmentation__mdt> listSegmentation;

    global MMPJ_XRM_BatchCalculateSegmentation() {

        // Id rtId = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Viticulteur').getRecordTypeId();
        // Id rtId = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.getRecordTypeInfosByDeveloperName().get('MMPJ_Ext_Vign_Vigneron').getRecordTypeId();

        MMPJ_XRM_Segmentation_Conf__c conf = 	MMPJ_XRM_Segmentation_Conf__c.getOrgDefaults();
        String rtList = String.join(conf.RecordTypes__c.split(','),'\',\'');

        mapSegmentation = new Map<String, List<MMPJ_XRM_Segmentation__mdt>>();
        for (MMPJ_XRM_Segmentation__mdt segmentation : 
                    [
                        SELECT Field_API_Name__c, Interval_start__c, Interval_end__c, Unit__c, Value__c, Multiplier__c, Weighter__c 
                        FROM MMPJ_XRM_Segmentation__mdt
                        WHERE IsActive__c = true
                    ]) {
            
            if (mapSegmentation.containsKey(segmentation.Field_API_Name__c)) {
                List<MMPJ_XRM_Segmentation__mdt> listTemp = mapSegmentation.get(segmentation.Field_API_Name__c);
                listTemp.add(segmentation);
                mapSegmentation.put(segmentation.Field_API_Name__c, listTemp);
            } else {
                mapSegmentation.put(segmentation.Field_API_Name__c, new List<MMPJ_XRM_Segmentation__mdt>{segmentation});
            }
        }

        query = 
            'SELECT Id, ' + String.join(new List<String>(mapSegmentation.keySet()), ', ') + ' ' +
            'FROM MMPJ_Ext_Vign_Societe__c ' +
            'WHERE RecordTypeId In (\'' + rtList + '\') ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {
        Map<String, Schema.SObjectField> mapSocieteSchema = Schema.SObjectType.MMPJ_Ext_Vign_Societe__c.fields.getMap();

        Map<Id, Decimal> mapSurface = new Map<Id, Decimal>();
        Map<Id, Integer> mapNbcontratGlissant = new Map<Id, Integer>();
        for(AggregateResult result : 
                [
                    SELECT MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Livreur__c Societe, SUM(MMPJ_XRM_Surface_Engagee__c) Surface
                    FROM MMPJ_XRM_Ligne_de_contrat__c
                    WHERE MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Livreur__c IN :(List<MMPJ_Ext_Vign_Societe__c>)scope
                    // AND (MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Type_de_contrat__c LIKE '%GLISSANT%' 
                    //     OR MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Type_de_contrat__c LIKE '%SPOT%')
                    AND MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Date_de_debut_du_contrat__c <= TODAY
                    AND (MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Date_de_fin_du_contrat__c >= TODAY 
                        OR MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null) 
                    GROUP BY MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Livreur__c 
                ]
        ) 
        {            
            mapSurface.put((Id)result.get('Societe'), (Decimal)result.get('Surface'));
        }
        for(AggregateResult result : 
                [
                    SELECT MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Livreur__c Societe, COUNT(Id) Nb
                    FROM MMPJ_XRM_Ligne_de_contrat__c
                    WHERE MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Livreur__c IN :(List<MMPJ_Ext_Vign_Societe__c>)scope
                    AND MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Type_de_contrat__c LIKE '%GLISSANT%' 
                    //     OR MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Type_de_contrat__c LIKE '%SPOT%')
                    AND MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Date_de_debut_du_contrat__c <= TODAY
                    AND (MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Date_de_fin_du_contrat__c >= TODAY 
                    OR MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null) 
                    GROUP BY MMPJ_XRM_Contrat__r.MMPJ_Ext_Vign_Livreur__c 
                    ]
                    ) 
        {            
            mapNbcontratGlissant.put((Id)result.get('Societe'), (Integer)result.get('Nb'));
        }
        
        List<MMPJ_Ext_Vign_Societe__c> listSociete = new List<MMPJ_Ext_Vign_Societe__c>();
        for(MMPJ_Ext_Vign_Societe__c societe : (List<MMPJ_Ext_Vign_Societe__c>)scope) {

            societe.MMPJ_XRM_surface_livree__c = mapSurface.get(societe.Id);
            societe.MMPJ_XRM_Nb_Contrats_Glissants__c = mapNbcontratGlissant.get(societe.Id);

            Decimal sum = 0;
            for (String key : mapSegmentation.keySet()) {
                for (MMPJ_XRM_Segmentation__mdt segmentation : mapSegmentation.get(key)) {

                    Schema.SObjectField fieldSchema = mapSocieteSchema.get(segmentation.Field_API_Name__c);

                    Decimal currentValue;
                    if (fieldSchema.getDescribe().getType() == Schema.DisplayType.Boolean) {
                        currentValue = ((Boolean)societe.get(segmentation.Field_API_Name__c) ? 1 : 0);
                    } else if (fieldSchema.getDescribe().getType() == Schema.DisplayType.String 
                                ||fieldSchema.getDescribe().getType() == Schema.DisplayType.Picklist) {
                        currentValue = (societe.get(segmentation.Field_API_Name__c) != null ? Decimal.valueOf((String)societe.get(segmentation.Field_API_Name__c)) : null);
                    } else {
                        currentValue = (Decimal)societe.get(segmentation.Field_API_Name__c);
                    }

                    if ((segmentation.Interval_start__c == segmentation.Interval_end__c && currentValue == segmentation.Interval_start__c) ||
                        (currentValue > segmentation.Interval_start__c && currentValue <= segmentation.Interval_end__c)) {

                        if (segmentation.Multiplier__c) {
                            sum += currentValue * segmentation.Value__c * segmentation.Weighter__c;    
                        } else {
                            sum += segmentation.Value__c * segmentation.Weighter__c;
                        }
                    }
                }
            }

            societe.MMPJ_XRM_Points_segmentation__c = sum;
            listSociete.add(societe);
        }

        update listSociete;
    }

    global void finish(Database.BatchableContext BC)
    {
       
    }
}