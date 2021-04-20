<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Atualizar_campo_ME</fullName>
        <description>Atualiza o campo picklist ME</description>
        <field>Sistema__c</field>
        <literalValue>ME</literalValue>
        <name>Atualizar campo ME</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualizar_campo_SCV</fullName>
        <description>atualiza campo com o SCV</description>
        <field>Sistema__c</field>
        <literalValue>SCV</literalValue>
        <name>Atualizar campo SCV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ME</fullName>
        <actions>
            <name>Atualizar_campo_ME</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Investimento_Bonificacao_e_Pagamento__c.Sistema__c</field>
            <operation>equals</operation>
            <value>ME</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCV</fullName>
        <actions>
            <name>Atualizar_campo_SCV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Investimento_Bonificacao_e_Pagamento__c.Sistema__c</field>
            <operation>equals</operation>
            <value>SCV</value>
        </criteriaItems>
        <description>Atualizar campo se for SCV</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
