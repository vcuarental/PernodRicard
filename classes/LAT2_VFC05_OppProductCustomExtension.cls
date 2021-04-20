/*************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_VFP05_OppProductCustomExtension
* Descripcion: extencion de la pagina LAT_VFP05_OppProductCustomExtension
* Fecha: 28/01/2014 
**************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class LAT2_VFC05_OppProductCustomExtension{

    public List<LAT_OpportunityLineItem__c> listOlis {get; set;}
    public List<Schema.FieldSetMember> lFields {get; set;}
    public Boolean isBR {get; set;}
    
    private LAT_Opportunity__c opp;
    private Set<Id> RtsBR;
    private Set<Id> RtsMX;
        
    public LAT2_VFC05_OppProductCustomExtension(ApexPages.StandardController controller){
        
        opp = (LAT_Opportunity__c)controller.getRecord();
        Id oppId = opp.Id;
        
        RtsBR = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c', new Set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'}); 
        RtsMX = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c', new Set<String>{'LAT_MX_OPP_NewOrder', 'LAT_MX_OPP_HeaderBlocked', 'LAT_MX_OPP_OrderBlocked'});    
        
        lFields = new List<Schema.FieldSetMember>();
        isBR = false;
        if(RtsBR.contains(opp.RecordTypeId)){
            lFields = SObjectType.LAT_OpportunityLineItem__c.FieldSets.LAT_BR_OppProductCustom.getFields();
            isBR = true;
        }else if(RtsMX.contains(opp.RecordTypeId)){
            lFields = SObjectType.LAT_OpportunityLineItem__c.FieldSets.LAT_MX_OppProductCustom.getFields();
        }
        
        String query = 'SELECT Id ';
        for (Schema.FieldSetMember f : lFields) {
            query += ', ' + f.getFieldPath();
        }
        
        query += ',  LAT_Product__r.Name';
        if(RtsBR.contains(opp.RecordTypeId)){
            query += ' FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: oppId ORDER BY LAT_NROrderLine__c, LAT_Product__r.Name';
        }else{
            query += ' FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: oppId ORDER BY LAT_NROrder_Item__c, LAT_Product__r.Name';
        }        
        
        listOlis = DataBase.query(query);
    }

}