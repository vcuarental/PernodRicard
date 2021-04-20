<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Erro_na_Integracao_do_Pagamento</fullName>
        <description>Erro na Integração do Pagamento</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Erro_de_integracao_Pagamento</template>
    </alerts>
    <fieldUpdates>
        <fullName>Atualiza_pagamento_dinheiro_bloqueado</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Dinheiro_Bloqueado</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza pagamento dinheiro bloqueado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_pagamento_prod_bloqueado</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Bonifica_o_Produtos_Bloqueado</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza pagamento prod bloqueado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Aprovado</fullName>
        <field>Status__c</field>
        <literalValue>Aprovado</literalValue>
        <name>Status Aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Reprovado</fullName>
        <field>Status__c</field>
        <literalValue>Reprovado</literalValue>
        <name>Status Reprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_do_Pagamento</fullName>
        <description>Atualiza para aguardando aprovação</description>
        <field>Status__c</field>
        <literalValue>Aguardando Aprovação</literalValue>
        <name>Status do Pagamento</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_do_Pagamento_final</fullName>
        <field>Status__c</field>
        <literalValue>Aprovado Integrado</literalValue>
        <name>Status do Pagamento final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_do_Pagamento_final2</fullName>
        <field>Status__c</field>
        <literalValue>Reprovado</literalValue>
        <name>Status do Pagamento final2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_do_Pagamento_gerete</fullName>
        <field>Status__c</field>
        <literalValue>Reprovado</literalValue>
        <name>Status do Pagamento gerete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_do_Pagamentocoordenador</fullName>
        <field>Status__c</field>
        <literalValue>Reprovado</literalValue>
        <name>Status do Pagamento coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>aprovado_status</fullName>
        <field>Status__c</field>
        <literalValue>Aprovado Integrado</literalValue>
        <name>aprovado status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Erro de integração Pagamento</fullName>
        <actions>
            <name>Erro_na_Integracao_do_Pagamento</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Erro_na_Integracao_do_Pagamento</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Pagamento__c.Status__c</field>
            <operation>equals</operation>
            <value>Erro de Integração</value>
        </criteriaItems>
        <description>quando ocorrer erro na integração de um pagamento o proprietário será avisado.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Erro_na_Integracao_do_Pagamento</fullName>
        <assignedToType>owner</assignedToType>
        <description>Erro de envio de Pagamento
Favor reenviar novamente</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Erro na Integração do Pagamento</subject>
    </tasks>
</Workflow>
