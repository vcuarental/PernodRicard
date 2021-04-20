/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
* Bloqueia que sejam criadas duas ou mais distribuição de valores para o mesma 
* cláusula na mesma data.
* 
* NAME: DistribuicaoValoresBloqueiaMesmaData.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 25/10/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger DistribuicaoValoresBloqueiaMesmaData on Distribui_o_de_Valores__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    //Declaração de variável
    Id idRecTypeDist = RecordTypeForTest.getRecType( 'Distribui_o_de_Valores__c' , 'BRA_Standard' );
    List< Distribui_o_de_Valores__c > listDist = new List< Distribui_o_de_Valores__c >();
    List< Distribui_o_de_Valores__c > listDistribuicao = new List< Distribui_o_de_Valores__c >();
    List< String > listIdDistribuicao = new List< String >();
    List< String > listIdClausula = new List< String >();
    Map< String, Distribui_o_de_Valores__c > mapDistribuicao = new Map< String, Distribui_o_de_Valores__c >();
    List< Date > listDatas = new List< Date >();
    List< Integer > listMes = new List< Integer >();
    
    for(Distribui_o_de_Valores__c dist : trigger.new ){
        if( dist.RecordTypeId == idRecTypeDist ){
            listIdDistribuicao.add( dist.Id );
            listDist.add( dist );
            listIdClausula.add( dist.Clausulas_do_Contrato__c );
        }
    }
    
    listDistribuicao = [SELECT Id, Data_de_Referencia_para_Apuracao__c, Clausulas_do_Contrato__c 
     FROM Distribui_o_de_Valores__c WHERE Id <>: listIdDistribuicao 
     AND Clausulas_do_Contrato__c =: listIdClausula AND RecordTypeId =: idRecTypeDist];
    
    if( listDistribuicao.size() > 0 ){
        for(Distribui_o_de_Valores__c dist : listDist ){
            for( Distribui_o_de_Valores__c d : listDistribuicao ){
                if( dist.Data_de_Referencia_para_Apuracao__c.month() == d.Data_de_Referencia_para_Apuracao__c.month() 
                   && dist.Clausulas_do_Contrato__c == d.Clausulas_do_Contrato__c ){
                    dist.addError('Não é possível criar Valores de Distribuição no mesmo mês.');
                }
            }
        }
    }
 }
}