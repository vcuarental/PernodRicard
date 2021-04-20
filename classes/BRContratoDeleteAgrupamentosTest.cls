/*************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck  Date:02/09/2013    *
**************************************************************************/

@istest
public with sharing class BRContratoDeleteAgrupamentosTest {

    static testMethod void unitTest() {
    
        String rtContrato = RecordTypeForTest.getRecType('LAT_Contract__c', 'OnTradeContratoNaoAprovado');
        String rtAgrup = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        
        UDC__c regional = new UDC__c(      
            CodDefUsuario__c = '1',    
            CodProd__c     = '01',     
            CodUs__c     = '01',    
            Internal_Id__c   = '01-01',      
            RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard')     
        );
        
        insert regional;  
              
        Account acc = new Account(    
            Name = 'Teste',
            Rating = 'Cliente',
            Status__c = 'Cliente cadastrado no JDE',
            CNPJ__c = '42034480000151',
            Regional__c = regional.Id, 
            Segmentation_Type_on_trade__c = 'Restaurante',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')
        );  
          
        insert acc;
          
        LAT_Contract__c contrato = new LAT_Contract__c(        
            RecordTypeId = rtContrato,
            Account__c = acc.Id,  
            Status__c = 'Não aprovado',  
            ROI_Comentarios_Negativo__c = 'Teste',    
            StartDate__c = System.today()
        );
        insert contrato;
        
        contrato.RecordTypeId = rtContrato;
        
        update contrato;
                
        Agrupamento_Fiscal_Year__c agrup = new Agrupamento_Fiscal_Year__c( 
            RecordTypeId = rtAgrup,
            LAT_Contract__c = contrato.id,
            Numero_da_D_A__c = 200,
            valor_total__c = 1000
        );
      
        insert agrup;   
        
   }
   
}