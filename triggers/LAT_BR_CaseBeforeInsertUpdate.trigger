/************************************************************************************
*   Company:Valuenet          Developers: Waldemar Mayo          Date:16/10/2013    *
************************************************************************************/

trigger LAT_BR_CaseBeforeInsertUpdate on Case (before update, after insert) {
    String i = '';
 /*   
    //Filtrado de RecordTypes de Brasil
    set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Case', new set<String>{'Termino_de_contrato', 'Contrato_assinatura_de_distrato_do_cliente', 'Contrato_aprovacao_de_proposta', 'Sem_proposta_de_pagamento', 'Novo_cadastro_de_cliente', 'Contrato_entrega_do_contrato', 'Contrato_coleta_de_assinatura_do_cliente_off', 'Contrato_Negociacao_de_cancelamento', 'Contrato_Proposta_de_renovacao', 'Contrato_Processo_de_prorrogacao', 'Proposta_de_pagamento', 'Cliente_inadimplente', 'Contrato_Assinatura_de_distrato_procurador', 'Solicitacoes_e_Reclamacoes', 'Alteracao_cadastro_de_clientes', 'Contrato_coleta_de_assinatura_do_cliente', 'nao_renovacao', 'Contrato_Assinatura_do_procurador', 'Justificativa_de_inadimplencia', 'Contrato_Assinatura_da_diretoria', 'Contrato_assinatura_de_prorrogacao_de_contrato', 'Contrato_nao_renovacao_de_contrato', 'Contrato_conferencia_de_documentacao', 'Gerar_D_A_no_sistema_ME', 'Contrato_renovacao_de_contrato', 'Contrato_Assinatura_de_distrato_diretoria', 'Contrato', 'Contrato_assinatura_prorroga_o_do_cliente', 'Alteracao_rota_de_promotor', 'Cancelar_D_A_no_sistema_ME', 'Inserir_o_Tipo_de_Verba', 'AlterarDAnoSistemaME'});
    List<Case> triggerNew_BR = new List<Case>();
    Map<Id, Case> triggerNewMap_BR = new Map<Id, Case>();
    Map<Id, Case> triggerOldMap_BR;
    for(Case acc: trigger.new){
        if(setIdRt.contains(acc.RecordTypeId) ){
            triggerNew_BR.add(acc);
            triggerNewMap_BR.put(acc.Id, acc);
            if (trigger.isUpdate){
                if(triggerOldMap_BR == null){triggerOldMap_BR = new Map<Id, Case>();}
                triggerOldMap_BR.put(trigger.oldMap.get(acc.id).id, trigger.oldMap.get(acc.id));
            }
        }
    }
    
    //Llamadas a metodos unicos para BR
    if(!triggerNew_BR.isEmpty()){
    	
    	if(trigger.isUpdate && trigger.isBefore){
            LAT_BR_AP01_Case.updateStatusNovoCadastroCliente(triggerNewMap_BR.values());
            LAT_BR_AP01_Case.updateStatusAccount(triggerNewMap_BR.values());
            LAT_BR_AP01_Case.originalOwner(triggerNewMap_BR, triggerOldMap_BR);
        }
    	
        if(trigger.isInsert && trigger.isAfter){
            LAT_BR_AP01_Case.shareWithAccountOwner(triggerNewMap_BR.values());
        }
    }
    */
}